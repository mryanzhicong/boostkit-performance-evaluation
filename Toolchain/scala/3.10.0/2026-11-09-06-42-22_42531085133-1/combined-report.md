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
      <td width="180">Toolchain</td>
      <td width="220">scala</td>
      <td width="160">3.10.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">scala</td>
      <td width="160">3.10.0</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### scala 3.10.0

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
      <td width="600">3.10.0</td>
      <td width="600">3.10.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">3.10.0</td>
      <td width="600">3.10.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-08T22:38:55Z</td>
      <td width="600">2026-11-08T22:39:09Z</td>
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
      <td width="600">2026-11-08T22:37:03Z</td>
      <td width="600">2026-11-08T22:37:01Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 61951 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 140372 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 167791 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 166200 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 134328 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 159693 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169172 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 163420 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 365402 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 378510 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 343153 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 350710 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">scala</td>
      <td width="880">3.10.0</td>
    </tr>
    <tr>
      <td width="500">openjdk</td>
      <td width="880">java-21-openjdk-21.0.12.8-4.oe2403sp4 (openEuler 24.03 LTS SP4)</td>
    </tr>
    <tr>
      <td width="500">container_image</td>
      <td width="880">openEuler 24.03 LTS SP4</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### scala 3.10.0

##### compile_20

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
      <td width="500">compile_20__wall_seconds</td>
      <td width="280">1.967615</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_20__peak_rss_mib</td>
      <td width="280">300.836</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_20__classes_per_second</td>
      <td width="280">10.16459</td>
      <td width="200">classes/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### compile_100

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
      <td width="500">compile_100__wall_seconds</td>
      <td width="280">2.668658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_100__peak_rss_mib</td>
      <td width="280">374.875</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_100__classes_per_second</td>
      <td width="280">37.472018</td>
      <td width="200">classes/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### compile_300

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
      <td width="500">compile_300__wall_seconds</td>
      <td width="280">3.771567</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_300__peak_rss_mib</td>
      <td width="280">502.477</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_300__classes_per_second</td>
      <td width="280">79.542535</td>
      <td width="200">classes/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### run_arith

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
      <td width="500">run_arith__wall_seconds</td>
      <td width="280">0.264188</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">run_arith__peak_rss_mib</td>
      <td width="280">53.969</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### run_collections

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
      <td width="500">run_collections__wall_seconds</td>
      <td width="280">0.564761</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">run_collections__peak_rss_mib</td>
      <td width="280">159.008</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### run_strings

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
      <td width="500">run_strings__wall_seconds</td>
      <td width="280">1.166028</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">run_strings__peak_rss_mib</td>
      <td width="280">739.148</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### pipeline_compile_and_run

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
      <td width="500">pipeline_compile_and_run__wall_seconds</td>
      <td width="280">2.769026</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pipeline_compile_and_run__peak_rss_mib</td>
      <td width="280">384.398</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### scala 3.10.0

##### compile_20

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
      <td width="500">compile_20__wall_seconds</td>
      <td width="280">2.828876</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_20__peak_rss_mib</td>
      <td width="280">291.164</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_20__classes_per_second</td>
      <td width="280">7.069946</td>
      <td width="200">classes/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### compile_100

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
      <td width="500">compile_100__wall_seconds</td>
      <td width="280">3.732461</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_100__peak_rss_mib</td>
      <td width="280">400.223</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_100__classes_per_second</td>
      <td width="280">26.791975</td>
      <td width="200">classes/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### compile_300

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
      <td width="500">compile_300__wall_seconds</td>
      <td width="280">5.645447</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_300__peak_rss_mib</td>
      <td width="280">477.355</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile_300__classes_per_second</td>
      <td width="280">53.140168</td>
      <td width="200">classes/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### run_arith

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
      <td width="500">run_arith__wall_seconds</td>
      <td width="280">0.416239</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">run_arith__peak_rss_mib</td>
      <td width="280">72.137</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### run_collections

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
      <td width="500">run_collections__wall_seconds</td>
      <td width="280">0.768307</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">run_collections__peak_rss_mib</td>
      <td width="280">163.945</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### run_strings

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
      <td width="500">run_strings__wall_seconds</td>
      <td width="280">1.571967</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">run_strings__peak_rss_mib</td>
      <td width="280">726.68</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### pipeline_compile_and_run

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
      <td width="500">pipeline_compile_and_run__wall_seconds</td>
      <td width="280">3.937194</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pipeline_compile_and_run__peak_rss_mib</td>
      <td width="280">410.5</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### scala 3.10.0

#### compile_20

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
      <td width="400">compile_20__wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">1.967615</td>
      <td width="200">2.828876</td>
      <td width="380">0.6955</td>
    </tr>
    <tr>
      <td width="400">compile_20__peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">300.836</td>
      <td width="200">291.164</td>
      <td width="380">1.0332</td>
    </tr>
    <tr>
      <td width="400">compile_20__classes_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">10.16459</td>
      <td width="200">7.069946</td>
      <td width="380">0.6955</td>
    </tr>
  </tbody>
</table>

#### compile_100

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
      <td width="400">compile_100__wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">2.668658</td>
      <td width="200">3.732461</td>
      <td width="380">0.715</td>
    </tr>
    <tr>
      <td width="400">compile_100__peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">374.875</td>
      <td width="200">400.223</td>
      <td width="380">0.9367</td>
    </tr>
    <tr>
      <td width="400">compile_100__classes_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">37.472018</td>
      <td width="200">26.791975</td>
      <td width="380">0.715</td>
    </tr>
  </tbody>
</table>

#### compile_300

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
      <td width="400">compile_300__wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">3.771567</td>
      <td width="200">5.645447</td>
      <td width="380">0.6681</td>
    </tr>
    <tr>
      <td width="400">compile_300__peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">502.477</td>
      <td width="200">477.355</td>
      <td width="380">1.0526</td>
    </tr>
    <tr>
      <td width="400">compile_300__classes_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">79.542535</td>
      <td width="200">53.140168</td>
      <td width="380">0.6681</td>
    </tr>
  </tbody>
</table>

#### run_arith

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
      <td width="400">run_arith__wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.264188</td>
      <td width="200">0.416239</td>
      <td width="380">0.6347</td>
    </tr>
    <tr>
      <td width="400">run_arith__peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">53.969</td>
      <td width="200">72.137</td>
      <td width="380">0.7481</td>
    </tr>
  </tbody>
</table>

#### run_collections

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
      <td width="400">run_collections__wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">0.564761</td>
      <td width="200">0.768307</td>
      <td width="380">0.7351</td>
    </tr>
    <tr>
      <td width="400">run_collections__peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">159.008</td>
      <td width="200">163.945</td>
      <td width="380">0.9699</td>
    </tr>
  </tbody>
</table>

#### run_strings

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
      <td width="400">run_strings__wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">1.166028</td>
      <td width="200">1.571967</td>
      <td width="380">0.7418</td>
    </tr>
    <tr>
      <td width="400">run_strings__peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">739.148</td>
      <td width="200">726.68</td>
      <td width="380">1.0172</td>
    </tr>
  </tbody>
</table>

#### pipeline_compile_and_run

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
      <td width="400">pipeline_compile_and_run__wall_seconds</td>
      <td width="200">越小越好</td>
      <td width="200">2.769026</td>
      <td width="200">3.937194</td>
      <td width="380">0.7033</td>
    </tr>
    <tr>
      <td width="400">pipeline_compile_and_run__peak_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">384.398</td>
      <td width="200">410.5</td>
      <td width="380">0.9364</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
