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
      <td width="180">Bigdata</td>
      <td width="220">flink</td>
      <td width="160">1.16.3</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Bigdata</td>
      <td width="220">flink</td>
      <td width="160">1.16.3</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### flink 1.16.3

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
      <td width="600">1.16.3</td>
      <td width="600">1.16.3</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.16.3</td>
      <td width="600">1.16.3</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-05T21:03:16Z</td>
      <td width="600">2026-11-05T21:01:10Z</td>
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
      <td width="600">2026-11-05T20:57:53Z</td>
      <td width="600">2026-11-05T20:57:53Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 126602 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 167625 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 169219 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 162520 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 132481 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 157239 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 163697 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 164998 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 378562 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 384009 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 380493 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 383446 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">nexmark</td>
      <td width="880">0.3-SNAPSHOT (6b3646c3baec701f1fa74baf938d235f742e5d3c)</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### flink 1.16.3

##### q0

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
      <td width="500">q0/throughput</td>
      <td width="280">2230000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q0/time</td>
      <td width="280">4.481</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q1

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
      <td width="500">q1/throughput</td>
      <td width="280">1880000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q1/time</td>
      <td width="280">5.313</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q2

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
      <td width="500">q2/throughput</td>
      <td width="280">2390000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q2/time</td>
      <td width="280">4.176</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q3

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
      <td width="500">q3/throughput</td>
      <td width="280">1930000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q3/time</td>
      <td width="280">5.192</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q4

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
      <td width="500">q4/throughput</td>
      <td width="280">473100.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q4/time</td>
      <td width="280">21.137</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q5

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
      <td width="500">q5/throughput</td>
      <td width="280">720360.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q5/time</td>
      <td width="280">13.882</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q7

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
      <td width="500">q7/throughput</td>
      <td width="280">235350.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q7/time</td>
      <td width="280">42.49</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q8

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
      <td width="500">q8/throughput</td>
      <td width="280">1620000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q8/time</td>
      <td width="280">6.154</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q9

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
      <td width="500">q9/throughput</td>
      <td width="280">319690.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q9/time</td>
      <td width="280">31.28</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q10

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
      <td width="500">q10/throughput</td>
      <td width="280">698710.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q10/time</td>
      <td width="280">14.312</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q11

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
      <td width="500">q11/throughput</td>
      <td width="280">625350.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q11/time</td>
      <td width="280">15.991</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q12

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
      <td width="500">q12/throughput</td>
      <td width="280">1810000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q12/time</td>
      <td width="280">5.514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q13

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
      <td width="500">q13/throughput</td>
      <td width="280">1660000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q13/time</td>
      <td width="280">6.042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q14

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
      <td width="500">q14/throughput</td>
      <td width="280">2080000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q14/time</td>
      <td width="280">4.817</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q15

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
      <td width="500">q15/throughput</td>
      <td width="280">820080.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q15/time</td>
      <td width="280">12.194</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q16

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
      <td width="500">q16/throughput</td>
      <td width="280">222180.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q16/time</td>
      <td width="280">45.009</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q17

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
      <td width="500">q17/throughput</td>
      <td width="280">1450000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q17/time</td>
      <td width="280">6.878</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q18

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
      <td width="500">q18/throughput</td>
      <td width="280">806710.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q18/time</td>
      <td width="280">12.396</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q19

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
      <td width="500">q19/throughput</td>
      <td width="280">805610.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q19/time</td>
      <td width="280">12.413</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q20

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
      <td width="500">q20/throughput</td>
      <td width="280">107870.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q20/time</td>
      <td width="280">92.707</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q21

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
      <td width="500">q21/throughput</td>
      <td width="280">1160000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q21/time</td>
      <td width="280">8.603</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q22

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
      <td width="500">q22/throughput</td>
      <td width="280">1500000.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q22/time</td>
      <td width="280">6.661</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q23

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
      <td width="500">q23/throughput</td>
      <td width="280">4940.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q23/time</td>
      <td width="280">2025.703</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### flink 1.16.3

##### q0

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
      <td width="500">q0/throughput</td>
      <td width="280">48780.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q0/time</td>
      <td width="280">204.981</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q1

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
      <td width="500">q1/throughput</td>
      <td width="280">44960.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q1/time</td>
      <td width="280">222.423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q2

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
      <td width="500">q2/throughput</td>
      <td width="280">48790.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q2/time</td>
      <td width="280">204.966</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q3

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
      <td width="500">q3/throughput</td>
      <td width="280">45580.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q3/time</td>
      <td width="280">219.381</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q4

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
      <td width="500">q4/throughput</td>
      <td width="280">28240.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q4/time</td>
      <td width="280">354.141</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q5

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
      <td width="500">q5/throughput</td>
      <td width="280">39630.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q5/time</td>
      <td width="280">252.349</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q7

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
      <td width="500">q7/throughput</td>
      <td width="280">24860.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q7/time</td>
      <td width="280">402.234</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q8

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
      <td width="500">q8/throughput</td>
      <td width="280">52410.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q8/time</td>
      <td width="280">190.785</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q9

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
      <td width="500">q9/throughput</td>
      <td width="280">17050.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q9/time</td>
      <td width="280">586.555</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q10

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
      <td width="500">q10/throughput</td>
      <td width="280">16910.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q10/time</td>
      <td width="280">591.5</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q11

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
      <td width="500">q11/throughput</td>
      <td width="280">38150.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q11/time</td>
      <td width="280">262.101</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q12

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
      <td width="500">q12/throughput</td>
      <td width="280">42740.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q12/time</td>
      <td width="280">233.967</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q13

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
      <td width="500">q13/throughput</td>
      <td width="280">42570.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q13/time</td>
      <td width="280">234.893</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q14

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
      <td width="500">q14/throughput</td>
      <td width="280">47160.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q14/time</td>
      <td width="280">212.058</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q15

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
      <td width="500">q15/throughput</td>
      <td width="280">25120.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q15/time</td>
      <td width="280">398.079</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q16

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
      <td width="500">q16/throughput</td>
      <td width="280">7460.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q16/time</td>
      <td width="280">1340.127</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q17

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
      <td width="500">q17/throughput</td>
      <td width="280">40150.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q17/time</td>
      <td width="280">249.07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q18

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
      <td width="500">q18/throughput</td>
      <td width="280">29060.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q18/time</td>
      <td width="280">344.145</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q19

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
      <td width="500">q19/throughput</td>
      <td width="280">25620.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q19/time</td>
      <td width="280">390.377</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q20

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
      <td width="500">q20/throughput</td>
      <td width="280">24430.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q20/time</td>
      <td width="280">409.359</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q21

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
      <td width="500">q21/throughput</td>
      <td width="280">34420.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q21/time</td>
      <td width="280">290.51</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q22

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
      <td width="500">q22/throughput</td>
      <td width="280">33550.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q22/time</td>
      <td width="280">298.038</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### q23

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
      <td width="500">q23/throughput</td>
      <td width="280">2210.0</td>
      <td width="200">events/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">q23/time</td>
      <td width="280">4521.013</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### flink 1.16.3

#### q0

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
      <td width="400">q0/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2230000.0</td>
      <td width="200">48780.0</td>
      <td width="380">0.0219</td>
    </tr>
    <tr>
      <td width="400">q0/time</td>
      <td width="200">越小越好</td>
      <td width="200">4.481</td>
      <td width="200">204.981</td>
      <td width="380">0.0219</td>
    </tr>
  </tbody>
</table>

#### q1

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
      <td width="400">q1/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1880000.0</td>
      <td width="200">44960.0</td>
      <td width="380">0.0239</td>
    </tr>
    <tr>
      <td width="400">q1/time</td>
      <td width="200">越小越好</td>
      <td width="200">5.313</td>
      <td width="200">222.423</td>
      <td width="380">0.0239</td>
    </tr>
  </tbody>
</table>

#### q2

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
      <td width="400">q2/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2390000.0</td>
      <td width="200">48790.0</td>
      <td width="380">0.0204</td>
    </tr>
    <tr>
      <td width="400">q2/time</td>
      <td width="200">越小越好</td>
      <td width="200">4.176</td>
      <td width="200">204.966</td>
      <td width="380">0.0204</td>
    </tr>
  </tbody>
</table>

#### q3

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
      <td width="400">q3/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1930000.0</td>
      <td width="200">45580.0</td>
      <td width="380">0.0236</td>
    </tr>
    <tr>
      <td width="400">q3/time</td>
      <td width="200">越小越好</td>
      <td width="200">5.192</td>
      <td width="200">219.381</td>
      <td width="380">0.0237</td>
    </tr>
  </tbody>
</table>

#### q4

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
      <td width="400">q4/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">473100.0</td>
      <td width="200">28240.0</td>
      <td width="380">0.0597</td>
    </tr>
    <tr>
      <td width="400">q4/time</td>
      <td width="200">越小越好</td>
      <td width="200">21.137</td>
      <td width="200">354.141</td>
      <td width="380">0.0597</td>
    </tr>
  </tbody>
</table>

#### q5

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
      <td width="400">q5/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">720360.0</td>
      <td width="200">39630.0</td>
      <td width="380">0.055</td>
    </tr>
    <tr>
      <td width="400">q5/time</td>
      <td width="200">越小越好</td>
      <td width="200">13.882</td>
      <td width="200">252.349</td>
      <td width="380">0.055</td>
    </tr>
  </tbody>
</table>

#### q7

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
      <td width="400">q7/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">235350.0</td>
      <td width="200">24860.0</td>
      <td width="380">0.1056</td>
    </tr>
    <tr>
      <td width="400">q7/time</td>
      <td width="200">越小越好</td>
      <td width="200">42.49</td>
      <td width="200">402.234</td>
      <td width="380">0.1056</td>
    </tr>
  </tbody>
</table>

#### q8

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
      <td width="400">q8/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1620000.0</td>
      <td width="200">52410.0</td>
      <td width="380">0.0324</td>
    </tr>
    <tr>
      <td width="400">q8/time</td>
      <td width="200">越小越好</td>
      <td width="200">6.154</td>
      <td width="200">190.785</td>
      <td width="380">0.0323</td>
    </tr>
  </tbody>
</table>

#### q9

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
      <td width="400">q9/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">319690.0</td>
      <td width="200">17050.0</td>
      <td width="380">0.0533</td>
    </tr>
    <tr>
      <td width="400">q9/time</td>
      <td width="200">越小越好</td>
      <td width="200">31.28</td>
      <td width="200">586.555</td>
      <td width="380">0.0533</td>
    </tr>
  </tbody>
</table>

#### q10

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
      <td width="400">q10/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">698710.0</td>
      <td width="200">16910.0</td>
      <td width="380">0.0242</td>
    </tr>
    <tr>
      <td width="400">q10/time</td>
      <td width="200">越小越好</td>
      <td width="200">14.312</td>
      <td width="200">591.5</td>
      <td width="380">0.0242</td>
    </tr>
  </tbody>
</table>

#### q11

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
      <td width="400">q11/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">625350.0</td>
      <td width="200">38150.0</td>
      <td width="380">0.061</td>
    </tr>
    <tr>
      <td width="400">q11/time</td>
      <td width="200">越小越好</td>
      <td width="200">15.991</td>
      <td width="200">262.101</td>
      <td width="380">0.061</td>
    </tr>
  </tbody>
</table>

#### q12

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
      <td width="400">q12/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1810000.0</td>
      <td width="200">42740.0</td>
      <td width="380">0.0236</td>
    </tr>
    <tr>
      <td width="400">q12/time</td>
      <td width="200">越小越好</td>
      <td width="200">5.514</td>
      <td width="200">233.967</td>
      <td width="380">0.0236</td>
    </tr>
  </tbody>
</table>

#### q13

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
      <td width="400">q13/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1660000.0</td>
      <td width="200">42570.0</td>
      <td width="380">0.0256</td>
    </tr>
    <tr>
      <td width="400">q13/time</td>
      <td width="200">越小越好</td>
      <td width="200">6.042</td>
      <td width="200">234.893</td>
      <td width="380">0.0257</td>
    </tr>
  </tbody>
</table>

#### q14

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
      <td width="400">q14/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">2080000.0</td>
      <td width="200">47160.0</td>
      <td width="380">0.0227</td>
    </tr>
    <tr>
      <td width="400">q14/time</td>
      <td width="200">越小越好</td>
      <td width="200">4.817</td>
      <td width="200">212.058</td>
      <td width="380">0.0227</td>
    </tr>
  </tbody>
</table>

#### q15

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
      <td width="400">q15/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">820080.0</td>
      <td width="200">25120.0</td>
      <td width="380">0.0306</td>
    </tr>
    <tr>
      <td width="400">q15/time</td>
      <td width="200">越小越好</td>
      <td width="200">12.194</td>
      <td width="200">398.079</td>
      <td width="380">0.0306</td>
    </tr>
  </tbody>
</table>

#### q16

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
      <td width="400">q16/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">222180.0</td>
      <td width="200">7460.0</td>
      <td width="380">0.0336</td>
    </tr>
    <tr>
      <td width="400">q16/time</td>
      <td width="200">越小越好</td>
      <td width="200">45.009</td>
      <td width="200">1340.127</td>
      <td width="380">0.0336</td>
    </tr>
  </tbody>
</table>

#### q17

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
      <td width="400">q17/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1450000.0</td>
      <td width="200">40150.0</td>
      <td width="380">0.0277</td>
    </tr>
    <tr>
      <td width="400">q17/time</td>
      <td width="200">越小越好</td>
      <td width="200">6.878</td>
      <td width="200">249.07</td>
      <td width="380">0.0276</td>
    </tr>
  </tbody>
</table>

#### q18

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
      <td width="400">q18/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">806710.0</td>
      <td width="200">29060.0</td>
      <td width="380">0.036</td>
    </tr>
    <tr>
      <td width="400">q18/time</td>
      <td width="200">越小越好</td>
      <td width="200">12.396</td>
      <td width="200">344.145</td>
      <td width="380">0.036</td>
    </tr>
  </tbody>
</table>

#### q19

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
      <td width="400">q19/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">805610.0</td>
      <td width="200">25620.0</td>
      <td width="380">0.0318</td>
    </tr>
    <tr>
      <td width="400">q19/time</td>
      <td width="200">越小越好</td>
      <td width="200">12.413</td>
      <td width="200">390.377</td>
      <td width="380">0.0318</td>
    </tr>
  </tbody>
</table>

#### q20

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
      <td width="400">q20/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">107870.0</td>
      <td width="200">24430.0</td>
      <td width="380">0.2265</td>
    </tr>
    <tr>
      <td width="400">q20/time</td>
      <td width="200">越小越好</td>
      <td width="200">92.707</td>
      <td width="200">409.359</td>
      <td width="380">0.2265</td>
    </tr>
  </tbody>
</table>

#### q21

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
      <td width="400">q21/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1160000.0</td>
      <td width="200">34420.0</td>
      <td width="380">0.0297</td>
    </tr>
    <tr>
      <td width="400">q21/time</td>
      <td width="200">越小越好</td>
      <td width="200">8.603</td>
      <td width="200">290.51</td>
      <td width="380">0.0296</td>
    </tr>
  </tbody>
</table>

#### q22

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
      <td width="400">q22/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">1500000.0</td>
      <td width="200">33550.0</td>
      <td width="380">0.0224</td>
    </tr>
    <tr>
      <td width="400">q22/time</td>
      <td width="200">越小越好</td>
      <td width="200">6.661</td>
      <td width="200">298.038</td>
      <td width="380">0.0223</td>
    </tr>
  </tbody>
</table>

#### q23

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
      <td width="400">q23/throughput</td>
      <td width="200">越大越好</td>
      <td width="200">4940.0</td>
      <td width="200">2210.0</td>
      <td width="380">0.4474</td>
    </tr>
    <tr>
      <td width="400">q23/time</td>
      <td width="200">越小越好</td>
      <td width="200">2025.703</td>
      <td width="200">4521.013</td>
      <td width="380">0.4481</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
