# spdk 26.09 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`41984521740-1`

## 测试环境

### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">请求软件版本</td>
      <td width="1200">26.09</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">26.09</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-05T07:10:50Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">aarch64</td>
    </tr>
  </tbody>
</table>

### 系统信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="1200">2026-11-05T07:04:11Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">Kunpeng 950 7592C To Be Filled By O.E.M. CPU @ 2.3GHz</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="1200">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="1200">openEuler 24.03 (LTS-SP3)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="1200">6.6.0-132.0.0.111.oe2403sp3.aarch64</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 379899 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 385404 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 382981 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 384705 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">bdevperf</td>
      <td width="880">26.09</td>
    </tr>
    <tr>
      <td width="500">DPDK</td>
      <td width="880">26.03.0</td>
    </tr>
    <tr>
      <td width="500">ISA-L</td>
      <td width="880">7c3479e0a9dac17f448603ec1ad64c7c625f530c</td>
    </tr>
  </tbody>
</table>

## 性能指标

### randread_bs4k_qd1_single

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
      <td width="500">randread_bs4k_qd1_single / IOPS</td>
      <td width="280">2870193.1</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd1_single / MiB/s</td>
      <td width="280">11211.69</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd1_single / avg_latency_us</td>
      <td width="280">0.29</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd1_single / p99_latency_us</td>
      <td width="280">0.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd1_single / peak_rss_mib</td>
      <td width="280">467.93</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### randread_bs4k_qd32_single

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
      <td width="500">randread_bs4k_qd32_single / IOPS</td>
      <td width="280">3122717.97</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_single / MiB/s</td>
      <td width="280">12198.12</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_single / avg_latency_us</td>
      <td width="280">10.19</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_single / p99_latency_us</td>
      <td width="280">10.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_single / peak_rss_mib</td>
      <td width="280">467.945</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### randread_bs4k_qd128_single

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
      <td width="500">randread_bs4k_qd128_single / IOPS</td>
      <td width="280">2989866.72</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd128_single / MiB/s</td>
      <td width="280">11679.17</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd128_single / avg_latency_us</td>
      <td width="280">42.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd128_single / p99_latency_us</td>
      <td width="280">50.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd128_single / peak_rss_mib</td>
      <td width="280">467.957</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### randwrite_bs4k_qd32_single

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
      <td width="500">randwrite_bs4k_qd32_single / IOPS</td>
      <td width="280">4097864.08</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randwrite_bs4k_qd32_single / MiB/s</td>
      <td width="280">16007.28</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randwrite_bs4k_qd32_single / avg_latency_us</td>
      <td width="280">7.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randwrite_bs4k_qd32_single / p99_latency_us</td>
      <td width="280">8.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randwrite_bs4k_qd32_single / peak_rss_mib</td>
      <td width="280">467.938</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### randrw_bs4k_qd32_single

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
      <td width="500">randrw_bs4k_qd32_single / IOPS</td>
      <td width="280">2884416.79</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randrw_bs4k_qd32_single / MiB/s</td>
      <td width="280">11267.25</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randrw_bs4k_qd32_single / avg_latency_us</td>
      <td width="280">11.03</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randrw_bs4k_qd32_single / p99_latency_us</td>
      <td width="280">12.72</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randrw_bs4k_qd32_single / peak_rss_mib</td>
      <td width="280">467.957</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### randread_bs64k_qd32_single

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
      <td width="500">randread_bs64k_qd32_single / IOPS</td>
      <td width="280">361337.83</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs64k_qd32_single / MiB/s</td>
      <td width="280">22583.61</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs64k_qd32_single / avg_latency_us</td>
      <td width="280">88.45</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs64k_qd32_single / p99_latency_us</td>
      <td width="280">100.48</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs64k_qd32_single / peak_rss_mib</td>
      <td width="280">467.957</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### randread_bs128k_qd32_single

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
      <td width="500">randread_bs128k_qd32_single / IOPS</td>
      <td width="280">190376.84</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs128k_qd32_single / MiB/s</td>
      <td width="280">23797.11</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs128k_qd32_single / avg_latency_us</td>
      <td width="280">167.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs128k_qd32_single / p99_latency_us</td>
      <td width="280">183.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs128k_qd32_single / peak_rss_mib</td>
      <td width="280">467.926</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### randread_bs4k_qd32_multi4

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
      <td width="500">randread_bs4k_qd32_multi4 / IOPS</td>
      <td width="280">6398754.25</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_multi4 / MiB/s</td>
      <td width="280">24995.13</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_multi4 / avg_latency_us</td>
      <td width="280">19.9</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_multi4 / p99_latency_us</td>
      <td width="280">22.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_multi4 / peak_rss_mib</td>
      <td width="280">525.0</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
