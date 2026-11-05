# fbthrift 2026.10.26.00 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`41986198492-1`

## 测试环境

### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">x86_64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">请求软件版本</td>
      <td width="1200">2026.10.26.00</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">2026.10.26.00</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-05T07:37:10Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">x86_64</td>
    </tr>
  </tbody>
</table>

### 系统信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">x86_64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="1200">2026-11-05T07:29:21Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">x86_64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">AMD EPYC 9654 96-Core Processor</td>
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
      <td width="1200">6.6.0</td>
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
      <td width="1200">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 127052 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 168727 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 170150 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 162475 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 151543 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 157471 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169289 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 165368 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
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

## 性能指标

### Binary / write

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
      <td width="280">25619651.150170647</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_complex_struct__objects_per_second</td>
      <td width="280">39.032537724204694</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_complex_struct__peak_rss_mb</td>
      <td width="280">210.890625</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_big_binary__ns_per_op</td>
      <td width="280">76.86024042448302</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_big_binary__objects_per_second</td>
      <td width="280">13010628.05004524</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_write_big_binary__peak_rss_mb</td>
      <td width="280">10.98046875</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### Binary / read

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
      <td width="280">83194491.04477613</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_complex_struct__objects_per_second</td>
      <td width="280">12.02002665611344</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_complex_struct__peak_rss_mb</td>
      <td width="280">368.93359375</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_big_binary__ns_per_op</td>
      <td width="280">38.98825967231225</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_big_binary__objects_per_second</td>
      <td width="280">25648746.786975875</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_big_binary__peak_rss_mb</td>
      <td width="280">10.95703125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_large_map_int__ns_per_op</td>
      <td width="280">25145619.35379061</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_large_map_int__objects_per_second</td>
      <td width="280">39.768358294553344</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_read_large_map_int__peak_rss_mb</td>
      <td width="280">110.5078125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### Compact / write

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
      <td width="280">33026455.718750004</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_complex_struct__objects_per_second</td>
      <td width="280">30.278756174016976</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_complex_struct__peak_rss_mb</td>
      <td width="280">191.34375</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_big_binary__ns_per_op</td>
      <td width="280">77.04541332651175</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_big_binary__objects_per_second</td>
      <td width="280">12979357.976341655</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_write_big_binary__peak_rss_mb</td>
      <td width="280">11.046875</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### Compact / read

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
      <td width="280">117849655.56666666</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_complex_struct__objects_per_second</td>
      <td width="280">8.485387549005669</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_complex_struct__peak_rss_mb</td>
      <td width="280">349.53125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_big_binary__ns_per_op</td>
      <td width="280">40.79563121272934</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_big_binary__objects_per_second</td>
      <td width="280">24512428.666331626</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_big_binary__peak_rss_mb</td>
      <td width="280">11.2578125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_large_map_int__ns_per_op</td>
      <td width="280">35242434.780612245</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_large_map_int__objects_per_second</td>
      <td width="280">28.37488403469006</td>
      <td width="200">objects/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">compact_read_large_map_int__peak_rss_mb</td>
      <td width="280">110.58203125</td>
      <td width="200">MiB</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
