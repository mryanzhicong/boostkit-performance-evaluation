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
      <td width="180">Media</td>
      <td width="220">x264</td>
      <td width="160">0.165.3223</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Media</td>
      <td width="220">x264</td>
      <td width="160">0.165.3223</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### x264 0.165.3223

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
      <td width="600">0.165.3223</td>
      <td width="600">0.165.3223</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">0.165.3223</td>
      <td width="600">0.165.3223</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-12T15:43:00Z</td>
      <td width="600">2026-11-12T15:43:00Z</td>
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
      <td width="600">2026-11-12T15:42:49Z</td>
      <td width="600">2026-11-12T15:42:50Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 135177 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 150250 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 169013 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 163200 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193481 MB<br>node 4 free: 166976 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193523 MB<br>node 5 free: 169858 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 70944 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 59244 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 377326 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 382541 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 373228 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 383006 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">x264</td>
      <td width="880">0.165.3223</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### x264 0.165.3223

##### 单路

###### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="500">2000k/total_fps</td>
      <td width="280">23.3</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">19.57</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">17.19</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">15.65</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### BQTerrace_1920x1080_60-dianbo

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
      <td width="500">2000k/total_fps</td>
      <td width="280">29.69</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">26.55</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">24.39</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">22.52</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### messi_1920x1080_25_1000

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
      <td width="500">2000k/total_fps</td>
      <td width="280">28.82</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">24.24</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">21.93</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">20.42</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 整机

###### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="500">2000k/total_fps</td>
      <td width="280">853.79</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">724.77</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">628.6</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">573.91</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### BQTerrace_1920x1080_60-dianbo

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
      <td width="500">2000k/total_fps</td>
      <td width="280">1153.22</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">1016.86</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">918.42</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">839.92</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### messi_1920x1080_25_1000

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
      <td width="500">2000k/total_fps</td>
      <td width="280">1073.13</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">896.0</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">806.14</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">748.04</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### x264 0.165.3223

##### 单路

###### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="500">2000k/total_fps</td>
      <td width="280">17.95</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">15.12</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">13.28</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">12.11</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### BQTerrace_1920x1080_60-dianbo

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
      <td width="500">2000k/total_fps</td>
      <td width="280">23.62</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">21.0</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">19.12</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">17.59</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### messi_1920x1080_25_1000

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
      <td width="500">2000k/total_fps</td>
      <td width="280">22.46</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">18.84</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">16.9</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">15.73</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 整机

###### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="500">2000k/total_fps</td>
      <td width="280">678.21</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">565.28</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">498.16</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">453.22</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### BQTerrace_1920x1080_60-dianbo

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
      <td width="500">2000k/total_fps</td>
      <td width="280">929.22</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">815.64</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">736.22</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">671.07</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### messi_1920x1080_25_1000

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
      <td width="500">2000k/total_fps</td>
      <td width="280">850.02</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">708.55</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">639.48</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">594.25</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### x264 0.165.3223

#### 单路

##### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">23.3</td>
      <td width="200">17.95</td>
      <td width="380">0.7704</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">19.57</td>
      <td width="200">15.12</td>
      <td width="380">0.7726</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">17.19</td>
      <td width="200">13.28</td>
      <td width="380">0.7725</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">15.65</td>
      <td width="200">12.11</td>
      <td width="380">0.7738</td>
    </tr>
  </tbody>
</table>

##### BQTerrace_1920x1080_60-dianbo

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">29.69</td>
      <td width="200">23.62</td>
      <td width="380">0.7956</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">26.55</td>
      <td width="200">21.0</td>
      <td width="380">0.791</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">24.39</td>
      <td width="200">19.12</td>
      <td width="380">0.7839</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">22.52</td>
      <td width="200">17.59</td>
      <td width="380">0.7811</td>
    </tr>
  </tbody>
</table>

##### messi_1920x1080_25_1000

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">28.82</td>
      <td width="200">22.46</td>
      <td width="380">0.7793</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">24.24</td>
      <td width="200">18.84</td>
      <td width="380">0.7772</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">21.93</td>
      <td width="200">16.9</td>
      <td width="380">0.7706</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">20.42</td>
      <td width="200">15.73</td>
      <td width="380">0.7703</td>
    </tr>
  </tbody>
</table>

#### 整机

##### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">853.79</td>
      <td width="200">678.21</td>
      <td width="380">0.7944</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">724.77</td>
      <td width="200">565.28</td>
      <td width="380">0.7799</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">628.6</td>
      <td width="200">498.16</td>
      <td width="380">0.7925</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">573.91</td>
      <td width="200">453.22</td>
      <td width="380">0.7897</td>
    </tr>
  </tbody>
</table>

##### BQTerrace_1920x1080_60-dianbo

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">1153.22</td>
      <td width="200">929.22</td>
      <td width="380">0.8058</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">1016.86</td>
      <td width="200">815.64</td>
      <td width="380">0.8021</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">918.42</td>
      <td width="200">736.22</td>
      <td width="380">0.8016</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">839.92</td>
      <td width="200">671.07</td>
      <td width="380">0.799</td>
    </tr>
  </tbody>
</table>

##### messi_1920x1080_25_1000

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">1073.13</td>
      <td width="200">850.02</td>
      <td width="380">0.7921</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">896.0</td>
      <td width="200">708.55</td>
      <td width="380">0.7908</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">806.14</td>
      <td width="200">639.48</td>
      <td width="380">0.7933</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">748.04</td>
      <td width="200">594.25</td>
      <td width="380">0.7944</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
