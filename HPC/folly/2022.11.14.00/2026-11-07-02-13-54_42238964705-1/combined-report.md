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
      <td width="600">2026-11-06T15:04:19Z</td>
      <td width="600">2026-11-06T15:05:16Z</td>
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
      <td width="600">2026-11-06T15:00:56Z</td>
      <td width="600">2026-11-06T15:00:57Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 81278 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 150061 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 168394 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 151369 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 133587 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 159193 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 168125 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 160929 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 371013 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 384606 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 367081 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 351187 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">22.54</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5483.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8136.0</td>
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
      <td width="280">148.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">205.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">92317.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">21.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14120.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">23963.0</td>
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
      <td width="280">153.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">228.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">88996.47</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">102.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11978.78</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">38845.0</td>
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
      <td width="280">1045.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">4114.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">421458.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">111.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">27452.16</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">92184.0</td>
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
      <td width="280">1140.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3214.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">455457.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">167.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">14548.38</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">15759.0</td>
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
      <td width="280">3249.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2071.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">687401.3</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">143.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">43391.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">123390.0</td>
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
      <td width="280">1638.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2942.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">587413.69</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">82.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">30383.45</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117151.0</td>
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
      <td width="280">2541.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1540.54</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">336110.39</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">124.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">50649.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128640.0</td>
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
      <td width="280">2957.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2787.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">508657.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">80.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6133.65</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8351.0</td>
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
      <td width="280">151.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">237.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">82738.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">109.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">11189.39</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">18505.0</td>
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
      <td width="280">147.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">276.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">112598.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">518.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9414.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10828.0</td>
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
      <td width="280">1703.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1400.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">531370.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">548.67</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">22252.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">56905.0</td>
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
      <td width="280">1620.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1863.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">561834.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">653.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">14932.82</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">15925.0</td>
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
      <td width="280">3254.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1996.54</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">669688.31</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">663.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">36811.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">40183.0</td>
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
      <td width="280">3209.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">1995.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">679072.38</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">361.38</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">27711.62</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">116653.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.9994415278956</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">186</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2916.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1773.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">370055.21</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">483.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">52164.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128786.0</td>
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
      <td width="280">3071.59</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2757.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">494692.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">297.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6560.55</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">11035.0</td>
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
      <td width="280">138.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">253.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">76216.73</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">282.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">17313.52</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">22908.0</td>
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
      <td width="280">145.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">236.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">72206.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2025.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9641.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">27478.0</td>
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
      <td width="280">1554.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">3346.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">518515.1</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">2093.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">23323.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">53328.0</td>
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
      <td width="280">1695.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2340.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">535860.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2374.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">16448.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">105573.0</td>
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
      <td width="280">2718.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4599.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">607848.69</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2208.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">44251.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128733.0</td>
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
      <td width="280">1875.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3248.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">565278.07</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2026.46</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">19291.29</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">114805.0</td>
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
      <td width="280">3907.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2949.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">518772.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1977.34</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">49358.35</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">126603.0</td>
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
      <td width="280">3126.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2959.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">506199.48</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">513.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7604.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13384.0</td>
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
      <td width="280">149.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">216.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">65751.67</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">464.74</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">21015.16</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">26946.0</td>
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
      <td width="280">159.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">199.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">59486.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">4051.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9641.38</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">11979.0</td>
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
      <td width="280">1795.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1723.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">518563.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">3812.93</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">25610.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">29536.0</td>
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
      <td width="280">1767.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1824.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">488054.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4131.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">18910.84</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">102567.0</td>
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
      <td width="280">2436.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4561.12</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">528824.03</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">6079.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">32136.05</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">110889.0</td>
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
      <td width="280">2863.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4740.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">778189.02</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4645.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">16825.07</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">113331.0</td>
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
      <td width="280">4679.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3695.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">594630.66</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">4308.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">45337.27</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">127261.0</td>
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
      <td width="280">3836.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3614.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">551517.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">694.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">11252.62</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">17132.0</td>
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
      <td width="280">163.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">199.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">44444.06</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">777.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">25130.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">33216.0</td>
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
      <td width="280">157.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">218.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">49747.38</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6719.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11625.27</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">16114.0</td>
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
      <td width="280">1794.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1634.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">430074.52</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6813.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28665.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">38183.0</td>
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
      <td width="280">1761.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1496.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">436039.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">10218.64</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">15288.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">16179.0</td>
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
      <td width="280">3327.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2396.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">653993.1</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10368.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">37666.29</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">38958.0</td>
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
      <td width="280">3299.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2360.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">663588.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">10151.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">15393.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">112732.0</td>
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
      <td width="280">5607.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">5086.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">649713.31</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10330.25</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">37819.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">124279.0</td>
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
      <td width="280">5293.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4957.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">661136.22</td>
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
      <td width="280">156.24</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6331.08</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">7723.0</td>
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
      <td width="280">152.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">235.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">79993.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">219.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">11196.18</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">18379.0</td>
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
      <td width="280">147.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">306.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">112409.33</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">730.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13375.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">38554.0</td>
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
      <td width="280">984.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">3762.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">374150.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1206.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">20250.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">27814.0</td>
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
      <td width="280">1700.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1916.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">617500.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1262.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">15473.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">16279.0</td>
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
      <td width="280">3240.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1982.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">646252.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1479.65</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">32995.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">38350.0</td>
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
      <td width="280">3228.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2371.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">757578.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">878.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">22879.93</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">115000.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.9997234492379</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">112</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">3836.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2072.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">449986.47</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">989.95</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">50975.94</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">125922.0</td>
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
      <td width="280">2549.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2539.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">506854.89</td>
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
      <td width="280">75.62</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6543.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9038.0</td>
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
      <td width="280">150.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">223.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">77433.09</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">81.46</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15083.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">25374.0</td>
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
      <td width="280">155.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">226.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">83411.27</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">552.46</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8847.45</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15396.0</td>
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
      <td width="280">1674.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2266.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">565714.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">580.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">21021.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">42829.0</td>
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
      <td width="280">1686.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2789.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">594796.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">705.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">13837.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">14982.0</td>
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
      <td width="280">3180.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2278.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">722764.06</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">708.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">34465.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">38163.0</td>
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
      <td width="280">3246.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2135.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">725296.44</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">390.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">25865.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">115825.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">3350.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1872.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">400223.27</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">486.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">51078.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">127583.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99860857558946</td>
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
      <td width="280">2638.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2565.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">498283.4</td>
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
      <td width="280">40.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6174.78</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8533.0</td>
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
      <td width="280">149.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">222.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">82210.79</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">41.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14663.99</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">24864.0</td>
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
      <td width="280">153.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">234.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">85762.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">295.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8276.74</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">9779.0</td>
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
      <td width="280">1718.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1839.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">604380.53</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">301.36</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">20258.91</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">23733.0</td>
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
      <td width="280">1691.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1564.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">617182.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">387.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">12593.37</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">13997.0</td>
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
      <td width="280">3243.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2608.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">794179.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">358.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">34067.74</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">37788.0</td>
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
      <td width="280">3232.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2722.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">733801.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">186.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">27102.52</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">115387.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99927571244807</td>
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
      <td width="280">3212.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1563.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">381981.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">252.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">50362.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">126532.0</td>
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
      <td width="280">2927.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2555.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">517981.02</td>
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
      <td width="280">309.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6319.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">11241.0</td>
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
      <td width="280">141.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">228.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">79125.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">326.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14954.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">23082.0</td>
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
      <td width="280">145.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">234.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">83592.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2293.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8516.74</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">11392.0</td>
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
      <td width="280">1736.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1830.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">587048.1</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">2166.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">22530.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">27991.0</td>
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
      <td width="280">1744.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1702.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">554707.03</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2976.23</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">13121.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">15342.0</td>
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
      <td width="280">3362.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2457.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">761914.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2557.46</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">38170.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">41044.0</td>
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
      <td width="280">3310.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2053.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">654708.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2267.04</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">17250.45</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">113876.0</td>
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
      <td width="280">4433.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3262.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">580362.67</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2190.62</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">44588.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">126442.0</td>
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
      <td width="280">3469.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3081.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">560798.27</td>
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
      <td width="280">148.22</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6686.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8640.0</td>
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
      <td width="280">156.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">225.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">75891.14</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">218.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">11239.05</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">18651.0</td>
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
      <td width="280">150.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">294.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">111964.52</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1070.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9124.61</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10841.0</td>
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
      <td width="280">1704.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1526.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">548239.14</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1057.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">23093.87</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">26511.0</td>
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
      <td width="280">1697.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1406.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">541389.84</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">778.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">25099.91</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">113490.0</td>
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
      <td width="280">1208.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1719.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">398431.09</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1375.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">35482.56</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">120150.0</td>
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
      <td width="280">2162.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3779.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">704481.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">795.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">24953.67</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">115799.0</td>
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
      <td width="280">3387.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1826.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">407109.73</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1015.59</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">49883.65</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">127830.0</td>
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
      <td width="280">2917.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2694.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">519982.79</td>
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
      <td width="280">482.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8095.43</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">12655.0</td>
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
      <td width="280">157.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">205.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">61776.84</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">474.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">20573.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">26221.0</td>
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
      <td width="280">165.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">194.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">60768.2</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">3794.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">10293.5</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">12015.0</td>
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
      <td width="280">1778.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1480.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">485693.69</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">3650.15</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">26752.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">29689.0</td>
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
      <td width="280">1747.59</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1372.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">467219.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4899.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">15941.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">16524.0</td>
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
      <td width="280">3326.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2088.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">627167.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5771.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">33832.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">38816.0</td>
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
      <td width="280">3281.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2456.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">738744.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">5300.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">14750.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">112267.0</td>
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
      <td width="280">4900.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4144.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">678492.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">4474.05</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">43683.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">127005.0</td>
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
      <td width="280">3891.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3449.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">572678.7</td>
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
      <td width="280">714.43</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">10936.61</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">16543.0</td>
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
      <td width="280">171.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">206.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">45723.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">742.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">26290.29</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">34097.0</td>
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
      <td width="280">166.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">212.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">47551.66</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6502.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12014.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15975.0</td>
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
      <td width="280">1778.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1622.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">416141.74</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">5851.39</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">33376.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">37531.0</td>
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
      <td width="280">1719.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1469.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">374489.01</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">9751.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">16021.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">17379.0</td>
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
      <td width="280">3370.59</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4320.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">624064.0</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10896.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">35842.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">39304.0</td>
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
      <td width="280">3280.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4910.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">697391.84</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">10021.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">15609.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">112545.0</td>
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
      <td width="280">5259.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4805.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">641398.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10098.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">38706.53</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">123073.0</td>
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
      <td width="280">5361.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">5088.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">646297.87</td>
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
      <td width="280">678.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">11511.12</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">17884.0</td>
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
      <td width="280">165.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">201.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">43445.69</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">750.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">26037.03</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">35821.0</td>
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
      <td width="280">155.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">212.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">48017.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6152.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12696.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15809.0</td>
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
      <td width="280">1746.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1695.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">393777.01</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6755.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28908.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">39225.0</td>
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
      <td width="280">1795.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1842.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">432374.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">10858.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">14387.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">16398.0</td>
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
      <td width="280">3416.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">5345.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">694946.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">11385.07</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">34304.92</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">39086.0</td>
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
      <td width="280">3317.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">5347.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">728644.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">10016.62</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">15619.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">112679.0</td>
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
      <td width="280">5202.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4717.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">641063.51</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">9924.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">39357.49</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">123231.0</td>
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
      <td width="280">5286.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4856.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">635156.86</td>
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
      <td width="280">246.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7939.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">12249.0</td>
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
      <td width="280">163.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">239.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">62984.46</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">253.38</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">19273.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">25379.0</td>
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
      <td width="280">163.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">239.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">64865.53</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2042.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9562.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">11190.0</td>
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
      <td width="280">1754.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2212.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">522853.27</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">2152.59</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">22680.06</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">25547.0</td>
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
      <td width="280">1736.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2234.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">551062.21</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2647.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">14751.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">15905.0</td>
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
      <td width="280">3352.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4597.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">677735.44</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2044.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">47804.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128022.0</td>
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
      <td width="280">1710.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3167.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">523279.21</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1977.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">19764.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">115345.0</td>
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
      <td width="280">3858.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3038.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">506364.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1975.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">49411.9</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">126347.0</td>
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
      <td width="280">2988.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3129.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">505801.39</td>
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
      <td width="280">24.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5111.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8147.0</td>
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
      <td width="280">152.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">443.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">99465.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">10.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">27876.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">45138.0</td>
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
      <td width="280">154.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">226.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">45035.1</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">62.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">19436.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">114057.0</td>
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
      <td width="280">1142.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1865.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">257462.33</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">83.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">36495.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">46599.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">99.99999351469111</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">2</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1633.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2150.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">342654.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">47.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">53629.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123788.0</td>
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
      <td width="280">884.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1707.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">193700.88</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">86.83</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">71750.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">135643.0</td>
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
      <td width="280">1310.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3085.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">355640.6</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">35.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">70268.99</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121451.0</td>
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
      <td width="280">832.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1196.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">147036.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">75.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">83792.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">137755.0</td>
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
      <td width="280">1992.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2939.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">310450.73</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">91.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5457.72</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9002.0</td>
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
      <td width="280">151.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">494.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">93344.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">92.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">13258.82</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">21916.0</td>
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
      <td width="280">154.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">478.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">94904.4</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">320.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">15542.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">105186.0</td>
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
      <td width="280">1195.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">3187.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">327960.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">343.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">35544.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">122176.0</td>
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
      <td width="280">1216.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3444.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">351842.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">158.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">63855.72</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122363.0</td>
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
      <td width="280">667.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1508.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">162067.09</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">323.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">77936.53</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">138151.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99791841556632</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">621</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1264.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3180.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">331471.37</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">149.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">67532.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122281.0</td>
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
      <td width="280">965.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1292.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">153384.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">287.24</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">85820.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">135525.0</td>
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
      <td width="280">1644.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2759.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">294136.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">354.61</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5509.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">10186.0</td>
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
      <td width="280">149.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">556.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">90780.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">342.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14239.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">23929.0</td>
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
      <td width="280">150.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">544.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">87791.91</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">812.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">24046.99</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">117065.0</td>
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
      <td width="280">697.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1982.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">208068.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1014.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">48189.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">128618.0</td>
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
      <td width="280">712.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2604.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">259630.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1042.61</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">37491.27</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">125429.0</td>
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
      <td width="280">1601.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2629.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">266907.2</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1446.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">67506.52</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">143057.0</td>
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
      <td width="280">1671.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3589.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">370203.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">872.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">44841.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124170.0</td>
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
      <td width="280">1616.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2040.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">223458.4</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1255.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">77752.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136859.0</td>
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
      <td width="280">2119.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3082.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">321493.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">663.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5886.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">11637.0</td>
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
      <td width="280">147.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">488.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">84965.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">671.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14552.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">20622.0</td>
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
      <td width="280">147.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">469.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">85911.37</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2766.89</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14116.56</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">22985.0</td>
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
      <td width="280">1715.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2288.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">354162.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">3066.34</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">31850.62</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">45021.0</td>
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
      <td width="280">1750.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2998.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">392491.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1826.93</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">42819.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124108.0</td>
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
      <td width="280">986.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2203.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">233847.56</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3178.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">60935.3</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">144605.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.66048884544408</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">124755</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2161.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4078.17</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">406896.93</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1781.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43937.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124366.0</td>
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
      <td width="280">1725.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2039.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">227978.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2424.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">80591.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">137183.0</td>
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
      <td width="280">1884.6</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2982.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">310352.52</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">1142.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6840.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">11598.0</td>
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
      <td width="280">137.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">459.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">73101.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">1083.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">18030.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">24207.0</td>
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
      <td width="280">135.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">424.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">69340.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">5847.95</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13357.71</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">21138.0</td>
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
      <td width="280">1758.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2681.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">374268.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6346.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">30775.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">110579.0</td>
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
      <td width="280">1438.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">4280.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">406199.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3631.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43053.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123354.0</td>
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
      <td width="280">949.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2280.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">232447.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5662.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">69005.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">143518.0</td>
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
      <td width="280">1668.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3614.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">362429.2</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3820.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40925.38</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123628.0</td>
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
      <td width="280">1990.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2226.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">244516.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5028.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">77695.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136977.0</td>
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
      <td width="280">2295.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3187.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">321842.21</td>
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
      <td width="280">181.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5450.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9094.0</td>
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
      <td width="280">151.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">548.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">93065.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">184.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">13346.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">21891.0</td>
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
      <td width="280">152.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">520.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">94221.04</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">247.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">40791.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">117609.0</td>
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
      <td width="280">362.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1136.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">126860.39</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">491.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">51621.37</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">124862.0</td>
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
      <td width="280">673.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2393.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">251493.48</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">295.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">67428.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122313.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99999264770972</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">1</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">553.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1418.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">151124.48</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">678.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">73086.06</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">137315.0</td>
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
      <td width="280">1387.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3315.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">347509.2</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">295.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">68474.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121596.0</td>
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
      <td width="280">933.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1275.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">151052.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">626.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">80610.69</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136070.0</td>
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
      <td width="280">2213.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3064.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">320580.71</td>
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
      <td width="280">92.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5348.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8904.0</td>
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
      <td width="280">152.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">528.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">94750.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">97.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">12660.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">21211.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">99.99998881731473</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">1</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">154.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">522.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">99359.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">338.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14433.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">20943.0</td>
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
      <td width="280">1644.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2475.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">346875.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">336.05</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">36352.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">46358.0</td>
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
      <td width="280">1658.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2366.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">344116.98</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">224.26</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">45099.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123312.0</td>
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
      <td width="280">1211.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2183.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">229644.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">328.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">75348.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136971.0</td>
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
      <td width="280">1283.12</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3190.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">336513.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">147.95</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">68296.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122364.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">916.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1268.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">151504.52</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">286.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">87703.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136786.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99801827153644</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">524</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1661.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2740.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">293789.33</td>
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
      <td width="280">48.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5126.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8648.0</td>
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
      <td width="280">151.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">572.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">98884.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">51.34</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">11957.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">19962.0</td>
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
      <td width="280">153.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">538.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">105148.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">111.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">22231.53</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">115718.0</td>
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
      <td width="280">858.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1955.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">228489.02</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">162.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">37643.84</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">123763.0</td>
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
      <td width="280">1134.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3256.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">332326.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">69.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">72144.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121737.0</td>
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
      <td width="280">489.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1309.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">142792.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">158.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">79297.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">135789.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99788145779075</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">620</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1119.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3028.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">325164.3</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">74.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">67849.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121835.0</td>
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
      <td width="280">997.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1349.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">152529.07</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">153.15</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">82318.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136279.0</td>
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
      <td width="280">2052.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2965.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">313641.21</td>
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
      <td width="280">351.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5564.11</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">10254.0</td>
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
      <td width="280">152.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">517.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">89886.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">157.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">30933.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">39325.0</td>
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
      <td width="280">149.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">274.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">40413.6</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1175.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">16608.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">111326.0</td>
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
      <td width="280">1118.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2836.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">301032.37</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1159.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">42131.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">130646.0</td>
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
      <td width="280">915.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2866.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">296852.03</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">882.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">44336.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123360.0</td>
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
      <td width="280">807.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2154.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">225979.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1310.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">74617.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">139096.0</td>
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
      <td width="280">1234.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3183.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">335396.21</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">892.07</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43818.36</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124342.0</td>
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
      <td width="280">1792.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1975.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">228369.02</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1381.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">70722.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136707.0</td>
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
      <td width="280">2628.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3278.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">353563.34</td>
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
      <td width="280">185.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5332.72</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8979.0</td>
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
      <td width="280">152.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">524.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">95132.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">184.74</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">13305.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">21606.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">99.9999882527671</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">1</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">154.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">490.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">94584.91</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">668.52</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14625.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">78076.0</td>
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
      <td width="280">1541.41</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2699.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">342281.73</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">667.17</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">36614.61</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">44679.0</td>
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
      <td width="280">1658.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2240.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">341591.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">707.62</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">28724.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121050.0</td>
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
      <td width="280">2081.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3463.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">362303.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">824.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">59937.87</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">149046.0</td>
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
      <td width="280">2289.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4072.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">422304.63</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">351.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">57713.35</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122508.0</td>
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
      <td width="280">1302.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1315.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">180060.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">640.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">78635.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">137966.0</td>
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
      <td width="280">2176.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3013.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">328078.68</td>
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
      <td width="280">683.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5718.52</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">10670.0</td>
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
      <td width="280">148.17</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">524.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">87460.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">647.49</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15084.5</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">32753.0</td>
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
      <td width="280">146.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">482.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">82878.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2618.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14919.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">98862.0</td>
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
      <td width="280">1586.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2674.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">335106.71</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">2585.46</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">37788.25</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">126084.0</td>
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
      <td width="280">1116.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3306.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">330939.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1959.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">39877.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">125816.0</td>
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
      <td width="280">1487.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2483.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">250778.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3382.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">57725.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">145074.0</td>
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
      <td width="280">2589.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4479.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">433013.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1782.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43831.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123774.0</td>
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
      <td width="280">1697.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2143.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">228204.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2620.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">74528.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136826.0</td>
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
      <td width="280">2590.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3325.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">335444.32</td>
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
      <td width="280">1086.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7192.11</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14990.0</td>
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
      <td width="280">137.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">468.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">69541.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">956.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">20423.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">44714.0</td>
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
      <td width="280">135.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">413.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">61207.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">4494.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">17380.77</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">111498.0</td>
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
      <td width="280">1129.17</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2641.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">287666.88</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">5289.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">36929.29</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">59453.0</td>
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
      <td width="280">1662.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2308.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">338505.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3827.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40872.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123278.0</td>
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
      <td width="280">1058.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2326.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">244977.32</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5694.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">68610.82</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">141196.0</td>
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
      <td width="280">1526.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3604.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">364477.33</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3522.24</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">44451.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124304.0</td>
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
      <td width="280">1766.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2183.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">225423.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">4939.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">79139.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">135705.0</td>
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
      <td width="280">1962.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3044.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">316114.26</td>
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
      <td width="280">1108.38</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7049.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">15693.0</td>
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
      <td width="280">137.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">472.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">70936.17</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">896.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">21782.48</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">44434.0</td>
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
      <td width="280">134.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">367.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">57395.79</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">5980.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13062.3</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">92527.0</td>
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
      <td width="280">1535.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">3304.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">382745.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">4955.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">39417.89</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">49640.0</td>
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
      <td width="280">1746.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1887.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">317124.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3985.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">39225.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124344.0</td>
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
      <td width="280">1437.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2495.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">255093.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5751.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">67968.82</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">140903.0</td>
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
      <td width="280">1535.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3634.41</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">368100.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3561.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43873.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124135.0</td>
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
      <td width="280">1862.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2158.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">227909.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5178.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">75400.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136240.0</td>
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
      <td width="280">2627.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3349.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">331420.22</td>
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
      <td width="280">346.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5644.29</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">10693.0</td>
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
      <td width="280">154.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">561.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">88610.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">314.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15538.42</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">34044.0</td>
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
      <td width="280">151.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">523.6</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">80452.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1376.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14186.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">91781.0</td>
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
      <td width="280">1596.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2876.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">352423.91</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1300.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">37535.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">45907.0</td>
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
      <td width="280">1714.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2318.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">333016.39</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1167.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">33490.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123771.0</td>
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
      <td width="280">1784.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2900.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">298820.24</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1387.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">70392.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">139798.0</td>
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
      <td width="280">1434.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3446.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">355123.71</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">858.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">45483.15</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124137.0</td>
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
      <td width="280">1470.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2007.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">219877.58</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1366.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">71456.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136486.0</td>
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
      <td width="280">2724.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3367.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">349823.61</td>
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
      <td width="200">22.54</td>
      <td width="200">24.28</td>
      <td width="380">1.0772</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">5483.75</td>
      <td width="200">5111.83</td>
      <td width="380">1.0728</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">8136.0</td>
      <td width="200">8147.0</td>
      <td width="380">0.9986</td>
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
      <td width="200">148.09</td>
      <td width="200">152.34</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">205.2</td>
      <td width="200">443.31</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">92317.11</td>
      <td width="200">99465.08</td>
      <td width="380">1.0774</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">21.73</td>
      <td width="200">10.99</td>
      <td width="380">0.5058</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14120.04</td>
      <td width="200">27876.88</td>
      <td width="380">0.5065</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">23963.0</td>
      <td width="200">45138.0</td>
      <td width="380">0.5309</td>
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
      <td width="200">153.69</td>
      <td width="200">154.81</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">228.77</td>
      <td width="200">226.53</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">88996.47</td>
      <td width="200">45035.1</td>
      <td width="380">0.506</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">102.9</td>
      <td width="200">62.86</td>
      <td width="380">0.6109</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">11978.78</td>
      <td width="200">19436.63</td>
      <td width="380">0.6163</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">38845.0</td>
      <td width="200">114057.0</td>
      <td width="380">0.3406</td>
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
      <td width="200">1045.94</td>
      <td width="200">1142.5</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4114.71</td>
      <td width="200">1865.25</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">421458.68</td>
      <td width="200">257462.33</td>
      <td width="380">0.6109</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">111.2</td>
      <td width="200">83.66</td>
      <td width="380">0.7523</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">27452.16</td>
      <td width="200">36495.26</td>
      <td width="380">0.7522</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">92184.0</td>
      <td width="200">46599.0</td>
      <td width="380">1.9782</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99999351469111</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">2</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1140.2</td>
      <td width="200">1633.96</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3214.26</td>
      <td width="200">2150.69</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">455457.26</td>
      <td width="200">342654.78</td>
      <td width="380">0.7523</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">167.82</td>
      <td width="200">47.29</td>
      <td width="380">0.2818</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14548.38</td>
      <td width="200">53629.51</td>
      <td width="380">0.2713</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">15759.0</td>
      <td width="200">123788.0</td>
      <td width="380">0.1273</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3249.33</td>
      <td width="200">884.29</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2071.19</td>
      <td width="200">1707.35</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">687401.3</td>
      <td width="200">193700.88</td>
      <td width="380">0.2818</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">143.41</td>
      <td width="200">86.83</td>
      <td width="380">0.6055</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">43391.88</td>
      <td width="200">71750.1</td>
      <td width="380">0.6048</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">123390.0</td>
      <td width="200">135643.0</td>
      <td width="380">0.9097</td>
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
      <td width="200">1638.04</td>
      <td width="200">1310.48</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2942.79</td>
      <td width="200">3085.29</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">587413.69</td>
      <td width="200">355640.6</td>
      <td width="380">0.6054</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">82.06</td>
      <td width="200">35.9</td>
      <td width="380">0.4375</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">30383.45</td>
      <td width="200">70268.99</td>
      <td width="380">0.4324</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">117151.0</td>
      <td width="200">121451.0</td>
      <td width="380">0.9646</td>
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
      <td width="200">2541.36</td>
      <td width="200">832.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1540.54</td>
      <td width="200">1196.86</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">336110.39</td>
      <td width="200">147036.89</td>
      <td width="380">0.4375</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">124.18</td>
      <td width="200">75.79</td>
      <td width="380">0.6103</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">50649.47</td>
      <td width="200">83792.17</td>
      <td width="380">0.6045</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">128640.0</td>
      <td width="200">137755.0</td>
      <td width="380">0.9338</td>
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
      <td width="200">2957.25</td>
      <td width="200">1992.23</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2787.45</td>
      <td width="200">2939.53</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">508657.72</td>
      <td width="200">310450.73</td>
      <td width="380">0.6103</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">80.8</td>
      <td width="200">91.16</td>
      <td width="380">1.1282</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">6133.65</td>
      <td width="200">5457.72</td>
      <td width="380">1.1238</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">8351.0</td>
      <td width="200">9002.0</td>
      <td width="380">0.9277</td>
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
      <td width="200">151.53</td>
      <td width="200">151.61</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">237.82</td>
      <td width="200">494.4</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">82738.29</td>
      <td width="200">93344.22</td>
      <td width="380">1.1282</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">109.96</td>
      <td width="200">92.68</td>
      <td width="380">0.8429</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">11189.39</td>
      <td width="200">13258.82</td>
      <td width="380">0.8439</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">18505.0</td>
      <td width="200">21916.0</td>
      <td width="380">0.8444</td>
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
      <td width="200">147.87</td>
      <td width="200">154.2</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">276.92</td>
      <td width="200">478.78</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">112598.77</td>
      <td width="200">94904.4</td>
      <td width="380">0.8429</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">518.92</td>
      <td width="200">320.27</td>
      <td width="380">0.6172</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">9414.86</td>
      <td width="200">15542.09</td>
      <td width="380">0.6058</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">10828.0</td>
      <td width="200">105186.0</td>
      <td width="380">0.1029</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1703.07</td>
      <td width="200">1195.44</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1400.31</td>
      <td width="200">3187.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">531370.61</td>
      <td width="200">327960.97</td>
      <td width="380">0.6172</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">548.67</td>
      <td width="200">343.6</td>
      <td width="380">0.6262</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">22252.57</td>
      <td width="200">35544.58</td>
      <td width="380">0.626</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">56905.0</td>
      <td width="200">122176.0</td>
      <td width="380">0.4658</td>
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
      <td width="200">1620.49</td>
      <td width="200">1216.68</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1863.48</td>
      <td width="200">3444.43</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">561834.81</td>
      <td width="200">351842.23</td>
      <td width="380">0.6262</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">653.99</td>
      <td width="200">158.27</td>
      <td width="380">0.242</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14932.82</td>
      <td width="200">63855.72</td>
      <td width="380">0.2339</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">15925.0</td>
      <td width="200">122363.0</td>
      <td width="380">0.1301</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3254.13</td>
      <td width="200">667.51</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1996.54</td>
      <td width="200">1508.78</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">669688.31</td>
      <td width="200">162067.09</td>
      <td width="380">0.242</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">663.16</td>
      <td width="200">323.7</td>
      <td width="380">0.4881</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">36811.75</td>
      <td width="200">77936.53</td>
      <td width="380">0.4723</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">40183.0</td>
      <td width="200">138151.0</td>
      <td width="380">0.2909</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99791841556632</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">621</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3209.95</td>
      <td width="200">1264.1</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1995.88</td>
      <td width="200">3180.9</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">679072.38</td>
      <td width="200">331471.37</td>
      <td width="380">0.4881</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">361.38</td>
      <td width="200">149.79</td>
      <td width="380">0.4145</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">27711.62</td>
      <td width="200">67532.23</td>
      <td width="380">0.4103</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">116653.0</td>
      <td width="200">122281.0</td>
      <td width="380">0.954</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.9994415278956</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">186</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2916.73</td>
      <td width="200">965.28</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1773.18</td>
      <td width="200">1292.35</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">370055.21</td>
      <td width="200">153384.19</td>
      <td width="380">0.4145</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">483.1</td>
      <td width="200">287.24</td>
      <td width="380">0.5946</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">52164.24</td>
      <td width="200">85820.47</td>
      <td width="380">0.6078</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">128786.0</td>
      <td width="200">135525.0</td>
      <td width="380">0.9503</td>
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
      <td width="200">3071.59</td>
      <td width="200">1644.85</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2757.16</td>
      <td width="200">2759.51</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">494692.81</td>
      <td width="200">294136.78</td>
      <td width="380">0.5946</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">297.72</td>
      <td width="200">354.61</td>
      <td width="380">1.1911</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">6560.55</td>
      <td width="200">5509.88</td>
      <td width="380">1.1907</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">11035.0</td>
      <td width="200">10186.0</td>
      <td width="380">1.0833</td>
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
      <td width="200">138.33</td>
      <td width="200">149.93</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">253.1</td>
      <td width="200">556.78</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">76216.73</td>
      <td width="200">90780.22</td>
      <td width="380">1.1911</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">282.06</td>
      <td width="200">342.94</td>
      <td width="380">1.2158</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">17313.52</td>
      <td width="200">14239.34</td>
      <td width="380">1.2159</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">22908.0</td>
      <td width="200">23929.0</td>
      <td width="380">0.9573</td>
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
      <td width="200">145.01</td>
      <td width="200">150.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">236.11</td>
      <td width="200">544.11</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">72206.68</td>
      <td width="200">87791.91</td>
      <td width="380">1.2158</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2025.45</td>
      <td width="200">812.77</td>
      <td width="380">0.4013</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">9641.95</td>
      <td width="200">24046.99</td>
      <td width="380">0.401</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">27478.0</td>
      <td width="200">117065.0</td>
      <td width="380">0.2347</td>
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
      <td width="200">1554.71</td>
      <td width="200">697.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3346.96</td>
      <td width="200">1982.46</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">518515.1</td>
      <td width="200">208068.43</td>
      <td width="380">0.4013</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2093.21</td>
      <td width="200">1014.18</td>
      <td width="380">0.4845</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">23323.22</td>
      <td width="200">48189.64</td>
      <td width="380">0.484</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">53328.0</td>
      <td width="200">128618.0</td>
      <td width="380">0.4146</td>
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
      <td width="200">1695.82</td>
      <td width="200">712.71</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2340.1</td>
      <td width="200">2604.2</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">535860.86</td>
      <td width="200">259630.96</td>
      <td width="380">0.4845</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2374.41</td>
      <td width="200">1042.61</td>
      <td width="380">0.4391</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">16448.13</td>
      <td width="200">37491.27</td>
      <td width="380">0.4387</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">105573.0</td>
      <td width="200">125429.0</td>
      <td width="380">0.8417</td>
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
      <td width="200">2718.15</td>
      <td width="200">1601.4</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4599.07</td>
      <td width="200">2629.72</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">607848.69</td>
      <td width="200">266907.2</td>
      <td width="380">0.4391</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2208.12</td>
      <td width="200">1446.11</td>
      <td width="380">0.6549</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">44251.04</td>
      <td width="200">67506.52</td>
      <td width="380">0.6555</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">128733.0</td>
      <td width="200">143057.0</td>
      <td width="380">0.8999</td>
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
      <td width="200">1875.21</td>
      <td width="200">1671.99</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3248.07</td>
      <td width="200">3589.02</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">565278.07</td>
      <td width="200">370203.92</td>
      <td width="380">0.6549</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2026.46</td>
      <td width="200">872.88</td>
      <td width="380">0.4307</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">19291.29</td>
      <td width="200">44841.13</td>
      <td width="380">0.4302</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">114805.0</td>
      <td width="200">124170.0</td>
      <td width="380">0.9246</td>
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
      <td width="200">3907.56</td>
      <td width="200">1616.79</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2949.28</td>
      <td width="200">2040.55</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">518772.76</td>
      <td width="200">223458.4</td>
      <td width="380">0.4307</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1977.34</td>
      <td width="200">1255.84</td>
      <td width="380">0.6351</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">49358.35</td>
      <td width="200">77752.41</td>
      <td width="380">0.6348</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">126603.0</td>
      <td width="200">136859.0</td>
      <td width="380">0.9251</td>
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
      <td width="200">3126.85</td>
      <td width="200">2119.63</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2959.7</td>
      <td width="200">3082.62</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">506199.48</td>
      <td width="200">321493.94</td>
      <td width="380">0.6351</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">513.68</td>
      <td width="200">663.79</td>
      <td width="380">1.2922</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">7604.75</td>
      <td width="200">5886.85</td>
      <td width="380">1.2918</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">13384.0</td>
      <td width="200">11637.0</td>
      <td width="380">1.1501</td>
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
      <td width="200">149.5</td>
      <td width="200">147.51</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">216.4</td>
      <td width="200">488.69</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">65751.67</td>
      <td width="200">84965.12</td>
      <td width="380">1.2922</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">464.74</td>
      <td width="200">671.18</td>
      <td width="380">1.4442</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">21015.16</td>
      <td width="200">14552.26</td>
      <td width="380">1.4441</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">26946.0</td>
      <td width="200">20622.0</td>
      <td width="380">1.3067</td>
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
      <td width="200">159.82</td>
      <td width="200">147.04</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">199.16</td>
      <td width="200">469.48</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">59486.72</td>
      <td width="200">85911.37</td>
      <td width="380">1.4442</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4051.27</td>
      <td width="200">2766.89</td>
      <td width="380">0.683</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">9641.38</td>
      <td width="200">14116.56</td>
      <td width="380">0.683</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">11979.0</td>
      <td width="200">22985.0</td>
      <td width="380">0.5212</td>
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
      <td width="200">1795.85</td>
      <td width="200">1715.68</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1723.18</td>
      <td width="200">2288.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">518563.18</td>
      <td width="200">354162.29</td>
      <td width="380">0.683</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">3812.93</td>
      <td width="200">3066.34</td>
      <td width="380">0.8042</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">25610.8</td>
      <td width="200">31850.62</td>
      <td width="380">0.8041</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">29536.0</td>
      <td width="200">45021.0</td>
      <td width="380">0.656</td>
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
      <td width="200">1767.72</td>
      <td width="200">1750.32</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1824.55</td>
      <td width="200">2998.32</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">488054.61</td>
      <td width="200">392491.99</td>
      <td width="380">0.8042</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4131.44</td>
      <td width="200">1826.93</td>
      <td width="380">0.4422</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">18910.84</td>
      <td width="200">42819.14</td>
      <td width="380">0.4416</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">102567.0</td>
      <td width="200">124108.0</td>
      <td width="380">0.8264</td>
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
      <td width="200">2436.21</td>
      <td width="200">986.79</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4561.12</td>
      <td width="200">2203.11</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">528824.03</td>
      <td width="200">233847.56</td>
      <td width="380">0.4422</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6079.6</td>
      <td width="200">3178.88</td>
      <td width="380">0.5229</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">32136.05</td>
      <td width="200">60935.3</td>
      <td width="380">0.5274</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">110889.0</td>
      <td width="200">144605.0</td>
      <td width="380">0.7668</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.66048884544408</td>
      <td width="380">0.9966</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">124755</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2863.95</td>
      <td width="200">2161.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4740.97</td>
      <td width="200">4078.17</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">778189.02</td>
      <td width="200">406896.93</td>
      <td width="380">0.5229</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4645.55</td>
      <td width="200">1781.08</td>
      <td width="380">0.3834</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">16825.07</td>
      <td width="200">43937.22</td>
      <td width="380">0.3829</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">113331.0</td>
      <td width="200">124366.0</td>
      <td width="380">0.9113</td>
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
      <td width="200">4679.37</td>
      <td width="200">1725.47</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3695.09</td>
      <td width="200">2039.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">594630.66</td>
      <td width="200">227978.43</td>
      <td width="380">0.3834</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4308.73</td>
      <td width="200">2424.63</td>
      <td width="380">0.5627</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">45337.27</td>
      <td width="200">80591.63</td>
      <td width="380">0.5626</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">127261.0</td>
      <td width="200">137183.0</td>
      <td width="380">0.9277</td>
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
      <td width="200">3836.29</td>
      <td width="200">1884.6</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3614.67</td>
      <td width="200">2982.28</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">551517.19</td>
      <td width="200">310352.52</td>
      <td width="380">0.5627</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">694.44</td>
      <td width="200">1142.21</td>
      <td width="380">1.6448</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">11252.62</td>
      <td width="200">6840.58</td>
      <td width="380">1.645</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">17132.0</td>
      <td width="200">11598.0</td>
      <td width="380">1.4772</td>
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
      <td width="200">163.93</td>
      <td width="200">137.36</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">199.84</td>
      <td width="200">459.84</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">44444.06</td>
      <td width="200">73101.36</td>
      <td width="380">1.6448</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">777.3</td>
      <td width="200">1083.45</td>
      <td width="380">1.3939</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">25130.26</td>
      <td width="200">18030.28</td>
      <td width="380">1.3938</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">33216.0</td>
      <td width="200">24207.0</td>
      <td width="380">1.3722</td>
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
      <td width="200">157.84</td>
      <td width="200">135.9</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">218.04</td>
      <td width="200">424.26</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">49747.38</td>
      <td width="200">69340.68</td>
      <td width="380">1.3939</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6719.91</td>
      <td width="200">5847.95</td>
      <td width="380">0.8702</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">11625.27</td>
      <td width="200">13357.71</td>
      <td width="380">0.8703</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">16114.0</td>
      <td width="200">21138.0</td>
      <td width="380">0.7623</td>
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
      <td width="200">1794.88</td>
      <td width="200">1758.69</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1634.61</td>
      <td width="200">2681.05</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">430074.52</td>
      <td width="200">374268.5</td>
      <td width="380">0.8702</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6813.12</td>
      <td width="200">6346.87</td>
      <td width="380">0.9316</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">28665.34</td>
      <td width="200">30775.96</td>
      <td width="380">0.9314</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">38183.0</td>
      <td width="200">110579.0</td>
      <td width="380">0.3453</td>
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
      <td width="200">1761.84</td>
      <td width="200">1438.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1496.8</td>
      <td width="200">4280.61</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">436039.78</td>
      <td width="200">406199.77</td>
      <td width="380">0.9316</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10218.64</td>
      <td width="200">3631.99</td>
      <td width="380">0.3554</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">15288.09</td>
      <td width="200">43053.31</td>
      <td width="380">0.3551</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">16179.0</td>
      <td width="200">123354.0</td>
      <td width="380">0.1312</td>
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
      <td width="200">3327.71</td>
      <td width="200">949.25</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2396.61</td>
      <td width="200">2280.3</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">653993.1</td>
      <td width="200">232447.18</td>
      <td width="380">0.3554</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10368.58</td>
      <td width="200">5662.96</td>
      <td width="380">0.5462</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">37666.29</td>
      <td width="200">69005.02</td>
      <td width="380">0.5458</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">38958.0</td>
      <td width="200">143518.0</td>
      <td width="380">0.2715</td>
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
      <td width="200">3299.0</td>
      <td width="200">1668.53</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2360.83</td>
      <td width="200">3614.02</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">663588.97</td>
      <td width="200">362429.2</td>
      <td width="380">0.5462</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10151.77</td>
      <td width="200">3820.56</td>
      <td width="380">0.3763</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">15393.1</td>
      <td width="200">40925.38</td>
      <td width="380">0.3761</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">112732.0</td>
      <td width="200">123628.0</td>
      <td width="380">0.9119</td>
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
      <td width="200">5607.15</td>
      <td width="200">1990.66</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">5086.49</td>
      <td width="200">2226.46</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">649713.31</td>
      <td width="200">244516.16</td>
      <td width="380">0.3763</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10330.25</td>
      <td width="200">5028.78</td>
      <td width="380">0.4868</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">37819.88</td>
      <td width="200">77695.51</td>
      <td width="380">0.4868</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">124279.0</td>
      <td width="200">136977.0</td>
      <td width="380">0.9073</td>
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
      <td width="200">5293.13</td>
      <td width="200">2295.53</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4957.97</td>
      <td width="200">3187.7</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">661136.22</td>
      <td width="200">321842.21</td>
      <td width="380">0.4868</td>
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
      <td width="200">156.24</td>
      <td width="200">181.77</td>
      <td width="380">1.1634</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">6331.08</td>
      <td width="200">5450.31</td>
      <td width="380">1.1616</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">7723.0</td>
      <td width="200">9094.0</td>
      <td width="380">0.8492</td>
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
      <td width="200">152.42</td>
      <td width="200">151.19</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">235.32</td>
      <td width="200">548.83</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">79993.82</td>
      <td width="200">93065.94</td>
      <td width="380">1.1634</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">219.55</td>
      <td width="200">184.03</td>
      <td width="380">0.8382</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">11196.18</td>
      <td width="200">13346.24</td>
      <td width="380">0.8389</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">18379.0</td>
      <td width="200">21891.0</td>
      <td width="380">0.8396</td>
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
      <td width="200">147.19</td>
      <td width="200">152.82</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">306.75</td>
      <td width="200">520.95</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">112409.33</td>
      <td width="200">94221.04</td>
      <td width="380">0.8382</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">730.76</td>
      <td width="200">247.77</td>
      <td width="380">0.3391</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">13375.2</td>
      <td width="200">40791.47</td>
      <td width="380">0.3279</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">38554.0</td>
      <td width="200">117609.0</td>
      <td width="380">0.3278</td>
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
      <td width="200">984.7</td>
      <td width="200">362.74</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3762.03</td>
      <td width="200">1136.52</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">374150.18</td>
      <td width="200">126860.39</td>
      <td width="380">0.3391</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1206.06</td>
      <td width="200">491.2</td>
      <td width="380">0.4073</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">20250.83</td>
      <td width="200">51621.37</td>
      <td width="380">0.3923</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">27814.0</td>
      <td width="200">124862.0</td>
      <td width="380">0.2228</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1700.88</td>
      <td width="200">673.58</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1916.35</td>
      <td width="200">2393.91</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">617500.5</td>
      <td width="200">251493.48</td>
      <td width="380">0.4073</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1262.21</td>
      <td width="200">295.16</td>
      <td width="380">0.2338</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">15473.24</td>
      <td width="200">67428.32</td>
      <td width="380">0.2295</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">16279.0</td>
      <td width="200">122313.0</td>
      <td width="380">0.1331</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99999264770972</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">1</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3240.97</td>
      <td width="200">553.22</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1982.91</td>
      <td width="200">1418.21</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">646252.83</td>
      <td width="200">151124.48</td>
      <td width="380">0.2338</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1479.65</td>
      <td width="200">678.73</td>
      <td width="380">0.4587</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">32995.02</td>
      <td width="200">73086.06</td>
      <td width="380">0.4515</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">38350.0</td>
      <td width="200">137315.0</td>
      <td width="380">0.2793</td>
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
      <td width="200">3228.21</td>
      <td width="200">1387.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2371.37</td>
      <td width="200">3315.92</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">757578.81</td>
      <td width="200">347509.2</td>
      <td width="380">0.4587</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">878.88</td>
      <td width="200">295.02</td>
      <td width="380">0.3357</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">22879.93</td>
      <td width="200">68474.66</td>
      <td width="380">0.3341</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">115000.0</td>
      <td width="200">121596.0</td>
      <td width="380">0.9458</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.9997234492379</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">112</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3836.2</td>
      <td width="200">933.81</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2072.22</td>
      <td width="200">1275.8</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">449986.47</td>
      <td width="200">151052.57</td>
      <td width="380">0.3357</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">989.95</td>
      <td width="200">626.13</td>
      <td width="380">0.6325</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">50975.94</td>
      <td width="200">80610.69</td>
      <td width="380">0.6324</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">125922.0</td>
      <td width="200">136070.0</td>
      <td width="380">0.9254</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2549.06</td>
      <td width="200">2213.35</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2539.15</td>
      <td width="200">3064.05</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">506854.89</td>
      <td width="200">320580.71</td>
      <td width="380">0.6325</td>
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
      <td width="200">75.62</td>
      <td width="200">92.53</td>
      <td width="380">1.2236</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">6543.68</td>
      <td width="200">5348.54</td>
      <td width="380">1.2235</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">9038.0</td>
      <td width="200">8904.0</td>
      <td width="380">1.015</td>
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
      <td width="200">150.79</td>
      <td width="200">152.01</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">223.78</td>
      <td width="200">528.99</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">77433.09</td>
      <td width="200">94750.43</td>
      <td width="380">1.2236</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">81.46</td>
      <td width="200">97.03</td>
      <td width="380">1.1911</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">15083.96</td>
      <td width="200">12660.85</td>
      <td width="380">1.1914</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">25374.0</td>
      <td width="200">21211.0</td>
      <td width="380">1.1963</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99998881731473</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">1</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">155.94</td>
      <td width="200">154.19</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">226.07</td>
      <td width="200">522.09</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">83411.27</td>
      <td width="200">99359.94</td>
      <td width="380">1.1912</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">552.46</td>
      <td width="200">338.75</td>
      <td width="380">0.6132</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8847.45</td>
      <td width="200">14433.1</td>
      <td width="380">0.613</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">15396.0</td>
      <td width="200">20943.0</td>
      <td width="380">0.7351</td>
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
      <td width="200">1674.21</td>
      <td width="200">1644.84</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2266.26</td>
      <td width="200">2475.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">565714.94</td>
      <td width="200">346875.13</td>
      <td width="380">0.6132</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">580.86</td>
      <td width="200">336.05</td>
      <td width="380">0.5785</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">21021.26</td>
      <td width="200">36352.04</td>
      <td width="380">0.5783</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">42829.0</td>
      <td width="200">46358.0</td>
      <td width="380">0.9239</td>
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
      <td width="200">1686.02</td>
      <td width="200">1658.52</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2789.19</td>
      <td width="200">2366.42</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">594796.81</td>
      <td width="200">344116.98</td>
      <td width="380">0.5785</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">705.82</td>
      <td width="200">224.26</td>
      <td width="380">0.3177</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">13837.04</td>
      <td width="200">45099.68</td>
      <td width="380">0.3068</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">14982.0</td>
      <td width="200">123312.0</td>
      <td width="380">0.1215</td>
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
      <td width="200">3180.11</td>
      <td width="200">1211.65</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2278.06</td>
      <td width="200">2183.85</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">722764.06</td>
      <td width="200">229644.87</td>
      <td width="380">0.3177</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">708.3</td>
      <td width="200">328.63</td>
      <td width="380">0.464</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">34465.22</td>
      <td width="200">75348.21</td>
      <td width="380">0.4574</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">38163.0</td>
      <td width="200">136971.0</td>
      <td width="380">0.2786</td>
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
      <td width="200">3246.1</td>
      <td width="200">1283.12</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2135.84</td>
      <td width="200">3190.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">725296.44</td>
      <td width="200">336513.81</td>
      <td width="380">0.464</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">390.84</td>
      <td width="200">147.95</td>
      <td width="380">0.3785</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">25865.31</td>
      <td width="200">68296.96</td>
      <td width="380">0.3787</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">115825.0</td>
      <td width="200">122364.0</td>
      <td width="380">0.9466</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3350.57</td>
      <td width="200">916.22</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1872.4</td>
      <td width="200">1268.04</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">400223.27</td>
      <td width="200">151504.52</td>
      <td width="380">0.3786</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">486.6</td>
      <td width="200">286.9</td>
      <td width="380">0.5896</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">51078.2</td>
      <td width="200">87703.81</td>
      <td width="380">0.5824</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">127583.0</td>
      <td width="200">136786.0</td>
      <td width="380">0.9327</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.99860857558946</td>
      <td width="200">99.99801827153644</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">624</td>
      <td width="200">524</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2638.65</td>
      <td width="200">1661.47</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2565.9</td>
      <td width="200">2740.95</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">498283.4</td>
      <td width="200">293789.33</td>
      <td width="380">0.5896</td>
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
      <td width="200">40.14</td>
      <td width="200">48.28</td>
      <td width="380">1.2028</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">6174.78</td>
      <td width="200">5126.32</td>
      <td width="380">1.2045</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">8533.0</td>
      <td width="200">8648.0</td>
      <td width="380">0.9867</td>
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
      <td width="200">149.69</td>
      <td width="200">151.5</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">222.7</td>
      <td width="200">572.47</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">82210.79</td>
      <td width="200">98884.99</td>
      <td width="380">1.2028</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">41.88</td>
      <td width="200">51.34</td>
      <td width="380">1.2259</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14663.99</td>
      <td width="200">11957.63</td>
      <td width="380">1.2263</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">24864.0</td>
      <td width="200">19962.0</td>
      <td width="380">1.2456</td>
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
      <td width="200">153.27</td>
      <td width="200">153.95</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">234.26</td>
      <td width="200">538.97</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">85762.77</td>
      <td width="200">105148.08</td>
      <td width="380">1.226</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">295.11</td>
      <td width="200">111.57</td>
      <td width="380">0.3781</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8276.74</td>
      <td width="200">22231.53</td>
      <td width="380">0.3723</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">9779.0</td>
      <td width="200">115718.0</td>
      <td width="380">0.0845</td>
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
      <td width="200">1718.95</td>
      <td width="200">858.42</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1839.08</td>
      <td width="200">1955.34</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">604380.53</td>
      <td width="200">228489.02</td>
      <td width="380">0.3781</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">301.36</td>
      <td width="200">162.27</td>
      <td width="380">0.5385</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">20258.91</td>
      <td width="200">37643.84</td>
      <td width="380">0.5382</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">23733.0</td>
      <td width="200">123763.0</td>
      <td width="380">0.1918</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1691.45</td>
      <td width="200">1134.27</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1564.65</td>
      <td width="200">3256.84</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">617182.49</td>
      <td width="200">332326.72</td>
      <td width="380">0.5385</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">387.78</td>
      <td width="200">69.72</td>
      <td width="380">0.1798</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">12593.37</td>
      <td width="200">72144.46</td>
      <td width="380">0.1746</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">13997.0</td>
      <td width="200">121737.0</td>
      <td width="380">0.115</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3243.82</td>
      <td width="200">489.84</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2608.44</td>
      <td width="200">1309.22</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">794179.76</td>
      <td width="200">142792.29</td>
      <td width="380">0.1798</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">358.3</td>
      <td width="200">158.77</td>
      <td width="380">0.4431</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">34067.74</td>
      <td width="200">79297.31</td>
      <td width="380">0.4296</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">37788.0</td>
      <td width="200">135789.0</td>
      <td width="380">0.2783</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.99788145779075</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">620</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3232.74</td>
      <td width="200">1119.81</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2722.9</td>
      <td width="200">3028.7</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">733801.68</td>
      <td width="200">325164.3</td>
      <td width="380">0.4431</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">186.51</td>
      <td width="200">74.48</td>
      <td width="380">0.3993</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">27102.52</td>
      <td width="200">67849.09</td>
      <td width="380">0.3995</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">115387.0</td>
      <td width="200">121835.0</td>
      <td width="380">0.9471</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">99.99927571244807</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">249</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3212.28</td>
      <td width="200">997.64</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1563.79</td>
      <td width="200">1349.49</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">381981.8</td>
      <td width="200">152529.07</td>
      <td width="380">0.3993</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">252.92</td>
      <td width="200">153.15</td>
      <td width="380">0.6055</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">50362.96</td>
      <td width="200">82318.04</td>
      <td width="380">0.6118</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">126532.0</td>
      <td width="200">136279.0</td>
      <td width="380">0.9285</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2927.08</td>
      <td width="200">2052.18</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2555.68</td>
      <td width="200">2965.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">517981.02</td>
      <td width="200">313641.21</td>
      <td width="380">0.6055</td>
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
      <td width="200">309.08</td>
      <td width="200">351.12</td>
      <td width="380">1.136</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">6319.34</td>
      <td width="200">5564.11</td>
      <td width="380">1.1357</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">11241.0</td>
      <td width="200">10254.0</td>
      <td width="380">1.0963</td>
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
      <td width="200">141.65</td>
      <td width="200">152.25</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">228.63</td>
      <td width="200">517.78</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">79125.23</td>
      <td width="200">89886.83</td>
      <td width="380">1.136</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">326.53</td>
      <td width="200">157.87</td>
      <td width="380">0.4835</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14954.57</td>
      <td width="200">30933.86</td>
      <td width="380">0.4834</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">23082.0</td>
      <td width="200">39325.0</td>
      <td width="380">0.587</td>
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
      <td width="200">145.88</td>
      <td width="200">149.83</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">234.45</td>
      <td width="200">274.58</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">83592.26</td>
      <td width="200">40413.6</td>
      <td width="380">0.4835</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2293.16</td>
      <td width="200">1175.91</td>
      <td width="380">0.5128</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8516.74</td>
      <td width="200">16608.09</td>
      <td width="380">0.5128</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">11392.0</td>
      <td width="200">111326.0</td>
      <td width="380">0.1023</td>
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
      <td width="200">1736.85</td>
      <td width="200">1118.29</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1830.84</td>
      <td width="200">2836.31</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">587048.1</td>
      <td width="200">301032.37</td>
      <td width="380">0.5128</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2166.82</td>
      <td width="200">1159.58</td>
      <td width="380">0.5352</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">22530.88</td>
      <td width="200">42131.23</td>
      <td width="380">0.5348</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">27991.0</td>
      <td width="200">130646.0</td>
      <td width="380">0.2143</td>
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
      <td width="200">1744.5</td>
      <td width="200">915.83</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1702.94</td>
      <td width="200">2866.97</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">554707.03</td>
      <td width="200">296852.03</td>
      <td width="380">0.5352</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2976.23</td>
      <td width="200">882.73</td>
      <td width="380">0.2966</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">13121.86</td>
      <td width="200">44336.02</td>
      <td width="380">0.296</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">15342.0</td>
      <td width="200">123360.0</td>
      <td width="380">0.1244</td>
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
      <td width="200">3362.49</td>
      <td width="200">807.68</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2457.78</td>
      <td width="200">2154.78</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">761914.87</td>
      <td width="200">225979.81</td>
      <td width="380">0.2966</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2557.46</td>
      <td width="200">1310.14</td>
      <td width="380">0.5123</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">38170.73</td>
      <td width="200">74617.34</td>
      <td width="380">0.5116</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">41044.0</td>
      <td width="200">139096.0</td>
      <td width="380">0.2951</td>
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
      <td width="200">3310.49</td>
      <td width="200">1234.95</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2053.14</td>
      <td width="200">3183.78</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">654708.61</td>
      <td width="200">335396.21</td>
      <td width="380">0.5123</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2267.04</td>
      <td width="200">892.07</td>
      <td width="380">0.3935</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">17250.45</td>
      <td width="200">43818.36</td>
      <td width="380">0.3937</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">113876.0</td>
      <td width="200">124342.0</td>
      <td width="380">0.9158</td>
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
      <td width="200">4433.64</td>
      <td width="200">1792.43</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3262.1</td>
      <td width="200">1975.92</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">580362.67</td>
      <td width="200">228369.02</td>
      <td width="380">0.3935</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2190.62</td>
      <td width="200">1381.11</td>
      <td width="380">0.6305</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">44588.34</td>
      <td width="200">70722.28</td>
      <td width="380">0.6305</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">126442.0</td>
      <td width="200">136707.0</td>
      <td width="380">0.9249</td>
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
      <td width="200">3469.22</td>
      <td width="200">2628.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3081.47</td>
      <td width="200">3278.49</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">560798.27</td>
      <td width="200">353563.34</td>
      <td width="380">0.6305</td>
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
      <td width="200">148.22</td>
      <td width="200">185.81</td>
      <td width="380">1.2536</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">6686.76</td>
      <td width="200">5332.72</td>
      <td width="380">1.2539</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">8640.0</td>
      <td width="200">8979.0</td>
      <td width="380">0.9622</td>
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
      <td width="200">156.25</td>
      <td width="200">152.01</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">225.89</td>
      <td width="200">524.55</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">75891.14</td>
      <td width="200">95132.23</td>
      <td width="380">1.2535</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">218.68</td>
      <td width="200">184.74</td>
      <td width="380">0.8448</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">11239.05</td>
      <td width="200">13305.4</td>
      <td width="380">0.8447</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">18651.0</td>
      <td width="200">21606.0</td>
      <td width="380">0.8632</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">99.9999882527671</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">1</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">150.42</td>
      <td width="200">154.82</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">294.31</td>
      <td width="200">490.7</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">111964.52</td>
      <td width="200">94584.91</td>
      <td width="380">0.8448</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1070.78</td>
      <td width="200">668.52</td>
      <td width="380">0.6243</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">9124.61</td>
      <td width="200">14625.47</td>
      <td width="380">0.6239</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">10841.0</td>
      <td width="200">78076.0</td>
      <td width="380">0.1389</td>
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
      <td width="200">1704.27</td>
      <td width="200">1541.41</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1526.62</td>
      <td width="200">2699.92</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">548239.14</td>
      <td width="200">342281.73</td>
      <td width="380">0.6243</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1057.4</td>
      <td width="200">667.17</td>
      <td width="380">0.631</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">23093.87</td>
      <td width="200">36614.61</td>
      <td width="380">0.6307</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">26511.0</td>
      <td width="200">44679.0</td>
      <td width="380">0.5934</td>
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
      <td width="200">1697.5</td>
      <td width="200">1658.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1406.01</td>
      <td width="200">2240.67</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">541389.84</td>
      <td width="200">341591.86</td>
      <td width="380">0.631</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">778.19</td>
      <td width="200">707.62</td>
      <td width="380">0.9093</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">25099.91</td>
      <td width="200">28724.95</td>
      <td width="380">0.8738</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">113490.0</td>
      <td width="200">121050.0</td>
      <td width="380">0.9375</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="200">越大越好</td>
      <td width="200">100.0</td>
      <td width="200">100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="200">仅展示</td>
      <td width="200">0</td>
      <td width="200">0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1208.98</td>
      <td width="200">2081.83</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1719.47</td>
      <td width="200">3463.21</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">398431.09</td>
      <td width="200">362303.89</td>
      <td width="380">0.9093</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1375.94</td>
      <td width="200">824.81</td>
      <td width="380">0.5995</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">35482.56</td>
      <td width="200">59937.87</td>
      <td width="380">0.592</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">120150.0</td>
      <td width="200">149046.0</td>
      <td width="380">0.8061</td>
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
      <td width="200">2162.49</td>
      <td width="200">2289.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3779.07</td>
      <td width="200">4072.85</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">704481.92</td>
      <td width="200">422304.63</td>
      <td width="380">0.5995</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">795.14</td>
      <td width="200">351.68</td>
      <td width="380">0.4423</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">24953.67</td>
      <td width="200">57713.35</td>
      <td width="380">0.4324</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">115799.0</td>
      <td width="200">122508.0</td>
      <td width="380">0.9452</td>
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
      <td width="200">3387.76</td>
      <td width="200">1302.89</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1826.46</td>
      <td width="200">1315.01</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">407109.73</td>
      <td width="200">180060.72</td>
      <td width="380">0.4423</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1015.59</td>
      <td width="200">640.78</td>
      <td width="380">0.6309</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">49883.65</td>
      <td width="200">78635.83</td>
      <td width="380">0.6344</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">127830.0</td>
      <td width="200">137966.0</td>
      <td width="380">0.9265</td>
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
      <td width="200">2917.52</td>
      <td width="200">2176.16</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2694.87</td>
      <td width="200">3013.02</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">519982.79</td>
      <td width="200">328078.68</td>
      <td width="380">0.6309</td>
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
      <td width="200">482.63</td>
      <td width="200">683.29</td>
      <td width="380">1.4158</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">8095.43</td>
      <td width="200">5718.52</td>
      <td width="380">1.4157</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">12655.0</td>
      <td width="200">10670.0</td>
      <td width="380">1.186</td>
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
      <td width="200">157.02</td>
      <td width="200">148.17</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">205.42</td>
      <td width="200">524.97</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">61776.84</td>
      <td width="200">87460.49</td>
      <td width="380">1.4157</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">474.75</td>
      <td width="200">647.49</td>
      <td width="380">1.3639</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">20573.09</td>
      <td width="200">15084.5</td>
      <td width="380">1.3639</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">26221.0</td>
      <td width="200">32753.0</td>
      <td width="380">0.8006</td>
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
      <td width="200">165.0</td>
      <td width="200">146.26</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">194.03</td>
      <td width="200">482.5</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">60768.2</td>
      <td width="200">82878.94</td>
      <td width="380">1.3639</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">3794.48</td>
      <td width="200">2618.02</td>
      <td width="380">0.69</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">10293.5</td>
      <td width="200">14919.21</td>
      <td width="380">0.6899</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">12015.0</td>
      <td width="200">98862.0</td>
      <td width="380">0.1215</td>
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
      <td width="200">1778.91</td>
      <td width="200">1586.46</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1480.81</td>
      <td width="200">2674.55</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">485693.69</td>
      <td width="200">335106.71</td>
      <td width="380">0.69</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">3650.15</td>
      <td width="200">2585.46</td>
      <td width="380">0.7083</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">26752.66</td>
      <td width="200">37788.25</td>
      <td width="380">0.708</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">29689.0</td>
      <td width="200">126084.0</td>
      <td width="380">0.2355</td>
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
      <td width="200">1747.59</td>
      <td width="200">1116.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1372.37</td>
      <td width="200">3306.14</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">467219.61</td>
      <td width="200">330939.13</td>
      <td width="380">0.7083</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4899.75</td>
      <td width="200">1959.21</td>
      <td width="380">0.3999</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">15941.75</td>
      <td width="200">39877.83</td>
      <td width="380">0.3998</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">16524.0</td>
      <td width="200">125816.0</td>
      <td width="380">0.1313</td>
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
      <td width="200">3326.37</td>
      <td width="200">1487.13</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2088.53</td>
      <td width="200">2483.52</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">627167.92</td>
      <td width="200">250778.49</td>
      <td width="380">0.3999</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">5771.44</td>
      <td width="200">3382.92</td>
      <td width="380">0.5861</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">33832.2</td>
      <td width="200">57725.81</td>
      <td width="380">0.5861</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">38816.0</td>
      <td width="200">145074.0</td>
      <td width="380">0.2676</td>
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
      <td width="200">3281.09</td>
      <td width="200">2589.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2456.15</td>
      <td width="200">4479.79</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">738744.76</td>
      <td width="200">433013.19</td>
      <td width="380">0.5861</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">5300.72</td>
      <td width="200">1782.85</td>
      <td width="380">0.3363</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14750.83</td>
      <td width="200">43831.23</td>
      <td width="380">0.3365</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">112267.0</td>
      <td width="200">123774.0</td>
      <td width="380">0.907</td>
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
      <td width="200">4900.3</td>
      <td width="200">1697.96</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4144.95</td>
      <td width="200">2143.9</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">678492.5</td>
      <td width="200">228204.19</td>
      <td width="380">0.3363</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4474.05</td>
      <td width="200">2620.66</td>
      <td width="380">0.5857</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">43683.34</td>
      <td width="200">74528.17</td>
      <td width="380">0.5861</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">127005.0</td>
      <td width="200">136826.0</td>
      <td width="380">0.9282</td>
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
      <td width="200">3891.67</td>
      <td width="200">2590.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3449.74</td>
      <td width="200">3325.65</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">572678.7</td>
      <td width="200">335444.32</td>
      <td width="380">0.5857</td>
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
      <td width="200">714.43</td>
      <td width="200">1086.58</td>
      <td width="380">1.5209</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">10936.61</td>
      <td width="200">7192.11</td>
      <td width="380">1.5206</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">16543.0</td>
      <td width="200">14990.0</td>
      <td width="380">1.1036</td>
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
      <td width="200">171.23</td>
      <td width="200">137.85</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">206.66</td>
      <td width="200">468.04</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">45723.8</td>
      <td width="200">69541.18</td>
      <td width="380">1.5209</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">742.99</td>
      <td width="200">956.37</td>
      <td width="380">1.2872</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">26290.29</td>
      <td width="200">20423.75</td>
      <td width="380">1.2872</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">34097.0</td>
      <td width="200">44714.0</td>
      <td width="380">0.7626</td>
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
      <td width="200">166.81</td>
      <td width="200">135.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">212.57</td>
      <td width="200">413.42</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">47551.66</td>
      <td width="200">61207.76</td>
      <td width="380">1.2872</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6502.21</td>
      <td width="200">4494.79</td>
      <td width="380">0.6913</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">12014.24</td>
      <td width="200">17380.77</td>
      <td width="380">0.6912</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">15975.0</td>
      <td width="200">111498.0</td>
      <td width="380">0.1433</td>
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
      <td width="200">1778.44</td>
      <td width="200">1129.17</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1622.98</td>
      <td width="200">2641.2</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">416141.74</td>
      <td width="200">287666.88</td>
      <td width="380">0.6913</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">5851.39</td>
      <td width="200">5289.14</td>
      <td width="380">0.9039</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">33376.68</td>
      <td width="200">36929.29</td>
      <td width="380">0.9038</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">37531.0</td>
      <td width="200">59453.0</td>
      <td width="380">0.6313</td>
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
      <td width="200">1719.03</td>
      <td width="200">1662.07</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1469.94</td>
      <td width="200">2308.22</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">374489.01</td>
      <td width="200">338505.19</td>
      <td width="380">0.9039</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">9751.0</td>
      <td width="200">3827.77</td>
      <td width="380">0.3926</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">16021.46</td>
      <td width="200">40872.73</td>
      <td width="380">0.392</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">17379.0</td>
      <td width="200">123278.0</td>
      <td width="380">0.141</td>
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
      <td width="200">3370.59</td>
      <td width="200">1058.86</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4320.53</td>
      <td width="200">2326.97</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">624064.0</td>
      <td width="200">244977.32</td>
      <td width="380">0.3926</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10896.75</td>
      <td width="200">5694.96</td>
      <td width="380">0.5226</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">35842.32</td>
      <td width="200">68610.82</td>
      <td width="380">0.5224</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">39304.0</td>
      <td width="200">141196.0</td>
      <td width="380">0.2784</td>
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
      <td width="200">3280.32</td>
      <td width="200">1526.92</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4910.4</td>
      <td width="200">3604.5</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">697391.84</td>
      <td width="200">364477.33</td>
      <td width="380">0.5226</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10021.86</td>
      <td width="200">3522.24</td>
      <td width="380">0.3515</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">15609.21</td>
      <td width="200">44451.24</td>
      <td width="380">0.3512</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">112545.0</td>
      <td width="200">124304.0</td>
      <td width="380">0.9054</td>
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
      <td width="200">5259.98</td>
      <td width="200">1766.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4805.25</td>
      <td width="200">2183.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">641398.97</td>
      <td width="200">225423.23</td>
      <td width="380">0.3515</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10098.4</td>
      <td width="200">4939.29</td>
      <td width="380">0.4891</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">38706.53</td>
      <td width="200">79139.22</td>
      <td width="380">0.4891</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">123073.0</td>
      <td width="200">135705.0</td>
      <td width="380">0.9069</td>
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
      <td width="200">5361.45</td>
      <td width="200">1962.78</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">5088.71</td>
      <td width="200">3044.4</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">646297.87</td>
      <td width="200">316114.26</td>
      <td width="380">0.4891</td>
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
      <td width="200">678.84</td>
      <td width="200">1108.38</td>
      <td width="380">1.6328</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">11511.12</td>
      <td width="200">7049.88</td>
      <td width="380">1.6328</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">17884.0</td>
      <td width="200">15693.0</td>
      <td width="380">1.1396</td>
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
      <td width="200">165.4</td>
      <td width="200">137.36</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">201.62</td>
      <td width="200">472.25</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">43445.69</td>
      <td width="200">70936.17</td>
      <td width="380">1.6328</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">750.28</td>
      <td width="200">896.81</td>
      <td width="380">1.1953</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">26037.03</td>
      <td width="200">21782.48</td>
      <td width="380">1.1953</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">35821.0</td>
      <td width="200">44434.0</td>
      <td width="380">0.8062</td>
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
      <td width="200">155.07</td>
      <td width="200">134.75</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">212.16</td>
      <td width="200">367.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">48017.62</td>
      <td width="200">57395.79</td>
      <td width="380">1.1953</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6152.77</td>
      <td width="200">5980.4</td>
      <td width="380">0.972</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">12696.66</td>
      <td width="200">13062.3</td>
      <td width="380">0.972</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">15809.0</td>
      <td width="200">92527.0</td>
      <td width="380">0.1709</td>
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
      <td width="200">1746.26</td>
      <td width="200">1535.49</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1695.0</td>
      <td width="200">3304.32</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">393777.01</td>
      <td width="200">382745.49</td>
      <td width="380">0.972</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">6755.84</td>
      <td width="200">4955.08</td>
      <td width="380">0.7335</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">28908.86</td>
      <td width="200">39417.89</td>
      <td width="380">0.7334</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">39225.0</td>
      <td width="200">49640.0</td>
      <td width="380">0.7902</td>
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
      <td width="200">1795.99</td>
      <td width="200">1746.45</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">1842.45</td>
      <td width="200">1887.51</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">432374.08</td>
      <td width="200">317124.89</td>
      <td width="380">0.7335</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10858.53</td>
      <td width="200">3985.84</td>
      <td width="380">0.3671</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14387.31</td>
      <td width="200">39225.83</td>
      <td width="380">0.3668</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">16398.0</td>
      <td width="200">124344.0</td>
      <td width="380">0.1319</td>
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
      <td width="200">3416.8</td>
      <td width="200">1437.09</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">5345.15</td>
      <td width="200">2495.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">694946.08</td>
      <td width="200">255093.76</td>
      <td width="380">0.3671</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">11385.07</td>
      <td width="200">5751.57</td>
      <td width="380">0.5052</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">34304.92</td>
      <td width="200">67968.82</td>
      <td width="380">0.5047</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">39086.0</td>
      <td width="200">140903.0</td>
      <td width="380">0.2774</td>
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
      <td width="200">3317.38</td>
      <td width="200">1535.98</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">5347.99</td>
      <td width="200">3634.41</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">728644.18</td>
      <td width="200">368100.49</td>
      <td width="380">0.5052</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">10016.62</td>
      <td width="200">3561.08</td>
      <td width="380">0.3555</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">15619.17</td>
      <td width="200">43873.95</td>
      <td width="380">0.356</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">112679.0</td>
      <td width="200">124135.0</td>
      <td width="380">0.9077</td>
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
      <td width="200">5202.14</td>
      <td width="200">1862.24</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4717.44</td>
      <td width="200">2158.39</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">641063.51</td>
      <td width="200">227909.29</td>
      <td width="380">0.3555</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">9924.33</td>
      <td width="200">5178.44</td>
      <td width="380">0.5218</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">39357.49</td>
      <td width="200">75400.01</td>
      <td width="380">0.522</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">123231.0</td>
      <td width="200">136240.0</td>
      <td width="380">0.9045</td>
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
      <td width="200">5286.7</td>
      <td width="200">2627.74</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4856.01</td>
      <td width="200">3349.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">635156.86</td>
      <td width="200">331420.22</td>
      <td width="380">0.5218</td>
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
      <td width="200">246.03</td>
      <td width="200">346.14</td>
      <td width="380">1.4069</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">7939.21</td>
      <td width="200">5644.29</td>
      <td width="380">1.4066</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">12249.0</td>
      <td width="200">10693.0</td>
      <td width="380">1.1455</td>
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
      <td width="200">163.31</td>
      <td width="200">154.05</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">239.3</td>
      <td width="200">561.44</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">62984.46</td>
      <td width="200">88610.61</td>
      <td width="380">1.4069</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">253.38</td>
      <td width="200">314.27</td>
      <td width="380">1.2403</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">19273.14</td>
      <td width="200">15538.42</td>
      <td width="380">1.2404</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">25379.0</td>
      <td width="200">34044.0</td>
      <td width="380">0.7455</td>
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
      <td width="200">163.85</td>
      <td width="200">151.91</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">239.55</td>
      <td width="200">523.6</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">64865.53</td>
      <td width="200">80452.22</td>
      <td width="380">1.2403</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2042.4</td>
      <td width="200">1376.66</td>
      <td width="380">0.674</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">9562.01</td>
      <td width="200">14186.1</td>
      <td width="380">0.674</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">11190.0</td>
      <td width="200">91781.0</td>
      <td width="380">0.1219</td>
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
      <td width="200">1754.7</td>
      <td width="200">1596.68</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2212.47</td>
      <td width="200">2876.75</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">522853.27</td>
      <td width="200">352423.91</td>
      <td width="380">0.674</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2152.59</td>
      <td width="200">1300.85</td>
      <td width="380">0.6043</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">22680.06</td>
      <td width="200">37535.2</td>
      <td width="380">0.6042</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">25547.0</td>
      <td width="200">45907.0</td>
      <td width="380">0.5565</td>
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
      <td width="200">1736.23</td>
      <td width="200">1714.3</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">2234.11</td>
      <td width="200">2318.38</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">551062.21</td>
      <td width="200">333016.39</td>
      <td width="380">0.6043</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2647.4</td>
      <td width="200">1167.27</td>
      <td width="380">0.4409</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">14751.96</td>
      <td width="200">33490.02</td>
      <td width="380">0.4405</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">15905.0</td>
      <td width="200">123771.0</td>
      <td width="380">0.1285</td>
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
      <td width="200">3352.08</td>
      <td width="200">1784.97</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">4597.96</td>
      <td width="200">2900.13</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">677735.44</td>
      <td width="200">298820.24</td>
      <td width="380">0.4409</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2044.06</td>
      <td width="200">1387.2</td>
      <td width="380">0.6786</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">47804.41</td>
      <td width="200">70392.54</td>
      <td width="380">0.6791</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">128022.0</td>
      <td width="200">139798.0</td>
      <td width="380">0.9158</td>
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
      <td width="200">1710.19</td>
      <td width="200">1434.25</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3167.38</td>
      <td width="200">3446.55</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">523279.21</td>
      <td width="200">355123.71</td>
      <td width="380">0.6787</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1977.99</td>
      <td width="200">858.9</td>
      <td width="380">0.4342</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">19764.81</td>
      <td width="200">45483.15</td>
      <td width="380">0.4346</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">115345.0</td>
      <td width="200">124137.0</td>
      <td width="380">0.9292</td>
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
      <td width="200">3858.56</td>
      <td width="200">1470.46</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3038.07</td>
      <td width="200">2007.85</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">506364.18</td>
      <td width="200">219877.58</td>
      <td width="380">0.4342</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1975.79</td>
      <td width="200">1366.5</td>
      <td width="380">0.6916</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="200">越小越好</td>
      <td width="200">49411.9</td>
      <td width="200">71456.76</td>
      <td width="380">0.6915</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="200">越小越好</td>
      <td width="200">126347.0</td>
      <td width="200">136486.0</td>
      <td width="380">0.9257</td>
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
      <td width="200">2988.9</td>
      <td width="200">2724.87</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="200">仅展示</td>
      <td width="200">3129.82</td>
      <td width="200">3367.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="200">越大越好</td>
      <td width="200">505801.39</td>
      <td width="200">349823.61</td>
      <td width="380">0.6916</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
