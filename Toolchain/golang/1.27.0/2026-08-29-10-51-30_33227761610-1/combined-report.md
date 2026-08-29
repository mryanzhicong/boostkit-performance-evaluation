# 性能测试汇总

- 任务总数：2
- 成功：2
- 失败：0
- 跨架构对比：1

<table width="1380">
  <thead>
    <tr>
      <th width="180">分类</th>
      <th width="220">软件</th>
      <th width="160">版本</th>
      <th width="220">架构</th>
      <th width="240">状态</th>
      <th width="360">环境清理</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">golang</td>
      <td width="160">1.27.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">golang</td>
      <td width="160">1.27.0</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### golang 1.27.0

#### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="600">x86_64</th>
      <th width="600">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">请求软件版本</td>
      <td width="600">1.27.0</td>
      <td width="600">1.27.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.27.0</td>
      <td width="600">1.27.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-08-29T01:58:48Z</td>
      <td width="600">2026-08-29T01:57:21Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
  </tbody>
</table>

#### 系统信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="600">x86_64</th>
      <th width="600">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="600">2026-08-29T01:58:44Z</td>
      <td width="600">2026-08-29T01:57:17Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">General Purpose Processor</td>
      <td width="600">Kunpeng 920 7270Z To be filled by O.E.M. CPU @ 2.9GHz</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">16</td>
      <td width="600">256</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0-159.4.10.164.oe2403sp4.x86_64</td>
      <td width="600">6.6.0-159.4.3.154.oe2403sp4.aarch64</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="600">3.11.6</td>
      <td width="600">3.11.6</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="600">12.3.1</td>
      <td width="600">12.3.1</td>
    </tr>
    <tr>
      <td width="180">glibc 版本</td>
      <td width="600">glibc 2.38</td>
      <td width="600">glibc 2.38</td>
    </tr>
    <tr>
      <td width="180">NUMA</td>
      <td width="600">N/A</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 127842 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 123344 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 126965 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 127364 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
    </tr>
  </tbody>
</table>

#### 测试工具

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

## 单架构指标

### x86_64

#### golang 1.27.0

##### github.com/egonelbre/spexs2/_benchmark

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

##### golang.org/x/benchmarks/cmd/bench/distsize

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

##### golang.org/x/benchmarks/gc_latency

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

### aarch64

#### golang 1.27.0

##### golang.org/x/benchmarks/cmd/bench/distsize

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
      <td width="280">71938440.0</td>
      <td width="200">total-bytes</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### golang.org/x/benchmarks/gc_latency

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
      <td width="280">2446865.0</td>
      <td width="200">data-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: debug-bytes</td>
      <td width="280">2076376.0</td>
      <td width="200">debug-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: pclntab-bytes</td>
      <td width="280">2508258.0</td>
      <td width="200">pclntab-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: rodata-bytes</td>
      <td width="280">2181096.0</td>
      <td width="200">rodata-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: text-bytes</td>
      <td width="280">2740660.0</td>
      <td width="200">text-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: total-bytes</td>
      <td width="280">11313760.0</td>
      <td width="200">total-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: data-bytes</td>
      <td width="280">276500.0</td>
      <td width="200">data-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: debug-bytes</td>
      <td width="280">1240365.0</td>
      <td width="200">debug-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: pclntab-bytes</td>
      <td width="280">1360182.0</td>
      <td width="200">pclntab-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: rodata-bytes</td>
      <td width="280">98337.0</td>
      <td width="200">rodata-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: text-bytes</td>
      <td width="280">1501460.0</td>
      <td width="200">text-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: total-bytes</td>
      <td width="280">5204510.0</td>
      <td width="200">total-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: data-bytes</td>
      <td width="280">242772.0</td>
      <td width="200">data-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: debug-bytes</td>
      <td width="280">1359827.0</td>
      <td width="200">debug-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: pclntab-bytes</td>
      <td width="280">1457153.0</td>
      <td width="200">pclntab-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: rodata-bytes</td>
      <td width="280">96065.0</td>
      <td width="200">rodata-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: text-bytes</td>
      <td width="280">1625204.0</td>
      <td width="200">text-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: total-bytes</td>
      <td width="280">5611757.0</td>
      <td width="200">total-bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=global/fluff=false-256 :: p99.999-ns</td>
      <td width="280">203880.0</td>
      <td width="200">p99.999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=global/fluff=false-256 :: p99.9999-ns</td>
      <td width="280">366920.0</td>
      <td width="200">p99.9999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=heap/fluff=false-256 :: p99.999-ns</td>
      <td width="280">196600.0</td>
      <td width="200">p99.999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=heap/fluff=false-256 :: p99.9999-ns</td>
      <td width="280">378475.0</td>
      <td width="200">p99.9999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=stack/fluff=false-256 :: p99.999-ns</td>
      <td width="280">189545.0</td>
      <td width="200">p99.999-ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=stack/fluff=false-256 :: p99.9999-ns</td>
      <td width="280">359880.0</td>
      <td width="200">p99.9999-ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/egonelbre/spexs2/_benchmark

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
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/0-256 :: ns/op</td>
      <td width="280">19530500820.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/1-256 :: ns/op</td>
      <td width="280">18896476340.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/16-256 :: ns/op</td>
      <td width="280">5557320235.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/2-256 :: ns/op</td>
      <td width="280">11364019145.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/32-256 :: ns/op</td>
      <td width="280">5637119645.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/4-256 :: ns/op</td>
      <td width="280">7753002545.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/8-256 :: ns/op</td>
      <td width="280">5962941015.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/0-256 :: ns/op</td>
      <td width="280">62258778205.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/1-256 :: ns/op</td>
      <td width="280">57288311565.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/16-256 :: ns/op</td>
      <td width="280">10220263020.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/2-256 :: ns/op</td>
      <td width="280">31751708725.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/32-256 :: ns/op</td>
      <td width="280">10862851265.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/4-256 :: ns/op</td>
      <td width="280">18727340645.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/8-256 :: ns/op</td>
      <td width="280">12510142535.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### golang 1.27.0

#### github.com/egonelbre/spexs2/_benchmark

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/0-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">13091126489.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/1-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">13121511323.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/16-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2688249351.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/2-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">7041744912.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/32-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2410566641.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/4-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">4189653343.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/8-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">3470453456.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/0-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">40944415717.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/1-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">40795580097.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/16-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">5857357056.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/2-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">20802028967.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/32-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">5744646966.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/4-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">11185863150.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/8-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">7408212513.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/0-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">19530500820.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/1-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">18896476340.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/16-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">5557320235.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/2-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">11364019145.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/32-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">5637119645.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/4-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">7753002545.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/10k/8-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">5962941015.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/0-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">62258778205.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/1-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">57288311565.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/16-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">10220263020.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/2-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">31751708725.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/32-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">10862851265.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/4-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">18727340645.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/egonelbre/spexs2/_benchmark :: BenchmarkRun/30k/8-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">12510142535.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### golang.org/x/benchmarks/cmd/bench/distsize

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">golang.org/x/benchmarks/cmd/bench/distsize :: BenchmarkGoDistribution :: total-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">75481644.0</td>
      <td width="200">71938440.0</td>
      <td width="380">1.0493</td>
    </tr>
  </tbody>
</table>

#### golang.org/x/benchmarks/gc_latency

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: data-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">2462321.0</td>
      <td width="200">2446865.0</td>
      <td width="380">1.0063</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: debug-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">2273057.0</td>
      <td width="200">2076376.0</td>
      <td width="380">1.0947</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: pclntab-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">2604412.0</td>
      <td width="200">2508258.0</td>
      <td width="380">1.0383</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: rodata-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">2196568.0</td>
      <td width="200">2181096.0</td>
      <td width="380">1.0071</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: text-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">3316056.0</td>
      <td width="200">2740660.0</td>
      <td width="380">1.2099</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkEthereum_ethash :: total-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">12256656.0</td>
      <td width="200">11313760.0</td>
      <td width="380">1.0833</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=global/fluff=false-16 :: p99.999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">156069.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=global/fluff=false-16 :: p99.9999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">787157.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=heap/fluff=false-16 :: p99.999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">152749.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=heap/fluff=false-16 :: p99.9999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">166739.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=stack/fluff=false-16 :: p99.999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">154689.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=stack/fluff=false-16 :: p99.9999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">167670.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: data-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">291092.0</td>
      <td width="200">276500.0</td>
      <td width="380">1.0528</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: debug-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">1313740.0</td>
      <td width="200">1240365.0</td>
      <td width="380">1.0592</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: pclntab-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">1417079.0</td>
      <td width="200">1360182.0</td>
      <td width="380">1.0418</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: rodata-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">113057.0</td>
      <td width="200">98337.0</td>
      <td width="380">1.1497</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: text-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">1701553.0</td>
      <td width="200">1501460.0</td>
      <td width="380">1.1333</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGonum_path :: total-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">5559864.0</td>
      <td width="200">5204510.0</td>
      <td width="380">1.0683</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: data-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">257364.0</td>
      <td width="200">242772.0</td>
      <td width="380">1.0601</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: debug-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">1445869.0</td>
      <td width="200">1359827.0</td>
      <td width="380">1.0633</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: pclntab-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">1527161.0</td>
      <td width="200">1457153.0</td>
      <td width="380">1.048</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: rodata-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">110785.0</td>
      <td width="200">96065.0</td>
      <td width="380">1.1532</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: text-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">1836081.0</td>
      <td width="200">1625204.0</td>
      <td width="380">1.1298</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkSpexs2 :: total-bytes</td>
      <td width="200">越小越好</td>
      <td width="200">5927586.0</td>
      <td width="200">5611757.0</td>
      <td width="380">1.0563</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=global/fluff=false-256 :: p99.999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">203880.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=global/fluff=false-256 :: p99.9999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">366920.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=heap/fluff=false-256 :: p99.999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">196600.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=heap/fluff=false-256 :: p99.9999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">378475.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=stack/fluff=false-256 :: p99.999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">189545.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">golang.org/x/benchmarks/gc_latency :: BenchmarkGCLatency/how=stack/fluff=false-256 :: p99.9999-ns</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">359880.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
