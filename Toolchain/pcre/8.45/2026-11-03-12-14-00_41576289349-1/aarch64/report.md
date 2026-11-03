# pcre 8.45 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`41576289349-1`

## 测试环境

### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">请求软件版本</td>
      <td width="1200">8.45</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">8.45</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-03T04:10:22Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">aarch64</td>
    </tr>
  </tbody>
</table>

### 系统信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="1200">2026-11-03T04:08:36Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">Kunpeng 950 7592C To Be Filled By O.E.M. CPU @ 2.3GHz</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="1200">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="1200">openEuler 24.03 (LTS-SP3)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="1200">6.6.0-132.0.0.111.oe2403sp3.aarch64</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="1200">3.11.6</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="1200">12.3.1</td>
    </tr>
    <tr>
      <td width="180">glibc 版本</td>
      <td width="1200">glibc 2.38</td>
    </tr>
    <tr>
      <td width="180">NUMA</td>
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 379543 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 385204 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 376495 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 382561 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
    </tr>
  </tbody>
</table>

### 测试工具

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

## 性能指标

### pcretest_upstream

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
      <td width="280">942256.925196</td>
      <td width="200">compiles/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_literal_matches_per_second</td>
      <td width="280">2041556.671258</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_compiles_per_second</td>
      <td width="280">796.00054</td>
      <td width="200">compiles/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_matches_per_second</td>
      <td width="280">796.00054</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_compiles_per_second</td>
      <td width="280">2261669.507889</td>
      <td width="200">compiles/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_matches_per_second</td>
      <td width="280">2261669.507889</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_dfa_matches_per_second</td>
      <td width="280">1110768.829753</td>
      <td width="200">matches/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_literal_wall_s</td>
      <td width="280">1.910307</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_literal_rss_mib</td>
      <td width="280">1.629</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_wall_s</td>
      <td width="280">2.261305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_backtrack_rss_mib</td>
      <td width="280">1.578</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_timing_utf8_wall_s</td>
      <td width="280">2.122326</td>
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
      <td width="280">1.350416</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcretest_dfa_rss_mib</td>
      <td width="280">1.637</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### runtest_upstream

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
      <td width="280">0.51445</td>
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

### pcre_exec_matrix

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
      <td width="280">225.433076</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_literal_ops_per_second</td>
      <td width="280">4435906.281038</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_match_ns_per_op</td>
      <td width="280">3755852.515</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_ops_per_second</td>
      <td width="280">266.251136</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_match_ns_per_op</td>
      <td width="280">168.069456</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_ops_per_second</td>
      <td width="280">5949921.082057</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_dfa_ns_per_op</td>
      <td width="280">330.626366</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_ops_per_second</td>
      <td width="280">3024562.176659</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_match_ns_per_op</td>
      <td width="280">37.58072</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_ops_per_second</td>
      <td width="280">26609389.034311</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_compile_compile_ns_per_op</td>
      <td width="280">726.475728</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_compile_compiles_per_second</td>
      <td width="280">1376508.480485</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_literal_wall_s</td>
      <td width="280">2.259622</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_literal_rss_mib</td>
      <td width="280">1.5</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_backtrack_wall_s</td>
      <td width="280">2.260762</td>
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
      <td width="280">2.021449</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_utf8_rss_mib</td>
      <td width="280">1.562</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_wall_s</td>
      <td width="280">1.657342</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_dfa_rss_mib</td>
      <td width="280">1.445</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pcre_exec_jit_wall_s</td>
      <td width="280">2.259081</td>
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
      <td width="280">2.183874</td>
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

### pcregrep_tool

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
      <td width="280">481.865516</td>
      <td width="200">MiB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">pcregrep_scan_wall_s</td>
      <td width="280">0.91039</td>
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
