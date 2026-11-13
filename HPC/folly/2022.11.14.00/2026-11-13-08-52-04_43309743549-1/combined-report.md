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
      <td width="160">2022.11.14.00</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">folly</td>
      <td width="160">2022.11.14.00</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### folly 2022.11.14.00

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
      <td width="600">2022.11.14.00</td>
      <td width="600">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">2022.11.14.00</td>
      <td width="600">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-12T21:43:46Z</td>
      <td width="600">2026-11-12T21:43:58Z</td>
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
      <td width="600">2026-11-12T21:40:31Z</td>
      <td width="600">2026-11-12T21:40:31Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 175995 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 176902 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 176920 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 176614 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193481 MB<br>node 4 free: 176842 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193523 MB<br>node 5 free: 177000 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 76327 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 75724 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 379388 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 383595 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 379604 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 384662 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">AccLibBenchmark</td>
      <td width="880">unknown</td>
    </tr>
    <tr>
      <td width="500">fbthrift</td>
      <td width="880">2022.11.14.00</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### folly 2022.11.14.00

##### binary payload

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
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">30.31</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">4076.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">5772.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">138.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">314.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">124165.9</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">29.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">10451.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">17400.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">145.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">284.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">120310.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">162.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">7535.39</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">9821.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1659.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">4880.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">663927.44</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">159.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">19117.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">23710.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">99.9999983011399</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">1</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1620.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">4919.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">654033.31</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">57.93</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">42736.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117209.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.9988105590513</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">254</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">766.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1407.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">237270.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">135.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">45986.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">126529.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1795.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3303.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">556092.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">58.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43419.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117988.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1499.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1376.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">238116.06</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">112.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">56189.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">129208.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2741.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2783.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">461012.41</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">88.47</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5613.91</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">7794.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">143.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">259.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">90593.28</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">102.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">12019.79</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">24206.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">146.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">277.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">104852.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">625.04</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">7817.74</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10038.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1649.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">3330.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">640037.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">667.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">18296.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">24687.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1599.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3929.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">683424.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">194.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">52178.53</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">116484.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99861236035831</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">249</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">556.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1113.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">199376.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">438.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">57538.71</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">125242.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1281.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2543.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">449006.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">285.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">35170.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117232.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1833.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1508.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">292736.46</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">484.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">51548.06</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">127248.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2863.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2833.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">496405.46</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">320.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6102.93</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9874.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">134.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">237.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">81928.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">295.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">16548.56</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">21832.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">140.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">207.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">75546.66</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2272.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8594.62</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10642.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1733.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1872.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">581709.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">2410.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">20252.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">25061.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1740.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2242.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">617181.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2147.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">18190.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">112774.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2156.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3410.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">549819.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2249.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">43411.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">130365.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2040.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3436.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">575750.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1892.25</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">20660.55</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">116606.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">3857.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2862.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">484416.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2128.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">45873.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128222.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3320.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3158.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">544978.6</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">568.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6871.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">10992.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">135.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">253.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">72776.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">543.39</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">17974.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">23830.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">128.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">199.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">69554.38</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">4023.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9708.15</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">11931.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1747.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1625.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">515012.24</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">3899.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">25048.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">74114.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1568.6</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2616.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">499092.44</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4695.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">16639.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">70161.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2657.41</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4995.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">600984.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3710.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">52660.93</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">164821.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1794.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4019.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">474985.06</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3810.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">20497.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">115219.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">4116.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3430.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">487796.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3937.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">49626.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">129384.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3491.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3389.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">503953.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">903.54</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8647.15</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13780.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">133.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">229.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">57826.53</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">844.36</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">23133.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">34846.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">146.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">183.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">54039.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6816.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11460.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15525.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1797.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1645.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">436241.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6768.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28856.3</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">37130.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1790.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1683.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">433210.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">8338.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">18739.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">52630.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2927.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3173.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">533677.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10717.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">36466.19</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">110318.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3252.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">5596.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">685929.93</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">8183.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">19115.06</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">113599.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">4512.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3996.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">523730.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">8418.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">46439.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136853.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3983.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4426.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">538759.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### i32 int

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
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">224.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">4402.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">6297.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">139.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">264.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">115081.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">234.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">10466.62</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">17319.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">146.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">256.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">120208.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1131.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8637.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">13607.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1700.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1862.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">579208.3</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">785.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">31399.97</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">95561.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">99.99970446888888</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">107</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1083.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3649.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">402287.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">369.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">54501.9</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">116675.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">517.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1274.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">189330.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1394.23</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">35143.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">127741.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2825.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4913.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">713847.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">654.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">30673.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117533.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2979.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1825.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">335127.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">901.42</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">55996.33</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">129185.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99849776416029</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">624</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2516.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2755.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">461527.34</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### i64 long

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
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">110.52</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">4474.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8417.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">138.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">277.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">113171.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">118.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">10351.18</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">17370.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">149.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">230.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">121708.46</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">568.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8589.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10153.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1700.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1559.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">582577.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">511.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">24096.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">114044.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1115.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3861.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">524053.27</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">498.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">20179.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">114394.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1969.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3330.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">510135.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">524.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">47032.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">172283.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1927.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4532.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">537154.1</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">268.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">37674.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">116259.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99899526831905</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">249</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1535.12</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3364.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">275360.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">504.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">50321.89</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128704.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3141.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2847.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">516676.32</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### double

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
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">49.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5006.7</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8372.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">139.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">228.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">101027.47</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">53.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">11577.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">23254.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">145.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">229.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">108539.64</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">166.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14787.59</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">34517.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">799.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">4147.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">341607.07</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">125.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">49179.87</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">96304.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">99.99972743295186</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">63</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">645.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">4414.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">256816.84</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">125.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">39198.29</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">81623.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">824.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4392.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">257223.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">129.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">95062.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">193300.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">850.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4443.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">265851.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">129.17</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">39044.18</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117412.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1739.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1833.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">264546.34</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">229.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">53725.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">140364.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2542.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2971.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">469212.09</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### list<i32>

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
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">343.95</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5678.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9071.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">132.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">272.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">88051.84</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">391.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">12478.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">16687.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">141.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">243.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">100180.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2104.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9277.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10765.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1791.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1511.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">538869.1</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1033.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">47248.55</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">88849.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">705.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">4486.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">264578.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2214.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">17640.74</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">67892.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2389.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4965.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">566786.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2317.89</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">42130.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">157700.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2288.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4747.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">593380.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1386.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">28199.92</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">118807.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2162.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2171.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">354931.59</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1785.43</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">54726.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">127850.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2745.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2842.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">457071.27</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### list<i64>

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
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">223.62</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">4421.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">6102.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">141.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">279.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">114494.0</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">229.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">10740.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">17613.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">151.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">255.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">117344.66</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1051.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9293.97</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10421.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1720.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1652.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">538341.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1171.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">20839.07</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">23148.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1704.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2144.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">600012.79</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1468.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">13478.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">77508.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2985.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4835.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">751876.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">997.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">50071.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">124621.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1645.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3103.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">510961.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">482.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">41441.59</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117193.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1469.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1406.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">247256.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">897.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">55523.71</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128248.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3045.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2725.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">459324.54</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### string

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
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">537.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7269.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">11759.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">131.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">259.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">68782.9</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">537.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">18161.38</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">24732.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">139.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">255.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">68835.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">4437.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8802.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10679.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1797.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2195.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">567977.9</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">4489.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">21750.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">26460.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1767.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2218.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">574689.48</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2641.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">29609.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">115779.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1188.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2115.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">338084.71</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">4375.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">44659.92</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">126467.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2088.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3657.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">560068.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2877.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">27176.7</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">119759.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2638.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2334.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">368271.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3991.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">48945.79</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">126601.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3344.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3390.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">510863.59</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### list<string>

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
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">910.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8580.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13477.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">138.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">225.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">58276.44</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">984.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">19841.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">25635.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">151.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">230.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">63004.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6194.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12611.91</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15125.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1786.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1742.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">396427.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6292.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">31038.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">37949.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1794.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1756.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">402749.14</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">9983.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">15658.65</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">85323.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">3212.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4895.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">638949.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10800.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">36172.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">103988.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3355.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">5354.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">691223.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">8254.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">18932.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">113253.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">4764.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4240.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">528263.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10266.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">38067.12</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">121942.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">5734.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">5714.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">657056.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### set<string>

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
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">909.39</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8592.35</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13586.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">142.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">223.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">58201.01</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">951.98</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">20518.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">25846.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">146.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">197.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">60926.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6226.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12545.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">14826.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1796.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1532.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">398519.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6773.31</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28833.56</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">34473.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1782.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1632.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">433491.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">10644.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">14677.12</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">16268.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">3485.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3385.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">681237.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">9796.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">39867.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">41326.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3376.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2934.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">626961.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">8782.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">17808.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">113071.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">4778.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4075.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">562109.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10704.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">36481.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">121376.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">5487.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">5258.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">685110.14</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### map<string, i64>

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
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">333.93</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5850.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9419.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">144.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">283.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">85485.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">346.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14109.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">19467.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">153.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">273.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">88598.01</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2309.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8455.08</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">9863.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1761.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2008.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">591311.53</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">2046.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">23853.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">25753.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1745.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1808.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">523946.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2806.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">13919.67</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">49915.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">3045.17</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3930.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">718537.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2229.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">43821.18</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128302.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2023.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3516.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">570674.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1352.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">28915.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">119464.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2317.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2105.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">346137.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2013.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">48520.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">129175.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3222.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3203.59</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">515422.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### folly 2022.11.14.00

##### binary payload

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
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">28.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">4289.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">6071.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">150.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">229.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">117938.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">29.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">10249.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">17073.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">151.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">234.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">122695.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">106.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11463.08</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">77332.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1574.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2914.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">436484.14</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">95.46</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">31975.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">34520.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1676.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1936.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">391023.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">39.59</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">63821.67</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120249.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">632.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1469.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">162173.67</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">84.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">75445.07</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131270.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1335.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3254.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">344149.38</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">35.49</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">71115.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120511.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">954.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1399.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">145351.33</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">86.17</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">71316.39</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133407.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2560.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3142.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">352950.63</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">93.67</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5267.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13752.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">141.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">368.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">95918.41</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">51.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">23626.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">38401.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">151.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">184.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">53219.31</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">363.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13454.3</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">14757.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">99.99999402381087</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">2</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1668.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1794.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">371846.01</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">382.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">32694.67</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">86854.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1643.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2025.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">391251.41</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">157.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">64158.37</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120412.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">653.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1468.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">161050.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">358.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">70209.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132928.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1501.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3320.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">367051.93</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">139.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">72155.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120197.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99421094208098</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">745</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">875.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1284.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">142981.79</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">297.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">84999.49</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131441.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1921.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2835.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">304620.9</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">238.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8180.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14032.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">140.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">238.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">61133.59</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">236.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">20691.27</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">29256.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">141.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">205.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">60419.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1447.64</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13491.45</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15531.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1750.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1939.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">370595.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1320.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">36999.49</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">126466.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1022.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3099.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">337955.63</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">976.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40044.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123020.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1088.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2266.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">249879.64</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1641.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">59521.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">142232.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2042.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3911.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">420118.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">966.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40484.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120640.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1879.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2212.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">247391.59</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1435.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">68022.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132270.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2789.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3286.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">367552.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">529.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7373.38</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14313.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">139.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">246.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">67822.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">660.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14794.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">30370.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">138.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">299.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">84498.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">3139.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12441.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">16550.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1760.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2147.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">401888.73</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">3352.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">29132.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">111941.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1509.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3749.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">429108.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1915.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40810.43</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122682.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1025.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2221.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">245223.28</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3590.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">54419.97</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">143542.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2486.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4324.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">459596.63</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1905.59</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">41080.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121163.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2012.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2228.54</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">243915.04</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2642.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">73898.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132694.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2602.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3221.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">338222.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">878.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8897.77</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">16571.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">129.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">212.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">56204.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">1015.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">19237.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">36598.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">128.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">255.54</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">64985.51</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6647.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11752.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">22760.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1626.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2948.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">425445.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6826.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28614.45</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">104064.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1477.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3411.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">436875.64</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4243.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">36825.61</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122940.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1495.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2529.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">271572.93</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">7278.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">53667.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">141334.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2692.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4557.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">465805.41</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3730.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">41895.35</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122937.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2060.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2232.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">238769.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5701.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">68483.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">130601.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2964.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3226.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">364908.74</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### i32 int

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
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">146.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6722.53</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13853.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">145.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">272.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">75212.51</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">155.07</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15806.67</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">35569.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">145.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">287.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">79394.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">772.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12655.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15490.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1690.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2227.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">395312.59</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">742.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">32877.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">36990.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1686.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1977.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">380382.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">334.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">60425.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120421.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">761.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1610.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">171055.28</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">731.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">67652.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133896.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1595.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3539.59</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">374674.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">296.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">68376.08</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">119834.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">976.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1358.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">151699.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">650.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">78094.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131858.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2292.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3101.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">332809.64</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### i64 long

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
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">96.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5109.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">7913.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">144.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">374.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">98684.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">94.93</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">12920.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">30753.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">145.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">366.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">97205.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">385.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12660.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">16055.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1619.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2411.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">395124.24</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">307.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">39716.87</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">121042.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">907.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2821.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">314890.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">152.71</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">65192.71</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120229.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">592.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1457.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">156378.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">326.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">77457.11</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131331.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1138.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3109.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">334316.21</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">141.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">71159.48</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">119863.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99809489853612</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">249</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">895.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1353.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">145221.34</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">306.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">82648.93</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131393.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99778938484567</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">624</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1967.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2970.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">313631.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### double

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
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">46.04</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5349.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13667.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">143.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">330.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">94293.24</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">38.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15764.48</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">35590.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">146.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">258.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">79628.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">211.71</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11541.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15110.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1699.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2886.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">433582.71</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">210.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28954.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">36915.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1684.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2979.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">431851.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">77.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">65243.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120321.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99651630439497</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">498</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">613.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1464.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">158829.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">159.17</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">79591.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131553.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1159.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3052.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">325970.67</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">69.95</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">72337.79</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120218.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99806888182208</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">249</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">871.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1343.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">143264.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">147.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">84029.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">130676.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99877376770446</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">334</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1798.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2753.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">302639.69</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### list<i32>

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
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">234.47</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8331.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14425.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">141.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">220.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">60023.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">210.65</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">23183.07</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">29573.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">144.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">177.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">53927.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1587.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12303.16</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">18403.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1615.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2970.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">406399.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1635.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">29874.39</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">113779.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1460.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3420.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">418701.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1050.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">37196.06</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121451.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1152.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2336.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">268948.42</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1545.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">63163.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">140168.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1842.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3636.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">395735.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">896.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43619.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123219.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1722.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2017.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">229444.31</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1333.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">73239.33</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133002.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2539.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3243.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">341450.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### list<i64>

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
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">153.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6412.16</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14034.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">145.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">306.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">78747.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">174.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14086.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">32882.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">144.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">329.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">89150.69</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">842.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11592.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">16714.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1687.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2599.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">431611.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">903.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">27020.59</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">113686.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1510.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3313.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">462802.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">513.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">39393.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">118961.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99895269014206</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">248</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1408.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2524.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">263105.2</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">740.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">67485.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133561.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1631.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3586.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">379247.98</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">294.38</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">68847.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120224.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1000.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1422.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">150724.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">643.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">78436.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133860.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2285.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3196.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">329500.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### string

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
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">517.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7545.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14664.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">130.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">239.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">66278.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">637.32</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15324.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">29211.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">137.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">238.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">81577.27</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2812.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13886.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">16118.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1777.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1845.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">360050.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">3297.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">29621.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">109591.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1451.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3597.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">422018.58</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2057.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">37977.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123286.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1328.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2434.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">263347.0</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3150.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">62019.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">141329.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1910.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3804.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">403311.42</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1821.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">42910.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122554.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1655.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2174.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">233144.32</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2687.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">72703.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132727.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2689.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3338.59</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">344055.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### list<string>

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
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">858.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">9103.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">16822.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">126.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">233.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">54937.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">892.67</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">21884.43</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">39013.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">127.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">236.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">57130.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">5758.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13566.36</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">18573.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1753.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2047.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">368568.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">5596.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">34906.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">45059.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1711.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1936.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">358148.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4079.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">38319.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124036.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1437.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2477.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">261100.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">7207.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">54210.43</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">144262.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2766.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4541.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">461301.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3853.24</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40616.16</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122775.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1860.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2363.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">246607.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5283.22</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">73923.9</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132361.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2432.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3250.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">338126.31</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### set<string>

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
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">914.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8541.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">16141.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">128.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">240.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">58546.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">856.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">22810.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">37800.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">130.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">207.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">54809.84</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">5564.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14039.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">18645.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1777.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1733.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">356153.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6538.61</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">29873.5</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">46642.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1695.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2453.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">418471.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4227.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">36986.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123184.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1389.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2553.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">270577.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">6231.46</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">62736.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">138383.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1794.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3823.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">398813.42</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3495.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">44767.19</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123459.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1889.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2174.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">223705.42</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5275.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">74063.37</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133190.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2727.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3323.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">337604.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### map<string, i64>

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
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">273.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7152.72</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13848.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">138.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">290.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">69908.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">269.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">18088.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">28946.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">141.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">293.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">69118.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1547.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12621.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">95271.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1529.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2837.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">396153.91</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1697.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28786.08</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">116517.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1420.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3571.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">434510.02</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1141.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">34232.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122849.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1523.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2677.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">292330.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1592.32</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">61349.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">142318.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1973.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3834.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">407634.53</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">923.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">42390.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122070.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1829.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2195.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">236442.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1338.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">73005.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132502.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2501.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3263.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">342551.66</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### folly 2022.11.14.00

#### binary payload

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
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">30.31</td>
      <td width="200">28.79</td>
      <td width="380">0.9499</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">4076.1</td>
      <td width="200">4289.68</td>
      <td width="380">0.9502</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">5772.0</td>
      <td width="200">6071.0</td>
      <td width="380">0.9507</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">138.94</td>
      <td width="200">150.32</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">314.88</td>
      <td width="200">229.81</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">124165.9</td>
      <td width="200">117938.19</td>
      <td width="380">0.9498</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">29.37</td>
      <td width="200">29.96</td>
      <td width="380">1.0201</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">10451.86</td>
      <td width="200">10249.47</td>
      <td width="380">1.0197</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">17400.0</td>
      <td width="200">17073.0</td>
      <td width="380">1.0192</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">145.42</td>
      <td width="200">151.2</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">284.94</td>
      <td width="200">234.65</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">120310.72</td>
      <td width="200">122695.8</td>
      <td width="380">1.0198</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">162.09</td>
      <td width="200">106.56</td>
      <td width="380">0.6574</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">7535.39</td>
      <td width="200">11463.08</td>
      <td width="380">0.6574</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">9821.0</td>
      <td width="200">77332.0</td>
      <td width="380">0.127</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1659.57</td>
      <td width="200">1574.1</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4880.21</td>
      <td width="200">2914.22</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">663927.44</td>
      <td width="200">436484.14</td>
      <td width="380">0.6574</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">159.68</td>
      <td width="200">95.46</td>
      <td width="380">0.5978</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">19117.14</td>
      <td width="200">31975.09</td>
      <td width="380">0.5979</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">23710.0</td>
      <td width="200">34520.0</td>
      <td width="380">0.6868</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.9999983011399</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">1</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1620.5</td>
      <td width="200">1676.46</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4919.79</td>
      <td width="200">1936.33</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">654033.31</td>
      <td width="200">391023.78</td>
      <td width="380">0.5979</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">57.93</td>
      <td width="200">39.59</td>
      <td width="380">0.6834</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">42736.58</td>
      <td width="200">63821.67</td>
      <td width="380">0.6696</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">117209.0</td>
      <td width="200">120249.0</td>
      <td width="380">0.9747</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.9988105590513</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">254</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">766.99</td>
      <td width="200">632.96</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1407.02</td>
      <td width="200">1469.92</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">237270.18</td>
      <td width="200">162173.67</td>
      <td width="380">0.6835</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">135.76</td>
      <td width="200">84.02</td>
      <td width="380">0.6189</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">45986.63</td>
      <td width="200">75445.07</td>
      <td width="380">0.6095</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">126529.0</td>
      <td width="200">131270.0</td>
      <td width="380">0.9639</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1795.26</td>
      <td width="200">1335.19</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3303.11</td>
      <td width="200">3254.23</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">556092.82</td>
      <td width="200">344149.38</td>
      <td width="380">0.6189</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">58.13</td>
      <td width="200">35.49</td>
      <td width="380">0.6105</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">43419.46</td>
      <td width="200">71115.86</td>
      <td width="380">0.6105</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">117988.0</td>
      <td width="200">120511.0</td>
      <td width="380">0.9791</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1499.36</td>
      <td width="200">954.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1376.04</td>
      <td width="200">1399.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">238116.06</td>
      <td width="200">145351.33</td>
      <td width="380">0.6104</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">112.55</td>
      <td width="200">86.17</td>
      <td width="380">0.7656</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">56189.6</td>
      <td width="200">71316.39</td>
      <td width="380">0.7879</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">129208.0</td>
      <td width="200">133407.0</td>
      <td width="380">0.9685</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2741.74</td>
      <td width="200">2560.75</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2783.35</td>
      <td width="200">3142.42</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">461012.41</td>
      <td width="200">352950.63</td>
      <td width="380">0.7656</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">88.47</td>
      <td width="200">93.67</td>
      <td width="380">1.0588</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">5613.91</td>
      <td width="200">5267.73</td>
      <td width="380">1.0657</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">7794.0</td>
      <td width="200">13752.0</td>
      <td width="380">0.5668</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">143.53</td>
      <td width="200">141.1</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">259.9</td>
      <td width="200">368.13</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">90593.28</td>
      <td width="200">95918.41</td>
      <td width="380">1.0588</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">102.4</td>
      <td width="200">51.97</td>
      <td width="380">0.5075</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">12019.79</td>
      <td width="200">23626.86</td>
      <td width="380">0.5087</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">24206.0</td>
      <td width="200">38401.0</td>
      <td width="380">0.6303</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">146.09</td>
      <td width="200">151.64</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">277.88</td>
      <td width="200">184.66</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">104852.76</td>
      <td width="200">53219.31</td>
      <td width="380">0.5076</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">625.04</td>
      <td width="200">363.13</td>
      <td width="380">0.581</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">7817.74</td>
      <td width="200">13454.3</td>
      <td width="380">0.5811</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">10038.0</td>
      <td width="200">14757.0</td>
      <td width="380">0.6802</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99999402381087</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">2</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1649.0</td>
      <td width="200">1668.89</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3330.88</td>
      <td width="200">1794.43</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">640037.19</td>
      <td width="200">371846.01</td>
      <td width="380">0.581</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">667.41</td>
      <td width="200">382.08</td>
      <td width="380">0.5725</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">18296.44</td>
      <td width="200">32694.67</td>
      <td width="380">0.5596</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">24687.0</td>
      <td width="200">86854.0</td>
      <td width="380">0.2842</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1599.34</td>
      <td width="200">1643.55</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3929.49</td>
      <td width="200">2025.69</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">683424.23</td>
      <td width="200">391251.41</td>
      <td width="380">0.5725</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">194.7</td>
      <td width="200">157.28</td>
      <td width="380">0.8078</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">52178.53</td>
      <td width="200">64158.37</td>
      <td width="380">0.8133</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">116484.0</td>
      <td width="200">120412.0</td>
      <td width="380">0.9674</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.99861236035831</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">249</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">556.67</td>
      <td width="200">653.47</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1113.92</td>
      <td width="200">1468.26</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">199376.57</td>
      <td width="200">161050.29</td>
      <td width="380">0.8078</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">438.48</td>
      <td width="200">358.45</td>
      <td width="380">0.8175</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">57538.71</td>
      <td width="200">70209.86</td>
      <td width="380">0.8195</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">125242.0</td>
      <td width="200">132928.0</td>
      <td width="380">0.9422</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1281.67</td>
      <td width="200">1501.1</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2543.46</td>
      <td width="200">3320.34</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">449006.26</td>
      <td width="200">367051.93</td>
      <td width="380">0.8175</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">285.88</td>
      <td width="200">139.63</td>
      <td width="380">0.4884</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">35170.47</td>
      <td width="200">72155.66</td>
      <td width="380">0.4874</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">117232.0</td>
      <td width="200">120197.0</td>
      <td width="380">0.9753</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99421094208098</td>
      <td width="380">0.9999</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">745</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1833.01</td>
      <td width="200">875.73</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1508.36</td>
      <td width="200">1284.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">292736.46</td>
      <td width="200">142981.79</td>
      <td width="380">0.4884</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">484.77</td>
      <td width="200">297.48</td>
      <td width="380">0.6137</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">51548.06</td>
      <td width="200">84999.49</td>
      <td width="380">0.6065</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">127248.0</td>
      <td width="200">131441.0</td>
      <td width="380">0.9681</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2863.83</td>
      <td width="200">1921.25</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2833.62</td>
      <td width="200">2835.15</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">496405.46</td>
      <td width="200">304620.9</td>
      <td width="380">0.6137</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">320.03</td>
      <td width="200">238.8</td>
      <td width="380">0.7462</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">6102.93</td>
      <td width="200">8180.34</td>
      <td width="380">0.746</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">9874.0</td>
      <td width="200">14032.0</td>
      <td width="380">0.7037</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">134.53</td>
      <td width="200">140.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">237.91</td>
      <td width="200">238.69</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">81928.87</td>
      <td width="200">61133.59</td>
      <td width="380">0.7462</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">295.1</td>
      <td width="200">236.01</td>
      <td width="380">0.7998</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">16548.56</td>
      <td width="200">20691.27</td>
      <td width="380">0.7998</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">21832.0</td>
      <td width="200">29256.0</td>
      <td width="380">0.7462</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">140.35</td>
      <td width="200">141.23</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">207.55</td>
      <td width="200">205.87</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">75546.66</td>
      <td width="200">60419.68</td>
      <td width="380">0.7998</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2272.3</td>
      <td width="200">1447.64</td>
      <td width="380">0.6371</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8594.62</td>
      <td width="200">13491.45</td>
      <td width="380">0.637</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">10642.0</td>
      <td width="200">15531.0</td>
      <td width="380">0.6852</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1733.53</td>
      <td width="200">1750.4</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1872.57</td>
      <td width="200">1939.55</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">581709.89</td>
      <td width="200">370595.86</td>
      <td width="380">0.6371</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2410.87</td>
      <td width="200">1320.14</td>
      <td width="380">0.5476</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">20252.41</td>
      <td width="200">36999.49</td>
      <td width="380">0.5474</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">25061.0</td>
      <td width="200">126466.0</td>
      <td width="380">0.1982</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1740.02</td>
      <td width="200">1022.18</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2242.87</td>
      <td width="200">3099.93</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">617181.81</td>
      <td width="200">337955.63</td>
      <td width="380">0.5476</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2147.73</td>
      <td width="200">976.09</td>
      <td width="380">0.4545</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">18190.44</td>
      <td width="200">40044.51</td>
      <td width="380">0.4543</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">112774.0</td>
      <td width="200">123020.0</td>
      <td width="380">0.9167</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2156.13</td>
      <td width="200">1088.7</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3410.25</td>
      <td width="200">2266.53</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">549819.16</td>
      <td width="200">249879.64</td>
      <td width="380">0.4545</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2249.03</td>
      <td width="200">1641.09</td>
      <td width="380">0.7297</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">43411.81</td>
      <td width="200">59521.88</td>
      <td width="380">0.7293</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">130365.0</td>
      <td width="200">142232.0</td>
      <td width="380">0.9166</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2040.65</td>
      <td width="200">2042.22</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3436.02</td>
      <td width="200">3911.14</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">575750.97</td>
      <td width="200">420118.26</td>
      <td width="380">0.7297</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1892.25</td>
      <td width="200">966.37</td>
      <td width="380">0.5107</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">20660.55</td>
      <td width="200">40484.81</td>
      <td width="380">0.5103</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">116606.0</td>
      <td width="200">120640.0</td>
      <td width="380">0.9666</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3857.1</td>
      <td width="200">1879.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2862.26</td>
      <td width="200">2212.07</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">484416.76</td>
      <td width="200">247391.59</td>
      <td width="380">0.5107</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2128.82</td>
      <td width="200">1435.75</td>
      <td width="380">0.6744</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">45873.0</td>
      <td width="200">68022.73</td>
      <td width="380">0.6744</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">128222.0</td>
      <td width="200">132270.0</td>
      <td width="380">0.9694</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3320.97</td>
      <td width="200">2789.16</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3158.78</td>
      <td width="200">3286.04</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">544978.6</td>
      <td width="200">367552.82</td>
      <td width="380">0.6744</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">568.56</td>
      <td width="200">529.86</td>
      <td width="380">0.9319</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">6871.81</td>
      <td width="200">7373.38</td>
      <td width="380">0.932</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">10992.0</td>
      <td width="200">14313.0</td>
      <td width="380">0.768</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">135.04</td>
      <td width="200">139.94</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">253.53</td>
      <td width="200">246.58</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">72776.12</td>
      <td width="200">67822.29</td>
      <td width="380">0.9319</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">543.39</td>
      <td width="200">660.14</td>
      <td width="380">1.2149</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">17974.44</td>
      <td width="200">14794.63</td>
      <td width="380">1.2149</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">23830.0</td>
      <td width="200">30370.0</td>
      <td width="380">0.7847</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">128.03</td>
      <td width="200">138.57</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">199.42</td>
      <td width="200">299.35</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">69554.38</td>
      <td width="200">84498.5</td>
      <td width="380">1.2149</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4023.53</td>
      <td width="200">3139.76</td>
      <td width="380">0.7803</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">9708.15</td>
      <td width="200">12441.24</td>
      <td width="380">0.7803</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">11931.0</td>
      <td width="200">16550.0</td>
      <td width="380">0.7209</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1747.35</td>
      <td width="200">1760.7</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1625.52</td>
      <td width="200">2147.42</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">515012.24</td>
      <td width="200">401888.73</td>
      <td width="380">0.7803</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">3899.16</td>
      <td width="200">3352.41</td>
      <td width="380">0.8598</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">25048.51</td>
      <td width="200">29132.31</td>
      <td width="380">0.8598</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">74114.0</td>
      <td width="200">111941.0</td>
      <td width="380">0.6621</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1568.6</td>
      <td width="200">1509.19</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2616.32</td>
      <td width="200">3749.4</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">499092.44</td>
      <td width="200">429108.89</td>
      <td width="380">0.8598</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4695.19</td>
      <td width="200">1915.81</td>
      <td width="380">0.408</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">16639.54</td>
      <td width="200">40810.43</td>
      <td width="380">0.4077</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">70161.0</td>
      <td width="200">122682.0</td>
      <td width="380">0.5719</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2657.41</td>
      <td width="200">1025.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4995.07</td>
      <td width="200">2221.96</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">600984.92</td>
      <td width="200">245223.28</td>
      <td width="380">0.408</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">3710.82</td>
      <td width="200">3590.6</td>
      <td width="380">0.9676</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">52660.93</td>
      <td width="200">54419.97</td>
      <td width="380">0.9677</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">164821.0</td>
      <td width="200">143542.0</td>
      <td width="380">1.1482</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1794.94</td>
      <td width="200">2486.66</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4019.7</td>
      <td width="200">4324.36</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">474985.06</td>
      <td width="200">459596.63</td>
      <td width="380">0.9676</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">3810.91</td>
      <td width="200">1905.59</td>
      <td width="380">0.5</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">20497.17</td>
      <td width="200">41080.26</td>
      <td width="380">0.499</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">115219.0</td>
      <td width="200">121163.0</td>
      <td width="380">0.9509</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4116.5</td>
      <td width="200">2012.02</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3430.3</td>
      <td width="200">2228.54</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">487796.86</td>
      <td width="200">243915.04</td>
      <td width="380">0.5</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">3937.14</td>
      <td width="200">2642.37</td>
      <td width="380">0.6711</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">49626.4</td>
      <td width="200">73898.88</td>
      <td width="380">0.6715</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">129384.0</td>
      <td width="200">132694.0</td>
      <td width="380">0.9751</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3491.64</td>
      <td width="200">2602.09</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3389.2</td>
      <td width="200">3221.83</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">503953.77</td>
      <td width="200">338222.82</td>
      <td width="380">0.6711</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">903.54</td>
      <td width="200">878.19</td>
      <td width="380">0.9719</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8647.15</td>
      <td width="200">8897.77</td>
      <td width="380">0.9718</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">13780.0</td>
      <td width="200">16571.0</td>
      <td width="380">0.8316</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">133.07</td>
      <td width="200">129.95</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">229.22</td>
      <td width="200">212.02</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">57826.53</td>
      <td width="200">56204.13</td>
      <td width="380">0.9719</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">844.36</td>
      <td width="200">1015.4</td>
      <td width="380">1.2026</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">23133.21</td>
      <td width="200">19237.46</td>
      <td width="380">1.2025</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">34846.0</td>
      <td width="200">36598.0</td>
      <td width="380">0.9521</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">146.11</td>
      <td width="200">128.33</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">183.51</td>
      <td width="200">255.54</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">54039.36</td>
      <td width="200">64985.51</td>
      <td width="380">1.2026</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6816.28</td>
      <td width="200">6647.58</td>
      <td width="380">0.9753</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">11460.81</td>
      <td width="200">11752.26</td>
      <td width="380">0.9752</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">15525.0</td>
      <td width="200">22760.0</td>
      <td width="380">0.6821</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1797.75</td>
      <td width="200">1626.26</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1645.32</td>
      <td width="200">2948.65</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">436241.8</td>
      <td width="200">425445.12</td>
      <td width="380">0.9753</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6768.91</td>
      <td width="200">6826.18</td>
      <td width="380">1.0085</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">28856.3</td>
      <td width="200">28614.45</td>
      <td width="380">1.0085</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">37130.0</td>
      <td width="200">104064.0</td>
      <td width="380">0.3568</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1790.51</td>
      <td width="200">1477.67</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1683.72</td>
      <td width="200">3411.19</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">433210.18</td>
      <td width="200">436875.64</td>
      <td width="380">1.0085</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">8338.72</td>
      <td width="200">4243.33</td>
      <td width="380">0.5089</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">18739.96</td>
      <td width="200">36825.61</td>
      <td width="380">0.5089</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">52630.0</td>
      <td width="200">122940.0</td>
      <td width="380">0.4281</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2927.77</td>
      <td width="200">1495.52</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3173.97</td>
      <td width="200">2529.44</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">533677.81</td>
      <td width="200">271572.93</td>
      <td width="380">0.5089</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10717.66</td>
      <td width="200">7278.21</td>
      <td width="380">0.6791</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">36466.19</td>
      <td width="200">53667.57</td>
      <td width="380">0.6795</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">110318.0</td>
      <td width="200">141334.0</td>
      <td width="380">0.7805</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3252.43</td>
      <td width="200">2692.27</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">5596.58</td>
      <td width="200">4557.45</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">685929.93</td>
      <td width="200">465805.41</td>
      <td width="380">0.6791</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">8183.29</td>
      <td width="200">3730.77</td>
      <td width="380">0.4559</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">19115.06</td>
      <td width="200">41895.35</td>
      <td width="380">0.4563</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">113599.0</td>
      <td width="200">122937.0</td>
      <td width="380">0.924</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4512.34</td>
      <td width="200">2060.81</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3996.3</td>
      <td width="200">2232.58</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">523730.82</td>
      <td width="200">238769.22</td>
      <td width="380">0.4559</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">8418.12</td>
      <td width="200">5701.7</td>
      <td width="380">0.6773</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">46439.01</td>
      <td width="200">68483.21</td>
      <td width="380">0.6781</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">136853.0</td>
      <td width="200">130601.0</td>
      <td width="380">1.0479</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3983.36</td>
      <td width="200">2964.92</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4426.99</td>
      <td width="200">3226.73</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">538759.86</td>
      <td width="200">364908.74</td>
      <td width="380">0.6773</td>
    </tr>
  </tbody>
</table>

#### i32 int

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
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">224.77</td>
      <td width="200">146.9</td>
      <td width="380">0.6536</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">4402.01</td>
      <td width="200">6722.53</td>
      <td width="380">0.6548</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">6297.0</td>
      <td width="200">13853.0</td>
      <td width="380">0.4546</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">139.81</td>
      <td width="200">145.49</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">264.01</td>
      <td width="200">272.77</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">115081.68</td>
      <td width="200">75212.51</td>
      <td width="380">0.6536</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">234.78</td>
      <td width="200">155.07</td>
      <td width="380">0.6605</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">10466.62</td>
      <td width="200">15806.67</td>
      <td width="380">0.6622</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">17319.0</td>
      <td width="200">35569.0</td>
      <td width="380">0.4869</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">146.81</td>
      <td width="200">145.01</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">256.83</td>
      <td width="200">287.35</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">120208.77</td>
      <td width="200">79394.82</td>
      <td width="380">0.6605</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1131.27</td>
      <td width="200">772.09</td>
      <td width="380">0.6825</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8637.44</td>
      <td width="200">12655.54</td>
      <td width="380">0.6825</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">13607.0</td>
      <td width="200">15490.0</td>
      <td width="380">0.8784</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1700.67</td>
      <td width="200">1690.94</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1862.09</td>
      <td width="200">2227.13</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">579208.3</td>
      <td width="200">395312.59</td>
      <td width="380">0.6825</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">785.72</td>
      <td width="200">742.94</td>
      <td width="380">0.9456</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">31399.97</td>
      <td width="200">32877.14</td>
      <td width="380">0.9551</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">95561.0</td>
      <td width="200">36990.0</td>
      <td width="380">2.5834</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.99970446888888</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">107</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1083.89</td>
      <td width="200">1686.9</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3649.39</td>
      <td width="200">1977.77</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">402287.72</td>
      <td width="200">380382.96</td>
      <td width="380">0.9455</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">369.79</td>
      <td width="200">334.09</td>
      <td width="380">0.9035</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">54501.9</td>
      <td width="200">60425.13</td>
      <td width="380">0.902</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">116675.0</td>
      <td width="200">120421.0</td>
      <td width="380">0.9689</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">517.78</td>
      <td width="200">761.36</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1274.94</td>
      <td width="200">1610.15</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">189330.36</td>
      <td width="200">171055.28</td>
      <td width="380">0.9035</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1394.23</td>
      <td width="200">731.79</td>
      <td width="380">0.5249</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">35143.73</td>
      <td width="200">67652.76</td>
      <td width="380">0.5195</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">127741.0</td>
      <td width="200">133896.0</td>
      <td width="380">0.954</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2825.76</td>
      <td width="200">1595.01</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4913.34</td>
      <td width="200">3539.59</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">713847.18</td>
      <td width="200">374674.62</td>
      <td width="380">0.5249</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">654.55</td>
      <td width="200">296.29</td>
      <td width="380">0.4527</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">30673.73</td>
      <td width="200">68376.08</td>
      <td width="380">0.4486</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">117533.0</td>
      <td width="200">119834.0</td>
      <td width="380">0.9808</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2979.56</td>
      <td width="200">976.46</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1825.98</td>
      <td width="200">1358.24</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">335127.08</td>
      <td width="200">151699.86</td>
      <td width="380">0.4527</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">901.42</td>
      <td width="200">650.02</td>
      <td width="380">0.7211</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">55996.33</td>
      <td width="200">78094.21</td>
      <td width="380">0.717</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">129185.0</td>
      <td width="200">131858.0</td>
      <td width="380">0.9797</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.99849776416029</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">624</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2516.25</td>
      <td width="200">2292.29</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2755.0</td>
      <td width="200">3101.5</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">461527.34</td>
      <td width="200">332809.64</td>
      <td width="380">0.7211</td>
    </tr>
  </tbody>
</table>

#### i64 long

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
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">110.52</td>
      <td width="200">96.37</td>
      <td width="380">0.872</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">4474.41</td>
      <td width="200">5109.14</td>
      <td width="380">0.8758</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">8417.0</td>
      <td width="200">7913.0</td>
      <td width="380">1.0637</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">138.06</td>
      <td width="200">144.46</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">277.15</td>
      <td width="200">374.36</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">113171.29</td>
      <td width="200">98684.7</td>
      <td width="380">0.872</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">118.86</td>
      <td width="200">94.93</td>
      <td width="380">0.7987</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">10351.18</td>
      <td width="200">12920.81</td>
      <td width="380">0.8011</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">17370.0</td>
      <td width="200">30753.0</td>
      <td width="380">0.5648</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">149.05</td>
      <td width="200">145.9</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">230.58</td>
      <td width="200">366.65</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">121708.46</td>
      <td width="200">97205.7</td>
      <td width="380">0.7987</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">568.92</td>
      <td width="200">385.86</td>
      <td width="380">0.6782</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8589.13</td>
      <td width="200">12660.8</td>
      <td width="380">0.6784</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">10153.0</td>
      <td width="200">16055.0</td>
      <td width="380">0.6324</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1700.71</td>
      <td width="200">1619.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1559.48</td>
      <td width="200">2411.35</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">582577.61</td>
      <td width="200">395124.24</td>
      <td width="380">0.6782</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">511.77</td>
      <td width="200">307.51</td>
      <td width="380">0.6009</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">24096.46</td>
      <td width="200">39716.87</td>
      <td width="380">0.6067</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">114044.0</td>
      <td width="200">121042.0</td>
      <td width="380">0.9422</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1115.56</td>
      <td width="200">907.47</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3861.44</td>
      <td width="200">2821.83</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">524053.27</td>
      <td width="200">314890.8</td>
      <td width="380">0.6009</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">498.18</td>
      <td width="200">152.71</td>
      <td width="380">0.3065</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">20179.95</td>
      <td width="200">65192.71</td>
      <td width="380">0.3095</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">114394.0</td>
      <td width="200">120229.0</td>
      <td width="380">0.9515</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1969.7</td>
      <td width="200">592.01</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3330.66</td>
      <td width="200">1457.14</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">510135.57</td>
      <td width="200">156378.62</td>
      <td width="380">0.3065</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">524.56</td>
      <td width="200">326.48</td>
      <td width="380">0.6224</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">47032.02</td>
      <td width="200">77457.11</td>
      <td width="380">0.6072</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">172283.0</td>
      <td width="200">131331.0</td>
      <td width="380">1.3118</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1927.34</td>
      <td width="200">1138.33</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4532.97</td>
      <td width="200">3109.69</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">537154.1</td>
      <td width="200">334316.21</td>
      <td width="380">0.6224</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">268.91</td>
      <td width="200">141.82</td>
      <td width="380">0.5274</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">37674.64</td>
      <td width="200">71159.48</td>
      <td width="380">0.5294</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">116259.0</td>
      <td width="200">119863.0</td>
      <td width="380">0.9699</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.99899526831905</td>
      <td width="200">99.99809489853612</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">249</td>
      <td width="200">249</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1535.12</td>
      <td width="200">895.21</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3364.82</td>
      <td width="200">1353.92</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">275360.97</td>
      <td width="200">145221.34</td>
      <td width="380">0.5274</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">504.57</td>
      <td width="200">306.28</td>
      <td width="380">0.607</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">50321.89</td>
      <td width="200">82648.93</td>
      <td width="380">0.6089</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">128704.0</td>
      <td width="200">131393.0</td>
      <td width="380">0.9795</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99778938484567</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">624</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3141.1</td>
      <td width="200">1967.58</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2847.76</td>
      <td width="200">2970.67</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">516676.32</td>
      <td width="200">313631.26</td>
      <td width="380">0.607</td>
    </tr>
  </tbody>
</table>

#### double

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
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">49.33</td>
      <td width="200">46.04</td>
      <td width="380">0.9333</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">5006.7</td>
      <td width="200">5349.66</td>
      <td width="380">0.9359</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">8372.0</td>
      <td width="200">13667.0</td>
      <td width="380">0.6126</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">139.74</td>
      <td width="200">143.4</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">228.05</td>
      <td width="200">330.69</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">101027.47</td>
      <td width="200">94293.24</td>
      <td width="380">0.9333</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">53.0</td>
      <td width="200">38.88</td>
      <td width="380">0.7336</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">11577.85</td>
      <td width="200">15764.48</td>
      <td width="380">0.7344</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">23254.0</td>
      <td width="200">35590.0</td>
      <td width="380">0.6534</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">145.57</td>
      <td width="200">146.68</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">229.09</td>
      <td width="200">258.16</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">108539.64</td>
      <td width="200">79628.22</td>
      <td width="380">0.7336</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">166.8</td>
      <td width="200">211.71</td>
      <td width="380">1.2692</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14787.59</td>
      <td width="200">11541.0</td>
      <td width="380">1.2813</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">34517.0</td>
      <td width="200">15110.0</td>
      <td width="380">2.2844</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">799.18</td>
      <td width="200">1699.37</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4147.31</td>
      <td width="200">2886.88</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">341607.07</td>
      <td width="200">433582.71</td>
      <td width="380">1.2692</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">125.4</td>
      <td width="200">210.87</td>
      <td width="380">1.6816</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">49179.87</td>
      <td width="200">28954.28</td>
      <td width="380">1.6985</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">96304.0</td>
      <td width="200">36915.0</td>
      <td width="380">2.6088</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.99972743295186</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">63</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">645.67</td>
      <td width="200">1684.89</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4414.94</td>
      <td width="200">2979.51</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">256816.84</td>
      <td width="200">431851.78</td>
      <td width="380">1.6816</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">125.6</td>
      <td width="200">77.55</td>
      <td width="380">0.6174</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">39198.29</td>
      <td width="200">65243.4</td>
      <td width="380">0.6008</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">81623.0</td>
      <td width="200">120321.0</td>
      <td width="380">0.6784</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99651630439497</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">498</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">824.37</td>
      <td width="200">613.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4392.4</td>
      <td width="200">1464.24</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">257223.5</td>
      <td width="200">158829.62</td>
      <td width="380">0.6175</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">129.81</td>
      <td width="200">159.17</td>
      <td width="380">1.2262</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">95062.28</td>
      <td width="200">79591.17</td>
      <td width="380">1.1944</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">193300.0</td>
      <td width="200">131553.0</td>
      <td width="380">1.4694</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">850.35</td>
      <td width="200">1159.9</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4443.43</td>
      <td width="200">3052.86</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">265851.76</td>
      <td width="200">325970.67</td>
      <td width="380">1.2261</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">129.17</td>
      <td width="200">69.95</td>
      <td width="380">0.5415</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">39044.18</td>
      <td width="200">72337.79</td>
      <td width="380">0.5397</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">117412.0</td>
      <td width="200">120218.0</td>
      <td width="380">0.9767</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99806888182208</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">249</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1739.57</td>
      <td width="200">871.37</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1833.04</td>
      <td width="200">1343.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">264546.34</td>
      <td width="200">143264.83</td>
      <td width="380">0.5415</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">229.11</td>
      <td width="200">147.77</td>
      <td width="380">0.645</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">53725.32</td>
      <td width="200">84029.68</td>
      <td width="380">0.6394</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">140364.0</td>
      <td width="200">130676.0</td>
      <td width="380">1.0741</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99877376770446</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">334</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2542.9</td>
      <td width="200">1798.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2971.38</td>
      <td width="200">2753.27</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">469212.09</td>
      <td width="200">302639.69</td>
      <td width="380">0.645</td>
    </tr>
  </tbody>
</table>

#### list<i32>

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
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">343.95</td>
      <td width="200">234.47</td>
      <td width="380">0.6817</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">5678.64</td>
      <td width="200">8331.14</td>
      <td width="380">0.6816</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">9071.0</td>
      <td width="200">14425.0</td>
      <td width="380">0.6288</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">132.53</td>
      <td width="200">141.33</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">272.01</td>
      <td width="200">220.94</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">88051.84</td>
      <td width="200">60023.57</td>
      <td width="380">0.6817</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">391.33</td>
      <td width="200">210.65</td>
      <td width="380">0.5383</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">12478.47</td>
      <td width="200">23183.07</td>
      <td width="380">0.5383</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">16687.0</td>
      <td width="200">29573.0</td>
      <td width="380">0.5643</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">141.96</td>
      <td width="200">144.92</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">243.26</td>
      <td width="200">177.72</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">100180.36</td>
      <td width="200">53927.08</td>
      <td width="380">0.5383</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2104.96</td>
      <td width="200">1587.5</td>
      <td width="380">0.7542</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">9277.76</td>
      <td width="200">12303.16</td>
      <td width="380">0.7541</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">10765.0</td>
      <td width="200">18403.0</td>
      <td width="380">0.585</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1791.13</td>
      <td width="200">1615.88</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1511.06</td>
      <td width="200">2970.64</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">538869.1</td>
      <td width="200">406399.83</td>
      <td width="380">0.7542</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1033.51</td>
      <td width="200">1635.55</td>
      <td width="380">1.5825</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">47248.55</td>
      <td width="200">29874.39</td>
      <td width="380">1.5816</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">88849.0</td>
      <td width="200">113779.0</td>
      <td width="380">0.7809</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">705.73</td>
      <td width="200">1460.43</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4486.43</td>
      <td width="200">3420.87</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">264578.18</td>
      <td width="200">418701.87</td>
      <td width="380">1.5825</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2214.01</td>
      <td width="200">1050.58</td>
      <td width="380">0.4745</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">17640.74</td>
      <td width="200">37196.06</td>
      <td width="380">0.4743</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">67892.0</td>
      <td width="200">121451.0</td>
      <td width="380">0.559</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2389.39</td>
      <td width="200">1152.82</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4965.5</td>
      <td width="200">2336.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">566786.23</td>
      <td width="200">268948.42</td>
      <td width="380">0.4745</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2317.89</td>
      <td width="200">1545.84</td>
      <td width="380">0.6669</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">42130.26</td>
      <td width="200">63163.58</td>
      <td width="380">0.667</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">157700.0</td>
      <td width="200">140168.0</td>
      <td width="380">1.1251</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2288.58</td>
      <td width="200">1842.95</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4747.09</td>
      <td width="200">3636.4</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">593380.7</td>
      <td width="200">395735.87</td>
      <td width="380">0.6669</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1386.45</td>
      <td width="200">896.27</td>
      <td width="380">0.6464</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">28199.92</td>
      <td width="200">43619.76</td>
      <td width="380">0.6465</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">118807.0</td>
      <td width="200">123219.0</td>
      <td width="380">0.9642</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2162.29</td>
      <td width="200">1722.57</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2171.81</td>
      <td width="200">2017.62</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">354931.59</td>
      <td width="200">229444.31</td>
      <td width="380">0.6464</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1785.43</td>
      <td width="200">1333.79</td>
      <td width="380">0.747</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">54726.68</td>
      <td width="200">73239.33</td>
      <td width="380">0.7472</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">127850.0</td>
      <td width="200">133002.0</td>
      <td width="380">0.9613</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2745.27</td>
      <td width="200">2539.33</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2842.67</td>
      <td width="200">3243.23</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">457071.27</td>
      <td width="200">341450.08</td>
      <td width="380">0.747</td>
    </tr>
  </tbody>
</table>

#### list<i64>

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
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">223.62</td>
      <td width="200">153.8</td>
      <td width="380">0.6878</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">4421.83</td>
      <td width="200">6412.16</td>
      <td width="380">0.6896</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">6102.0</td>
      <td width="200">14034.0</td>
      <td width="380">0.4348</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">141.71</td>
      <td width="200">145.31</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">279.98</td>
      <td width="200">306.86</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">114494.0</td>
      <td width="200">78747.8</td>
      <td width="380">0.6878</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">229.19</td>
      <td width="200">174.12</td>
      <td width="380">0.7597</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">10740.01</td>
      <td width="200">14086.85</td>
      <td width="380">0.7624</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">17613.0</td>
      <td width="200">32882.0</td>
      <td width="380">0.5356</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">151.26</td>
      <td width="200">144.92</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">255.21</td>
      <td width="200">329.58</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">117344.66</td>
      <td width="200">89150.69</td>
      <td width="380">0.7597</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1051.45</td>
      <td width="200">842.99</td>
      <td width="380">0.8017</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">9293.97</td>
      <td width="200">11592.73</td>
      <td width="380">0.8017</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">10421.0</td>
      <td width="200">16714.0</td>
      <td width="380">0.6235</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1720.1</td>
      <td width="200">1687.89</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1652.97</td>
      <td width="200">2599.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">538341.13</td>
      <td width="200">431611.86</td>
      <td width="380">0.8017</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1171.9</td>
      <td width="200">903.91</td>
      <td width="380">0.7713</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">20839.07</td>
      <td width="200">27020.59</td>
      <td width="380">0.7712</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">23148.0</td>
      <td width="200">113686.0</td>
      <td width="380">0.2036</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1704.11</td>
      <td width="200">1510.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2144.39</td>
      <td width="200">3313.53</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">600012.79</td>
      <td width="200">462802.94</td>
      <td width="380">0.7713</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1468.51</td>
      <td width="200">513.88</td>
      <td width="380">0.3499</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">13478.24</td>
      <td width="200">39393.14</td>
      <td width="380">0.3421</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">77508.0</td>
      <td width="200">118961.0</td>
      <td width="380">0.6515</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99895269014206</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">248</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2985.43</td>
      <td width="200">1408.2</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4835.19</td>
      <td width="200">2524.71</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">751876.99</td>
      <td width="200">263105.2</td>
      <td width="380">0.3499</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">997.97</td>
      <td width="200">740.72</td>
      <td width="380">0.7422</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">50071.32</td>
      <td width="200">67485.31</td>
      <td width="380">0.742</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">124621.0</td>
      <td width="200">133561.0</td>
      <td width="380">0.9331</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1645.08</td>
      <td width="200">1631.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3103.73</td>
      <td width="200">3586.81</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">510961.29</td>
      <td width="200">379247.98</td>
      <td width="380">0.7422</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">482.92</td>
      <td width="200">294.38</td>
      <td width="380">0.6096</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">41441.59</td>
      <td width="200">68847.22</td>
      <td width="380">0.6019</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">117193.0</td>
      <td width="200">120224.0</td>
      <td width="380">0.9748</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1469.29</td>
      <td width="200">1000.26</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1406.46</td>
      <td width="200">1422.79</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">247256.5</td>
      <td width="200">150724.77</td>
      <td width="380">0.6096</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">897.12</td>
      <td width="200">643.55</td>
      <td width="380">0.7174</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">55523.71</td>
      <td width="200">78436.63</td>
      <td width="380">0.7079</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">128248.0</td>
      <td width="200">133860.0</td>
      <td width="380">0.9581</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3045.2</td>
      <td width="200">2285.24</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2725.67</td>
      <td width="200">3196.19</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">459324.54</td>
      <td width="200">329500.11</td>
      <td width="380">0.7174</td>
    </tr>
  </tbody>
</table>

#### string

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
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">537.37</td>
      <td width="200">517.8</td>
      <td width="380">0.9636</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">7269.95</td>
      <td width="200">7545.01</td>
      <td width="380">0.9635</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">11759.0</td>
      <td width="200">14664.0</td>
      <td width="380">0.8019</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">131.11</td>
      <td width="200">130.25</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">259.35</td>
      <td width="200">239.99</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">68782.9</td>
      <td width="200">66278.43</td>
      <td width="380">0.9636</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">537.78</td>
      <td width="200">637.32</td>
      <td width="380">1.1851</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">18161.38</td>
      <td width="200">15324.02</td>
      <td width="380">1.1852</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">24732.0</td>
      <td width="200">29211.0</td>
      <td width="380">0.8467</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">139.72</td>
      <td width="200">137.88</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">255.09</td>
      <td width="200">238.33</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">68835.99</td>
      <td width="200">81577.27</td>
      <td width="380">1.1851</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4437.33</td>
      <td width="200">2812.9</td>
      <td width="380">0.6339</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8802.73</td>
      <td width="200">13886.32</td>
      <td width="380">0.6339</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">10679.0</td>
      <td width="200">16118.0</td>
      <td width="380">0.6626</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1797.09</td>
      <td width="200">1777.65</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2195.28</td>
      <td width="200">1845.71</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">567977.9</td>
      <td width="200">360050.78</td>
      <td width="380">0.6339</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4489.76</td>
      <td width="200">3297.02</td>
      <td width="380">0.7343</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">21750.8</td>
      <td width="200">29621.2</td>
      <td width="380">0.7343</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">26460.0</td>
      <td width="200">109591.0</td>
      <td width="380">0.2414</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1767.43</td>
      <td width="200">1451.35</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2218.73</td>
      <td width="200">3597.31</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">574689.48</td>
      <td width="200">422018.58</td>
      <td width="380">0.7343</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2641.29</td>
      <td width="200">2057.4</td>
      <td width="380">0.7789</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">29609.76</td>
      <td width="200">37977.54</td>
      <td width="380">0.7797</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">115779.0</td>
      <td width="200">123286.0</td>
      <td width="380">0.9391</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1188.95</td>
      <td width="200">1328.32</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2115.64</td>
      <td width="200">2434.34</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">338084.71</td>
      <td width="200">263347.0</td>
      <td width="380">0.7789</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4375.53</td>
      <td width="200">3150.87</td>
      <td width="380">0.7201</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">44659.92</td>
      <td width="200">62019.57</td>
      <td width="380">0.7201</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">126467.0</td>
      <td width="200">141329.0</td>
      <td width="380">0.8948</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2088.39</td>
      <td width="200">1910.49</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3657.71</td>
      <td width="200">3804.28</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">560068.26</td>
      <td width="200">403311.42</td>
      <td width="380">0.7201</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2877.12</td>
      <td width="200">1821.44</td>
      <td width="380">0.6331</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">27176.7</td>
      <td width="200">42910.75</td>
      <td width="380">0.6333</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">119759.0</td>
      <td width="200">122554.0</td>
      <td width="380">0.9772</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2638.44</td>
      <td width="200">1655.74</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2334.77</td>
      <td width="200">2174.86</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">368271.96</td>
      <td width="200">233144.32</td>
      <td width="380">0.6331</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">3991.12</td>
      <td width="200">2687.94</td>
      <td width="380">0.6735</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">48945.79</td>
      <td width="200">72703.23</td>
      <td width="380">0.6732</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">126601.0</td>
      <td width="200">132727.0</td>
      <td width="380">0.9538</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3344.47</td>
      <td width="200">2689.62</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3390.56</td>
      <td width="200">3338.59</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">510863.59</td>
      <td width="200">344055.82</td>
      <td width="380">0.6735</td>
    </tr>
  </tbody>
</table>

#### list<string>

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
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">910.57</td>
      <td width="200">858.4</td>
      <td width="380">0.9427</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8580.57</td>
      <td width="200">9103.32</td>
      <td width="380">0.9426</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">13477.0</td>
      <td width="200">16822.0</td>
      <td width="380">0.8012</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">138.79</td>
      <td width="200">126.22</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">225.65</td>
      <td width="200">233.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">58276.44</td>
      <td width="200">54937.89</td>
      <td width="380">0.9427</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">984.45</td>
      <td width="200">892.67</td>
      <td width="380">0.9068</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">19841.54</td>
      <td width="200">21884.43</td>
      <td width="380">0.9067</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">25635.0</td>
      <td width="200">39013.0</td>
      <td width="380">0.6571</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">151.7</td>
      <td width="200">127.63</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">230.57</td>
      <td width="200">236.75</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">63004.72</td>
      <td width="200">57130.82</td>
      <td width="380">0.9068</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6194.18</td>
      <td width="200">5758.88</td>
      <td width="380">0.9297</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">12611.91</td>
      <td width="200">13566.36</td>
      <td width="380">0.9296</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">15125.0</td>
      <td width="200">18573.0</td>
      <td width="380">0.8144</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1786.22</td>
      <td width="200">1753.58</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1742.55</td>
      <td width="200">2047.29</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">396427.22</td>
      <td width="200">368568.22</td>
      <td width="380">0.9297</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6292.96</td>
      <td width="200">5596.06</td>
      <td width="380">0.8893</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">31038.73</td>
      <td width="200">34906.75</td>
      <td width="380">0.8892</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">37949.0</td>
      <td width="200">45059.0</td>
      <td width="380">0.8422</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1794.77</td>
      <td width="200">1711.64</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1756.83</td>
      <td width="200">1936.4</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">402749.14</td>
      <td width="200">358148.13</td>
      <td width="380">0.8893</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">9983.58</td>
      <td width="200">4079.7</td>
      <td width="380">0.4086</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">15658.65</td>
      <td width="200">38319.81</td>
      <td width="380">0.4086</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">85323.0</td>
      <td width="200">124036.0</td>
      <td width="380">0.6879</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3212.04</td>
      <td width="200">1437.81</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4895.18</td>
      <td width="200">2477.23</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">638949.12</td>
      <td width="200">261100.57</td>
      <td width="380">0.4086</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10800.37</td>
      <td width="200">7207.84</td>
      <td width="380">0.6674</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">36172.88</td>
      <td width="200">54210.43</td>
      <td width="380">0.6673</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">103988.0</td>
      <td width="200">144262.0</td>
      <td width="380">0.7208</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3355.91</td>
      <td width="200">2766.75</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">5354.38</td>
      <td width="200">4541.8</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">691223.72</td>
      <td width="200">461301.7</td>
      <td width="380">0.6674</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">8254.12</td>
      <td width="200">3853.24</td>
      <td width="380">0.4668</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">18932.57</td>
      <td width="200">40616.16</td>
      <td width="380">0.4661</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">113253.0</td>
      <td width="200">122775.0</td>
      <td width="380">0.9224</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4764.38</td>
      <td width="200">1860.35</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4240.22</td>
      <td width="200">2363.91</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">528263.49</td>
      <td width="200">246607.16</td>
      <td width="380">0.4668</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10266.5</td>
      <td width="200">5283.22</td>
      <td width="380">0.5146</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">38067.12</td>
      <td width="200">73923.9</td>
      <td width="380">0.515</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">121942.0</td>
      <td width="200">132361.0</td>
      <td width="380">0.9213</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">5734.91</td>
      <td width="200">2432.85</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">5714.57</td>
      <td width="200">3250.63</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">657056.08</td>
      <td width="200">338126.31</td>
      <td width="380">0.5146</td>
    </tr>
  </tbody>
</table>

#### set<string>

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
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">909.39</td>
      <td width="200">914.78</td>
      <td width="380">1.0059</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8592.35</td>
      <td width="200">8541.76</td>
      <td width="380">1.0059</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">13586.0</td>
      <td width="200">16141.0</td>
      <td width="380">0.8417</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">142.1</td>
      <td width="200">128.1</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">223.71</td>
      <td width="200">240.27</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">58201.01</td>
      <td width="200">58546.18</td>
      <td width="380">1.0059</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">951.98</td>
      <td width="200">856.4</td>
      <td width="380">0.8996</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">20518.96</td>
      <td width="200">22810.64</td>
      <td width="380">0.8995</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">25846.0</td>
      <td width="200">37800.0</td>
      <td width="380">0.6838</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">146.14</td>
      <td width="200">130.75</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">197.14</td>
      <td width="200">207.48</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">60926.92</td>
      <td width="200">54809.84</td>
      <td width="380">0.8996</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6226.87</td>
      <td width="200">5564.9</td>
      <td width="380">0.8937</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">12545.75</td>
      <td width="200">14039.13</td>
      <td width="380">0.8936</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">14826.0</td>
      <td width="200">18645.0</td>
      <td width="380">0.7952</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1796.98</td>
      <td width="200">1777.49</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1532.94</td>
      <td width="200">1733.93</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">398519.7</td>
      <td width="200">356153.36</td>
      <td width="380">0.8937</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6773.31</td>
      <td width="200">6538.61</td>
      <td width="380">0.9653</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">28833.56</td>
      <td width="200">29873.5</td>
      <td width="380">0.9652</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">34473.0</td>
      <td width="200">46642.0</td>
      <td width="380">0.7391</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1782.46</td>
      <td width="200">1695.16</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1632.26</td>
      <td width="200">2453.93</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">433491.99</td>
      <td width="200">418471.23</td>
      <td width="380">0.9653</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10644.33</td>
      <td width="200">4227.78</td>
      <td width="380">0.3972</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14677.12</td>
      <td width="200">36986.26</td>
      <td width="380">0.3968</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">16268.0</td>
      <td width="200">123184.0</td>
      <td width="380">0.1321</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3485.94</td>
      <td width="200">1389.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3385.5</td>
      <td width="200">2553.73</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">681237.11</td>
      <td width="200">270577.87</td>
      <td width="380">0.3972</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">9796.28</td>
      <td width="200">6231.46</td>
      <td width="380">0.6361</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">39867.85</td>
      <td width="200">62736.44</td>
      <td width="380">0.6355</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">41326.0</td>
      <td width="200">138383.0</td>
      <td width="380">0.2986</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3376.55</td>
      <td width="200">1794.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2934.49</td>
      <td width="200">3823.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">626961.96</td>
      <td width="200">398813.42</td>
      <td width="380">0.6361</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">8782.96</td>
      <td width="200">3495.4</td>
      <td width="380">0.398</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">17808.02</td>
      <td width="200">44767.19</td>
      <td width="380">0.3978</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">113071.0</td>
      <td width="200">123459.0</td>
      <td width="380">0.9159</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4778.89</td>
      <td width="200">1889.34</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4075.88</td>
      <td width="200">2174.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">562109.68</td>
      <td width="200">223705.42</td>
      <td width="380">0.398</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10704.85</td>
      <td width="200">5275.08</td>
      <td width="380">0.4928</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">36481.34</td>
      <td width="200">74063.37</td>
      <td width="380">0.4926</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">121376.0</td>
      <td width="200">133190.0</td>
      <td width="380">0.9113</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">5487.76</td>
      <td width="200">2727.21</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">5258.9</td>
      <td width="200">3323.48</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">685110.14</td>
      <td width="200">337604.83</td>
      <td width="380">0.4928</td>
    </tr>
  </tbody>
</table>

#### map<string, i64>

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
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">333.93</td>
      <td width="200">273.08</td>
      <td width="380">0.8178</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">5850.1</td>
      <td width="200">7152.72</td>
      <td width="380">0.8179</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">9419.0</td>
      <td width="200">13848.0</td>
      <td width="380">0.6802</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">144.99</td>
      <td width="200">138.31</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">283.08</td>
      <td width="200">290.81</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">85485.87</td>
      <td width="200">69908.77</td>
      <td width="380">0.8178</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">346.09</td>
      <td width="200">269.99</td>
      <td width="380">0.7801</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14109.04</td>
      <td width="200">18088.22</td>
      <td width="380">0.78</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">19467.0</td>
      <td width="200">28946.0</td>
      <td width="380">0.6725</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">153.86</td>
      <td width="200">141.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">273.48</td>
      <td width="200">293.19</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">88598.01</td>
      <td width="200">69118.16</td>
      <td width="380">0.7801</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2309.81</td>
      <td width="200">1547.48</td>
      <td width="380">0.67</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8455.08</td>
      <td width="200">12621.23</td>
      <td width="380">0.6699</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">9863.0</td>
      <td width="200">95271.0</td>
      <td width="380">0.1035</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1761.48</td>
      <td width="200">1529.23</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2008.39</td>
      <td width="200">2837.11</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">591311.53</td>
      <td width="200">396153.91</td>
      <td width="380">0.67</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2046.66</td>
      <td width="200">1697.3</td>
      <td width="380">0.8293</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">23853.95</td>
      <td width="200">28786.08</td>
      <td width="380">0.8287</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">25753.0</td>
      <td width="200">116517.0</td>
      <td width="380">0.221</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1745.35</td>
      <td width="200">1420.64</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1808.18</td>
      <td width="200">3571.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">523946.18</td>
      <td width="200">434510.02</td>
      <td width="380">0.8293</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2806.79</td>
      <td width="200">1141.92</td>
      <td width="380">0.4068</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">13919.67</td>
      <td width="200">34232.41</td>
      <td width="380">0.4066</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">49915.0</td>
      <td width="200">122849.0</td>
      <td width="380">0.4063</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3045.17</td>
      <td width="200">1523.01</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3930.01</td>
      <td width="200">2677.82</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">718537.96</td>
      <td width="200">292330.61</td>
      <td width="380">0.4068</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2229.2</td>
      <td width="200">1592.32</td>
      <td width="380">0.7143</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">43821.18</td>
      <td width="200">61349.83</td>
      <td width="380">0.7143</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">128302.0</td>
      <td width="200">142318.0</td>
      <td width="380">0.9015</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2023.81</td>
      <td width="200">1973.92</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3516.72</td>
      <td width="200">3834.93</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">570674.57</td>
      <td width="200">407634.53</td>
      <td width="380">0.7143</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1352.1</td>
      <td width="200">923.6</td>
      <td width="380">0.6831</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">28915.75</td>
      <td width="200">42390.23</td>
      <td width="380">0.6821</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">119464.0</td>
      <td width="200">122070.0</td>
      <td width="380">0.9787</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2317.79</td>
      <td width="200">1829.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2105.71</td>
      <td width="200">2195.64</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">346137.12</td>
      <td width="200">236442.08</td>
      <td width="380">0.6831</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2013.37</td>
      <td width="200">1338.09</td>
      <td width="380">0.6646</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">48520.58</td>
      <td width="200">73005.22</td>
      <td width="380">0.6646</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">129175.0</td>
      <td width="200">132502.0</td>
      <td width="380">0.9749</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3222.09</td>
      <td width="200">2501.48</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3203.59</td>
      <td width="200">3263.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">515422.68</td>
      <td width="200">342551.66</td>
      <td width="380">0.6646</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
