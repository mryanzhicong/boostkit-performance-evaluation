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
      <td width="180">AI</td>
      <td width="220">scann</td>
      <td width="160">1.4.2</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">AI</td>
      <td width="220">scann</td>
      <td width="160">1.4.2</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### scann 1.4.2

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
      <td width="600">1.4.2</td>
      <td width="600">1.4.2</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.4.2</td>
      <td width="600">1.4.2</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-05T05:04:37Z</td>
      <td width="600">2026-11-05T05:03:47Z</td>
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
      <td width="600">2026-11-05T05:01:45Z</td>
      <td width="600">2026-11-05T05:01:45Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 127318 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 168137 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 170099 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 162475 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 151366 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 157232 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169381 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 165676 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 377365 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 378850 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 345546 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 362782 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">ann_benchmarks</td>
      <td width="880">2e081ad32c1eccab72dcb739ad886c310b90f715</td>
    </tr>
    <tr>
      <td width="500">scann</td>
      <td width="880">1.4.2</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### scann 1.4.2

##### fashion-mnist-784-euclidean

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
      <td width="500">fashion-mnist-784-euclidean/recall_at_10</td>
      <td width="280">0.9837</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">fashion-mnist-784-euclidean/qps</td>
      <td width="280">56147.59562738236</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">fashion-mnist-784-euclidean/build_time_s</td>
      <td width="280">6.768923759460449</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fashion-mnist-784-euclidean/candidates</td>
      <td width="280">10.0</td>
      <td width="200">count</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">fashion-mnist-784-euclidean/index_size_kb</td>
      <td width="280">229704.0</td>
      <td width="200">kB</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

##### sift-128-euclidean

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
      <td width="500">sift-128-euclidean/recall_at_10</td>
      <td width="280">0.9607</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">sift-128-euclidean/qps</td>
      <td width="280">42184.8859511657</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">sift-128-euclidean/build_time_s</td>
      <td width="280">9.05025053024292</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sift-128-euclidean/candidates</td>
      <td width="280">10.0</td>
      <td width="200">count</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">sift-128-euclidean/index_size_kb</td>
      <td width="280">662996.0</td>
      <td width="200">kB</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

##### glove-100-angular

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
      <td width="500">glove-100-angular/recall_at_10</td>
      <td width="280">0.97178</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">glove-100-angular/qps</td>
      <td width="280">41291.3794495313</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">glove-100-angular/build_time_s</td>
      <td width="280">6.09151029586792</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">glove-100-angular/candidates</td>
      <td width="280">10.0</td>
      <td width="200">count</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">glove-100-angular/index_size_kb</td>
      <td width="280">518452.0</td>
      <td width="200">kB</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

##### gist-960-euclidean

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
      <td width="500">gist-960-euclidean/recall_at_10</td>
      <td width="280">0.9847</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gist-960-euclidean/qps</td>
      <td width="280">5702.4396080094075</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gist-960-euclidean/build_time_s</td>
      <td width="280">39.653669118881226</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gist-960-euclidean/candidates</td>
      <td width="280">10.0</td>
      <td width="200">count</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">gist-960-euclidean/index_size_kb</td>
      <td width="280">4311344.0</td>
      <td width="200">kB</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

##### deep-image-96-angular

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
      <td width="500">deep-image-96-angular/recall_at_10</td>
      <td width="280">0.9675300000000001</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">deep-image-96-angular/qps</td>
      <td width="280">35675.40625251705</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">deep-image-96-angular/build_time_s</td>
      <td width="280">35.68984031677246</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deep-image-96-angular/candidates</td>
      <td width="280">10.0</td>
      <td width="200">count</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">deep-image-96-angular/index_size_kb</td>
      <td width="280">3832688.0</td>
      <td width="200">kB</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

### aarch64

#### scann 1.4.2

##### fashion-mnist-784-euclidean

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
      <td width="500">fashion-mnist-784-euclidean/recall_at_10</td>
      <td width="280">0.98461</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">fashion-mnist-784-euclidean/qps</td>
      <td width="280">27616.307320758155</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">fashion-mnist-784-euclidean/build_time_s</td>
      <td width="280">9.905945777893066</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fashion-mnist-784-euclidean/candidates</td>
      <td width="280">10.0</td>
      <td width="200">count</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">fashion-mnist-784-euclidean/index_size_kb</td>
      <td width="280">226104.0</td>
      <td width="200">kB</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

##### sift-128-euclidean

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
      <td width="500">sift-128-euclidean/recall_at_10</td>
      <td width="280">0.96045</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">sift-128-euclidean/qps</td>
      <td width="280">25277.672645928367</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">sift-128-euclidean/build_time_s</td>
      <td width="280">12.909593105316162</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sift-128-euclidean/candidates</td>
      <td width="280">10.0</td>
      <td width="200">count</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">sift-128-euclidean/index_size_kb</td>
      <td width="280">664080.0</td>
      <td width="200">kB</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

##### glove-100-angular

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
      <td width="500">glove-100-angular/recall_at_10</td>
      <td width="280">0.9717800000000001</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">glove-100-angular/qps</td>
      <td width="280">22183.622015094752</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">glove-100-angular/build_time_s</td>
      <td width="280">7.4964940547943115</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">glove-100-angular/candidates</td>
      <td width="280">10.0</td>
      <td width="200">count</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">glove-100-angular/index_size_kb</td>
      <td width="280">525596.0</td>
      <td width="200">kB</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

##### gist-960-euclidean

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
      <td width="500">gist-960-euclidean/recall_at_10</td>
      <td width="280">0.9857</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gist-960-euclidean/qps</td>
      <td width="280">5461.134229481135</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">gist-960-euclidean/build_time_s</td>
      <td width="280">54.01877474784851</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gist-960-euclidean/candidates</td>
      <td width="280">10.0</td>
      <td width="200">count</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">gist-960-euclidean/index_size_kb</td>
      <td width="280">4317216.0</td>
      <td width="200">kB</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

##### deep-image-96-angular

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
      <td width="500">deep-image-96-angular/recall_at_10</td>
      <td width="280">0.9674800000000001</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">deep-image-96-angular/qps</td>
      <td width="280">15772.892822424636</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">deep-image-96-angular/build_time_s</td>
      <td width="280">40.87046670913696</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deep-image-96-angular/candidates</td>
      <td width="280">10.0</td>
      <td width="200">count</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">deep-image-96-angular/index_size_kb</td>
      <td width="280">3874116.0</td>
      <td width="200">kB</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### scann 1.4.2

#### fashion-mnist-784-euclidean

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
      <td width="400">fashion-mnist-784-euclidean/recall_at_10</td>
      <td width="200">越大越好</td>
      <td width="200">0.9837</td>
      <td width="200">0.98461</td>
      <td width="380">1.0009</td>
    </tr>
    <tr>
      <td width="400">fashion-mnist-784-euclidean/qps</td>
      <td width="200">越大越好</td>
      <td width="200">56147.59562738236</td>
      <td width="200">27616.307320758155</td>
      <td width="380">0.4919</td>
    </tr>
    <tr>
      <td width="400">fashion-mnist-784-euclidean/build_time_s</td>
      <td width="200">越小越好</td>
      <td width="200">6.768923759460449</td>
      <td width="200">9.905945777893066</td>
      <td width="380">0.6833</td>
    </tr>
    <tr>
      <td width="400">fashion-mnist-784-euclidean/candidates</td>
      <td width="200">仅展示</td>
      <td width="200">10.0</td>
      <td width="200">10.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">fashion-mnist-784-euclidean/index_size_kb</td>
      <td width="200">仅展示</td>
      <td width="200">229704.0</td>
      <td width="200">226104.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### sift-128-euclidean

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
      <td width="400">sift-128-euclidean/recall_at_10</td>
      <td width="200">越大越好</td>
      <td width="200">0.9607</td>
      <td width="200">0.96045</td>
      <td width="380">0.9997</td>
    </tr>
    <tr>
      <td width="400">sift-128-euclidean/qps</td>
      <td width="200">越大越好</td>
      <td width="200">42184.8859511657</td>
      <td width="200">25277.672645928367</td>
      <td width="380">0.5992</td>
    </tr>
    <tr>
      <td width="400">sift-128-euclidean/build_time_s</td>
      <td width="200">越小越好</td>
      <td width="200">9.05025053024292</td>
      <td width="200">12.909593105316162</td>
      <td width="380">0.701</td>
    </tr>
    <tr>
      <td width="400">sift-128-euclidean/candidates</td>
      <td width="200">仅展示</td>
      <td width="200">10.0</td>
      <td width="200">10.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">sift-128-euclidean/index_size_kb</td>
      <td width="200">仅展示</td>
      <td width="200">662996.0</td>
      <td width="200">664080.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### glove-100-angular

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
      <td width="400">glove-100-angular/recall_at_10</td>
      <td width="200">越大越好</td>
      <td width="200">0.97178</td>
      <td width="200">0.9717800000000001</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">glove-100-angular/qps</td>
      <td width="200">越大越好</td>
      <td width="200">41291.3794495313</td>
      <td width="200">22183.622015094752</td>
      <td width="380">0.5372</td>
    </tr>
    <tr>
      <td width="400">glove-100-angular/build_time_s</td>
      <td width="200">越小越好</td>
      <td width="200">6.09151029586792</td>
      <td width="200">7.4964940547943115</td>
      <td width="380">0.8126</td>
    </tr>
    <tr>
      <td width="400">glove-100-angular/candidates</td>
      <td width="200">仅展示</td>
      <td width="200">10.0</td>
      <td width="200">10.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">glove-100-angular/index_size_kb</td>
      <td width="200">仅展示</td>
      <td width="200">518452.0</td>
      <td width="200">525596.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### gist-960-euclidean

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
      <td width="400">gist-960-euclidean/recall_at_10</td>
      <td width="200">越大越好</td>
      <td width="200">0.9847</td>
      <td width="200">0.9857</td>
      <td width="380">1.001</td>
    </tr>
    <tr>
      <td width="400">gist-960-euclidean/qps</td>
      <td width="200">越大越好</td>
      <td width="200">5702.4396080094075</td>
      <td width="200">5461.134229481135</td>
      <td width="380">0.9577</td>
    </tr>
    <tr>
      <td width="400">gist-960-euclidean/build_time_s</td>
      <td width="200">越小越好</td>
      <td width="200">39.653669118881226</td>
      <td width="200">54.01877474784851</td>
      <td width="380">0.7341</td>
    </tr>
    <tr>
      <td width="400">gist-960-euclidean/candidates</td>
      <td width="200">仅展示</td>
      <td width="200">10.0</td>
      <td width="200">10.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gist-960-euclidean/index_size_kb</td>
      <td width="200">仅展示</td>
      <td width="200">4311344.0</td>
      <td width="200">4317216.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### deep-image-96-angular

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
      <td width="400">deep-image-96-angular/recall_at_10</td>
      <td width="200">越大越好</td>
      <td width="200">0.9675300000000001</td>
      <td width="200">0.9674800000000001</td>
      <td width="380">0.9999</td>
    </tr>
    <tr>
      <td width="400">deep-image-96-angular/qps</td>
      <td width="200">越大越好</td>
      <td width="200">35675.40625251705</td>
      <td width="200">15772.892822424636</td>
      <td width="380">0.4421</td>
    </tr>
    <tr>
      <td width="400">deep-image-96-angular/build_time_s</td>
      <td width="200">越小越好</td>
      <td width="200">35.68984031677246</td>
      <td width="200">40.87046670913696</td>
      <td width="380">0.8732</td>
    </tr>
    <tr>
      <td width="400">deep-image-96-angular/candidates</td>
      <td width="200">仅展示</td>
      <td width="200">10.0</td>
      <td width="200">10.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">deep-image-96-angular/index_size_kb</td>
      <td width="200">仅展示</td>
      <td width="200">3832688.0</td>
      <td width="200">3874116.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
