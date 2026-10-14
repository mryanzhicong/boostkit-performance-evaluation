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
      <td width="180">Database</td>
      <td width="220">oceanbase</td>
      <td width="160">4.2.5.6</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Database</td>
      <td width="220">oceanbase</td>
      <td width="160">4.2.5.6</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### oceanbase 4.2.5.6

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
      <td width="600">4.2.5.6</td>
      <td width="600">4.2.5.6</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">4.2.5.6</td>
      <td width="600">4.2.5.6</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-10-14T06:17:29Z</td>
      <td width="600">2026-10-14T06:18:03Z</td>
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
      <td width="600">2026-10-14T06:14:35Z</td>
      <td width="600">2026-10-14T06:14:58Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 0 size: 192588 MB<br>node 0 free: 137118 MB<br>node 1 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 1 size: 193511 MB<br>node 1 free: 159420 MB<br>node 2 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 2 size: 193469 MB<br>node 2 free: 119801 MB<br>node 3 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 193443 MB<br>node 3 free: 111734 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  32  32 <br>  1:  12  10  32  32 <br>  2:  32  32  10  12 <br>  3:  32  32  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 574945 MB<br>node 0 free: 332382 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 580594 MB<br>node 1 free: 364073 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 580594 MB<br>node 2 free: 369181 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 482782 MB<br>node 3 free: 380298 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">sysbench</td>
      <td width="880">1.0.20</td>
    </tr>
    <tr>
      <td width="500">obproxy</td>
      <td width="880">4.3.6.1</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### oceanbase 4.2.5.6

##### read_only

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
      <td width="500">read_only :: threads=1 :: tps</td>
      <td width="280">652.78</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=1 :: qps</td>
      <td width="280">10444.43</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=1 :: avg_latency_ms</td>
      <td width="280">1.53</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=1 :: p95_latency_ms</td>
      <td width="280">1.67</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: tps</td>
      <td width="280">27893.97</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: qps</td>
      <td width="280">446303.45</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: avg_latency_ms</td>
      <td width="280">2.29</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: p95_latency_ms</td>
      <td width="280">2.52</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: tps</td>
      <td width="280">40882.3</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: qps</td>
      <td width="280">654116.75</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: avg_latency_ms</td>
      <td width="280">6.26</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: p95_latency_ms</td>
      <td width="280">8.28</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### insert

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
      <td width="500">insert :: threads=1 :: tps</td>
      <td width="280">3969.81</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=1 :: qps</td>
      <td width="280">3969.81</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=1 :: avg_latency_ms</td>
      <td width="280">0.25</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=1 :: p95_latency_ms</td>
      <td width="280">0.38</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: tps</td>
      <td width="280">112568.92</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: qps</td>
      <td width="280">112568.92</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: avg_latency_ms</td>
      <td width="280">0.57</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: p95_latency_ms</td>
      <td width="280">1.08</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: tps</td>
      <td width="280">157184.43</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: qps</td>
      <td width="280">157184.43</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: avg_latency_ms</td>
      <td width="280">1.62</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: p95_latency_ms</td>
      <td width="280">2.18</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### read_write

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
      <td width="500">read_write :: threads=1 :: tps</td>
      <td width="280">313.82</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=1 :: qps</td>
      <td width="280">6276.34</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=1 :: avg_latency_ms</td>
      <td width="280">3.19</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=1 :: p95_latency_ms</td>
      <td width="280">4.25</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: tps</td>
      <td width="280">16104.23</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: qps</td>
      <td width="280">322084.69</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: avg_latency_ms</td>
      <td width="280">3.97</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: p95_latency_ms</td>
      <td width="280">4.82</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: tps</td>
      <td width="280">27446.92</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: qps</td>
      <td width="280">548938.31</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: avg_latency_ms</td>
      <td width="280">9.32</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: p95_latency_ms</td>
      <td width="280">12.08</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### write_only

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
      <td width="500">write_only :: threads=1 :: tps</td>
      <td width="280">961.66</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=1 :: qps</td>
      <td width="280">5769.95</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=1 :: avg_latency_ms</td>
      <td width="280">1.04</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=1 :: p95_latency_ms</td>
      <td width="280">1.34</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: tps</td>
      <td width="280">52968.4</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: qps</td>
      <td width="280">317810.43</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: avg_latency_ms</td>
      <td width="280">1.21</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: p95_latency_ms</td>
      <td width="280">1.5</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: tps</td>
      <td width="280">91928.36</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: qps</td>
      <td width="280">551570.15</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: avg_latency_ms</td>
      <td width="280">2.78</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: p95_latency_ms</td>
      <td width="280">4.03</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### oceanbase 4.2.5.6

##### read_only

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
      <td width="500">read_only :: threads=1 :: tps</td>
      <td width="280">556.65</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=1 :: qps</td>
      <td width="280">8906.44</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=1 :: avg_latency_ms</td>
      <td width="280">1.8</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=1 :: p95_latency_ms</td>
      <td width="280">2.35</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: tps</td>
      <td width="280">22615.12</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: qps</td>
      <td width="280">361841.92</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: avg_latency_ms</td>
      <td width="280">2.83</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: p95_latency_ms</td>
      <td width="280">3.25</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: tps</td>
      <td width="280">34412.38</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: qps</td>
      <td width="280">550598.0</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: avg_latency_ms</td>
      <td width="280">7.44</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: p95_latency_ms</td>
      <td width="280">9.06</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### insert

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
      <td width="500">insert :: threads=1 :: tps</td>
      <td width="280">3330.88</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=1 :: qps</td>
      <td width="280">3330.88</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=1 :: avg_latency_ms</td>
      <td width="280">0.3</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=1 :: p95_latency_ms</td>
      <td width="280">0.37</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: tps</td>
      <td width="280">113029.24</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: qps</td>
      <td width="280">113029.24</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: avg_latency_ms</td>
      <td width="280">0.56</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: p95_latency_ms</td>
      <td width="280">0.69</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: tps</td>
      <td width="280">69764.09</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: qps</td>
      <td width="280">69764.09</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: avg_latency_ms</td>
      <td width="280">3.66</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: p95_latency_ms</td>
      <td width="280">6.79</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### read_write

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
      <td width="500">read_write :: threads=1 :: tps</td>
      <td width="280">304.44</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=1 :: qps</td>
      <td width="280">6088.79</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=1 :: avg_latency_ms</td>
      <td width="280">3.28</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=1 :: p95_latency_ms</td>
      <td width="280">3.62</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: tps</td>
      <td width="280">13623.69</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: qps</td>
      <td width="280">272473.77</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: avg_latency_ms</td>
      <td width="280">4.7</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: p95_latency_ms</td>
      <td width="280">5.47</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: tps</td>
      <td width="280">21909.46</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: qps</td>
      <td width="280">438189.19</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: avg_latency_ms</td>
      <td width="280">11.68</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: p95_latency_ms</td>
      <td width="280">13.46</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### write_only

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
      <td width="500">write_only :: threads=1 :: tps</td>
      <td width="280">814.25</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=1 :: qps</td>
      <td width="280">4885.5</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=1 :: avg_latency_ms</td>
      <td width="280">1.23</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=1 :: p95_latency_ms</td>
      <td width="280">1.42</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: tps</td>
      <td width="280">38402.6</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: qps</td>
      <td width="280">230415.63</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: avg_latency_ms</td>
      <td width="280">1.67</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: p95_latency_ms</td>
      <td width="280">1.96</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: tps</td>
      <td width="280">72502.05</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: qps</td>
      <td width="280">435012.28</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: avg_latency_ms</td>
      <td width="280">3.53</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: p95_latency_ms</td>
      <td width="280">4.25</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### oceanbase 4.2.5.6

#### read_only

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
      <td width="400">read_only :: threads=1 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">652.78</td>
      <td width="200">556.65</td>
      <td width="380">0.8527</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=1 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">10444.43</td>
      <td width="200">8906.44</td>
      <td width="380">0.8527</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=1 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">1.53</td>
      <td width="200">1.8</td>
      <td width="380">0.85</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=1 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">1.67</td>
      <td width="200">2.35</td>
      <td width="380">0.7106</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=64 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">27893.97</td>
      <td width="200">22615.12</td>
      <td width="380">0.8108</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=64 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">446303.45</td>
      <td width="200">361841.92</td>
      <td width="380">0.8108</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=64 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">2.29</td>
      <td width="200">2.83</td>
      <td width="380">0.8092</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=64 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">2.52</td>
      <td width="200">3.25</td>
      <td width="380">0.7754</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=256 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">40882.3</td>
      <td width="200">34412.38</td>
      <td width="380">0.8417</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=256 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">654116.75</td>
      <td width="200">550598.0</td>
      <td width="380">0.8417</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=256 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">6.26</td>
      <td width="200">7.44</td>
      <td width="380">0.8414</td>
    </tr>
    <tr>
      <td width="400">read_only :: threads=256 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">8.28</td>
      <td width="200">9.06</td>
      <td width="380">0.9139</td>
    </tr>
  </tbody>
</table>

#### insert

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
      <td width="400">insert :: threads=1 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">3969.81</td>
      <td width="200">3330.88</td>
      <td width="380">0.8391</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=1 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">3969.81</td>
      <td width="200">3330.88</td>
      <td width="380">0.8391</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=1 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">0.25</td>
      <td width="200">0.3</td>
      <td width="380">0.8333</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=1 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">0.38</td>
      <td width="200">0.37</td>
      <td width="380">1.027</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=64 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">112568.92</td>
      <td width="200">113029.24</td>
      <td width="380">1.0041</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=64 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">112568.92</td>
      <td width="200">113029.24</td>
      <td width="380">1.0041</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=64 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">0.57</td>
      <td width="200">0.56</td>
      <td width="380">1.0179</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=64 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">1.08</td>
      <td width="200">0.69</td>
      <td width="380">1.5652</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=256 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">157184.43</td>
      <td width="200">69764.09</td>
      <td width="380">0.4438</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=256 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">157184.43</td>
      <td width="200">69764.09</td>
      <td width="380">0.4438</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=256 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">1.62</td>
      <td width="200">3.66</td>
      <td width="380">0.4426</td>
    </tr>
    <tr>
      <td width="400">insert :: threads=256 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">2.18</td>
      <td width="200">6.79</td>
      <td width="380">0.3211</td>
    </tr>
  </tbody>
</table>

#### read_write

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
      <td width="400">read_write :: threads=1 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">313.82</td>
      <td width="200">304.44</td>
      <td width="380">0.9701</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=1 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">6276.34</td>
      <td width="200">6088.79</td>
      <td width="380">0.9701</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=1 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">3.19</td>
      <td width="200">3.28</td>
      <td width="380">0.9726</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=1 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">4.25</td>
      <td width="200">3.62</td>
      <td width="380">1.174</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=64 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">16104.23</td>
      <td width="200">13623.69</td>
      <td width="380">0.846</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=64 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">322084.69</td>
      <td width="200">272473.77</td>
      <td width="380">0.846</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=64 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">3.97</td>
      <td width="200">4.7</td>
      <td width="380">0.8447</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=64 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">4.82</td>
      <td width="200">5.47</td>
      <td width="380">0.8812</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=256 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">27446.92</td>
      <td width="200">21909.46</td>
      <td width="380">0.7982</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=256 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">548938.31</td>
      <td width="200">438189.19</td>
      <td width="380">0.7982</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=256 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">9.32</td>
      <td width="200">11.68</td>
      <td width="380">0.7979</td>
    </tr>
    <tr>
      <td width="400">read_write :: threads=256 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">12.08</td>
      <td width="200">13.46</td>
      <td width="380">0.8975</td>
    </tr>
  </tbody>
</table>

#### write_only

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
      <td width="400">write_only :: threads=1 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">961.66</td>
      <td width="200">814.25</td>
      <td width="380">0.8467</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=1 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">5769.95</td>
      <td width="200">4885.5</td>
      <td width="380">0.8467</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=1 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">1.04</td>
      <td width="200">1.23</td>
      <td width="380">0.8455</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=1 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">1.34</td>
      <td width="200">1.42</td>
      <td width="380">0.9437</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=64 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">52968.4</td>
      <td width="200">38402.6</td>
      <td width="380">0.725</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=64 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">317810.43</td>
      <td width="200">230415.63</td>
      <td width="380">0.725</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=64 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">1.21</td>
      <td width="200">1.67</td>
      <td width="380">0.7246</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=64 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">1.5</td>
      <td width="200">1.96</td>
      <td width="380">0.7653</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=256 :: tps</td>
      <td width="200">越大越好</td>
      <td width="200">91928.36</td>
      <td width="200">72502.05</td>
      <td width="380">0.7887</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=256 :: qps</td>
      <td width="200">越大越好</td>
      <td width="200">551570.15</td>
      <td width="200">435012.28</td>
      <td width="380">0.7887</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=256 :: avg_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">2.78</td>
      <td width="200">3.53</td>
      <td width="380">0.7875</td>
    </tr>
    <tr>
      <td width="400">write_only :: threads=256 :: p95_latency_ms</td>
      <td width="200">越小越好</td>
      <td width="200">4.03</td>
      <td width="200">4.25</td>
      <td width="380">0.9482</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
