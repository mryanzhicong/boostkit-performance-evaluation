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
      <td width="220">libmpc</td>
      <td width="160">1.4.1</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">libmpc</td>
      <td width="160">1.4.1</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### libmpc 1.4.1

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
      <td width="600">1.4.1</td>
      <td width="600">1.4.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.4.1</td>
      <td width="600">1.4.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-08T19:55:30Z</td>
      <td width="600">2026-11-08T19:56:25Z</td>
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
      <td width="600">2026-11-08T19:54:22Z</td>
      <td width="600">2026-11-08T19:54:21Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 62010 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 140438 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 168000 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 166211 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 134583 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 159755 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169229 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 163516 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 365930 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 378618 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 344170 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 351074 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">mpc-bench</td>
      <td width="880">fixed-workload harness following upstream tools/bench methodology</td>
    </tr>
    <tr>
      <td width="500">gmp</td>
      <td width="880">6.3.0 (pinned private dependency)</td>
    </tr>
    <tr>
      <td width="500">mpfr</td>
      <td width="880">4.2.2 (pinned private dependency)</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### libmpc 1.4.1

##### mpc_mul_256

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
      <td width="500">mpc_mul_256.ops_per_second</td>
      <td width="280">7331779.495635</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_256.ns_per_op</td>
      <td width="280">136.392536163</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_256.wall_seconds</td>
      <td width="280">0.264185</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_256.peak_rss_mib</td>
      <td width="280">12.602</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_mul_1024

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
      <td width="500">mpc_mul_1024.ops_per_second</td>
      <td width="280">1632228.665832</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_1024.ns_per_op</td>
      <td width="280">612.659255981</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_1024.wall_seconds</td>
      <td width="280">0.264224</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_1024.peak_rss_mib</td>
      <td width="280">12.566</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_mul_4096

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
      <td width="500">mpc_mul_4096.ops_per_second</td>
      <td width="280">1095232.281878</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_4096.ns_per_op</td>
      <td width="280">913.048324585</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_4096.wall_seconds</td>
      <td width="280">0.214098</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_4096.peak_rss_mib</td>
      <td width="280">12.598</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_sqr_1024

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
      <td width="500">mpc_sqr_1024.ops_per_second</td>
      <td width="280">4030083.141527</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_sqr_1024.ns_per_op</td>
      <td width="280">248.133838654</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_sqr_1024.wall_seconds</td>
      <td width="280">0.214078</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_sqr_1024.peak_rss_mib</td>
      <td width="280">12.582</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_div_1024

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
      <td width="500">mpc_div_1024.ops_per_second</td>
      <td width="280">577635.615861</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_div_1024.ns_per_op</td>
      <td width="280">1731.195190431</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_div_1024.wall_seconds</td>
      <td width="280">0.214155</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_div_1024.peak_rss_mib</td>
      <td width="280">12.559</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_pow_256

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
      <td width="500">mpc_pow_256.ops_per_second</td>
      <td width="280">47565.073515</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_256.ns_per_op</td>
      <td width="280">21023.829589681</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_256.wall_seconds</td>
      <td width="280">0.264183</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_256.peak_rss_mib</td>
      <td width="280">12.598</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_pow_1024

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
      <td width="500">mpc_pow_1024.ops_per_second</td>
      <td width="280">17096.030524</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_1024.ns_per_op</td>
      <td width="280">58493.110350743</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_1024.wall_seconds</td>
      <td width="280">0.214128</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_1024.peak_rss_mib</td>
      <td width="280">12.562</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_exp_256

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
      <td width="500">mpc_exp_256.ops_per_second</td>
      <td width="280">213919.964269</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_exp_256.ns_per_op</td>
      <td width="280">4674.645507806</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_exp_256.wall_seconds</td>
      <td width="280">0.264232</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_exp_256.peak_rss_mib</td>
      <td width="280">12.559</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### libmpc 1.4.1

##### mpc_mul_256

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
      <td width="500">mpc_mul_256.ops_per_second</td>
      <td width="280">4476660.974867</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_256.ns_per_op</td>
      <td width="280">223.380775452</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_256.wall_seconds</td>
      <td width="280">0.215187</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_256.peak_rss_mib</td>
      <td width="280">11.754</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_mul_1024

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
      <td width="500">mpc_mul_1024.ops_per_second</td>
      <td width="280">917274.662989</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_1024.ns_per_op</td>
      <td width="280">1090.186004638</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_1024.wall_seconds</td>
      <td width="280">0.265533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_1024.peak_rss_mib</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_mul_4096

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
      <td width="500">mpc_mul_4096.ops_per_second</td>
      <td width="280">683100.364242</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_4096.ns_per_op</td>
      <td width="280">1463.913726806</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_4096.wall_seconds</td>
      <td width="280">0.316054</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_mul_4096.peak_rss_mib</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_sqr_1024

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
      <td width="500">mpc_sqr_1024.ops_per_second</td>
      <td width="280">1254323.363782</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_sqr_1024.ns_per_op</td>
      <td width="280">797.242584229</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_sqr_1024.wall_seconds</td>
      <td width="280">0.165044</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_sqr_1024.peak_rss_mib</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_div_1024

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
      <td width="500">mpc_div_1024.ops_per_second</td>
      <td width="280">323546.052092</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_div_1024.ns_per_op</td>
      <td width="280">3090.750122074</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_div_1024.wall_seconds</td>
      <td width="280">0.164978</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_div_1024.peak_rss_mib</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_pow_256

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
      <td width="500">mpc_pow_256.ops_per_second</td>
      <td width="280">32812.204602</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_256.ns_per_op</td>
      <td width="280">30476.464843787</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_256.wall_seconds</td>
      <td width="280">0.215116</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_256.peak_rss_mib</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_pow_1024

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
      <td width="500">mpc_pow_1024.ops_per_second</td>
      <td width="280">9988.673001</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_1024.ns_per_op</td>
      <td width="280">100113.398436398</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_1024.wall_seconds</td>
      <td width="280">0.165031</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_pow_1024.peak_rss_mib</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### mpc_exp_256

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
      <td width="500">mpc_exp_256.ops_per_second</td>
      <td width="280">146001.871005</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">mpc_exp_256.ns_per_op</td>
      <td width="280">6849.227294942</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_exp_256.wall_seconds</td>
      <td width="280">0.215613</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mpc_exp_256.peak_rss_mib</td>
      <td width="280">11.754</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### libmpc 1.4.1

#### mpc_mul_256

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
      <td width="400">mpc_mul_256.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">7331779.495635</td>
      <td width="200">4476660.974867</td>
      <td width="380">0.6106</td>
    </tr>
    <tr>
      <td width="400">mpc_mul_256.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">136.392536163</td>
      <td width="200">223.380775452</td>
      <td width="380">0.6106</td>
    </tr>
    <tr>
      <td width="400">mpc_mul_256.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.264185</td>
      <td width="200">0.215187</td>
      <td width="380">1.2277</td>
    </tr>
    <tr>
      <td width="400">mpc_mul_256.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.602</td>
      <td width="200">11.754</td>
      <td width="380">1.0721</td>
    </tr>
  </tbody>
</table>

#### mpc_mul_1024

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
      <td width="400">mpc_mul_1024.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">1632228.665832</td>
      <td width="200">917274.662989</td>
      <td width="380">0.562</td>
    </tr>
    <tr>
      <td width="400">mpc_mul_1024.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">612.659255981</td>
      <td width="200">1090.186004638</td>
      <td width="380">0.562</td>
    </tr>
    <tr>
      <td width="400">mpc_mul_1024.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.264224</td>
      <td width="200">0.265533</td>
      <td width="380">0.9951</td>
    </tr>
    <tr>
      <td width="400">mpc_mul_1024.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.566</td>
      <td width="200">11.758</td>
      <td width="380">1.0687</td>
    </tr>
  </tbody>
</table>

#### mpc_mul_4096

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
      <td width="400">mpc_mul_4096.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">1095232.281878</td>
      <td width="200">683100.364242</td>
      <td width="380">0.6237</td>
    </tr>
    <tr>
      <td width="400">mpc_mul_4096.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">913.048324585</td>
      <td width="200">1463.913726806</td>
      <td width="380">0.6237</td>
    </tr>
    <tr>
      <td width="400">mpc_mul_4096.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.214098</td>
      <td width="200">0.316054</td>
      <td width="380">0.6774</td>
    </tr>
    <tr>
      <td width="400">mpc_mul_4096.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.598</td>
      <td width="200">11.758</td>
      <td width="380">1.0714</td>
    </tr>
  </tbody>
</table>

#### mpc_sqr_1024

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
      <td width="400">mpc_sqr_1024.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">4030083.141527</td>
      <td width="200">1254323.363782</td>
      <td width="380">0.3112</td>
    </tr>
    <tr>
      <td width="400">mpc_sqr_1024.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">248.133838654</td>
      <td width="200">797.242584229</td>
      <td width="380">0.3112</td>
    </tr>
    <tr>
      <td width="400">mpc_sqr_1024.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.214078</td>
      <td width="200">0.165044</td>
      <td width="380">1.2971</td>
    </tr>
    <tr>
      <td width="400">mpc_sqr_1024.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.582</td>
      <td width="200">11.758</td>
      <td width="380">1.0701</td>
    </tr>
  </tbody>
</table>

#### mpc_div_1024

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
      <td width="400">mpc_div_1024.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">577635.615861</td>
      <td width="200">323546.052092</td>
      <td width="380">0.5601</td>
    </tr>
    <tr>
      <td width="400">mpc_div_1024.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">1731.195190431</td>
      <td width="200">3090.750122074</td>
      <td width="380">0.5601</td>
    </tr>
    <tr>
      <td width="400">mpc_div_1024.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.214155</td>
      <td width="200">0.164978</td>
      <td width="380">1.2981</td>
    </tr>
    <tr>
      <td width="400">mpc_div_1024.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.559</td>
      <td width="200">11.758</td>
      <td width="380">1.0681</td>
    </tr>
  </tbody>
</table>

#### mpc_pow_256

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
      <td width="400">mpc_pow_256.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">47565.073515</td>
      <td width="200">32812.204602</td>
      <td width="380">0.6898</td>
    </tr>
    <tr>
      <td width="400">mpc_pow_256.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">21023.829589681</td>
      <td width="200">30476.464843787</td>
      <td width="380">0.6898</td>
    </tr>
    <tr>
      <td width="400">mpc_pow_256.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.264183</td>
      <td width="200">0.215116</td>
      <td width="380">1.2281</td>
    </tr>
    <tr>
      <td width="400">mpc_pow_256.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.598</td>
      <td width="200">11.758</td>
      <td width="380">1.0714</td>
    </tr>
  </tbody>
</table>

#### mpc_pow_1024

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
      <td width="400">mpc_pow_1024.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">17096.030524</td>
      <td width="200">9988.673001</td>
      <td width="380">0.5843</td>
    </tr>
    <tr>
      <td width="400">mpc_pow_1024.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">58493.110350743</td>
      <td width="200">100113.398436398</td>
      <td width="380">0.5843</td>
    </tr>
    <tr>
      <td width="400">mpc_pow_1024.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.214128</td>
      <td width="200">0.165031</td>
      <td width="380">1.2975</td>
    </tr>
    <tr>
      <td width="400">mpc_pow_1024.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.562</td>
      <td width="200">11.758</td>
      <td width="380">1.0684</td>
    </tr>
  </tbody>
</table>

#### mpc_exp_256

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
      <td width="400">mpc_exp_256.ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">213919.964269</td>
      <td width="200">146001.871005</td>
      <td width="380">0.6825</td>
    </tr>
    <tr>
      <td width="400">mpc_exp_256.ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">4674.645507806</td>
      <td width="200">6849.227294942</td>
      <td width="380">0.6825</td>
    </tr>
    <tr>
      <td width="400">mpc_exp_256.wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.264232</td>
      <td width="200">0.215613</td>
      <td width="380">1.2255</td>
    </tr>
    <tr>
      <td width="400">mpc_exp_256.peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">12.559</td>
      <td width="200">11.754</td>
      <td width="380">1.0685</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
