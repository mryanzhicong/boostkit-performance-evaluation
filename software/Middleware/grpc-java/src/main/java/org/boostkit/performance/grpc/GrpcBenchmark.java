package org.boostkit.performance.grpc;

import io.grpc.CallOptions;
import io.grpc.Channel;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.MethodDescriptor;
import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.ServerServiceDefinition;
import io.grpc.stub.ClientCalls;
import io.grpc.stub.ServerCalls;
import io.grpc.stub.StreamObserver;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
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
 * Single-process gRPC-Java unary echo throughput benchmark.
 *
 * The service side is a hand-registered unary method ("benchmark.Echo/Send")
 * that answers every request with the identical payload — the minimal RPC
 * counterpart of the classic echo pattern used by the Netty case.  The
 * request is a fixed-size frame of [sequence:8][sendNanos:8][zero padding]
 * marshalled by a plain byte-array marshaller, so no protobuf compiler or
 * generated code is involved and the only dependencies are the official
 * gRPC-Java artifacts themselves.
 *
 * The client side keeps a fixed per-channel window of outstanding unary
 * calls; every response immediately triggers the next request.  After the
 * warmup phase the counters and RTT samples (every 1024th call) are
 * collected for the configured duration and written to a JSON report
 * consumed by scripts/collect_grpc_java_benchmark.py.
 *
 * All gRPC and Netty-shaded settings (flow-control windows, HTTP/2
 * concurrency, executors) are left at their out-of-the-box defaults.
 */
public final class GrpcBenchmark {

    static final int HEADER_SIZE = 16;
    static final long SAMPLE_MASK = 1023;
    static final String SERVICE_NAME = "benchmark.Echo";
    static final String METHOD_NAME = "Send";

    private final int port;
    private final int messageSize;
    private final int channels;
    private final int pipeline;
    private final int warmupSeconds;
    private final int durationSeconds;
    private final String scenario;
    private final Path output;

    private final AtomicBoolean measuring = new AtomicBoolean(false);
    private final AtomicBoolean failed = new AtomicBoolean(false);
    private final AtomicLong callCount = new AtomicLong();
    private final AtomicLong sampleTick = new AtomicLong();
    private volatile boolean shuttingDown = false;

    private GrpcBenchmark(
            int port,
            int messageSize,
            int channels,
            int pipeline,
            int warmupSeconds,
            int durationSeconds,
            String scenario,
            Path output) {
        this.port = port;
        this.messageSize = messageSize;
        this.channels = channels;
        this.pipeline = pipeline;
        this.warmupSeconds = warmupSeconds;
        this.durationSeconds = durationSeconds;
        this.scenario = scenario;
        this.output = output;
    }

    public static void main(String[] args) {
        try {
            if (args.length == 1 && "--version".equals(args[0])) {
                printVersion();
                return;
            }
            Map<String, String> options = parseOptions(args);
            int port = requiredInt(options, "port", 1024, 65535);
            int messageSize = requiredInt(options, "message-size", HEADER_SIZE + 16, 1 << 20);
            int channels = requiredInt(options, "channels", 1, 65535);
            int pipeline = requiredInt(options, "pipeline", 1, 4096);
            int warmupSeconds = requiredInt(options, "warmup-seconds", 0, 3600);
            int durationSeconds = requiredInt(options, "duration-seconds", 1, 3600);
            String scenario = requiredValue(options, "scenario");
            Path output = Paths.get(requiredValue(options, "output"));
            new GrpcBenchmark(
                    port,
                    messageSize,
                    channels,
                    pipeline,
                    warmupSeconds,
                    durationSeconds,
                    scenario,
                    output).run();
        } catch (Exception exception) {
            System.err.println("[grpc-bench] ERROR: " + exception);
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

    private static void printVersion() {
        // The gRPC runtime does not expose a version API; the official
        // grpc-core jar manifest carries the implementation version.
        Package grpcPackage = io.grpc.Server.class.getPackage();
        String version = grpcPackage.getImplementationVersion();
        if (version == null || version.isEmpty()) {
            System.err.println("[grpc-bench] ERROR: no gRPC version found on the classpath");
            System.exit(1);
        }
        System.out.println("grpc-java-version=" + version);
    }

    boolean isMeasuring() {
        return measuring.get();
    }

    boolean isShuttingDown() {
        return shuttingDown;
    }

    void recordCall() {
        callCount.incrementAndGet();
    }

    /**
     * Reserves the next global completion tick; every 1024th measured
     * completion (tick % 1024 == 0) also contributes an RTT sample.  A
     * global tick (instead of a per-driver sequence) guarantees samples
     * even when individual drivers complete fewer than 1024 calls inside
     * the measuring window.
     */
    long nextSampleTick() {
        return sampleTick.getAndIncrement();
    }

    void markFailed() {
        failed.set(true);
    }

    private void run() throws Exception {
        MethodDescriptor<byte[], byte[]> method = MethodDescriptor
                .<byte[], byte[]>newBuilder()
                .setType(MethodDescriptor.MethodType.UNARY)
                .setFullMethodName(
                        MethodDescriptor.generateFullMethodName(SERVICE_NAME, METHOD_NAME))
                .setRequestMarshaller(BYTE_ARRAY_MARSHALLER)
                .setResponseMarshaller(BYTE_ARRAY_MARSHALLER)
                .build();

        ServerServiceDefinition service = ServerServiceDefinition
                .builder(SERVICE_NAME)
                .addMethod(method, ServerCalls.asyncUnaryCall(
                        (ServerCalls.UnaryMethod<byte[], byte[]>) (request, responseObserver) -> {
                            responseObserver.onNext(request);
                            responseObserver.onCompleted();
                        }))
                .build();

        Server server = ServerBuilder.forPort(port)
                .addService(service)
                .build()
                .start();

        List<ManagedChannel> managedChannels = new ArrayList<>(channels);
        List<UnaryEchoCallDriver> drivers =
                Collections.synchronizedList(new ArrayList<>(channels));
        try {
            for (int i = 0; i < channels; i++) {
                ManagedChannel channel = ManagedChannelBuilder
                        .forAddress("127.0.0.1", port)
                        .usePlaintext()
                        .build();
                managedChannels.add(channel);
                UnaryEchoCallDriver driver = new UnaryEchoCallDriver(
                        this, channel, method, messageSize, pipeline);
                drivers.add(driver);
                driver.start();
            }

            Thread.sleep(warmupSeconds * 1000L);
            long startNanos = System.nanoTime();
            measuring.set(true);
            Thread.sleep(durationSeconds * 1000L);
            measuring.set(false);
            long endNanos = System.nanoTime();
            double duration = (endNanos - startNanos) / 1e9;
            long calls = callCount.get();

            shuttingDown = true;
            for (ManagedChannel channel : managedChannels) {
                channel.shutdownNow().awaitTermination(10, TimeUnit.SECONDS);
            }
            server.shutdown().awaitTermination(10, TimeUnit.SECONDS);

            if (failed.get()) {
                throw new IllegalStateException("a benchmark call failed");
            }
            if (calls <= 0) {
                throw new IllegalStateException("no unary calls were measured");
            }

            long sampledCount = 0;
            long sampledSumNanos = 0;
            List<Long> samples = new ArrayList<>();
            for (UnaryEchoCallDriver driver : drivers) {
                sampledCount += driver.sampledCount();
                sampledSumNanos += driver.sampledSumNanos();
                samples.addAll(driver.samples());
            }
            if (sampledCount <= 0) {
                throw new IllegalStateException("no round-trip samples were collected");
            }

            double callsPerSecond = calls / duration;
            double averageRttMs = sampledSumNanos / (double) sampledCount / 1e6;
            Collections.sort(samples);
            int p99Index =
                    (int) Math.min(samples.size() - 1, Math.ceil(samples.size() * 0.99) - 1);
            double p99RttMs = samples.get(p99Index) / 1e6;

            writeReport(calls, duration, callsPerSecond, averageRttMs, p99RttMs);
            System.out.printf(
                    Locale.ROOT,
                    "[grpc-bench] scenario=%s channels=%d messageSize=%d pipeline=%d "
                            + "calls=%d calls/s=%.1f avgRTT=%.3fms p99RTT=%.3fms%n",
                    scenario,
                    channels,
                    messageSize,
                    pipeline,
                    calls,
                    callsPerSecond,
                    averageRttMs,
                    p99RttMs);
        } finally {
            for (ManagedChannel channel : managedChannels) {
                channel.shutdownNow();
            }
            server.shutdown();
        }
    }

    private void writeReport(
            long calls,
            double duration,
            double callsPerSecond,
            double averageRttMs,
            double p99RttMs)
            throws IOException {
        StringBuilder json = new StringBuilder();
        json.append("{\n");
        json.append("  \"scenario\": \"").append(scenario).append("\",\n");
        json.append("  \"message_size\": ").append(messageSize).append(",\n");
        json.append("  \"channels\": ").append(channels).append(",\n");
        json.append("  \"pipeline\": ").append(pipeline).append(",\n");
        json.append("  \"warmup_seconds\": ").append(warmupSeconds).append(",\n");
        json.append("  \"duration_seconds\": ")
                .append(String.format(Locale.ROOT, "%.3f", duration)).append(",\n");
        json.append("  \"calls\": ").append(calls).append(",\n");
        json.append("  \"calls_per_second\": ")
                .append(String.format(Locale.ROOT, "%.3f", callsPerSecond)).append(",\n");
        json.append("  \"avg_rtt_ms\": ")
                .append(String.format(Locale.ROOT, "%.3f", averageRttMs)).append(",\n");
        json.append("  \"p99_rtt_ms\": ")
                .append(String.format(Locale.ROOT, "%.3f", p99RttMs)).append("\n");
        json.append("}\n");
        Files.write(output, json.toString().getBytes(StandardCharsets.UTF_8));
    }

    /** Plain byte-array marshaller: no protobuf codegen involved. */
    static final MethodDescriptor.Marshaller<byte[]> BYTE_ARRAY_MARSHALLER =
            new MethodDescriptor.Marshaller<byte[]>() {
                @Override
                public InputStream stream(byte[] value) {
                    return new ByteArrayInputStream(value);
                }

                @Override
                public byte[] parse(InputStream stream) {
                    try {
                        java.io.ByteArrayOutputStream buffer =
                                new java.io.ByteArrayOutputStream();
                        byte[] chunk = new byte[8192];
                        int read;
                        while ((read = stream.read(chunk)) != -1) {
                            buffer.write(chunk, 0, read);
                        }
                        return buffer.toByteArray();
                    } catch (IOException exception) {
                        throw new RuntimeException(exception);
                    }
                }
            };
}

/**
 * Drives one channel: keeps {@code pipeline} outstanding unary calls in
 * flight, validates the echoed frame sequence, counts measured calls, and
 * samples every 1024th round trip.
 */
final class UnaryEchoCallDriver {

    private final GrpcBenchmark benchmark;
    private final Channel channel;
    private final MethodDescriptor<byte[], byte[]> method;
    private final int messageSize;
    private final int pipeline;
    private final Map<Long, Long> outstanding = new HashMap<>();
    private final List<Long> samples = new ArrayList<>();
    private final AtomicLong nextSequence = new AtomicLong();
    private long sampledCount;
    private long sampledSumNanos;

    UnaryEchoCallDriver(
            GrpcBenchmark benchmark,
            Channel channel,
            MethodDescriptor<byte[], byte[]> method,
            int messageSize,
            int pipeline) {
        this.benchmark = benchmark;
        this.channel = channel;
        this.method = method;
        this.messageSize = messageSize;
        this.pipeline = pipeline;
    }

    void start() {
        for (int i = 0; i < pipeline; i++) {
            sendNext();
        }
    }

    private void sendNext() {
        // gRPC response callbacks arrive concurrently on different transport
        // threads, so the per-driver sequence must be atomically unique.
        final long sequence = nextSequence.getAndIncrement();
        final long sendNanos = System.nanoTime();
        byte[] frame = new byte[messageSize];
        putLong(frame, 0, sequence);
        putLong(frame, 8, sendNanos);
        synchronized (outstanding) {
            outstanding.put(sequence, sendNanos);
        }
        ClientCalls.asyncUnaryCall(
                channel.newCall(method, CallOptions.DEFAULT),
                frame,
                new StreamObserver<byte[]>() {
                    @Override
                    public void onNext(byte[] value) {
                        boolean counting = benchmark.isMeasuring();
                        if (value.length != messageSize) {
                            System.err.println("[grpc-bench] length mismatch: "
                                    + value.length + " != " + messageSize);
                            benchmark.markFailed();
                            return;
                        }
                        long echoedSequence = getLong(value, 0);
                        long echoedSendNanos = getLong(value, 8);
                        Long recorded;
                        synchronized (outstanding) {
                            recorded = outstanding.remove(echoedSequence);
                        }
                        if (recorded == null || recorded != echoedSendNanos) {
                            System.err.println("[grpc-bench] sequence mismatch: seq="
                                    + echoedSequence + " recorded=" + recorded
                                    + " echoed=" + echoedSendNanos
                                    + " outstanding=" + outstanding.size());
                            benchmark.markFailed();
                            return;
                        }
                        if (counting) {
                            benchmark.recordCall();
                            if ((benchmark.nextSampleTick()
                                    & GrpcBenchmark.SAMPLE_MASK) == 0) {
                                long rttNanos = System.nanoTime() - sendNanos;
                                synchronized (samples) {
                                    samples.add(rttNanos);
                                    sampledSumNanos += rttNanos;
                                    sampledCount++;
                                }
                            }
                        }
                        if (!benchmark.isShuttingDown()) {
                            sendNext();
                        }
                    }

                    @Override
                    public void onError(Throwable throwable) {
                        if (!benchmark.isShuttingDown()) {
                            System.err.println("[grpc-bench] call error: " + throwable);
                            benchmark.markFailed();
                        }
                    }

                    @Override
                    public void onCompleted() {
                        // unary call finished; next request already issued in onNext
                    }
                });
    }

    private static void putLong(byte[] buffer, int offset, long value) {
        for (int i = 0; i < 8; i++) {
            buffer[offset + i] = (byte) (value >>> (8 * (7 - i)));
        }
    }

    private static long getLong(byte[] buffer, int offset) {
        long value = 0;
        for (int i = 0; i < 8; i++) {
            value = (value << 8) | (buffer[offset + i] & 0xFFL);
        }
        return value;
    }

    long sampledCount() {
        return sampledCount;
    }

    long sampledSumNanos() {
        return sampledSumNanos;
    }

    List<Long> samples() {
        synchronized (samples) {
            return new ArrayList<>(samples);
        }
    }
}
