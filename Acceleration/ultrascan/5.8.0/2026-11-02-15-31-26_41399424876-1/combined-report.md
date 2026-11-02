# 性能测试汇总

- 任务总数：1
- 成功：1
- 失败：0
- 跨架构对比：0

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
      <td width="220">ultrascan</td>
      <td width="160">5.8.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### ultrascan 5.8.0

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
      <td width="600">N/A</td>
      <td width="600">5.8.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">N/A</td>
      <td width="600">5.8.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">N/A</td>
      <td width="600">2026-11-02T07:25:52Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">N/A</td>
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
      <td width="600">N/A</td>
      <td width="600">2026-11-02T07:23:56Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">N/A</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">N/A</td>
      <td width="600">-</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">N/A</td>
      <td width="600">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">N/A</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">N/A</td>
      <td width="600">6.6.0-132.0.0.111.oe2403sp3.aarch64</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="600">N/A</td>
      <td width="600">3.11.6</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="600">N/A</td>
      <td width="600">12.3.1</td>
    </tr>
    <tr>
      <td width="180">glibc 版本</td>
      <td width="600">N/A</td>
      <td width="600">glibc 2.38</td>
    </tr>
    <tr>
      <td width="180">NUMA</td>
      <td width="600">N/A</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 378410 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 383575 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 379283 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 385957 MB<br>node 3 free: 383325 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">hsbench</td>
      <td width="880">与 Ultrascan 5.8.0 源码一致</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### aarch64

#### ultrascan 5.8.0

##### corpus

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
      <td width="500">corpus__corpus_data_bytes</td>
      <td width="280">177087567</td>
      <td width="200">bytes</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">corpus__corpus_database_file_bytes</td>
      <td width="280">192055296</td>
      <td width="200">bytes</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

##### snort_literals_block_1c

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
      <td width="500">snort_literals_block_1c__block_rate</td>
      <td width="280">374312.5</td>
      <td width="200">blocks/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_1c__database_size</td>
      <td width="280">921592.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_1c__expression_count</td>
      <td width="280">3116.0</td>
      <td width="200">patterns</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_1c__matches_per_iteration</td>
      <td width="280">637380.0</td>
      <td width="200">matches</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_1c__peak_rss</td>
      <td width="280">381644800.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_1c__scan_throughput</td>
      <td width="280">4049.33</td>
      <td width="200">Mbit/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_1c__wall_time</td>
      <td width="280">1.2674858400132507</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### snort_literals_block_4c

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
      <td width="500">snort_literals_block_4c__block_rate</td>
      <td width="280">875370.38</td>
      <td width="200">blocks/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_4c__database_size</td>
      <td width="280">921592.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_4c__expression_count</td>
      <td width="280">3116.0</td>
      <td width="200">patterns</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_4c__matches_per_iteration</td>
      <td width="280">637380.0</td>
      <td width="200">matches</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_4c__peak_rss</td>
      <td width="280">938262528.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_4c__scan_throughput</td>
      <td width="280">9469.81</td>
      <td width="200">Mbit/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_block_4c__wall_time</td>
      <td width="280">2.055218399007572</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### snort_literals_stream_1c

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
      <td width="500">snort_literals_stream_1c__block_rate</td>
      <td width="280">419417.67</td>
      <td width="200">blocks/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_1c__database_size</td>
      <td width="280">693880.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_1c__expression_count</td>
      <td width="280">3116.0</td>
      <td width="200">patterns</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_1c__matches_per_iteration</td>
      <td width="280">81963.0</td>
      <td width="200">matches</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_1c__peak_rss</td>
      <td width="280">381415424.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_1c__scan_throughput</td>
      <td width="280">4537.29</td>
      <td width="200">Mbit/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_1c__wall_time</td>
      <td width="280">1.15411801400478</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### snort_literals_stream_4c

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
      <td width="500">snort_literals_stream_4c__block_rate</td>
      <td width="280">967635.25</td>
      <td width="200">blocks/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_4c__database_size</td>
      <td width="280">693880.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_4c__expression_count</td>
      <td width="280">3116.0</td>
      <td width="200">patterns</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_4c__matches_per_iteration</td>
      <td width="280">81963.0</td>
      <td width="200">matches</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_4c__peak_rss</td>
      <td width="280">938487808.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_4c__scan_throughput</td>
      <td width="280">10467.94</td>
      <td width="200">Mbit/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_literals_stream_4c__wall_time</td>
      <td width="280">1.880665874981787</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### snort_pcres_block_1c

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
      <td width="500">snort_pcres_block_1c__block_rate</td>
      <td width="280">111004.56</td>
      <td width="200">blocks/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c__database_size</td>
      <td width="280">2018136.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c__expression_count</td>
      <td width="280">847.0</td>
      <td width="200">patterns</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c__matches_per_iteration</td>
      <td width="280">1522622.0</td>
      <td width="200">matches</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c__peak_rss</td>
      <td width="280">383049728.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c__scan_throughput</td>
      <td width="280">1200.85</td>
      <td width="200">Mbit/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c__wall_time</td>
      <td width="280">7.078895738988649</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### snort_pcres_block_1c_db_load

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
      <td width="500">snort_pcres_block_1c_db_load__block_rate</td>
      <td width="280">110949.19</td>
      <td width="200">blocks/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c_db_load__database_size</td>
      <td width="280">2018136.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c_db_load__expression_count</td>
      <td width="280">847.0</td>
      <td width="200">patterns</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c_db_load__matches_per_iteration</td>
      <td width="280">1522622.0</td>
      <td width="200">matches</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c_db_load__peak_rss</td>
      <td width="280">379645952.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c_db_load__scan_throughput</td>
      <td width="280">1200.25</td>
      <td width="200">Mbit/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_1c_db_load__wall_time</td>
      <td width="280">2.7952755419828463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### snort_pcres_block_4c

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
      <td width="500">snort_pcres_block_4c__block_rate</td>
      <td width="280">316810.22</td>
      <td width="200">blocks/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_4c__database_size</td>
      <td width="280">2018136.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_4c__expression_count</td>
      <td width="280">847.0</td>
      <td width="200">patterns</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_4c__matches_per_iteration</td>
      <td width="280">1522622.0</td>
      <td width="200">matches</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_4c__peak_rss</td>
      <td width="280">940040192.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_4c__scan_throughput</td>
      <td width="280">3427.27</td>
      <td width="200">Mbit/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_block_4c__wall_time</td>
      <td width="280">8.509058886003913</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### snort_pcres_stream_1c

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
      <td width="500">snort_pcres_stream_1c__block_rate</td>
      <td width="280">65477.58</td>
      <td width="200">blocks/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c__database_size</td>
      <td width="280">1960864.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c__expression_count</td>
      <td width="280">847.0</td>
      <td width="200">patterns</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c__matches_per_iteration</td>
      <td width="280">305637.0</td>
      <td width="200">matches</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c__peak_rss</td>
      <td width="280">382963712.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c__scan_throughput</td>
      <td width="280">708.34</td>
      <td width="200">Mbit/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c__wall_time</td>
      <td width="280">8.911281170003349</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### snort_pcres_stream_1c_db_load

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
      <td width="500">snort_pcres_stream_1c_db_load__block_rate</td>
      <td width="280">65913.9</td>
      <td width="200">blocks/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c_db_load__database_size</td>
      <td width="280">1960864.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c_db_load__expression_count</td>
      <td width="280">847.0</td>
      <td width="200">patterns</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c_db_load__matches_per_iteration</td>
      <td width="280">305637.0</td>
      <td width="200">matches</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c_db_load__peak_rss</td>
      <td width="280">379559936.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c_db_load__scan_throughput</td>
      <td width="280">713.06</td>
      <td width="200">Mbit/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_1c_db_load__wall_time</td>
      <td width="280">4.50302547699539</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### snort_pcres_stream_4c

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
      <td width="500">snort_pcres_stream_4c__block_rate</td>
      <td width="280">200431.04</td>
      <td width="200">blocks/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_4c__database_size</td>
      <td width="280">1960864.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_4c__expression_count</td>
      <td width="280">847.0</td>
      <td width="200">patterns</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_4c__matches_per_iteration</td>
      <td width="280">305637.0</td>
      <td width="200">matches</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_4c__peak_rss</td>
      <td width="280">939622400.0</td>
      <td width="200">bytes</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_4c__scan_throughput</td>
      <td width="280">2168.27</td>
      <td width="200">Mbit/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">snort_pcres_stream_4c__wall_time</td>
      <td width="280">10.757840709993616</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
