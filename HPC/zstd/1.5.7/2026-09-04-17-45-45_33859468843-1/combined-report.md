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
      <td width="220">zstd</td>
      <td width="160">1.5.7</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">zstd</td>
      <td width="160">1.5.7</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### zstd 1.5.7

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
      <td width="600">1.5.7</td>
      <td width="600">1.5.7</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.5.7</td>
      <td width="600">1.5.7</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-09-04T09:41:12Z</td>
      <td width="600">2026-09-04T09:41:45Z</td>
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
      <td width="600">2026-09-04T09:40:45Z</td>
      <td width="600">2026-09-04T09:41:00Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">AMD EPYC 9654 96-Core Processor</td>
      <td width="600">unknown</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">384</td>
      <td width="600">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
      <td width="600">openEuler 24.03 (LTS-SP2)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0-132.0.0.111.oe2403sp3.x86_64</td>
      <td width="600">6.6.0-cc</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 0 size: 192588 MB<br>node 0 free: 190018 MB<br>node 1 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 1 size: 193511 MB<br>node 1 free: 188876 MB<br>node 2 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 2 size: 193469 MB<br>node 2 free: 191478 MB<br>node 3 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 193443 MB<br>node 3 free: 191400 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  32  32 <br>  1:  12  10  32  32 <br>  2:  32  32  10  12 <br>  3:  32  32  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 171144 MB<br>node 0 free: 168325 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 193468 MB<br>node 1 free: 189389 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 193522 MB<br>node 2 free: 191303 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 192478 MB<br>node 3 free: 188224 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### zstd 1.5.7

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
      <td width="500">compress</td>
      <td width="280">312.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decompress</td>
      <td width="280">1381.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compress_freshCCtx</td>
      <td width="280">313.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decompressDCtx</td>
      <td width="280">1381.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressContinue</td>
      <td width="280">313.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressContinue_extDict</td>
      <td width="280">311.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decompressContinue</td>
      <td width="280">1374.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream</td>
      <td width="280">287.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream_freshCCtx</td>
      <td width="280">287.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decompressStream</td>
      <td width="280">1381.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compress2</td>
      <td width="280">313.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream2, end</td>
      <td width="280">313.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream2, end &amp; short</td>
      <td width="280">311.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream2, continue</td>
      <td width="280">287.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream2, -T2, continue</td>
      <td width="280">499.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream2, -T2, end</td>
      <td width="280">512.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressSequences</td>
      <td width="280">828.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressSequencesAndLiterals</td>
      <td width="280">934.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">convertSequences (1st block)</td>
      <td width="280">10915.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">get1BlockSummary (1st block)</td>
      <td width="280">24363.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decodeLiteralsHeader (1st block</td>
      <td width="280">184929.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decodeLiteralsBlock (1st block)</td>
      <td width="280">12595.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decodeSeqHeaders (1st block)</td>
      <td width="280">52094.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### zstd 1.5.7

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
      <td width="500">compress</td>
      <td width="280">216.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decompress</td>
      <td width="280">808.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compress_freshCCtx</td>
      <td width="280">213.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decompressDCtx</td>
      <td width="280">803.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressContinue</td>
      <td width="280">215.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressContinue_extDict</td>
      <td width="280">215.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decompressContinue</td>
      <td width="280">805.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream</td>
      <td width="280">196.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream_freshCCtx</td>
      <td width="280">196.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decompressStream</td>
      <td width="280">805.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compress2</td>
      <td width="280">215.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream2, end</td>
      <td width="280">215.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream2, end &amp; short</td>
      <td width="280">213.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream2, continue</td>
      <td width="280">197.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream2, -T2, continue</td>
      <td width="280">346.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressStream2, -T2, end</td>
      <td width="280">343.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressSequences</td>
      <td width="280">532.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compressSequencesAndLiterals</td>
      <td width="280">605.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">convertSequences (1st block)</td>
      <td width="280">8352.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">get1BlockSummary (1st block)</td>
      <td width="280">17307.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decodeLiteralsHeader (1st block</td>
      <td width="280">130858.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decodeLiteralsBlock (1st block)</td>
      <td width="280">6152.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">decodeSeqHeaders (1st block)</td>
      <td width="280">31058.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### zstd 1.5.7

<table width="1380">
  <thead>
    <tr>
      <th width="450">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="450">compress</td>
      <td width="190">越大越好</td>
      <td width="190">312.5</td>
      <td width="190">216.0</td>
      <td width="360">0.6912</td>
    </tr>
    <tr>
      <td width="450">decompress</td>
      <td width="190">越大越好</td>
      <td width="190">1381.0</td>
      <td width="190">808.4</td>
      <td width="360">0.5854</td>
    </tr>
    <tr>
      <td width="450">compress_freshCCtx</td>
      <td width="190">越大越好</td>
      <td width="190">313.3</td>
      <td width="190">213.1</td>
      <td width="360">0.6802</td>
    </tr>
    <tr>
      <td width="450">decompressDCtx</td>
      <td width="190">越大越好</td>
      <td width="190">1381.1</td>
      <td width="190">803.8</td>
      <td width="360">0.582</td>
    </tr>
    <tr>
      <td width="450">compressContinue</td>
      <td width="190">越大越好</td>
      <td width="190">313.4</td>
      <td width="190">215.3</td>
      <td width="360">0.687</td>
    </tr>
    <tr>
      <td width="450">compressContinue_extDict</td>
      <td width="190">越大越好</td>
      <td width="190">311.8</td>
      <td width="190">215.1</td>
      <td width="360">0.6899</td>
    </tr>
    <tr>
      <td width="450">decompressContinue</td>
      <td width="190">越大越好</td>
      <td width="190">1374.7</td>
      <td width="190">805.9</td>
      <td width="360">0.5862</td>
    </tr>
    <tr>
      <td width="450">compressStream</td>
      <td width="190">越大越好</td>
      <td width="190">287.3</td>
      <td width="190">196.8</td>
      <td width="360">0.685</td>
    </tr>
    <tr>
      <td width="450">compressStream_freshCCtx</td>
      <td width="190">越大越好</td>
      <td width="190">287.0</td>
      <td width="190">196.6</td>
      <td width="360">0.685</td>
    </tr>
    <tr>
      <td width="450">decompressStream</td>
      <td width="190">越大越好</td>
      <td width="190">1381.4</td>
      <td width="190">805.7</td>
      <td width="360">0.5832</td>
    </tr>
    <tr>
      <td width="450">compress2</td>
      <td width="190">越大越好</td>
      <td width="190">313.1</td>
      <td width="190">215.6</td>
      <td width="360">0.6886</td>
    </tr>
    <tr>
      <td width="450">compressStream2, end</td>
      <td width="190">越大越好</td>
      <td width="190">313.1</td>
      <td width="190">215.8</td>
      <td width="360">0.6892</td>
    </tr>
    <tr>
      <td width="450">compressStream2, end &amp; short</td>
      <td width="190">越大越好</td>
      <td width="190">311.4</td>
      <td width="190">213.8</td>
      <td width="360">0.6866</td>
    </tr>
    <tr>
      <td width="450">compressStream2, continue</td>
      <td width="190">越大越好</td>
      <td width="190">287.3</td>
      <td width="190">197.2</td>
      <td width="360">0.6864</td>
    </tr>
    <tr>
      <td width="450">compressStream2, -T2, continue</td>
      <td width="190">越大越好</td>
      <td width="190">499.2</td>
      <td width="190">346.5</td>
      <td width="360">0.6941</td>
    </tr>
    <tr>
      <td width="450">compressStream2, -T2, end</td>
      <td width="190">越大越好</td>
      <td width="190">512.3</td>
      <td width="190">343.9</td>
      <td width="360">0.6713</td>
    </tr>
    <tr>
      <td width="450">compressSequences</td>
      <td width="190">越大越好</td>
      <td width="190">828.7</td>
      <td width="190">532.4</td>
      <td width="360">0.6425</td>
    </tr>
    <tr>
      <td width="450">compressSequencesAndLiterals</td>
      <td width="190">越大越好</td>
      <td width="190">934.4</td>
      <td width="190">605.0</td>
      <td width="360">0.6475</td>
    </tr>
    <tr>
      <td width="450">convertSequences (1st block)</td>
      <td width="190">越大越好</td>
      <td width="190">10915.4</td>
      <td width="190">8352.6</td>
      <td width="360">0.7652</td>
    </tr>
    <tr>
      <td width="450">get1BlockSummary (1st block)</td>
      <td width="190">越大越好</td>
      <td width="190">24363.8</td>
      <td width="190">17307.5</td>
      <td width="360">0.7104</td>
    </tr>
    <tr>
      <td width="450">decodeLiteralsHeader (1st block</td>
      <td width="190">越大越好</td>
      <td width="190">184929.8</td>
      <td width="190">130858.3</td>
      <td width="360">0.7076</td>
    </tr>
    <tr>
      <td width="450">decodeLiteralsBlock (1st block)</td>
      <td width="190">越大越好</td>
      <td width="190">12595.6</td>
      <td width="190">6152.5</td>
      <td width="360">0.4885</td>
    </tr>
    <tr>
      <td width="450">decodeSeqHeaders (1st block)</td>
      <td width="190">越大越好</td>
      <td width="190">52094.9</td>
      <td width="190">31058.3</td>
      <td width="360">0.5962</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
