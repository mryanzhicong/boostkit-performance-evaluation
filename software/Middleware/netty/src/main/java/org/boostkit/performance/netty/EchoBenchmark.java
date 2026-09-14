package org.boostkit.performance.netty;

import io.netty.bootstrap.Bootstrap;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.channel.Channel;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.MultiThreadIoEventLoopGroup;
import io.netty.channel.nio.NioIoHandler;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.util.Version;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Single-process Netty echo throughput benchmark.
 *
 * The server side follows the official Netty echo-server pattern: it writes
 * every received buffer straight back and flushes on readComplete.  The
 * client side keeps a fixed per-connection pipeline window in flight; every
 * message is a fixed-size frame of [sequence:8][sendNanos:8][zero payload],
 * which lets the client re-frame the echoed byte stream and measure message
 * throughput plus sampled round-trip latencies without any external
 * dependency beyond the Netty jars themselves.
 *
 * One run measures a single (message size, connection count) combination:
 * after the warmup phase the counters and RTT samples are collected for the
 * configured duration and written to a JSON report consumed by
 * scripts/collect_netty_benchmark.py.
 */
public final class EchoBenchmark {

    static final int HEADER_SIZE = 16;
    static final long SAMPLE_MASK = 1023;

    private final int port;
    private final int messageSize;
    private final int connections;
    private final int pipeline;
    private final int warmupSeconds;
    private final int durationSeconds;
    private final String scenario;
    private final Path output;

    private final AtomicBoolean measuring = new AtomicBoolean(false);
    private final AtomicBoolean failed = new AtomicBoolean(false);
    private final AtomicLong messageCount = new AtomicLong();
    private volatile boolean shuttingDown = false;

    private EchoBenchmark(
            int port,
            int messageSize,
            int connections,
            int pipeline,
            int warmupSeconds,
            int durationSeconds,
            String scenario,
            Path output) {
        this.port = port;
        this.messageSize = messageSize;
        this.connections = connections;
        this.pipeline = pipeline;
        this.warmupSeconds = warmupSeconds;
        this.durationSeconds = durationSeconds;
        this.scenario = scenario;
        this.output = output;
    }

    public static void main(String[] args) {
        try {
            if (args.length == 1 && "--version".equals(args[0])) {
                printVersions();
                return;
            }
            Map<String, String> options = parseOptions(args);
            int port = requiredInt(options, "port", 1024, 65535);
            int messageSize = requiredInt(options, "message-size", HEADER_SIZE + 16, 1 << 20);
            int connections = requiredInt(options, "connections", 1, 65535);
            int pipeline = requiredInt(options, "pipeline", 1, 4096);
            int warmupSeconds = requiredInt(options, "warmup-seconds", 0, 3600);
            int durationSeconds = requiredInt(options, "duration-seconds", 1, 3600);
            String scenario = requiredValue(options, "scenario");
            Path output = Paths.get(requiredValue(options, "output"));
            new EchoBenchmark(
                    port,
                    messageSize,
                    connections,
                    pipeline,
                    warmupSeconds,
                    durationSeconds,
                    scenario,
                    output).run();
        } catch (Exception exception) {
            System.err.println("[netty-echo] ERROR: " + exception);
            exception.printStackTrace();
            System.exit(1);
        }
    }

    private static Map<String, String> parseOptions(String[] args) {
        if (args.length == 0 || args.length % 2 != 0) {
            throw new IllegalArgumentException("arguments must be --key value pairs");
        }
        Map<String, String> options = new HashMap<>();
        for (int i = 0; i < args.length; i += 2) {
            if (!args[i].startsWith("--")) {
                throw new IllegalArgumentException("unsupported argument: " + args[i]);
            }
            options.put(args[i].substring(2), args[i + 1]);
        }
        return options;
    }

    private static String requiredValue(Map<String, String> options, String key) {
        String value = options.get(key);
        if (value == null || value.isEmpty()) {
            throw new IllegalArgumentException("missing required option: --" + key);
        }
        return value;
    }

    private static int requiredInt(
            Map<String, String> options, String key, int minimum, int maximum) {
        String value = requiredValue(options, key);
        int parsed;
        try {
            parsed = Integer.parseInt(value);
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("option --" + key + " is not a number: " + value);
        }
        if (parsed < minimum || parsed > maximum) {
            throw new IllegalArgumentException(
                    "option --" + key + " must be between " + minimum + " and " + maximum);
        }
        return parsed;
    }

    private static void printVersions() {
        Map<String, Version> versions = Version.identify();
        if (versions.isEmpty()) {
            System.err.println("[netty-echo] ERROR: no Netty artifacts found on the classpath");
            System.exit(1);
        }
        Map<String, Version> sorted = new TreeMap<>(versions);
        for (Map.Entry<String, Version> entry : sorted.entrySet()) {
            System.out.println(entry.getKey() + "=" + entry.getValue().artifactVersion());
        }
    }

    boolean isMeasuring() {
        return measuring.get();
    }

    boolean isShuttingDown() {
        return shuttingDown;
    }

    void recordMessage() {
        messageCount.incrementAndGet();
    }

    void markFailed() {
        failed.set(true);
    }

    private void run() throws Exception {
        EventLoopGroup bossGroup = new MultiThreadIoEventLoopGroup(1, NioIoHandler.newFactory());
        EventLoopGroup serverGroup = new MultiThreadIoEventLoopGroup(NioIoHandler.newFactory());
        EventLoopGroup clientGroup = new MultiThreadIoEventLoopGroup(NioIoHandler.newFactory());
        List<Channel> channels = new ArrayList<>(connections);
        List<EchoClientHandler> handlers =
                Collections.synchronizedList(new ArrayList<>(connections));
        try {
            ServerBootstrap serverBootstrap = new ServerBootstrap()
                    .group(bossGroup, serverGroup)
                    .channel(NioServerSocketChannel.class)
                    .childOption(ChannelOption.TCP_NODELAY, true)
                    .childHandler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel channel) {
                            channel.pipeline().addLast(new EchoServerHandler());
                        }
                    });
            Channel serverChannel =
                    serverBootstrap.bind("127.0.0.1", port).sync().channel();

            Bootstrap clientBootstrap = new Bootstrap()
                    .group(clientGroup)
                    .channel(NioSocketChannel.class)
                    .option(ChannelOption.TCP_NODELAY, true)
                    .handler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel channel) {
                            EchoClientHandler handler = new EchoClientHandler(
                                    EchoBenchmark.this, messageSize, pipeline);
                            channel.pipeline().addLast(handler);
                            handlers.add(handler);
                        }
                    });

            ChannelFuture[] connectFutures = new ChannelFuture[connections];
            for (int i = 0; i < connections; i++) {
                connectFutures[i] = clientBootstrap.connect("127.0.0.1", port);
            }
            for (ChannelFuture connectFuture : connectFutures) {
                connectFuture.sync();
                channels.add(connectFuture.channel());
            }

            Thread.sleep(warmupSeconds * 1000L);
            long startNanos = System.nanoTime();
            measuring.set(true);
            Thread.sleep(durationSeconds * 1000L);
            measuring.set(false);
            long endNanos = System.nanoTime();
            double duration = (endNanos - startNanos) / 1e9;
            long messages = messageCount.get();

            shuttingDown = true;
            for (Channel channel : channels) {
                channel.close().syncUninterruptibly();
            }
            serverChannel.close().syncUninterruptibly();

            if (failed.get()) {
                throw new IllegalStateException("a benchmark connection failed");
            }
            if (messages <= 0) {
                throw new IllegalStateException("no echo messages were measured");
            }

            long sampledCount = 0;
            long sampledSumNanos = 0;
            List<Long> samples = new ArrayList<>();
            for (EchoClientHandler handler : handlers) {
                sampledCount += handler.sampledCount();
                sampledSumNanos += handler.sampledSumNanos();
                samples.addAll(handler.samples());
            }
            if (sampledCount <= 0) {
                throw new IllegalStateException("no round-trip samples were collected");
            }

            double messagesPerSecond = messages / duration;
            double averageRttMs = sampledSumNanos / (double) sampledCount / 1e6;
            Collections.sort(samples);
            int p99Index =
                    (int) Math.min(samples.size() - 1, Math.ceil(samples.size() * 0.99) - 1);
            double p99RttMs = samples.get(p99Index) / 1e6;

            writeReport(messages, duration, messagesPerSecond, averageRttMs, p99RttMs);
            System.out.printf(
                    Locale.ROOT,
                    "[netty-echo] scenario=%s connections=%d messageSize=%d pipeline=%d "
                            + "messages=%d messages/s=%.1f avgRTT=%.3fms p99RTT=%.3fms%n",
                    scenario,
                    connections,
                    messageSize,
                    pipeline,
                    messages,
                    messagesPerSecond,
                    averageRttMs,
                    p99RttMs);
        } finally {
            bossGroup.shutdownGracefully(0, 2, TimeUnit.SECONDS).syncUninterruptibly();
            serverGroup.shutdownGracefully(0, 2, TimeUnit.SECONDS).syncUninterruptibly();
            clientGroup.shutdownGracefully(0, 2, TimeUnit.SECONDS).syncUninterruptibly();
        }
    }

    private void writeReport(
            long messages,
            double duration,
            double messagesPerSecond,
            double averageRttMs,
            double p99RttMs)
            throws IOException {
        StringBuilder json = new StringBuilder();
        json.append("{\n");
        json.append("  \"scenario\": \"").append(scenario).append("\",\n");
        json.append("  \"message_size\": ").append(messageSize).append(",\n");
        json.append("  \"connections\": ").append(connections).append(",\n");
        json.append("  \"pipeline\": ").append(pipeline).append(",\n");
        json.append("  \"warmup_seconds\": ").append(warmupSeconds).append(",\n");
        json.append("  \"duration_seconds\": ")
                .append(String.format(Locale.ROOT, "%.3f", duration)).append(",\n");
        json.append("  \"messages\": ").append(messages).append(",\n");
        json.append("  \"messages_per_second\": ")
                .append(String.format(Locale.ROOT, "%.3f", messagesPerSecond)).append(",\n");
        json.append("  \"avg_rtt_ms\": ")
                .append(String.format(Locale.ROOT, "%.3f", averageRttMs)).append(",\n");
        json.append("  \"p99_rtt_ms\": ")
                .append(String.format(Locale.ROOT, "%.3f", p99RttMs)).append("\n");
        json.append("}\n");
        Files.write(output, json.toString().getBytes(StandardCharsets.UTF_8));
    }
}

/**
 * The official Netty echo-server pattern: write every received buffer back
 * and flush once the read burst is complete.
 */
final class EchoServerHandler extends ChannelInboundHandlerAdapter {

    @Override
    public void channelRead(ChannelHandlerContext context, Object message) {
        context.write(message);
    }

    @Override
    public void channelReadComplete(ChannelHandlerContext context) {
        context.flush();
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext context, Throwable cause) {
        cause.printStackTrace();
        context.close();
    }
}

/**
 * Pipelined echo client: keeps {@code pipeline} framed messages in flight
 * per connection, re-frames the echoed byte stream, counts measured
 * messages, and samples every 1024th round trip.
 */
final class EchoClientHandler extends ChannelInboundHandlerAdapter {

    private final EchoBenchmark benchmark;
    private final int messageSize;
    private final int pipeline;
    private final Map<Long, Long> outstanding = new HashMap<>();
    private final List<Long> samples = new ArrayList<>();
    private ByteBuf cumulation;
    private long nextSequence;
    private long sampledCount;
    private long sampledSumNanos;

    EchoClientHandler(EchoBenchmark benchmark, int messageSize, int pipeline) {
        this.benchmark = benchmark;
        this.messageSize = messageSize;
        this.pipeline = pipeline;
    }

    @Override
    public void channelActive(ChannelHandlerContext context) {
        for (int i = 0; i < pipeline; i++) {
            sendNext(context);
        }
    }

    @Override
    public void channelRead(ChannelHandlerContext context, Object message) {
        ByteBuf incoming = (ByteBuf) message;
        try {
            if (cumulation == null) {
                cumulation = context.alloc().buffer(messageSize * 2);
            }
            cumulation.writeBytes(incoming);
        } finally {
            incoming.release();
        }
        boolean counting = benchmark.isMeasuring();
        while (cumulation.readableBytes() >= messageSize) {
            long sequence = cumulation.readLong();
            long sendNanos = cumulation.readLong();
            cumulation.skipBytes(messageSize - EchoBenchmark.HEADER_SIZE);
            Long recorded = outstanding.remove(sequence);
            if (recorded == null) {
                benchmark.markFailed();
                context.close();
                return;
            }
            if (counting) {
                benchmark.recordMessage();
                if ((sequence & EchoBenchmark.SAMPLE_MASK) == 0) {
                    long rttNanos = System.nanoTime() - sendNanos;
                    samples.add(rttNanos);
                    sampledSumNanos += rttNanos;
                    sampledCount++;
                }
            }
            sendNext(context);
        }
        cumulation.discardReadBytes();
    }

    private void sendNext(ChannelHandlerContext context) {
        long sequence = nextSequence++;
        long sendNanos = System.nanoTime();
        ByteBuf buffer = context.alloc().buffer(messageSize);
        buffer.writeLong(sequence);
        buffer.writeLong(sendNanos);
        buffer.writeZero(messageSize - EchoBenchmark.HEADER_SIZE);
        outstanding.put(sequence, sendNanos);
        context.writeAndFlush(buffer);
    }

    @Override
    public void channelInactive(ChannelHandlerContext context) {
        if (!benchmark.isShuttingDown()) {
            benchmark.markFailed();
        }
        releaseCumulation();
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext context, Throwable cause) {
        benchmark.markFailed();
        context.close();
    }

    private void releaseCumulation() {
        if (cumulation != null) {
            cumulation.release();
            cumulation = null;
        }
    }

    long sampledCount() {
        return sampledCount;
    }

    long sampledSumNanos() {
        return sampledSumNanos;
    }

    List<Long> samples() {
        return samples;
    }
}
