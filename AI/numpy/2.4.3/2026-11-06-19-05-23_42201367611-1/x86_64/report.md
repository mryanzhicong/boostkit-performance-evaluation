# numpy 2.4.3 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`42201367611-1`

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
      <td width="1200">2026-11-06T10:25:19Z</td>
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
      <td width="1200">2026-11-06T10:17:00Z</td>
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
      <td width="1200">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 92046 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 152584 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 168863 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 154978 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 136732 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 161804 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169565 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 165317 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
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
      <td width="280">0.007102456875145435</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduce.time_axis_1</td>
      <td width="280">0.0038087470456957817</td>
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
      <td width="280">9.69800166785717e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;float64&#x27;)</td>
      <td width="280">0.00017959903925657272</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int16&#x27;)</td>
      <td width="280">0.00029931822791695595</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int32&#x27;)</td>
      <td width="280">0.0002846280112862587</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int64&#x27;)</td>
      <td width="280">0.0001316792331635952</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;float32&#x27;)</td>
      <td width="280">0.00016527902334928513</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;float64&#x27;)</td>
      <td width="280">0.00017281901091337204</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int16&#x27;)</td>
      <td width="280">0.0003054584376513958</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int32&#x27;)</td>
      <td width="280">0.0002921079285442829</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int64&#x27;)</td>
      <td width="280">0.00014656875282526016</td>
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
      <td width="280">1.080334186553955e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_all_slow</td>
      <td width="280">2.54996120929718e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_any_fast</td>
      <td width="280">1.1101365089416504e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_any_slow</td>
      <td width="280">2.519693225622177e-06</td>
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
      <td width="280">2.88989394903183e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">1.3350043445825577e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">2.584978938102722e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">5.3998082876205444e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">1.046992838382721e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">2.6910100132226944e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">4.299916326999664e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">6.8498775362968445e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">1.049041748046875e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">1.8829945474863052e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">4.200264811515808e-06</td>
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
      <td width="280">2.0498409867286682e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.FMinMax.time_min(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">2.089887857437134e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.FMinMax.time_min(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">2.8903596103191376e-06</td>
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
      <td width="280">1.9101426005363464e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;float32&#x27;)</td>
      <td width="280">2.0298175513744354e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;uint64&#x27;)</td>
      <td width="280">2.020038664340973e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;bool_&#x27;)</td>
      <td width="280">1.8803402781486511e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;float32&#x27;)</td>
      <td width="280">1.9301660358905792e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;float64&#x27;)</td>
      <td width="280">2.020038664340973e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;int64&#x27;)</td>
      <td width="280">1.9301660358905792e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;uint64&#x27;)</td>
      <td width="280">1.970212906599045e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;bool_&#x27;)</td>
      <td width="280">2.2598542273044586e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;float32&#x27;)</td>
      <td width="280">2.0400620996952057e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;float64&#x27;)</td>
      <td width="280">2.0703300833702087e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;int64&#x27;)</td>
      <td width="280">2.0400620996952057e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;uint64&#x27;)</td>
      <td width="280">2.0102597773075104e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;bool_&#x27;)</td>
      <td width="280">9.109731763601303e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;float32&#x27;)</td>
      <td width="280">9.269919246435165e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;float64&#x27;)</td>
      <td width="280">7.760245352983475e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;int64&#x27;)</td>
      <td width="280">8.590053766965866e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;uint64&#x27;)</td>
      <td width="280">8.760020136833191e-06</td>
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
      <td width="280">0.006126403342932463</td>
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
      <td width="280">2.1299347281455994e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">4.9602240324020386e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">9.889714419841766e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">2.949964255094528e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">5.220063030719757e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">1.032976433634758e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.0801089704036713e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">3.0999071896076202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">5.550216883420944e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">1.1329539120197296e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">2.149958163499832e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">2.1401792764663696e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">3.7997961044311523e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">6.9802626967430115e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">2.869870513677597e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">4.250090569257736e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">7.870141416788101e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.820044755935669e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">2.8600916266441345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">4.5602209866046906e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">8.648727089166641e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">2.149958163499832e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">2.8400681912899017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">3.769993782043457e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">6.689690053462982e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">2.8703361749649048e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">4.299916326999664e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">8.049886673688889e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.8498470783233643e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">3.070104867219925e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">4.979781806468964e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">8.950009942054749e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">2.3101456463336945e-06</td>
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
      <td width="280">1.969747245311737e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, -8)</td>
      <td width="280">1.98977068066597e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, 43)</td>
      <td width="280">1.9399449229240417e-06</td>
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
      <td width="280">3.300141543149948e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, -8)</td>
      <td width="280">3.119930624961853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, 43)</td>
      <td width="280">3.1599774956703186e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, 8)</td>
      <td width="280">3.1301751732826233e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, -43)</td>
      <td width="280">7.4999406933784485e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, -8)</td>
      <td width="280">7.470138370990753e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, 43)</td>
      <td width="280">7.4999406933784485e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, 8)</td>
      <td width="280">7.43987038731575e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, -43)</td>
      <td width="280">1.8798746168613434e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, -8)</td>
      <td width="280">1.8798746168613434e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, 43)</td>
      <td width="280">1.889653503894806e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, 8)</td>
      <td width="280">1.8603168427944183e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, -43)</td>
      <td width="280">7.409602403640747e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, -8)</td>
      <td width="280">7.410068064928055e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, 43)</td>
      <td width="280">7.519964128732681e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, 8)</td>
      <td width="280">7.470138370990753e-06</td>
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
      <td width="280">1.5897676348686218e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint16&#x27;&gt;, 8)</td>
      <td width="280">1.5399418771266937e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint32&#x27;&gt;, 43)</td>
      <td width="280">2.2598542273044586e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint32&#x27;&gt;, 8)</td>
      <td width="280">2.3297034204006195e-06</td>
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
      <td width="280">4.339031875133514e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint8&#x27;&gt;, 43)</td>
      <td width="280">1.4398247003555298e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint8&#x27;&gt;, 8)</td>
      <td width="280">1.4500692486763e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.ulonglong&#x27;&gt;, 43)</td>
      <td width="280">4.370231181383133e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.ulonglong&#x27;&gt;, 8)</td>
      <td width="280">4.500150680541992e-06</td>
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
      <td width="280">6.50063157081604e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">6.402842700481415e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.300397217273712e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.300397217273712e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.598420441150665e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.300397217273712e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">6.295740604400635e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.300397217273712e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.300397217273712e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">5.797483026981354e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.598420441150665e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">8.898787200450897e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.095506250858307e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.19795173406601e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.402842700481415e-07</td>
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
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.702037692070007e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.702037692070007e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.604248821735382e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.799826562404633e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.497146725654602e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.69738107919693e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.897615432739258e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.497146725654602e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.702037692070007e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
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
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.501803338527679e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.501803338527679e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.501803338527679e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.497146725654602e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.799826562404633e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.497146725654602e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.69738107919693e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.404014468193054e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.799826562404633e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.604248821735382e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.702037692070007e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.296912372112274e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.296912372112274e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">1.3299286365509033e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">1.330394297838211e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.2200325727462769e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.200009137392044e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.2400560081005096e-06</td>
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
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">8.102506399154663e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
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
      <td width="280">4.302710294723511e-07</td>
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
      <td width="280">3.7997961044311523e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((0, 0), &#x27;small&#x27;)</td>
      <td width="280">3.7997961044311523e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem(0, &#x27;big&#x27;)</td>
      <td width="280">4.2980536818504333e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem(0, &#x27;small&#x27;)</td>
      <td width="280">4.0978193283081055e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem([0, -1], &#x27;big&#x27;)</td>
      <td width="280">1.7802231013774872e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem([0, -1], &#x27;small&#x27;)</td>
      <td width="280">1.7802231013774872e-06</td>
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
      <td width="280">1.2302771210670471e-06</td>
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
      <td width="280">1.269858330488205e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int8&#x27;)</td>
      <td width="280">1.1799857020378113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;intp&#x27;)</td>
      <td width="280">1.2498348951339722e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint16&#x27;)</td>
      <td width="280">1.2200325727462769e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint32&#x27;)</td>
      <td width="280">1.300126314163208e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint64&#x27;)</td>
      <td width="280">1.3499520719051361e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint8&#x27;)</td>
      <td width="280">1.1702068150043488e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.25030055642128e-06</td>
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
      <td width="280">1.3299286365509033e-06</td>
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
      <td width="280">1.3099052011966705e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint16&#x27;)</td>
      <td width="280">1.2400560081005096e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint32&#x27;)</td>
      <td width="280">1.2898817658424377e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint64&#x27;)</td>
      <td width="280">1.369975507259369e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint8&#x27;)</td>
      <td width="280">1.200009137392044e-06</td>
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
      <td width="280">3.7997961044311523e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((-1, 0), &#x27;small&#x27;)</td>
      <td width="280">2.4028122425079346e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((0, 0), &#x27;big&#x27;)</td>
      <td width="280">3.296881914138794e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((0, 0), &#x27;small&#x27;)</td>
      <td width="280">2.300366759300232e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem(0, &#x27;big&#x27;)</td>
      <td width="280">6.803311407566071e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem(0, &#x27;small&#x27;)</td>
      <td width="280">2.50060111284256e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem([0, -1], &#x27;big&#x27;)</td>
      <td width="280">1.9599683582782745e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem([0, -1], &#x27;small&#x27;)</td>
      <td width="280">2.300366759300232e-07</td>
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
      <td width="280">4.187971353530884e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_and&#x27;)</td>
      <td width="280">1.4800112694501877e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_count&#x27;)</td>
      <td width="280">2.2440217435359955e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_not&#x27;)</td>
      <td width="280">9.400304406881332e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_or&#x27;)</td>
      <td width="280">1.4720018953084946e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_xor&#x27;)</td>
      <td width="280">1.4699995517730713e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;cbrt&#x27;)</td>
      <td width="280">5.852989852428436e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;ceil&#x27;)</td>
      <td width="280">6.71599991619587e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;deg2rad&#x27;)</td>
      <td width="280">0.00013357866555452347</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;degrees&#x27;)</td>
      <td width="280">0.0001339293085038662</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;equal&#x27;)</td>
      <td width="280">7.706880569458008e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;exp2&#x27;)</td>
      <td width="280">0.0010292637161910534</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fabs&#x27;)</td>
      <td width="280">0.0001333397813141346</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;floor&#x27;)</td>
      <td width="280">6.786966696381569e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;floor_divide&#x27;)</td>
      <td width="280">0.0002500191330909729</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fmax&#x27;)</td>
      <td width="280">0.00010222988203167915</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fmin&#x27;)</td>
      <td width="280">9.960867464542389e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;greater&#x27;)</td>
      <td width="280">8.379993960261345e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;greater_equal&#x27;)</td>
      <td width="280">8.313870057463646e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;invert&#x27;)</td>
      <td width="280">9.600073099136353e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isfinite&#x27;)</td>
      <td width="280">5.328981205821037e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isinf&#x27;)</td>
      <td width="280">5.305977538228035e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isnan&#x27;)</td>
      <td width="280">5.035987123847008e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isnat&#x27;)</td>
      <td width="280">2.2025778889656067e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;left_shift&#x27;)</td>
      <td width="280">1.5280209481716156e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;less&#x27;)</td>
      <td width="280">8.341902866959572e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;less_equal&#x27;)</td>
      <td width="280">8.318014442920685e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;log2&#x27;)</td>
      <td width="280">0.0010983040556311607</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_and&#x27;)</td>
      <td width="280">0.00011877994984388351</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_not&#x27;)</td>
      <td width="280">6.930902600288391e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_or&#x27;)</td>
      <td width="280">0.00010896893218159676</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_xor&#x27;)</td>
      <td width="280">0.00012372899800539017</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;minimum&#x27;)</td>
      <td width="280">9.965011849999428e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;negative&#x27;)</td>
      <td width="280">6.572995334863663e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;positive&#x27;)</td>
      <td width="280">7.280893623828888e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;rad2deg&#x27;)</td>
      <td width="280">0.00013340869918465614</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;radians&#x27;)</td>
      <td width="280">0.00013364898040890694</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;reciprocal&#x27;)</td>
      <td width="280">0.00013342918828129768</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;right_shift&#x27;)</td>
      <td width="280">1.5620142221450806e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;rint&#x27;)</td>
      <td width="280">0.00011611869558691978</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;true_divide&#x27;)</td>
      <td width="280">0.00016200914978981018</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;trunc&#x27;)</td>
      <td width="280">7.545901462435722e-05</td>
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
      <td width="280">0.0002791779115796089</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00013118889182806015</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005927667953073978</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004436075687408447</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001356541644781828</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00047844694927334785</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0015931599773466587</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004101279191672802</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020333267748355865</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008827936835587025</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0022346959449350834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001079103909432888</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006454959511756897</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004019276238977909</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013178419321775436</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000865704845637083</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017535490915179253</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.000904143787920475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0020074881613254547</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007972661405801773</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002373575698584318</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012938729487359524</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002614073920994997</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0015175710432231426</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00027603888884186745</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00013157865032553673</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006262962706387043</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004424871876835823</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001352512277662754</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00048081716522574425</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0015924000181257725</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004071970470249653</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020202272571623325</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008811447769403458</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002208717167377472</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0011110142804682255</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006468757055699825</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003944169729948044</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0012989221140742302</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008685551583766937</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017479187808930874</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0009138239547610283</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.002023198176175356</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007917550392448902</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0024127853102982044</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013278410769999027</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0025883051566779613</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0015219911001622677</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005911961197853088</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004469272680580616</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013390318490564823</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00048170704394578934</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001560721080750227</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000406517181545496</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020102481357753277</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008798949420452118</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0022040270268917084</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001083883922547102</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007572057656943798</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00041579827666282654</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013392819091677666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008715642616152763</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017859088256955147</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0009097843430936337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00206960691139102</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007995548658072948</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002466175239533186</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013135820627212524</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0026361439377069473</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0015419903211295605</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002797376364469528</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0001385691575706005</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006002569571137428</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00045220740139484406</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013592122122645378</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0004766867496073246</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0015775500796735287</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00040333811193704605</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002009567804634571</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008803252130746841</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002246496267616749</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010920041240751743</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007578353397548199</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004190080799162388</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001350420992821455</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00086965411901474</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017909989692270756</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0009130341932177544</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0021011182107031345</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007973550818860531</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002468045335263014</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012932419776916504</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002664133906364441</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0015496709384024143</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004823473282158375</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00036705704405903816</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008504148572683334</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008497051894664764</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013916417956352234</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008440837264060974</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016434602439403534</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007311860099434853</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020705880597233772</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011964826844632626</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0023341961205005646</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012718122452497482</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00048432732000947</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003671967424452305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008496353402733803</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008385349065065384</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013733613304793835</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008414750918745995</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016777287237346172</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007283850573003292</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002184587065130472</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011956533417105675</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024424749426543713</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012558121234178543</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004849168471992016</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00036703702062368393</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008490351028740406</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008388650603592396</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001384431030601263</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008402648381888866</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016277199611067772</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007287953048944473</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002070038113743067</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011911531910300255</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0023537762463092804</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001241913065314293</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00048238690942525864</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003670467995107174</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008503049612045288</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008386853151023388</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0014005210250616074</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008418252691626549</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016796588897705078</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007280348800122738</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002180736977607012</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011923029087483883</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024615549482405186</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012488020583987236</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008702250197529793</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008384152315557003</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013840007595717907</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008392753079533577</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001658670138567686</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007483861409127712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021077566780149937</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001228442881256342</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0023939060047268867</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0013153119944036007</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000626786146312952</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00039582792669534683</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008708452805876732</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008364953100681305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013966122642159462</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008395747281610966</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017314599826931953</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007485551759600639</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0022074473090469837</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012274421751499176</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0025049648247659206</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012818421237170696</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006276858039200306</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00039688777178525925</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.000868143979460001</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008370550349354744</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0014006518758833408</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008398052304983139</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016910000704228878</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007466152310371399</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021136468276381493</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012163431383669376</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002393235918134451</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001266011968255043</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006263870745897293</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00039520813152194023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008696853183209896</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008368846029043198</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013796119019389153</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008418746292591095</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017489800229668617</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00074805598706007</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002204115968197584</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012166020460426807</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002528265118598938</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001274951733648777</td>
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
      <td width="280">4.262896254658699e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.2150262743234634e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">3.3428892493247986e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">4.097912460565567e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.098983481526375e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">4.2830128222703934e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">4.176981747150421e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">3.333901986479759e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">4.1239894926548004e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">4.106992855668068e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.2809173464775085e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.131020978093147e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">3.289012238383293e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">4.197005182504654e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.1319988667964935e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">4.330882802605629e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">4.1880179196596146e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">3.402959555387497e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">4.1460152715444565e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">4.097959026694298e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.279986023902893e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.245014861226082e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">3.363983705639839e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">4.873890429735184e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.931027069687843e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">4.31891530752182e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">4.214979708194733e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">3.3880118280649185e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">4.880037158727646e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">4.897965118288994e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">4.258984699845314e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">4.119938239455223e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.3008866012096405e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.1670165956020355e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.106014966964722e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">4.308018833398819e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">4.101032391190529e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.2349955290555954e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.102010279893875e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.0889717638492584e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.269881173968315e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.233000800013542e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">3.4320168197155e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">4.889024421572685e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.9110036343336105e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">4.3120235204696655e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">4.258006811141968e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">3.4839846193790436e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">4.893029108643532e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">4.898896440863609e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.270998761057854e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.1930004954338074e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">3.464892506599426e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">4.904903471469879e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.929909482598305e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">4.3109990656375885e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">4.205992445349693e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">3.484869375824928e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">4.9239955842494965e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">4.8980116844177246e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.2700208723545074e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.237005487084389e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">3.584008663892746e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">5.825888365507126e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">5.860021337866783e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">4.321988672018051e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">4.3079257011413574e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">3.592018038034439e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">5.8399979025125504e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">5.845027044415474e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">4.590023308992386e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">8.400063961744308e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.5180092304944992e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.787914127111435e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.763001248240471e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">4.640314728021622e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">8.109956979751587e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.5269964933395386e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.7609989047050476e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.7860049158334732e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.2549800127744675e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.1909050196409225e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">3.3120159059762955e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">4.1120219975709915e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.100985825061798e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">4.282034933567047e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">4.236912354826927e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">3.3590011298656464e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">4.124967381358147e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">4.081986844539642e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.268018528819084e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.1428953409194946e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">3.3540185540914536e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">4.168972373008728e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.111975431442261e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">4.3120235204696655e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">4.11192886531353e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">3.5050325095653534e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">4.12696972489357e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">4.100985825061798e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.2839907109737396e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.253024235367775e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">3.35201621055603e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">4.902016371488571e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.882877692580223e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">4.321988672018051e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">4.226900637149811e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">3.485893830657005e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">4.8819929361343384e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">4.900014027953148e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">4.261033609509468e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">4.125991836190224e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.2559968531131744e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.166876897215843e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.136888310313225e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">4.2939092963933945e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">4.1659921407699585e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.421911969780922e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.129018634557724e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.094885662198067e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.2700208723545074e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.243990406394005e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">3.366032615303993e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">4.8808753490448e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">4.8980116844177246e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">4.31891530752182e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">4.241010174155235e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">3.4829601645469666e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">4.887022078037262e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">4.883855581283569e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.2750034481287e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.1789840906858444e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">3.465963527560234e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">4.936009645462036e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.9250200390815735e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">4.320964217185974e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">4.180986434221268e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">3.472995012998581e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">4.907883703708649e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">4.899967461824417e-05</td>
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
      <td width="280">4.240032285451889e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">3.5390257835388184e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">5.8469828218221664e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">5.865003913640976e-05</td>
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
      <td width="280">4.238029941916466e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">3.598025068640709e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">5.845027044415474e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">5.839020013809204e-05</td>
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
      <td width="280">9.401701390743256e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.239590346813202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7299316823482513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.8596259653568268e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.8600916266441345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.499490261077881e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.2298114597797394e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7299316823482513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.8600916266441345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.800021320581436e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.401701390743256e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.2298114597797394e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7997808754444122e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.8600916266441345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.770218998193741e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.797513484954834e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.2200325727462769e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7499551177024841e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.850312739610672e-06</td>
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
      <td width="280">9.699724614620209e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.2097880244255066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7401762306690216e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.9103830456733704e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.8600916266441345e-06</td>
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
      <td width="280">1.2102536857128143e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7201527953147888e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.769753336906433e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.8796494007110596e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.601935744285583e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.2097880244255066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.719687134027481e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.770218998193741e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.299255907535553e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.2298114597797394e-06</td>
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
      <td width="280">2.88989394903183e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.8098002076148987e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.850072294473648e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5902332961559296e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7504207789897919e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.9103830456733704e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.9401853680610657e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8598511815071106e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.569744199514389e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7499551177024841e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.9602088034152985e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.9602088034152985e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.597279131412506e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1902302503585815e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.6898848116397858e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.9900111258029938e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.949964255094528e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.899958968162537e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.150183379650116e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.6801059246063232e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.9602088034152985e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.9597431421279907e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.401701390743256e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.150183379650116e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.5296973288059235e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.370215952396393e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.3799948394298553e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.699724614620209e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.1404044926166534e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.550186425447464e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.3399479687213898e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.3497268557548523e-06</td>
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
      <td width="280">1.1497177183628082e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7099082469940186e-06</td>
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
      <td width="280">2.9900111258029938e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.699724614620209e-07</td>
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
      <td width="280">1.6796402633190155e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.9602088034152985e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.9802322387695312e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.0100193321704865e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.2298114597797394e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7401762306690216e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.9797665774822235e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.0300579965114594e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.0100193321704865e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.2200325727462769e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7299316823482513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.9602088034152985e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.9797665774822235e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8598511815071106e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5702098608016968e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7299316823482513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.969987690448761e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.930406481027603e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.9297003746032715e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.669861376285553e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7597340047359467e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.000255674123764e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.070104867219925e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.597279131412506e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1897645890712738e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.730397343635559e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.8400681912899017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.820044755935669e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.397044777870178e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.2298114597797394e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.7601996660232544e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.830289304256439e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.8498470783233643e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3997778296470642e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5604309737682343e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.9399449229240417e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.6798807084560394e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.6496127247810364e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.369975507259369e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5599653124809265e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.9203871488571167e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.6798807084560394e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.6603229343891144e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.419801265001297e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5799887478351593e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.8998980522155762e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.6402994990348816e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.670101821422577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3601966202259064e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5897676348686218e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.9301660358905792e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.670101821422577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.6999041438102722e-06</td>
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
      <td width="280">1.550186425447464e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.8901191651821136e-06</td>
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
      <td width="280">2.6603229343891144e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3899989426136017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5599653124809265e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.9301660358905792e-06</td>
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
      <td width="280">2.650078386068344e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3899989426136017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.600012183189392e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.9301660358905792e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.6300549507141113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.6999041438102722e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.4798715710639954e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5599653124809265e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.919921487569809e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.6598572731018066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.6598572731018066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">2.0400620996952057e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.8700957298278809e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.919921487569809e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.750195562839508e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.7902424335479736e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">2.120155841112137e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.8901191651821136e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.8803402781486511e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.769753336906433e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.7599744498729706e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3802200555801392e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.4901161193847656e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.9203871488571167e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.9099173843860626e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.9103830456733704e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.4100223779678345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.519918441772461e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.100132405757904e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.9299408197402954e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.920161932706833e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.4100223779678345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.480337232351303e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7997808754444122e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.7497299015522003e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.670101821422577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3499520719051361e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.4789402484893799e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.8300488591194153e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.7101486921310425e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.6901252567768097e-06</td>
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
      <td width="280">1.4901161193847656e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.8803402781486511e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.9099173843860626e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.8996728360652924e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3899989426136017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.519918441772461e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.900363713502884e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.9401853680610657e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.919696271419525e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.7797574400901794e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5799887478351593e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.98977068066597e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.800021320581436e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.789776772260666e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3899989426136017e-06</td>
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
      <td width="280">1.9599683582782745e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.8098002076148987e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.019813448190689e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">2.0400620996952057e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.8798746168613434e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.8901191651821136e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.830289304256439e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.7497299015522003e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">2.089887857437134e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.8798746168613434e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.9399449229240417e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.9299408197402954e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.9001384973526e-06</td>
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
      <td width="280">1.5404075384140015e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.9399449229240417e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.650078386068344e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.7096830308437347e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3601966202259064e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.550186425447464e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.1797604858875275e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.6603229343891144e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.6901252567768097e-06</td>
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
      <td width="280">0.00027727894484996796</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005473969504237175</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00027203792706131935</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002841292880475521</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005475059151649475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027736788615584373</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00027712807059288025</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005475957877933979</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002788286656141281</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002819579094648361</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005426160059869289</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027588801458477974</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00018198927864432335</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">4.285993054509163e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.147908374667168e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00028295814990997314</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0003662882372736931</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002722390927374363</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007856353186070919</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003666677512228489</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002094777300953865</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010250541381537914</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00036782771348953247</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002769678831100464</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010049543343484402</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00034022796899080276</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00033316807821393013</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013186722062528133</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.018743086140602827</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006389073096215725</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0024573546834290028</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.018758606165647507</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0009347847662866116</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002904122229665518</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.018759487196803093</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011857328936457634</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00017667794600129128</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004622401669621468</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.169002830982208e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00028230808675289154</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004625692032277584</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027269916608929634</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007951650768518448</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004627032205462456</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002085380256175995</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010397238656878471</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00462384195998311</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002810480073094368</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013637817464768887</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004871179815381765</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001360252033919096</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013610715977847576</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004870960954576731</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013619018718600273</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014055720530450344</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004865080118179321</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013603707775473595</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001461902167648077</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0048706308007240295</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013629421591758728</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013627219013869762</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004632312338799238</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013612820766866207</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00136265205219388</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0046254610642790794</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013610320165753365</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014099609106779099</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004626251757144928</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013614310882985592</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0014574117958545685</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004627981688827276</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013622106052935123</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007205051369965076</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00019345944747328758</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002533290535211563</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0009906738996505737</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005441717337816954</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005820970982313156</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0020367479883134365</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005442266818135977</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006669857539236546</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00245244475081563</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005442716646939516</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0010267538018524647</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001362222246825695</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004624232184141874</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001359362155199051</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00136173190549016</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0046260119415819645</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013604923151433468</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014118119142949581</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004626361653208733</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001360282301902771</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0014592809602618217</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0046267518773674965</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001361682079732418</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00018014898523688316</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0046277423389256</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.174916729331017e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00027863821014761925</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004627301823347807</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027265818789601326</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007942751981317997</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004635482095181942</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021121883764863014</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010497337207198143</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004637091886252165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027824798598885536</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0008760849013924599</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00022712908685207367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00025284895673394203</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0011957832612097263</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005729155149310827</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005774772725999355</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0023216363042593002</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005727115087211132</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007859249599277973</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0027373130433261395</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00572861498221755</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0010762130841612816</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0005813571624457836</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0013624117709696293</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006320159882307053</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006387559697031975</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.001361191738396883</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005932673811912537</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006699860095977783</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.001364242285490036</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006320164538919926</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007089260034263134</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0013625524006783962</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005863872356712818</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00018301792442798615</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005468269810080528</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.535897359251976e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005566570907831192</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005425759591162205</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005655568093061447</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001462371088564396</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005472069606184959</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003945068456232548</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010557030327618122</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005477461963891983</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00042912689968943596</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00027280906215310097</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005473066121339798</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00027235783636569977</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00028461776673793793</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005477974191308022</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002731489948928356</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0009231646545231342</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.000542796216905117</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002744286321103573</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001043462660163641</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005471967160701752</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00028466759249567986</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013615922071039677</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004623851738870144</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001359542366117239</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013604117557406425</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004624892026185989</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013604220002889633</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014081108383834362</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004627502057701349</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013632811605930328</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0014569819904863834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004628241993486881</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013616420328617096</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013609318993985653</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004874379839748144</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001360141672194004</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013630818575620651</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00487109087407589</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013632620684802532</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014129821211099625</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004867479670792818</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00136150186881423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0014558807015419006</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00486963102594018</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013620518147945404</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006754258647561073</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0038096560165286064</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020479876548051834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006447862833738327</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003812056966125965</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00028174789622426033</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007773060351610184</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003814206924289465</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00022141914814710617</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010240641422569752</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003813536837697029</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000281347893178463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00017980905249714851</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.008715757168829441</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.177012205123901e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00028682779520750046</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.008722256869077682</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002727089449763298</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0008079949766397476</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.008710466790944338</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020641926676034927</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010295440442860126</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.008738297037780285</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002812780439853668</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00017748912796378136</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004623561631888151</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.188886567950249e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002789790742099285</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004626262001693249</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027384934946894646</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000792394857853651</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.004899440333247185</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021034898236393929</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010237242095172405</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004629142116755247</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00028126779943704605</td>
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
      <td width="280">0.0002782992087304592</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005491869524121284</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00027348892763257027</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002821078523993492</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005489857867360115</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027532922104001045</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00027692923322319984</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.000548176933079958</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002719191834330559</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00028177816420793533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005425172857940197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002775988541543484</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00017941929399967194</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">4.2750034481287e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.202856406569481e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00028135813772678375</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00036697695031762123</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002727392129600048</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007856353186070919</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00036700814962387085</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020857900381088257</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010245139710605145</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00036809779703617096</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027866801247000694</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010088840499520302</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003392482176423073</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003271689638495445</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013192221522331238</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.012082627043128014</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006437958218157291</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00244713481515646</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.012231064960360527</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0009279740042984486</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0028850031085312366</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.012242705561220646</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011842320673167706</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00017960881814360619</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005225928965955973</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.179014548659325e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002865283749997616</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005230617709457874</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027303770184516907</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0008003548718988895</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005223968997597694</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021237879991531372</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010316427797079086</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005223059095442295</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002806279808282852</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00167744979262352</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.01766781322658062</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001679880078881979</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017228992655873299</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017682062927633524</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0016563399694859982</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016926298849284649</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017678982112556696</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001674049999564886</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017211390659213066</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017674302216619253</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0016527199186384678</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016607302241027355</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017721562180668116</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016810102388262749</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017231600359082222</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.01772373216226697</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0017231102101504803</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017507998272776604</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.01770043233409524</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0017212890088558197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017846394330263138</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017692582216113806</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0017237388528883457</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0019483189098536968</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0008681253530085087</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013662618584930897</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0026539028622210026</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005876063834875822</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0022044070065021515</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.004049345850944519</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005875574890524149</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0021260171197354794</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.004635902121663094</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00587776442989707</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0027368427254259586</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013612410984933376</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005273138172924519</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013612019829452038</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013641123659908772</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00527693796902895</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013620024546980858</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014104307629168034</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005279997829347849</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013623107224702835</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0014554508961737156</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00527863809838891</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013634911738336086</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0001801690086722374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005327537190169096</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.190004155039787e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00028099771589040756</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005329327192157507</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027313781902194023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000793644692748785</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005332726985216141</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000209038145840168</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010405541397631168</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005331947933882475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00027908897027373314</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0022188667207956314</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0013167019933462143</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013066916726529598</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0025829337537288666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006370321847498417</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013585812412202358</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.003785486798733473</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006324081681668758</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0017246799543499947</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.004219363909214735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006316562183201313</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.002004648093134165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016704797744750977</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017711862921714783</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016881492920219898</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017228303477168083</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0176220228895545</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001669479999691248</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001685860101133585</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017697883304208517</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016755787655711174</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017131101340055466</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.01771499216556549</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001669660210609436</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0016819499433040619</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.01768202194944024</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016837399452924728</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016537397168576717</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017681392841041088</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0016713100485503674</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001692189835011959</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.01768332300707698</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016740900464355946</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017230487428605556</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0176819721236825</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001662710215896368</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0018478990532457829</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017099545802921057</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006333258934319019</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002023217733949423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.01706811599433422</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008726250380277634</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0019234279170632362</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.017113196197897196</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000715944916009903</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021391469053924084</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.017116036731749773</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0010430337861180305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00017562881112098694</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0060545639134943485</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.158991113305092e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0002812179736793041</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006062264088541269</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002727080136537552</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007934952154755592</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006122381892055273</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020719878375530243</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010348041541874409</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006124342791736126</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002779080532491207</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00017729774117469788</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005337836686521769</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">8.196011185646057e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00028555793687701225</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005336038302630186</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002728882245719433</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007880851626396179</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0053394571878015995</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020879879593849182</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0010174629278481007</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005332658067345619</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002802889794111252</td>
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
      <td width="280">0.021772346924990416</td>
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
      <td width="280">0.003075371030718088</td>
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
      <td width="280">0.004950739908963442</td>
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
      <td width="280">0.00336829898878932</td>
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
      <td width="280">0.005859544035047293</td>
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
      <td width="280">0.004066055174916983</td>
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
      <td width="280">0.004987210035324097</td>
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
      <td width="280">0.10530028119683266</td>
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
      <td width="280">0.017883821856230497</td>
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
      <td width="280">0.055474753957241774</td>
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
      <td width="280">2.2898893803358078e-05</td>
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
      <td width="280">0.006649409886449575</td>
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
      <td width="280">0.12306561321020126</td>
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
      <td width="280">0.06541522312909365</td>
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
      <td width="280">0.04277665074914694</td>
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
      <td width="280">0.2657759366557002</td>
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
      <td width="280">0.07455828785896301</td>
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
      <td width="280">0.06529155420139432</td>
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
      <td width="280">0.013259559869766235</td>
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
      <td width="280">0.15638355072587729</td>
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
      <td width="280">0.16595155280083418</td>
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
      <td width="280">0.0027175629511475563</td>
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
      <td width="280">9.949784725904465e-06</td>
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
      <td width="280">0.0031108707189559937</td>
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
      <td width="280">0.0768426638096571</td>
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
      <td width="280">0.06039004307240248</td>
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
      <td width="280">0.2104243729263544</td>
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
      <td width="280">0.015851144213229418</td>
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
      <td width="280">0.027718661818653345</td>
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
      <td width="280">0.024587600957602262</td>
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
      <td width="280">0.2656801878474653</td>
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
      <td width="280">0.1292666159570217</td>
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
      <td width="280">0.08347253315150738</td>
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
      <td width="280">0.0016618398949503899</td>
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
      <td width="280">0.042528561782091856</td>
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
      <td width="280">0.01807895116508007</td>
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
      <td width="280">0.004226375371217728</td>
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
      <td width="280">0.06524252379313111</td>
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
      <td width="280">0.23188797291368246</td>
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
      <td width="280">0.04994412697851658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
