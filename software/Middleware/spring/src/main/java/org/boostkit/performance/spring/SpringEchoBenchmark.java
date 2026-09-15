package org.boostkit.performance.spring;

import org.springframework.core.SpringVersion;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.core.io.buffer.DataBufferUtils;
import org.springframework.core.io.buffer.DefaultDataBufferFactory;
import org.springframework.http.MediaType;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import org.springframework.web.reactive.function.server.RouterFunction;
import org.springframework.web.reactive.function.server.RouterFunctions;
import org.springframework.web.reactive.function.server.ServerResponse;
import org.springframework.web.server.WebHandler;

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
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

import reactor.core.publisher.Mono;

/**
 * Single-process Spring WebFlux functional echo throughput benchmark.
 *
 * The service side is a functional router endpoint ("POST /echo", the
 * canonical WebFlux Fn pattern from the official Spring Framework
 * documentation) that echoes every request payload back unchanged.  The
 * benchmark drives the complete framework pipeline — router matching,
 * ServerRequest construction, request-body decoding, handler invocation,
 * response serialization and reactive scheduling — without any actual
 * network transport: exchanges are fed through the official
 * MockServerWebExchange from the spring-test artifact, the same facility
 * Spring itself uses for framework testing.  This keeps the software
 * under test the Spring Framework pipeline itself rather than a
 * third-party HTTP server stack.
 *
 * A fixed pool of driver threads keeps a global window of outstanding
 * exchanges (the concurrency ladder); every completed exchange
 * immediately triggers the next one.  After the warmup phase the
 * counters and RTT samples (every 1024th completion) are collected for
 * the configured duration and written to a JSON report consumed by
 * scripts/collect_spring_benchmark.py.
 *
 * All Spring and Reactor settings (handler strategies, message codecs,
 * schedulers) are left at their out-of-the-box defaults.
 */
public final class SpringEchoBenchmark {

    static final int HEADER_SIZE = 16;
    static final long SAMPLE_MASK = 1023;
    static final byte[] EMPTY_BODY = new byte[0];

    private final int messageSize;
    private final int concurrency;
    private final int drivers;
    private final int warmupSeconds;
    private final int durationSeconds;
    private final String scenario;
    private final Path output;

    private final AtomicBoolean measuring = new AtomicBoolean(false);
    private final AtomicBoolean failed = new AtomicBoolean(false);
    private final AtomicLong callCount = new AtomicLong();
    private final AtomicLong sampleTick = new AtomicLong();
    private final AtomicLong nextSequence = new AtomicLong();
    private volatile boolean shuttingDown = false;

    private WebHandler webHandler;
    private final List<Driver> driverList = new ArrayList<>();
    private final Map<Long, Long> outstanding = new HashMap<>();
    private final List<Long> samples = new ArrayList<>();
    private long sampledCount;
    private long sampledSumNanos;

    private SpringEchoBenchmark(
            int messageSize,
            int concurrency,
            int drivers,
            int warmupSeconds,
            int durationSeconds,
            String scenario,
            Path output) {
        this.messageSize = messageSize;
        this.concurrency = concurrency;
        this.drivers = drivers;
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
            int messageSize = requiredInt(options, "message-size", HEADER_SIZE + 16, 1 << 20);
            int concurrency = requiredInt(options, "concurrency", 1, 1 << 16);
            int drivers = requiredInt(options, "drivers", 1, 1024);
            int warmupSeconds = requiredInt(options, "warmup-seconds", 0, 3600);
            int durationSeconds = requiredInt(options, "duration-seconds", 1, 3600);
            String scenario = requiredValue(options, "scenario");
            Path output = Paths.get(requiredValue(options, "output"));
            new SpringEchoBenchmark(
                    messageSize,
                    concurrency,
                    drivers,
                    warmupSeconds,
                    durationSeconds,
                    scenario,
                    output).run();
        } catch (Exception exception) {
            System.err.println("[spring-bench] ERROR: " + exception);
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
        // SpringVersion is the official public API carrying the framework
        // version from the spring-core manifest.
        String version = SpringVersion.getVersion();
        if (version == null || version.isEmpty()) {
            System.err.println("[spring-bench] ERROR: no Spring Framework version found on the classpath");
            System.exit(1);
        }
        System.out.println("spring-version=" + version);
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
        RouterFunction<ServerResponse> route = RouterFunctions
                .route()
                .POST("/echo", request -> request
                        .bodyToMono(byte[].class)
                        .flatMap(body -> ServerResponse
                                .ok()
                                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                                .bodyValue(body)))
                .build();
        webHandler = RouterFunctions.toWebHandler(route);

        CountDownLatch finished = new CountDownLatch(drivers);
        int depth = Math.max(1, concurrency / drivers);
        for (int i = 0; i < drivers; i++) {
            Driver driver = new Driver(depth);
            driverList.add(driver);
        }
        Thread[] threads = new Thread[drivers];
        for (int i = 0; i < drivers; i++) {
            threads[i] = new Thread(driverList.get(i), "spring-bench-driver-" + i);
            threads[i].setDaemon(true);
        }
        for (Thread thread : threads) {
            thread.start();
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
        for (Thread thread : threads) {
            thread.join(TimeUnit.SECONDS.toMillis(30));
        }

        if (failed.get()) {
            throw new IllegalStateException("a benchmark exchange failed");
        }
        if (calls <= 0) {
            throw new IllegalStateException("no exchanges were measured");
        }
        synchronized (samples) {
            if (sampledCount <= 0) {
                throw new IllegalStateException("no round-trip samples were collected");
            }
        }

        double exchangesPerSecond = calls / duration;
        double averageRttMs;
        double p99RttMs;
        List<Long> sorted;
        synchronized (samples) {
            averageRttMs = sampledSumNanos / (double) sampledCount / 1e6;
            sorted = new ArrayList<>(samples);
        }
        Collections.sort(sorted);
        int p99Index =
                (int) Math.min(sorted.size() - 1, Math.ceil(sorted.size() * 0.99) - 1);
        p99RttMs = sorted.get(p99Index) / 1e6;

        writeReport(calls, duration, exchangesPerSecond, averageRttMs, p99RttMs);
        System.out.printf(
                Locale.ROOT,
                "[spring-bench] scenario=%s concurrency=%d drivers=%d messageSize=%d "
                        + "calls=%d exchanges/s=%.1f avgRTT=%.3fms p99RTT=%.3fms%n",
                scenario,
                concurrency,
                drivers,
                messageSize,
                calls,
                exchangesPerSecond,
                averageRttMs,
                p99RttMs);
    }

    private void writeReport(
            long calls,
            double duration,
            double exchangesPerSecond,
            double averageRttMs,
            double p99RttMs)
            throws IOException {
        StringBuilder json = new StringBuilder();
        json.append("{\n");
        json.append("  \"scenario\": \"").append(scenario).append("\",\n");
        json.append("  \"message_size\": ").append(messageSize).append(",\n");
        json.append("  \"concurrency\": ").append(concurrency).append(",\n");
        json.append("  \"drivers\": ").append(drivers).append(",\n");
        json.append("  \"warmup_seconds\": ").append(warmupSeconds).append(",\n");
        json.append("  \"duration_seconds\": ")
                .append(String.format(Locale.ROOT, "%.3f", duration)).append(",\n");
        json.append("  \"calls\": ").append(calls).append(",\n");
        json.append("  \"exchanges_per_second\": ")
                .append(String.format(Locale.ROOT, "%.3f", exchangesPerSecond)).append(",\n");
        json.append("  \"avg_rtt_ms\": ")
                .append(String.format(Locale.ROOT, "%.3f", averageRttMs)).append(",\n");
        json.append("  \"p99_rtt_ms\": ")
                .append(String.format(Locale.ROOT, "%.3f", p99RttMs)).append("\n");
        json.append("}\n");
        Files.write(output, json.toString().getBytes(StandardCharsets.UTF_8));
    }

    /** Frames are fixed-size: [sequence:8][sendNanos:8][zero padding]. */
    void sendNext(Driver driver) {
        final long sequence = nextSequence.getAndIncrement();
        final long sendNanos = System.nanoTime();
        byte[] frame = new byte[messageSize];
        putLong(frame, 0, sequence);
        putLong(frame, 8, sendNanos);
        synchronized (outstanding) {
            outstanding.put(sequence, sendNanos);
        }
        MockServerHttpRequest request = MockServerHttpRequest
                .post("/echo")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .contentLength(messageSize)
                .body(Mono.just(
                        DefaultDataBufferFactory.sharedInstance.wrap(frame)));
        MockServerWebExchange exchange = MockServerWebExchange.from(request);
        webHandler
                .handle(exchange)
                .subscribe(
                        ignored -> { },
                        throwable -> exchangeFailed(driver, sequence, throwable),
                        () -> collectResponse(driver, exchange, sequence, sendNanos));
    }

    private void collectResponse(
            Driver driver, MockServerWebExchange exchange, long sequence, long sendNanos) {
        DataBufferUtils.join(exchange.getResponse().getBody())
                .map(buffer -> {
                    byte[] bytes = new byte[buffer.readableByteCount()];
                    buffer.read(bytes);
                    DataBufferUtils.release(buffer);
                    return bytes;
                })
                .defaultIfEmpty(EMPTY_BODY)
                .subscribe(
                        bytes -> exchangeCompleted(driver, bytes, sequence, sendNanos),
                        throwable -> exchangeFailed(driver, sequence, throwable));
    }

    private void exchangeCompleted(
            Driver driver, byte[] echoed, long sequence, long sendNanos) {
        boolean counting = isMeasuring();
        try {
            if (echoed.length != messageSize) {
                System.err.println("[spring-bench] length mismatch: "
                        + echoed.length + " != " + messageSize);
                markFailed();
                return;
            }
            long echoedSequence = getLong(echoed, 0);
            long echoedSendNanos = getLong(echoed, 8);
            Long recorded;
            synchronized (outstanding) {
                recorded = outstanding.remove(echoedSequence);
            }
            if (recorded == null || recorded != echoedSendNanos) {
                System.err.println("[spring-bench] sequence mismatch: seq="
                        + echoedSequence + " recorded=" + recorded
                        + " echoed=" + echoedSendNanos);
                markFailed();
                return;
            }
            if (counting) {
                recordCall();
                if ((nextSampleTick() & SAMPLE_MASK) == 0) {
                    long rttNanos = System.nanoTime() - sendNanos;
                    synchronized (samples) {
                        samples.add(rttNanos);
                        sampledSumNanos += rttNanos;
                        sampledCount++;
                    }
                }
            }
        } finally {
            driver.release();
        }
    }

    private void exchangeFailed(Driver driver, long sequence, Throwable throwable) {
        synchronized (outstanding) {
            outstanding.remove(sequence);
        }
        if (!isShuttingDown()) {
            System.err.println("[spring-bench] exchange error: " + throwable);
            markFailed();
        }
        driver.release();
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

    /**
     * One driver thread: keeps its share of the global concurrency window
     * filled with outstanding exchanges; every completion releases a
     * permit and the loop immediately submits the next exchange.
     */
    final class Driver implements Runnable {

        private final Semaphore window;

        Driver(int depth) {
            this.window = new Semaphore(depth);
        }

        void release() {
            window.release();
        }

        @Override
        public void run() {
            try {
                while (!isShuttingDown()) {
                    window.acquire();
                    if (isShuttingDown()) {
                        window.release();
                        return;
                    }
                    sendNext(this);
                }
            } catch (InterruptedException exception) {
                Thread.currentThread().interrupt();
            }
        }
    }
}
