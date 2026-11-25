/*
 * ZkBench - 跨架构可比的 ZooKeeper 客户端基准工具
 *
 * 目标：同一份客户端代码在 ARM / x86 上运行，消除绑定工具差异，得到可直接对比的
 *       吞吐量(ops/s) 与 时延(P50/P95/P99/max) 指标。
 *
 * 编译（使用 ZooKeeper 发行包自带的 jar，无需联网）：
 *   javac -cp $ZOOKEEPER_HOME/lib/*:$(ls $ZOOKEEPER_HOME/lib/*.jar | tr '\n' ':') ZkBench.java
 * 运行：
 *   java -cp .:$ZOOKEEPER_HOME/lib/* ZkBench --connect 127.0.0.1:2181 --mode=read --threads=32 --ops=200000
 *
 * 说明：
 *  - create 模式写入持久 znode，路径 /zkbench/k%012d；
 *  - read/update 模式在已预置的 keyspace 内随机命中（默认 1,000,000 个节点）；
 *  - delete 模式删除已存在的节点（用于生命周期测试，需在 read 之后单独执行）；
 *  - mixed 模式按 read:update = 9:1 混合，模拟典型读多写少场景；
 *  - 时延只统计成功操作；失败操作计数后单列输出，不计入时延。
 */

import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.KeeperException;
import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.ZooDefs;
import org.apache.zookeeper.ZooKeeper;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicLong;

public class ZkBench {

    private static String connect = "127.0.0.1:2181";
    private static String root = "/zkbench";
    private static String mode = "read";
    private static int threads = 32;
    private static long opsPerThread = 20000;
    private static long warmupOps = 2000;
    private static int valueSize = 1024;
    private static long keyspace = 1000000L;
    private static int sessionTimeoutMs = 60000;
    private static String label = "local";
    /**
     * 本轮运行的序号，用于给 create 模式生成不重复的节点名。
     * 背景（实测踩过的坑）：早期版本 create 路径固定为 root/k<seq>，同一并发档跑第二轮、
     * 或不同并发档的相同 tid 会命中同一批路径，全部失败并计入 ops_err——看起来像
     * "高并发 create 有缺陷"，实际上是 NodeExists 自撞。传入不同的 --run-seq 即可彻底避免。
     */
    private static long runSeq = 0;

    /**
     * 失败原因分类计数（并发安全）。
     * 背景：实测 create 模式在高并发下会失败（t64 达 50%），但原版只记 ops_err 总数，
     * 无法判断是"客户端请求队列满(ConnectionLoss)"、"节点已存在(NodeExists)"还是
     * "会话过期(SessionExpired)"——这三种的处理方式完全不同，必须分开统计。
     */
    private static final ConcurrentHashMap<String, AtomicLong> ERR_KINDS =
            new ConcurrentHashMap<String, AtomicLong>();

    private static void noteErr(String kind) {
        noteErr(kind, false);
    }

    private static void noteErr(String kind, boolean warmup) {
        if (warmup) {
            return; // 预热不计入统计，也不计入失败原因
        }
        AtomicLong a = ERR_KINDS.get(kind);
        if (a == null) {
            ERR_KINDS.putIfAbsent(kind, new AtomicLong());
            a = ERR_KINDS.get(kind);
        }
        a.incrementAndGet();
    }

    private static String errKindSummary() {
        if (ERR_KINDS.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (java.util.Map.Entry<String, AtomicLong> e : ERR_KINDS.entrySet()) {
            if (sb.length() > 0) {
                sb.append(';');
            }
            sb.append(e.getKey()).append('=').append(e.getValue().get());
        }
        return sb.toString();
    }

    private static final byte[] VALUE_TEMPLATE;

    static {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 4096; i++) {
            sb.append((char) ('a' + (i % 26)));
        }
        VALUE_TEMPLATE = sb.toString().getBytes(StandardCharsets.UTF_8);
    }

    private static byte[] value(int size) {
        byte[] v = new byte[size];
        for (int i = 0; i < size; i++) {
            v[i] = VALUE_TEMPLATE[i % VALUE_TEMPLATE.length];
        }
        return v;
    }

    private static String path(long id) {
        return String.format("%s/k%012d", root, id);
    }

    /**
     * create 模式专用命名空间 root/c/——与 keyspace(root/k*)彻底隔离，
     * 这样 create 产生的几十万个节点不会污染 read/update/mixed 的命中集合，
     * 清理时也只需 deleteall root/c。
     */
    /**
     * create 模式的轮次目录：root/c/r<runSeq>。
     *
     * 为什么要**分片**：早期版本把一轮 40 万节点全平铺在 root/c 下，1.9M 子节点时
     * getChildren(root/c) 的响应远超服务端 jute.maxbuffer(4MB)，服务端直接断连，
     * 结果既清不掉（clean 必现 ConnectionLoss）也查不了。按 r<runSeq>/t<tid> 分片后，
     * 每个父节点最多 per_thread 个子节点（默认 6250），getChildren 永远在 4MB 以内。
     */
    private static String roundDir(long seqBase) {
        return String.format("%s/c/r%03d", root, seqBase / 10000000L);
    }

    private static int tidOf(long seqBase) {
        return (int) ((seqBase % 10000000L) / 100000L) - 1;
    }

    private static String createPath(long seqBase, long i) {
        return String.format("%s/t%02d/k%012d", roundDir(seqBase), tidOf(seqBase), i);
    }

    /** 预热创建的节点放独立子目录，避免与正式测量的 create 路径自撞（NodeExists） */
    private static String warmupPath(long seqBase, long i) {
        return String.format("%s/warm/k%012d", roundDir(seqBase), i);
    }

    public static void main(String[] args) throws Exception {
        for (String a : args) {
            int eq = a.indexOf('=');
            if (!a.startsWith("--") || eq < 0) {
                continue;
            }
            String k = a.substring(2, eq);
            String v = a.substring(eq + 1);
            switch (k) {
                case "connect": connect = v; break;
                case "root": root = v; break;
                case "mode": mode = v; break;
                case "threads": threads = Integer.parseInt(v); break;
                case "ops": opsPerThread = Long.parseLong(v); break;
                case "warmup": warmupOps = Long.parseLong(v); break;
                case "value-size": valueSize = Integer.parseInt(v); break;
                case "keyspace": keyspace = Long.parseLong(v); break;
                case "session-timeout": sessionTimeoutMs = Integer.parseInt(v); break;
                case "label": label = v; break;
                case "run-seq": runSeq = Long.parseLong(v); break;
                default: break;
            }
        }

        final CountDownLatch connected = new CountDownLatch(1);
        ZooKeeper zk = new ZooKeeper(connect, sessionTimeoutMs, new Watcher() {
            @Override
            public void process(WatchedEvent e) {
                if (e.getState() == Event.KeeperState.SyncConnected) {
                    connected.countDown();
                }
            }
        });
        connected.await();
        ensureRoot(zk);

        if ("preload".equals(mode)) {
            preload(zk);
            zk.close();
            return;
        }

        if ("clean".equals(mode)) {
            clean(zk);
            zk.close();
            return;
        }

        final byte[] payload = value(valueSize);
        final long startBarrier = System.nanoTime() + 1500L * 1000000L; // 1.5s 后统一起跑
        final AtomicLong errors = new AtomicLong();
        final AtomicLong totalOps = new AtomicLong();
        final CountDownLatch done = new CountDownLatch(threads);
        // 必须线程安全：普通 ArrayList 在 64 线程并发 add 时会丢元素（实测 ops_ok 少计 2000）
        final List<long[]> latencies = java.util.Collections.synchronizedList(new ArrayList<long[]>());

        long t0 = System.nanoTime();
        for (int t = 0; t < threads; t++) {
            final int tid = t;
            Thread th = new Thread(new Runnable() {
                @Override
                public void run() {
                    long[] lat = new long[(int) opsPerThread];
                    ZooKeeper czk = null;
                    try {
                        final CountDownLatch c2 = new CountDownLatch(1);
                        czk = new ZooKeeper(connect, sessionTimeoutMs, new Watcher() {
                            @Override
                            public void process(WatchedEvent e) {
                                if (e.getState() == Event.KeeperState.SyncConnected) {
                                    c2.countDown();
                                }
                            }
                        });
                        c2.await();
                        Random rnd = new Random(12345L + tid);
                        // runSeq 每轮递增，tid 隔离线程，i 为线程内序号 → 三次运行路径绝不重叠
                        long seqBase = runSeq * 10000000L + 100000L * (tid + 1);

                        // 预热（不计入统计）
                        // 预热：按本轮模式预热，避免 create 模式拿 read 预热而刷出 NoNode
                        String warmMode = "create".equals(mode) ? "create" : "read";
                        for (long i = 0; i < warmupOps; i++) {
                            doOp(czk, warmMode, rnd, seqBase, i, payload, true);
                        }

                        long wait = startBarrier - System.nanoTime();
                        if (wait > 0) {
                            Thread.sleep(wait / 1000000L, (int) (wait % 1000000L));
                        }

                        int ok = 0;
                        for (long i = 0; i < opsPerThread; i++) {
                            long s = System.nanoTime();
                            boolean success = doOp(czk, mode, rnd, seqBase, i, payload, false);
                            long e = System.nanoTime();
                            if (success) {
                                lat[ok++] = e - s;
                                totalOps.incrementAndGet();
                            } else {
                                errors.incrementAndGet();
                            }
                        }
                        latencies.add(Arrays.copyOf(lat, ok));
                    } catch (Exception ex) {
                        errors.addAndGet(opsPerThread);
                        System.err.println("[ZkBench] thread " + tid + " failed: " + ex);
                    } finally {
                        if (czk != null) {
                            try { czk.close(); } catch (Exception ignore) { }
                        }
                        done.countDown();
                    }
                }
            }, "zkbench-" + t);
            th.setDaemon(true);
            th.start();
        }
        done.await();
        long elapsedNs = System.nanoTime() - t0;

        long[] all;
        synchronized (latencies) {
            all = merge(latencies);
        }
        double elapsedSec = elapsedNs / 1e9;
        double throughput = all.length / elapsedSec;

        System.out.println("label,arch,threads,mode,value_size,keyspace,ops_ok,ops_err,elapsed_s,throughput_ops,"
                + "avg_us,p50_us,p95_us,p99_us,max_us");
        System.out.printf("%s,%s,%d,%s,%d,%d,%d,%d,%.3f,%.1f,%.1f,%.1f,%.1f,%.1f,%.1f%n",
                label, System.getProperty("os.arch"), threads, mode, valueSize, keyspace,
                all.length, errors.get(), elapsedSec, throughput,
                mean(all) / 1000.0, pct(all, 50) / 1000.0, pct(all, 95) / 1000.0,
                pct(all, 99) / 1000.0, (all.length > 0 ? all[all.length - 1] / 1000.0 : 0.0));
        // 失败原因单独打到 stderr：保持 stdout 的 CSV 表头/列数不变（下游解析不受影响）
        if (errors.get() > 0) {
            System.err.println("[ZkBench] ops_err=" + errors.get() + " error_kinds " + errKindSummary());
        }
        zk.close();
    }

    private static boolean doOp(ZooKeeper zk, String op, Random rnd, long seqBase, long i, byte[] payload,
                                boolean warmup) {
        try {
            if ("create".equals(op)) {
                String p = warmup ? warmupPath(seqBase, i) : createPath(seqBase, i);
                zk.create(p, payload, ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
                return true;
            } else if ("update".equals(op)) {
                zk.setData(path((long) (rnd.nextDouble() * keyspace)), payload, -1);
                return true;
            } else if ("delete".equals(op)) {
                zk.delete(path((long) (rnd.nextDouble() * keyspace)), -1);
                return true;
            } else if ("mixed".equals(op)) {
                if (rnd.nextInt(10) == 0) {
                    zk.setData(path((long) (rnd.nextDouble() * keyspace)), payload, -1);
                } else {
                    zk.getData(path((long) (rnd.nextDouble() * keyspace)), false, null);
                }
                return true;
            } else {
                zk.getData(path((long) (rnd.nextDouble() * keyspace)), false, null);
                return true;
            }
        } catch (KeeperException.NoNodeException nne) {
            noteErr("NoNode", warmup);
            return false;
        } catch (KeeperException.NodeExistsException nee) {
            noteErr("NodeExists", warmup);
            return false;
        } catch (KeeperException.ConnectionLossException cle) {
            // 高并发 create 最常见的失败：客户端与服务端之间请求队列/连接被打满
            noteErr("ConnectionLoss", warmup);
            return false;
        } catch (KeeperException.SessionExpiredException se) {
            noteErr("SessionExpired", warmup);
            return false;
        } catch (KeeperException.BadVersionException bve) {
            noteErr("BadVersion", warmup);
            return false;
        } catch (InterruptedException ie) {
            Thread.currentThread().interrupt();
            noteErr("Interrupted", warmup);
            return false;
        } catch (Exception ex) {
            noteErr(ex.getClass().getSimpleName(), warmup);
            return false;
        }
    }

    private static void preload(ZooKeeper zk) throws Exception {
        System.out.println("[ZkBench] preload " + keyspace + " znodes under " + root + " ...");
        long t0 = System.currentTimeMillis();
        byte[] payload = value(valueSize);
        for (long i = 0; i < keyspace; i++) {
            String p = path(i);
            try {
                zk.create(p, payload, ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
            } catch (KeeperException.NodeExistsException ignore) {
            }
            if ((i + 1) % 100000 == 0) {
                System.out.printf("[ZkBench] preload %d/%d, %.1fs%n", i + 1, keyspace,
                        (System.currentTimeMillis() - t0) / 1000.0);
            }
        }
        System.out.printf("[ZkBench] preload done, %d znodes, %.1fs%n",
                keyspace, (System.currentTimeMillis() - t0) / 1000.0);
    }

    /**
     * 清理 create 模式产生的节点（root/c 整棵子树）。
     *
     * 为什么不用 zkCli 的 deleteall：几十万个 znode 一次性递归删除会直接
     * KeeperErrorCode = ConnectionLoss 并把 zkCli 干掉（实测 40 万节点时必现）。
     * 这里分批 getChildren + 逐个 delete，单批失败只跳过不中断，可断点重跑。
     */
    private static void clean(ZooKeeper zk) throws Exception {
        String base = root + "/c";
        long t0 = System.currentTimeMillis();
        long[] counter = new long[]{0};
        try {
            deleteTree(zk, base, counter, t0);
        } catch (KeeperException.NoNodeException nne) {
            System.out.println("[ZkBench] clean: " + base + " 不存在，无需清理");
            return;
        } catch (KeeperException.ConnectionLossException cle) {
            System.err.println("[ZkBench] clean: getChildren(" + base + ") 连接被断开。"
                    + "若这是历史版本留下的**扁平**目录（单父节点上百万子节点），"
                    + "getChildren 响应会超过 jute.maxbuffer(4MB)，此路不通——"
                    + "直接重建数据目录：zkServer.sh stop && rm -rf $DATA/zk/{data,log}。");
            throw cle;
        }
        System.out.printf("[ZkBench] clean done: %d znodes, %.1fs%n", counter[0],
                (System.currentTimeMillis() - t0) / 1000.0);
    }

    /**
     * 深度优先删除整棵子树（ZK 只能先删叶子）。
     *
     * 三个必须处理的失败：ConnectionLoss（大批量删除时的正常抖动，重试）、
     * NotEmpty（递归期间又被写入，重新递归）、NoNode（并发已删）。
     */
    private static void deleteTree(ZooKeeper zk, String path, long[] counter, long t0) throws Exception {
        List<String> kids;
        try {
            kids = zk.getChildren(path, false);
        } catch (KeeperException.NoNodeException nne) {
            return;
        }
        for (String k : kids) {
            deleteTree(zk, path + "/" + k, counter, t0);
        }
        for (int attempt = 0; attempt < 10; attempt++) {
            try {
                zk.delete(path, -1);
                counter[0]++;
                if (counter[0] % 50000 == 0) {
                    System.out.printf("[ZkBench] clean %d znodes, %.1fs%n", counter[0],
                            (System.currentTimeMillis() - t0) / 1000.0);
                }
                return;
            } catch (KeeperException.NoNodeException nne) {
                return;
            } catch (KeeperException.NotEmptyException ne) {
                deleteTree(zk, path, counter, t0);   // 有人又写了子节点，重来
                return;
            } catch (KeeperException.ConnectionLossException cle) {
                Thread.sleep(100L * (attempt + 1));
            }
        }
        System.err.println("[ZkBench] clean: 放弃删除 " + path + "（连续 ConnectionLoss）");
    }

    private static void ensureRoot(ZooKeeper zk) throws Exception {
        StringBuilder sb = new StringBuilder();
        for (String seg : root.split("/")) {
            if (seg.isEmpty()) continue;
            sb.append('/').append(seg);
            try {
                zk.create(sb.toString(), new byte[0], ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
            } catch (KeeperException.NodeExistsException ignore) {
            }
        }
        // create 模式的命名空间 root/c/r<runSeq>/t<tid>（分片，见 roundDir 注释）
        // root/c/r<runSeq>/t<tid>：**每个线程的父目录必须预先建好**，否则 create 会拿到 NoNode
        // （实测：只建 t00 时，其余 7 个线程的 3500 次 create 全部 NoNode）
        String dir = String.format("%s/c/r%03d", root, runSeq);
        java.util.List<String> dirs = new java.util.ArrayList<>();
        dirs.add(root + "/c");
        dirs.add(dir);
        dirs.add(dir + "/warm");
        for (int t = 0; t < threads; t++) {
            dirs.add(String.format("%s/t%02d", dir, t));
        }
        for (String p : dirs) {
            try {
                zk.create(p, new byte[0], ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
            } catch (KeeperException.NodeExistsException ignore) {
            }
        }
    }

    private static long[] merge(List<long[]> parts) {
        int n = 0;
        for (long[] p : parts) n += p.length;
        long[] all = new long[n];
        int o = 0;
        for (long[] p : parts) {
            System.arraycopy(p, 0, all, o, p.length);
            o += p.length;
        }
        Arrays.sort(all);
        return all;
    }

    private static double mean(long[] a) {
        if (a.length == 0) return 0;
        double s = 0;
        for (long v : a) s += v;
        return s / a.length;
    }

    private static double pct(long[] a, double p) {
        if (a.length == 0) return 0;
        int idx = (int) Math.min(a.length - 1, Math.max(0, Math.round(p / 100.0 * a.length) - 1));
        return a[idx];
    }
}
