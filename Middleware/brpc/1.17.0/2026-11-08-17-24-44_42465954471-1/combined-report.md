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
      <td width="600">2026-11-08T09:10:28Z</td>
      <td width="600">2026-11-08T09:10:37Z</td>
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
      <td width="600">2026-11-08T09:09:53Z</td>
      <td width="600">2026-11-08T09:09:52Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 62731 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 140679 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 168058 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 166169 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 134765 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 159771 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169688 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 164183 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 364923 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 378517 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 346538 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 349037 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">1836.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p90_latency</td>
      <td width="280">1976.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p99_latency</td>
      <td width="280">2083.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p999_latency</td>
      <td width="280">2164.6</td>
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
      <td width="280">560400.0</td>
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
      <td width="280">3409.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p90_latency</td>
      <td width="280">3672.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p99_latency</td>
      <td width="280">3796.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p999_latency</td>
      <td width="280">3859.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_throughput</td>
      <td width="280">294.2486</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_qps</td>
      <td width="280">301310.5664</td>
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
      <td width="280">7864.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p90_latency</td>
      <td width="280">8572.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p99_latency</td>
      <td width="280">8962.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p999_latency</td>
      <td width="280">9103.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_throughput</td>
      <td width="280">505.99179999999996</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_qps</td>
      <td width="280">129533.90079999999</td>
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
      <td width="280">13634.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p90_latency</td>
      <td width="280">14555.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p99_latency</td>
      <td width="280">14925.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p999_latency</td>
      <td width="280">15091.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_throughput</td>
      <td width="280">590.4481999999999</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_qps</td>
      <td width="280">75577.36959999999</td>
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
      <td width="280">29717.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p90_latency</td>
      <td width="280">32994.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p99_latency</td>
      <td width="280">37119.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p999_latency</td>
      <td width="280">40422.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_throughput</td>
      <td width="280">1049.0242</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_qps</td>
      <td width="280">10742.007807999998</td>
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
      <td width="280">29829.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p90_latency</td>
      <td width="280">34657.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p99_latency</td>
      <td width="280">38383.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p999_latency</td>
      <td width="280">42420.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_throughput</td>
      <td width="280">1039.772</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_qps</td>
      <td width="280">5323.63264</td>
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
      <td width="280">24563.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p90_latency</td>
      <td width="280">26857.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p99_latency</td>
      <td width="280">30093.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p999_latency</td>
      <td width="280">37379.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_throughput</td>
      <td width="280">1308.682</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_qps</td>
      <td width="280">1308.682</td>
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
      <td width="280">28158.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p90_latency</td>
      <td width="280">33908.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p99_latency</td>
      <td width="280">38266.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p999_latency</td>
      <td width="280">40717.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_throughput</td>
      <td width="280">1146.598</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_qps</td>
      <td width="280">143.32475</td>
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
      <td width="280">3299.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p90_latency</td>
      <td width="280">3946.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p99_latency</td>
      <td width="280">4629.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_0B_p999_latency</td>
      <td width="280">5825.2</td>
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
      <td width="280">327400.0</td>
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
      <td width="280">5149.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p90_latency</td>
      <td width="280">6464.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p99_latency</td>
      <td width="280">7338.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_p999_latency</td>
      <td width="280">8438.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_throughput</td>
      <td width="280">194.09900000000002</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1024B_qps</td>
      <td width="280">198757.37600000002</td>
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
      <td width="280">7761.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p90_latency</td>
      <td width="280">9224.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p99_latency</td>
      <td width="280">10174.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_p999_latency</td>
      <td width="280">11257.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_throughput</td>
      <td width="280">511.4291999999999</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_4096B_qps</td>
      <td width="280">130925.87519999998</td>
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
      <td width="280">10562.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p90_latency</td>
      <td width="280">12452.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p99_latency</td>
      <td width="280">13688.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_p999_latency</td>
      <td width="280">22317.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_throughput</td>
      <td width="280">751.7716</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8192B_qps</td>
      <td width="280">96226.7648</td>
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
      <td width="280">25942.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p90_latency</td>
      <td width="280">30253.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p99_latency</td>
      <td width="280">33081.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_p999_latency</td>
      <td width="280">41716.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_throughput</td>
      <td width="280">1201.792</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_102400B_qps</td>
      <td width="280">12306.35008</td>
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
      <td width="280">25271.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p90_latency</td>
      <td width="280">29298.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p99_latency</td>
      <td width="280">32577.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_p999_latency</td>
      <td width="280">34681.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_throughput</td>
      <td width="280">1215.458</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_204800B_qps</td>
      <td width="280">6223.1449600000005</td>
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
      <td width="280">31776.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p90_latency</td>
      <td width="280">39019.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p99_latency</td>
      <td width="280">43573.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_p999_latency</td>
      <td width="280">46347.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_throughput</td>
      <td width="280">1012.3471999999999</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_1048576B_qps</td>
      <td width="280">1012.3471999999999</td>
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
      <td width="280">26185.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p90_latency</td>
      <td width="280">32822.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p99_latency</td>
      <td width="280">40072.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_p999_latency</td>
      <td width="280">46489.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_throughput</td>
      <td width="280">1178.4180000000001</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">attachment_8388608B_qps</td>
      <td width="280">147.30225000000002</td>
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
      <td width="200">1836.6</td>
      <td width="200">3299.6</td>
      <td width="380">0.5566</td>
    </tr>
    <tr>
      <td width="400">attachment_0B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">1976.4</td>
      <td width="200">3946.6</td>
      <td width="380">0.5008</td>
    </tr>
    <tr>
      <td width="400">attachment_0B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">2083.2</td>
      <td width="200">4629.2</td>
      <td width="380">0.45</td>
    </tr>
    <tr>
      <td width="400">attachment_0B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">2164.6</td>
      <td width="200">5825.2</td>
      <td width="380">0.3716</td>
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
      <td width="200">560400.0</td>
      <td width="200">327400.0</td>
      <td width="380">0.5842</td>
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
      <td width="200">3409.2</td>
      <td width="200">5149.4</td>
      <td width="380">0.6621</td>
    </tr>
    <tr>
      <td width="400">attachment_1024B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">3672.4</td>
      <td width="200">6464.4</td>
      <td width="380">0.5681</td>
    </tr>
    <tr>
      <td width="400">attachment_1024B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">3796.8</td>
      <td width="200">7338.2</td>
      <td width="380">0.5174</td>
    </tr>
    <tr>
      <td width="400">attachment_1024B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">3859.6</td>
      <td width="200">8438.4</td>
      <td width="380">0.4574</td>
    </tr>
    <tr>
      <td width="400">attachment_1024B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">294.2486</td>
      <td width="200">194.09900000000002</td>
      <td width="380">0.6596</td>
    </tr>
    <tr>
      <td width="400">attachment_1024B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">301310.5664</td>
      <td width="200">198757.37600000002</td>
      <td width="380">0.6596</td>
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
      <td width="200">7864.4</td>
      <td width="200">7761.2</td>
      <td width="380">1.0133</td>
    </tr>
    <tr>
      <td width="400">attachment_4096B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">8572.4</td>
      <td width="200">9224.6</td>
      <td width="380">0.9293</td>
    </tr>
    <tr>
      <td width="400">attachment_4096B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">8962.6</td>
      <td width="200">10174.2</td>
      <td width="380">0.8809</td>
    </tr>
    <tr>
      <td width="400">attachment_4096B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">9103.0</td>
      <td width="200">11257.4</td>
      <td width="380">0.8086</td>
    </tr>
    <tr>
      <td width="400">attachment_4096B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">505.99179999999996</td>
      <td width="200">511.4291999999999</td>
      <td width="380">1.0107</td>
    </tr>
    <tr>
      <td width="400">attachment_4096B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">129533.90079999999</td>
      <td width="200">130925.87519999998</td>
      <td width="380">1.0107</td>
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
      <td width="200">13634.8</td>
      <td width="200">10562.8</td>
      <td width="380">1.2908</td>
    </tr>
    <tr>
      <td width="400">attachment_8192B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">14555.2</td>
      <td width="200">12452.2</td>
      <td width="380">1.1689</td>
    </tr>
    <tr>
      <td width="400">attachment_8192B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">14925.2</td>
      <td width="200">13688.6</td>
      <td width="380">1.0903</td>
    </tr>
    <tr>
      <td width="400">attachment_8192B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">15091.4</td>
      <td width="200">22317.4</td>
      <td width="380">0.6762</td>
    </tr>
    <tr>
      <td width="400">attachment_8192B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">590.4481999999999</td>
      <td width="200">751.7716</td>
      <td width="380">1.2732</td>
    </tr>
    <tr>
      <td width="400">attachment_8192B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">75577.36959999999</td>
      <td width="200">96226.7648</td>
      <td width="380">1.2732</td>
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
      <td width="200">29717.8</td>
      <td width="200">25942.2</td>
      <td width="380">1.1455</td>
    </tr>
    <tr>
      <td width="400">attachment_102400B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">32994.6</td>
      <td width="200">30253.2</td>
      <td width="380">1.0906</td>
    </tr>
    <tr>
      <td width="400">attachment_102400B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">37119.8</td>
      <td width="200">33081.6</td>
      <td width="380">1.1221</td>
    </tr>
    <tr>
      <td width="400">attachment_102400B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">40422.6</td>
      <td width="200">41716.6</td>
      <td width="380">0.969</td>
    </tr>
    <tr>
      <td width="400">attachment_102400B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1049.0242</td>
      <td width="200">1201.792</td>
      <td width="380">1.1456</td>
    </tr>
    <tr>
      <td width="400">attachment_102400B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">10742.007807999998</td>
      <td width="200">12306.35008</td>
      <td width="380">1.1456</td>
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
      <td width="200">29829.8</td>
      <td width="200">25271.8</td>
      <td width="380">1.1804</td>
    </tr>
    <tr>
      <td width="400">attachment_204800B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">34657.6</td>
      <td width="200">29298.0</td>
      <td width="380">1.1829</td>
    </tr>
    <tr>
      <td width="400">attachment_204800B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">38383.6</td>
      <td width="200">32577.2</td>
      <td width="380">1.1782</td>
    </tr>
    <tr>
      <td width="400">attachment_204800B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">42420.8</td>
      <td width="200">34681.4</td>
      <td width="380">1.2232</td>
    </tr>
    <tr>
      <td width="400">attachment_204800B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1039.772</td>
      <td width="200">1215.458</td>
      <td width="380">1.169</td>
    </tr>
    <tr>
      <td width="400">attachment_204800B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">5323.63264</td>
      <td width="200">6223.1449600000005</td>
      <td width="380">1.169</td>
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
      <td width="200">24563.4</td>
      <td width="200">31776.2</td>
      <td width="380">0.773</td>
    </tr>
    <tr>
      <td width="400">attachment_1048576B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">26857.6</td>
      <td width="200">39019.0</td>
      <td width="380">0.6883</td>
    </tr>
    <tr>
      <td width="400">attachment_1048576B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">30093.4</td>
      <td width="200">43573.0</td>
      <td width="380">0.6906</td>
    </tr>
    <tr>
      <td width="400">attachment_1048576B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">37379.6</td>
      <td width="200">46347.2</td>
      <td width="380">0.8065</td>
    </tr>
    <tr>
      <td width="400">attachment_1048576B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1308.682</td>
      <td width="200">1012.3471999999999</td>
      <td width="380">0.7736</td>
    </tr>
    <tr>
      <td width="400">attachment_1048576B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">1308.682</td>
      <td width="200">1012.3471999999999</td>
      <td width="380">0.7736</td>
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
      <td width="200">28158.0</td>
      <td width="200">26185.0</td>
      <td width="380">1.0753</td>
    </tr>
    <tr>
      <td width="400">attachment_8388608B_p90_latency</td>
      <td width="200">越小越好</td>
      <td width="200">33908.6</td>
      <td width="200">32822.2</td>
      <td width="380">1.0331</td>
    </tr>
    <tr>
      <td width="400">attachment_8388608B_p99_latency</td>
      <td width="200">越小越好</td>
      <td width="200">38266.8</td>
      <td width="200">40072.8</td>
      <td width="380">0.9549</td>
    </tr>
    <tr>
      <td width="400">attachment_8388608B_p999_latency</td>
      <td width="200">越小越好</td>
      <td width="200">40717.8</td>
      <td width="200">46489.0</td>
      <td width="380">0.8759</td>
    </tr>
    <tr>
      <td width="400">attachment_8388608B_throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1146.598</td>
      <td width="200">1178.4180000000001</td>
      <td width="380">1.0278</td>
    </tr>
    <tr>
      <td width="400">attachment_8388608B_qps</td>
      <td width="200">越大越好</td>
      <td width="200">143.32475</td>
      <td width="200">147.30225000000002</td>
      <td width="380">1.0278</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
