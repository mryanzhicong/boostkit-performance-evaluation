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
      <td width="220">flatbuffers</td>
      <td width="160">25.12.19</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">flatbuffers</td>
      <td width="160">25.12.19</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### flatbuffers 25.12.19

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
      <td width="600">25.12.19</td>
      <td width="600">25.12.19</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">25.12.19</td>
      <td width="600">25.12.19</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-08T18:54:58Z</td>
      <td width="600">2026-11-08T18:55:25Z</td>
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
      <td width="600">2026-11-08T18:53:48Z</td>
      <td width="600">2026-11-08T18:53:47Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 62009 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 140529 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 167993 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 166174 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 134635 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 159725 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169296 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 163747 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 365947 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 378802 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 344177 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 351117 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">flatbuffers</td>
      <td width="880">25.12.19</td>
    </tr>
    <tr>
      <td width="500">system_cmake</td>
      <td width="880">unpinned Runner cmake; the exact cmake version is recorded per run in build_info.json</td>
    </tr>
    <tr>
      <td width="500">system_c_compiler</td>
      <td width="880">unpinned Runner cc/c++; the exact compiler string is recorded per run in build_info.json and results.json</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### flatbuffers 25.12.19

##### accessor_1k

###### builder_accessor

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
      <td width="500">accessor_1k</td>
      <td width="280">0.063761</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">accessor_1k_rss</td>
      <td width="280">12.562</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">accessor_1k_mbs</td>
      <td width="280">6018.703359763414</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">accessor_1k_elem_s</td>
      <td width="280">1568356832.546541</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### builder_1k

###### builder_accessor

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
      <td width="500">builder_1k</td>
      <td width="280">0.015576</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_1k_rss</td>
      <td width="280">12.594</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_1k_mbs</td>
      <td width="280">24637.811050454224</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">builder_1k_elem_s</td>
      <td width="280">6420133538.777607</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### builder_accessor_100k

###### builder_accessor

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
      <td width="500">builder_accessor_100k</td>
      <td width="280">0.063868</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_100k_rss</td>
      <td width="280">12.473</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_100k_mbs</td>
      <td width="280">5973.141710184972</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_100k_elem_s</td>
      <td width="280">1565729316.7157264</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### builder_accessor_10k

###### builder_accessor

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
      <td width="500">builder_accessor_10k</td>
      <td width="280">0.063806</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_10k_rss</td>
      <td width="280">12.598</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_10k_mbs</td>
      <td width="280">5982.174221835525</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_10k_elem_s</td>
      <td width="280">1567250728.7715888</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### builder_accessor_1k

###### builder_accessor

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
      <td width="500">builder_accessor_1k</td>
      <td width="280">0.063752</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1k_rss</td>
      <td width="280">12.484</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1k_mbs</td>
      <td width="280">6019.553032404865</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1k_elem_s</td>
      <td width="280">1568578240.682645</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### builder_accessor_1m

###### builder_accessor

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
      <td width="500">builder_accessor_1m</td>
      <td width="280">0.063803</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1m_rss</td>
      <td width="280">13.992</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1m_mbs</td>
      <td width="280">5978.90405436828</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1m_elem_s</td>
      <td width="280">1567324420.4817955</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### upstream_bench_encode_use

###### upstream_benchmark

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
      <td width="500">upstream_bench_encode_use</td>
      <td width="280">0.03167</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">upstream_bench_encode_use_rss</td>
      <td width="280">12.602</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">upstream_bench_encode_use_mbs</td>
      <td width="280">1035.8824276720873</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">upstream_bench_encode_use_iter_s</td>
      <td width="280">3157562.361856647</td>
      <td width="200">iter/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### flatbuffers 25.12.19

##### accessor_1k

###### builder_accessor

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
      <td width="500">accessor_1k</td>
      <td width="280">0.064506</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">accessor_1k_rss</td>
      <td width="280">11.754</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">accessor_1k_mbs</td>
      <td width="280">5949.191469349751</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">accessor_1k_elem_s</td>
      <td width="280">1550243388.2119493</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### builder_1k

###### builder_accessor

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
      <td width="500">builder_1k</td>
      <td width="280">0.016306</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_1k_rss</td>
      <td width="280">11.75</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_1k_mbs</td>
      <td width="280">23534.805894877652</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">builder_1k_elem_s</td>
      <td width="280">6132711885.195633</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### builder_accessor_100k

###### builder_accessor

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
      <td width="500">builder_accessor_100k</td>
      <td width="280">0.064635</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_100k_rss</td>
      <td width="280">11.762</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_100k_mbs</td>
      <td width="280">5902.260613384293</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_100k_elem_s</td>
      <td width="280">1547149377.2723756</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### builder_accessor_10k

###### builder_accessor

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
      <td width="500">builder_accessor_10k</td>
      <td width="280">0.064716</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_10k_rss</td>
      <td width="280">11.762</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_10k_mbs</td>
      <td width="280">5898.056251907373</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_10k_elem_s</td>
      <td width="280">1545212930.3418012</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### builder_accessor_1k

###### builder_accessor

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
      <td width="500">builder_accessor_1k</td>
      <td width="280">0.064578</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1k_rss</td>
      <td width="280">11.754</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1k_mbs</td>
      <td width="280">5942.558532656246</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1k_elem_s</td>
      <td width="280">1548514974.1398</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### builder_accessor_1m

###### builder_accessor

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
      <td width="500">builder_accessor_1m</td>
      <td width="280">0.114767</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1m_rss</td>
      <td width="280">14.465</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1m_mbs</td>
      <td width="280">3323.882434679476</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">builder_accessor_1m_elem_s</td>
      <td width="280">871330608.9729626</td>
      <td width="200">elem/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### upstream_bench_encode_use

###### upstream_benchmark

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
      <td width="500">upstream_bench_encode_use</td>
      <td width="280">0.064529</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">upstream_bench_encode_use_rss</td>
      <td width="280">11.758</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">upstream_bench_encode_use_mbs</td>
      <td width="280">508.39772016264004</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">upstream_bench_encode_use_iter_s</td>
      <td width="280">1549690.8366780826</td>
      <td width="200">iter/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### flatbuffers 25.12.19

#### accessor_1k

##### builder_accessor

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
      <td width="400">accessor_1k</td>
      <td width="200">越小越好</td>
      <td width="200">0.063761</td>
      <td width="200">0.064506</td>
      <td width="380">0.9885</td>
    </tr>
    <tr>
      <td width="400">accessor_1k_rss</td>
      <td width="200">越小越好</td>
      <td width="200">12.562</td>
      <td width="200">11.754</td>
      <td width="380">1.0687</td>
    </tr>
    <tr>
      <td width="400">accessor_1k_mbs</td>
      <td width="200">越大越好</td>
      <td width="200">6018.703359763414</td>
      <td width="200">5949.191469349751</td>
      <td width="380">0.9885</td>
    </tr>
    <tr>
      <td width="400">accessor_1k_elem_s</td>
      <td width="200">越大越好</td>
      <td width="200">1568356832.546541</td>
      <td width="200">1550243388.2119493</td>
      <td width="380">0.9885</td>
    </tr>
  </tbody>
</table>

#### builder_1k

##### builder_accessor

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
      <td width="400">builder_1k</td>
      <td width="200">越小越好</td>
      <td width="200">0.015576</td>
      <td width="200">0.016306</td>
      <td width="380">0.9552</td>
    </tr>
    <tr>
      <td width="400">builder_1k_rss</td>
      <td width="200">越小越好</td>
      <td width="200">12.594</td>
      <td width="200">11.75</td>
      <td width="380">1.0718</td>
    </tr>
    <tr>
      <td width="400">builder_1k_mbs</td>
      <td width="200">越大越好</td>
      <td width="200">24637.811050454224</td>
      <td width="200">23534.805894877652</td>
      <td width="380">0.9552</td>
    </tr>
    <tr>
      <td width="400">builder_1k_elem_s</td>
      <td width="200">越大越好</td>
      <td width="200">6420133538.777607</td>
      <td width="200">6132711885.195633</td>
      <td width="380">0.9552</td>
    </tr>
  </tbody>
</table>

#### builder_accessor_100k

##### builder_accessor

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
      <td width="400">builder_accessor_100k</td>
      <td width="200">越小越好</td>
      <td width="200">0.063868</td>
      <td width="200">0.064635</td>
      <td width="380">0.9881</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_100k_rss</td>
      <td width="200">越小越好</td>
      <td width="200">12.473</td>
      <td width="200">11.762</td>
      <td width="380">1.0604</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_100k_mbs</td>
      <td width="200">越大越好</td>
      <td width="200">5973.141710184972</td>
      <td width="200">5902.260613384293</td>
      <td width="380">0.9881</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_100k_elem_s</td>
      <td width="200">越大越好</td>
      <td width="200">1565729316.7157264</td>
      <td width="200">1547149377.2723756</td>
      <td width="380">0.9881</td>
    </tr>
  </tbody>
</table>

#### builder_accessor_10k

##### builder_accessor

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
      <td width="400">builder_accessor_10k</td>
      <td width="200">越小越好</td>
      <td width="200">0.063806</td>
      <td width="200">0.064716</td>
      <td width="380">0.9859</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_10k_rss</td>
      <td width="200">越小越好</td>
      <td width="200">12.598</td>
      <td width="200">11.762</td>
      <td width="380">1.0711</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_10k_mbs</td>
      <td width="200">越大越好</td>
      <td width="200">5982.174221835525</td>
      <td width="200">5898.056251907373</td>
      <td width="380">0.9859</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_10k_elem_s</td>
      <td width="200">越大越好</td>
      <td width="200">1567250728.7715888</td>
      <td width="200">1545212930.3418012</td>
      <td width="380">0.9859</td>
    </tr>
  </tbody>
</table>

#### builder_accessor_1k

##### builder_accessor

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
      <td width="400">builder_accessor_1k</td>
      <td width="200">越小越好</td>
      <td width="200">0.063752</td>
      <td width="200">0.064578</td>
      <td width="380">0.9872</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_1k_rss</td>
      <td width="200">越小越好</td>
      <td width="200">12.484</td>
      <td width="200">11.754</td>
      <td width="380">1.0621</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_1k_mbs</td>
      <td width="200">越大越好</td>
      <td width="200">6019.553032404865</td>
      <td width="200">5942.558532656246</td>
      <td width="380">0.9872</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_1k_elem_s</td>
      <td width="200">越大越好</td>
      <td width="200">1568578240.682645</td>
      <td width="200">1548514974.1398</td>
      <td width="380">0.9872</td>
    </tr>
  </tbody>
</table>

#### builder_accessor_1m

##### builder_accessor

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
      <td width="400">builder_accessor_1m</td>
      <td width="200">越小越好</td>
      <td width="200">0.063803</td>
      <td width="200">0.114767</td>
      <td width="380">0.5559</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_1m_rss</td>
      <td width="200">越小越好</td>
      <td width="200">13.992</td>
      <td width="200">14.465</td>
      <td width="380">0.9673</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_1m_mbs</td>
      <td width="200">越大越好</td>
      <td width="200">5978.90405436828</td>
      <td width="200">3323.882434679476</td>
      <td width="380">0.5559</td>
    </tr>
    <tr>
      <td width="400">builder_accessor_1m_elem_s</td>
      <td width="200">越大越好</td>
      <td width="200">1567324420.4817955</td>
      <td width="200">871330608.9729626</td>
      <td width="380">0.5559</td>
    </tr>
  </tbody>
</table>

#### upstream_bench_encode_use

##### upstream_benchmark

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
      <td width="400">upstream_bench_encode_use</td>
      <td width="200">越小越好</td>
      <td width="200">0.03167</td>
      <td width="200">0.064529</td>
      <td width="380">0.4908</td>
    </tr>
    <tr>
      <td width="400">upstream_bench_encode_use_rss</td>
      <td width="200">越小越好</td>
      <td width="200">12.602</td>
      <td width="200">11.758</td>
      <td width="380">1.0718</td>
    </tr>
    <tr>
      <td width="400">upstream_bench_encode_use_mbs</td>
      <td width="200">越大越好</td>
      <td width="200">1035.8824276720873</td>
      <td width="200">508.39772016264004</td>
      <td width="380">0.4908</td>
    </tr>
    <tr>
      <td width="400">upstream_bench_encode_use_iter_s</td>
      <td width="200">越大越好</td>
      <td width="200">3157562.361856647</td>
      <td width="200">1549690.8366780826</td>
      <td width="380">0.4908</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
