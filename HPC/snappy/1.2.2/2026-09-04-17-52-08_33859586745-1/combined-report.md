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
      <td width="220">snappy</td>
      <td width="160">1.2.2</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">snappy</td>
      <td width="160">1.2.2</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### snappy 1.2.2

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
      <td width="600">1.2.2</td>
      <td width="600">1.2.2</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.2.2</td>
      <td width="600">1.2.2</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-09-04T09:47:05Z</td>
      <td width="600">2026-09-04T09:48:17Z</td>
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
      <td width="600">2026-09-04T09:46:22Z</td>
      <td width="600">2026-09-04T09:46:43Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 0 size: 192588 MB<br>node 0 free: 190037 MB<br>node 1 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 1 size: 193511 MB<br>node 1 free: 188958 MB<br>node 2 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 2 size: 193469 MB<br>node 2 free: 191465 MB<br>node 3 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 193443 MB<br>node 3 free: 191438 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  32  32 <br>  1:  12  10  32  32 <br>  2:  32  32  10  12 <br>  3:  32  32  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 171144 MB<br>node 0 free: 168338 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 193468 MB<br>node 1 free: 189371 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 193522 MB<br>node 2 free: 191290 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 192478 MB<br>node 3 free: 188174 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### snappy 1.2.2

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
      <td width="500">BM_ZFlatAll/1</td>
      <td width="280">564.518929</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">BM_ZFlatAll/2</td>
      <td width="280">381.835938</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">BM_UFlatMedley</td>
      <td width="280">1073.846817</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">BM_UValidateMedley</td>
      <td width="280">1803.455353</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### snappy 1.2.2

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
      <td width="500">BM_ZFlatAll/1</td>
      <td width="280">348.321915</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">BM_ZFlatAll/2</td>
      <td width="280">285.80761</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">BM_UFlatMedley</td>
      <td width="280">1121.711731</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">BM_UValidateMedley</td>
      <td width="280">1508.626938</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### snappy 1.2.2

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
      <td width="450">BM_ZFlatAll/1</td>
      <td width="190">越大越好</td>
      <td width="190">564.518929</td>
      <td width="190">348.321915</td>
      <td width="360">0.617</td>
    </tr>
    <tr>
      <td width="450">BM_ZFlatAll/2</td>
      <td width="190">越大越好</td>
      <td width="190">381.835938</td>
      <td width="190">285.80761</td>
      <td width="360">0.7485</td>
    </tr>
    <tr>
      <td width="450">BM_UFlatMedley</td>
      <td width="190">越大越好</td>
      <td width="190">1073.846817</td>
      <td width="190">1121.711731</td>
      <td width="360">1.0446</td>
    </tr>
    <tr>
      <td width="450">BM_UValidateMedley</td>
      <td width="190">越大越好</td>
      <td width="190">1803.455353</td>
      <td width="190">1508.626938</td>
      <td width="360">0.8365</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
