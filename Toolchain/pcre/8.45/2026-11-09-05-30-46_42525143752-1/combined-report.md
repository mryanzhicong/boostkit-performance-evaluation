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
      <td width="220">pcre</td>
      <td width="160">8.45</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">pcre</td>
      <td width="160">8.45</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### pcre 8.45

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
      <td width="600">8.45</td>
      <td width="600">8.45</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">8.45</td>
      <td width="600">8.45</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-08T21:26:47Z</td>
      <td width="600">2026-11-08T21:27:07Z</td>
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
      <td width="600">2026-11-08T21:26:07Z</td>
      <td width="600">2026-11-08T21:26:07Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 61967 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 140428 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 167939 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 166199 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 134414 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 159697 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169196 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 163502 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 365468 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 378435 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 343642 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 350501 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">pcretest</td>
      <td width="880">8.45 (built from the pinned source archive)</td>
    </tr>
    <tr>
      <td width="500">pcregrep</td>
      <td width="880">8.45 (built from the pinned source archive)</td>
    </tr>
    <tr>
      <td width="500">RunTest</td>
      <td width="880">8.45 upstream test suite shipped in the source archive</td>
    </tr>
    <tr>
      <td width="500">pcre_bench</td>
      <td width="880">1.0.0 (case-owned MIT load, compiled against the built libpcre)</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### pcre 8.45

##### pcretest_upstream

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
      <td width="500">pcretest_timing_literal_compiles_per_second</td>
      <td width="280">1324748.960072</td>
      <td width="200">compiles/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_literal_matches_per_second</td>
      <td width="280">2870289.413489</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_compiles_per_second</td>
      <td width="280">1152.219751</td>
      <td width="200">compiles/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_matches_per_second</td>
      <td width="280">1152.219751</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_compiles_per_second</td>
      <td width="280">3532515.703136</td>
      <td width="200">compiles/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_matches_per_second</td>
      <td width="280">3532515.703136</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_dfa_matches_per_second</td>
      <td width="280">1567214.704235</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_literal_wall_s</td>
      <td width="280">1.358748</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_literal_rss_mib</td>
      <td width="280">2.0</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_wall_s</td>
      <td width="280">1.562202</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_rss_mib</td>
      <td width="280">1.945</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_wall_s</td>
      <td width="280">1.358805</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_rss_mib</td>
      <td width="280">1.852</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_dfa_wall_s</td>
      <td width="280">0.957112</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_dfa_rss_mib</td>
      <td width="280">1.996</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### runtest_upstream

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
      <td width="500">upstream_runtest_tests_ok</td>
      <td width="280">36.0</td>
      <td width="200">tests</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">upstream_runtest_wall_s</td>
      <td width="280">0.337544</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">upstream_runtest_rss_mib</td>
      <td width="280">3.359</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### pcre_exec_matrix

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
      <td width="500">pcre_exec_literal_match_ns_per_op</td>
      <td width="280">132.723502</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_literal_ops_per_second</td>
      <td width="280">7534460.643303</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_match_ns_per_op</td>
      <td width="280">2441250.681667</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_ops_per_second</td>
      <td width="280">409.626102</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_match_ns_per_op</td>
      <td width="280">105.789406</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_ops_per_second</td>
      <td width="280">9452742.403513</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_dfa_ns_per_op</td>
      <td width="280">223.41675</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_ops_per_second</td>
      <td width="280">4475940.151266</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_match_ns_per_op</td>
      <td width="280">23.431197</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_ops_per_second</td>
      <td width="280">42678144.136008</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_compile_compile_ns_per_op</td>
      <td width="280">503.131037</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_compile_compiles_per_second</td>
      <td width="280">1987553.791081</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_literal_wall_s</td>
      <td width="280">1.333296</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_literal_rss_mib</td>
      <td width="280">1.859</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_wall_s</td>
      <td width="280">1.470554</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_rss_mib</td>
      <td width="280">1.812</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_wall_s</td>
      <td width="280">1.272359</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_rss_mib</td>
      <td width="280">1.863</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_wall_s</td>
      <td width="280">1.119973</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_rss_mib</td>
      <td width="280">1.801</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_wall_s</td>
      <td width="280">1.409663</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_rss_mib</td>
      <td width="280">1.941</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_compile_wall_s</td>
      <td width="280">1.51124</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_compile_rss_mib</td>
      <td width="280">1.621</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### pcregrep_tool

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
      <td width="500">pcregrep_scan_matched_lines</td>
      <td width="280">725100.0</td>
      <td width="200">lines</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcregrep_scan_scan_mib_per_second</td>
      <td width="280">768.201919</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcregrep_scan_wall_s</td>
      <td width="280">0.571055</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcregrep_scan_rss_mib</td>
      <td width="280">3.258</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### pcre 8.45

##### pcretest_upstream

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
      <td width="500">pcretest_timing_literal_compiles_per_second</td>
      <td width="280">939631.789623</td>
      <td width="200">compiles/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_literal_matches_per_second</td>
      <td width="280">2035868.877516</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_compiles_per_second</td>
      <td width="280">789.476454</td>
      <td width="200">compiles/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_matches_per_second</td>
      <td width="280">789.476454</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_compiles_per_second</td>
      <td width="280">2264747.04191</td>
      <td width="200">compiles/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_matches_per_second</td>
      <td width="280">2264747.04191</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_dfa_matches_per_second</td>
      <td width="280">1108999.903887</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_literal_wall_s</td>
      <td width="280">1.915644</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_literal_rss_mib</td>
      <td width="280">1.617</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_wall_s</td>
      <td width="280">2.279992</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_rss_mib</td>
      <td width="280">1.57</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_wall_s</td>
      <td width="280">2.119442</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_rss_mib</td>
      <td width="280">1.629</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_dfa_wall_s</td>
      <td width="280">1.35257</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_dfa_rss_mib</td>
      <td width="280">1.633</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### runtest_upstream

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
      <td width="500">upstream_runtest_tests_ok</td>
      <td width="280">36.0</td>
      <td width="200">tests</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">upstream_runtest_wall_s</td>
      <td width="280">0.50321</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">upstream_runtest_rss_mib</td>
      <td width="280">3.141</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### pcre_exec_matrix

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
      <td width="500">pcre_exec_literal_match_ns_per_op</td>
      <td width="280">225.024775</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_literal_ops_per_second</td>
      <td width="280">4443955.117584</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_match_ns_per_op</td>
      <td width="280">3766429.373333</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_ops_per_second</td>
      <td width="280">265.503452</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_match_ns_per_op</td>
      <td width="280">167.293939</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_ops_per_second</td>
      <td width="280">5977502.87293</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_dfa_ns_per_op</td>
      <td width="280">329.588536</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_ops_per_second</td>
      <td width="280">3034086.110911</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_match_ns_per_op</td>
      <td width="280">37.659414</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_ops_per_second</td>
      <td width="280">26553785.403755</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_compile_compile_ns_per_op</td>
      <td width="280">725.171162</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_compile_compiles_per_second</td>
      <td width="280">1378984.786491</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_literal_wall_s</td>
      <td width="280">2.255661</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_literal_rss_mib</td>
      <td width="280">1.496</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_wall_s</td>
      <td width="280">2.268902</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_rss_mib</td>
      <td width="280">1.492</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_wall_s</td>
      <td width="280">2.012613</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_rss_mib</td>
      <td width="280">1.559</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_wall_s</td>
      <td width="280">1.651582</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_rss_mib</td>
      <td width="280">1.441</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_wall_s</td>
      <td width="280">2.265722</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_rss_mib</td>
      <td width="280">1.523</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_compile_wall_s</td>
      <td width="280">2.181637</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_compile_rss_mib</td>
      <td width="280">1.375</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### pcregrep_tool

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
      <td width="500">pcregrep_scan_matched_lines</td>
      <td width="280">725100.0</td>
      <td width="200">lines</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcregrep_scan_scan_mib_per_second</td>
      <td width="280">483.49755</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcregrep_scan_wall_s</td>
      <td width="280">0.907317</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcregrep_scan_rss_mib</td>
      <td width="280">2.902</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### pcre 8.45

#### pcretest_upstream

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
      <td width="400">pcretest_timing_literal_compiles_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">1324748.960072</td>
      <td width="200">939631.789623</td>
      <td width="380">0.7093</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_literal_matches_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">2870289.413489</td>
      <td width="200">2035868.877516</td>
      <td width="380">0.7093</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_backtrack_compiles_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">1152.219751</td>
      <td width="200">789.476454</td>
      <td width="380">0.6852</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_backtrack_matches_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">1152.219751</td>
      <td width="200">789.476454</td>
      <td width="380">0.6852</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_utf8_compiles_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">3532515.703136</td>
      <td width="200">2264747.04191</td>
      <td width="380">0.6411</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_utf8_matches_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">3532515.703136</td>
      <td width="200">2264747.04191</td>
      <td width="380">0.6411</td>
    </tr>
    <tr>
      <td width="400">pcretest_dfa_matches_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">1567214.704235</td>
      <td width="200">1108999.903887</td>
      <td width="380">0.7076</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_literal_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">1.358748</td>
      <td width="200">1.915644</td>
      <td width="380">0.7093</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_literal_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">1.617</td>
      <td width="380">1.2369</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_backtrack_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">1.562202</td>
      <td width="200">2.279992</td>
      <td width="380">0.6852</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_backtrack_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.945</td>
      <td width="200">1.57</td>
      <td width="380">1.2389</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_utf8_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">1.358805</td>
      <td width="200">2.119442</td>
      <td width="380">0.6411</td>
    </tr>
    <tr>
      <td width="400">pcretest_timing_utf8_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.852</td>
      <td width="200">1.629</td>
      <td width="380">1.1369</td>
    </tr>
    <tr>
      <td width="400">pcretest_dfa_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">0.957112</td>
      <td width="200">1.35257</td>
      <td width="380">0.7076</td>
    </tr>
    <tr>
      <td width="400">pcretest_dfa_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.996</td>
      <td width="200">1.633</td>
      <td width="380">1.2223</td>
    </tr>
  </tbody>
</table>

#### runtest_upstream

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
      <td width="400">upstream_runtest_tests_ok</td>
      <td width="200">越大越好</td>
      <td width="200">36.0</td>
      <td width="200">36.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">upstream_runtest_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">0.337544</td>
      <td width="200">0.50321</td>
      <td width="380">0.6708</td>
    </tr>
    <tr>
      <td width="400">upstream_runtest_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">3.359</td>
      <td width="200">3.141</td>
      <td width="380">1.0694</td>
    </tr>
  </tbody>
</table>

#### pcre_exec_matrix

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
      <td width="400">pcre_exec_literal_match_ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">132.723502</td>
      <td width="200">225.024775</td>
      <td width="380">0.5898</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_literal_ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">7534460.643303</td>
      <td width="200">4443955.117584</td>
      <td width="380">0.5898</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_backtrack_match_ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">2441250.681667</td>
      <td width="200">3766429.373333</td>
      <td width="380">0.6482</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_backtrack_ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">409.626102</td>
      <td width="200">265.503452</td>
      <td width="380">0.6482</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_utf8_match_ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">105.789406</td>
      <td width="200">167.293939</td>
      <td width="380">0.6324</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_utf8_ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">9452742.403513</td>
      <td width="200">5977502.87293</td>
      <td width="380">0.6324</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_dfa_dfa_ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">223.41675</td>
      <td width="200">329.588536</td>
      <td width="380">0.6779</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_dfa_ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">4475940.151266</td>
      <td width="200">3034086.110911</td>
      <td width="380">0.6779</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_jit_match_ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">23.431197</td>
      <td width="200">37.659414</td>
      <td width="380">0.6222</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_jit_ops_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">42678144.136008</td>
      <td width="200">26553785.403755</td>
      <td width="380">0.6222</td>
    </tr>
    <tr>
      <td width="400">pcre_compile_compile_ns_per_op</td>
      <td width="200">越小越好</td>
      <td width="200">503.131037</td>
      <td width="200">725.171162</td>
      <td width="380">0.6938</td>
    </tr>
    <tr>
      <td width="400">pcre_compile_compiles_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">1987553.791081</td>
      <td width="200">1378984.786491</td>
      <td width="380">0.6938</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_literal_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">1.333296</td>
      <td width="200">2.255661</td>
      <td width="380">0.5911</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_literal_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.859</td>
      <td width="200">1.496</td>
      <td width="380">1.2426</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_backtrack_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">1.470554</td>
      <td width="200">2.268902</td>
      <td width="380">0.6481</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_backtrack_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.812</td>
      <td width="200">1.492</td>
      <td width="380">1.2145</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_utf8_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">1.272359</td>
      <td width="200">2.012613</td>
      <td width="380">0.6322</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_utf8_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.863</td>
      <td width="200">1.559</td>
      <td width="380">1.195</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_dfa_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">1.119973</td>
      <td width="200">1.651582</td>
      <td width="380">0.6781</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_dfa_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.801</td>
      <td width="200">1.441</td>
      <td width="380">1.2498</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_jit_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">1.409663</td>
      <td width="200">2.265722</td>
      <td width="380">0.6222</td>
    </tr>
    <tr>
      <td width="400">pcre_exec_jit_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.941</td>
      <td width="200">1.523</td>
      <td width="380">1.2745</td>
    </tr>
    <tr>
      <td width="400">pcre_compile_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">1.51124</td>
      <td width="200">2.181637</td>
      <td width="380">0.6927</td>
    </tr>
    <tr>
      <td width="400">pcre_compile_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">1.621</td>
      <td width="200">1.375</td>
      <td width="380">1.1789</td>
    </tr>
  </tbody>
</table>

#### pcregrep_tool

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
      <td width="400">pcregrep_scan_matched_lines</td>
      <td width="200">越大越好</td>
      <td width="200">725100.0</td>
      <td width="200">725100.0</td>
      <td width="380">1.0</td>
    </tr>
    <tr>
      <td width="400">pcregrep_scan_scan_mib_per_second</td>
      <td width="200">越大越好</td>
      <td width="200">768.201919</td>
      <td width="200">483.49755</td>
      <td width="380">0.6294</td>
    </tr>
    <tr>
      <td width="400">pcregrep_scan_wall_s</td>
      <td width="200">越小越好</td>
      <td width="200">0.571055</td>
      <td width="200">0.907317</td>
      <td width="380">0.6294</td>
    </tr>
    <tr>
      <td width="400">pcregrep_scan_rss_mib</td>
      <td width="200">越小越好</td>
      <td width="200">3.258</td>
      <td width="200">2.902</td>
      <td width="380">1.1227</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
