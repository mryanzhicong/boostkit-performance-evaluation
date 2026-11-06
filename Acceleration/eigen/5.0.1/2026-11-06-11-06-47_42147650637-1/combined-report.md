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
      <td width="220">eigen</td>
      <td width="160">5.0.1</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Acceleration</td>
      <td width="220">eigen</td>
      <td width="160">5.0.1</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### eigen 5.0.1

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
      <td width="600">5.0.1</td>
      <td width="600">5.0.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">5.0.1</td>
      <td width="600">5.0.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-06T03:05:02Z</td>
      <td width="600">2026-11-06T02:25:20Z</td>
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
      <td width="600">2026-11-06T03:04:18Z</td>
      <td width="600">2026-11-06T02:24:26Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 126273 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 164525 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 169181 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 156081 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 131430 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 156176 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 163466 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 164214 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 378545 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 383882 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 376745 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 350625 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">eigen_bench_gemm</td>
      <td width="880">5.0.1 (bench/bench_gemm.cpp that ships inside the pinned Eigen 5.0.1 release archive, compiled with -O3 -DNDEBUG -std=c++17 inside the private container)</td>
    </tr>
    <tr>
      <td width="500">system_cxx_compiler</td>
      <td width="880">unpinned Runner c++; the exact compiler string is recorded per run in build_info.json and results.json</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### eigen 5.0.1

##### gemm

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
      <td width="500">gemm_gflops_m14_k28_n16</td>
      <td width="280">21.3333</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m16_k8_n4</td>
      <td width="280">8.25806</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m19_k8_n4</td>
      <td width="280">8.21622</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m1_k16_n16</td>
      <td width="280">5.22449</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m1_k24_n16</td>
      <td width="280">7.31429</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m32_k16_n8</td>
      <td width="280">23.339</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m32_k32_n8</td>
      <td width="280">27.3067</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m32_k8_n4</td>
      <td width="280">12.3373</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m35_k400_n400</td>
      <td width="280">36.0864</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m35_k800_n1</td>
      <td width="280">19.519</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m39_k400_n400</td>
      <td width="280">34.8377</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m39_k492_n1</td>
      <td width="280">18.858</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m39_k5_n1</td>
      <td width="280">5.0</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m39_k800_n1</td>
      <td width="280">19.1235</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m4130_k104_n32</td>
      <td width="280">36.6431</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m4130_k116_n32</td>
      <td width="280">36.6666</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m4130_k16_n1</td>
      <td width="280">29.1808</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m4130_k32_n16</td>
      <td width="280">34.2569</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m46_k492_n1</td>
      <td width="280">21.9942</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m46_k5_n1</td>
      <td width="280">5.89744</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m48_k18_n16</td>
      <td width="280">29.9221</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m50_k100_n1</td>
      <td width="280">22.779</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m50_k1298_n250</td>
      <td width="280">36.792</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m50_k250_n100</td>
      <td width="280">37.1631</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m50_k250_n250</td>
      <td width="280">37.1065</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k128_n64</td>
      <td width="280">36.2301</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k1316_n2</td>
      <td width="280">9.29534</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k1316_n256</td>
      <td width="280">37.2551</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k1540_n64</td>
      <td width="280">36.2934</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k1570_n128</td>
      <td width="280">36.9408</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k1570_n256</td>
      <td width="280">37.2262</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k16_n8</td>
      <td width="280">23.8987</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k256_n128</td>
      <td width="280">37.3482</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k30_n16</td>
      <td width="280">30.305</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k32_n2</td>
      <td width="280">11.8</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k48_n48</td>
      <td width="280">34.7929</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k48_n80</td>
      <td width="280">35.4053</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k64_n1</td>
      <td width="280">19.5648</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k64_n2</td>
      <td width="280">11.9399</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k64_n32</td>
      <td width="280">34.4251</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k64_n6</td>
      <td width="280">21.8899</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k8_n1</td>
      <td width="280">9.73196</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m77_k20_n16</td>
      <td width="280">30.2331</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m80_k36_n16</td>
      <td width="280">33.9073</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### eigen 5.0.1

##### gemm

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
      <td width="500">gemm_gflops_m14_k28_n16</td>
      <td width="280">23.8933</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m16_k8_n4</td>
      <td width="280">6.69281</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m19_k8_n4</td>
      <td width="280">6.57297</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m1_k16_n16</td>
      <td width="280">6.16867</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m1_k24_n16</td>
      <td width="280">8.72727</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m32_k16_n8</td>
      <td width="280">22.8189</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m32_k32_n8</td>
      <td width="280">27.4899</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m32_k8_n4</td>
      <td width="280">10.3959</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m35_k400_n400</td>
      <td width="280">38.4101</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m35_k800_n1</td>
      <td width="280">18.4636</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m39_k400_n400</td>
      <td width="280">38.7267</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m39_k492_n1</td>
      <td width="280">17.0333</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m39_k5_n1</td>
      <td width="280">5.65217</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m39_k800_n1</td>
      <td width="280">17.6471</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m4130_k104_n32</td>
      <td width="280">41.1571</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m4130_k116_n32</td>
      <td width="280">41.3991</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m4130_k16_n1</td>
      <td width="280">20.5825</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m4130_k32_n16</td>
      <td width="280">36.0517</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m46_k492_n1</td>
      <td width="280">20.9847</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m46_k5_n1</td>
      <td width="280">6.76471</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m48_k18_n16</td>
      <td width="280">32.6038</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m50_k100_n1</td>
      <td width="280">23.4742</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m50_k1298_n250</td>
      <td width="280">43.035</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m50_k250_n100</td>
      <td width="280">43.3358</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m50_k250_n250</td>
      <td width="280">42.5225</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k128_n64</td>
      <td width="280">40.2505</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k1316_n2</td>
      <td width="280">9.51112</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k1316_n256</td>
      <td width="280">41.8389</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k1540_n64</td>
      <td width="280">39.9592</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k1570_n128</td>
      <td width="280">40.2163</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k1570_n256</td>
      <td width="280">41.7987</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k16_n8</td>
      <td width="280">22.1791</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k256_n128</td>
      <td width="280">42.4824</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k30_n16</td>
      <td width="280">31.9099</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k32_n2</td>
      <td width="280">9.54741</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k48_n48</td>
      <td width="280">39.2765</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k48_n80</td>
      <td width="280">40.7592</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k64_n1</td>
      <td width="280">19.4139</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k64_n2</td>
      <td width="280">9.97622</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k64_n32</td>
      <td width="280">38.7966</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k64_n6</td>
      <td width="280">21.4545</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m59_k8_n1</td>
      <td width="280">10.0426</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m77_k20_n16</td>
      <td width="280">32.6142</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gemm_gflops_m80_k36_n16</td>
      <td width="280">38.384</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### eigen 5.0.1

#### gemm

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
      <td width="400">gemm_gflops_m14_k28_n16</td>
      <td width="200">越大越好</td>
      <td width="200">21.3333</td>
      <td width="200">23.8933</td>
      <td width="380">1.12</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m16_k8_n4</td>
      <td width="200">越大越好</td>
      <td width="200">8.25806</td>
      <td width="200">6.69281</td>
      <td width="380">0.8105</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m19_k8_n4</td>
      <td width="200">越大越好</td>
      <td width="200">8.21622</td>
      <td width="200">6.57297</td>
      <td width="380">0.8</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m1_k16_n16</td>
      <td width="200">越大越好</td>
      <td width="200">5.22449</td>
      <td width="200">6.16867</td>
      <td width="380">1.1807</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m1_k24_n16</td>
      <td width="200">越大越好</td>
      <td width="200">7.31429</td>
      <td width="200">8.72727</td>
      <td width="380">1.1932</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m32_k16_n8</td>
      <td width="200">越大越好</td>
      <td width="200">23.339</td>
      <td width="200">22.8189</td>
      <td width="380">0.9777</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m32_k32_n8</td>
      <td width="200">越大越好</td>
      <td width="200">27.3067</td>
      <td width="200">27.4899</td>
      <td width="380">1.0067</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m32_k8_n4</td>
      <td width="200">越大越好</td>
      <td width="200">12.3373</td>
      <td width="200">10.3959</td>
      <td width="380">0.8426</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m35_k400_n400</td>
      <td width="200">越大越好</td>
      <td width="200">36.0864</td>
      <td width="200">38.4101</td>
      <td width="380">1.0644</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m35_k800_n1</td>
      <td width="200">越大越好</td>
      <td width="200">19.519</td>
      <td width="200">18.4636</td>
      <td width="380">0.9459</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m39_k400_n400</td>
      <td width="200">越大越好</td>
      <td width="200">34.8377</td>
      <td width="200">38.7267</td>
      <td width="380">1.1116</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m39_k492_n1</td>
      <td width="200">越大越好</td>
      <td width="200">18.858</td>
      <td width="200">17.0333</td>
      <td width="380">0.9032</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m39_k5_n1</td>
      <td width="200">越大越好</td>
      <td width="200">5.0</td>
      <td width="200">5.65217</td>
      <td width="380">1.1304</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m39_k800_n1</td>
      <td width="200">越大越好</td>
      <td width="200">19.1235</td>
      <td width="200">17.6471</td>
      <td width="380">0.9228</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m4130_k104_n32</td>
      <td width="200">越大越好</td>
      <td width="200">36.6431</td>
      <td width="200">41.1571</td>
      <td width="380">1.1232</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m4130_k116_n32</td>
      <td width="200">越大越好</td>
      <td width="200">36.6666</td>
      <td width="200">41.3991</td>
      <td width="380">1.1291</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m4130_k16_n1</td>
      <td width="200">越大越好</td>
      <td width="200">29.1808</td>
      <td width="200">20.5825</td>
      <td width="380">0.7053</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m4130_k32_n16</td>
      <td width="200">越大越好</td>
      <td width="200">34.2569</td>
      <td width="200">36.0517</td>
      <td width="380">1.0524</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m46_k492_n1</td>
      <td width="200">越大越好</td>
      <td width="200">21.9942</td>
      <td width="200">20.9847</td>
      <td width="380">0.9541</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m46_k5_n1</td>
      <td width="200">越大越好</td>
      <td width="200">5.89744</td>
      <td width="200">6.76471</td>
      <td width="380">1.1471</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m48_k18_n16</td>
      <td width="200">越大越好</td>
      <td width="200">29.9221</td>
      <td width="200">32.6038</td>
      <td width="380">1.0896</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m50_k100_n1</td>
      <td width="200">越大越好</td>
      <td width="200">22.779</td>
      <td width="200">23.4742</td>
      <td width="380">1.0305</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m50_k1298_n250</td>
      <td width="200">越大越好</td>
      <td width="200">36.792</td>
      <td width="200">43.035</td>
      <td width="380">1.1697</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m50_k250_n100</td>
      <td width="200">越大越好</td>
      <td width="200">37.1631</td>
      <td width="200">43.3358</td>
      <td width="380">1.1661</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m50_k250_n250</td>
      <td width="200">越大越好</td>
      <td width="200">37.1065</td>
      <td width="200">42.5225</td>
      <td width="380">1.146</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k128_n64</td>
      <td width="200">越大越好</td>
      <td width="200">36.2301</td>
      <td width="200">40.2505</td>
      <td width="380">1.111</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k1316_n2</td>
      <td width="200">越大越好</td>
      <td width="200">9.29534</td>
      <td width="200">9.51112</td>
      <td width="380">1.0232</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k1316_n256</td>
      <td width="200">越大越好</td>
      <td width="200">37.2551</td>
      <td width="200">41.8389</td>
      <td width="380">1.123</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k1540_n64</td>
      <td width="200">越大越好</td>
      <td width="200">36.2934</td>
      <td width="200">39.9592</td>
      <td width="380">1.101</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k1570_n128</td>
      <td width="200">越大越好</td>
      <td width="200">36.9408</td>
      <td width="200">40.2163</td>
      <td width="380">1.0887</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k1570_n256</td>
      <td width="200">越大越好</td>
      <td width="200">37.2262</td>
      <td width="200">41.7987</td>
      <td width="380">1.1228</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k16_n8</td>
      <td width="200">越大越好</td>
      <td width="200">23.8987</td>
      <td width="200">22.1791</td>
      <td width="380">0.928</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k256_n128</td>
      <td width="200">越大越好</td>
      <td width="200">37.3482</td>
      <td width="200">42.4824</td>
      <td width="380">1.1375</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k30_n16</td>
      <td width="200">越大越好</td>
      <td width="200">30.305</td>
      <td width="200">31.9099</td>
      <td width="380">1.053</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k32_n2</td>
      <td width="200">越大越好</td>
      <td width="200">11.8</td>
      <td width="200">9.54741</td>
      <td width="380">0.8091</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k48_n48</td>
      <td width="200">越大越好</td>
      <td width="200">34.7929</td>
      <td width="200">39.2765</td>
      <td width="380">1.1289</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k48_n80</td>
      <td width="200">越大越好</td>
      <td width="200">35.4053</td>
      <td width="200">40.7592</td>
      <td width="380">1.1512</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k64_n1</td>
      <td width="200">越大越好</td>
      <td width="200">19.5648</td>
      <td width="200">19.4139</td>
      <td width="380">0.9923</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k64_n2</td>
      <td width="200">越大越好</td>
      <td width="200">11.9399</td>
      <td width="200">9.97622</td>
      <td width="380">0.8355</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k64_n32</td>
      <td width="200">越大越好</td>
      <td width="200">34.4251</td>
      <td width="200">38.7966</td>
      <td width="380">1.127</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k64_n6</td>
      <td width="200">越大越好</td>
      <td width="200">21.8899</td>
      <td width="200">21.4545</td>
      <td width="380">0.9801</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m59_k8_n1</td>
      <td width="200">越大越好</td>
      <td width="200">9.73196</td>
      <td width="200">10.0426</td>
      <td width="380">1.0319</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m77_k20_n16</td>
      <td width="200">越大越好</td>
      <td width="200">30.2331</td>
      <td width="200">32.6142</td>
      <td width="380">1.0788</td>
    </tr>
    <tr>
      <td width="400">gemm_gflops_m80_k36_n16</td>
      <td width="200">越大越好</td>
      <td width="200">33.9073</td>
      <td width="200">38.384</td>
      <td width="380">1.132</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
