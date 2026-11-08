# numpy 2.4.3 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`42485778506-1`

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
      <td width="1200">2.4.3</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">2.4.3</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-08T13:43:02Z</td>
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
      <td width="1200">2026-11-08T13:37:10Z</td>
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
      <td width="1200">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 62453 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 140538 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 168071 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 166171 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 134701 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 159611 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169627 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 164099 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
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
      <td width="500">numpy_baseline</td>
      <td width="880">2.4.3 (289c872fc2cc3a82a63a66b4c1a32e8ef6e80fb6)</td>
    </tr>
    <tr>
      <td width="500">asv_bench</td>
      <td width="880">2.4.3 (95422b21eb5b43a2453e45b8531a3dd09c9b61ab)</td>
    </tr>
    <tr>
      <td width="500">cpython</td>
      <td width="880">3.14.10</td>
    </tr>
    <tr>
      <td width="500">asv</td>
      <td width="880">0.6.4</td>
    </tr>
  </tbody>
</table>

## 性能指标

### bench_reduce.AddReduce

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
      <td width="500">bench_reduce.AddReduce.time_axis_0</td>
      <td width="280">0.007102685980498791</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduce.time_axis_1</td>
      <td width="280">0.0037864367477595806</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_reduce.AddReduceSeparate

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
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;float32&#x27;)</td>
      <td width="280">0.0001010592095553875</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;float64&#x27;)</td>
      <td width="280">0.00017734896391630173</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int16&#x27;)</td>
      <td width="280">0.0002993578091263771</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int32&#x27;)</td>
      <td width="280">0.000290747731924057</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int64&#x27;)</td>
      <td width="280">0.00014248909428715706</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;float32&#x27;)</td>
      <td width="280">0.00016549881547689438</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;float64&#x27;)</td>
      <td width="280">0.0001725992187857628</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int16&#x27;)</td>
      <td width="280">0.0003050980158150196</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int32&#x27;)</td>
      <td width="280">0.0002958988770842552</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int64&#x27;)</td>
      <td width="280">0.00015405891463160515</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_reduce.AnyAll

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
      <td width="500">bench_reduce.AnyAll.time_all_fast</td>
      <td width="280">1.0901130735874176e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_all_slow</td>
      <td width="280">2.5602057576179504e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_any_fast</td>
      <td width="280">1.0901130735874176e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_any_slow</td>
      <td width="280">2.5900080800056458e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_reduce.ArgMin

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
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;bool&#x27;&gt;)</td>
      <td width="280">2.920161932706833e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">1.4489982277154922e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">2.800021320581436e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">5.610287189483643e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">1.074979081749916e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">1.890026032924652e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">4.270114004611969e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">6.739981472492218e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">1.0939780622720718e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">2.621905878186226e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">4.169996827840805e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_reduce.FMinMax

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
      <td width="500">bench_reduce.FMinMax.time_max(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">2.0400620996952057e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.FMinMax.time_min(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">2.050306648015976e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.FMinMax.time_min(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">2.919696271419525e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_reduce.StatsReductions

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
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;bool_&#x27;)</td>
      <td width="280">1.8598511815071106e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;float32&#x27;)</td>
      <td width="280">1.9399449229240417e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;uint64&#x27;)</td>
      <td width="280">2.0400620996952057e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;bool_&#x27;)</td>
      <td width="280">1.8598511815071106e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;float32&#x27;)</td>
      <td width="280">1.9399449229240417e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;float64&#x27;)</td>
      <td width="280">1.9497238099575043e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;int64&#x27;)</td>
      <td width="280">1.979060471057892e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;uint64&#x27;)</td>
      <td width="280">2.030283212661743e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;bool_&#x27;)</td>
      <td width="280">2.219807356595993e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;float32&#x27;)</td>
      <td width="280">2.0298175513744354e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;float64&#x27;)</td>
      <td width="280">2.020038664340973e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;int64&#x27;)</td>
      <td width="280">1.9599683582782745e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;uint64&#x27;)</td>
      <td width="280">1.9902363419532776e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;bool_&#x27;)</td>
      <td width="280">9.369570761919022e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;float32&#x27;)</td>
      <td width="280">9.329989552497864e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;float64&#x27;)</td>
      <td width="280">9.319745004177094e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;int64&#x27;)</td>
      <td width="280">8.579809218645096e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;uint64&#x27;)</td>
      <td width="280">8.780043572187424e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.Broadcast

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
      <td width="500">bench_ufunc.Broadcast.time_broadcast</td>
      <td width="280">0.006169261876493692</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.CustomComparison

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
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">2.0600855350494385e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">5.290377885103226e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">1.014024019241333e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">3.119930624961853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">5.059875547885895e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">1.0249670594930649e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.0400620996952057e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">3.039836883544922e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">5.660112947225571e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">1.1430121958255768e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">2.0796433091163635e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">2.1299347281455994e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">3.769993782043457e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">6.979797035455704e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">2.8801150619983673e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">4.169996827840805e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">7.770024240016937e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.8400681912899017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">2.869870513677597e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">4.6300701797008514e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">8.74977558851242e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">2.1597370505332947e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">2.800021320581436e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">3.919936716556549e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">6.750226020812988e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">2.869870513677597e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">4.4996850192546844e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">7.909722626209259e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.8102658689022064e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">3.000255674123764e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">4.88990917801857e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">8.929986506700516e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">2.2798776626586914e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.CustomScalarFloorDivideInt

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
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, -43)</td>
      <td width="280">1.9902363419532776e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, -8)</td>
      <td width="280">1.9399449229240417e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, 43)</td>
      <td width="280">1.919921487569809e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, 8)</td>
      <td width="280">1.9599683582782745e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, -43)</td>
      <td width="280">3.2102689146995544e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, -8)</td>
      <td width="280">3.0598603188991547e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, 43)</td>
      <td width="280">3.1301751732826233e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, 8)</td>
      <td width="280">3.070104867219925e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, -43)</td>
      <td width="280">7.459893822669983e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, -8)</td>
      <td width="280">7.329974323511124e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, 43)</td>
      <td width="280">7.419846951961517e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, 8)</td>
      <td width="280">7.400289177894592e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, -43)</td>
      <td width="280">1.8398277461528778e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, -8)</td>
      <td width="280">1.8803402781486511e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, 43)</td>
      <td width="280">1.8402934074401855e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, 8)</td>
      <td width="280">1.850072294473648e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, -43)</td>
      <td width="280">7.4803829193115234e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, -8)</td>
      <td width="280">7.400289177894592e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, 43)</td>
      <td width="280">7.320195436477661e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, 8)</td>
      <td width="280">7.359776645898819e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.CustomScalarFloorDivideUInt

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
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint16&#x27;&gt;, 43)</td>
      <td width="280">1.5096738934516907e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint16&#x27;&gt;, 8)</td>
      <td width="280">1.5003606677055359e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint32&#x27;&gt;, 43)</td>
      <td width="280">2.219807356595993e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint32&#x27;&gt;, 8)</td>
      <td width="280">2.1900050342082977e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint64&#x27;&gt;, 43)</td>
      <td width="280">4.33996319770813e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint64&#x27;&gt;, 8)</td>
      <td width="280">4.319939762353897e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint8&#x27;&gt;, 43)</td>
      <td width="280">1.419801265001297e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint8&#x27;&gt;, 8)</td>
      <td width="280">1.3899989426136017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.ulonglong&#x27;&gt;, 43)</td>
      <td width="280">4.319939762353897e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.ulonglong&#x27;&gt;, 8)</td>
      <td width="280">4.359986633062363e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.MethodsV0

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
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.100162863731384e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">6.398186087608337e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">5.997717380523682e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.100162863731384e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.300397217273712e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.202608346939087e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">5.899928510189056e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">5.699694156646729e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.100162863731384e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.002373993396759e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.100162863731384e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">6.402842700481415e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">5.802139639854431e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">5.997717380523682e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.300397217273712e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.MethodsV1

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
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.003545761108398e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.296912372112274e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.798654794692993e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.901100277900696e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.901100277900696e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.798654794692993e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.203780114650726e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.296912372112274e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.096678018569946e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.003545761108398e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.203780114650726e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.501803338527679e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.688067853450775e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.003545761108398e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.096678018569946e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">1.2703239917755127e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">1.3299286365509033e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.169741153717041e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.1599622666835785e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.2097880244255066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.MethodsV1IntOnly

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
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.203780114650726e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.896443665027618e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.798654794692993e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.803311407566071e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.901100277900696e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.NDArrayGetItem

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
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((-1, 0), &#x27;big&#x27;)</td>
      <td width="280">3.702007234096527e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((-1, 0), &#x27;small&#x27;)</td>
      <td width="280">3.702007234096527e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((0, 0), &#x27;big&#x27;)</td>
      <td width="280">4.2980536818504333e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((0, 0), &#x27;small&#x27;)</td>
      <td width="280">4.00003045797348e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem(0, &#x27;big&#x27;)</td>
      <td width="280">3.902241587638855e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem(0, &#x27;small&#x27;)</td>
      <td width="280">4.00003045797348e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem([0, -1], &#x27;big&#x27;)</td>
      <td width="280">1.700129359960556e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem([0, -1], &#x27;small&#x27;)</td>
      <td width="280">1.7099082469940186e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.NDArrayLRShifts

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
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.2097880244255066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.269858330488205e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.300126314163208e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int8&#x27;)</td>
      <td width="280">1.1301599442958832e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;intp&#x27;)</td>
      <td width="280">1.2898817658424377e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint16&#x27;)</td>
      <td width="280">1.2102536857128143e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint32&#x27;)</td>
      <td width="280">1.2703239917755127e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint64&#x27;)</td>
      <td width="280">1.3397075235843658e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint8&#x27;)</td>
      <td width="280">1.1799857020378113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.2898817658424377e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.2600794434547424e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.3499520719051361e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int8&#x27;)</td>
      <td width="280">1.200009137392044e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;intp&#x27;)</td>
      <td width="280">1.3201497495174408e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint16&#x27;)</td>
      <td width="280">1.2600794434547424e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint32&#x27;)</td>
      <td width="280">1.2400560081005096e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint64&#x27;)</td>
      <td width="280">1.3499520719051361e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint8&#x27;)</td>
      <td width="280">1.1599622666835785e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.NDArraySetItem

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
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((-1, 0), &#x27;big&#x27;)</td>
      <td width="280">4.00003045797348e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((-1, 0), &#x27;small&#x27;)</td>
      <td width="280">2.9010698199272156e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((0, 0), &#x27;big&#x27;)</td>
      <td width="280">4.00003045797348e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((0, 0), &#x27;small&#x27;)</td>
      <td width="280">2.6030465960502625e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem(0, &#x27;big&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem(0, &#x27;small&#x27;)</td>
      <td width="280">2.598389983177185e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem([0, -1], &#x27;big&#x27;)</td>
      <td width="280">2.100132405757904e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem([0, -1], &#x27;small&#x27;)</td>
      <td width="280">2.798624336719513e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc.UFunc

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
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;absolute&#x27;)</td>
      <td width="280">4.1740015149116516e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_and&#x27;)</td>
      <td width="280">1.4839228242635727e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_count&#x27;)</td>
      <td width="280">2.2099819034337997e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_not&#x27;)</td>
      <td width="280">9.378883987665176e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_or&#x27;)</td>
      <td width="280">1.4670193195343018e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_xor&#x27;)</td>
      <td width="280">1.4769844710826874e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;cbrt&#x27;)</td>
      <td width="280">5.8508943766355515e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;ceil&#x27;)</td>
      <td width="280">7.468881085515022e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;deg2rad&#x27;)</td>
      <td width="280">0.00013277912512421608</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;degrees&#x27;)</td>
      <td width="280">0.0001336401328444481</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;equal&#x27;)</td>
      <td width="280">7.670978084206581e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;exp2&#x27;)</td>
      <td width="280">0.0009748437441885471</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fabs&#x27;)</td>
      <td width="280">0.00016481894999742508</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;floor&#x27;)</td>
      <td width="280">7.54399225115776e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;floor_divide&#x27;)</td>
      <td width="280">0.0002566678449511528</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fmax&#x27;)</td>
      <td width="280">0.0001005600206553936</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fmin&#x27;)</td>
      <td width="280">0.00010202918201684952</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;greater&#x27;)</td>
      <td width="280">8.436013013124466e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;greater_equal&#x27;)</td>
      <td width="280">8.314009755849838e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;invert&#x27;)</td>
      <td width="280">9.200070053339005e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isfinite&#x27;)</td>
      <td width="280">5.34597784280777e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isinf&#x27;)</td>
      <td width="280">5.288003012537956e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isnan&#x27;)</td>
      <td width="280">5.058012902736664e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isnat&#x27;)</td>
      <td width="280">2.0023435354232788e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;left_shift&#x27;)</td>
      <td width="280">1.5120021998882294e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;less&#x27;)</td>
      <td width="280">8.29789787530899e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;less_equal&#x27;)</td>
      <td width="280">8.411984890699387e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;log2&#x27;)</td>
      <td width="280">0.0010964442044496536</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_and&#x27;)</td>
      <td width="280">0.00012119906023144722</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_not&#x27;)</td>
      <td width="280">6.906921043992043e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_or&#x27;)</td>
      <td width="280">0.00010770978406071663</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_xor&#x27;)</td>
      <td width="280">0.00012379931285977364</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;minimum&#x27;)</td>
      <td width="280">9.793974459171295e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;negative&#x27;)</td>
      <td width="280">6.558001041412354e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;positive&#x27;)</td>
      <td width="280">7.930910214781761e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;rad2deg&#x27;)</td>
      <td width="280">0.00013301894068717957</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;radians&#x27;)</td>
      <td width="280">0.0001333090476691723</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;reciprocal&#x27;)</td>
      <td width="280">0.00013506924733519554</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;right_shift&#x27;)</td>
      <td width="280">1.5190336853265762e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;rint&#x27;)</td>
      <td width="280">0.00011503929272294044</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;true_divide&#x27;)</td>
      <td width="280">0.00015792902559041977</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;trunc&#x27;)</td>
      <td width="280">7.573002949357033e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc_strides.BinaryFP

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
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002920478582382202</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00013437867164611816</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005976958200335503</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00045081693679094315</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013719219714403152</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00048240693286061287</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016318499110639095</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00040475791320204735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002087697386741638</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008749938569962978</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002319064922630787</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010548029094934464</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00060291588306427</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003926381468772888</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0012013120576739311</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008636447601020336</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0016892491839826107</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.000878515187650919</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0019895178265869617</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007825451903045177</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0023360359482467175</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012902719900012016</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002513654064387083</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014305212534964085</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002856277860701084</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00013453885912895203</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005621267482638359</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004506469704210758</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013709720224142075</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00048469798639416695</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016490300185978413</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004182984121143818</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002122987061738968</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0009002252481877804</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0023129358887672424</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010621137917041779</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006482256576418877</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00040359795093536377</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001205342821776867</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008634547702968121</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0016511501744389534</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008774637244641781</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0019699479453265667</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007763649336993694</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0023331749252974987</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012686722911894321</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0025239940732717514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014599612914025784</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005686967633664608</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004468369297683239</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013939808122813702</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0004808371886610985</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016156099736690521</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004087379202246666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002095567062497139</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000933885108679533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002314794808626175</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001063093077391386</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007115448825061321</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000413358211517334</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001226021908223629</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008620037697255611</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001705000177025795</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008831950835883617</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.002000608015805483</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000776585191488266</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0023811860010027885</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012799520045518875</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0026739039458334446</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014835209585726261</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002945377491414547</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00013987859711050987</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.000578826293349266</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00045241694897413254</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.00141157116740942</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0004784967750310898</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016154698096215725</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00040539680048823357</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002090528141707182</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008832649327814579</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0022714859806001186</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010712342336773872</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007102862000465393</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00042386725544929504</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0012424029409885406</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008711647242307663</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0016846098005771637</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008765538223087788</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.002043277956545353</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007822453044354916</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0023692757822573185</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012667528353631496</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0025626239366829395</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014824909158051014</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004905466921627522</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003678780049085617</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008493252098560333</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008391952142119408</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001383940689265728</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008414052426815033</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016711601056158543</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000729304738342762</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002163077238947153</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011955620720982552</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024338350631296635</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00123654305934906</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000486746896058321</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00036810804158449173</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008471147157251835</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008380450308322906</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001396232284605503</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008400650694966316</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016910689882934093</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007287650369107723</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002150577027350664</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001191343180835247</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024555549025535583</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012634419836103916</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004897173494100571</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003684479743242264</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008478150703012943</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008394941687583923</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013887220993638039</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008410238660871983</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016736900433897972</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007286248728632927</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002141767181456089</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011941730044782162</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024596350267529488</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00123504176735878</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004894770681858063</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00036871712654829025</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008451240137219429</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008386247791349888</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001392832025885582</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008424348197877407</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016600401140749454</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007276050746440887</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021439669653773308</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011919629760086536</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002504854928702116</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001239921897649765</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008647250942885876</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008372548036277294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001380720641463995</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008385949768126011</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017373589798808098</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007483148947358131</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002197297289967537</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012285229749977589</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024783750995993614</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012656822800636292</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006286459974944592</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00039546703919768333</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008819242939352989</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008371151052415371</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0014381008222699165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008383649401366711</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017243600450456142</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000759664922952652</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021878271363675594</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012268428690731525</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002524404786527157</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012763720005750656</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006270860321819782</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00039555784314870834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008694948628544807</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008362950757145882</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013990923762321472</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008384138345718384</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017169201746582985</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007496359758079052</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021952870301902294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012147626839578152</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002514745108783245</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012656222097575665</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006272359751164913</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00039700698107481003</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008668247610330582</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008382750675082207</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0014148210175335407</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008404147811233997</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017618290148675442</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007501058280467987</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0022011571563780308</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001219733152538538</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024799248203635216</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012679621577262878</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc_strides.BinaryInt

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
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.268903285264969e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.317937418818474e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">3.3460091799497604e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">4.1190069168806076e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.245992749929428e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">4.2910221964120865e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">4.241010174155235e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">3.3659860491752625e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">4.129018634557724e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">4.090974107384682e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.2499974370002747e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.117004573345184e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">3.3488962799310684e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">4.188995808362961e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.184897989034653e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">4.290882498025894e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">4.165014252066612e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">3.342004492878914e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">4.2248982936143875e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">4.2140018194913864e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.2990315705537796e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.2100436985492706e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">3.647897392511368e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">4.930002614855766e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.931958392262459e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">4.301872104406357e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">4.2419880628585815e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">3.599002957344055e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">4.9180351197719574e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">4.914868623018265e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">4.251999780535698e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">4.114024341106415e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.382004797458649e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.1599851101636887e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.150019958615303e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">4.298985004425049e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">4.17390838265419e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.418978303670883e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.237005487084389e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.2010098695755005e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.2689964175224304e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.218006506562233e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">3.639981150627136e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">4.9029942601919174e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.92301769554615e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">4.329020157456398e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">4.210928454995155e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">3.630993887782097e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">4.938989877700806e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">4.913005977869034e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.3040141463279724e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.150019958615303e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">3.5929959267377853e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">5.092984065413475e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.927022382616997e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">4.329998046159744e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">4.1389837861061096e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">3.5999808460474014e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">4.8998743295669556e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">4.905974492430687e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.287995398044586e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.366040229797363e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">3.603985533118248e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">5.829986184835434e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">5.894014611840248e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">4.3289270251989365e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">4.400033503770828e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">3.663916140794754e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">5.8209989219903946e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">5.825003609061241e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">4.480127245187759e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">8.23894515633583e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.6650184988975525e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.92300246655941e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.9259826987981796e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">4.569999873638153e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">8.150003850460052e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.621013507246971e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.9330141842365265e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.935994416475296e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.2640138417482376e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.218006506562233e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">3.3400021493434906e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">4.121987149119377e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.122033715248108e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">4.292000085115433e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">4.230998456478119e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">3.3908989280462265e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">4.1750259697437286e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">4.101032391190529e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.254002124071121e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.10890206694603e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">3.520911559462547e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">4.220008850097656e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.202965646982193e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">4.308996722102165e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">4.14801761507988e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">3.400025889277458e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">4.366878420114517e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">4.1919760406017303e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.2829662561416626e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.2350031435489655e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">3.728969022631645e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">4.932982847094536e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.9170106649398804e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">4.303036257624626e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">4.2289961129426956e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">3.550993278622627e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">4.914030432701111e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">4.9179885536432266e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">4.2658764868974686e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">4.1180290281772614e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.466010093688965e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.344014450907707e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.294980317354202e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">4.2879022657871246e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">4.115886986255646e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.542006015777588e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.165899008512497e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.202965646982193e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.291906952857971e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.205899313092232e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">3.6079902201890945e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">4.936009645462036e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.927022382616997e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">4.335865378379822e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">4.24189493060112e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">3.805896267294884e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">4.9180351197719574e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">4.921993240714073e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.274025559425354e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.2858999222517014e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">3.5068951547145844e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">4.952913150191307e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.9190130084753036e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">4.346994683146477e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">4.1789840906858444e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">3.6230310797691345e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">4.942016676068306e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">4.937034100294113e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.2759813368320465e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.383036866784096e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">3.624986857175827e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">5.8480072766542435e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">5.824025720357895e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">4.317006096243858e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">4.359893500804901e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">3.6349985748529434e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">5.882931873202324e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">5.8459118008613586e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc_strides.BinaryIntContig

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
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.103678166866302e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1599622666835785e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.700129359960556e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.770218998193741e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.397044777870178e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.2097880244255066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.6898848116397858e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.769753336906433e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.7902424335479736e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.299255907535553e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.200009137392044e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7201527953147888e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.7599744498729706e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.7599744498729706e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.099021553993225e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.1902302503585815e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.6996636986732483e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.8298236429691315e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.800021320581436e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.201467037200928e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.169741153717041e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.700129359960556e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.7497299015522003e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.8102658689022064e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.401701390743256e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.1599622666835785e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7299316823482513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.7599744498729706e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.819579094648361e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.299255907535553e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1599622666835785e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7201527953147888e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.8400681912899017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.739951014518738e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.401701390743256e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.1799857020378113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7299316823482513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.750195562839508e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.7902424335479736e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8598511815071106e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.6102567315101624e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.819804310798645e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.9797665774822235e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.050081431865692e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8300488591194153e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5296973288059235e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.769978553056717e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.0100345611572266e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.0403025448322296e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.201467037200928e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1399388313293457e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.6600824892520905e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.039836883544922e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.9802322387695312e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.601935744285583e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.1399388313293457e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.6498379409313202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.969987690448761e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.939719706773758e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.997747838497162e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1599622666835785e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.4798715710639954e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.5103799998760223e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.419576048851013e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.797513484954834e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.1599622666835785e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.519918441772461e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.469867467880249e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.4102628231048584e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.499490261077881e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1702068150043488e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.5902332961559296e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.949964255094528e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.9997900128364563e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.499490261077881e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.150183379650116e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.6400590538978577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.9802322387695312e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.9597431421279907e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.299255907535553e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1799857020378113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7201527953147888e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.0100345611572266e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.0798837542533875e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.499490261077881e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.2796372175216675e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.6898848116397858e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.0603259801864624e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.119930624961853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8402934074401855e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.519918441772461e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.769978553056717e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.9900111258029938e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.0100345611572266e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8700957298278809e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.6796402633190155e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7900019884109497e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.070104867219925e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.0403025448322296e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.099021553993225e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.200009137392044e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.6898848116397858e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.9099173843860626e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.103678166866302e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.2796372175216675e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7099082469940186e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.8098002076148987e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.7902424335479736e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.319684088230133e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5301629900932312e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.8700957298278809e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.6901252567768097e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.7203932404518127e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3401731848716736e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5497207641601562e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.8901191651821136e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.7101486921310425e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.669636160135269e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3099052011966705e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5101395547389984e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.950189471244812e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.670101821422577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.6901252567768097e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3201497495174408e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.519918441772461e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.919921487569809e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.6901252567768097e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.6798807084560394e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3499520719051361e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5399418771266937e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.919921487569809e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.650078386068344e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.6598572731018066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.400243490934372e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5101395547389984e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.950189471244812e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.650078386068344e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.7096830308437347e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.5399418771266937e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5101395547389984e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.8803402781486511e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.6901252567768097e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.6798807084560394e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3299286365509033e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.550186425447464e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.9101426005363464e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.6901252567768097e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.6901252567768097e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.9799917936325073e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.8202699720859528e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.9599683582782745e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.9401853680610657e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.9401853680610657e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.9799917936325073e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.8398277461528778e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.9399449229240417e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.8796494007110596e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.8801150619983673e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3401731848716736e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.4798715710639954e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.8798746168613434e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.9299408197402954e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.88989394903183e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.6498379409313202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5101395547389984e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.8998980522155762e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.8600916266441345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.8600916266441345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3401731848716736e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.4700926840305328e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7499551177024841e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.6999041438102722e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.6598572731018066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3601966202259064e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.4798715710639954e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7802231013774872e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.639833837747574e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.7096830308437347e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3797543942928314e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5096738934516907e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.8402934074401855e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.8298236429691315e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.8298236429691315e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3201497495174408e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.4896504580974579e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.8402934074401855e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.9099173843860626e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.8801150619983673e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3499520719051361e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5399418771266937e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.8798746168613434e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.8600916266441345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.8102658689022064e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.369975507259369e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5599653124809265e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.950189471244812e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.8498470783233643e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.850312739610672e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">2.0097941160202026e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.8398277461528778e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.9101426005363464e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.8498470783233643e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.869870513677597e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">2.0400620996952057e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.8598511815071106e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.020038664340973e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.949964255094528e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.019813448190689e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.369975507259369e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5189871191978455e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.919921487569809e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.670101821422577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.7599744498729706e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3299286365509033e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5301629900932312e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.919921487569809e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.6598572731018066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.670101821422577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc_strides.UnaryFP

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
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00027707871049642563</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005462169647216797</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002807183191180229</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00028587784618139267</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005471264012157917</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002809385769069195</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00028126779943704605</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005471971817314625</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002719089388847351</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00029257824644446373</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.000542796216905117</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002797478809952736</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0001809387467801571</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">4.578009247779846e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.186930790543556e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002783993259072304</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00036658765748143196</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002727680839598179</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007975148037075996</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00036652805283665657</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002114987000823021</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010288744233548641</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00036919768899679184</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027753785252571106</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010184338316321373</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00034115836024284363</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00033437786623835564</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013190717436373234</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.018770324997603893</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000641165766865015</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.002453115303069353</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.018783335108309984</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0009261439554393291</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0028911633417010307</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.01876490470021963</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011747428216040134</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00018330896273255348</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0046270121820271015</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.461019024252892e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002943379804491997</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004618771839886904</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027230894193053246</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007998249493539333</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0046294922940433025</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021118903532624245</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010490831919014454</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004630882292985916</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002779681235551834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013637109659612179</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004871940240263939</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013611824251711369</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00136207090690732</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004877530038356781</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013613421469926834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014097122475504875</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004868110176175833</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001360171940177679</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0014621210284531116</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004864699672907591</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013619917444884777</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001363131683319807</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004620851017534733</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013614017516374588</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001361371949315071</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004619800951331854</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013606022112071514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014085010625422</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0046211411245167255</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013630022294819355</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0014703408814966679</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004625512287020683</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013604611158370972</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007116449996829033</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00019870931282639503</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00025272928178310394</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0009935637935996056</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005440516863018274</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005797473713755608</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0020137480460107327</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005439586937427521</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006696661002933979</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0024160947650671005</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0054436069913208485</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0010224930010735989</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013633319176733494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004624051973223686</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013607917353510857</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021771062165498734</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005435657221823931</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.002174186985939741</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.002180656883865595</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0046237618662416935</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013610310852527618</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021859370172023773</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0046255020424723625</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013606310822069645</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0001849588006734848</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005436326842755079</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.478900417685509e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002785883843898773</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00544017693027854</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002731787972152233</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007989946752786636</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005438916850835085</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021191919222474098</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010278141126036644</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0054403068497776985</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00028165802359580994</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0008916649967432022</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00022904900833964348</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002629077062010765</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001193671952933073</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005716335028409958</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005783159285783768</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0022993851453065872</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0057231648825109005</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007860050536692142</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0027237338945269585</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005715665407478809</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0010631443001329899</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0005776570178568363</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0013629919849336147</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006266660057008266</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006324560381472111</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0013589318841695786</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005884259007871151</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006660460494458675</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0013628019951283932</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006316658109426498</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007113763131201267</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0013605118729174137</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005993973463773727</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0001915888860821724</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005430672317743301</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">9.067915380001068e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005616070702672005</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005469769239425659</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005601560696959496</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014479910023510456</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005439571104943752</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00040122726932168007</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010838131420314312</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005447166040539742</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004338780418038368</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002727080136537552</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005479371175169945</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00027233874425292015</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002766689285635948</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005484367720782757</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00028313789516687393</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0009532440453767776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005434867925941944</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00027988897636532784</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010540629737079144</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005479971878230572</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002756579779088497</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013618809171020985</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004626271314918995</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013593919575214386</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001360301859676838</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004621472209692001</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013600615784525871</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001409952063113451</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0046212319284677505</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013596918433904648</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0014621010050177574</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004624502267688513</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013619312085211277</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013652420602738857</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004870350006967783</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00136196194216609</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013617421500384808</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004876701161265373</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013620718382298946</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001442180946469307</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0048738201148808</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013710209168493748</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0014597410336136818</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004865890368819237</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013620317913591862</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006775259971618652</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0038097472861409187</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020711775869131088</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006535360589623451</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0038083060644567013</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002792077139019966</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0008013350889086723</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0038113868795335293</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021982938051223755</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010534138418734074</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003811516799032688</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027724774554371834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000183038879185915</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.008711296133697033</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.292915299534798e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002835080958902836</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00871804729104042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027345819398760796</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0008223750628530979</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.008736676070839167</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021126912906765938</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010309242643415928</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.008723475970327854</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002779979258775711</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00019248900935053825</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004622091073542833</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.511915802955627e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00027892831712961197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005436696112155914</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002727983519434929</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0008039246313273907</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005446017254143953</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002253190614283085</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001039964146912098</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004627722315490246</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027825916185975075</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### bench_ufunc_strides.UnaryFPSpecial

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
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002819579094648361</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005420767702162266</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002719378098845482</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002837381325662136</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005423869006335735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00028292788192629814</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002848678268492222</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005467860028147697</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002829991281032562</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002831290476024151</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005470570176839828</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027880771085619926</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00018431805074214935</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">4.5740045607089996e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.175894618034363e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00027827778831124306</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0003667478449642658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002728779800236225</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0008049248717725277</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003669080324470997</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00022171763703227043</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001043303869664669</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0003692083992063999</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002777981571853161</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010294131934642792</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003430279903113842</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00033354759216308594</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001322742085903883</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.01219026604667306</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006410563364624977</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0024510747753083706</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.012348983902484179</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0009324550628662109</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0029642716981470585</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.012247545178979635</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011752629652619362</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00018249917775392532</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00522652780637145</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">9.150896221399307e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.000284567940980196</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005228437948971987</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002728779800236225</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000816594809293747</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005227548070251942</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021378882229328156</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010675536468625069</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005229548085480928</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002855979837477207</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017220093868672848</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017670131754130125</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0017222389578819275</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017224391922354698</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017685811035335064</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0017254301346838474</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017534904181957245</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017692212015390396</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0017235400155186653</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001794768963009119</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017709562089294195</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0017272192053496838</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017259689047932625</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017729192040860653</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0017234589904546738</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001648319885134697</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.01770257204771042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0016665398143231869</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001698940061032772</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017702800687402487</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0017013601027429104</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001786768902093172</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017696240916848183</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0017372802831232548</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0021008681505918503</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0008758250623941422</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013917908072471619</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0026636337861418724</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0058716642670333385</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.002229626290500164</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.004271893762052059</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005919293034821749</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.002048347145318985</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.004162263590842485</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005877053830772638</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0026677041314542294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013663619756698608</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005274987779557705</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013621612451970577</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013605221174657345</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005611935630440712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013615922071039677</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0021852469071745872</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005301377736032009</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0021755769848823547</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002191436942666769</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005607375875115395</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.002180047333240509</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00018065888434648514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0058232638984918594</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.202996104955673e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00027762865647673607</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005659355781972408</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002728886902332306</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0008114050142467022</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005821714177727699</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002109389752149582</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010419031605124474</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005499326158314943</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002775588072836399</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0022468166425824165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0013234317302703857</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001311042346060276</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002591694239526987</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006367910653352737</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013571321032941341</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0038057370111346245</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0063097719103097916</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0017052702605724335</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.004153415095061064</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006316320970654488</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001979548018425703</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016717100515961647</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017706402111798525</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016647200100123882</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001650140155106783</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.01770096179097891</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0016689100302755833</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001747718546539545</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017705552279949188</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016839602030813694</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017289998941123486</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017698312178254128</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0016652001067996025</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016748500056564808</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.01769652171060443</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016723903827369213</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015666498802602291</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.01769187208265066</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0016752197407186031</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017201690934598446</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.01769473124295473</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016864989884197712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017354488372802734</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.01769187208265066</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0016837702132761478</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0018600593321025372</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.01709386520087719</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006339163519442081</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020240582525730133</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017135105095803738</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008705551736056805</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0019247783347964287</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017199045047163963</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007193759083747864</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002139326650649309</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017126545310020447</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0010417629964649677</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00018216902390122414</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006075533106923103</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.17389227449894e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002928576432168484</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006060831714421511</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002726181410253048</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007873950526118279</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006395981181412935</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021611899137496948</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010403040796518326</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006111042574048042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002789590507745743</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00018082931637763977</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005325156729668379</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.171005174517632e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00027919793501496315</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005335547029972076</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027262838557362556</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007855049334466457</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0054992372170090675</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00022026896476745605</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010374132543802261</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005667455028742552</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002927379682660103</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_reduce3.AddReduce

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
      <td width="500">aggregate_950.bench_reduce3.AddReduce.time_aggregate</td>
      <td width="280">0.021331059280782938</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_reduce3.AnyAll

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
      <td width="500">aggregate_950.bench_reduce3.AnyAll.time_aggregate</td>
      <td width="280">0.0030236910097301006</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_reduce3.Argmin

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
      <td width="500">aggregate_950.bench_reduce3.Argmin.time_aggregate</td>
      <td width="280">0.004872680176049471</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_reduce3.Max

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
      <td width="500">aggregate_950.bench_reduce3.Max.time_aggregate</td>
      <td width="280">0.003285279031842947</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_reduce3.Min

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
      <td width="500">aggregate_950.bench_reduce3.Min.time_aggregate</td>
      <td width="280">0.005758164916187525</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_reduce3.Prod

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
      <td width="500">aggregate_950.bench_reduce3.Prod.time_aggregate</td>
      <td width="280">0.003984146285802126</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_reduce3.Var

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
      <td width="500">aggregate_950.bench_reduce3.Var.time_aggregate</td>
      <td width="280">0.004918590188026428</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Abs

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
      <td width="500">aggregate_950.bench_ufunc3.Abs.time_aggregate</td>
      <td width="280">0.11064379196614027</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Add

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
      <td width="500">aggregate_950.bench_ufunc3.Add.time_aggregate</td>
      <td width="280">0.01749900309368968</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Bitwise

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
      <td width="500">aggregate_950.bench_ufunc3.Bitwise.time_aggregate</td>
      <td width="280">0.05386797012761235</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.BitwiseCount

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
      <td width="500">aggregate_950.bench_ufunc3.BitwiseCount.time_aggregate</td>
      <td width="280">2.253009006381035e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Broadcast

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
      <td width="500">aggregate_950.bench_ufunc3.Broadcast.time_aggregate</td>
      <td width="280">0.006015223916620016</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Cbrt

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
      <td width="500">aggregate_950.bench_ufunc3.Cbrt.time_aggregate</td>
      <td width="280">0.12335429480299354</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Ceil

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
      <td width="500">aggregate_950.bench_ufunc3.Ceil.time_aggregate</td>
      <td width="280">0.06311255367472768</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Comparison

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
      <td width="500">aggregate_950.bench_ufunc3.Comparison.time_aggregate</td>
      <td width="280">0.042119752150028944</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Deg

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
      <td width="500">aggregate_950.bench_ufunc3.Deg.time_aggregate</td>
      <td width="280">0.2669428652152419</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Exp2

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
      <td width="500">aggregate_950.bench_ufunc3.Exp2.time_aggregate</td>
      <td width="280">0.07494405098259449</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Floor

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
      <td width="500">aggregate_950.bench_ufunc3.Floor.time_aggregate</td>
      <td width="280">0.06629311433061957</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.FloorDivide

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
      <td width="500">aggregate_950.bench_ufunc3.FloorDivide.time_aggregate</td>
      <td width="280">0.013037760276347399</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Fmax

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
      <td width="500">aggregate_950.bench_ufunc3.Fmax.time_aggregate</td>
      <td width="280">0.15861097862944007</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Fmin

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
      <td width="500">aggregate_950.bench_ufunc3.Fmin.time_aggregate</td>
      <td width="280">0.1582345711067319</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Getitem

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
      <td width="500">aggregate_950.bench_ufunc3.Getitem.time_aggregate</td>
      <td width="280">0.002681152895092964</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Invert

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
      <td width="500">aggregate_950.bench_ufunc3.Invert.time_aggregate</td>
      <td width="280">9.609851986169815e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Is

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
      <td width="500">aggregate_950.bench_ufunc3.Is.time_aggregate</td>
      <td width="280">0.0031192810274660587</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Log2

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
      <td width="500">aggregate_950.bench_ufunc3.Log2.time_aggregate</td>
      <td width="280">0.0769563177600503</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Logical

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
      <td width="500">aggregate_950.bench_ufunc3.Logical.time_aggregate</td>
      <td width="280">0.06007406208664179</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Minimum

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
      <td width="500">aggregate_950.bench_ufunc3.Minimum.time_aggregate</td>
      <td width="280">0.20843535289168358</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Mul

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
      <td width="500">aggregate_950.bench_ufunc3.Mul.time_aggregate</td>
      <td width="280">0.015372176188975573</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Neg

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
      <td width="500">aggregate_950.bench_ufunc3.Neg.time_aggregate</td>
      <td width="280">0.027809590101242065</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Pos

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
      <td width="500">aggregate_950.bench_ufunc3.Pos.time_aggregate</td>
      <td width="280">0.024308381136506796</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Rad

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
      <td width="500">aggregate_950.bench_ufunc3.Rad.time_aggregate</td>
      <td width="280">0.26270728139206767</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Reciprocal

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
      <td width="500">aggregate_950.bench_ufunc3.Reciprocal.time_aggregate</td>
      <td width="280">0.1283928332850337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Rint

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
      <td width="500">aggregate_950.bench_ufunc3.Rint.time_aggregate</td>
      <td width="280">0.0833625397644937</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Setitem

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
      <td width="500">aggregate_950.bench_ufunc3.Setitem.time_aggregate</td>
      <td width="280">0.001645709853619337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Shift

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
      <td width="500">aggregate_950.bench_ufunc3.Shift.time_aggregate</td>
      <td width="280">0.042294621001929045</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Sub

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
      <td width="500">aggregate_950.bench_ufunc3.Sub.time_aggregate</td>
      <td width="280">0.017575721722096205</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Truediv

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
      <td width="500">aggregate_950.bench_ufunc3.Truediv.time_aggregate</td>
      <td width="280">0.0041199647821486</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc3.Trunc

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
      <td width="500">aggregate_950.bench_ufunc3.Trunc.time_aggregate</td>
      <td width="280">0.0651991106569767</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc_strides3.Maximum

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
      <td width="500">aggregate_950.bench_ufunc_strides3.Maximum.time_aggregate</td>
      <td width="280">0.2296150028705597</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aggregate_950.bench_ufunc_strides3.OnesLike

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
      <td width="500">aggregate_950.bench_ufunc_strides3.OnesLike.time_aggregate</td>
      <td width="280">0.049395367968827486</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
