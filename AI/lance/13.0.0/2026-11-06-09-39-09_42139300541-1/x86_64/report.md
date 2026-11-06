# lance 13.0.0 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`42139300541-1`

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
      <td width="1200">13.0.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">13.0.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-06T01:19:38Z</td>
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
      <td width="1200">2026-11-06T01:02:32Z</td>
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
      <td width="1200">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 126518 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 167464 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 169205 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 162268 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 132116 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 156228 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 163620 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 164555 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
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
      <td width="500">lance_sift</td>
      <td width="880">13.0.0</td>
    </tr>
  </tbody>
</table>

## 性能指标

### nprobes=1,refine_factor=1

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
      <td width="500">nprobes=1,refine_factor=1/mean_query_time</td>
      <td width="280">0.001062903881072998</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=1/recall_at_1</td>
      <td width="280">0.33</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=1,refine_factor=10

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
      <td width="500">nprobes=1,refine_factor=10/mean_query_time</td>
      <td width="280">0.0013659467697143554</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=10/recall_at_1</td>
      <td width="280">0.541</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=1,refine_factor=20

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
      <td width="500">nprobes=1,refine_factor=20/mean_query_time</td>
      <td width="280">0.0014702026844024658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=20/recall_at_1</td>
      <td width="280">0.55</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=1,refine_factor=30

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
      <td width="500">nprobes=1,refine_factor=30/mean_query_time</td>
      <td width="280">0.0015043461322784425</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=30/recall_at_1</td>
      <td width="280">0.552</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=1,refine_factor=40

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
      <td width="500">nprobes=1,refine_factor=40/mean_query_time</td>
      <td width="280">0.0015017108917236327</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=40/recall_at_1</td>
      <td width="280">0.552</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=1,refine_factor=50

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
      <td width="500">nprobes=1,refine_factor=50/mean_query_time</td>
      <td width="280">0.0016885924339294434</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=50/recall_at_1</td>
      <td width="280">0.552</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=1,refine_factor=none

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
      <td width="500">nprobes=1,refine_factor=none/mean_query_time</td>
      <td width="280">0.0009970314502716065</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=none/recall_at_1</td>
      <td width="280">0.33</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=10,refine_factor=1

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
      <td width="500">nprobes=10,refine_factor=1/mean_query_time</td>
      <td width="280">0.0017806570529937745</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=1/recall_at_1</td>
      <td width="280">0.464</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=10,refine_factor=10

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
      <td width="500">nprobes=10,refine_factor=10/mean_query_time</td>
      <td width="280">0.0018594110012054444</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=10/recall_at_1</td>
      <td width="280">0.89</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=10,refine_factor=20

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
      <td width="500">nprobes=10,refine_factor=20/mean_query_time</td>
      <td width="280">0.001832386016845703</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=20/recall_at_1</td>
      <td width="280">0.949</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=10,refine_factor=30

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
      <td width="500">nprobes=10,refine_factor=30/mean_query_time</td>
      <td width="280">0.0017586874961853028</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=30/recall_at_1</td>
      <td width="280">0.964</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=10,refine_factor=40

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
      <td width="500">nprobes=10,refine_factor=40/mean_query_time</td>
      <td width="280">0.001806307315826416</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=40/recall_at_1</td>
      <td width="280">0.968</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=10,refine_factor=50

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
      <td width="500">nprobes=10,refine_factor=50/mean_query_time</td>
      <td width="280">0.001959707021713257</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=50/recall_at_1</td>
      <td width="280">0.972</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=10,refine_factor=none

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
      <td width="500">nprobes=10,refine_factor=none/mean_query_time</td>
      <td width="280">0.001325113296508789</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=none/recall_at_1</td>
      <td width="280">0.464</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=100,refine_factor=1

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
      <td width="500">nprobes=100,refine_factor=1/mean_query_time</td>
      <td width="280">0.004441267728805542</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=1/recall_at_1</td>
      <td width="280">0.469</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=100,refine_factor=10

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
      <td width="500">nprobes=100,refine_factor=10/mean_query_time</td>
      <td width="280">0.00452047061920166</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=10/recall_at_1</td>
      <td width="280">0.904</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=100,refine_factor=20

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
      <td width="500">nprobes=100,refine_factor=20/mean_query_time</td>
      <td width="280">0.004592530727386475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=20/recall_at_1</td>
      <td width="280">0.967</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=100,refine_factor=30

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
      <td width="500">nprobes=100,refine_factor=30/mean_query_time</td>
      <td width="280">0.004716219902038574</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=30/recall_at_1</td>
      <td width="280">0.986</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=100,refine_factor=40

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
      <td width="500">nprobes=100,refine_factor=40/mean_query_time</td>
      <td width="280">0.004744471311569214</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=40/recall_at_1</td>
      <td width="280">0.991</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=100,refine_factor=50

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
      <td width="500">nprobes=100,refine_factor=50/mean_query_time</td>
      <td width="280">0.004811790943145752</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=50/recall_at_1</td>
      <td width="280">0.996</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=100,refine_factor=none

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
      <td width="500">nprobes=100,refine_factor=none/mean_query_time</td>
      <td width="280">0.004021477222442627</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=none/recall_at_1</td>
      <td width="280">0.469</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=25,refine_factor=1

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
      <td width="500">nprobes=25,refine_factor=1/mean_query_time</td>
      <td width="280">0.0022606501579284666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=1/recall_at_1</td>
      <td width="280">0.469</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=25,refine_factor=10

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
      <td width="500">nprobes=25,refine_factor=10/mean_query_time</td>
      <td width="280">0.0021286530494689943</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=10/recall_at_1</td>
      <td width="280">0.904</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=25,refine_factor=20

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
      <td width="500">nprobes=25,refine_factor=20/mean_query_time</td>
      <td width="280">0.0020860137939453125</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=20/recall_at_1</td>
      <td width="280">0.966</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=25,refine_factor=30

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
      <td width="500">nprobes=25,refine_factor=30/mean_query_time</td>
      <td width="280">0.0020933427810668945</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=30/recall_at_1</td>
      <td width="280">0.985</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=25,refine_factor=40

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
      <td width="500">nprobes=25,refine_factor=40/mean_query_time</td>
      <td width="280">0.0023388214111328123</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=40/recall_at_1</td>
      <td width="280">0.99</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=25,refine_factor=50

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
      <td width="500">nprobes=25,refine_factor=50/mean_query_time</td>
      <td width="280">0.00240919828414917</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=50/recall_at_1</td>
      <td width="280">0.995</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=25,refine_factor=none

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
      <td width="500">nprobes=25,refine_factor=none/mean_query_time</td>
      <td width="280">0.0017043888568878175</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=none/recall_at_1</td>
      <td width="280">0.469</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=50,refine_factor=1

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
      <td width="500">nprobes=50,refine_factor=1/mean_query_time</td>
      <td width="280">0.0029774973392486573</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=1/recall_at_1</td>
      <td width="280">0.469</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=50,refine_factor=10

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
      <td width="500">nprobes=50,refine_factor=10/mean_query_time</td>
      <td width="280">0.0030794992446899414</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=10/recall_at_1</td>
      <td width="280">0.904</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=50,refine_factor=20

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
      <td width="500">nprobes=50,refine_factor=20/mean_query_time</td>
      <td width="280">0.003102020502090454</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=20/recall_at_1</td>
      <td width="280">0.967</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=50,refine_factor=30

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
      <td width="500">nprobes=50,refine_factor=30/mean_query_time</td>
      <td width="280">0.003039160490036011</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=30/recall_at_1</td>
      <td width="280">0.986</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=50,refine_factor=40

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
      <td width="500">nprobes=50,refine_factor=40/mean_query_time</td>
      <td width="280">0.0031312036514282225</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=40/recall_at_1</td>
      <td width="280">0.991</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=50,refine_factor=50

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
      <td width="500">nprobes=50,refine_factor=50/mean_query_time</td>
      <td width="280">0.003088364601135254</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=50/recall_at_1</td>
      <td width="280">0.996</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=50,refine_factor=none

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
      <td width="500">nprobes=50,refine_factor=none/mean_query_time</td>
      <td width="280">0.002467188119888306</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=none/recall_at_1</td>
      <td width="280">0.469</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=75,refine_factor=1

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
      <td width="500">nprobes=75,refine_factor=1/mean_query_time</td>
      <td width="280">0.0034716196060180665</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=1/recall_at_1</td>
      <td width="280">0.469</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=75,refine_factor=10

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
      <td width="500">nprobes=75,refine_factor=10/mean_query_time</td>
      <td width="280">0.00366841721534729</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=10/recall_at_1</td>
      <td width="280">0.904</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=75,refine_factor=20

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
      <td width="500">nprobes=75,refine_factor=20/mean_query_time</td>
      <td width="280">0.0036023728847503662</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=20/recall_at_1</td>
      <td width="280">0.967</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=75,refine_factor=30

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
      <td width="500">nprobes=75,refine_factor=30/mean_query_time</td>
      <td width="280">0.0036614646911621094</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=30/recall_at_1</td>
      <td width="280">0.986</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=75,refine_factor=40

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
      <td width="500">nprobes=75,refine_factor=40/mean_query_time</td>
      <td width="280">0.003764613151550293</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=40/recall_at_1</td>
      <td width="280">0.991</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=75,refine_factor=50

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
      <td width="500">nprobes=75,refine_factor=50/mean_query_time</td>
      <td width="280">0.004004249811172486</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=50/recall_at_1</td>
      <td width="280">0.996</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### nprobes=75,refine_factor=none

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
      <td width="500">nprobes=75,refine_factor=none/mean_query_time</td>
      <td width="280">0.00304852294921875</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=none/recall_at_1</td>
      <td width="280">0.469</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
