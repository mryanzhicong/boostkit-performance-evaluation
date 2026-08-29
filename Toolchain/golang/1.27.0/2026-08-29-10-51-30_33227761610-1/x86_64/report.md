# golang 1.27.0 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`33227761610-1`

## 测试环境

### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">x86_64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">请求软件版本</td>
      <td width="1200">1.27.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">1.27.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-29T01:58:48Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">x86_64</td>
    </tr>
  </tbody>
</table>

### 系统信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">x86_64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="1200">2026-08-29T01:58:44Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">x86_64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">General Purpose Processor</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="1200">16</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="1200">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="1200">6.6.0-159.4.10.164.oe2403sp4.x86_64</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="1200">3.11.6</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="1200">12.3.1</td>
    </tr>
    <tr>
      <td width="180">glibc 版本</td>
      <td width="1200">glibc 2.38</td>
    </tr>
    <tr>
      <td width="180">NUMA</td>
      <td width="1200">N/A</td>
    </tr>
  </tbody>
</table>

### 测试工具

<table width="1380">
  <thead>
    <tr>
      <th width="500">工具</th>
      <th width="880">版本</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">golang_benchmarks</td>
      <td width="880">master (70693762b6a0d7f393892f0ace40979e3cbe5737)</td>
    </tr>
  </tbody>
</table>

## 性能指标

### github.com/egonelbre/spexs2/_benchmark

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/0-16 :: ns/op</td>
      <td width="280">13091126489.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/1-16 :: ns/op</td>
      <td width="280">13121511323.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/16-16 :: ns/op</td>
      <td width="280">2688249351.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/2-16 :: ns/op</td>
      <td width="280">7041744912.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/32-16 :: ns/op</td>
      <td width="280">2410566641.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/4-16 :: ns/op</td>
      <td width="280">4189653343.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/8-16 :: ns/op</td>
      <td width="280">3470453456.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/0-16 :: ns/op</td>
      <td width="280">40944415717.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/1-16 :: ns/op</td>
      <td width="280">40795580097.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/16-16 :: ns/op</td>
      <td width="280">5857357056.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/2-16 :: ns/op</td>
      <td width="280">20802028967.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/32-16 :: ns/op</td>
      <td width="280">5744646966.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/4-16 :: ns/op</td>
      <td width="280">11185863150.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/8-16 :: ns/op</td>
      <td width="280">7408212513.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### golang.org/x/benchmarks/cmd/bench/distsize

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">golang.org/x/benchmarks/cmd/bench/distsize :: BenchmarkGoDistribution :: total-bytes</td>
      <td width="280">75481644.0</td>
      <td width="200">total-bytes</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### golang.org/x/benchmarks/gc_latency

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: data-bytes</td>
      <td width="280">2462321.0</td>
      <td width="200">data-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: debug-bytes</td>
      <td width="280">2273057.0</td>
      <td width="200">debug-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: pclntab-bytes</td>
      <td width="280">2604412.0</td>
      <td width="200">pclntab-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: rodata-bytes</td>
      <td width="280">2196568.0</td>
      <td width="200">rodata-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: text-bytes</td>
      <td width="280">3316056.0</td>
      <td width="200">text-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: total-bytes</td>
      <td width="280">12256656.0</td>
      <td width="200">total-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=global/fluff=false-16 :: p99.999-ns</td>
      <td width="280">156069.5</td>
      <td width="200">p99.999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=global/fluff=false-16 :: p99.9999-ns</td>
      <td width="280">787157.0</td>
      <td width="200">p99.9999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=heap/fluff=false-16 :: p99.999-ns</td>
      <td width="280">152749.0</td>
      <td width="200">p99.999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=heap/fluff=false-16 :: p99.9999-ns</td>
      <td width="280">166739.5</td>
      <td width="200">p99.9999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=stack/fluff=false-16 :: p99.999-ns</td>
      <td width="280">154689.5</td>
      <td width="200">p99.999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=stack/fluff=false-16 :: p99.9999-ns</td>
      <td width="280">167670.0</td>
      <td width="200">p99.9999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: data-bytes</td>
      <td width="280">291092.0</td>
      <td width="200">data-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: debug-bytes</td>
      <td width="280">1313740.0</td>
      <td width="200">debug-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: pclntab-bytes</td>
      <td width="280">1417079.0</td>
      <td width="200">pclntab-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: rodata-bytes</td>
      <td width="280">113057.0</td>
      <td width="200">rodata-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: text-bytes</td>
      <td width="280">1701553.0</td>
      <td width="200">text-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: total-bytes</td>
      <td width="280">5559864.0</td>
      <td width="200">total-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: data-bytes</td>
      <td width="280">257364.0</td>
      <td width="200">data-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: debug-bytes</td>
      <td width="280">1445869.0</td>
      <td width="200">debug-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: pclntab-bytes</td>
      <td width="280">1527161.0</td>
      <td width="200">pclntab-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: rodata-bytes</td>
      <td width="280">110785.0</td>
      <td width="200">rodata-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: text-bytes</td>
      <td width="280">1836081.0</td>
      <td width="200">text-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: total-bytes</td>
      <td width="280">5927586.0</td>
      <td width="200">total-bytes</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
