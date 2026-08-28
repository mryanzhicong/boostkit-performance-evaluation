# golang 1.27.0 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`33136448799-1`

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
      <td width="1200">2026-08-28T02:37:26Z</td>
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
      <td width="1200">2026-08-28T02:37:21Z</td>
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
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=global/fluff=false-16 :: p99.999-ns</td>
      <td width="280">160014.0</td>
      <td width="200">p99.999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=global/fluff=false-16 :: p99.9999-ns</td>
      <td width="280">793987.0</td>
      <td width="200">p99.9999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=heap/fluff=false-16 :: p99.999-ns</td>
      <td width="280">157139.5</td>
      <td width="200">p99.999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=heap/fluff=false-16 :: p99.9999-ns</td>
      <td width="280">171530.0</td>
      <td width="200">p99.9999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=stack/fluff=false-16 :: p99.999-ns</td>
      <td width="280">158889.0</td>
      <td width="200">p99.999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=stack/fluff=false-16 :: p99.9999-ns</td>
      <td width="280">169630.0</td>
      <td width="200">p99.9999-ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
