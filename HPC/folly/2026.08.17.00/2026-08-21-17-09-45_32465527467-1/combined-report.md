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
      <td width="180">HPC</td>
      <td width="220">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### folly 2026.08.17.00

#### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="600">x86</th>
      <th width="600">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">请求软件版本</td>
      <td width="600">2026.08.17.00</td>
      <td width="600">2026.08.17.00</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">2026.08.17.00</td>
      <td width="600">2026.08.17.00</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-08-21T08:59:31Z</td>
      <td width="600">2026-08-21T08:59:36Z</td>
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
      <th width="600">x86</th>
      <th width="600">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="600">2026-08-21T08:56:42Z</td>
      <td width="600">2026-08-21T08:56:34Z</td>
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
      <td width="600">6.6.0-159.4.3.154.oe2403sp4.x86_64</td>
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
      <td width="600">available: 1 nodes (0)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>node 0 size: 30886 MB<br>node 0 free: 16331 MB<br>node distances:<br>node   0 <br>  0:  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 127983 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 124670 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127330 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 128430 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

<table width="1380">
  <thead>
    <tr>
      <th width="180">软件</th>
      <th width="160">版本</th>
      <th width="420">指标</th>
      <th width="200">数值</th>
      <th width="160">单位</th>
      <th width="260">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">container/test/container_bit_iterator_bench/SimpleFFSTest</td>
      <td width="200">117576015.86369014</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">container/test/container_bit_iterator_bench/RealFFSTest</td>
      <td width="200">7561140.863690138</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="200">88.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="200">87.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="200">86.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="200">146.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="200">145.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="200">145.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="200">20.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="200">20.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="200">20.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="200">16.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="200">16.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="200">16.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="200">9.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="200">11.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="200">11.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="200">11.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="200">57.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="200">56.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="200">55.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="200">90.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="200">88.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="200">86.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="200">184.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="200">162.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="200">148.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="200">27.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="200">15.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="200">23.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="200">32.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="200">31.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="200">29.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="200">31.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="200">31.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="200">31.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="200">16.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="200">56.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="200">56.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="200">55.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="200">144.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="200">142.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="200">142.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="200">142.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="200">142.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="200">142.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="200">141.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="200">157.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="200">142.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="200">132.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="200">277.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="200">253.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="200">242.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="200">31.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="200">33.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="200">26.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="200">11.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="200">38.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="200">32.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="200">22.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="200">39.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="200">33.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="200">22.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="200">35.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="200">31.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="200">25.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="200">11.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="200">9.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="200">44.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="200">36.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="200">31.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="200">37.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="200">31.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="200">25.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="200">35.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="200">32.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="200">15.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="200">9.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="200">11.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="200">20.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="200">3.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="200">3.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="200">3.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="200">3.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Max time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="200">3.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="200">128.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="200">118.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="200">110.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="200">301.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="200">289.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="200">282.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="200">301.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="200">287.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="200">282.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="200">297.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="200">290.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="200">282.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="200">317.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="200">288.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="200">282.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="200">300.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="200">287.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="200">282.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/constantFuture</td>
      <td width="200">15.962965488433838</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%promiseAndFuture</td>
      <td width="200">35.58347940444946</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%withThen</td>
      <td width="200">96.20817422866821</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/oneThen</td>
      <td width="200">70.14250040054321</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%twoThens</td>
      <td width="200">126.41508340835571</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%fourThens</td>
      <td width="200">236.6042923927307</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%hundredThens</td>
      <td width="200">5471.504194736481</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%fourThensOnThread</td>
      <td width="200">27476.11356973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%fourThensOnThreadInline</td>
      <td width="200">27133.14481973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%hundredThensOnThread</td>
      <td width="200">41522.98856973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%hundredThensOnThreadInline</td>
      <td width="200">28017.05106973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/no_contention</td>
      <td width="200">1550356.8635697365</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%contention</td>
      <td width="200">1195305.8635697365</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/throwAndCatch</td>
      <td width="200">3417.7541947364807</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwAndCatchWrapped</td>
      <td width="200">1490.8010697364807</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwWrappedAndCatch</td>
      <td width="200">2184.6487259864807</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwWrappedAndCatchWrapped</td>
      <td width="200">197.3159623146057</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/throwAndCatchContended</td>
      <td width="200">35536083.86356974</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwAndCatchWrappedContended</td>
      <td width="200">15766261.863569736</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwWrappedAndCatchContended</td>
      <td width="200">15656582.863569736</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwWrappedAndCatchWrappedContended</td>
      <td width="200">3360511.8635697365</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/lvalue_get</td>
      <td width="200">126.66093301773071</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%rvalue_get</td>
      <td width="200">125.67338418960571</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/complexUnit</td>
      <td width="200">24511.11356973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob4</td>
      <td width="200">24497.83231973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob8</td>
      <td width="200">23825.01981973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob64</td>
      <td width="200">26054.23856973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob128</td>
      <td width="200">27157.67606973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob256</td>
      <td width="200">29098.30106973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob512</td>
      <td width="200">36205.17606973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob1024</td>
      <td width="200">45243.92606973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob2048</td>
      <td width="200">51500.17606973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob4096</td>
      <td width="200">83093.61356973648</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_8</td>
      <td width="200">5.037438869476318</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_16</td>
      <td width="200">5.580995082855225</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_32</td>
      <td width="200">6.683480739593506</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_64</td>
      <td width="200">8.860909938812256</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_128</td>
      <td width="200">12.658212184906006</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_256</td>
      <td width="200">21.38570547103882</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_512</td>
      <td width="200">38.83764028549194</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_1024</td>
      <td width="200">73.74059438705444</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_2048</td>
      <td width="200">143.61608266830444</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_4096</td>
      <td width="200">283.22570180892944</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_8192</td>
      <td width="200">562.3880553245544</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_16384</td>
      <td width="200">1121.9046568870544</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_32768</td>
      <td width="200">2237.8519225120544</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_65536</td>
      <td width="200">4477.519891262054</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_131072</td>
      <td width="200">8957.051141262054</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_262144</td>
      <td width="200">17891.426141262054</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_524288</td>
      <td width="200">35768.301141262054</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_8</td>
      <td width="200">3.138749599456787</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_16</td>
      <td width="200">3.9670348167419434</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_32</td>
      <td width="200">3.966691493988037</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_64</td>
      <td width="200">4.231126308441162</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_128</td>
      <td width="200">7.509667873382568</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_256</td>
      <td width="200">12.833306789398193</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_512</td>
      <td width="200">23.28603506088257</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_1024</td>
      <td width="200">41.00469350814819</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_2048</td>
      <td width="200">75.77123403549194</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_4096</td>
      <td width="200">150.24816274642944</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_8192</td>
      <td width="200">440.04186391830444</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_16384</td>
      <td width="200">823.1448912620544</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_32768</td>
      <td width="200">1587.8323912620544</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_65536</td>
      <td width="200">3114.8831725120544</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_131072</td>
      <td width="200">6172.051141262054</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_262144</td>
      <td width="200">12258.066766262054</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_524288</td>
      <td width="200">24406.269891262054</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroy</td>
      <td width="200">13.75613808631897</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/cloneOneBenchmark</td>
      <td width="200">12.73532509803772</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/cloneOneIntoBenchmark</td>
      <td width="200">7.77255654335022</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/cloneBenchmark</td>
      <td width="200">14.812504053115845</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/cloneIntoBenchmark</td>
      <td width="200">8.043102502822876</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/moveBenchmark</td>
      <td width="200">8.04385781288147</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/copyBenchmark</td>
      <td width="200">11.355938196182251</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/copyBufferFromStringBenchmark</td>
      <td width="200">20.016056299209595</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/copyBufferFromStringPieceBenchmark</td>
      <td width="200">17.032352685928345</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/cloneCoalescedBaseline</td>
      <td width="200">148.54037880897522</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/%cloneCoalescedBenchmark</td>
      <td width="200">28.91055703163147</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/takeOwnershipBenchmark</td>
      <td width="200">17.093998193740845</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(64)</td>
      <td width="200">18399.394870996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(256)</td>
      <td width="200">18433.926120996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(1024)</td>
      <td width="200">31892.363620996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(4096)</td>
      <td width="200">33928.926120996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(5000)</td>
      <td width="200">33482.676120996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(5120)</td>
      <td width="200">36799.863620996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(8192)</td>
      <td width="200">34491.113620996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(10000)</td>
      <td width="200">34211.426120996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(10240)</td>
      <td width="200">34494.863620996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(16384)</td>
      <td width="200">35121.738620996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(17000)</td>
      <td width="200">35035.488620996475</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/libc_tolower</td>
      <td width="200">698.2229578495026</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/folly_toLowerAscii</td>
      <td width="200">14.585415124893188</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/folly_toUpperAscii</td>
      <td width="200">15.153347253799438</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(1)</td>
      <td width="200">65.60247445106506</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(4)</td>
      <td width="200">77.75884652137756</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(16)</td>
      <td width="200">77.33465218544006</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(64)</td>
      <td width="200">78.59502816200256</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(256)</td>
      <td width="200">170.86529183387756</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(1024)</td>
      <td width="200">230.31353402137756</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfAppendfBenchmark</td>
      <td width="200">9035845.86358285</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(1)</td>
      <td width="200">47.83068490028381</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(4)</td>
      <td width="200">59.33489632606506</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(16)</td>
      <td width="200">59.36938118934631</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(64)</td>
      <td width="200">59.05382943153381</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(256)</td>
      <td width="200">59.91045784950256</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(1024)</td>
      <td width="200">97.17779183387756</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtAppendfBenchmark</td>
      <td width="200">2744559.8635828495</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(1)</td>
      <td width="200">64.72539925575256</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(4)</td>
      <td width="200">85.85821175575256</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(16)</td>
      <td width="200">85.36504769325256</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(64)</td>
      <td width="200">85.11791634559631</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(256)</td>
      <td width="200">85.20757699012756</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(1024)</td>
      <td width="200">114.87615609169006</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/BM_cEscape</td>
      <td width="200">181027.3635828495</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/BM_cUnescape</td>
      <td width="200">127733.6135828495</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/BM_uriEscape</td>
      <td width="200">1359.4631922245026</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/BM_uriUnescape</td>
      <td width="200">753.1887781620026</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/BM_unhexlify</td>
      <td width="200">0.20695090293884277</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/splitOnSingleChar</td>
      <td width="200">632.2073328495026</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/splitOnSingleCharFixed</td>
      <td width="200">161.17828011512756</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/splitOnSingleCharFixedAllowExtra</td>
      <td width="200">135.17120003700256</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/splitStr</td>
      <td width="200">1373.7317469120026</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/splitStrFixed</td>
      <td width="200">254.29961800575256</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/boost_splitOnSingleChar</td>
      <td width="200">1257.6575281620026</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/joinCharStr</td>
      <td width="200">692.5198328495026</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/joinStrStr</td>
      <td width="200">636.5676844120026</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/joinInt</td>
      <td width="200">847.7493250370026</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

<table width="1380">
  <thead>
    <tr>
      <th width="180">软件</th>
      <th width="160">版本</th>
      <th width="420">指标</th>
      <th width="200">数值</th>
      <th width="160">单位</th>
      <th width="260">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">container/test/container_bit_iterator_bench/SimpleFFSTest</td>
      <td width="200">122522179.65516806</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">container/test/container_bit_iterator_bench/RealFFSTest</td>
      <td width="200">8649659.655168056</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="200">112.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="200">109.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="200">106.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="200">305.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="200">302.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="200">299.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="200">16.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="200">15.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="200">15.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="200">15.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="200">25.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="200">25.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="200">22.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="200">41.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="200">35.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="200">33.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="200">60.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="200">59.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="200">59.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="200">68.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="200">68.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="200">67.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="200">177.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="200">175.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="200">175.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="200">188.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="200">188.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="200">187.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="200">176.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="200">175.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="200">112.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="200">109.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="200">106.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="200">362.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="200">317.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="200">305.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="200">22.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="200">15.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="200">16.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="200">16.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="200">15.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="200">33.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="200">31.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="200">31.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="200">55.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="200">55.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="200">55.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Max time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="200">68.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="200">68.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="200">67.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="200">179.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="200">178.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="200">177.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="200">179.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="200">176.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="200">177.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="200">175.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="200">177.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="200">175.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="200">175.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="200">175.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="200">174.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="200">112.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="200">112.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="200">112.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="200">656.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="200">348.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="200">310.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="200">20.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="200">27.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="200">23.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="200">29.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="200">19.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="200">50.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="200">30.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="200">26.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="200">63.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="200">50.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="200">43.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="200">3.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="200">3.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Max time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Min time (ns/op)</td>
      <td width="200">1.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="200">2.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="200">7.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="200">69.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="200">68.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="200">68.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="200">180.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="200">179.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="200">178.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="200">180.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="200">179.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="200">178.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="200">180.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="200">179.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="200">178.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="200">180.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="200">179.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="200">179.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="200">182.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="200">181.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="200">180.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/constantFuture</td>
      <td width="200">29.715442657470703</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%promiseAndFuture</td>
      <td width="200">75.83620071411133</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%withThen</td>
      <td width="200">265.3949165344238</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/oneThen</td>
      <td width="200">166.52162551879883</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%twoThens</td>
      <td width="200">302.9193305969238</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%fourThens</td>
      <td width="200">570.6366157531738</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%hundredThens</td>
      <td width="200">13582.545795440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%fourThensOnThread</td>
      <td width="200">31286.530170440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%fourThensOnThreadInline</td>
      <td width="200">31576.530170440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%hundredThensOnThread</td>
      <td width="200">68744.03017044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%hundredThensOnThreadInline</td>
      <td width="200">50332.780170440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/no_contention</td>
      <td width="200">4473272.655170441</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%contention</td>
      <td width="200">4145012.6551704407</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/throwAndCatch</td>
      <td width="200">7581.334857940674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwAndCatchWrapped</td>
      <td width="200">3196.100482940674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwWrappedAndCatch</td>
      <td width="200">4762.975482940674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwWrappedAndCatchWrapped</td>
      <td width="200">435.9906196594238</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/throwAndCatchContended</td>
      <td width="200">13978355.65517044</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwAndCatchWrappedContended</td>
      <td width="200">4280615.655170441</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwWrappedAndCatchContended</td>
      <td width="200">6768065.655170441</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%throwWrappedAndCatchWrappedContended</td>
      <td width="200">1009915.6551704407</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/lvalue_get</td>
      <td width="200">213.37123489379883</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%rvalue_get</td>
      <td width="200">213.15272903442383</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/complexUnit</td>
      <td width="200">68309.65517044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob4</td>
      <td width="200">67514.65517044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob8</td>
      <td width="200">67396.53017044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob64</td>
      <td width="200">69160.90517044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob128</td>
      <td width="200">71305.90517044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob256</td>
      <td width="200">75689.03017044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob512</td>
      <td width="200">75602.78017044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob1024</td>
      <td width="200">96624.65517044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob2048</td>
      <td width="200">110573.40517044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">futures/test/futures_benchmark/%complexBlob4096</td>
      <td width="200">136097.15517044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_8</td>
      <td width="200">4.797074794769287</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_16</td>
      <td width="200">11.019303798675537</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_32</td>
      <td width="200">22.609117031097412</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_64</td>
      <td width="200">53.06367635726929</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_128</td>
      <td width="200">124.36342000961304</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_256</td>
      <td width="200">263.81288290023804</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_512</td>
      <td width="200">539.450089931488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_1024</td>
      <td width="200">1085.426652431488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_2048</td>
      <td width="200">2196.940324306488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_4096</td>
      <td width="200">4331.881730556488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_8192</td>
      <td width="200">8614.030168056488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_16384</td>
      <td width="200">17229.811418056488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_32768</td>
      <td width="200">34551.21766805649</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_65536</td>
      <td width="200">68967.78016805649</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_131072</td>
      <td width="200">137595.9051680565</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_262144</td>
      <td width="200">275987.1551680565</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32_524288</td>
      <td width="200">553789.6551680565</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_8</td>
      <td width="200">4.740273952484131</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_16</td>
      <td width="200">10.58786153793335</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_32</td>
      <td width="200">22.414567470550537</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_64</td>
      <td width="200">54.34266805648804</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_128</td>
      <td width="200">122.77772665023804</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_256</td>
      <td width="200">260.56825399398804</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_512</td>
      <td width="200">535.870988368988</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_1024</td>
      <td width="200">1093.444230556488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_2048</td>
      <td width="200">2212.389543056488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_4096</td>
      <td width="200">4348.912980556488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_8192</td>
      <td width="200">8661.295793056488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_16384</td>
      <td width="200">17303.248918056488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_32768</td>
      <td width="200">34500.28016805649</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_65536</td>
      <td width="200">69001.53016805649</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_131072</td>
      <td width="200">138274.6551680565</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_262144</td>
      <td width="200">275804.6551680565</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">hash/test/hash_checksum_benchmark/crc32c_524288</td>
      <td width="200">552744.6551680565</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroy</td>
      <td width="200">16.947193145751953</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/cloneOneBenchmark</td>
      <td width="200">33.32643508911133</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/cloneOneIntoBenchmark</td>
      <td width="200">24.432392120361328</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/cloneBenchmark</td>
      <td width="200">34.35548782348633</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/cloneIntoBenchmark</td>
      <td width="200">24.309864044189453</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/moveBenchmark</td>
      <td width="200">7.981510162353516</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/copyBenchmark</td>
      <td width="200">26.902179718017578</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/copyBufferFromStringBenchmark</td>
      <td width="200">23.589496612548828</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/copyBufferFromStringPieceBenchmark</td>
      <td width="200">23.143482208251953</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/cloneCoalescedBaseline</td>
      <td width="200">369.5331001281738</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/%cloneCoalescedBenchmark</td>
      <td width="200">45.97169876098633</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/takeOwnershipBenchmark</td>
      <td width="200">22.837085723876953</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(64)</td>
      <td width="200">24055.592670440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(256)</td>
      <td width="200">24397.467670440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(1024)</td>
      <td width="200">39116.217670440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(4096)</td>
      <td width="200">46337.780170440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(5000)</td>
      <td width="200">48857.467670440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(5120)</td>
      <td width="200">47662.780170440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(8192)</td>
      <td width="200">48519.030170440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(10000)</td>
      <td width="200">48590.905170440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(10240)</td>
      <td width="200">49187.780170440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(16384)</td>
      <td width="200">49617.780170440674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">io/test/io_iobuf_benchmark/createAndDestroyMulti(17000)</td>
      <td width="200">1489279.6551704407</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/libc_tolower</td>
      <td width="200">530.0164985656738</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/folly_toLowerAscii</td>
      <td width="200">21.495380401611328</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/folly_toUpperAscii</td>
      <td width="200">21.701068878173828</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(1)</td>
      <td width="200">85.65633010864258</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(4)</td>
      <td width="200">110.34993362426758</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(16)</td>
      <td width="200">110.41279983520508</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(64)</td>
      <td width="200">116.64143753051758</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(256)</td>
      <td width="200">256.0572700500488</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfOutputSize(1024)</td>
      <td width="200">428.8624458312988</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/stringPrintfAppendfBenchmark</td>
      <td width="200">15075982.65517044</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(1)</td>
      <td width="200">51.16496658325195</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(4)</td>
      <td width="200">65.25654983520508</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(16)</td>
      <td width="200">66.14033889770508</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(64)</td>
      <td width="200">76.06648635864258</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(256)</td>
      <td width="200">78.42854690551758</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtOutputSize(1024)</td>
      <td width="200">186.16676712036133</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/fmtAppendfBenchmark</td>
      <td width="200">2847199.6551704407</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(1)</td>
      <td width="200">71.77632522583008</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(4)</td>
      <td width="200">107.55086135864258</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(16)</td>
      <td width="200">105.86995315551758</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(64)</td>
      <td width="200">106.52852249145508</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(256)</td>
      <td width="200">109.56563186645508</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/follyFmtOutputSize(1024)</td>
      <td width="200">163.94874954223633</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/BM_cEscape</td>
      <td width="200">234624.65517044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/BM_cUnescape</td>
      <td width="200">172123.40517044067</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/BM_uriEscape</td>
      <td width="200">2365.553607940674</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/BM_uriUnescape</td>
      <td width="200">1117.4188423156738</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/BM_unhexlify</td>
      <td width="200">0.10802745819091797</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/splitOnSingleChar</td>
      <td width="200">889.4891548156738</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/splitOnSingleCharFixed</td>
      <td width="200">267.6214790344238</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/splitOnSingleCharFixedAllowExtra</td>
      <td width="200">174.42445755004883</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/splitStr</td>
      <td width="200">1588.6395454406738</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/splitStrFixed</td>
      <td width="200">407.9339790344238</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/boost_splitOnSingleChar</td>
      <td width="200">1596.1883735656738</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/joinCharStr</td>
      <td width="200">1152.8094673156738</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/joinStrStr</td>
      <td width="200">1054.9969673156738</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">test/string_benchmark/joinInt</td>
      <td width="200">1521.7254829406738</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="200">232.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="200">218.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="200">215.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="200">620.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="200">500.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="200">474.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="200">29.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="200">22.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="200">25.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="200">20.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="200">11.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="200">9.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="200">43.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="200">34.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="200">29.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="200">30.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="200">29.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="200">29.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="200">43.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="200">33.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="200">29.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="200">11.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="200">40.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="200">38.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="200">37.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="200">60.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="200">53.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="200">49.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="200">56.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="200">52.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="200">46.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="200">28.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="200">24.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="200">20.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="200">23.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="200">16.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="200">38.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="200">26.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="200">23.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="200">60.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="200">35.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="200">28.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="200">99.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="200">62.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="200">40.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- empty/Max time (ns/op)</td>
      <td width="200">3.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="200">3.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- empty/Min time (ns/op)</td>
      <td width="200">3.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="200">6.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="200">5.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="200">4.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="200">20.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="200">16.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="200">129.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="200">118.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="200">110.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="200">304.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="200">299.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="200">295.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="200">315.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="200">299.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="200">296.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="200">310.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="200">299.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="200">293.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="200">297.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="200">287.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="200">284.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="200">318.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="200">302.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="200">297.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="200">490.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="200">477.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="200">439.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="200">1070.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="200">819.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="200">529.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="200">77.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="200">67.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="200">60.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="200">62.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="200">51.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="200">47.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="200">33.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="200">25.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="200">18.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="200">80.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="200">76.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="200">67.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="200">87.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="200">74.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="200">65.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="200">89.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="200">80.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="200">63.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="200">33.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="200">26.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="200">21.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="200">105.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="200">93.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="200">81.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="200">89.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="200">85.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="200">81.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="200">95.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="200">81.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="200">75.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="200">54.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="200">49.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="200">40.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="200">62.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="200">55.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="200">50.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="200">88.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="200">72.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="200">63.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="200">113.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="200">100.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="200">71.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="200">3619.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="200">1212.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="200">56.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="200">15.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="200">15.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="200">13.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="200">11.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- empty/Max time (ns/op)</td>
      <td width="200">10.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="200">9.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- empty/Min time (ns/op)</td>
      <td width="200">8.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="200">17.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="200">14.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="200">12.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="200">57.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="200">43.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="200">34.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="200">317.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="200">279.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="200">251.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="200">840.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="200">725.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="200">638.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="200">678.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="200">654.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="200">632.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="200">840.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="200">698.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="200">631.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="200">915.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="200">748.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="200">624.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="200">894.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="200">721.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">folly</td>
      <td width="160">2026.08.17.00</td>
      <td width="420">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="200">624.0</td>
      <td width="160">ns/op</td>
      <td width="260">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

<table width="1380">
  <thead>
    <tr>
      <th width="160">软件</th>
      <th width="140">版本</th>
      <th width="340">指标</th>
      <th width="180">优化方向</th>
      <th width="160">x86_64</th>
      <th width="160">aarch64</th>
      <th width="240">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">container/test/container_bit_iterator_bench/SimpleFFSTest</td>
      <td width="180">越小越好</td>
      <td width="160">117576015.86369014</td>
      <td width="160">122522179.65516806</td>
      <td width="240">0.9596</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">container/test/container_bit_iterator_bench/RealFFSTest</td>
      <td width="180">越小越好</td>
      <td width="160">7561140.863690138</td>
      <td width="160">8649659.655168056</td>
      <td width="240">0.8742</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">88.0</td>
      <td width="160">112.0</td>
      <td width="240">0.7857</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">87.0</td>
      <td width="160">109.0</td>
      <td width="240">0.7982</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">86.0</td>
      <td width="160">106.0</td>
      <td width="240">0.8113</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">146.0</td>
      <td width="160">305.0</td>
      <td width="240">0.4787</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">145.0</td>
      <td width="160">302.0</td>
      <td width="240">0.4801</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">145.0</td>
      <td width="160">299.0</td>
      <td width="240">0.4849</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">12.0</td>
      <td width="160">17.0</td>
      <td width="240">0.7059</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">12.0</td>
      <td width="160">16.0</td>
      <td width="240">0.75</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">12.0</td>
      <td width="160">15.0</td>
      <td width="240">0.8</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">8.0</td>
      <td width="160">10.0</td>
      <td width="240">0.8</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">8.0</td>
      <td width="160">10.0</td>
      <td width="240">0.8</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">7.0</td>
      <td width="160">10.0</td>
      <td width="240">0.7</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">4.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">4.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">4.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">5.0</td>
      <td width="240">0.8</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">4.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">4.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">20.0</td>
      <td width="160">24.0</td>
      <td width="240">0.8333</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">20.0</td>
      <td width="160">24.0</td>
      <td width="240">0.8333</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">20.0</td>
      <td width="160">24.0</td>
      <td width="240">0.8333</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">17.0</td>
      <td width="160">19.0</td>
      <td width="240">0.8947</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">17.0</td>
      <td width="160">19.0</td>
      <td width="240">0.8947</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">17.0</td>
      <td width="160">19.0</td>
      <td width="240">0.8947</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">16.0</td>
      <td width="160">18.0</td>
      <td width="240">0.8889</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">16.0</td>
      <td width="160">18.0</td>
      <td width="240">0.8889</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">16.0</td>
      <td width="160">18.0</td>
      <td width="240">0.8889</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">8.0</td>
      <td width="160">10.0</td>
      <td width="240">0.8</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">8.0</td>
      <td width="160">10.0</td>
      <td width="240">0.8</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">8.0</td>
      <td width="160">10.0</td>
      <td width="240">0.8</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">15.0</td>
      <td width="240">0.4</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">15.0</td>
      <td width="240">0.4</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">14.0</td>
      <td width="240">0.4286</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">5.0</td>
      <td width="160">25.0</td>
      <td width="240">0.2</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">5.0</td>
      <td width="160">25.0</td>
      <td width="240">0.2</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">5.0</td>
      <td width="160">22.0</td>
      <td width="240">0.2273</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">10.0</td>
      <td width="160">41.0</td>
      <td width="240">0.2439</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">10.0</td>
      <td width="160">35.0</td>
      <td width="240">0.2857</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">9.0</td>
      <td width="160">33.0</td>
      <td width="240">0.2727</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">11.0</td>
      <td width="160">60.0</td>
      <td width="240">0.1833</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">11.0</td>
      <td width="160">59.0</td>
      <td width="240">0.1864</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">11.0</td>
      <td width="160">59.0</td>
      <td width="240">0.1864</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">2.0</td>
      <td width="240">0.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">2.0</td>
      <td width="240">0.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">2.0</td>
      <td width="240">0.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">7.0</td>
      <td width="240">0.8571</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">7.0</td>
      <td width="240">0.8571</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">7.0</td>
      <td width="240">0.8571</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">57.0</td>
      <td width="160">68.0</td>
      <td width="240">0.8382</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">56.0</td>
      <td width="160">68.0</td>
      <td width="240">0.8235</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">55.0</td>
      <td width="160">67.0</td>
      <td width="240">0.8209</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">177.0</td>
      <td width="240">0.7966</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">175.0</td>
      <td width="240">0.8057</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">175.0</td>
      <td width="240">0.8057</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">188.0</td>
      <td width="240">0.75</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">188.0</td>
      <td width="240">0.75</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">187.0</td>
      <td width="240">0.754</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">176.0</td>
      <td width="240">0.8011</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">175.0</td>
      <td width="240">0.8057</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">90.0</td>
      <td width="160">112.0</td>
      <td width="240">0.8036</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">88.0</td>
      <td width="160">109.0</td>
      <td width="240">0.8073</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">86.0</td>
      <td width="160">106.0</td>
      <td width="240">0.8113</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">184.0</td>
      <td width="160">362.0</td>
      <td width="240">0.5083</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">162.0</td>
      <td width="160">317.0</td>
      <td width="240">0.511</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">148.0</td>
      <td width="160">305.0</td>
      <td width="240">0.4852</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">27.0</td>
      <td width="160">14.0</td>
      <td width="240">1.9286</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">24.0</td>
      <td width="160">13.0</td>
      <td width="240">1.8462</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">18.0</td>
      <td width="160">13.0</td>
      <td width="240">1.3846</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">18.0</td>
      <td width="160">10.0</td>
      <td width="240">1.8</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">15.0</td>
      <td width="160">10.0</td>
      <td width="240">1.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">7.0</td>
      <td width="160">10.0</td>
      <td width="240">0.7</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">4.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">4.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">4.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">19.0</td>
      <td width="240">2.0526</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">19.0</td>
      <td width="240">2.0526</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">19.0</td>
      <td width="240">2.0526</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">19.0</td>
      <td width="240">2.0526</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">19.0</td>
      <td width="240">2.0526</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">19.0</td>
      <td width="240">2.0526</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">19.0</td>
      <td width="240">2.0526</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">23.0</td>
      <td width="160">19.0</td>
      <td width="240">1.2105</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">5.0</td>
      <td width="240">0.8</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">5.0</td>
      <td width="240">0.8</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">4.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">24.0</td>
      <td width="240">1.625</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">24.0</td>
      <td width="240">1.625</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">24.0</td>
      <td width="240">1.625</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">32.0</td>
      <td width="160">19.0</td>
      <td width="240">1.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">31.0</td>
      <td width="160">19.0</td>
      <td width="240">1.6316</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">29.0</td>
      <td width="160">19.0</td>
      <td width="240">1.5263</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">31.0</td>
      <td width="160">18.0</td>
      <td width="240">1.7222</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">31.0</td>
      <td width="160">18.0</td>
      <td width="240">1.7222</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">31.0</td>
      <td width="160">18.0</td>
      <td width="240">1.7222</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">16.0</td>
      <td width="160">22.0</td>
      <td width="240">0.7273</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">17.0</td>
      <td width="240">0.7647</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">12.0</td>
      <td width="160">13.0</td>
      <td width="240">0.9231</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">15.0</td>
      <td width="240">0.4</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">14.0</td>
      <td width="240">0.4286</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">14.0</td>
      <td width="240">0.4286</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">5.0</td>
      <td width="160">16.0</td>
      <td width="240">0.3125</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">5.0</td>
      <td width="160">16.0</td>
      <td width="240">0.3125</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">5.0</td>
      <td width="160">15.0</td>
      <td width="240">0.3333</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">7.0</td>
      <td width="160">33.0</td>
      <td width="240">0.2121</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">7.0</td>
      <td width="160">31.0</td>
      <td width="240">0.2258</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">7.0</td>
      <td width="160">31.0</td>
      <td width="240">0.2258</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">14.0</td>
      <td width="160">55.0</td>
      <td width="240">0.2545</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">14.0</td>
      <td width="160">55.0</td>
      <td width="240">0.2545</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">14.0</td>
      <td width="160">55.0</td>
      <td width="240">0.2545</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">2.0</td>
      <td width="240">0.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">2.0</td>
      <td width="240">0.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">2.0</td>
      <td width="240">0.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">7.0</td>
      <td width="240">0.8571</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">7.0</td>
      <td width="240">0.8571</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">6.0</td>
      <td width="160">7.0</td>
      <td width="240">0.8571</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">56.0</td>
      <td width="160">68.0</td>
      <td width="240">0.8235</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">56.0</td>
      <td width="160">68.0</td>
      <td width="240">0.8235</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">55.0</td>
      <td width="160">67.0</td>
      <td width="240">0.8209</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">144.0</td>
      <td width="160">179.0</td>
      <td width="240">0.8045</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">142.0</td>
      <td width="160">178.0</td>
      <td width="240">0.7978</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">177.0</td>
      <td width="240">0.7966</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">142.0</td>
      <td width="160">179.0</td>
      <td width="240">0.7933</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">176.0</td>
      <td width="240">0.8011</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">142.0</td>
      <td width="160">177.0</td>
      <td width="240">0.8023</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">175.0</td>
      <td width="240">0.8057</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">142.0</td>
      <td width="160">177.0</td>
      <td width="240">0.8023</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">175.0</td>
      <td width="240">0.8057</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">142.0</td>
      <td width="160">175.0</td>
      <td width="240">0.8114</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">175.0</td>
      <td width="240">0.8057</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">141.0</td>
      <td width="160">174.0</td>
      <td width="240">0.8103</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">157.0</td>
      <td width="160">112.0</td>
      <td width="240">1.4018</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">142.0</td>
      <td width="160">112.0</td>
      <td width="240">1.2679</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">132.0</td>
      <td width="160">112.0</td>
      <td width="240">1.1786</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">277.0</td>
      <td width="160">656.0</td>
      <td width="240">0.4223</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">253.0</td>
      <td width="160">348.0</td>
      <td width="240">0.727</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">242.0</td>
      <td width="160">310.0</td>
      <td width="240">0.7806</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">31.0</td>
      <td width="160">14.0</td>
      <td width="240">2.2143</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">24.0</td>
      <td width="160">13.0</td>
      <td width="240">1.8462</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">17.0</td>
      <td width="160">13.0</td>
      <td width="240">1.3077</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">33.0</td>
      <td width="160">10.0</td>
      <td width="240">3.3</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">26.0</td>
      <td width="160">10.0</td>
      <td width="240">2.6</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">14.0</td>
      <td width="160">10.0</td>
      <td width="240">1.4</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">11.0</td>
      <td width="160">4.0</td>
      <td width="240">2.75</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">8.0</td>
      <td width="160">4.0</td>
      <td width="240">2.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">8.0</td>
      <td width="160">4.0</td>
      <td width="240">2.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">38.0</td>
      <td width="160">19.0</td>
      <td width="240">2.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">32.0</td>
      <td width="160">19.0</td>
      <td width="240">1.6842</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">22.0</td>
      <td width="160">19.0</td>
      <td width="240">1.1579</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">39.0</td>
      <td width="160">19.0</td>
      <td width="240">2.0526</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">33.0</td>
      <td width="160">19.0</td>
      <td width="240">1.7368</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">22.0</td>
      <td width="160">19.0</td>
      <td width="240">1.1579</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">35.0</td>
      <td width="160">19.0</td>
      <td width="240">1.8421</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">31.0</td>
      <td width="160">19.0</td>
      <td width="240">1.6316</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">25.0</td>
      <td width="160">19.0</td>
      <td width="240">1.3158</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">11.0</td>
      <td width="160">8.0</td>
      <td width="240">1.375</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">9.0</td>
      <td width="160">6.0</td>
      <td width="240">1.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">8.0</td>
      <td width="160">5.0</td>
      <td width="240">1.6</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">44.0</td>
      <td width="160">24.0</td>
      <td width="240">1.8333</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">36.0</td>
      <td width="160">24.0</td>
      <td width="240">1.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">31.0</td>
      <td width="160">24.0</td>
      <td width="240">1.2917</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">37.0</td>
      <td width="160">20.0</td>
      <td width="240">1.85</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">31.0</td>
      <td width="160">19.0</td>
      <td width="240">1.6316</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">25.0</td>
      <td width="160">19.0</td>
      <td width="240">1.3158</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">35.0</td>
      <td width="160">18.0</td>
      <td width="240">1.9444</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">32.0</td>
      <td width="160">18.0</td>
      <td width="240">1.7778</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">24.0</td>
      <td width="160">18.0</td>
      <td width="240">1.3333</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">17.0</td>
      <td width="160">27.0</td>
      <td width="240">0.6296</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">15.0</td>
      <td width="160">23.0</td>
      <td width="240">0.6522</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">12.0</td>
      <td width="160">19.0</td>
      <td width="240">0.6316</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">12.0</td>
      <td width="160">14.0</td>
      <td width="240">0.8571</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">9.0</td>
      <td width="160">14.0</td>
      <td width="240">0.6429</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">8.0</td>
      <td width="160">14.0</td>
      <td width="240">0.5714</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">10.0</td>
      <td width="160">29.0</td>
      <td width="240">0.3448</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">8.0</td>
      <td width="160">19.0</td>
      <td width="240">0.4211</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">7.0</td>
      <td width="160">18.0</td>
      <td width="240">0.3889</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">17.0</td>
      <td width="160">50.0</td>
      <td width="240">0.34</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">14.0</td>
      <td width="160">30.0</td>
      <td width="240">0.4667</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">11.0</td>
      <td width="160">26.0</td>
      <td width="240">0.4231</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">20.0</td>
      <td width="160">63.0</td>
      <td width="240">0.3175</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">19.0</td>
      <td width="160">50.0</td>
      <td width="240">0.38</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">18.0</td>
      <td width="160">43.0</td>
      <td width="240">0.4186</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">2.0</td>
      <td width="240">2.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">3.0</td>
      <td width="160">2.0</td>
      <td width="240">1.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">2.0</td>
      <td width="160">1.0</td>
      <td width="240">2.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">2.0</td>
      <td width="240">2.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">3.0</td>
      <td width="160">2.0</td>
      <td width="240">1.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">2.0</td>
      <td width="160">2.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">3.0</td>
      <td width="240">1.3333</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">3.0</td>
      <td width="160">2.0</td>
      <td width="240">1.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">2.0</td>
      <td width="160">2.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">3.0</td>
      <td width="240">1.3333</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">3.0</td>
      <td width="160">2.0</td>
      <td width="240">1.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">2.0</td>
      <td width="160">2.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">2.0</td>
      <td width="160">2.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">4.0</td>
      <td width="160">2.0</td>
      <td width="240">2.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">3.0</td>
      <td width="160">2.0</td>
      <td width="240">1.5</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">2.0</td>
      <td width="160">2.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">18.0</td>
      <td width="160">8.0</td>
      <td width="240">2.25</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">13.0</td>
      <td width="160">7.0</td>
      <td width="240">1.8571</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">12.0</td>
      <td width="160">7.0</td>
      <td width="240">1.7143</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">128.0</td>
      <td width="160">69.0</td>
      <td width="240">1.8551</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">118.0</td>
      <td width="160">68.0</td>
      <td width="240">1.7353</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">110.0</td>
      <td width="160">68.0</td>
      <td width="240">1.6176</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">301.0</td>
      <td width="160">180.0</td>
      <td width="240">1.6722</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">289.0</td>
      <td width="160">179.0</td>
      <td width="240">1.6145</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">282.0</td>
      <td width="160">178.0</td>
      <td width="240">1.5843</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">301.0</td>
      <td width="160">180.0</td>
      <td width="240">1.6722</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">287.0</td>
      <td width="160">179.0</td>
      <td width="240">1.6034</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">282.0</td>
      <td width="160">178.0</td>
      <td width="240">1.5843</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">297.0</td>
      <td width="160">180.0</td>
      <td width="240">1.65</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">290.0</td>
      <td width="160">179.0</td>
      <td width="240">1.6201</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">282.0</td>
      <td width="160">178.0</td>
      <td width="240">1.5843</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">317.0</td>
      <td width="160">180.0</td>
      <td width="240">1.7611</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">288.0</td>
      <td width="160">179.0</td>
      <td width="240">1.6089</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">282.0</td>
      <td width="160">179.0</td>
      <td width="240">1.5754</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">300.0</td>
      <td width="160">182.0</td>
      <td width="240">1.6484</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">287.0</td>
      <td width="160">181.0</td>
      <td width="240">1.5856</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">282.0</td>
      <td width="160">180.0</td>
      <td width="240">1.5667</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/constantFuture</td>
      <td width="180">越小越好</td>
      <td width="160">15.962965488433838</td>
      <td width="160">29.715442657470703</td>
      <td width="240">0.5372</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%promiseAndFuture</td>
      <td width="180">越小越好</td>
      <td width="160">35.58347940444946</td>
      <td width="160">75.83620071411133</td>
      <td width="240">0.4692</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%withThen</td>
      <td width="180">越小越好</td>
      <td width="160">96.20817422866821</td>
      <td width="160">265.3949165344238</td>
      <td width="240">0.3625</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/oneThen</td>
      <td width="180">越小越好</td>
      <td width="160">70.14250040054321</td>
      <td width="160">166.52162551879883</td>
      <td width="240">0.4212</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%twoThens</td>
      <td width="180">越小越好</td>
      <td width="160">126.41508340835571</td>
      <td width="160">302.9193305969238</td>
      <td width="240">0.4173</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%fourThens</td>
      <td width="180">越小越好</td>
      <td width="160">236.6042923927307</td>
      <td width="160">570.6366157531738</td>
      <td width="240">0.4146</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%hundredThens</td>
      <td width="180">越小越好</td>
      <td width="160">5471.504194736481</td>
      <td width="160">13582.545795440674</td>
      <td width="240">0.4028</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%fourThensOnThread</td>
      <td width="180">越小越好</td>
      <td width="160">27476.11356973648</td>
      <td width="160">31286.530170440674</td>
      <td width="240">0.8782</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%fourThensOnThreadInline</td>
      <td width="180">越小越好</td>
      <td width="160">27133.14481973648</td>
      <td width="160">31576.530170440674</td>
      <td width="240">0.8593</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%hundredThensOnThread</td>
      <td width="180">越小越好</td>
      <td width="160">41522.98856973648</td>
      <td width="160">68744.03017044067</td>
      <td width="240">0.604</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%hundredThensOnThreadInline</td>
      <td width="180">越小越好</td>
      <td width="160">28017.05106973648</td>
      <td width="160">50332.780170440674</td>
      <td width="240">0.5566</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/no_contention</td>
      <td width="180">越小越好</td>
      <td width="160">1550356.8635697365</td>
      <td width="160">4473272.655170441</td>
      <td width="240">0.3466</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%contention</td>
      <td width="180">越小越好</td>
      <td width="160">1195305.8635697365</td>
      <td width="160">4145012.6551704407</td>
      <td width="240">0.2884</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/throwAndCatch</td>
      <td width="180">越小越好</td>
      <td width="160">3417.7541947364807</td>
      <td width="160">7581.334857940674</td>
      <td width="240">0.4508</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%throwAndCatchWrapped</td>
      <td width="180">越小越好</td>
      <td width="160">1490.8010697364807</td>
      <td width="160">3196.100482940674</td>
      <td width="240">0.4664</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%throwWrappedAndCatch</td>
      <td width="180">越小越好</td>
      <td width="160">2184.6487259864807</td>
      <td width="160">4762.975482940674</td>
      <td width="240">0.4587</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%throwWrappedAndCatchWrapped</td>
      <td width="180">越小越好</td>
      <td width="160">197.3159623146057</td>
      <td width="160">435.9906196594238</td>
      <td width="240">0.4526</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/throwAndCatchContended</td>
      <td width="180">越小越好</td>
      <td width="160">35536083.86356974</td>
      <td width="160">13978355.65517044</td>
      <td width="240">2.5422</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%throwAndCatchWrappedContended</td>
      <td width="180">越小越好</td>
      <td width="160">15766261.863569736</td>
      <td width="160">4280615.655170441</td>
      <td width="240">3.6832</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%throwWrappedAndCatchContended</td>
      <td width="180">越小越好</td>
      <td width="160">15656582.863569736</td>
      <td width="160">6768065.655170441</td>
      <td width="240">2.3133</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%throwWrappedAndCatchWrappedContended</td>
      <td width="180">越小越好</td>
      <td width="160">3360511.8635697365</td>
      <td width="160">1009915.6551704407</td>
      <td width="240">3.3275</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/lvalue_get</td>
      <td width="180">越小越好</td>
      <td width="160">126.66093301773071</td>
      <td width="160">213.37123489379883</td>
      <td width="240">0.5936</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%rvalue_get</td>
      <td width="180">越小越好</td>
      <td width="160">125.67338418960571</td>
      <td width="160">213.15272903442383</td>
      <td width="240">0.5896</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/complexUnit</td>
      <td width="180">越小越好</td>
      <td width="160">24511.11356973648</td>
      <td width="160">68309.65517044067</td>
      <td width="240">0.3588</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%complexBlob4</td>
      <td width="180">越小越好</td>
      <td width="160">24497.83231973648</td>
      <td width="160">67514.65517044067</td>
      <td width="240">0.3629</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%complexBlob8</td>
      <td width="180">越小越好</td>
      <td width="160">23825.01981973648</td>
      <td width="160">67396.53017044067</td>
      <td width="240">0.3535</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%complexBlob64</td>
      <td width="180">越小越好</td>
      <td width="160">26054.23856973648</td>
      <td width="160">69160.90517044067</td>
      <td width="240">0.3767</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%complexBlob128</td>
      <td width="180">越小越好</td>
      <td width="160">27157.67606973648</td>
      <td width="160">71305.90517044067</td>
      <td width="240">0.3809</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%complexBlob256</td>
      <td width="180">越小越好</td>
      <td width="160">29098.30106973648</td>
      <td width="160">75689.03017044067</td>
      <td width="240">0.3844</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%complexBlob512</td>
      <td width="180">越小越好</td>
      <td width="160">36205.17606973648</td>
      <td width="160">75602.78017044067</td>
      <td width="240">0.4789</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%complexBlob1024</td>
      <td width="180">越小越好</td>
      <td width="160">45243.92606973648</td>
      <td width="160">96624.65517044067</td>
      <td width="240">0.4682</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%complexBlob2048</td>
      <td width="180">越小越好</td>
      <td width="160">51500.17606973648</td>
      <td width="160">110573.40517044067</td>
      <td width="240">0.4658</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">futures/test/futures_benchmark/%complexBlob4096</td>
      <td width="180">越小越好</td>
      <td width="160">83093.61356973648</td>
      <td width="160">136097.15517044067</td>
      <td width="240">0.6105</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_8</td>
      <td width="180">越小越好</td>
      <td width="160">5.037438869476318</td>
      <td width="160">4.797074794769287</td>
      <td width="240">1.0501</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_16</td>
      <td width="180">越小越好</td>
      <td width="160">5.580995082855225</td>
      <td width="160">11.019303798675537</td>
      <td width="240">0.5065</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_32</td>
      <td width="180">越小越好</td>
      <td width="160">6.683480739593506</td>
      <td width="160">22.609117031097412</td>
      <td width="240">0.2956</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_64</td>
      <td width="180">越小越好</td>
      <td width="160">8.860909938812256</td>
      <td width="160">53.06367635726929</td>
      <td width="240">0.167</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_128</td>
      <td width="180">越小越好</td>
      <td width="160">12.658212184906006</td>
      <td width="160">124.36342000961304</td>
      <td width="240">0.1018</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_256</td>
      <td width="180">越小越好</td>
      <td width="160">21.38570547103882</td>
      <td width="160">263.81288290023804</td>
      <td width="240">0.0811</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_512</td>
      <td width="180">越小越好</td>
      <td width="160">38.83764028549194</td>
      <td width="160">539.450089931488</td>
      <td width="240">0.072</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_1024</td>
      <td width="180">越小越好</td>
      <td width="160">73.74059438705444</td>
      <td width="160">1085.426652431488</td>
      <td width="240">0.0679</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_2048</td>
      <td width="180">越小越好</td>
      <td width="160">143.61608266830444</td>
      <td width="160">2196.940324306488</td>
      <td width="240">0.0654</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_4096</td>
      <td width="180">越小越好</td>
      <td width="160">283.22570180892944</td>
      <td width="160">4331.881730556488</td>
      <td width="240">0.0654</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_8192</td>
      <td width="180">越小越好</td>
      <td width="160">562.3880553245544</td>
      <td width="160">8614.030168056488</td>
      <td width="240">0.0653</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_16384</td>
      <td width="180">越小越好</td>
      <td width="160">1121.9046568870544</td>
      <td width="160">17229.811418056488</td>
      <td width="240">0.0651</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_32768</td>
      <td width="180">越小越好</td>
      <td width="160">2237.8519225120544</td>
      <td width="160">34551.21766805649</td>
      <td width="240">0.0648</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_65536</td>
      <td width="180">越小越好</td>
      <td width="160">4477.519891262054</td>
      <td width="160">68967.78016805649</td>
      <td width="240">0.0649</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_131072</td>
      <td width="180">越小越好</td>
      <td width="160">8957.051141262054</td>
      <td width="160">137595.9051680565</td>
      <td width="240">0.0651</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_262144</td>
      <td width="180">越小越好</td>
      <td width="160">17891.426141262054</td>
      <td width="160">275987.1551680565</td>
      <td width="240">0.0648</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32_524288</td>
      <td width="180">越小越好</td>
      <td width="160">35768.301141262054</td>
      <td width="160">553789.6551680565</td>
      <td width="240">0.0646</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_8</td>
      <td width="180">越小越好</td>
      <td width="160">3.138749599456787</td>
      <td width="160">4.740273952484131</td>
      <td width="240">0.6621</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_16</td>
      <td width="180">越小越好</td>
      <td width="160">3.9670348167419434</td>
      <td width="160">10.58786153793335</td>
      <td width="240">0.3747</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_32</td>
      <td width="180">越小越好</td>
      <td width="160">3.966691493988037</td>
      <td width="160">22.414567470550537</td>
      <td width="240">0.177</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_64</td>
      <td width="180">越小越好</td>
      <td width="160">4.231126308441162</td>
      <td width="160">54.34266805648804</td>
      <td width="240">0.0779</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_128</td>
      <td width="180">越小越好</td>
      <td width="160">7.509667873382568</td>
      <td width="160">122.77772665023804</td>
      <td width="240">0.0612</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_256</td>
      <td width="180">越小越好</td>
      <td width="160">12.833306789398193</td>
      <td width="160">260.56825399398804</td>
      <td width="240">0.0493</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_512</td>
      <td width="180">越小越好</td>
      <td width="160">23.28603506088257</td>
      <td width="160">535.870988368988</td>
      <td width="240">0.0435</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_1024</td>
      <td width="180">越小越好</td>
      <td width="160">41.00469350814819</td>
      <td width="160">1093.444230556488</td>
      <td width="240">0.0375</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_2048</td>
      <td width="180">越小越好</td>
      <td width="160">75.77123403549194</td>
      <td width="160">2212.389543056488</td>
      <td width="240">0.0342</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_4096</td>
      <td width="180">越小越好</td>
      <td width="160">150.24816274642944</td>
      <td width="160">4348.912980556488</td>
      <td width="240">0.0345</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_8192</td>
      <td width="180">越小越好</td>
      <td width="160">440.04186391830444</td>
      <td width="160">8661.295793056488</td>
      <td width="240">0.0508</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_16384</td>
      <td width="180">越小越好</td>
      <td width="160">823.1448912620544</td>
      <td width="160">17303.248918056488</td>
      <td width="240">0.0476</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_32768</td>
      <td width="180">越小越好</td>
      <td width="160">1587.8323912620544</td>
      <td width="160">34500.28016805649</td>
      <td width="240">0.046</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_65536</td>
      <td width="180">越小越好</td>
      <td width="160">3114.8831725120544</td>
      <td width="160">69001.53016805649</td>
      <td width="240">0.0451</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_131072</td>
      <td width="180">越小越好</td>
      <td width="160">6172.051141262054</td>
      <td width="160">138274.6551680565</td>
      <td width="240">0.0446</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_262144</td>
      <td width="180">越小越好</td>
      <td width="160">12258.066766262054</td>
      <td width="160">275804.6551680565</td>
      <td width="240">0.0444</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">hash/test/hash_checksum_benchmark/crc32c_524288</td>
      <td width="180">越小越好</td>
      <td width="160">24406.269891262054</td>
      <td width="160">552744.6551680565</td>
      <td width="240">0.0442</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroy</td>
      <td width="180">越小越好</td>
      <td width="160">13.75613808631897</td>
      <td width="160">16.947193145751953</td>
      <td width="240">0.8117</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/cloneOneBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">12.73532509803772</td>
      <td width="160">33.32643508911133</td>
      <td width="240">0.3821</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/cloneOneIntoBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">7.77255654335022</td>
      <td width="160">24.432392120361328</td>
      <td width="240">0.3181</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/cloneBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">14.812504053115845</td>
      <td width="160">34.35548782348633</td>
      <td width="240">0.4312</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/cloneIntoBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">8.043102502822876</td>
      <td width="160">24.309864044189453</td>
      <td width="240">0.3309</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/moveBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">8.04385781288147</td>
      <td width="160">7.981510162353516</td>
      <td width="240">1.0078</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/copyBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">11.355938196182251</td>
      <td width="160">26.902179718017578</td>
      <td width="240">0.4221</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/copyBufferFromStringBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">20.016056299209595</td>
      <td width="160">23.589496612548828</td>
      <td width="240">0.8485</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/copyBufferFromStringPieceBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">17.032352685928345</td>
      <td width="160">23.143482208251953</td>
      <td width="240">0.7359</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/cloneCoalescedBaseline</td>
      <td width="180">越小越好</td>
      <td width="160">148.54037880897522</td>
      <td width="160">369.5331001281738</td>
      <td width="240">0.402</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/%cloneCoalescedBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">28.91055703163147</td>
      <td width="160">45.97169876098633</td>
      <td width="240">0.6289</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/takeOwnershipBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">17.093998193740845</td>
      <td width="160">22.837085723876953</td>
      <td width="240">0.7485</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(64)</td>
      <td width="180">越小越好</td>
      <td width="160">18399.394870996475</td>
      <td width="160">24055.592670440674</td>
      <td width="240">0.7649</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(256)</td>
      <td width="180">越小越好</td>
      <td width="160">18433.926120996475</td>
      <td width="160">24397.467670440674</td>
      <td width="240">0.7556</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(1024)</td>
      <td width="180">越小越好</td>
      <td width="160">31892.363620996475</td>
      <td width="160">39116.217670440674</td>
      <td width="240">0.8153</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(4096)</td>
      <td width="180">越小越好</td>
      <td width="160">33928.926120996475</td>
      <td width="160">46337.780170440674</td>
      <td width="240">0.7322</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(5000)</td>
      <td width="180">越小越好</td>
      <td width="160">33482.676120996475</td>
      <td width="160">48857.467670440674</td>
      <td width="240">0.6853</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(5120)</td>
      <td width="180">越小越好</td>
      <td width="160">36799.863620996475</td>
      <td width="160">47662.780170440674</td>
      <td width="240">0.7721</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(8192)</td>
      <td width="180">越小越好</td>
      <td width="160">34491.113620996475</td>
      <td width="160">48519.030170440674</td>
      <td width="240">0.7109</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(10000)</td>
      <td width="180">越小越好</td>
      <td width="160">34211.426120996475</td>
      <td width="160">48590.905170440674</td>
      <td width="240">0.7041</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(10240)</td>
      <td width="180">越小越好</td>
      <td width="160">34494.863620996475</td>
      <td width="160">49187.780170440674</td>
      <td width="240">0.7013</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(16384)</td>
      <td width="180">越小越好</td>
      <td width="160">35121.738620996475</td>
      <td width="160">49617.780170440674</td>
      <td width="240">0.7078</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">io/test/io_iobuf_benchmark/createAndDestroyMulti(17000)</td>
      <td width="180">越小越好</td>
      <td width="160">35035.488620996475</td>
      <td width="160">1489279.6551704407</td>
      <td width="240">0.0235</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/libc_tolower</td>
      <td width="180">越小越好</td>
      <td width="160">698.2229578495026</td>
      <td width="160">530.0164985656738</td>
      <td width="240">1.3174</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/folly_toLowerAscii</td>
      <td width="180">越小越好</td>
      <td width="160">14.585415124893188</td>
      <td width="160">21.495380401611328</td>
      <td width="240">0.6785</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/folly_toUpperAscii</td>
      <td width="180">越小越好</td>
      <td width="160">15.153347253799438</td>
      <td width="160">21.701068878173828</td>
      <td width="240">0.6983</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/stringPrintfOutputSize(1)</td>
      <td width="180">越小越好</td>
      <td width="160">65.60247445106506</td>
      <td width="160">85.65633010864258</td>
      <td width="240">0.7659</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/stringPrintfOutputSize(4)</td>
      <td width="180">越小越好</td>
      <td width="160">77.75884652137756</td>
      <td width="160">110.34993362426758</td>
      <td width="240">0.7047</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/stringPrintfOutputSize(16)</td>
      <td width="180">越小越好</td>
      <td width="160">77.33465218544006</td>
      <td width="160">110.41279983520508</td>
      <td width="240">0.7004</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/stringPrintfOutputSize(64)</td>
      <td width="180">越小越好</td>
      <td width="160">78.59502816200256</td>
      <td width="160">116.64143753051758</td>
      <td width="240">0.6738</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/stringPrintfOutputSize(256)</td>
      <td width="180">越小越好</td>
      <td width="160">170.86529183387756</td>
      <td width="160">256.0572700500488</td>
      <td width="240">0.6673</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/stringPrintfOutputSize(1024)</td>
      <td width="180">越小越好</td>
      <td width="160">230.31353402137756</td>
      <td width="160">428.8624458312988</td>
      <td width="240">0.537</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/stringPrintfAppendfBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">9035845.86358285</td>
      <td width="160">15075982.65517044</td>
      <td width="240">0.5994</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/fmtOutputSize(1)</td>
      <td width="180">越小越好</td>
      <td width="160">47.83068490028381</td>
      <td width="160">51.16496658325195</td>
      <td width="240">0.9348</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/fmtOutputSize(4)</td>
      <td width="180">越小越好</td>
      <td width="160">59.33489632606506</td>
      <td width="160">65.25654983520508</td>
      <td width="240">0.9093</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/fmtOutputSize(16)</td>
      <td width="180">越小越好</td>
      <td width="160">59.36938118934631</td>
      <td width="160">66.14033889770508</td>
      <td width="240">0.8976</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/fmtOutputSize(64)</td>
      <td width="180">越小越好</td>
      <td width="160">59.05382943153381</td>
      <td width="160">76.06648635864258</td>
      <td width="240">0.7763</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/fmtOutputSize(256)</td>
      <td width="180">越小越好</td>
      <td width="160">59.91045784950256</td>
      <td width="160">78.42854690551758</td>
      <td width="240">0.7639</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/fmtOutputSize(1024)</td>
      <td width="180">越小越好</td>
      <td width="160">97.17779183387756</td>
      <td width="160">186.16676712036133</td>
      <td width="240">0.522</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/fmtAppendfBenchmark</td>
      <td width="180">越小越好</td>
      <td width="160">2744559.8635828495</td>
      <td width="160">2847199.6551704407</td>
      <td width="240">0.964</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/follyFmtOutputSize(1)</td>
      <td width="180">越小越好</td>
      <td width="160">64.72539925575256</td>
      <td width="160">71.77632522583008</td>
      <td width="240">0.9018</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/follyFmtOutputSize(4)</td>
      <td width="180">越小越好</td>
      <td width="160">85.85821175575256</td>
      <td width="160">107.55086135864258</td>
      <td width="240">0.7983</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/follyFmtOutputSize(16)</td>
      <td width="180">越小越好</td>
      <td width="160">85.36504769325256</td>
      <td width="160">105.86995315551758</td>
      <td width="240">0.8063</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/follyFmtOutputSize(64)</td>
      <td width="180">越小越好</td>
      <td width="160">85.11791634559631</td>
      <td width="160">106.52852249145508</td>
      <td width="240">0.799</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/follyFmtOutputSize(256)</td>
      <td width="180">越小越好</td>
      <td width="160">85.20757699012756</td>
      <td width="160">109.56563186645508</td>
      <td width="240">0.7777</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/follyFmtOutputSize(1024)</td>
      <td width="180">越小越好</td>
      <td width="160">114.87615609169006</td>
      <td width="160">163.94874954223633</td>
      <td width="240">0.7007</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/BM_cEscape</td>
      <td width="180">越小越好</td>
      <td width="160">181027.3635828495</td>
      <td width="160">234624.65517044067</td>
      <td width="240">0.7716</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/BM_cUnescape</td>
      <td width="180">越小越好</td>
      <td width="160">127733.6135828495</td>
      <td width="160">172123.40517044067</td>
      <td width="240">0.7421</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/BM_uriEscape</td>
      <td width="180">越小越好</td>
      <td width="160">1359.4631922245026</td>
      <td width="160">2365.553607940674</td>
      <td width="240">0.5747</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/BM_uriUnescape</td>
      <td width="180">越小越好</td>
      <td width="160">753.1887781620026</td>
      <td width="160">1117.4188423156738</td>
      <td width="240">0.674</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/BM_unhexlify</td>
      <td width="180">越小越好</td>
      <td width="160">0.20695090293884277</td>
      <td width="160">0.10802745819091797</td>
      <td width="240">1.9157</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/splitOnSingleChar</td>
      <td width="180">越小越好</td>
      <td width="160">632.2073328495026</td>
      <td width="160">889.4891548156738</td>
      <td width="240">0.7108</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/splitOnSingleCharFixed</td>
      <td width="180">越小越好</td>
      <td width="160">161.17828011512756</td>
      <td width="160">267.6214790344238</td>
      <td width="240">0.6023</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/splitOnSingleCharFixedAllowExtra</td>
      <td width="180">越小越好</td>
      <td width="160">135.17120003700256</td>
      <td width="160">174.42445755004883</td>
      <td width="240">0.775</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/splitStr</td>
      <td width="180">越小越好</td>
      <td width="160">1373.7317469120026</td>
      <td width="160">1588.6395454406738</td>
      <td width="240">0.8647</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/splitStrFixed</td>
      <td width="180">越小越好</td>
      <td width="160">254.29961800575256</td>
      <td width="160">407.9339790344238</td>
      <td width="240">0.6234</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/boost_splitOnSingleChar</td>
      <td width="180">越小越好</td>
      <td width="160">1257.6575281620026</td>
      <td width="160">1596.1883735656738</td>
      <td width="240">0.7879</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/joinCharStr</td>
      <td width="180">越小越好</td>
      <td width="160">692.5198328495026</td>
      <td width="160">1152.8094673156738</td>
      <td width="240">0.6007</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/joinStrStr</td>
      <td width="180">越小越好</td>
      <td width="160">636.5676844120026</td>
      <td width="160">1054.9969673156738</td>
      <td width="240">0.6034</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">test/string_benchmark/joinInt</td>
      <td width="180">越小越好</td>
      <td width="160">847.7493250370026</td>
      <td width="160">1521.7254829406738</td>
      <td width="240">0.5571</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">232.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">218.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">215.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">620.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">500.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">474.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">29.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">24.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">22.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">25.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">20.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">17.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">11.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">10.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">9.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">43.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">34.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">29.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">30.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">29.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">29.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">43.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">33.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">29.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">14.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">11.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">8.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">40.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">38.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">37.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">60.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">53.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">49.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">56.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">52.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">46.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">28.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">24.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">20.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">23.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">17.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">16.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">38.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">26.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">23.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">60.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">35.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">28.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">99.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">62.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">40.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">4.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">4.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">4.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">5.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">5.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">4.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">5.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">4.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">4.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">5.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">4.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">4.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">3.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">3.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">3.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">6.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">5.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">4.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">20.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">16.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">14.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">129.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">118.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">110.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">304.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">299.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">295.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">315.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">299.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">296.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">310.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">299.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">293.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">297.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">287.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">284.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">318.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">302.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=64/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">297.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">490.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">477.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">439.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">1070.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">819.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">529.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">77.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">67.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">60.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">62.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">51.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">47.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">33.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">25.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">18.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">80.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">76.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">67.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">87.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">74.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">65.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">89.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">80.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">63.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">33.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">26.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">21.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">105.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">93.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">81.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">89.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">85.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">81.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">95.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">81.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">75.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">54.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">49.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">40.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">62.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">55.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">50.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">88.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">72.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">63.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">113.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">100.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">71.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">3619.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">1212.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">56.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">13.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">12.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">12.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">15.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">12.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">10.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">15.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">13.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">10.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">13.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">12.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">11.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- empty/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">10.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">9.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- empty/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">8.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">17.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">14.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">12.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">57.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">43.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">34.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">317.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">279.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">251.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">840.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">725.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">638.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">678.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">654.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">632.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">840.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">698.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">631.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">915.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">748.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">624.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">894.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">721.0</td>
      <td width="240">N/A</td>
    </tr>
    <tr>
      <td width="160">folly</td>
      <td width="140">2026.08.17.00</td>
      <td width="340">concurrency/test/concurrency_concurrent_hash_map_bench/threads=256/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="180">越小越好</td>
      <td width="160">N/A</td>
      <td width="160">624.0</td>
      <td width="240">N/A</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
