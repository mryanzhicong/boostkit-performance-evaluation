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
      <td width="220">protobuf</td>
      <td width="160">33.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">protobuf</td>
      <td width="160">33.0</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### protobuf 33.0

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
      <td width="600">33.0</td>
      <td width="600">33.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">33.0</td>
      <td width="600">33.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-12T20:46:00Z</td>
      <td width="600">2026-11-12T20:46:14Z</td>
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
      <td width="600">2026-11-12T20:44:52Z</td>
      <td width="600">2026-11-12T20:44:51Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 175896 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 176614 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 176969 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 176351 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193481 MB<br>node 4 free: 176809 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193523 MB<br>node 5 free: 176996 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 76247 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 75692 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 378180 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 382791 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 379374 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 383969 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">AccLibBenchmark/protobuf-benchmark</td>
      <td width="880">01d083c6633babb2fb1307d93f596f10dda36778</td>
    </tr>
    <tr>
      <td width="500">google-benchmark</td>
      <td width="880">1.8.3</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### protobuf 33.0

##### 序列化 / Scalar（非 packed）

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
      <td width="500">BM_Serialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="280">13.522174117150948</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">63.01519819292613</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">555.8165486749151</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">5434.243933494696</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">16.206047749998742</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">113.59246694827182</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">1094.6285056831452</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">10830.30451197606</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">32.52866251463951</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">260.0232088525624</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">2413.3365391410084</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">25414.086538809424</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">15.4033120539479</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">112.77945483532353</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">1093.5372031563265</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">10829.700516018534</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">39.68776521406976</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">345.6840802420392</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">3478.0538954978438</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">36214.69050573991</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">39.72093812475858</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">413.0595337397939</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">4306.446124921485</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">41936.90268425922</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">44.20980458686294</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">405.7894067248716</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">4521.95485653359</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">45456.36260025374</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">52.90557580468924</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">483.91872171198764</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">4829.76579903926</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">47850.6556484348</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">37.436138194844546</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">316.744020493215</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">3630.073636368354</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">36708.63679270016</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">51.35525674919405</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">462.6980588234493</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">5175.302359009899</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">51154.76145045136</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 反序列化 / Scalar（非 packed）

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
      <td width="500">BM_Deserialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="280">59.018824016492715</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">218.03113461419343</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">1501.1032261453809</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">13985.849517768474</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">73.85433751820032</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">201.64607012439785</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">1342.6153105286662</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">13393.013359381717</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">58.35178406255245</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">216.01298390756193</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">1301.6408619957467</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">12159.303750173778</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">53.280528888519086</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">172.65104572446933</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">1098.1122709057672</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">10407.06603127373</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">63.74334747920981</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">295.2613854248758</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">2637.331716967951</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">26462.243483188526</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">83.09363597933213</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">375.0125317485839</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">3108.122580990196</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">31925.785242562048</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">67.5910775989474</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">320.6580013781835</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">2634.4367111465417</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">27628.117034930754</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">81.97116287613733</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">367.0832333308598</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">3035.3053014187003</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">29984.340326040634</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">63.4725097226504</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">281.05877532467144</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">2480.1768810652707</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">24385.485377465477</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">87.56555518353419</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">378.31205998699033</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">3289.990345925958</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">32468.65962198131</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 序列化 / Repeated（packed）

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
      <td width="500">BM_Serialize_Repeated_Double/10/cpu_time_median</td>
      <td width="280">10.27680422748561</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">15.82926993286324</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">80.22919379446411</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1429.8928338383682</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">10.81769817427718</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">12.473237750541914</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">44.36755058418953</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">735.9363483653391</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">33.75672125258447</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">322.2589933722347</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">3637.5730551469946</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">36755.70218184624</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">47.36480385452188</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">359.9762012033217</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">4101.766076412872</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">41148.84381885457</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">43.01137240680826</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">335.34837419322963</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">3823.7691470096274</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">38232.7889707885</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">54.01974645006604</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">461.2055069801849</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">4776.912597256597</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">54310.49562218931</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">34.10341304215223</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">299.34381737785515</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">3391.2215582809313</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">34179.583943745085</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">40.90052702269646</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">385.676695291904</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">4221.837935069806</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">41810.99070155737</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 反序列化 / Repeated（packed）

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
      <td width="500">BM_Deserialize_Repeated_Double/10/cpu_time_median</td>
      <td width="280">29.21486222566337</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">32.92321258721364</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">108.5139737806763</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1480.5877339571182</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">28.402950979553893</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">31.06578895121879</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">77.4910840900174</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">782.5720019341118</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">65.47022797743142</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">287.6332944614111</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">3043.2284659174065</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">29738.47294167754</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">78.58591066451815</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">406.4860632230043</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">4325.0200684072415</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">43440.69920238313</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">68.44954730121108</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">285.36709829852873</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">3331.922849942975</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">33897.704901341815</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">82.07331826096572</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">463.48054016414665</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">4624.050758238177</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">46784.765275459504</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">67.06851561950783</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">296.1937308659166</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">3021.831229711933</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">29828.506430472127</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">84.82924918584251</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">436.6506731595321</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">4384.641991511515</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">44734.70910824944</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 序列化 / String 与 Bytes

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
      <td width="500">BM_Serialize_Bytes/10/cpu_time_median</td>
      <td width="280">12.440496169963929</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/100/cpu_time_median</td>
      <td width="280">12.710947409489693</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/1000/cpu_time_median</td>
      <td width="280">19.89491206416238</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/10000/cpu_time_median</td>
      <td width="280">95.7889748628937</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">16.227340057262</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">18.391670297088606</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">74.71127395051695</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">650.5681723980758</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">17.580085655980497</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">29.63354728832159</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">177.63559581653342</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1634.5509872662665</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 反序列化 / String 与 Bytes

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
      <td width="500">BM_Deserialize_Bytes/10/cpu_time_median</td>
      <td width="280">37.60346518575909</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/100/cpu_time_median</td>
      <td width="280">47.348574675241956</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/1000/cpu_time_median</td>
      <td width="280">52.29119170246734</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/10000/cpu_time_median</td>
      <td width="280">226.70990294707332</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">43.818453955271636</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">56.00874559336884</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">109.73513341283689</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">786.9414302342091</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">47.61525557757113</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">63.91623839040926</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">217.51746888528191</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1775.9148066904522</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### protobuf 33.0

##### 序列化 / Scalar（非 packed）

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
      <td width="500">BM_Serialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="280">17.7567098040368</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">128.5663114126108</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">1169.9958465826662</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">11569.263121364622</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">14.896875624652463</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">90.1904984456603</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">849.3230868319896</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">8122.637736614808</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">32.529039099220256</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">256.94481130666117</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">2659.766627171116</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">24879.977265057365</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">14.50402617332576</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">89.81503528506708</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">803.3003722707473</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">7712.810794136849</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">45.31065946483661</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">396.95443826259276</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">4163.646537970886</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">91165.47212165088</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">44.37655967770242</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">506.54860137156146</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">5600.975381450851</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">103544.90294351612</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">38.65345887901271</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">307.4066560839663</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">3544.558695963708</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">89692.98476407901</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">62.34998218323527</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">558.1721438636348</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">6323.858871097698</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">120815.34031882502</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">35.1150023929224</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">256.12541335251314</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">2936.602345811169</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">68587.65156070596</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">51.592347194414366</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">521.275685782683</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">5751.638998815781</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">121330.50810416935</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 反序列化 / Scalar（非 packed）

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
      <td width="500">BM_Deserialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="280">89.90174243670477</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">370.65870143174544</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">3160.2656808085117</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">30161.541033766087</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">86.77988468236153</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">427.17903193071174</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">3364.598525355949</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">35402.75196929806</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">88.04954997231707</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">447.3104252441227</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">3593.4265491676492</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">37319.29187377212</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">66.81715342271315</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">427.8305463832181</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">3496.286872750906</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">35451.27534833973</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">94.61795625993635</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">440.10716964154153</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">3494.0563435380877</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">51055.133864437936</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">114.28387967585147</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">569.8089165999936</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">5767.31491364148</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">75788.98291480218</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">91.85738486115322</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">451.3503540254563</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">4129.853178737129</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">51295.21792021413</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">139.90726298162403</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">645.0936438731832</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">6278.7288245724185</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">81435.94160760596</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">93.06290778695212</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">431.9650448529505</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">3448.533655886585</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">48921.840335400724</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">134.0311088532022</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">596.0442522278113</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">5827.354473012613</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">73456.97020893086</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 序列化 / Repeated（packed）

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
      <td width="500">BM_Serialize_Repeated_Double/10/cpu_time_median</td>
      <td width="280">9.239053745587752</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">18.127114287081366</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">111.95267330162255</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1054.067738933767</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">8.661947600635273</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">11.89318343337863</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">55.40796812127678</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">339.78518475903</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">39.38251461331728</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">360.35279464373997</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">4157.454263648252</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">61259.185076350186</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">59.171500800994835</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">492.2194821469418</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">5598.036788085419</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">82603.30778003216</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">42.656470672671034</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">318.2666470659131</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">3755.4113217018044</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">58076.17342577506</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">67.33601834231794</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">623.6495398706913</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">6328.242028466933</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">100496.50670912777</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">32.259370296071054</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">269.7190768694785</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">2956.819399836412</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">48861.12664397874</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">47.91546872427045</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">539.6267487572259</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">5664.989969909904</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">91648.87483085475</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 反序列化 / Repeated（packed）

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
      <td width="500">BM_Deserialize_Repeated_Double/10/cpu_time_median</td>
      <td width="280">31.78151210279956</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">45.94270293764326</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">154.61542139484706</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1110.3695824208282</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">31.25815973499342</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">41.717325181563396</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">81.46040504552748</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">426.4614237107417</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">76.91638136239226</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">440.91834812659016</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">4374.117781385676</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">60876.46127701309</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">99.7207963084604</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">542.6933498965157</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">6101.161055584778</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">73675.21018254521</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">87.43718941268628</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">454.2645430559215</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">5074.019743225438</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">59311.7797521661</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">105.86850691406894</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">659.2122050684785</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">6826.097523925353</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">80564.11170564446</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">73.62943821660552</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">446.8501471331143</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">4434.404812310036</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">56290.132296458</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">107.40269152796891</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">580.6370254087655</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">6034.698020785391</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">73225.19473805603</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 序列化 / String 与 Bytes

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
      <td width="500">BM_Serialize_Bytes/10/cpu_time_median</td>
      <td width="280">10.781229311815487</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/100/cpu_time_median</td>
      <td width="280">11.162652607597382</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/1000/cpu_time_median</td>
      <td width="280">21.44649580785351</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/10000/cpu_time_median</td>
      <td width="280">133.05594355219884</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">13.476364888350298</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">19.77302141021845</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">88.5692388080281</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">684.8520932386626</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">17.948812157007655</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">30.72274123569304</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">195.2116944509343</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1851.691974142113</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 反序列化 / String 与 Bytes

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
      <td width="500">BM_Deserialize_Bytes/10/cpu_time_median</td>
      <td width="280">37.18249389664252</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/100/cpu_time_median</td>
      <td width="280">50.28609231211514</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/1000/cpu_time_median</td>
      <td width="280">64.82757261053517</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/10000/cpu_time_median</td>
      <td width="280">244.44807906677693</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">40.57196319679358</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">61.29999014297695</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">146.79871966436127</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">809.9850931183743</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">45.59140769751143</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">78.69427003666104</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">248.85152423955225</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1966.1588337931253</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### protobuf 33.0

#### 序列化 / Scalar（非 packed）

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
      <td width="400">BM_Serialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">13.522174117150948</td>
      <td width="200">17.7567098040368</td>
      <td width="380">0.7615</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">63.01519819292613</td>
      <td width="200">128.5663114126108</td>
      <td width="380">0.4901</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">555.8165486749151</td>
      <td width="200">1169.9958465826662</td>
      <td width="380">0.4751</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">5434.243933494696</td>
      <td width="200">11569.263121364622</td>
      <td width="380">0.4697</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Double/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">16.206047749998742</td>
      <td width="200">14.896875624652463</td>
      <td width="380">1.0879</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Double/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">113.59246694827182</td>
      <td width="200">90.1904984456603</td>
      <td width="380">1.2595</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1094.6285056831452</td>
      <td width="200">849.3230868319896</td>
      <td width="380">1.2888</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10830.30451197606</td>
      <td width="200">8122.637736614808</td>
      <td width="380">1.3333</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">32.52866251463951</td>
      <td width="200">32.529039099220256</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">260.0232088525624</td>
      <td width="200">256.94481130666117</td>
      <td width="380">1.012</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">2413.3365391410084</td>
      <td width="200">2659.766627171116</td>
      <td width="380">0.9073</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">25414.086538809424</td>
      <td width="200">24879.977265057365</td>
      <td width="380">1.0215</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Float/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">15.4033120539479</td>
      <td width="200">14.50402617332576</td>
      <td width="380">1.062</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Float/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">112.77945483532353</td>
      <td width="200">89.81503528506708</td>
      <td width="380">1.2557</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1093.5372031563265</td>
      <td width="200">803.3003722707473</td>
      <td width="380">1.3613</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10829.700516018534</td>
      <td width="200">7712.810794136849</td>
      <td width="380">1.4041</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">39.68776521406976</td>
      <td width="200">45.31065946483661</td>
      <td width="380">0.8759</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">345.6840802420392</td>
      <td width="200">396.95443826259276</td>
      <td width="380">0.8708</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3478.0538954978438</td>
      <td width="200">4163.646537970886</td>
      <td width="380">0.8353</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">36214.69050573991</td>
      <td width="200">91165.47212165088</td>
      <td width="380">0.3972</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">39.72093812475858</td>
      <td width="200">44.37655967770242</td>
      <td width="380">0.8951</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">413.0595337397939</td>
      <td width="200">506.54860137156146</td>
      <td width="380">0.8154</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4306.446124921485</td>
      <td width="200">5600.975381450851</td>
      <td width="380">0.7689</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">41936.90268425922</td>
      <td width="200">103544.90294351612</td>
      <td width="380">0.405</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">44.20980458686294</td>
      <td width="200">38.65345887901271</td>
      <td width="380">1.1437</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">405.7894067248716</td>
      <td width="200">307.4066560839663</td>
      <td width="380">1.32</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4521.95485653359</td>
      <td width="200">3544.558695963708</td>
      <td width="380">1.2757</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">45456.36260025374</td>
      <td width="200">89692.98476407901</td>
      <td width="380">0.5068</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">52.90557580468924</td>
      <td width="200">62.34998218323527</td>
      <td width="380">0.8485</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">483.91872171198764</td>
      <td width="200">558.1721438636348</td>
      <td width="380">0.867</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4829.76579903926</td>
      <td width="200">6323.858871097698</td>
      <td width="380">0.7637</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">47850.6556484348</td>
      <td width="200">120815.34031882502</td>
      <td width="380">0.3961</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">37.436138194844546</td>
      <td width="200">35.1150023929224</td>
      <td width="380">1.0661</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">316.744020493215</td>
      <td width="200">256.12541335251314</td>
      <td width="380">1.2367</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3630.073636368354</td>
      <td width="200">2936.602345811169</td>
      <td width="380">1.2361</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">36708.63679270016</td>
      <td width="200">68587.65156070596</td>
      <td width="380">0.5352</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">51.35525674919405</td>
      <td width="200">51.592347194414366</td>
      <td width="380">0.9954</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">462.6980588234493</td>
      <td width="200">521.275685782683</td>
      <td width="380">0.8876</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">5175.302359009899</td>
      <td width="200">5751.638998815781</td>
      <td width="380">0.8998</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">51154.76145045136</td>
      <td width="200">121330.50810416935</td>
      <td width="380">0.4216</td>
    </tr>
  </tbody>
</table>

#### 反序列化 / Scalar（非 packed）

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
      <td width="400">BM_Deserialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">59.018824016492715</td>
      <td width="200">89.90174243670477</td>
      <td width="380">0.6565</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">218.03113461419343</td>
      <td width="200">370.65870143174544</td>
      <td width="380">0.5882</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1501.1032261453809</td>
      <td width="200">3160.2656808085117</td>
      <td width="380">0.475</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">13985.849517768474</td>
      <td width="200">30161.541033766087</td>
      <td width="380">0.4637</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Double/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">73.85433751820032</td>
      <td width="200">86.77988468236153</td>
      <td width="380">0.8511</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Double/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">201.64607012439785</td>
      <td width="200">427.17903193071174</td>
      <td width="380">0.472</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1342.6153105286662</td>
      <td width="200">3364.598525355949</td>
      <td width="380">0.399</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">13393.013359381717</td>
      <td width="200">35402.75196929806</td>
      <td width="380">0.3783</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">58.35178406255245</td>
      <td width="200">88.04954997231707</td>
      <td width="380">0.6627</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">216.01298390756193</td>
      <td width="200">447.3104252441227</td>
      <td width="380">0.4829</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1301.6408619957467</td>
      <td width="200">3593.4265491676492</td>
      <td width="380">0.3622</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">12159.303750173778</td>
      <td width="200">37319.29187377212</td>
      <td width="380">0.3258</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Float/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">53.280528888519086</td>
      <td width="200">66.81715342271315</td>
      <td width="380">0.7974</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Float/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">172.65104572446933</td>
      <td width="200">427.8305463832181</td>
      <td width="380">0.4036</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1098.1122709057672</td>
      <td width="200">3496.286872750906</td>
      <td width="380">0.3141</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10407.06603127373</td>
      <td width="200">35451.27534833973</td>
      <td width="380">0.2936</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">63.74334747920981</td>
      <td width="200">94.61795625993635</td>
      <td width="380">0.6737</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">295.2613854248758</td>
      <td width="200">440.10716964154153</td>
      <td width="380">0.6709</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">2637.331716967951</td>
      <td width="200">3494.0563435380877</td>
      <td width="380">0.7548</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">26462.243483188526</td>
      <td width="200">51055.133864437936</td>
      <td width="380">0.5183</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">83.09363597933213</td>
      <td width="200">114.28387967585147</td>
      <td width="380">0.7271</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">375.0125317485839</td>
      <td width="200">569.8089165999936</td>
      <td width="380">0.6581</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3108.122580990196</td>
      <td width="200">5767.31491364148</td>
      <td width="380">0.5389</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">31925.785242562048</td>
      <td width="200">75788.98291480218</td>
      <td width="380">0.4212</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">67.5910775989474</td>
      <td width="200">91.85738486115322</td>
      <td width="380">0.7358</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">320.6580013781835</td>
      <td width="200">451.3503540254563</td>
      <td width="380">0.7104</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">2634.4367111465417</td>
      <td width="200">4129.853178737129</td>
      <td width="380">0.6379</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">27628.117034930754</td>
      <td width="200">51295.21792021413</td>
      <td width="380">0.5386</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">81.97116287613733</td>
      <td width="200">139.90726298162403</td>
      <td width="380">0.5859</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">367.0832333308598</td>
      <td width="200">645.0936438731832</td>
      <td width="380">0.569</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3035.3053014187003</td>
      <td width="200">6278.7288245724185</td>
      <td width="380">0.4834</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">29984.340326040634</td>
      <td width="200">81435.94160760596</td>
      <td width="380">0.3682</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">63.4725097226504</td>
      <td width="200">93.06290778695212</td>
      <td width="380">0.682</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">281.05877532467144</td>
      <td width="200">431.9650448529505</td>
      <td width="380">0.6507</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">2480.1768810652707</td>
      <td width="200">3448.533655886585</td>
      <td width="380">0.7192</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">24385.485377465477</td>
      <td width="200">48921.840335400724</td>
      <td width="380">0.4985</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">87.56555518353419</td>
      <td width="200">134.0311088532022</td>
      <td width="380">0.6533</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">378.31205998699033</td>
      <td width="200">596.0442522278113</td>
      <td width="380">0.6347</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3289.990345925958</td>
      <td width="200">5827.354473012613</td>
      <td width="380">0.5646</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">32468.65962198131</td>
      <td width="200">73456.97020893086</td>
      <td width="380">0.442</td>
    </tr>
  </tbody>
</table>

#### 序列化 / Repeated（packed）

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
      <td width="400">BM_Serialize_Repeated_Double/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10.27680422748561</td>
      <td width="200">9.239053745587752</td>
      <td width="380">1.1123</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Double/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">15.82926993286324</td>
      <td width="200">18.127114287081366</td>
      <td width="380">0.8732</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">80.22919379446411</td>
      <td width="200">111.95267330162255</td>
      <td width="380">0.7166</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1429.8928338383682</td>
      <td width="200">1054.067738933767</td>
      <td width="380">1.3565</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Float/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10.81769817427718</td>
      <td width="200">8.661947600635273</td>
      <td width="380">1.2489</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Float/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">12.473237750541914</td>
      <td width="200">11.89318343337863</td>
      <td width="380">1.0488</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">44.36755058418953</td>
      <td width="200">55.40796812127678</td>
      <td width="380">0.8007</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">735.9363483653391</td>
      <td width="200">339.78518475903</td>
      <td width="380">2.1659</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">33.75672125258447</td>
      <td width="200">39.38251461331728</td>
      <td width="380">0.8571</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">322.2589933722347</td>
      <td width="200">360.35279464373997</td>
      <td width="380">0.8943</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3637.5730551469946</td>
      <td width="200">4157.454263648252</td>
      <td width="380">0.875</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">36755.70218184624</td>
      <td width="200">61259.185076350186</td>
      <td width="380">0.6</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">47.36480385452188</td>
      <td width="200">59.171500800994835</td>
      <td width="380">0.8005</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">359.9762012033217</td>
      <td width="200">492.2194821469418</td>
      <td width="380">0.7313</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4101.766076412872</td>
      <td width="200">5598.036788085419</td>
      <td width="380">0.7327</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">41148.84381885457</td>
      <td width="200">82603.30778003216</td>
      <td width="380">0.4982</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">43.01137240680826</td>
      <td width="200">42.656470672671034</td>
      <td width="380">1.0083</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">335.34837419322963</td>
      <td width="200">318.2666470659131</td>
      <td width="380">1.0537</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3823.7691470096274</td>
      <td width="200">3755.4113217018044</td>
      <td width="380">1.0182</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">38232.7889707885</td>
      <td width="200">58076.17342577506</td>
      <td width="380">0.6583</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">54.01974645006604</td>
      <td width="200">67.33601834231794</td>
      <td width="380">0.8022</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">461.2055069801849</td>
      <td width="200">623.6495398706913</td>
      <td width="380">0.7395</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4776.912597256597</td>
      <td width="200">6328.242028466933</td>
      <td width="380">0.7549</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">54310.49562218931</td>
      <td width="200">100496.50670912777</td>
      <td width="380">0.5404</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">34.10341304215223</td>
      <td width="200">32.259370296071054</td>
      <td width="380">1.0572</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">299.34381737785515</td>
      <td width="200">269.7190768694785</td>
      <td width="380">1.1098</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3391.2215582809313</td>
      <td width="200">2956.819399836412</td>
      <td width="380">1.1469</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">34179.583943745085</td>
      <td width="200">48861.12664397874</td>
      <td width="380">0.6995</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">40.90052702269646</td>
      <td width="200">47.91546872427045</td>
      <td width="380">0.8536</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">385.676695291904</td>
      <td width="200">539.6267487572259</td>
      <td width="380">0.7147</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4221.837935069806</td>
      <td width="200">5664.989969909904</td>
      <td width="380">0.7453</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">41810.99070155737</td>
      <td width="200">91648.87483085475</td>
      <td width="380">0.4562</td>
    </tr>
  </tbody>
</table>

#### 反序列化 / Repeated（packed）

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
      <td width="400">BM_Deserialize_Repeated_Double/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">29.21486222566337</td>
      <td width="200">31.78151210279956</td>
      <td width="380">0.9192</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Double/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">32.92321258721364</td>
      <td width="200">45.94270293764326</td>
      <td width="380">0.7166</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">108.5139737806763</td>
      <td width="200">154.61542139484706</td>
      <td width="380">0.7018</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1480.5877339571182</td>
      <td width="200">1110.3695824208282</td>
      <td width="380">1.3334</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Float/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">28.402950979553893</td>
      <td width="200">31.25815973499342</td>
      <td width="380">0.9087</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Float/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">31.06578895121879</td>
      <td width="200">41.717325181563396</td>
      <td width="380">0.7447</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">77.4910840900174</td>
      <td width="200">81.46040504552748</td>
      <td width="380">0.9513</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">782.5720019341118</td>
      <td width="200">426.4614237107417</td>
      <td width="380">1.835</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">65.47022797743142</td>
      <td width="200">76.91638136239226</td>
      <td width="380">0.8512</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">287.6332944614111</td>
      <td width="200">440.91834812659016</td>
      <td width="380">0.6524</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3043.2284659174065</td>
      <td width="200">4374.117781385676</td>
      <td width="380">0.6957</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">29738.47294167754</td>
      <td width="200">60876.46127701309</td>
      <td width="380">0.4885</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">78.58591066451815</td>
      <td width="200">99.7207963084604</td>
      <td width="380">0.7881</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">406.4860632230043</td>
      <td width="200">542.6933498965157</td>
      <td width="380">0.749</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4325.0200684072415</td>
      <td width="200">6101.161055584778</td>
      <td width="380">0.7089</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">43440.69920238313</td>
      <td width="200">73675.21018254521</td>
      <td width="380">0.5896</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">68.44954730121108</td>
      <td width="200">87.43718941268628</td>
      <td width="380">0.7828</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">285.36709829852873</td>
      <td width="200">454.2645430559215</td>
      <td width="380">0.6282</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3331.922849942975</td>
      <td width="200">5074.019743225438</td>
      <td width="380">0.6567</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">33897.704901341815</td>
      <td width="200">59311.7797521661</td>
      <td width="380">0.5715</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">82.07331826096572</td>
      <td width="200">105.86850691406894</td>
      <td width="380">0.7752</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">463.48054016414665</td>
      <td width="200">659.2122050684785</td>
      <td width="380">0.7031</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4624.050758238177</td>
      <td width="200">6826.097523925353</td>
      <td width="380">0.6774</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">46784.765275459504</td>
      <td width="200">80564.11170564446</td>
      <td width="380">0.5807</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">67.06851561950783</td>
      <td width="200">73.62943821660552</td>
      <td width="380">0.9109</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">296.1937308659166</td>
      <td width="200">446.8501471331143</td>
      <td width="380">0.6628</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3021.831229711933</td>
      <td width="200">4434.404812310036</td>
      <td width="380">0.6815</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">29828.506430472127</td>
      <td width="200">56290.132296458</td>
      <td width="380">0.5299</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">84.82924918584251</td>
      <td width="200">107.40269152796891</td>
      <td width="380">0.7898</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">436.6506731595321</td>
      <td width="200">580.6370254087655</td>
      <td width="380">0.752</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4384.641991511515</td>
      <td width="200">6034.698020785391</td>
      <td width="380">0.7266</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">44734.70910824944</td>
      <td width="200">73225.19473805603</td>
      <td width="380">0.6109</td>
    </tr>
  </tbody>
</table>

#### 序列化 / String 与 Bytes

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
      <td width="400">BM_Serialize_Bytes/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">12.440496169963929</td>
      <td width="200">10.781229311815487</td>
      <td width="380">1.1539</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Bytes/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">12.710947409489693</td>
      <td width="200">11.162652607597382</td>
      <td width="380">1.1387</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Bytes/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">19.89491206416238</td>
      <td width="200">21.44649580785351</td>
      <td width="380">0.9277</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Bytes/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">95.7889748628937</td>
      <td width="200">133.05594355219884</td>
      <td width="380">0.7199</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_ASCII/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">16.227340057262</td>
      <td width="200">13.476364888350298</td>
      <td width="380">1.2041</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_ASCII/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">18.391670297088606</td>
      <td width="200">19.77302141021845</td>
      <td width="380">0.9301</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_ASCII/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">74.71127395051695</td>
      <td width="200">88.5692388080281</td>
      <td width="380">0.8435</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_ASCII/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">650.5681723980758</td>
      <td width="200">684.8520932386626</td>
      <td width="380">0.9499</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_Chinese/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">17.580085655980497</td>
      <td width="200">17.948812157007655</td>
      <td width="380">0.9795</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_Chinese/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">29.63354728832159</td>
      <td width="200">30.72274123569304</td>
      <td width="380">0.9645</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_Chinese/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">177.63559581653342</td>
      <td width="200">195.2116944509343</td>
      <td width="380">0.91</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_Chinese/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1634.5509872662665</td>
      <td width="200">1851.691974142113</td>
      <td width="380">0.8827</td>
    </tr>
  </tbody>
</table>

#### 反序列化 / String 与 Bytes

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
      <td width="400">BM_Deserialize_Bytes/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">37.60346518575909</td>
      <td width="200">37.18249389664252</td>
      <td width="380">1.0113</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Bytes/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">47.348574675241956</td>
      <td width="200">50.28609231211514</td>
      <td width="380">0.9416</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Bytes/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">52.29119170246734</td>
      <td width="200">64.82757261053517</td>
      <td width="380">0.8066</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Bytes/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">226.70990294707332</td>
      <td width="200">244.44807906677693</td>
      <td width="380">0.9274</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_ASCII/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">43.818453955271636</td>
      <td width="200">40.57196319679358</td>
      <td width="380">1.08</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_ASCII/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">56.00874559336884</td>
      <td width="200">61.29999014297695</td>
      <td width="380">0.9137</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_ASCII/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">109.73513341283689</td>
      <td width="200">146.79871966436127</td>
      <td width="380">0.7475</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_ASCII/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">786.9414302342091</td>
      <td width="200">809.9850931183743</td>
      <td width="380">0.9716</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_Chinese/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">47.61525557757113</td>
      <td width="200">45.59140769751143</td>
      <td width="380">1.0444</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_Chinese/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">63.91623839040926</td>
      <td width="200">78.69427003666104</td>
      <td width="380">0.8122</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_Chinese/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">217.51746888528191</td>
      <td width="200">248.85152423955225</td>
      <td width="380">0.8741</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_Chinese/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1775.9148066904522</td>
      <td width="200">1966.1588337931253</td>
      <td width="380">0.9032</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
