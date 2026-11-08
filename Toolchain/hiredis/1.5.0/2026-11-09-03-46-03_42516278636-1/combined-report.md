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
      <td width="220">hiredis</td>
      <td width="160">1.5.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">hiredis</td>
      <td width="160">1.5.0</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### hiredis 1.5.0

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
      <td width="600">1.5.0</td>
      <td width="600">1.5.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.5.0</td>
      <td width="600">1.5.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-08T19:42:23Z</td>
      <td width="600">2026-11-08T19:42:37Z</td>
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
      <td width="600">2026-11-08T19:41:51Z</td>
      <td width="600">2026-11-08T19:41:50Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 62010 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 140459 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 168019 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 166263 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 134625 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 159667 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169212 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 163545 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 365871 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 378697 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 344074 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 350941 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">hiredis_library</td>
      <td width="880">1.5.0 (static library built from the pinned source archive)</td>
    </tr>
    <tr>
      <td width="500">resp_bench</td>
      <td width="880">case-owned harness that only uses public hiredis APIs</td>
    </tr>
    <tr>
      <td width="500">upstream_local_tests</td>
      <td width="880">test.c from the pinned 1.5.0 source archive (server-free subset)</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### hiredis 1.5.0

##### resp_reader

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
      <td width="500">reader_pipeline_parse_mib_per_second</td>
      <td width="280">451.803696</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_pipeline_replies_per_second</td>
      <td width="280">20757418.750111</td>
      <td width="200">replies/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_pipeline_wall_s</td>
      <td width="280">0.616647</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_pipeline_rss_mib</td>
      <td width="280">4.086</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_bulk_parse_mib_per_second</td>
      <td width="280">19055.596067</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_bulk_replies_per_second</td>
      <td width="280">76219.185984</td>
      <td width="200">replies/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_bulk_wall_s</td>
      <td width="280">0.214959</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_bulk_rss_mib</td>
      <td width="280">18.465</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_nested_parse_mib_per_second</td>
      <td width="280">195.568259</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_nested_replies_per_second</td>
      <td width="280">5592723.86625</td>
      <td width="200">replies/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_nested_wall_s</td>
      <td width="280">0.286086</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_nested_rss_mib</td>
      <td width="280">3.664</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_mixed_parse_mib_per_second</td>
      <td width="280">166.053216</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_mixed_replies_per_second</td>
      <td width="280">20930833.406918</td>
      <td width="200">replies/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_mixed_wall_s</td>
      <td width="280">0.611538</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_mixed_rss_mib</td>
      <td width="280">2.691</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_fragmented_parse_mib_per_second</td>
      <td width="280">523.6212</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_fragmented_replies_per_second</td>
      <td width="280">24056962.376226</td>
      <td width="200">replies/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_fragmented_wall_s</td>
      <td width="280">1.064141</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_fragmented_rss_mib</td>
      <td width="280">4.0</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### command_format

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
      <td width="500">format_command_commands_per_second</td>
      <td width="280">1317771.332412</td>
      <td width="200">commands/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">format_command_wall_s</td>
      <td width="280">0.758857</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">format_command_rss_mib</td>
      <td width="280">1.941</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">format_argv_commands_per_second</td>
      <td width="280">4251176.5131</td>
      <td width="200">commands/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">format_argv_wall_s</td>
      <td width="280">0.235229</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">format_argv_rss_mib</td>
      <td width="280">1.812</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### upstream_suite

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
      <td width="500">upstream_local_suite_tests_passed</td>
      <td width="280">77.0</td>
      <td width="200">tests</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">upstream_local_suite_wall_s</td>
      <td width="280">0.006419</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">upstream_local_suite_rss_mib</td>
      <td width="280">0.535</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### hiredis 1.5.0

##### resp_reader

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
      <td width="500">reader_pipeline_parse_mib_per_second</td>
      <td width="280">314.177385</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_pipeline_replies_per_second</td>
      <td width="280">14434391.742626</td>
      <td width="200">replies/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_pipeline_wall_s</td>
      <td width="280">0.886771</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_pipeline_rss_mib</td>
      <td width="280">3.531</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_bulk_parse_mib_per_second</td>
      <td width="280">17281.092321</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_bulk_replies_per_second</td>
      <td width="280">69121.468831</td>
      <td width="200">replies/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_bulk_wall_s</td>
      <td width="280">0.237032</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_bulk_rss_mib</td>
      <td width="280">17.98</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_nested_parse_mib_per_second</td>
      <td width="280">117.514463</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_nested_replies_per_second</td>
      <td width="280">3360596.169761</td>
      <td width="200">replies/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_nested_wall_s</td>
      <td width="280">0.476106</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_nested_rss_mib</td>
      <td width="280">3.098</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_mixed_parse_mib_per_second</td>
      <td width="280">109.34538</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_mixed_replies_per_second</td>
      <td width="280">13782870.261196</td>
      <td width="200">replies/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_mixed_wall_s</td>
      <td width="280">0.928689</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_mixed_rss_mib</td>
      <td width="280">2.145</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_fragmented_parse_mib_per_second</td>
      <td width="280">349.706617</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_fragmented_replies_per_second</td>
      <td width="280">16066727.126096</td>
      <td width="200">replies/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reader_fragmented_wall_s</td>
      <td width="280">1.593355</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reader_fragmented_rss_mib</td>
      <td width="280">3.477</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### command_format

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
      <td width="500">format_command_commands_per_second</td>
      <td width="280">793739.616894</td>
      <td width="200">commands/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">format_command_wall_s</td>
      <td width="280">1.259859</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">format_command_rss_mib</td>
      <td width="280">1.531</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">format_argv_commands_per_second</td>
      <td width="280">1973608.901766</td>
      <td width="200">commands/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">format_argv_wall_s</td>
      <td width="280">0.506686</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">format_argv_rss_mib</td>
      <td width="280">1.348</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### upstream_suite

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
      <td width="500">upstream_local_suite_tests_passed</td>
      <td width="280">77.0</td>
      <td width="200">tests</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">upstream_local_suite_wall_s</td>
      <td width="280">0.238069</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">upstream_local_suite_rss_mib</td>
      <td width="280">2.137</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### hiredis 1.5.0

#### resp_reader

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
      <td width="400">reader_pipeline_parse_mib_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">451.803696</td>
      <td width="200">314.177385</td>
      <td width="380">0.6954</td>
    </tr>
    <tr>
      <td width="400">reader_pipeline_replies_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">20757418.750111</td>
      <td width="200">14434391.742626</td>
      <td width="380">0.6954</td>
    </tr>
    <tr>
      <td width="400">reader_pipeline_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">0.616647</td>
      <td width="200">0.886771</td>
      <td width="380">0.6954</td>
    </tr>
    <tr>
      <td width="400">reader_pipeline_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">4.086</td>
      <td width="200">3.531</td>
      <td width="380">1.1572</td>
    </tr>
    <tr>
      <td width="400">reader_bulk_parse_mib_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">19055.596067</td>
      <td width="200">17281.092321</td>
      <td width="380">0.9069</td>
    </tr>
    <tr>
      <td width="400">reader_bulk_replies_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">76219.185984</td>
      <td width="200">69121.468831</td>
      <td width="380">0.9069</td>
    </tr>
    <tr>
      <td width="400">reader_bulk_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">0.214959</td>
      <td width="200">0.237032</td>
      <td width="380">0.9069</td>
    </tr>
    <tr>
      <td width="400">reader_bulk_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">18.465</td>
      <td width="200">17.98</td>
      <td width="380">1.027</td>
    </tr>
    <tr>
      <td width="400">reader_nested_parse_mib_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">195.568259</td>
      <td width="200">117.514463</td>
      <td width="380">0.6009</td>
    </tr>
    <tr>
      <td width="400">reader_nested_replies_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">5592723.86625</td>
      <td width="200">3360596.169761</td>
      <td width="380">0.6009</td>
    </tr>
    <tr>
      <td width="400">reader_nested_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">0.286086</td>
      <td width="200">0.476106</td>
      <td width="380">0.6009</td>
    </tr>
    <tr>
      <td width="400">reader_nested_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">3.664</td>
      <td width="200">3.098</td>
      <td width="380">1.1827</td>
    </tr>
    <tr>
      <td width="400">reader_mixed_parse_mib_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">166.053216</td>
      <td width="200">109.34538</td>
      <td width="380">0.6585</td>
    </tr>
    <tr>
      <td width="400">reader_mixed_replies_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">20930833.406918</td>
      <td width="200">13782870.261196</td>
      <td width="380">0.6585</td>
    </tr>
    <tr>
      <td width="400">reader_mixed_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">0.611538</td>
      <td width="200">0.928689</td>
      <td width="380">0.6585</td>
    </tr>
    <tr>
      <td width="400">reader_mixed_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">2.691</td>
      <td width="200">2.145</td>
      <td width="380">1.2545</td>
    </tr>
    <tr>
      <td width="400">reader_fragmented_parse_mib_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">523.6212</td>
      <td width="200">349.706617</td>
      <td width="380">0.6679</td>
    </tr>
    <tr>
      <td width="400">reader_fragmented_replies_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">24056962.376226</td>
      <td width="200">16066727.126096</td>
      <td width="380">0.6679</td>
    </tr>
    <tr>
      <td width="400">reader_fragmented_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">1.064141</td>
      <td width="200">1.593355</td>
      <td width="380">0.6679</td>
    </tr>
    <tr>
      <td width="400">reader_fragmented_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">4.0</td>
      <td width="200">3.477</td>
      <td width="380">1.1504</td>
    </tr>
  </tbody>
</table>

#### command_format

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
      <td width="400">format_command_commands_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">1317771.332412</td>
      <td width="200">793739.616894</td>
      <td width="380">0.6023</td>
    </tr>
    <tr>
      <td width="400">format_command_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">0.758857</td>
      <td width="200">1.259859</td>
      <td width="380">0.6023</td>
    </tr>
    <tr>
      <td width="400">format_command_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.941</td>
      <td width="200">1.531</td>
      <td width="380">1.2678</td>
    </tr>
    <tr>
      <td width="400">format_argv_commands_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">4251176.5131</td>
      <td width="200">1973608.901766</td>
      <td width="380">0.4643</td>
    </tr>
    <tr>
      <td width="400">format_argv_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">0.235229</td>
      <td width="200">0.506686</td>
      <td width="380">0.4643</td>
    </tr>
    <tr>
      <td width="400">format_argv_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.812</td>
      <td width="200">1.348</td>
      <td width="380">1.3442</td>
    </tr>
  </tbody>
</table>

#### upstream_suite

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
      <td width="400">upstream_local_suite_tests_passed</td>
      <td width="200">越大越好</td>
      <td width="200">77.0</td>
      <td width="200">77.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">upstream_local_suite_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">0.006419</td>
      <td width="200">0.238069</td>
      <td width="380">0.027</td>
    </tr>
    <tr>
      <td width="400">upstream_local_suite_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">0.535</td>
      <td width="200">2.137</td>
      <td width="380">0.2504</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
