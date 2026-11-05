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
      <td width="600">2026-11-05T04:49:43Z</td>
      <td width="600">2026-11-05T04:49:34Z</td>
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
      <td width="600">2026-11-05T04:47:27Z</td>
      <td width="600">2026-11-05T04:47:34Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 127313 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 168108 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 170084 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 162514 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 151328 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 157244 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169373 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 165710 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 377346 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 378833 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 345599 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 362634 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">eigen_btl</td>
      <td width="880">5.0.1 (bench/btl that ships inside the pinned Eigen 5.0.1 release archive, built with -DEIGEN_BUILD_BTL=ON)</td>
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

##### o3_gemm

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
      <td width="500">o3_gemm_wall</td>
      <td width="280">18.09323</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemm_rss</td>
      <td width="280">970.531</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemm_gflops_128</td>
      <td width="280">38.379695</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemm_gflops_512</td>
      <td width="280">39.227001</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemm_gflops_1024</td>
      <td width="280">39.293143</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### o3_gemv

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
      <td width="500">o3_gemv_wall</td>
      <td width="280">2.868113</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemv_rss</td>
      <td width="280">289.91</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemv_gflops_128</td>
      <td width="280">33.199414</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemv_gflops_512</td>
      <td width="280">26.137694</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemv_gflops_1024</td>
      <td width="280">21.80205</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### o3_trisolve_matrix

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
      <td width="500">o3_trisolve_matrix_wall</td>
      <td width="280">3.470238</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_trisolve_matrix_rss</td>
      <td width="280">351.195</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_trisolve_matrix_gflops_128</td>
      <td width="280">22.686698</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_trisolve_matrix_gflops_512</td>
      <td width="280">28.647405</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_trisolve_matrix_gflops_1024</td>
      <td width="280">28.146556</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### o3_cholesky

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
      <td width="500">o3_cholesky_wall</td>
      <td width="280">1.215622</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_cholesky_rss</td>
      <td width="280">178.547</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_cholesky_gflops_128</td>
      <td width="280">21.976288</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_cholesky_gflops_512</td>
      <td width="280">31.571041</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_cholesky_gflops_1024</td>
      <td width="280">32.47929</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### o3_axpy

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
      <td width="500">o3_axpy_wall</td>
      <td width="280">1.166139</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_axpy_rss</td>
      <td width="280">83.664</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_axpy_gflops_128</td>
      <td width="280">14.343702</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_axpy_gflops_512</td>
      <td width="280">14.676004</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_axpy_gflops_1024</td>
      <td width="280">14.732985</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### native_gemm

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
      <td width="500">native_gemm_wall</td>
      <td width="280">9.933616</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_gemm_rss</td>
      <td width="280">969.23</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_gemm_gflops_128</td>
      <td width="280">107.695079</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_gemm_gflops_512</td>
      <td width="280">114.459781</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_gemm_gflops_1024</td>
      <td width="280">113.858571</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### native_gemv

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
      <td width="500">native_gemv_wall</td>
      <td width="280">2.870273</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_gemv_rss</td>
      <td width="280">289.895</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_gemv_gflops_128</td>
      <td width="280">56.458797</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_gemv_gflops_512</td>
      <td width="280">49.339087</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_gemv_gflops_1024</td>
      <td width="280">40.097925</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### native_trisolve_matrix

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
      <td width="500">native_trisolve_matrix_wall</td>
      <td width="280">2.519565</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_trisolve_matrix_rss</td>
      <td width="280">350.957</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_trisolve_matrix_gflops_128</td>
      <td width="280">69.942869</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_trisolve_matrix_gflops_512</td>
      <td width="280">77.077739</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_trisolve_matrix_gflops_1024</td>
      <td width="280">84.896303</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### native_cholesky

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
      <td width="500">native_cholesky_wall</td>
      <td width="280">1.616878</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_cholesky_rss</td>
      <td width="280">178.672</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_cholesky_gflops_128</td>
      <td width="280">37.503283</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_cholesky_gflops_512</td>
      <td width="280">69.349898</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_cholesky_gflops_1024</td>
      <td width="280">72.240227</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### native_axpy

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
      <td width="500">native_axpy_wall</td>
      <td width="280">1.115993</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_axpy_rss</td>
      <td width="280">83.641</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_axpy_gflops_128</td>
      <td width="280">38.210748</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_axpy_gflops_512</td>
      <td width="280">49.005317</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_axpy_gflops_1024</td>
      <td width="280">46.97596</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### eigen 5.0.1

##### o3_gemm

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
      <td width="500">o3_gemm_wall</td>
      <td width="280">22.484866</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemm_rss</td>
      <td width="280">961.781</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemm_gflops_128</td>
      <td width="280">46.10347</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemm_gflops_512</td>
      <td width="280">44.660638</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemm_gflops_1024</td>
      <td width="280">44.76066</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### o3_gemv

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
      <td width="500">o3_gemv_wall</td>
      <td width="280">5.404055</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemv_rss</td>
      <td width="280">289.477</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemv_gflops_128</td>
      <td width="280">25.857769</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemv_gflops_512</td>
      <td width="280">16.342308</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_gemv_gflops_1024</td>
      <td width="280">10.643981</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### o3_trisolve_matrix

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
      <td width="500">o3_trisolve_matrix_wall</td>
      <td width="280">5.308323</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_trisolve_matrix_rss</td>
      <td width="280">348.094</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_trisolve_matrix_gflops_128</td>
      <td width="280">20.038419</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_trisolve_matrix_gflops_512</td>
      <td width="280">31.461407</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_trisolve_matrix_gflops_1024</td>
      <td width="280">37.354241</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### o3_cholesky

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
      <td width="500">o3_cholesky_wall</td>
      <td width="280">2.23169</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_cholesky_rss</td>
      <td width="280">178.039</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_cholesky_gflops_128</td>
      <td width="280">19.425692</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_cholesky_gflops_512</td>
      <td width="280">35.49416</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_cholesky_gflops_1024</td>
      <td width="280">39.588735</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### o3_axpy

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
      <td width="500">o3_axpy_wall</td>
      <td width="280">1.974973</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_axpy_rss</td>
      <td width="280">83.238</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">o3_axpy_gflops_128</td>
      <td width="280">14.996141</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_axpy_gflops_512</td>
      <td width="280">12.407392</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">o3_axpy_gflops_1024</td>
      <td width="280">15.519419</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### native_gemm

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
      <td width="500">native_gemm_wall</td>
      <td width="280">22.725724</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_gemm_rss</td>
      <td width="280">961.773</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_gemm_gflops_128</td>
      <td width="280">45.682481</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_gemm_gflops_512</td>
      <td width="280">41.481454</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_gemm_gflops_1024</td>
      <td width="280">41.070546</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### native_gemv

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
      <td width="500">native_gemv_wall</td>
      <td width="280">5.452973</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_gemv_rss</td>
      <td width="280">289.484</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_gemv_gflops_128</td>
      <td width="280">26.132494</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_gemv_gflops_512</td>
      <td width="280">15.769871</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_gemv_gflops_1024</td>
      <td width="280">10.57645</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### native_trisolve_matrix

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
      <td width="500">native_trisolve_matrix_wall</td>
      <td width="280">5.40336</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_trisolve_matrix_rss</td>
      <td width="280">348.098</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_trisolve_matrix_gflops_128</td>
      <td width="280">20.194253</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_trisolve_matrix_gflops_512</td>
      <td width="280">32.362124</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_trisolve_matrix_gflops_1024</td>
      <td width="280">38.035136</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### native_cholesky

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
      <td width="500">native_cholesky_wall</td>
      <td width="280">1.623538</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_cholesky_rss</td>
      <td width="280">178.035</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_cholesky_gflops_128</td>
      <td width="280">19.099452</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_cholesky_gflops_512</td>
      <td width="280">34.155876</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_cholesky_gflops_1024</td>
      <td width="280">38.180486</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### native_axpy

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
      <td width="500">native_axpy_wall</td>
      <td width="280">1.974702</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_axpy_rss</td>
      <td width="280">83.246</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">native_axpy_gflops_128</td>
      <td width="280">15.402988</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_axpy_gflops_512</td>
      <td width="280">12.974696</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">native_axpy_gflops_1024</td>
      <td width="280">16.998859</td>
      <td width="200">GFLOP/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### eigen 5.0.1

#### o3_gemm

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
      <td width="400">o3_gemm_wall</td>
      <td width="200">越小越好</td>
      <td width="200">18.09323</td>
      <td width="200">22.484866</td>
      <td width="380">0.8047</td>
    </tr>
    <tr>
      <td width="400">o3_gemm_rss</td>
      <td width="200">越小越好</td>
      <td width="200">970.531</td>
      <td width="200">961.781</td>
      <td width="380">1.0091</td>
    </tr>
    <tr>
      <td width="400">o3_gemm_gflops_128</td>
      <td width="200">越大越好</td>
      <td width="200">38.379695</td>
      <td width="200">46.10347</td>
      <td width="380">1.2012</td>
    </tr>
    <tr>
      <td width="400">o3_gemm_gflops_512</td>
      <td width="200">越大越好</td>
      <td width="200">39.227001</td>
      <td width="200">44.660638</td>
      <td width="380">1.1385</td>
    </tr>
    <tr>
      <td width="400">o3_gemm_gflops_1024</td>
      <td width="200">越大越好</td>
      <td width="200">39.293143</td>
      <td width="200">44.76066</td>
      <td width="380">1.1391</td>
    </tr>
  </tbody>
</table>

#### o3_gemv

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
      <td width="400">o3_gemv_wall</td>
      <td width="200">越小越好</td>
      <td width="200">2.868113</td>
      <td width="200">5.404055</td>
      <td width="380">0.5307</td>
    </tr>
    <tr>
      <td width="400">o3_gemv_rss</td>
      <td width="200">越小越好</td>
      <td width="200">289.91</td>
      <td width="200">289.477</td>
      <td width="380">1.0015</td>
    </tr>
    <tr>
      <td width="400">o3_gemv_gflops_128</td>
      <td width="200">越大越好</td>
      <td width="200">33.199414</td>
      <td width="200">25.857769</td>
      <td width="380">0.7789</td>
    </tr>
    <tr>
      <td width="400">o3_gemv_gflops_512</td>
      <td width="200">越大越好</td>
      <td width="200">26.137694</td>
      <td width="200">16.342308</td>
      <td width="380">0.6252</td>
    </tr>
    <tr>
      <td width="400">o3_gemv_gflops_1024</td>
      <td width="200">越大越好</td>
      <td width="200">21.80205</td>
      <td width="200">10.643981</td>
      <td width="380">0.4882</td>
    </tr>
  </tbody>
</table>

#### o3_trisolve_matrix

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
      <td width="400">o3_trisolve_matrix_wall</td>
      <td width="200">越小越好</td>
      <td width="200">3.470238</td>
      <td width="200">5.308323</td>
      <td width="380">0.6537</td>
    </tr>
    <tr>
      <td width="400">o3_trisolve_matrix_rss</td>
      <td width="200">越小越好</td>
      <td width="200">351.195</td>
      <td width="200">348.094</td>
      <td width="380">1.0089</td>
    </tr>
    <tr>
      <td width="400">o3_trisolve_matrix_gflops_128</td>
      <td width="200">越大越好</td>
      <td width="200">22.686698</td>
      <td width="200">20.038419</td>
      <td width="380">0.8833</td>
    </tr>
    <tr>
      <td width="400">o3_trisolve_matrix_gflops_512</td>
      <td width="200">越大越好</td>
      <td width="200">28.647405</td>
      <td width="200">31.461407</td>
      <td width="380">1.0982</td>
    </tr>
    <tr>
      <td width="400">o3_trisolve_matrix_gflops_1024</td>
      <td width="200">越大越好</td>
      <td width="200">28.146556</td>
      <td width="200">37.354241</td>
      <td width="380">1.3271</td>
    </tr>
  </tbody>
</table>

#### o3_cholesky

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
      <td width="400">o3_cholesky_wall</td>
      <td width="200">越小越好</td>
      <td width="200">1.215622</td>
      <td width="200">2.23169</td>
      <td width="380">0.5447</td>
    </tr>
    <tr>
      <td width="400">o3_cholesky_rss</td>
      <td width="200">越小越好</td>
      <td width="200">178.547</td>
      <td width="200">178.039</td>
      <td width="380">1.0029</td>
    </tr>
    <tr>
      <td width="400">o3_cholesky_gflops_128</td>
      <td width="200">越大越好</td>
      <td width="200">21.976288</td>
      <td width="200">19.425692</td>
      <td width="380">0.8839</td>
    </tr>
    <tr>
      <td width="400">o3_cholesky_gflops_512</td>
      <td width="200">越大越好</td>
      <td width="200">31.571041</td>
      <td width="200">35.49416</td>
      <td width="380">1.1243</td>
    </tr>
    <tr>
      <td width="400">o3_cholesky_gflops_1024</td>
      <td width="200">越大越好</td>
      <td width="200">32.47929</td>
      <td width="200">39.588735</td>
      <td width="380">1.2189</td>
    </tr>
  </tbody>
</table>

#### o3_axpy

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
      <td width="400">o3_axpy_wall</td>
      <td width="200">越小越好</td>
      <td width="200">1.166139</td>
      <td width="200">1.974973</td>
      <td width="380">0.5905</td>
    </tr>
    <tr>
      <td width="400">o3_axpy_rss</td>
      <td width="200">越小越好</td>
      <td width="200">83.664</td>
      <td width="200">83.238</td>
      <td width="380">1.0051</td>
    </tr>
    <tr>
      <td width="400">o3_axpy_gflops_128</td>
      <td width="200">越大越好</td>
      <td width="200">14.343702</td>
      <td width="200">14.996141</td>
      <td width="380">1.0455</td>
    </tr>
    <tr>
      <td width="400">o3_axpy_gflops_512</td>
      <td width="200">越大越好</td>
      <td width="200">14.676004</td>
      <td width="200">12.407392</td>
      <td width="380">0.8454</td>
    </tr>
    <tr>
      <td width="400">o3_axpy_gflops_1024</td>
      <td width="200">越大越好</td>
      <td width="200">14.732985</td>
      <td width="200">15.519419</td>
      <td width="380">1.0534</td>
    </tr>
  </tbody>
</table>

#### native_gemm

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
      <td width="400">native_gemm_wall</td>
      <td width="200">越小越好</td>
      <td width="200">9.933616</td>
      <td width="200">22.725724</td>
      <td width="380">0.4371</td>
    </tr>
    <tr>
      <td width="400">native_gemm_rss</td>
      <td width="200">越小越好</td>
      <td width="200">969.23</td>
      <td width="200">961.773</td>
      <td width="380">1.0078</td>
    </tr>
    <tr>
      <td width="400">native_gemm_gflops_128</td>
      <td width="200">越大越好</td>
      <td width="200">107.695079</td>
      <td width="200">45.682481</td>
      <td width="380">0.4242</td>
    </tr>
    <tr>
      <td width="400">native_gemm_gflops_512</td>
      <td width="200">越大越好</td>
      <td width="200">114.459781</td>
      <td width="200">41.481454</td>
      <td width="380">0.3624</td>
    </tr>
    <tr>
      <td width="400">native_gemm_gflops_1024</td>
      <td width="200">越大越好</td>
      <td width="200">113.858571</td>
      <td width="200">41.070546</td>
      <td width="380">0.3607</td>
    </tr>
  </tbody>
</table>

#### native_gemv

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
      <td width="400">native_gemv_wall</td>
      <td width="200">越小越好</td>
      <td width="200">2.870273</td>
      <td width="200">5.452973</td>
      <td width="380">0.5264</td>
    </tr>
    <tr>
      <td width="400">native_gemv_rss</td>
      <td width="200">越小越好</td>
      <td width="200">289.895</td>
      <td width="200">289.484</td>
      <td width="380">1.0014</td>
    </tr>
    <tr>
      <td width="400">native_gemv_gflops_128</td>
      <td width="200">越大越好</td>
      <td width="200">56.458797</td>
      <td width="200">26.132494</td>
      <td width="380">0.4629</td>
    </tr>
    <tr>
      <td width="400">native_gemv_gflops_512</td>
      <td width="200">越大越好</td>
      <td width="200">49.339087</td>
      <td width="200">15.769871</td>
      <td width="380">0.3196</td>
    </tr>
    <tr>
      <td width="400">native_gemv_gflops_1024</td>
      <td width="200">越大越好</td>
      <td width="200">40.097925</td>
      <td width="200">10.57645</td>
      <td width="380">0.2638</td>
    </tr>
  </tbody>
</table>

#### native_trisolve_matrix

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
      <td width="400">native_trisolve_matrix_wall</td>
      <td width="200">越小越好</td>
      <td width="200">2.519565</td>
      <td width="200">5.40336</td>
      <td width="380">0.4663</td>
    </tr>
    <tr>
      <td width="400">native_trisolve_matrix_rss</td>
      <td width="200">越小越好</td>
      <td width="200">350.957</td>
      <td width="200">348.098</td>
      <td width="380">1.0082</td>
    </tr>
    <tr>
      <td width="400">native_trisolve_matrix_gflops_128</td>
      <td width="200">越大越好</td>
      <td width="200">69.942869</td>
      <td width="200">20.194253</td>
      <td width="380">0.2887</td>
    </tr>
    <tr>
      <td width="400">native_trisolve_matrix_gflops_512</td>
      <td width="200">越大越好</td>
      <td width="200">77.077739</td>
      <td width="200">32.362124</td>
      <td width="380">0.4199</td>
    </tr>
    <tr>
      <td width="400">native_trisolve_matrix_gflops_1024</td>
      <td width="200">越大越好</td>
      <td width="200">84.896303</td>
      <td width="200">38.035136</td>
      <td width="380">0.448</td>
    </tr>
  </tbody>
</table>

#### native_cholesky

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
      <td width="400">native_cholesky_wall</td>
      <td width="200">越小越好</td>
      <td width="200">1.616878</td>
      <td width="200">1.623538</td>
      <td width="380">0.9959</td>
    </tr>
    <tr>
      <td width="400">native_cholesky_rss</td>
      <td width="200">越小越好</td>
      <td width="200">178.672</td>
      <td width="200">178.035</td>
      <td width="380">1.0036</td>
    </tr>
    <tr>
      <td width="400">native_cholesky_gflops_128</td>
      <td width="200">越大越好</td>
      <td width="200">37.503283</td>
      <td width="200">19.099452</td>
      <td width="380">0.5093</td>
    </tr>
    <tr>
      <td width="400">native_cholesky_gflops_512</td>
      <td width="200">越大越好</td>
      <td width="200">69.349898</td>
      <td width="200">34.155876</td>
      <td width="380">0.4925</td>
    </tr>
    <tr>
      <td width="400">native_cholesky_gflops_1024</td>
      <td width="200">越大越好</td>
      <td width="200">72.240227</td>
      <td width="200">38.180486</td>
      <td width="380">0.5285</td>
    </tr>
  </tbody>
</table>

#### native_axpy

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
      <td width="400">native_axpy_wall</td>
      <td width="200">越小越好</td>
      <td width="200">1.115993</td>
      <td width="200">1.974702</td>
      <td width="380">0.5651</td>
    </tr>
    <tr>
      <td width="400">native_axpy_rss</td>
      <td width="200">越小越好</td>
      <td width="200">83.641</td>
      <td width="200">83.246</td>
      <td width="380">1.0047</td>
    </tr>
    <tr>
      <td width="400">native_axpy_gflops_128</td>
      <td width="200">越大越好</td>
      <td width="200">38.210748</td>
      <td width="200">15.402988</td>
      <td width="380">0.4031</td>
    </tr>
    <tr>
      <td width="400">native_axpy_gflops_512</td>
      <td width="200">越大越好</td>
      <td width="200">49.005317</td>
      <td width="200">12.974696</td>
      <td width="380">0.2648</td>
    </tr>
    <tr>
      <td width="400">native_axpy_gflops_1024</td>
      <td width="200">越大越好</td>
      <td width="200">46.97596</td>
      <td width="200">16.998859</td>
      <td width="380">0.3619</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
