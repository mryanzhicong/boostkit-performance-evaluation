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
      <td width="220">lance</td>
      <td width="160">13.0.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">AI</td>
      <td width="220">lance</td>
      <td width="160">13.0.0</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### lance 13.0.0

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
      <td width="600">13.0.0</td>
      <td width="600">13.0.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">13.0.0</td>
      <td width="600">13.0.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-07T20:22:31Z</td>
      <td width="600">2026-11-07T20:31:30Z</td>
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
      <td width="600">2026-11-07T20:05:58Z</td>
      <td width="600">2026-11-07T20:06:06Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 62802 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 140814 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 168242 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 163494 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 135116 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 160134 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 167531 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 164626 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 367725 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 379295 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 356529 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 351493 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">lance_sift</td>
      <td width="880">13.0.0</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### lance 13.0.0

##### nprobes=1,refine_factor=1

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
      <td width="500">nprobes=1,refine_factor=1/mean_query_time</td>
      <td width="280">0.00122989821434021</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=1/recall_at_1</td>
      <td width="280">0.289</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=10

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
      <td width="500">nprobes=1,refine_factor=10/mean_query_time</td>
      <td width="280">0.0013705015182495118</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=10/recall_at_1</td>
      <td width="280">0.479</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=20

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
      <td width="500">nprobes=1,refine_factor=20/mean_query_time</td>
      <td width="280">0.0013538064956665039</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=20/recall_at_1</td>
      <td width="280">0.492</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=30

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
      <td width="500">nprobes=1,refine_factor=30/mean_query_time</td>
      <td width="280">0.0013089995384216308</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=30/recall_at_1</td>
      <td width="280">0.496</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=40

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
      <td width="500">nprobes=1,refine_factor=40/mean_query_time</td>
      <td width="280">0.0013406226634979249</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=40/recall_at_1</td>
      <td width="280">0.496</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=50

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
      <td width="500">nprobes=1,refine_factor=50/mean_query_time</td>
      <td width="280">0.0014215428829193115</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=50/recall_at_1</td>
      <td width="280">0.499</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=none

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
      <td width="500">nprobes=1,refine_factor=none/mean_query_time</td>
      <td width="280">0.0010795209407806396</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=none/recall_at_1</td>
      <td width="280">0.289</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=1

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
      <td width="500">nprobes=10,refine_factor=1/mean_query_time</td>
      <td width="280">0.0015138669013977052</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=1/recall_at_1</td>
      <td width="280">0.455</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=10

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
      <td width="500">nprobes=10,refine_factor=10/mean_query_time</td>
      <td width="280">0.0015335733890533448</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=10/recall_at_1</td>
      <td width="280">0.867</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=20

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
      <td width="500">nprobes=10,refine_factor=20/mean_query_time</td>
      <td width="280">0.0015966274738311768</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=20/recall_at_1</td>
      <td width="280">0.928</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=30

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
      <td width="500">nprobes=10,refine_factor=30/mean_query_time</td>
      <td width="280">0.0016234753131866455</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=30/recall_at_1</td>
      <td width="280">0.947</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=40

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
      <td width="500">nprobes=10,refine_factor=40/mean_query_time</td>
      <td width="280">0.0018463349342346192</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=40/recall_at_1</td>
      <td width="280">0.959</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=50

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
      <td width="500">nprobes=10,refine_factor=50/mean_query_time</td>
      <td width="280">0.00230857253074646</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=50/recall_at_1</td>
      <td width="280">0.964</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=none

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
      <td width="500">nprobes=10,refine_factor=none/mean_query_time</td>
      <td width="280">0.0012049386501312256</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=none/recall_at_1</td>
      <td width="280">0.455</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=1

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
      <td width="500">nprobes=100,refine_factor=1/mean_query_time</td>
      <td width="280">0.004389755725860596</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=1/recall_at_1</td>
      <td width="280">0.46</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=10

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
      <td width="500">nprobes=100,refine_factor=10/mean_query_time</td>
      <td width="280">0.004751595020294189</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=10/recall_at_1</td>
      <td width="280">0.885</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=20

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
      <td width="500">nprobes=100,refine_factor=20/mean_query_time</td>
      <td width="280">0.004683312892913819</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=20/recall_at_1</td>
      <td width="280">0.953</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=30

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
      <td width="500">nprobes=100,refine_factor=30/mean_query_time</td>
      <td width="280">0.004860017538070679</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=30/recall_at_1</td>
      <td width="280">0.973</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=40

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
      <td width="500">nprobes=100,refine_factor=40/mean_query_time</td>
      <td width="280">0.004982337951660156</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=40/recall_at_1</td>
      <td width="280">0.987</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=50

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
      <td width="500">nprobes=100,refine_factor=50/mean_query_time</td>
      <td width="280">0.005027457714080811</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=50/recall_at_1</td>
      <td width="280">0.993</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=none

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
      <td width="500">nprobes=100,refine_factor=none/mean_query_time</td>
      <td width="280">0.004188713550567627</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=none/recall_at_1</td>
      <td width="280">0.46</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=1

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
      <td width="500">nprobes=25,refine_factor=1/mean_query_time</td>
      <td width="280">0.0023599042892456057</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=1/recall_at_1</td>
      <td width="280">0.46</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=10

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
      <td width="500">nprobes=25,refine_factor=10/mean_query_time</td>
      <td width="280">0.0026242117881774903</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=10/recall_at_1</td>
      <td width="280">0.885</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=20

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
      <td width="500">nprobes=25,refine_factor=20/mean_query_time</td>
      <td width="280">0.002624452590942383</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=20/recall_at_1</td>
      <td width="280">0.953</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=30

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
      <td width="500">nprobes=25,refine_factor=30/mean_query_time</td>
      <td width="280">0.002522761821746826</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=30/recall_at_1</td>
      <td width="280">0.973</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=40

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
      <td width="500">nprobes=25,refine_factor=40/mean_query_time</td>
      <td width="280">0.0025836198329925535</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=40/recall_at_1</td>
      <td width="280">0.987</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=50

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
      <td width="500">nprobes=25,refine_factor=50/mean_query_time</td>
      <td width="280">0.0026563000679016113</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=50/recall_at_1</td>
      <td width="280">0.993</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=none

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
      <td width="500">nprobes=25,refine_factor=none/mean_query_time</td>
      <td width="280">0.0019903056621551514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=none/recall_at_1</td>
      <td width="280">0.46</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=1

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
      <td width="500">nprobes=50,refine_factor=1/mean_query_time</td>
      <td width="280">0.00318346381187439</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=1/recall_at_1</td>
      <td width="280">0.46</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=10

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
      <td width="500">nprobes=50,refine_factor=10/mean_query_time</td>
      <td width="280">0.0031737141609191897</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=10/recall_at_1</td>
      <td width="280">0.885</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=20

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
      <td width="500">nprobes=50,refine_factor=20/mean_query_time</td>
      <td width="280">0.003340775728225708</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=20/recall_at_1</td>
      <td width="280">0.953</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=30

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
      <td width="500">nprobes=50,refine_factor=30/mean_query_time</td>
      <td width="280">0.0034741928577423095</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=30/recall_at_1</td>
      <td width="280">0.973</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=40

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
      <td width="500">nprobes=50,refine_factor=40/mean_query_time</td>
      <td width="280">0.0036256492137908937</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=40/recall_at_1</td>
      <td width="280">0.987</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=50

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
      <td width="500">nprobes=50,refine_factor=50/mean_query_time</td>
      <td width="280">0.003533083438873291</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=50/recall_at_1</td>
      <td width="280">0.993</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=none

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
      <td width="500">nprobes=50,refine_factor=none/mean_query_time</td>
      <td width="280">0.0025994510650634768</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=none/recall_at_1</td>
      <td width="280">0.46</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=1

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
      <td width="500">nprobes=75,refine_factor=1/mean_query_time</td>
      <td width="280">0.00405472469329834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=1/recall_at_1</td>
      <td width="280">0.46</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=10

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
      <td width="500">nprobes=75,refine_factor=10/mean_query_time</td>
      <td width="280">0.003950880527496338</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=10/recall_at_1</td>
      <td width="280">0.885</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=20

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
      <td width="500">nprobes=75,refine_factor=20/mean_query_time</td>
      <td width="280">0.0038808276653289793</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=20/recall_at_1</td>
      <td width="280">0.953</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=30

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
      <td width="500">nprobes=75,refine_factor=30/mean_query_time</td>
      <td width="280">0.003869875192642212</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=30/recall_at_1</td>
      <td width="280">0.973</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=40

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
      <td width="500">nprobes=75,refine_factor=40/mean_query_time</td>
      <td width="280">0.004033694505691529</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=40/recall_at_1</td>
      <td width="280">0.987</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=50

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
      <td width="500">nprobes=75,refine_factor=50/mean_query_time</td>
      <td width="280">0.004145896911621093</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=50/recall_at_1</td>
      <td width="280">0.993</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=none

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
      <td width="500">nprobes=75,refine_factor=none/mean_query_time</td>
      <td width="280">0.003336729288101196</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=none/recall_at_1</td>
      <td width="280">0.46</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### lance 13.0.0

##### nprobes=1,refine_factor=1

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
      <td width="500">nprobes=1,refine_factor=1/mean_query_time</td>
      <td width="280">0.004252521991729736</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=1/recall_at_1</td>
      <td width="280">0.3</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=10

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
      <td width="500">nprobes=1,refine_factor=10/mean_query_time</td>
      <td width="280">0.007630712032318116</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=10/recall_at_1</td>
      <td width="280">0.51</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=20

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
      <td width="500">nprobes=1,refine_factor=20/mean_query_time</td>
      <td width="280">0.008721610069274903</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=20/recall_at_1</td>
      <td width="280">0.526</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=30

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
      <td width="500">nprobes=1,refine_factor=30/mean_query_time</td>
      <td width="280">0.01054902744293213</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=30/recall_at_1</td>
      <td width="280">0.527</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=40

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
      <td width="500">nprobes=1,refine_factor=40/mean_query_time</td>
      <td width="280">0.01633111023902893</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=40/recall_at_1</td>
      <td width="280">0.53</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=50

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
      <td width="500">nprobes=1,refine_factor=50/mean_query_time</td>
      <td width="280">0.015829875946044923</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=50/recall_at_1</td>
      <td width="280">0.53</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=1,refine_factor=none

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
      <td width="500">nprobes=1,refine_factor=none/mean_query_time</td>
      <td width="280">0.003971836566925049</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=none/recall_at_1</td>
      <td width="280">0.3</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=1

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
      <td width="500">nprobes=10,refine_factor=1/mean_query_time</td>
      <td width="280">0.006200378179550171</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=1/recall_at_1</td>
      <td width="280">0.438</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=10

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
      <td width="500">nprobes=10,refine_factor=10/mean_query_time</td>
      <td width="280">0.009572388172149658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=10/recall_at_1</td>
      <td width="280">0.877</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=20

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
      <td width="500">nprobes=10,refine_factor=20/mean_query_time</td>
      <td width="280">0.009475063800811768</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=20/recall_at_1</td>
      <td width="280">0.942</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=30

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
      <td width="500">nprobes=10,refine_factor=30/mean_query_time</td>
      <td width="280">0.01224823784828186</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=30/recall_at_1</td>
      <td width="280">0.955</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=40

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
      <td width="500">nprobes=10,refine_factor=40/mean_query_time</td>
      <td width="280">0.014960773229599</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=40/recall_at_1</td>
      <td width="280">0.961</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=50

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
      <td width="500">nprobes=10,refine_factor=50/mean_query_time</td>
      <td width="280">0.02082332706451416</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=50/recall_at_1</td>
      <td width="280">0.963</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=10,refine_factor=none

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
      <td width="500">nprobes=10,refine_factor=none/mean_query_time</td>
      <td width="280">0.005725554943084717</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=none/recall_at_1</td>
      <td width="280">0.438</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=1

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
      <td width="500">nprobes=100,refine_factor=1/mean_query_time</td>
      <td width="280">0.015196753501892089</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=1/recall_at_1</td>
      <td width="280">0.447</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=10

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
      <td width="500">nprobes=100,refine_factor=10/mean_query_time</td>
      <td width="280">0.016570975780487062</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=10/recall_at_1</td>
      <td width="280">0.892</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=20

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
      <td width="500">nprobes=100,refine_factor=20/mean_query_time</td>
      <td width="280">0.018924864053726197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=20/recall_at_1</td>
      <td width="280">0.961</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=30

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
      <td width="500">nprobes=100,refine_factor=30/mean_query_time</td>
      <td width="280">0.02154319357872009</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=30/recall_at_1</td>
      <td width="280">0.976</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=40

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
      <td width="500">nprobes=100,refine_factor=40/mean_query_time</td>
      <td width="280">0.02640098214149475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=40/recall_at_1</td>
      <td width="280">0.983</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=50

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
      <td width="500">nprobes=100,refine_factor=50/mean_query_time</td>
      <td width="280">0.021464047431945802</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=50/recall_at_1</td>
      <td width="280">0.986</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=100,refine_factor=none

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
      <td width="500">nprobes=100,refine_factor=none/mean_query_time</td>
      <td width="280">0.013142791032791137</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=none/recall_at_1</td>
      <td width="280">0.447</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=1

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
      <td width="500">nprobes=25,refine_factor=1/mean_query_time</td>
      <td width="280">0.008517679691314697</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=1/recall_at_1</td>
      <td width="280">0.446</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=10

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
      <td width="500">nprobes=25,refine_factor=10/mean_query_time</td>
      <td width="280">0.01077463173866272</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=10/recall_at_1</td>
      <td width="280">0.891</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=20

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
      <td width="500">nprobes=25,refine_factor=20/mean_query_time</td>
      <td width="280">0.010751885652542115</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=20/recall_at_1</td>
      <td width="280">0.96</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=30

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
      <td width="500">nprobes=25,refine_factor=30/mean_query_time</td>
      <td width="280">0.0160760133266449</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=30/recall_at_1</td>
      <td width="280">0.975</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=40

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
      <td width="500">nprobes=25,refine_factor=40/mean_query_time</td>
      <td width="280">0.018794228315353392</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=40/recall_at_1</td>
      <td width="280">0.982</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=50

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
      <td width="500">nprobes=25,refine_factor=50/mean_query_time</td>
      <td width="280">0.01697736191749573</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=50/recall_at_1</td>
      <td width="280">0.985</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=25,refine_factor=none

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
      <td width="500">nprobes=25,refine_factor=none/mean_query_time</td>
      <td width="280">0.007372876644134521</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=none/recall_at_1</td>
      <td width="280">0.446</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=1

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
      <td width="500">nprobes=50,refine_factor=1/mean_query_time</td>
      <td width="280">0.01027724027633667</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=1/recall_at_1</td>
      <td width="280">0.447</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=10

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
      <td width="500">nprobes=50,refine_factor=10/mean_query_time</td>
      <td width="280">0.013400490283966065</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=10/recall_at_1</td>
      <td width="280">0.892</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=20

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
      <td width="500">nprobes=50,refine_factor=20/mean_query_time</td>
      <td width="280">0.014154971837997436</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=20/recall_at_1</td>
      <td width="280">0.961</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=30

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
      <td width="500">nprobes=50,refine_factor=30/mean_query_time</td>
      <td width="280">0.018411922693252564</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=30/recall_at_1</td>
      <td width="280">0.976</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=40

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
      <td width="500">nprobes=50,refine_factor=40/mean_query_time</td>
      <td width="280">0.0176273033618927</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=40/recall_at_1</td>
      <td width="280">0.983</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=50

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
      <td width="500">nprobes=50,refine_factor=50/mean_query_time</td>
      <td width="280">0.02254028844833374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=50/recall_at_1</td>
      <td width="280">0.986</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=50,refine_factor=none

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
      <td width="500">nprobes=50,refine_factor=none/mean_query_time</td>
      <td width="280">0.009735166788101197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=none/recall_at_1</td>
      <td width="280">0.447</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=1

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
      <td width="500">nprobes=75,refine_factor=1/mean_query_time</td>
      <td width="280">0.013492329359054565</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=1/recall_at_1</td>
      <td width="280">0.447</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=10

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
      <td width="500">nprobes=75,refine_factor=10/mean_query_time</td>
      <td width="280">0.015122019290924072</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=10/recall_at_1</td>
      <td width="280">0.892</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=20

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
      <td width="500">nprobes=75,refine_factor=20/mean_query_time</td>
      <td width="280">0.015415410041809081</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=20/recall_at_1</td>
      <td width="280">0.961</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=30

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
      <td width="500">nprobes=75,refine_factor=30/mean_query_time</td>
      <td width="280">0.01959055757522583</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=30/recall_at_1</td>
      <td width="280">0.976</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=40

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
      <td width="500">nprobes=75,refine_factor=40/mean_query_time</td>
      <td width="280">0.01988649129867554</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=40/recall_at_1</td>
      <td width="280">0.983</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=50

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
      <td width="500">nprobes=75,refine_factor=50/mean_query_time</td>
      <td width="280">0.02005660581588745</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=50/recall_at_1</td>
      <td width="280">0.986</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### nprobes=75,refine_factor=none

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
      <td width="500">nprobes=75,refine_factor=none/mean_query_time</td>
      <td width="280">0.011492565393447876</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=none/recall_at_1</td>
      <td width="280">0.447</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### lance 13.0.0

#### nprobes=1,refine_factor=1

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
      <td width="400">nprobes=1,refine_factor=1/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.00122989821434021</td>
      <td width="200">0.004252521991729736</td>
      <td width="380">0.2892</td>
    </tr>
    <tr>
      <td width="400">nprobes=1,refine_factor=1/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.289</td>
      <td width="200">0.3</td>
      <td width="380">1.0381</td>
    </tr>
  </tbody>
</table>

#### nprobes=1,refine_factor=10

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
      <td width="400">nprobes=1,refine_factor=10/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0013705015182495118</td>
      <td width="200">0.007630712032318116</td>
      <td width="380">0.1796</td>
    </tr>
    <tr>
      <td width="400">nprobes=1,refine_factor=10/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.479</td>
      <td width="200">0.51</td>
      <td width="380">1.0647</td>
    </tr>
  </tbody>
</table>

#### nprobes=1,refine_factor=20

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
      <td width="400">nprobes=1,refine_factor=20/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0013538064956665039</td>
      <td width="200">0.008721610069274903</td>
      <td width="380">0.1552</td>
    </tr>
    <tr>
      <td width="400">nprobes=1,refine_factor=20/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.492</td>
      <td width="200">0.526</td>
      <td width="380">1.0691</td>
    </tr>
  </tbody>
</table>

#### nprobes=1,refine_factor=30

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
      <td width="400">nprobes=1,refine_factor=30/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0013089995384216308</td>
      <td width="200">0.01054902744293213</td>
      <td width="380">0.1241</td>
    </tr>
    <tr>
      <td width="400">nprobes=1,refine_factor=30/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.496</td>
      <td width="200">0.527</td>
      <td width="380">1.0625</td>
    </tr>
  </tbody>
</table>

#### nprobes=1,refine_factor=40

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
      <td width="400">nprobes=1,refine_factor=40/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0013406226634979249</td>
      <td width="200">0.01633111023902893</td>
      <td width="380">0.0821</td>
    </tr>
    <tr>
      <td width="400">nprobes=1,refine_factor=40/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.496</td>
      <td width="200">0.53</td>
      <td width="380">1.0685</td>
    </tr>
  </tbody>
</table>

#### nprobes=1,refine_factor=50

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
      <td width="400">nprobes=1,refine_factor=50/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0014215428829193115</td>
      <td width="200">0.015829875946044923</td>
      <td width="380">0.0898</td>
    </tr>
    <tr>
      <td width="400">nprobes=1,refine_factor=50/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.499</td>
      <td width="200">0.53</td>
      <td width="380">1.0621</td>
    </tr>
  </tbody>
</table>

#### nprobes=1,refine_factor=none

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
      <td width="400">nprobes=1,refine_factor=none/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0010795209407806396</td>
      <td width="200">0.003971836566925049</td>
      <td width="380">0.2718</td>
    </tr>
    <tr>
      <td width="400">nprobes=1,refine_factor=none/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.289</td>
      <td width="200">0.3</td>
      <td width="380">1.0381</td>
    </tr>
  </tbody>
</table>

#### nprobes=10,refine_factor=1

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
      <td width="400">nprobes=10,refine_factor=1/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0015138669013977052</td>
      <td width="200">0.006200378179550171</td>
      <td width="380">0.2442</td>
    </tr>
    <tr>
      <td width="400">nprobes=10,refine_factor=1/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.455</td>
      <td width="200">0.438</td>
      <td width="380">0.9626</td>
    </tr>
  </tbody>
</table>

#### nprobes=10,refine_factor=10

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
      <td width="400">nprobes=10,refine_factor=10/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0015335733890533448</td>
      <td width="200">0.009572388172149658</td>
      <td width="380">0.1602</td>
    </tr>
    <tr>
      <td width="400">nprobes=10,refine_factor=10/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.867</td>
      <td width="200">0.877</td>
      <td width="380">1.0115</td>
    </tr>
  </tbody>
</table>

#### nprobes=10,refine_factor=20

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
      <td width="400">nprobes=10,refine_factor=20/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0015966274738311768</td>
      <td width="200">0.009475063800811768</td>
      <td width="380">0.1685</td>
    </tr>
    <tr>
      <td width="400">nprobes=10,refine_factor=20/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.928</td>
      <td width="200">0.942</td>
      <td width="380">1.0151</td>
    </tr>
  </tbody>
</table>

#### nprobes=10,refine_factor=30

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
      <td width="400">nprobes=10,refine_factor=30/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0016234753131866455</td>
      <td width="200">0.01224823784828186</td>
      <td width="380">0.1325</td>
    </tr>
    <tr>
      <td width="400">nprobes=10,refine_factor=30/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.947</td>
      <td width="200">0.955</td>
      <td width="380">1.0084</td>
    </tr>
  </tbody>
</table>

#### nprobes=10,refine_factor=40

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
      <td width="400">nprobes=10,refine_factor=40/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0018463349342346192</td>
      <td width="200">0.014960773229599</td>
      <td width="380">0.1234</td>
    </tr>
    <tr>
      <td width="400">nprobes=10,refine_factor=40/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.959</td>
      <td width="200">0.961</td>
      <td width="380">1.0021</td>
    </tr>
  </tbody>
</table>

#### nprobes=10,refine_factor=50

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
      <td width="400">nprobes=10,refine_factor=50/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.00230857253074646</td>
      <td width="200">0.02082332706451416</td>
      <td width="380">0.1109</td>
    </tr>
    <tr>
      <td width="400">nprobes=10,refine_factor=50/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.964</td>
      <td width="200">0.963</td>
      <td width="380">0.999</td>
    </tr>
  </tbody>
</table>

#### nprobes=10,refine_factor=none

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
      <td width="400">nprobes=10,refine_factor=none/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0012049386501312256</td>
      <td width="200">0.005725554943084717</td>
      <td width="380">0.2104</td>
    </tr>
    <tr>
      <td width="400">nprobes=10,refine_factor=none/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.455</td>
      <td width="200">0.438</td>
      <td width="380">0.9626</td>
    </tr>
  </tbody>
</table>

#### nprobes=100,refine_factor=1

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
      <td width="400">nprobes=100,refine_factor=1/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.004389755725860596</td>
      <td width="200">0.015196753501892089</td>
      <td width="380">0.2889</td>
    </tr>
    <tr>
      <td width="400">nprobes=100,refine_factor=1/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.46</td>
      <td width="200">0.447</td>
      <td width="380">0.9717</td>
    </tr>
  </tbody>
</table>

#### nprobes=100,refine_factor=10

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
      <td width="400">nprobes=100,refine_factor=10/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.004751595020294189</td>
      <td width="200">0.016570975780487062</td>
      <td width="380">0.2867</td>
    </tr>
    <tr>
      <td width="400">nprobes=100,refine_factor=10/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.885</td>
      <td width="200">0.892</td>
      <td width="380">1.0079</td>
    </tr>
  </tbody>
</table>

#### nprobes=100,refine_factor=20

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
      <td width="400">nprobes=100,refine_factor=20/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.004683312892913819</td>
      <td width="200">0.018924864053726197</td>
      <td width="380">0.2475</td>
    </tr>
    <tr>
      <td width="400">nprobes=100,refine_factor=20/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.953</td>
      <td width="200">0.961</td>
      <td width="380">1.0084</td>
    </tr>
  </tbody>
</table>

#### nprobes=100,refine_factor=30

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
      <td width="400">nprobes=100,refine_factor=30/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.004860017538070679</td>
      <td width="200">0.02154319357872009</td>
      <td width="380">0.2256</td>
    </tr>
    <tr>
      <td width="400">nprobes=100,refine_factor=30/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.973</td>
      <td width="200">0.976</td>
      <td width="380">1.0031</td>
    </tr>
  </tbody>
</table>

#### nprobes=100,refine_factor=40

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
      <td width="400">nprobes=100,refine_factor=40/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.004982337951660156</td>
      <td width="200">0.02640098214149475</td>
      <td width="380">0.1887</td>
    </tr>
    <tr>
      <td width="400">nprobes=100,refine_factor=40/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.987</td>
      <td width="200">0.983</td>
      <td width="380">0.9959</td>
    </tr>
  </tbody>
</table>

#### nprobes=100,refine_factor=50

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
      <td width="400">nprobes=100,refine_factor=50/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.005027457714080811</td>
      <td width="200">0.021464047431945802</td>
      <td width="380">0.2342</td>
    </tr>
    <tr>
      <td width="400">nprobes=100,refine_factor=50/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.993</td>
      <td width="200">0.986</td>
      <td width="380">0.993</td>
    </tr>
  </tbody>
</table>

#### nprobes=100,refine_factor=none

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
      <td width="400">nprobes=100,refine_factor=none/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.004188713550567627</td>
      <td width="200">0.013142791032791137</td>
      <td width="380">0.3187</td>
    </tr>
    <tr>
      <td width="400">nprobes=100,refine_factor=none/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.46</td>
      <td width="200">0.447</td>
      <td width="380">0.9717</td>
    </tr>
  </tbody>
</table>

#### nprobes=25,refine_factor=1

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
      <td width="400">nprobes=25,refine_factor=1/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0023599042892456057</td>
      <td width="200">0.008517679691314697</td>
      <td width="380">0.2771</td>
    </tr>
    <tr>
      <td width="400">nprobes=25,refine_factor=1/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.46</td>
      <td width="200">0.446</td>
      <td width="380">0.9696</td>
    </tr>
  </tbody>
</table>

#### nprobes=25,refine_factor=10

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
      <td width="400">nprobes=25,refine_factor=10/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0026242117881774903</td>
      <td width="200">0.01077463173866272</td>
      <td width="380">0.2436</td>
    </tr>
    <tr>
      <td width="400">nprobes=25,refine_factor=10/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.885</td>
      <td width="200">0.891</td>
      <td width="380">1.0068</td>
    </tr>
  </tbody>
</table>

#### nprobes=25,refine_factor=20

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
      <td width="400">nprobes=25,refine_factor=20/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.002624452590942383</td>
      <td width="200">0.010751885652542115</td>
      <td width="380">0.2441</td>
    </tr>
    <tr>
      <td width="400">nprobes=25,refine_factor=20/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.953</td>
      <td width="200">0.96</td>
      <td width="380">1.0073</td>
    </tr>
  </tbody>
</table>

#### nprobes=25,refine_factor=30

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
      <td width="400">nprobes=25,refine_factor=30/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.002522761821746826</td>
      <td width="200">0.0160760133266449</td>
      <td width="380">0.1569</td>
    </tr>
    <tr>
      <td width="400">nprobes=25,refine_factor=30/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.973</td>
      <td width="200">0.975</td>
      <td width="380">1.0021</td>
    </tr>
  </tbody>
</table>

#### nprobes=25,refine_factor=40

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
      <td width="400">nprobes=25,refine_factor=40/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0025836198329925535</td>
      <td width="200">0.018794228315353392</td>
      <td width="380">0.1375</td>
    </tr>
    <tr>
      <td width="400">nprobes=25,refine_factor=40/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.987</td>
      <td width="200">0.982</td>
      <td width="380">0.9949</td>
    </tr>
  </tbody>
</table>

#### nprobes=25,refine_factor=50

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
      <td width="400">nprobes=25,refine_factor=50/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0026563000679016113</td>
      <td width="200">0.01697736191749573</td>
      <td width="380">0.1565</td>
    </tr>
    <tr>
      <td width="400">nprobes=25,refine_factor=50/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.993</td>
      <td width="200">0.985</td>
      <td width="380">0.9919</td>
    </tr>
  </tbody>
</table>

#### nprobes=25,refine_factor=none

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
      <td width="400">nprobes=25,refine_factor=none/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0019903056621551514</td>
      <td width="200">0.007372876644134521</td>
      <td width="380">0.2699</td>
    </tr>
    <tr>
      <td width="400">nprobes=25,refine_factor=none/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.46</td>
      <td width="200">0.446</td>
      <td width="380">0.9696</td>
    </tr>
  </tbody>
</table>

#### nprobes=50,refine_factor=1

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
      <td width="400">nprobes=50,refine_factor=1/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.00318346381187439</td>
      <td width="200">0.01027724027633667</td>
      <td width="380">0.3098</td>
    </tr>
    <tr>
      <td width="400">nprobes=50,refine_factor=1/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.46</td>
      <td width="200">0.447</td>
      <td width="380">0.9717</td>
    </tr>
  </tbody>
</table>

#### nprobes=50,refine_factor=10

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
      <td width="400">nprobes=50,refine_factor=10/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0031737141609191897</td>
      <td width="200">0.013400490283966065</td>
      <td width="380">0.2368</td>
    </tr>
    <tr>
      <td width="400">nprobes=50,refine_factor=10/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.885</td>
      <td width="200">0.892</td>
      <td width="380">1.0079</td>
    </tr>
  </tbody>
</table>

#### nprobes=50,refine_factor=20

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
      <td width="400">nprobes=50,refine_factor=20/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.003340775728225708</td>
      <td width="200">0.014154971837997436</td>
      <td width="380">0.236</td>
    </tr>
    <tr>
      <td width="400">nprobes=50,refine_factor=20/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.953</td>
      <td width="200">0.961</td>
      <td width="380">1.0084</td>
    </tr>
  </tbody>
</table>

#### nprobes=50,refine_factor=30

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
      <td width="400">nprobes=50,refine_factor=30/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0034741928577423095</td>
      <td width="200">0.018411922693252564</td>
      <td width="380">0.1887</td>
    </tr>
    <tr>
      <td width="400">nprobes=50,refine_factor=30/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.973</td>
      <td width="200">0.976</td>
      <td width="380">1.0031</td>
    </tr>
  </tbody>
</table>

#### nprobes=50,refine_factor=40

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
      <td width="400">nprobes=50,refine_factor=40/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0036256492137908937</td>
      <td width="200">0.0176273033618927</td>
      <td width="380">0.2057</td>
    </tr>
    <tr>
      <td width="400">nprobes=50,refine_factor=40/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.987</td>
      <td width="200">0.983</td>
      <td width="380">0.9959</td>
    </tr>
  </tbody>
</table>

#### nprobes=50,refine_factor=50

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
      <td width="400">nprobes=50,refine_factor=50/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.003533083438873291</td>
      <td width="200">0.02254028844833374</td>
      <td width="380">0.1567</td>
    </tr>
    <tr>
      <td width="400">nprobes=50,refine_factor=50/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.993</td>
      <td width="200">0.986</td>
      <td width="380">0.993</td>
    </tr>
  </tbody>
</table>

#### nprobes=50,refine_factor=none

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
      <td width="400">nprobes=50,refine_factor=none/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0025994510650634768</td>
      <td width="200">0.009735166788101197</td>
      <td width="380">0.267</td>
    </tr>
    <tr>
      <td width="400">nprobes=50,refine_factor=none/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.46</td>
      <td width="200">0.447</td>
      <td width="380">0.9717</td>
    </tr>
  </tbody>
</table>

#### nprobes=75,refine_factor=1

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
      <td width="400">nprobes=75,refine_factor=1/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.00405472469329834</td>
      <td width="200">0.013492329359054565</td>
      <td width="380">0.3005</td>
    </tr>
    <tr>
      <td width="400">nprobes=75,refine_factor=1/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.46</td>
      <td width="200">0.447</td>
      <td width="380">0.9717</td>
    </tr>
  </tbody>
</table>

#### nprobes=75,refine_factor=10

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
      <td width="400">nprobes=75,refine_factor=10/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.003950880527496338</td>
      <td width="200">0.015122019290924072</td>
      <td width="380">0.2613</td>
    </tr>
    <tr>
      <td width="400">nprobes=75,refine_factor=10/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.885</td>
      <td width="200">0.892</td>
      <td width="380">1.0079</td>
    </tr>
  </tbody>
</table>

#### nprobes=75,refine_factor=20

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
      <td width="400">nprobes=75,refine_factor=20/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.0038808276653289793</td>
      <td width="200">0.015415410041809081</td>
      <td width="380">0.2517</td>
    </tr>
    <tr>
      <td width="400">nprobes=75,refine_factor=20/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.953</td>
      <td width="200">0.961</td>
      <td width="380">1.0084</td>
    </tr>
  </tbody>
</table>

#### nprobes=75,refine_factor=30

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
      <td width="400">nprobes=75,refine_factor=30/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.003869875192642212</td>
      <td width="200">0.01959055757522583</td>
      <td width="380">0.1975</td>
    </tr>
    <tr>
      <td width="400">nprobes=75,refine_factor=30/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.973</td>
      <td width="200">0.976</td>
      <td width="380">1.0031</td>
    </tr>
  </tbody>
</table>

#### nprobes=75,refine_factor=40

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
      <td width="400">nprobes=75,refine_factor=40/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.004033694505691529</td>
      <td width="200">0.01988649129867554</td>
      <td width="380">0.2028</td>
    </tr>
    <tr>
      <td width="400">nprobes=75,refine_factor=40/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.987</td>
      <td width="200">0.983</td>
      <td width="380">0.9959</td>
    </tr>
  </tbody>
</table>

#### nprobes=75,refine_factor=50

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
      <td width="400">nprobes=75,refine_factor=50/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.004145896911621093</td>
      <td width="200">0.02005660581588745</td>
      <td width="380">0.2067</td>
    </tr>
    <tr>
      <td width="400">nprobes=75,refine_factor=50/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.993</td>
      <td width="200">0.986</td>
      <td width="380">0.993</td>
    </tr>
  </tbody>
</table>

#### nprobes=75,refine_factor=none

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
      <td width="400">nprobes=75,refine_factor=none/mean_query_time</td>
      <td width="200">越小越好</td>
      <td width="200">0.003336729288101196</td>
      <td width="200">0.011492565393447876</td>
      <td width="380">0.2903</td>
    </tr>
    <tr>
      <td width="400">nprobes=75,refine_factor=none/recall_at_1</td>
      <td width="200">越大越好</td>
      <td width="200">0.46</td>
      <td width="200">0.447</td>
      <td width="380">0.9717</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
