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
      <td width="180">Acceleration</td>
      <td width="220">fbthrift</td>
      <td width="160">2026.10.26.00</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Acceleration</td>
      <td width="220">fbthrift</td>
      <td width="160">2026.10.26.00</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### fbthrift 2026.10.26.00

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
      <td width="600">2026.10.26.00</td>
      <td width="600">2026.10.26.00</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">2026.10.26.00</td>
      <td width="600">2026.10.26.00</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-19T14:02:40Z</td>
      <td width="600">2026-11-19T14:04:06Z</td>
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
      <td width="600">2026-11-19T13:52:28Z</td>
      <td width="600">2026-11-19T13:53:17Z</td>
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
      <td width="600">6.6.0-132.0.0.111.oe2403sp3.x86_64</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192620 MB<br>node 0 free: 77753 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 170982 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 170790 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 171838 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193481 MB<br>node 4 free: 171995 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193523 MB<br>node 5 free: 174007 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 172805 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 172815 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 351672 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 379531 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 242085 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 347750 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">ProtocolBench</td>
      <td width="880">2026.10.26.00 (c7fdfc9a80aa162c3934bf325c8e6ba56d15e845)</td>
    </tr>
    <tr>
      <td width="500">GoogleBenchmark</td>
      <td width="880">1.9.5</td>
    </tr>
    <tr>
      <td width="500">folly</td>
      <td width="880">2026.10.26.00</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### fbthrift 2026.10.26.00

##### Binary / write

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
      <td width="500">binary_write_complex_struct__ns_per_op</td>
      <td width="280">25850779.6534296</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_complex_struct__objects_per_second</td>
      <td width="280">38.68355281374776</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_complex_struct__peak_rss_mb</td>
      <td width="280">212.3515625</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_big_binary__ns_per_op</td>
      <td width="280">94.50655271785752</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_big_binary__objects_per_second</td>
      <td width="280">10581276.866435153</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_big_binary__peak_rss_mb</td>
      <td width="280">12.578125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### Binary / read

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
      <td width="500">binary_read_complex_struct__ns_per_op</td>
      <td width="280">82640746.73750001</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_complex_struct__objects_per_second</td>
      <td width="280">12.100568296852387</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_complex_struct__peak_rss_mb</td>
      <td width="280">370.25</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_big_binary__ns_per_op</td>
      <td width="280">38.25029531542952</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_big_binary__objects_per_second</td>
      <td width="280">26143589.003785208</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_big_binary__peak_rss_mb</td>
      <td width="280">12.6171875</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_large_map_int__ns_per_op</td>
      <td width="280">24639980.93869732</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_large_map_int__objects_per_second</td>
      <td width="280">40.58444698021218</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_large_map_int__peak_rss_mb</td>
      <td width="280">112.20703125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### Compact / write

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
      <td width="500">compact_write_complex_struct__ns_per_op</td>
      <td width="280">32946677.277227726</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_complex_struct__objects_per_second</td>
      <td width="280">30.35207440148102</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_complex_struct__peak_rss_mb</td>
      <td width="280">192.796875</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_big_binary__ns_per_op</td>
      <td width="280">79.44044906133985</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_big_binary__objects_per_second</td>
      <td width="280">12588045.659558788</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_big_binary__peak_rss_mb</td>
      <td width="280">12.61328125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### Compact / read

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
      <td width="500">compact_read_complex_struct__ns_per_op</td>
      <td width="280">101581235.95588237</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_complex_struct__objects_per_second</td>
      <td width="280">9.844337791226609</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_complex_struct__peak_rss_mb</td>
      <td width="280">351.015625</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_big_binary__ns_per_op</td>
      <td width="280">40.52366565268859</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_big_binary__objects_per_second</td>
      <td width="280">24676938.37400057</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_big_binary__peak_rss_mb</td>
      <td width="280">12.90234375</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_large_map_int__ns_per_op</td>
      <td width="280">36873402.25966851</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_large_map_int__objects_per_second</td>
      <td width="280">27.119819130272738</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_large_map_int__peak_rss_mb</td>
      <td width="280">112.203125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### fbthrift 2026.10.26.00

##### Binary / write

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
      <td width="500">binary_write_complex_struct__ns_per_op</td>
      <td width="280">40426403.62637363</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_complex_struct__objects_per_second</td>
      <td width="280">24.7363087066101</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_complex_struct__peak_rss_mb</td>
      <td width="280">212.30078125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_big_binary__ns_per_op</td>
      <td width="280">90.29743899367288</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_big_binary__objects_per_second</td>
      <td width="280">11074511.205905516</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_big_binary__peak_rss_mb</td>
      <td width="280">12.87890625</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### Binary / read

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
      <td width="500">binary_read_complex_struct__ns_per_op</td>
      <td width="280">92931754.32432431</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_complex_struct__objects_per_second</td>
      <td width="280">10.760584552295018</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_complex_struct__peak_rss_mb</td>
      <td width="280">370.23828125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_big_binary__ns_per_op</td>
      <td width="280">46.25901991763304</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_big_binary__objects_per_second</td>
      <td width="280">21617405.681758065</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_big_binary__peak_rss_mb</td>
      <td width="280">12.87109375</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_large_map_int__ns_per_op</td>
      <td width="280">32796915.44600939</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_large_map_int__objects_per_second</td>
      <td width="280">30.490672259902308</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_large_map_int__peak_rss_mb</td>
      <td width="280">112.07421875</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### Compact / write

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
      <td width="500">compact_write_complex_struct__ns_per_op</td>
      <td width="280">38279439.44751381</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_complex_struct__objects_per_second</td>
      <td width="280">26.12368452707184</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_complex_struct__peak_rss_mb</td>
      <td width="280">192.73046875</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_big_binary__ns_per_op</td>
      <td width="280">97.68306014107364</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_big_binary__objects_per_second</td>
      <td width="280">10237189.524527615</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_big_binary__peak_rss_mb</td>
      <td width="280">12.87890625</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### Compact / read

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
      <td width="500">compact_read_complex_struct__ns_per_op</td>
      <td width="280">109627793.90625</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_complex_struct__objects_per_second</td>
      <td width="280">9.121774363672467</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_complex_struct__peak_rss_mb</td>
      <td width="280">350.8125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_big_binary__ns_per_op</td>
      <td width="280">48.306603817904374</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_big_binary__objects_per_second</td>
      <td width="280">20701103.38887785</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_big_binary__peak_rss_mb</td>
      <td width="280">12.875</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_large_map_int__ns_per_op</td>
      <td width="280">43468901.98757764</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_large_map_int__objects_per_second</td>
      <td width="280">23.004951914492246</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_large_map_int__peak_rss_mb</td>
      <td width="280">111.9765625</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### fbthrift 2026.10.26.00

#### Binary / write

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
      <td width="400">binary_write_complex_struct__ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">25850779.6534296</td>
      <td width="200">40426403.62637363</td>
      <td width="380">0.6395</td>
    </tr>
    <tr>
      <td width="400">binary_write_complex_struct__objects_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">38.68355281374776</td>
      <td width="200">24.7363087066101</td>
      <td width="380">0.6395</td>
    </tr>
    <tr>
      <td width="400">binary_write_complex_struct__peak_rss_mb</td>
      <td width="200">越小越好</td>
      <td width="200">212.3515625</td>
      <td width="200">212.30078125</td>
      <td width="380">1.0002</td>
    </tr>
    <tr>
      <td width="400">binary_write_big_binary__ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">94.50655271785752</td>
      <td width="200">90.29743899367288</td>
      <td width="380">1.0466</td>
    </tr>
    <tr>
      <td width="400">binary_write_big_binary__objects_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">10581276.866435153</td>
      <td width="200">11074511.205905516</td>
      <td width="380">1.0466</td>
    </tr>
    <tr>
      <td width="400">binary_write_big_binary__peak_rss_mb</td>
      <td width="200">越小越好</td>
      <td width="200">12.578125</td>
      <td width="200">12.87890625</td>
      <td width="380">0.9766</td>
    </tr>
  </tbody>
</table>

#### Binary / read

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
      <td width="400">binary_read_complex_struct__ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">82640746.73750001</td>
      <td width="200">92931754.32432431</td>
      <td width="380">0.8893</td>
    </tr>
    <tr>
      <td width="400">binary_read_complex_struct__objects_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">12.100568296852387</td>
      <td width="200">10.760584552295018</td>
      <td width="380">0.8893</td>
    </tr>
    <tr>
      <td width="400">binary_read_complex_struct__peak_rss_mb</td>
      <td width="200">越小越好</td>
      <td width="200">370.25</td>
      <td width="200">370.23828125</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">binary_read_big_binary__ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">38.25029531542952</td>
      <td width="200">46.25901991763304</td>
      <td width="380">0.8269</td>
    </tr>
    <tr>
      <td width="400">binary_read_big_binary__objects_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">26143589.003785208</td>
      <td width="200">21617405.681758065</td>
      <td width="380">0.8269</td>
    </tr>
    <tr>
      <td width="400">binary_read_big_binary__peak_rss_mb</td>
      <td width="200">越小越好</td>
      <td width="200">12.6171875</td>
      <td width="200">12.87109375</td>
      <td width="380">0.9803</td>
    </tr>
    <tr>
      <td width="400">binary_read_large_map_int__ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">24639980.93869732</td>
      <td width="200">32796915.44600939</td>
      <td width="380">0.7513</td>
    </tr>
    <tr>
      <td width="400">binary_read_large_map_int__objects_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">40.58444698021218</td>
      <td width="200">30.490672259902308</td>
      <td width="380">0.7513</td>
    </tr>
    <tr>
      <td width="400">binary_read_large_map_int__peak_rss_mb</td>
      <td width="200">越小越好</td>
      <td width="200">112.20703125</td>
      <td width="200">112.07421875</td>
      <td width="380">1.0012</td>
    </tr>
  </tbody>
</table>

#### Compact / write

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
      <td width="400">compact_write_complex_struct__ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">32946677.277227726</td>
      <td width="200">38279439.44751381</td>
      <td width="380">0.8607</td>
    </tr>
    <tr>
      <td width="400">compact_write_complex_struct__objects_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">30.35207440148102</td>
      <td width="200">26.12368452707184</td>
      <td width="380">0.8607</td>
    </tr>
    <tr>
      <td width="400">compact_write_complex_struct__peak_rss_mb</td>
      <td width="200">越小越好</td>
      <td width="200">192.796875</td>
      <td width="200">192.73046875</td>
      <td width="380">1.0003</td>
    </tr>
    <tr>
      <td width="400">compact_write_big_binary__ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">79.44044906133985</td>
      <td width="200">97.68306014107364</td>
      <td width="380">0.8132</td>
    </tr>
    <tr>
      <td width="400">compact_write_big_binary__objects_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">12588045.659558788</td>
      <td width="200">10237189.524527615</td>
      <td width="380">0.8132</td>
    </tr>
    <tr>
      <td width="400">compact_write_big_binary__peak_rss_mb</td>
      <td width="200">越小越好</td>
      <td width="200">12.61328125</td>
      <td width="200">12.87890625</td>
      <td width="380">0.9794</td>
    </tr>
  </tbody>
</table>

#### Compact / read

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
      <td width="400">compact_read_complex_struct__ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">101581235.95588237</td>
      <td width="200">109627793.90625</td>
      <td width="380">0.9266</td>
    </tr>
    <tr>
      <td width="400">compact_read_complex_struct__objects_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">9.844337791226609</td>
      <td width="200">9.121774363672467</td>
      <td width="380">0.9266</td>
    </tr>
    <tr>
      <td width="400">compact_read_complex_struct__peak_rss_mb</td>
      <td width="200">越小越好</td>
      <td width="200">351.015625</td>
      <td width="200">350.8125</td>
      <td width="380">1.0006</td>
    </tr>
    <tr>
      <td width="400">compact_read_big_binary__ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">40.52366565268859</td>
      <td width="200">48.306603817904374</td>
      <td width="380">0.8389</td>
    </tr>
    <tr>
      <td width="400">compact_read_big_binary__objects_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">24676938.37400057</td>
      <td width="200">20701103.38887785</td>
      <td width="380">0.8389</td>
    </tr>
    <tr>
      <td width="400">compact_read_big_binary__peak_rss_mb</td>
      <td width="200">越小越好</td>
      <td width="200">12.90234375</td>
      <td width="200">12.875</td>
      <td width="380">1.0021</td>
    </tr>
    <tr>
      <td width="400">compact_read_large_map_int__ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">36873402.25966851</td>
      <td width="200">43468901.98757764</td>
      <td width="380">0.8483</td>
    </tr>
    <tr>
      <td width="400">compact_read_large_map_int__objects_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">27.119819130272738</td>
      <td width="200">23.004951914492246</td>
      <td width="380">0.8483</td>
    </tr>
    <tr>
      <td width="400">compact_read_large_map_int__peak_rss_mb</td>
      <td width="200">越小越好</td>
      <td width="200">112.203125</td>
      <td width="200">111.9765625</td>
      <td width="380">1.002</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
