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
      <td width="180">Acceleration</td>
      <td width="220">spdk</td>
      <td width="160">26.09</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Acceleration</td>
      <td width="220">spdk</td>
      <td width="160">26.09</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### spdk 26.09

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
      <td width="600">26.09</td>
      <td width="600">26.09</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">26.09</td>
      <td width="600">26.09</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-05T07:21:02Z</td>
      <td width="600">2026-11-05T07:10:50Z</td>
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
      <td width="600">2026-11-05T07:17:09Z</td>
      <td width="600">2026-11-05T07:04:11Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">AMD EPYC 9654 96-Core Processor</td>
      <td width="600">Kunpeng 950 7592C To Be Filled By O.E.M. CPU @ 2.3GHz</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">384</td>
      <td width="600">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0</td>
      <td width="600">6.6.0-132.0.0.111.oe2403sp3.aarch64</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 126915 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 168503 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 170014 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 162429 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 151196 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 157375 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169359 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 165294 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 379899 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 385404 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 382981 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 384705 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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

## 单架构指标

### x86_64

#### spdk 26.09

##### randread_bs4k_qd1_single

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
      <td width="280">2297899.7</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd1_single / MiB/s</td>
      <td width="280">8976.17</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd1_single / avg_latency_us</td>
      <td width="280">0.36</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd1_single / p99_latency_us</td>
      <td width="280">0.392</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd1_single / peak_rss_mib</td>
      <td width="280">417.004</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### randread_bs4k_qd32_single

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
      <td width="280">2403822.29</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_single / MiB/s</td>
      <td width="280">9389.93</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_single / avg_latency_us</td>
      <td width="280">13.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_single / p99_latency_us</td>
      <td width="280">9.067</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_single / peak_rss_mib</td>
      <td width="280">420.066</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### randread_bs4k_qd128_single

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
      <td width="280">2269572.72</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd128_single / MiB/s</td>
      <td width="280">8865.52</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd128_single / avg_latency_us</td>
      <td width="280">56.33</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd128_single / p99_latency_us</td>
      <td width="280">47.787</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd128_single / peak_rss_mib</td>
      <td width="280">419.934</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### randwrite_bs4k_qd32_single

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
      <td width="280">2630328.64</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randwrite_bs4k_qd32_single / MiB/s</td>
      <td width="280">10274.72</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randwrite_bs4k_qd32_single / avg_latency_us</td>
      <td width="280">12.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randwrite_bs4k_qd32_single / p99_latency_us</td>
      <td width="280">8.533</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randwrite_bs4k_qd32_single / peak_rss_mib</td>
      <td width="280">420.07</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### randrw_bs4k_qd32_single

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
      <td width="280">2438737.31</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randrw_bs4k_qd32_single / MiB/s</td>
      <td width="280">9526.32</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randrw_bs4k_qd32_single / avg_latency_us</td>
      <td width="280">13.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randrw_bs4k_qd32_single / p99_latency_us</td>
      <td width="280">9.173</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randrw_bs4k_qd32_single / peak_rss_mib</td>
      <td width="280">420.023</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### randread_bs64k_qd32_single

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
      <td width="280">342144.58</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs64k_qd32_single / MiB/s</td>
      <td width="280">21384.04</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs64k_qd32_single / avg_latency_us</td>
      <td width="280">93.42</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs64k_qd32_single / p99_latency_us</td>
      <td width="280">1126.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs64k_qd32_single / peak_rss_mib</td>
      <td width="280">419.895</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### randread_bs128k_qd32_single

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
      <td width="280">180085.49</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs128k_qd32_single / MiB/s</td>
      <td width="280">22510.69</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs128k_qd32_single / avg_latency_us</td>
      <td width="280">177.55</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs128k_qd32_single / p99_latency_us</td>
      <td width="280">4150.613</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs128k_qd32_single / peak_rss_mib</td>
      <td width="280">422.945</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### randread_bs4k_qd32_multi4

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
      <td width="280">9536442.61</td>
      <td width="200">IOPS</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_multi4 / MiB/s</td>
      <td width="280">37251.73</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_multi4 / avg_latency_us</td>
      <td width="280">13.37</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_multi4 / p99_latency_us</td>
      <td width="280">22.933</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">randread_bs4k_qd32_multi4 / peak_rss_mib</td>
      <td width="280">476.922</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### spdk 26.09

##### randread_bs4k_qd1_single

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

##### randread_bs4k_qd32_single

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

##### randread_bs4k_qd128_single

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

##### randwrite_bs4k_qd32_single

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

##### randrw_bs4k_qd32_single

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

##### randread_bs64k_qd32_single

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

##### randread_bs128k_qd32_single

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

##### randread_bs4k_qd32_multi4

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

## 跨架构指标

### spdk 26.09

#### randread_bs4k_qd1_single

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
      <td width="400">randread_bs4k_qd1_single / IOPS</td>
      <td width="200">越大越好</td>
      <td width="200">2297899.7</td>
      <td width="200">2870193.1</td>
      <td width="380">1.2491</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd1_single / MiB/s</td>
      <td width="200">越大越好</td>
      <td width="200">8976.17</td>
      <td width="200">11211.69</td>
      <td width="380">1.2491</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd1_single / avg_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">0.36</td>
      <td width="200">0.29</td>
      <td width="380">1.2414</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd1_single / p99_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">0.392</td>
      <td width="200">0.41</td>
      <td width="380">0.9561</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd1_single / peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">417.004</td>
      <td width="200">467.93</td>
      <td width="380">0.8912</td>
    </tr>
  </tbody>
</table>

#### randread_bs4k_qd32_single

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
      <td width="400">randread_bs4k_qd32_single / IOPS</td>
      <td width="200">越大越好</td>
      <td width="200">2403822.29</td>
      <td width="200">3122717.97</td>
      <td width="380">1.2991</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd32_single / MiB/s</td>
      <td width="200">越大越好</td>
      <td width="200">9389.93</td>
      <td width="200">12198.12</td>
      <td width="380">1.2991</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd32_single / avg_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">13.24</td>
      <td width="200">10.19</td>
      <td width="380">1.2993</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd32_single / p99_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">9.067</td>
      <td width="200">10.8</td>
      <td width="380">0.8395</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd32_single / peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">420.066</td>
      <td width="200">467.945</td>
      <td width="380">0.8977</td>
    </tr>
  </tbody>
</table>

#### randread_bs4k_qd128_single

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
      <td width="400">randread_bs4k_qd128_single / IOPS</td>
      <td width="200">越大越好</td>
      <td width="200">2269572.72</td>
      <td width="200">2989866.72</td>
      <td width="380">1.3174</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd128_single / MiB/s</td>
      <td width="200">越大越好</td>
      <td width="200">8865.52</td>
      <td width="200">11679.17</td>
      <td width="380">1.3174</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd128_single / avg_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">56.33</td>
      <td width="200">42.75</td>
      <td width="380">1.3177</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd128_single / p99_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">47.787</td>
      <td width="200">50.24</td>
      <td width="380">0.9512</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd128_single / peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">419.934</td>
      <td width="200">467.957</td>
      <td width="380">0.8974</td>
    </tr>
  </tbody>
</table>

#### randwrite_bs4k_qd32_single

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
      <td width="400">randwrite_bs4k_qd32_single / IOPS</td>
      <td width="200">越大越好</td>
      <td width="200">2630328.64</td>
      <td width="200">4097864.08</td>
      <td width="380">1.5579</td>
    </tr>
    <tr>
      <td width="400">randwrite_bs4k_qd32_single / MiB/s</td>
      <td width="200">越大越好</td>
      <td width="200">10274.72</td>
      <td width="200">16007.28</td>
      <td width="380">1.5579</td>
    </tr>
    <tr>
      <td width="400">randwrite_bs4k_qd32_single / avg_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">12.09</td>
      <td width="200">7.75</td>
      <td width="380">1.56</td>
    </tr>
    <tr>
      <td width="400">randwrite_bs4k_qd32_single / p99_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">8.533</td>
      <td width="200">8.32</td>
      <td width="380">1.0256</td>
    </tr>
    <tr>
      <td width="400">randwrite_bs4k_qd32_single / peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">420.07</td>
      <td width="200">467.938</td>
      <td width="380">0.8977</td>
    </tr>
  </tbody>
</table>

#### randrw_bs4k_qd32_single

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
      <td width="400">randrw_bs4k_qd32_single / IOPS</td>
      <td width="200">越大越好</td>
      <td width="200">2438737.31</td>
      <td width="200">2884416.79</td>
      <td width="380">1.1828</td>
    </tr>
    <tr>
      <td width="400">randrw_bs4k_qd32_single / MiB/s</td>
      <td width="200">越大越好</td>
      <td width="200">9526.32</td>
      <td width="200">11267.25</td>
      <td width="380">1.1827</td>
    </tr>
    <tr>
      <td width="400">randrw_bs4k_qd32_single / avg_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">13.04</td>
      <td width="200">11.03</td>
      <td width="380">1.1822</td>
    </tr>
    <tr>
      <td width="400">randrw_bs4k_qd32_single / p99_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">9.173</td>
      <td width="200">12.72</td>
      <td width="380">0.7211</td>
    </tr>
    <tr>
      <td width="400">randrw_bs4k_qd32_single / peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">420.023</td>
      <td width="200">467.957</td>
      <td width="380">0.8976</td>
    </tr>
  </tbody>
</table>

#### randread_bs64k_qd32_single

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
      <td width="400">randread_bs64k_qd32_single / IOPS</td>
      <td width="200">越大越好</td>
      <td width="200">342144.58</td>
      <td width="200">361337.83</td>
      <td width="380">1.0561</td>
    </tr>
    <tr>
      <td width="400">randread_bs64k_qd32_single / MiB/s</td>
      <td width="200">越大越好</td>
      <td width="200">21384.04</td>
      <td width="200">22583.61</td>
      <td width="380">1.0561</td>
    </tr>
    <tr>
      <td width="400">randread_bs64k_qd32_single / avg_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">93.42</td>
      <td width="200">88.45</td>
      <td width="380">1.0562</td>
    </tr>
    <tr>
      <td width="400">randread_bs64k_qd32_single / p99_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">1126.4</td>
      <td width="200">100.48</td>
      <td width="380">11.2102</td>
    </tr>
    <tr>
      <td width="400">randread_bs64k_qd32_single / peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">419.895</td>
      <td width="200">467.957</td>
      <td width="380">0.8973</td>
    </tr>
  </tbody>
</table>

#### randread_bs128k_qd32_single

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
      <td width="400">randread_bs128k_qd32_single / IOPS</td>
      <td width="200">越大越好</td>
      <td width="200">180085.49</td>
      <td width="200">190376.84</td>
      <td width="380">1.0571</td>
    </tr>
    <tr>
      <td width="400">randread_bs128k_qd32_single / MiB/s</td>
      <td width="200">越大越好</td>
      <td width="200">22510.69</td>
      <td width="200">23797.11</td>
      <td width="380">1.0571</td>
    </tr>
    <tr>
      <td width="400">randread_bs128k_qd32_single / avg_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">177.55</td>
      <td width="200">167.95</td>
      <td width="380">1.0572</td>
    </tr>
    <tr>
      <td width="400">randread_bs128k_qd32_single / p99_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">4150.613</td>
      <td width="200">183.04</td>
      <td width="380">22.676</td>
    </tr>
    <tr>
      <td width="400">randread_bs128k_qd32_single / peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">422.945</td>
      <td width="200">467.926</td>
      <td width="380">0.9039</td>
    </tr>
  </tbody>
</table>

#### randread_bs4k_qd32_multi4

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
      <td width="400">randread_bs4k_qd32_multi4 / IOPS</td>
      <td width="200">越大越好</td>
      <td width="200">9536442.61</td>
      <td width="200">6398754.25</td>
      <td width="380">0.671</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd32_multi4 / MiB/s</td>
      <td width="200">越大越好</td>
      <td width="200">37251.73</td>
      <td width="200">24995.13</td>
      <td width="380">0.671</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd32_multi4 / avg_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">13.37</td>
      <td width="200">19.9</td>
      <td width="380">0.6719</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd32_multi4 / p99_latency_us</td>
      <td width="200">越小越好</td>
      <td width="200">22.933</td>
      <td width="200">22.24</td>
      <td width="380">1.0312</td>
    </tr>
    <tr>
      <td width="400">randread_bs4k_qd32_multi4 / peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">476.922</td>
      <td width="200">525.0</td>
      <td width="380">0.9084</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
