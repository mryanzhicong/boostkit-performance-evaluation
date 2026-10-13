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
      <td width="600">2026-10-13T04:32:21Z</td>
      <td width="600">2026-10-13T04:32:46Z</td>
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
      <td width="600">2026-10-13T04:30:20Z</td>
      <td width="600">2026-10-13T04:30:43Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">AMD EPYC 9654 96-Core Processor</td>
      <td width="600">-</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">384</td>
      <td width="600">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0-132.0.0.111.oe2403sp3.x86_64</td>
      <td width="600">6.6.0-159.4.14.168.oe2403sp4.aarch64</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 0 size: 192588 MB<br>node 0 free: 137312 MB<br>node 1 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 1 size: 193511 MB<br>node 1 free: 161475 MB<br>node 2 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 2 size: 193469 MB<br>node 2 free: 120843 MB<br>node 3 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 193443 MB<br>node 3 free: 93482 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  32  32 <br>  1:  12  10  32  32 <br>  2:  32  32  10  12 <br>  3:  32  32  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 574945 MB<br>node 0 free: 557292 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 580594 MB<br>node 1 free: 571596 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 580594 MB<br>node 2 free: 565252 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 482782 MB<br>node 3 free: 474020 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">9710.0</td>
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
      <td width="280">21771.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: B/op</td>
      <td width="280">6647.0</td>
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
      <td width="280">18117.0</td>
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
      <td width="280">98788.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: B/op</td>
      <td width="280">55837.0</td>
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
      <td width="280">65260.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: B/op</td>
      <td width="280">47976.0</td>
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
      <td width="280">51242.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: B/op</td>
      <td width="280">49466.0</td>
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
      <td width="280">122448.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="280">9968.0</td>
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
      <td width="280">4361.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="280">6916.0</td>
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
      <td width="280">2382.0</td>
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
      <td width="280">7574.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="280">55686.0</td>
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
      <td width="280">27454.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="280">47968.0</td>
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
      <td width="280">24446.0</td>
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
      <td width="280">34950.0</td>
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
      <td width="280">9880.0</td>
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
      <td width="280">7136.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: B/op</td>
      <td width="280">9851.0</td>
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
      <td width="280">6591.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: B/op</td>
      <td width="280">9552.0</td>
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
      <td width="280">12745.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: B/op</td>
      <td width="280">13614.0</td>
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
      <td width="280">28812.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: B/op</td>
      <td width="280">13552.0</td>
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
      <td width="280">20387.0</td>
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
      <td width="280">75135.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="280">10943.0</td>
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
      <td width="280">1588.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="280">10782.0</td>
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
      <td width="280">1598.0</td>
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
      <td width="280">1900.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="280">15261.0</td>
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
      <td width="280">3154.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="280">14706.0</td>
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
      <td width="280">2984.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="280">32932.0</td>
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
      <td width="280">19589.0</td>
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
      <td width="280">8270.0</td>
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
      <td width="280">26074.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: B/op</td>
      <td width="280">5245.0</td>
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
      <td width="280">22765.0</td>
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
      <td width="280">115137.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: B/op</td>
      <td width="280">36869.0</td>
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
      <td width="280">58070.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: B/op</td>
      <td width="280">30030.0</td>
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
      <td width="280">42897.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: B/op</td>
      <td width="280">49466.0</td>
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
      <td width="280">150932.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="280">8191.0</td>
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
      <td width="280">1572.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="280">5205.0</td>
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
      <td width="280">377.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: B/op</td>
      <td width="280">11417.0</td>
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
      <td width="280">10333.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="280">36348.0</td>
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
      <td width="280">8092.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="280">29050.0</td>
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
      <td width="280">6534.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="280">49469.0</td>
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
      <td width="280">47001.0</td>
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
      <td width="280">9847.0</td>
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
      <td width="280">17477.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: B/op</td>
      <td width="280">9761.0</td>
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
      <td width="280">15800.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: B/op</td>
      <td width="280">9560.0</td>
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
      <td width="280">16530.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: B/op</td>
      <td width="280">13648.0</td>
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
      <td width="280">59472.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: B/op</td>
      <td width="280">13591.0</td>
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
      <td width="280">48919.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: B/op</td>
      <td width="280">33225.0</td>
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
      <td width="280">109099.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="280">11966.0</td>
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
      <td width="280">2270.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="280">11503.0</td>
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
      <td width="280">2051.0</td>
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
      <td width="280">2243.0</td>
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
      <td width="280">4008.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="280">14361.0</td>
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
      <td width="280">3555.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="280">32965.0</td>
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
      <td width="280">25625.0</td>
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
      <td width="200">9710.0</td>
      <td width="200">8270.0</td>
      <td width="380">1.1741</td>
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
      <td width="200">21771.0</td>
      <td width="200">26074.0</td>
      <td width="380">0.835</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Binding_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">6647.0</td>
      <td width="200">5245.0</td>
      <td width="380">1.2673</td>
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
      <td width="200">18117.0</td>
      <td width="200">22765.0</td>
      <td width="380">0.7958</td>
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
      <td width="200">98788.0</td>
      <td width="200">115137.0</td>
      <td width="380">0.858</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">55837.0</td>
      <td width="200">36869.0</td>
      <td width="380">1.5145</td>
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
      <td width="200">65260.0</td>
      <td width="200">58070.0</td>
      <td width="380">1.1238</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">47976.0</td>
      <td width="200">30030.0</td>
      <td width="380">1.5976</td>
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
      <td width="200">51242.0</td>
      <td width="200">42897.0</td>
      <td width="380">1.1945</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Generic_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">49466.0</td>
      <td width="200">49466.0</td>
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
      <td width="200">122448.0</td>
      <td width="200">150932.0</td>
      <td width="380">0.8113</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9968.0</td>
      <td width="200">8191.0</td>
      <td width="380">1.2169</td>
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
      <td width="200">4361.0</td>
      <td width="200">1572.0</td>
      <td width="380">2.7742</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">6916.0</td>
      <td width="200">5205.0</td>
      <td width="380">1.3287</td>
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
      <td width="200">2382.0</td>
      <td width="200">377.5</td>
      <td width="380">6.3099</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Binding_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">11416.0</td>
      <td width="200">11417.0</td>
      <td width="380">0.9999</td>
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
      <td width="200">7574.0</td>
      <td width="200">10333.0</td>
      <td width="380">0.733</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">55686.0</td>
      <td width="200">36348.0</td>
      <td width="380">1.532</td>
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
      <td width="200">27454.0</td>
      <td width="200">8092.0</td>
      <td width="380">3.3927</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">47968.0</td>
      <td width="200">29050.0</td>
      <td width="380">1.6512</td>
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
      <td width="200">24446.0</td>
      <td width="200">6534.0</td>
      <td width="380">3.7414</td>
    </tr>
    <tr>
      <td width="400">decoder :: default :: BenchmarkDecoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">49467.0</td>
      <td width="200">49469.0</td>
      <td width="380">1.0</td>
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
      <td width="200">34950.0</td>
      <td width="200">47001.0</td>
      <td width="380">0.7436</td>
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
      <td width="200">9880.0</td>
      <td width="200">9847.0</td>
      <td width="380">1.0034</td>
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
      <td width="200">7136.0</td>
      <td width="200">17477.0</td>
      <td width="380">0.4083</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9851.0</td>
      <td width="200">9761.0</td>
      <td width="380">1.0092</td>
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
      <td width="200">6591.0</td>
      <td width="200">15800.0</td>
      <td width="380">0.4172</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Binding_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9552.0</td>
      <td width="200">9560.0</td>
      <td width="380">0.9992</td>
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
      <td width="200">12745.0</td>
      <td width="200">16530.0</td>
      <td width="380">0.771</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">13614.0</td>
      <td width="200">13648.0</td>
      <td width="380">0.9975</td>
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
      <td width="200">28812.0</td>
      <td width="200">59472.0</td>
      <td width="380">0.4845</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">13552.0</td>
      <td width="200">13591.0</td>
      <td width="380">0.9971</td>
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
      <td width="200">20387.0</td>
      <td width="200">48919.0</td>
      <td width="380">0.4168</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Generic_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">33192.0</td>
      <td width="200">33225.0</td>
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
      <td width="200">75135.0</td>
      <td width="200">109099.0</td>
      <td width="380">0.6887</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">10943.0</td>
      <td width="200">11966.0</td>
      <td width="380">0.9145</td>
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
      <td width="200">1588.0</td>
      <td width="200">2270.0</td>
      <td width="380">0.6996</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">10782.0</td>
      <td width="200">11503.0</td>
      <td width="380">0.9373</td>
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
      <td width="200">1598.0</td>
      <td width="200">2051.0</td>
      <td width="380">0.7791</td>
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
      <td width="200">1900.0</td>
      <td width="200">2243.0</td>
      <td width="380">0.8471</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">15261.0</td>
      <td width="200">14841.0</td>
      <td width="380">1.0283</td>
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
      <td width="200">3154.0</td>
      <td width="200">4008.0</td>
      <td width="380">0.7869</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">14706.0</td>
      <td width="200">14361.0</td>
      <td width="380">1.024</td>
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
      <td width="200">2984.0</td>
      <td width="200">3555.0</td>
      <td width="380">0.8394</td>
    </tr>
    <tr>
      <td width="400">encoder :: default :: BenchmarkEncoder_Parallel_Generic_StdLib :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">32932.0</td>
      <td width="200">32965.0</td>
      <td width="380">0.999</td>
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
      <td width="200">19589.0</td>
      <td width="200">25625.0</td>
      <td width="380">0.7644</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
