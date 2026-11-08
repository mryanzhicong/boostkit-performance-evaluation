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
      <td width="220">gmp</td>
      <td width="160">6.3.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">gmp</td>
      <td width="160">6.3.0</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### gmp 6.3.0

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
      <td width="600">6.3.0</td>
      <td width="600">6.3.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">6.3.0</td>
      <td width="600">6.3.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-08T19:13:27Z</td>
      <td width="600">2026-11-08T19:14:05Z</td>
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
      <td width="600">2026-11-08T19:12:31Z</td>
      <td width="600">2026-11-08T19:12:31Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 61912 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 140501 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 168030 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 166183 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 134610 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 159720 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169268 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 163802 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 363656 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 377701 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 343680 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 349363 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">gmp-tune-speed</td>
      <td width="880">6.3.0 upstream tune/speed benchmark</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### gmp 6.3.0

##### mpn_mul_n_512

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
      <td width="500">mpn_mul_n_512.ops_per_second</td>
      <td width="280">33749.578130273</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_512.ns_per_op</td>
      <td width="280">29630.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_512.wall_seconds</td>
      <td width="280">0.031691</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_512.peak_rss_mib</td>
      <td width="280">12.578</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_mul_n_2048

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
      <td width="500">mpn_mul_n_2048.ops_per_second</td>
      <td width="280">4772.586264497</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_2048.ns_per_op</td>
      <td width="280">209530.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_2048.wall_seconds</td>
      <td width="280">0.03167</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_2048.peak_rss_mib</td>
      <td width="280">12.566</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_mul_n_8192

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
      <td width="500">mpn_mul_n_8192.ops_per_second</td>
      <td width="280">839.531877025</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_8192.ns_per_op</td>
      <td width="280">1191140.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_8192.wall_seconds</td>
      <td width="280">0.063765</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_8192.peak_rss_mib</td>
      <td width="280">12.523</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_sqr_4096

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
      <td width="500">mpn_sqr_4096.ops_per_second</td>
      <td width="280">3294.241665569</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_sqr_4096.ns_per_op</td>
      <td width="280">303560.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_sqr_4096.wall_seconds</td>
      <td width="280">0.063825</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_sqr_4096.peak_rss_mib</td>
      <td width="280">12.578</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_add_n_8192

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
      <td width="500">mpn_add_n_8192.ops_per_second</td>
      <td width="280">366300.366300366</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_add_n_8192.ns_per_op</td>
      <td width="280">2730.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_add_n_8192.wall_seconds</td>
      <td width="280">0.031675</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_add_n_8192.peak_rss_mib</td>
      <td width="280">12.469</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_div_qr_2n_2048

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
      <td width="500">mpn_div_qr_2n_2048.ops_per_second</td>
      <td width="280">129032.258064516</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_2048.ns_per_op</td>
      <td width="280">7750.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_2048.wall_seconds</td>
      <td width="280">0.031648</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_2048.peak_rss_mib</td>
      <td width="280">12.609</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_div_qr_2n_8192

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
      <td width="500">mpn_div_qr_2n_8192.ops_per_second</td>
      <td width="280">32467.532467532</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_8192.ns_per_op</td>
      <td width="280">30800.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_8192.wall_seconds</td>
      <td width="280">0.031651</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_8192.peak_rss_mib</td>
      <td width="280">12.566</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpz_add_2048

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
      <td width="500">mpz_add_2048.ops_per_second</td>
      <td width="280">1146788.990825688</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_2048.ns_per_op</td>
      <td width="280">872.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_2048.wall_seconds</td>
      <td width="280">0.031699</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_2048.peak_rss_mib</td>
      <td width="280">12.551</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpz_add_8192

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
      <td width="500">mpz_add_8192.ops_per_second</td>
      <td width="280">322061.191626409</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_8192.ns_per_op</td>
      <td width="280">3105.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_8192.wall_seconds</td>
      <td width="280">0.031666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_8192.peak_rss_mib</td>
      <td width="280">12.562</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### gmp 6.3.0

##### mpn_mul_n_512

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
      <td width="500">mpn_mul_n_512.ops_per_second</td>
      <td width="280">19102.196752627</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_512.ns_per_op</td>
      <td width="280">52350.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_512.wall_seconds</td>
      <td width="280">0.008193</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_512.peak_rss_mib</td>
      <td width="280">11.75</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_mul_n_2048

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
      <td width="500">mpn_mul_n_2048.ops_per_second</td>
      <td width="280">2666.737779674</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_2048.ns_per_op</td>
      <td width="280">374990.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_2048.wall_seconds</td>
      <td width="280">0.016132</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_2048.peak_rss_mib</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_mul_n_8192

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
      <td width="500">mpn_mul_n_8192.ops_per_second</td>
      <td width="280">530.346422283</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_8192.ns_per_op</td>
      <td width="280">1885560.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_8192.wall_seconds</td>
      <td width="280">0.032208</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_mul_n_8192.peak_rss_mib</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_sqr_4096

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
      <td width="500">mpn_sqr_4096.ops_per_second</td>
      <td width="280">1869.822927769</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_sqr_4096.ns_per_op</td>
      <td width="280">534810.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_sqr_4096.wall_seconds</td>
      <td width="280">0.016137</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_sqr_4096.peak_rss_mib</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_add_n_8192

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
      <td width="500">mpn_add_n_8192.ops_per_second</td>
      <td width="280">265745.415891576</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_add_n_8192.ns_per_op</td>
      <td width="280">3763.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_add_n_8192.wall_seconds</td>
      <td width="280">0.01588</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_add_n_8192.peak_rss_mib</td>
      <td width="280">11.754</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_div_qr_2n_2048

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
      <td width="500">mpn_div_qr_2n_2048.ops_per_second</td>
      <td width="280">68493.150684932</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_2048.ns_per_op</td>
      <td width="280">14600.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_2048.wall_seconds</td>
      <td width="280">0.008085</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_2048.peak_rss_mib</td>
      <td width="280">11.762</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpn_div_qr_2n_8192

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
      <td width="500">mpn_div_qr_2n_8192.ops_per_second</td>
      <td width="280">17418.568193694</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_8192.ns_per_op</td>
      <td width="280">57410.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_8192.wall_seconds</td>
      <td width="280">0.016088</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpn_div_qr_2n_8192.peak_rss_mib</td>
      <td width="280">11.762</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpz_add_2048

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
      <td width="500">mpz_add_2048.ops_per_second</td>
      <td width="280">1070663.811563169</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_2048.ns_per_op</td>
      <td width="280">934.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_2048.wall_seconds</td>
      <td width="280">0.008064</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_2048.peak_rss_mib</td>
      <td width="280">11.75</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpz_add_8192

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
      <td width="500">mpz_add_8192.ops_per_second</td>
      <td width="280">263643.553915107</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_8192.ns_per_op</td>
      <td width="280">3793.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_8192.wall_seconds</td>
      <td width="280">0.015964</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpz_add_8192.peak_rss_mib</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### gmp 6.3.0

#### mpn_mul_n_512

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
      <td width="400">mpn_mul_n_512.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">33749.578130273</td>
      <td width="200">19102.196752627</td>
      <td width="380">0.566</td>
    </tr>
    <tr>
      <td width="400">mpn_mul_n_512.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">29630.0</td>
      <td width="200">52350.0</td>
      <td width="380">0.566</td>
    </tr>
    <tr>
      <td width="400">mpn_mul_n_512.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.031691</td>
      <td width="200">0.008193</td>
      <td width="380">3.8681</td>
    </tr>
    <tr>
      <td width="400">mpn_mul_n_512.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.578</td>
      <td width="200">11.75</td>
      <td width="380">1.0705</td>
    </tr>
  </tbody>
</table>

#### mpn_mul_n_2048

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
      <td width="400">mpn_mul_n_2048.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">4772.586264497</td>
      <td width="200">2666.737779674</td>
      <td width="380">0.5588</td>
    </tr>
    <tr>
      <td width="400">mpn_mul_n_2048.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">209530.0</td>
      <td width="200">374990.0</td>
      <td width="380">0.5588</td>
    </tr>
    <tr>
      <td width="400">mpn_mul_n_2048.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.03167</td>
      <td width="200">0.016132</td>
      <td width="380">1.9632</td>
    </tr>
    <tr>
      <td width="400">mpn_mul_n_2048.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.566</td>
      <td width="200">11.758</td>
      <td width="380">1.0687</td>
    </tr>
  </tbody>
</table>

#### mpn_mul_n_8192

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
      <td width="400">mpn_mul_n_8192.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">839.531877025</td>
      <td width="200">530.346422283</td>
      <td width="380">0.6317</td>
    </tr>
    <tr>
      <td width="400">mpn_mul_n_8192.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">1191140.0</td>
      <td width="200">1885560.0</td>
      <td width="380">0.6317</td>
    </tr>
    <tr>
      <td width="400">mpn_mul_n_8192.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.063765</td>
      <td width="200">0.032208</td>
      <td width="380">1.9798</td>
    </tr>
    <tr>
      <td width="400">mpn_mul_n_8192.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.523</td>
      <td width="200">11.758</td>
      <td width="380">1.0651</td>
    </tr>
  </tbody>
</table>

#### mpn_sqr_4096

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
      <td width="400">mpn_sqr_4096.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">3294.241665569</td>
      <td width="200">1869.822927769</td>
      <td width="380">0.5676</td>
    </tr>
    <tr>
      <td width="400">mpn_sqr_4096.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">303560.0</td>
      <td width="200">534810.0</td>
      <td width="380">0.5676</td>
    </tr>
    <tr>
      <td width="400">mpn_sqr_4096.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.063825</td>
      <td width="200">0.016137</td>
      <td width="380">3.9552</td>
    </tr>
    <tr>
      <td width="400">mpn_sqr_4096.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.578</td>
      <td width="200">11.758</td>
      <td width="380">1.0697</td>
    </tr>
  </tbody>
</table>

#### mpn_add_n_8192

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
      <td width="400">mpn_add_n_8192.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">366300.366300366</td>
      <td width="200">265745.415891576</td>
      <td width="380">0.7255</td>
    </tr>
    <tr>
      <td width="400">mpn_add_n_8192.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">2730.0</td>
      <td width="200">3763.0</td>
      <td width="380">0.7255</td>
    </tr>
    <tr>
      <td width="400">mpn_add_n_8192.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.031675</td>
      <td width="200">0.01588</td>
      <td width="380">1.9946</td>
    </tr>
    <tr>
      <td width="400">mpn_add_n_8192.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.469</td>
      <td width="200">11.754</td>
      <td width="380">1.0608</td>
    </tr>
  </tbody>
</table>

#### mpn_div_qr_2n_2048

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
      <td width="400">mpn_div_qr_2n_2048.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">129032.258064516</td>
      <td width="200">68493.150684932</td>
      <td width="380">0.5308</td>
    </tr>
    <tr>
      <td width="400">mpn_div_qr_2n_2048.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">7750.0</td>
      <td width="200">14600.0</td>
      <td width="380">0.5308</td>
    </tr>
    <tr>
      <td width="400">mpn_div_qr_2n_2048.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.031648</td>
      <td width="200">0.008085</td>
      <td width="380">3.9144</td>
    </tr>
    <tr>
      <td width="400">mpn_div_qr_2n_2048.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.609</td>
      <td width="200">11.762</td>
      <td width="380">1.072</td>
    </tr>
  </tbody>
</table>

#### mpn_div_qr_2n_8192

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
      <td width="400">mpn_div_qr_2n_8192.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">32467.532467532</td>
      <td width="200">17418.568193694</td>
      <td width="380">0.5365</td>
    </tr>
    <tr>
      <td width="400">mpn_div_qr_2n_8192.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">30800.0</td>
      <td width="200">57410.0</td>
      <td width="380">0.5365</td>
    </tr>
    <tr>
      <td width="400">mpn_div_qr_2n_8192.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.031651</td>
      <td width="200">0.016088</td>
      <td width="380">1.9674</td>
    </tr>
    <tr>
      <td width="400">mpn_div_qr_2n_8192.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.566</td>
      <td width="200">11.762</td>
      <td width="380">1.0684</td>
    </tr>
  </tbody>
</table>

#### mpz_add_2048

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
      <td width="400">mpz_add_2048.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">1146788.990825688</td>
      <td width="200">1070663.811563169</td>
      <td width="380">0.9336</td>
    </tr>
    <tr>
      <td width="400">mpz_add_2048.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">872.0</td>
      <td width="200">934.0</td>
      <td width="380">0.9336</td>
    </tr>
    <tr>
      <td width="400">mpz_add_2048.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.031699</td>
      <td width="200">0.008064</td>
      <td width="380">3.9309</td>
    </tr>
    <tr>
      <td width="400">mpz_add_2048.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.551</td>
      <td width="200">11.75</td>
      <td width="380">1.0682</td>
    </tr>
  </tbody>
</table>

#### mpz_add_8192

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
      <td width="400">mpz_add_8192.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">322061.191626409</td>
      <td width="200">263643.553915107</td>
      <td width="380">0.8186</td>
    </tr>
    <tr>
      <td width="400">mpz_add_8192.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">3105.0</td>
      <td width="200">3793.0</td>
      <td width="380">0.8186</td>
    </tr>
    <tr>
      <td width="400">mpz_add_8192.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.031666</td>
      <td width="200">0.015964</td>
      <td width="380">1.9836</td>
    </tr>
    <tr>
      <td width="400">mpz_add_8192.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.562</td>
      <td width="200">11.758</td>
      <td width="380">1.0684</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
