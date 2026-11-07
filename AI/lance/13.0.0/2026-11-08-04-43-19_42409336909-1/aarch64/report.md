# lance 13.0.0 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`42409336909-1`

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
      <td width="1200">13.0.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">13.0.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-07T20:31:30Z</td>
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
      <td width="1200">2026-11-07T20:06:06Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 367725 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 379295 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 356529 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 351493 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">0.004252521991729736</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=1/recall_at_1</td>
      <td width="280">0.3</td>
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
      <td width="280">0.007630712032318116</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=10/recall_at_1</td>
      <td width="280">0.51</td>
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
      <td width="280">0.008721610069274903</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=20/recall_at_1</td>
      <td width="280">0.526</td>
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
      <td width="280">0.01054902744293213</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=30/recall_at_1</td>
      <td width="280">0.527</td>
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
      <td width="280">0.01633111023902893</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=40/recall_at_1</td>
      <td width="280">0.53</td>
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
      <td width="280">0.015829875946044923</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=50/recall_at_1</td>
      <td width="280">0.53</td>
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
      <td width="280">0.003971836566925049</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=1,refine_factor=none/recall_at_1</td>
      <td width="280">0.3</td>
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
      <td width="280">0.006200378179550171</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=1/recall_at_1</td>
      <td width="280">0.438</td>
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
      <td width="280">0.009572388172149658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=10/recall_at_1</td>
      <td width="280">0.877</td>
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
      <td width="280">0.009475063800811768</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=20/recall_at_1</td>
      <td width="280">0.942</td>
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
      <td width="280">0.01224823784828186</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=30/recall_at_1</td>
      <td width="280">0.955</td>
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
      <td width="280">0.014960773229599</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=40/recall_at_1</td>
      <td width="280">0.961</td>
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
      <td width="280">0.02082332706451416</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=50/recall_at_1</td>
      <td width="280">0.963</td>
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
      <td width="280">0.005725554943084717</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=10,refine_factor=none/recall_at_1</td>
      <td width="280">0.438</td>
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
      <td width="280">0.015196753501892089</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=1/recall_at_1</td>
      <td width="280">0.447</td>
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
      <td width="280">0.016570975780487062</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=10/recall_at_1</td>
      <td width="280">0.892</td>
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
      <td width="280">0.018924864053726197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=20/recall_at_1</td>
      <td width="280">0.961</td>
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
      <td width="280">0.02154319357872009</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=30/recall_at_1</td>
      <td width="280">0.976</td>
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
      <td width="280">0.02640098214149475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=40/recall_at_1</td>
      <td width="280">0.983</td>
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
      <td width="280">0.021464047431945802</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=50/recall_at_1</td>
      <td width="280">0.986</td>
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
      <td width="280">0.013142791032791137</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=100,refine_factor=none/recall_at_1</td>
      <td width="280">0.447</td>
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
      <td width="280">0.008517679691314697</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=1/recall_at_1</td>
      <td width="280">0.446</td>
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
      <td width="280">0.01077463173866272</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=10/recall_at_1</td>
      <td width="280">0.891</td>
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
      <td width="280">0.010751885652542115</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=20/recall_at_1</td>
      <td width="280">0.96</td>
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
      <td width="280">0.0160760133266449</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=30/recall_at_1</td>
      <td width="280">0.975</td>
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
      <td width="280">0.018794228315353392</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=40/recall_at_1</td>
      <td width="280">0.982</td>
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
      <td width="280">0.01697736191749573</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=50/recall_at_1</td>
      <td width="280">0.985</td>
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
      <td width="280">0.007372876644134521</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=25,refine_factor=none/recall_at_1</td>
      <td width="280">0.446</td>
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
      <td width="280">0.01027724027633667</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=1/recall_at_1</td>
      <td width="280">0.447</td>
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
      <td width="280">0.013400490283966065</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=10/recall_at_1</td>
      <td width="280">0.892</td>
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
      <td width="280">0.014154971837997436</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=20/recall_at_1</td>
      <td width="280">0.961</td>
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
      <td width="280">0.018411922693252564</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=30/recall_at_1</td>
      <td width="280">0.976</td>
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
      <td width="280">0.0176273033618927</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=40/recall_at_1</td>
      <td width="280">0.983</td>
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
      <td width="280">0.02254028844833374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=50/recall_at_1</td>
      <td width="280">0.986</td>
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
      <td width="280">0.009735166788101197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=50,refine_factor=none/recall_at_1</td>
      <td width="280">0.447</td>
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
      <td width="280">0.013492329359054565</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=1/recall_at_1</td>
      <td width="280">0.447</td>
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
      <td width="280">0.015122019290924072</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=10/recall_at_1</td>
      <td width="280">0.892</td>
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
      <td width="280">0.015415410041809081</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=20/recall_at_1</td>
      <td width="280">0.961</td>
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
      <td width="280">0.01959055757522583</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=30/recall_at_1</td>
      <td width="280">0.976</td>
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
      <td width="280">0.01988649129867554</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=40/recall_at_1</td>
      <td width="280">0.983</td>
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
      <td width="280">0.02005660581588745</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=50/recall_at_1</td>
      <td width="280">0.986</td>
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
      <td width="280">0.011492565393447876</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nprobes=75,refine_factor=none/recall_at_1</td>
      <td width="280">0.447</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
