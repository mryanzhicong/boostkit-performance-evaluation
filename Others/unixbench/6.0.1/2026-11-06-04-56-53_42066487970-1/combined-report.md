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
      <td width="180">Others</td>
      <td width="220">unixbench</td>
      <td width="160">6.0.1</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Others</td>
      <td width="220">unixbench</td>
      <td width="160">6.0.1</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### unixbench 6.0.1

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
      <td width="600">6.0.1</td>
      <td width="600">6.0.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">6.0.1</td>
      <td width="600">6.0.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-05T19:55:31Z</td>
      <td width="600">2026-11-05T19:55:38Z</td>
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
      <td width="600">2026-11-05T19:54:59Z</td>
      <td width="600">2026-11-05T19:54:55Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 126542 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 167630 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 169247 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 162472 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 132512 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 157246 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 163882 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 164982 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 379676 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 385088 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 381619 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 384739 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">unixbench</td>
      <td width="880">6.0.1 (e949d4402f76b4bc9b7b114418faace882f0ef12)</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### unixbench 6.0.1

##### 1 copy

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
      <td width="500">1 copy/Dhrystone 2 using register variables/index</td>
      <td width="280">4865.4</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Double-Precision Whetstone/index</td>
      <td width="280">1740.3</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Execl Throughput/index</td>
      <td width="280">1085.4</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/File Copy 1024 bufsize 2000 maxblocks/index</td>
      <td width="280">1948.9</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/File Copy 256 bufsize 500 maxblocks/index</td>
      <td width="280">1193.7</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/File Copy 4096 bufsize 8000 maxblocks/index</td>
      <td width="280">4595.8</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Pipe Throughput/index</td>
      <td width="280">778.4</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Pipe-based Context Switching/index</td>
      <td width="280">401.5</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Process Creation/index</td>
      <td width="280">687.9</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/System Call Overhead/index</td>
      <td width="280">503.1</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Shell Scripts (1 concurrent)/index</td>
      <td width="280">2209.3</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Shell Scripts (8 concurrent)/index</td>
      <td width="280">12122.3</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/System Benchmarks Index Score</td>
      <td width="280">1601.5</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 384 copies

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
      <td width="500">384 copies/Dhrystone 2 using register variables/index</td>
      <td width="280">1229419.5</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Double-Precision Whetstone/index</td>
      <td width="280">526460.6</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Execl Throughput/index</td>
      <td width="280">7199.9</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/File Copy 1024 bufsize 2000 maxblocks/index</td>
      <td width="280">435273.2</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/File Copy 256 bufsize 500 maxblocks/index</td>
      <td width="280">343730.0</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/File Copy 4096 bufsize 8000 maxblocks/index</td>
      <td width="280">318042.8</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Pipe Throughput/index</td>
      <td width="280">236017.9</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Pipe-based Context Switching/index</td>
      <td width="280">78742.2</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Process Creation/index</td>
      <td width="280">6460.9</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/System Call Overhead/index</td>
      <td width="280">160671.7</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Shell Scripts (1 concurrent)/index</td>
      <td width="280">39434.7</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Shell Scripts (8 concurrent)/index</td>
      <td width="280">38210.1</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/System Benchmarks Index Score</td>
      <td width="280">116799.7</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### unixbench 6.0.1

##### 1 copy

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
      <td width="500">1 copy/Dhrystone 2 using register variables/index</td>
      <td width="280">4384.6</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Double-Precision Whetstone/index</td>
      <td width="280">1288.9</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Execl Throughput/index</td>
      <td width="280">914.9</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/File Copy 1024 bufsize 2000 maxblocks/index</td>
      <td width="280">2520.2</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/File Copy 256 bufsize 500 maxblocks/index</td>
      <td width="280">1767.8</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/File Copy 4096 bufsize 8000 maxblocks/index</td>
      <td width="280">4586.1</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Pipe Throughput/index</td>
      <td width="280">1093.5</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Pipe-based Context Switching/index</td>
      <td width="280">366.6</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Process Creation/index</td>
      <td width="280">266.2</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/System Call Overhead/index</td>
      <td width="280">616.2</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Shell Scripts (1 concurrent)/index</td>
      <td width="280">998.9</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/Shell Scripts (8 concurrent)/index</td>
      <td width="280">4544.5</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">1 copy/System Benchmarks Index Score</td>
      <td width="280">1333.2</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 384 copies

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
      <td width="500">384 copies/Dhrystone 2 using register variables/index</td>
      <td width="280">1123594.4</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Double-Precision Whetstone/index</td>
      <td width="280">447308.5</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Execl Throughput/index</td>
      <td width="280">5342.6</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/File Copy 1024 bufsize 2000 maxblocks/index</td>
      <td width="280">409344.7</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/File Copy 256 bufsize 500 maxblocks/index</td>
      <td width="280">504381.0</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/File Copy 4096 bufsize 8000 maxblocks/index</td>
      <td width="280">400618.4</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Pipe Throughput/index</td>
      <td width="280">328363.6</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Pipe-based Context Switching/index</td>
      <td width="280">31754.4</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Process Creation/index</td>
      <td width="280">5259.4</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/System Call Overhead/index</td>
      <td width="280">199160.8</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Shell Scripts (1 concurrent)/index</td>
      <td width="280">26895.8</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/Shell Scripts (8 concurrent)/index</td>
      <td width="280">27884.3</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">384 copies/System Benchmarks Index Score</td>
      <td width="280">105113.2</td>
      <td width="200">index</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### unixbench 6.0.1

#### 1 copy

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
      <td width="400">1 copy/Dhrystone 2 using register variables/index</td>
      <td width="200">越大越好</td>
      <td width="200">4865.4</td>
      <td width="200">4384.6</td>
      <td width="380">0.9012</td>
    </tr>
    <tr>
      <td width="400">1 copy/Double-Precision Whetstone/index</td>
      <td width="200">越大越好</td>
      <td width="200">1740.3</td>
      <td width="200">1288.9</td>
      <td width="380">0.7406</td>
    </tr>
    <tr>
      <td width="400">1 copy/Execl Throughput/index</td>
      <td width="200">越大越好</td>
      <td width="200">1085.4</td>
      <td width="200">914.9</td>
      <td width="380">0.8429</td>
    </tr>
    <tr>
      <td width="400">1 copy/File Copy 1024 bufsize 2000 maxblocks/index</td>
      <td width="200">越大越好</td>
      <td width="200">1948.9</td>
      <td width="200">2520.2</td>
      <td width="380">1.2931</td>
    </tr>
    <tr>
      <td width="400">1 copy/File Copy 256 bufsize 500 maxblocks/index</td>
      <td width="200">越大越好</td>
      <td width="200">1193.7</td>
      <td width="200">1767.8</td>
      <td width="380">1.4809</td>
    </tr>
    <tr>
      <td width="400">1 copy/File Copy 4096 bufsize 8000 maxblocks/index</td>
      <td width="200">越大越好</td>
      <td width="200">4595.8</td>
      <td width="200">4586.1</td>
      <td width="380">0.9979</td>
    </tr>
    <tr>
      <td width="400">1 copy/Pipe Throughput/index</td>
      <td width="200">越大越好</td>
      <td width="200">778.4</td>
      <td width="200">1093.5</td>
      <td width="380">1.4048</td>
    </tr>
    <tr>
      <td width="400">1 copy/Pipe-based Context Switching/index</td>
      <td width="200">越大越好</td>
      <td width="200">401.5</td>
      <td width="200">366.6</td>
      <td width="380">0.9131</td>
    </tr>
    <tr>
      <td width="400">1 copy/Process Creation/index</td>
      <td width="200">越大越好</td>
      <td width="200">687.9</td>
      <td width="200">266.2</td>
      <td width="380">0.387</td>
    </tr>
    <tr>
      <td width="400">1 copy/System Call Overhead/index</td>
      <td width="200">越大越好</td>
      <td width="200">503.1</td>
      <td width="200">616.2</td>
      <td width="380">1.2248</td>
    </tr>
    <tr>
      <td width="400">1 copy/Shell Scripts (1 concurrent)/index</td>
      <td width="200">越大越好</td>
      <td width="200">2209.3</td>
      <td width="200">998.9</td>
      <td width="380">0.4521</td>
    </tr>
    <tr>
      <td width="400">1 copy/Shell Scripts (8 concurrent)/index</td>
      <td width="200">越大越好</td>
      <td width="200">12122.3</td>
      <td width="200">4544.5</td>
      <td width="380">0.3749</td>
    </tr>
    <tr>
      <td width="400">1 copy/System Benchmarks Index Score</td>
      <td width="200">越大越好</td>
      <td width="200">1601.5</td>
      <td width="200">1333.2</td>
      <td width="380">0.8325</td>
    </tr>
  </tbody>
</table>

#### 384 copies

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
      <td width="400">384 copies/Dhrystone 2 using register variables/index</td>
      <td width="200">越大越好</td>
      <td width="200">1229419.5</td>
      <td width="200">1123594.4</td>
      <td width="380">0.9139</td>
    </tr>
    <tr>
      <td width="400">384 copies/Double-Precision Whetstone/index</td>
      <td width="200">越大越好</td>
      <td width="200">526460.6</td>
      <td width="200">447308.5</td>
      <td width="380">0.8497</td>
    </tr>
    <tr>
      <td width="400">384 copies/Execl Throughput/index</td>
      <td width="200">越大越好</td>
      <td width="200">7199.9</td>
      <td width="200">5342.6</td>
      <td width="380">0.742</td>
    </tr>
    <tr>
      <td width="400">384 copies/File Copy 1024 bufsize 2000 maxblocks/index</td>
      <td width="200">越大越好</td>
      <td width="200">435273.2</td>
      <td width="200">409344.7</td>
      <td width="380">0.9404</td>
    </tr>
    <tr>
      <td width="400">384 copies/File Copy 256 bufsize 500 maxblocks/index</td>
      <td width="200">越大越好</td>
      <td width="200">343730.0</td>
      <td width="200">504381.0</td>
      <td width="380">1.4674</td>
    </tr>
    <tr>
      <td width="400">384 copies/File Copy 4096 bufsize 8000 maxblocks/index</td>
      <td width="200">越大越好</td>
      <td width="200">318042.8</td>
      <td width="200">400618.4</td>
      <td width="380">1.2596</td>
    </tr>
    <tr>
      <td width="400">384 copies/Pipe Throughput/index</td>
      <td width="200">越大越好</td>
      <td width="200">236017.9</td>
      <td width="200">328363.6</td>
      <td width="380">1.3913</td>
    </tr>
    <tr>
      <td width="400">384 copies/Pipe-based Context Switching/index</td>
      <td width="200">越大越好</td>
      <td width="200">78742.2</td>
      <td width="200">31754.4</td>
      <td width="380">0.4033</td>
    </tr>
    <tr>
      <td width="400">384 copies/Process Creation/index</td>
      <td width="200">越大越好</td>
      <td width="200">6460.9</td>
      <td width="200">5259.4</td>
      <td width="380">0.814</td>
    </tr>
    <tr>
      <td width="400">384 copies/System Call Overhead/index</td>
      <td width="200">越大越好</td>
      <td width="200">160671.7</td>
      <td width="200">199160.8</td>
      <td width="380">1.2396</td>
    </tr>
    <tr>
      <td width="400">384 copies/Shell Scripts (1 concurrent)/index</td>
      <td width="200">越大越好</td>
      <td width="200">39434.7</td>
      <td width="200">26895.8</td>
      <td width="380">0.682</td>
    </tr>
    <tr>
      <td width="400">384 copies/Shell Scripts (8 concurrent)/index</td>
      <td width="200">越大越好</td>
      <td width="200">38210.1</td>
      <td width="200">27884.3</td>
      <td width="380">0.7298</td>
    </tr>
    <tr>
      <td width="400">384 copies/System Benchmarks Index Score</td>
      <td width="200">越大越好</td>
      <td width="200">116799.7</td>
      <td width="200">105113.2</td>
      <td width="380">0.8999</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
