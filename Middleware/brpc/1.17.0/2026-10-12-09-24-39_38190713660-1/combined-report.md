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
      <td width="180">Middleware</td>
      <td width="220">brpc</td>
      <td width="160">1.17.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Middleware</td>
      <td width="220">brpc</td>
      <td width="160">1.17.0</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### brpc 1.17.0

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
      <td width="600">1.17.0</td>
      <td width="600">1.17.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.17.0</td>
      <td width="600">1.17.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-10-12T01:09:20Z</td>
      <td width="600">2026-10-12T01:09:20Z</td>
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
      <td width="600">2026-10-12T01:08:20Z</td>
      <td width="600">2026-10-12T01:08:37Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">AMD EPYC 9654 96-Core Processor</td>
      <td width="600">-</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">384</td>
      <td width="600">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0-132.0.0.111.oe2403sp3.x86_64</td>
      <td width="600">6.6.0-159.4.14.168.oe2403sp4.aarch64</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 574945 MB<br>node 0 free: 344577 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 580594 MB<br>node 1 free: 419395 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 580594 MB<br>node 2 free: 431717 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 482782 MB<br>node 3 free: 329952 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">example/rdma_performance</td>
      <td width="880">1.17.0</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### brpc 1.17.0

##### 0B attachment

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
      <td width="500">attachment_0B_avg_latency</td>
      <td width="280">1970.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p90_latency</td>
      <td width="280">2219.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p99_latency</td>
      <td width="280">2648.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p999_latency</td>
      <td width="280">3281.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_throughput</td>
      <td width="280">0.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_qps</td>
      <td width="280">534200.0</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 1024B attachment

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
      <td width="500">attachment_1024B_avg_latency</td>
      <td width="280">5169.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p90_latency</td>
      <td width="280">6801.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p99_latency</td>
      <td width="280">8852.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p999_latency</td>
      <td width="280">12484.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_throughput</td>
      <td width="280">214.7386</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_qps</td>
      <td width="280">219892.3264</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 4096B attachment

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
      <td width="500">attachment_4096B_avg_latency</td>
      <td width="280">6370.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p90_latency</td>
      <td width="280">7271.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p99_latency</td>
      <td width="280">9004.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p999_latency</td>
      <td width="280">10260.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_throughput</td>
      <td width="280">638.5572</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_qps</td>
      <td width="280">163470.6432</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 8192B attachment

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
      <td width="500">attachment_8192B_avg_latency</td>
      <td width="280">9557.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p90_latency</td>
      <td width="280">11188.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p99_latency</td>
      <td width="280">13777.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p999_latency</td>
      <td width="280">15187.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_throughput</td>
      <td width="280">857.1938</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_qps</td>
      <td width="280">109720.8064</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 102400B attachment

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
      <td width="500">attachment_102400B_avg_latency</td>
      <td width="280">27681.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p90_latency</td>
      <td width="280">34416.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p99_latency</td>
      <td width="280">41582.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p999_latency</td>
      <td width="280">49543.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_throughput</td>
      <td width="280">1096.106</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_qps</td>
      <td width="280">11224.12544</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 204800B attachment

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
      <td width="500">attachment_204800B_avg_latency</td>
      <td width="280">29656.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p90_latency</td>
      <td width="280">36808.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p99_latency</td>
      <td width="280">44800.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p999_latency</td>
      <td width="280">52953.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_throughput</td>
      <td width="280">1080.462</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_qps</td>
      <td width="280">5531.96544</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 1048576B attachment

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
      <td width="500">attachment_1048576B_avg_latency</td>
      <td width="280">22744.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p90_latency</td>
      <td width="280">25937.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p99_latency</td>
      <td width="280">30239.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p999_latency</td>
      <td width="280">32768.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_throughput</td>
      <td width="280">1362.0359999999998</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_qps</td>
      <td width="280">1362.0359999999998</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 8388608B attachment

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
      <td width="500">attachment_8388608B_avg_latency</td>
      <td width="280">26876.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p90_latency</td>
      <td width="280">42894.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p99_latency</td>
      <td width="280">66896.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p999_latency</td>
      <td width="280">81952.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_throughput</td>
      <td width="280">1143.8152000000002</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_qps</td>
      <td width="280">142.97690000000003</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### brpc 1.17.0

##### 0B attachment

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
      <td width="500">attachment_0B_avg_latency</td>
      <td width="280">2211.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p90_latency</td>
      <td width="280">2427.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p99_latency</td>
      <td width="280">2586.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p999_latency</td>
      <td width="280">2677.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_throughput</td>
      <td width="280">0.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_qps</td>
      <td width="280">494000.0</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 1024B attachment

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
      <td width="500">attachment_1024B_avg_latency</td>
      <td width="280">3018.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p90_latency</td>
      <td width="280">3198.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p99_latency</td>
      <td width="280">3358.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p999_latency</td>
      <td width="280">4124.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_throughput</td>
      <td width="280">331.1928</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_qps</td>
      <td width="280">339141.4272</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 4096B attachment

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
      <td width="500">attachment_4096B_avg_latency</td>
      <td width="280">4777.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p90_latency</td>
      <td width="280">5146.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p99_latency</td>
      <td width="280">5321.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p999_latency</td>
      <td width="280">5670.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_throughput</td>
      <td width="280">844.0514000000001</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_qps</td>
      <td width="280">216077.15840000001</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 8192B attachment

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
      <td width="500">attachment_8192B_avg_latency</td>
      <td width="280">6021.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p90_latency</td>
      <td width="280">6853.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p99_latency</td>
      <td width="280">7144.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p999_latency</td>
      <td width="280">7708.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_throughput</td>
      <td width="280">1309.17</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_qps</td>
      <td width="280">167573.76</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 102400B attachment

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
      <td width="500">attachment_102400B_avg_latency</td>
      <td width="280">16388.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p90_latency</td>
      <td width="280">18435.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p99_latency</td>
      <td width="280">18711.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p999_latency</td>
      <td width="280">19161.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_throughput</td>
      <td width="280">1954.898</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_qps</td>
      <td width="280">20018.15552</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 204800B attachment

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
      <td width="500">attachment_204800B_avg_latency</td>
      <td width="280">16663.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p90_latency</td>
      <td width="280">18843.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p99_latency</td>
      <td width="280">19617.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p999_latency</td>
      <td width="280">19925.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_throughput</td>
      <td width="280">1835.768</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_qps</td>
      <td width="280">9399.132160000001</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 1048576B attachment

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
      <td width="500">attachment_1048576B_avg_latency</td>
      <td width="280">15634.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p90_latency</td>
      <td width="280">16882.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p99_latency</td>
      <td width="280">17885.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p999_latency</td>
      <td width="280">19808.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_throughput</td>
      <td width="280">2029.7920000000001</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_qps</td>
      <td width="280">2029.7920000000001</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 8388608B attachment

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
      <td width="500">attachment_8388608B_avg_latency</td>
      <td width="280">16161.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p90_latency</td>
      <td width="280">19592.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p99_latency</td>
      <td width="280">24868.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p999_latency</td>
      <td width="280">31769.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_throughput</td>
      <td width="280">1904.9779999999998</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_qps</td>
      <td width="280">238.12224999999998</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### brpc 1.17.0

#### 0B attachment

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
      <td width="400">attachment_0B_avg_latency</td>
      <td width="200">越小越好</td>
      <td width="200">1970.0</td>
      <td width="200">2211.0</td>
      <td width="380">0.891</td>
    </tr>
    <tr>
      <td width="400">attachment_0B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">2219.4</td>
      <td width="200">2427.8</td>
      <td width="380">0.9142</td>
    </tr>
    <tr>
      <td width="400">attachment_0B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">2648.2</td>
      <td width="200">2586.0</td>
      <td width="380">1.0241</td>
    </tr>
    <tr>
      <td width="400">attachment_0B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">3281.0</td>
      <td width="200">2677.0</td>
      <td width="380">1.2256</td>
    </tr>
    <tr>
      <td width="400">attachment_0B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">0.0</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">attachment_0B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">534200.0</td>
      <td width="200">494000.0</td>
      <td width="380">0.9247</td>
    </tr>
  </tbody>
</table>

#### 1024B attachment

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
      <td width="400">attachment_1024B_avg_latency</td>
      <td width="200">越小越好</td>
      <td width="200">5169.8</td>
      <td width="200">3018.4</td>
      <td width="380">1.7128</td>
    </tr>
    <tr>
      <td width="400">attachment_1024B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">6801.2</td>
      <td width="200">3198.4</td>
      <td width="380">2.1264</td>
    </tr>
    <tr>
      <td width="400">attachment_1024B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">8852.4</td>
      <td width="200">3358.8</td>
      <td width="380">2.6356</td>
    </tr>
    <tr>
      <td width="400">attachment_1024B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">12484.8</td>
      <td width="200">4124.2</td>
      <td width="380">3.0272</td>
    </tr>
    <tr>
      <td width="400">attachment_1024B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">214.7386</td>
      <td width="200">331.1928</td>
      <td width="380">1.5423</td>
    </tr>
    <tr>
      <td width="400">attachment_1024B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">219892.3264</td>
      <td width="200">339141.4272</td>
      <td width="380">1.5423</td>
    </tr>
  </tbody>
</table>

#### 4096B attachment

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
      <td width="400">attachment_4096B_avg_latency</td>
      <td width="200">越小越好</td>
      <td width="200">6370.4</td>
      <td width="200">4777.0</td>
      <td width="380">1.3336</td>
    </tr>
    <tr>
      <td width="400">attachment_4096B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">7271.6</td>
      <td width="200">5146.0</td>
      <td width="380">1.4131</td>
    </tr>
    <tr>
      <td width="400">attachment_4096B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">9004.8</td>
      <td width="200">5321.0</td>
      <td width="380">1.6923</td>
    </tr>
    <tr>
      <td width="400">attachment_4096B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">10260.2</td>
      <td width="200">5670.4</td>
      <td width="380">1.8094</td>
    </tr>
    <tr>
      <td width="400">attachment_4096B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">638.5572</td>
      <td width="200">844.0514000000001</td>
      <td width="380">1.3218</td>
    </tr>
    <tr>
      <td width="400">attachment_4096B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">163470.6432</td>
      <td width="200">216077.15840000001</td>
      <td width="380">1.3218</td>
    </tr>
  </tbody>
</table>

#### 8192B attachment

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
      <td width="400">attachment_8192B_avg_latency</td>
      <td width="200">越小越好</td>
      <td width="200">9557.2</td>
      <td width="200">6021.6</td>
      <td width="380">1.5872</td>
    </tr>
    <tr>
      <td width="400">attachment_8192B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">11188.2</td>
      <td width="200">6853.0</td>
      <td width="380">1.6326</td>
    </tr>
    <tr>
      <td width="400">attachment_8192B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">13777.8</td>
      <td width="200">7144.2</td>
      <td width="380">1.9285</td>
    </tr>
    <tr>
      <td width="400">attachment_8192B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">15187.2</td>
      <td width="200">7708.4</td>
      <td width="380">1.9702</td>
    </tr>
    <tr>
      <td width="400">attachment_8192B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">857.1938</td>
      <td width="200">1309.17</td>
      <td width="380">1.5273</td>
    </tr>
    <tr>
      <td width="400">attachment_8192B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">109720.8064</td>
      <td width="200">167573.76</td>
      <td width="380">1.5273</td>
    </tr>
  </tbody>
</table>

#### 102400B attachment

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
      <td width="400">attachment_102400B_avg_latency</td>
      <td width="200">越小越好</td>
      <td width="200">27681.6</td>
      <td width="200">16388.2</td>
      <td width="380">1.6891</td>
    </tr>
    <tr>
      <td width="400">attachment_102400B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">34416.8</td>
      <td width="200">18435.6</td>
      <td width="380">1.8669</td>
    </tr>
    <tr>
      <td width="400">attachment_102400B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">41582.8</td>
      <td width="200">18711.2</td>
      <td width="380">2.2223</td>
    </tr>
    <tr>
      <td width="400">attachment_102400B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">49543.0</td>
      <td width="200">19161.2</td>
      <td width="380">2.5856</td>
    </tr>
    <tr>
      <td width="400">attachment_102400B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1096.106</td>
      <td width="200">1954.898</td>
      <td width="380">1.7835</td>
    </tr>
    <tr>
      <td width="400">attachment_102400B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">11224.12544</td>
      <td width="200">20018.15552</td>
      <td width="380">1.7835</td>
    </tr>
  </tbody>
</table>

#### 204800B attachment

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
      <td width="400">attachment_204800B_avg_latency</td>
      <td width="200">越小越好</td>
      <td width="200">29656.6</td>
      <td width="200">16663.2</td>
      <td width="380">1.7798</td>
    </tr>
    <tr>
      <td width="400">attachment_204800B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">36808.2</td>
      <td width="200">18843.2</td>
      <td width="380">1.9534</td>
    </tr>
    <tr>
      <td width="400">attachment_204800B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">44800.6</td>
      <td width="200">19617.8</td>
      <td width="380">2.2837</td>
    </tr>
    <tr>
      <td width="400">attachment_204800B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">52953.4</td>
      <td width="200">19925.8</td>
      <td width="380">2.6575</td>
    </tr>
    <tr>
      <td width="400">attachment_204800B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1080.462</td>
      <td width="200">1835.768</td>
      <td width="380">1.6991</td>
    </tr>
    <tr>
      <td width="400">attachment_204800B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">5531.96544</td>
      <td width="200">9399.132160000001</td>
      <td width="380">1.6991</td>
    </tr>
  </tbody>
</table>

#### 1048576B attachment

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
      <td width="400">attachment_1048576B_avg_latency</td>
      <td width="200">越小越好</td>
      <td width="200">22744.4</td>
      <td width="200">15634.4</td>
      <td width="380">1.4548</td>
    </tr>
    <tr>
      <td width="400">attachment_1048576B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">25937.2</td>
      <td width="200">16882.0</td>
      <td width="380">1.5364</td>
    </tr>
    <tr>
      <td width="400">attachment_1048576B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">30239.6</td>
      <td width="200">17885.4</td>
      <td width="380">1.6907</td>
    </tr>
    <tr>
      <td width="400">attachment_1048576B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">32768.0</td>
      <td width="200">19808.2</td>
      <td width="380">1.6543</td>
    </tr>
    <tr>
      <td width="400">attachment_1048576B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1362.0359999999998</td>
      <td width="200">2029.7920000000001</td>
      <td width="380">1.4903</td>
    </tr>
    <tr>
      <td width="400">attachment_1048576B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">1362.0359999999998</td>
      <td width="200">2029.7920000000001</td>
      <td width="380">1.4903</td>
    </tr>
  </tbody>
</table>

#### 8388608B attachment

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
      <td width="400">attachment_8388608B_avg_latency</td>
      <td width="200">越小越好</td>
      <td width="200">26876.8</td>
      <td width="200">16161.2</td>
      <td width="380">1.663</td>
    </tr>
    <tr>
      <td width="400">attachment_8388608B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">42894.8</td>
      <td width="200">19592.0</td>
      <td width="380">2.1894</td>
    </tr>
    <tr>
      <td width="400">attachment_8388608B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">66896.0</td>
      <td width="200">24868.4</td>
      <td width="380">2.69</td>
    </tr>
    <tr>
      <td width="400">attachment_8388608B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">81952.4</td>
      <td width="200">31769.2</td>
      <td width="380">2.5796</td>
    </tr>
    <tr>
      <td width="400">attachment_8388608B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1143.8152000000002</td>
      <td width="200">1904.9779999999998</td>
      <td width="380">1.6655</td>
    </tr>
    <tr>
      <td width="400">attachment_8388608B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">142.97690000000003</td>
      <td width="200">238.12224999999998</td>
      <td width="380">1.6655</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
