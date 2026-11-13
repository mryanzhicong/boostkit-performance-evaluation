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
      <td width="220">sonic-go</td>
      <td width="160">1.15.2</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">sonic-go</td>
      <td width="160">1.15.2</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### sonic-go 1.15.2

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
      <td width="600">1.15.2</td>
      <td width="600">1.15.2</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.15.2</td>
      <td width="600">1.15.2</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-13T06:28:35Z</td>
      <td width="600">2026-11-13T06:29:05Z</td>
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
      <td width="600">2026-11-13T06:27:24Z</td>
      <td width="600">2026-11-13T06:27:24Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 163435 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 166439 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 162686 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 164393 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 163049 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193523 MB<br>node 5 free: 167391 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 166275 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193413 MB<br>node 7 free: 145237 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 378438 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 383512 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 378731 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 383798 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">go test</td>
      <td width="880">1.24.6</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### sonic-go 1.15.2

##### decoder/default

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
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic :: B/op</td>
      <td width="280">9708.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic :: allocs/op</td>
      <td width="280">127.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic :: ns/op</td>
      <td width="280">21966.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: B/op</td>
      <td width="280">6649.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: allocs/op</td>
      <td width="280">24.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: ns/op</td>
      <td width="280">18257.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_StdLib :: B/op</td>
      <td width="280">11416.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_StdLib :: allocs/op</td>
      <td width="280">160.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_StdLib :: ns/op</td>
      <td width="280">99273.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: B/op</td>
      <td width="280">55835.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: allocs/op</td>
      <td width="280">747.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: ns/op</td>
      <td width="280">65115.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: B/op</td>
      <td width="280">47979.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: allocs/op</td>
      <td width="280">337.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: ns/op</td>
      <td width="280">51695.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: B/op</td>
      <td width="280">49465.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: allocs/op</td>
      <td width="280">795.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: ns/op</td>
      <td width="280">123684.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="280">9956.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: allocs/op</td>
      <td width="280">127.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: ns/op</td>
      <td width="280">4329.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="280">6894.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: allocs/op</td>
      <td width="280">24.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: ns/op</td>
      <td width="280">2365.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: B/op</td>
      <td width="280">11416.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: allocs/op</td>
      <td width="280">160.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: ns/op</td>
      <td width="280">7539.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="280">55664.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: allocs/op</td>
      <td width="280">747.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: ns/op</td>
      <td width="280">26390.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="280">48015.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: allocs/op</td>
      <td width="280">337.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: ns/op</td>
      <td width="280">26898.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="280">49467.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: allocs/op</td>
      <td width="280">795.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: ns/op</td>
      <td width="280">34024.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### encoder/default

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
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic :: B/op</td>
      <td width="280">9889.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic :: ns/op</td>
      <td width="280">6948.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: B/op</td>
      <td width="280">9858.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: ns/op</td>
      <td width="280">6393.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: B/op</td>
      <td width="280">9555.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: ns/op</td>
      <td width="280">12791.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: B/op</td>
      <td width="280">13617.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: allocs/op</td>
      <td width="280">40.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: ns/op</td>
      <td width="280">28890.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: B/op</td>
      <td width="280">13569.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: allocs/op</td>
      <td width="280">40.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: ns/op</td>
      <td width="280">20078.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: B/op</td>
      <td width="280">33192.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: allocs/op</td>
      <td width="280">653.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: ns/op</td>
      <td width="280">75506.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="280">11068.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: ns/op</td>
      <td width="280">1757.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="280">10619.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: ns/op</td>
      <td width="280">1563.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_StdLib :: B/op</td>
      <td width="280">9478.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_StdLib :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_StdLib :: ns/op</td>
      <td width="280">1816.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="280">14841.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: allocs/op</td>
      <td width="280">40.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: ns/op</td>
      <td width="280">2985.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="280">14664.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: allocs/op</td>
      <td width="280">40.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: ns/op</td>
      <td width="280">2762.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="280">32929.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: allocs/op</td>
      <td width="280">653.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: ns/op</td>
      <td width="280">19697.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### sonic-go 1.15.2

##### decoder/default

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
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic :: B/op</td>
      <td width="280">8279.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic :: allocs/op</td>
      <td width="280">144.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic :: ns/op</td>
      <td width="280">26848.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: B/op</td>
      <td width="280">5190.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: allocs/op</td>
      <td width="280">41.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: ns/op</td>
      <td width="280">22888.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_StdLib :: B/op</td>
      <td width="280">11416.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_StdLib :: allocs/op</td>
      <td width="280">160.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_StdLib :: ns/op</td>
      <td width="280">116467.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: B/op</td>
      <td width="280">36933.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: allocs/op</td>
      <td width="280">705.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: ns/op</td>
      <td width="280">58511.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: B/op</td>
      <td width="280">29968.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: allocs/op</td>
      <td width="280">105.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: ns/op</td>
      <td width="280">44041.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: B/op</td>
      <td width="280">49467.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: allocs/op</td>
      <td width="280">795.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: ns/op</td>
      <td width="280">155473.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="280">8166.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: allocs/op</td>
      <td width="280">144.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: ns/op</td>
      <td width="280">1691.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="280">5185.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: allocs/op</td>
      <td width="280">41.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: ns/op</td>
      <td width="280">409.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: B/op</td>
      <td width="280">11416.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: allocs/op</td>
      <td width="280">160.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: ns/op</td>
      <td width="280">10909.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="280">36338.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: allocs/op</td>
      <td width="280">705.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: ns/op</td>
      <td width="280">8866.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="280">29736.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: allocs/op</td>
      <td width="280">105.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: ns/op</td>
      <td width="280">6099.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="280">49470.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: allocs/op</td>
      <td width="280">795.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: ns/op</td>
      <td width="280">56637.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### encoder/default

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
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic :: B/op</td>
      <td width="280">9840.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic :: ns/op</td>
      <td width="280">17884.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: B/op</td>
      <td width="280">9759.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: ns/op</td>
      <td width="280">16340.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: B/op</td>
      <td width="280">9557.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: ns/op</td>
      <td width="280">16917.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: B/op</td>
      <td width="280">13644.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: allocs/op</td>
      <td width="280">40.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: ns/op</td>
      <td width="280">59172.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: B/op</td>
      <td width="280">13593.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: allocs/op</td>
      <td width="280">40.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: ns/op</td>
      <td width="280">48916.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: B/op</td>
      <td width="280">33224.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: allocs/op</td>
      <td width="280">653.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: ns/op</td>
      <td width="280">110858.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="280">9683.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: ns/op</td>
      <td width="280">982.9</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="280">10590.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: ns/op</td>
      <td width="280">1517.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_StdLib :: B/op</td>
      <td width="280">9480.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_StdLib :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_StdLib :: ns/op</td>
      <td width="280">2278.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="280">14799.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: allocs/op</td>
      <td width="280">40.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: ns/op</td>
      <td width="280">4295.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="280">14359.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: allocs/op</td>
      <td width="280">40.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: ns/op</td>
      <td width="280">3939.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="280">32941.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: allocs/op</td>
      <td width="280">653.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: ns/op</td>
      <td width="280">27730.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### sonic-go 1.15.2

#### decoder/default

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
      <td width="400">decoder :: default :: BenchmarkDecoder_Binding_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9708.0</td>
      <td width="200">8279.0</td>
      <td width="380">1.1726</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Binding_Sonic :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">127.0</td>
      <td width="200">144.0</td>
      <td width="380">0.8819</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Binding_Sonic :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">21966.0</td>
      <td width="200">26848.0</td>
      <td width="380">0.8182</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">6649.0</td>
      <td width="200">5190.0</td>
      <td width="380">1.2811</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">24.0</td>
      <td width="200">41.0</td>
      <td width="380">0.5854</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">18257.0</td>
      <td width="200">22888.0</td>
      <td width="380">0.7977</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Binding_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">11416.0</td>
      <td width="200">11416.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Binding_StdLib :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">160.0</td>
      <td width="200">160.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Binding_StdLib :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">99273.0</td>
      <td width="200">116467.0</td>
      <td width="380">0.8524</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">55835.0</td>
      <td width="200">36933.0</td>
      <td width="380">1.5118</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">747.0</td>
      <td width="200">705.0</td>
      <td width="380">1.0596</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">65115.0</td>
      <td width="200">58511.0</td>
      <td width="380">1.1129</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">47979.0</td>
      <td width="200">29968.0</td>
      <td width="380">1.601</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">337.0</td>
      <td width="200">105.0</td>
      <td width="380">3.2095</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">51695.0</td>
      <td width="200">44041.0</td>
      <td width="380">1.1738</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">49465.0</td>
      <td width="200">49467.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">795.0</td>
      <td width="200">795.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">123684.0</td>
      <td width="200">155473.0</td>
      <td width="380">0.7955</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9956.0</td>
      <td width="200">8166.0</td>
      <td width="380">1.2192</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">127.0</td>
      <td width="200">144.0</td>
      <td width="380">0.8819</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">4329.0</td>
      <td width="200">1691.0</td>
      <td width="380">2.56</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">6894.0</td>
      <td width="200">5185.0</td>
      <td width="380">1.3296</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">24.0</td>
      <td width="200">41.0</td>
      <td width="380">0.5854</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2365.0</td>
      <td width="200">409.0</td>
      <td width="380">5.7824</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">11416.0</td>
      <td width="200">11416.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">160.0</td>
      <td width="200">160.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">7539.0</td>
      <td width="200">10909.0</td>
      <td width="380">0.6911</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">55664.0</td>
      <td width="200">36338.0</td>
      <td width="380">1.5318</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">747.0</td>
      <td width="200">705.0</td>
      <td width="380">1.0596</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">26390.0</td>
      <td width="200">8866.0</td>
      <td width="380">2.9765</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">48015.0</td>
      <td width="200">29736.0</td>
      <td width="380">1.6147</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">337.0</td>
      <td width="200">105.0</td>
      <td width="380">3.2095</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">26898.0</td>
      <td width="200">6099.0</td>
      <td width="380">4.4102</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">49467.0</td>
      <td width="200">49470.0</td>
      <td width="380">0.9999</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">795.0</td>
      <td width="200">795.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">34024.0</td>
      <td width="200">56637.0</td>
      <td width="380">0.6007</td>
    </tr>
  </tbody>
</table>

#### encoder/default

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
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9889.0</td>
      <td width="200">9840.0</td>
      <td width="380">1.005</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_Sonic :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">2.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_Sonic :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">6948.0</td>
      <td width="200">17884.0</td>
      <td width="380">0.3885</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9858.0</td>
      <td width="200">9759.0</td>
      <td width="380">1.0101</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">2.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">6393.0</td>
      <td width="200">16340.0</td>
      <td width="380">0.3912</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9555.0</td>
      <td width="200">9557.0</td>
      <td width="380">0.9998</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">1.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">12791.0</td>
      <td width="200">16917.0</td>
      <td width="380">0.7561</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">13617.0</td>
      <td width="200">13644.0</td>
      <td width="380">0.998</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">40.0</td>
      <td width="200">40.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">28890.0</td>
      <td width="200">59172.0</td>
      <td width="380">0.4882</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">13569.0</td>
      <td width="200">13593.0</td>
      <td width="380">0.9982</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">40.0</td>
      <td width="200">40.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">20078.0</td>
      <td width="200">48916.0</td>
      <td width="380">0.4105</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">33192.0</td>
      <td width="200">33224.0</td>
      <td width="380">0.999</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">653.0</td>
      <td width="200">653.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">75506.0</td>
      <td width="200">110858.0</td>
      <td width="380">0.6811</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">11068.0</td>
      <td width="200">9683.0</td>
      <td width="380">1.143</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">2.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1757.0</td>
      <td width="200">982.9</td>
      <td width="380">1.7876</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">10619.0</td>
      <td width="200">10590.0</td>
      <td width="380">1.0027</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">2.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1563.0</td>
      <td width="200">1517.0</td>
      <td width="380">1.0303</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9478.0</td>
      <td width="200">9480.0</td>
      <td width="380">0.9998</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_StdLib :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">1.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_StdLib :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1816.0</td>
      <td width="200">2278.0</td>
      <td width="380">0.7972</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">14841.0</td>
      <td width="200">14799.0</td>
      <td width="380">1.0028</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">40.0</td>
      <td width="200">40.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2985.0</td>
      <td width="200">4295.0</td>
      <td width="380">0.695</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">14664.0</td>
      <td width="200">14359.0</td>
      <td width="380">1.0212</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">40.0</td>
      <td width="200">40.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2762.0</td>
      <td width="200">3939.0</td>
      <td width="380">0.7012</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">32929.0</td>
      <td width="200">32941.0</td>
      <td width="380">0.9996</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">653.0</td>
      <td width="200">653.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">19697.0</td>
      <td width="200">27730.0</td>
      <td width="380">0.7103</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
