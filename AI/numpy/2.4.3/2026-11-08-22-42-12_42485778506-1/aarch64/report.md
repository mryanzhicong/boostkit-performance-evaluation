# numpy 2.4.3 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`42485778506-1`

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
      <td width="1200">2.4.3</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">2.4.3</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-08T14:29:15Z</td>
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
      <td width="1200">2026-11-08T13:37:11Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 365513 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 378634 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 346146 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 350210 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">0.006037437997292727</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduce.time_axis_1</td>
      <td width="280">0.0040988760301843286</td>
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
      <td width="280">0.0001397299929521978</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;float64&#x27;)</td>
      <td width="280">0.00023961905390024185</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int16&#x27;)</td>
      <td width="280">0.000383298029191792</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int32&#x27;)</td>
      <td width="280">0.0003986579831689596</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int64&#x27;)</td>
      <td width="280">0.0002454490168020129</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;float32&#x27;)</td>
      <td width="280">0.0002374689793214202</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;float64&#x27;)</td>
      <td width="280">0.0002527390024624765</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int16&#x27;)</td>
      <td width="280">0.00037320901174098253</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int32&#x27;)</td>
      <td width="280">0.0003866290207952261</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int64&#x27;)</td>
      <td width="280">0.00024188903626054525</td>
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
      <td width="280">1.469976268708706e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_all_slow</td>
      <td width="280">6.1800237745046616e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_any_fast</td>
      <td width="280">1.4399993233382702e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_any_slow</td>
      <td width="280">5.699985194951296e-06</td>
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
      <td width="280">7.750000804662704e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">5.189899820834398e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">0.0001491790171712637</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">1.810002140700817e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">3.156001912429929e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">7.372000254690647e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">1.0390009265393019e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">1.6689999029040337e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">3.242999082431197e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">7.120001828297973e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">9.729992598295212e-06</td>
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
      <td width="280">3.209977876394987e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.FMinMax.time_min(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">3.1400122679769993e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.FMinMax.time_min(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">4.649977199733257e-06</td>
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
      <td width="280">2.869986928999424e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;float32&#x27;)</td>
      <td width="280">2.900022082030773e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;uint64&#x27;)</td>
      <td width="280">3.009976353496313e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;bool_&#x27;)</td>
      <td width="280">2.839951775968075e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;float32&#x27;)</td>
      <td width="280">2.800021320581436e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;float64&#x27;)</td>
      <td width="280">2.969987690448761e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;int64&#x27;)</td>
      <td width="280">2.9400107450783253e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;uint64&#x27;)</td>
      <td width="280">2.8999638743698597e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;bool_&#x27;)</td>
      <td width="280">3.390014171600342e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;float32&#x27;)</td>
      <td width="280">2.9900111258029938e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;float64&#x27;)</td>
      <td width="280">3.0199880711734295e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;int64&#x27;)</td>
      <td width="280">3.00002284348011e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;uint64&#x27;)</td>
      <td width="280">3.10997711494565e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;bool_&#x27;)</td>
      <td width="280">1.1819996871054173e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;float32&#x27;)</td>
      <td width="280">1.2370001059025526e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;float64&#x27;)</td>
      <td width="280">1.009996049106121e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;int64&#x27;)</td>
      <td width="280">1.1030002497136593e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;uint64&#x27;)</td>
      <td width="280">1.1129945050925016e-05</td>
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
      <td width="280">0.006052347947843373</td>
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
      <td width="280">3.8800062611699104e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">8.410017471760511e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">1.585000427439809e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">4.839967004954815e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">8.660019375383854e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">1.5610014088451862e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.749962732195854e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">4.609988536685705e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">8.5500068962574e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">1.562997931614518e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">3.0900118872523308e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">7.030030246824026e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">1.2060045264661312e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">4.450033884495497e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">7.11000757291913e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">1.1709984391927719e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">3.0900118872523308e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">4.430010449141264e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">7.269962225109339e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">1.1888972949236631e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">3.130000550299883e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">3.130000550299883e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">6.999995093792677e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">1.1850032024085522e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">4.369998350739479e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">6.949994713068008e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">1.160003012046218e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">3.029999788850546e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">4.44002216681838e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">7.0499954745173454e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">1.1729949619621038e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">3.0800001695752144e-06</td>
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
      <td width="280">4.809990059584379e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, -8)</td>
      <td width="280">4.840025212615728e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, 43)</td>
      <td width="280">4.749977961182594e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, 8)</td>
      <td width="280">4.7800131142139435e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, -43)</td>
      <td width="280">8.570030331611633e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, -8)</td>
      <td width="280">8.620030712336302e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, 43)</td>
      <td width="280">8.679984603077173e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, 8)</td>
      <td width="280">8.650007657706738e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, -43)</td>
      <td width="280">6.353005301207304e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, -8)</td>
      <td width="280">6.333901546895504e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, 43)</td>
      <td width="280">6.356002995744348e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, 8)</td>
      <td width="280">6.347999442368746e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, -43)</td>
      <td width="280">3.1500239856541157e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, -8)</td>
      <td width="280">3.1800009310245514e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, 43)</td>
      <td width="280">3.169989213347435e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, 8)</td>
      <td width="280">3.2400130294263363e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, -43)</td>
      <td width="280">6.302999099716544e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, -8)</td>
      <td width="280">6.324000423774123e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, 43)</td>
      <td width="280">6.325996946543455e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, 8)</td>
      <td width="280">6.333895726129413e-05</td>
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
      <td width="280">3.1199888326227665e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint16&#x27;&gt;, 8)</td>
      <td width="280">3.0800001695752144e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint32&#x27;&gt;, 43)</td>
      <td width="280">4.6800123527646065e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint32&#x27;&gt;, 8)</td>
      <td width="280">4.67000063508749e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint64&#x27;&gt;, 43)</td>
      <td width="280">1.1709984391927719e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint64&#x27;&gt;, 8)</td>
      <td width="280">1.165998401120305e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint8&#x27;&gt;, 43)</td>
      <td width="280">2.320040948688984e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint8&#x27;&gt;, 8)</td>
      <td width="280">2.2899475879967213e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.ulonglong&#x27;&gt;, 43)</td>
      <td width="280">1.178000820800662e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.ulonglong&#x27;&gt;, 8)</td>
      <td width="280">1.16900191642344e-05</td>
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
      <td width="280">8.399947546422482e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">8.599599823355675e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">8.799834176898003e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">8.500064723193645e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">8.800416253507137e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">8.600181899964809e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">8.600181899964809e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">8.399947546422482e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">8.699717000126839e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">8.399947546422482e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.00006853044033e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.00006853044033e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">8.299830369651318e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">8.299830369651318e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">8.399947546422482e-07</td>
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
      <td width="280">9.299837984144688e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.300420060753822e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.799841791391373e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.400537237524986e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.60018951445818e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.60018951445818e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.799841791391373e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.200302883982658e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.300420060753822e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.60018951445818e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.499490261077881e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.799841791391373e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.200302883982658e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.60018951445818e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.599607437849045e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.00006853044033e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.699724614620209e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.60018951445818e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.899958968162537e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.60018951445818e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.700306691229343e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.599607437849045e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.100185707211494e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.599607437849045e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">1.660024281591177e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">1.66997779160738e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.569977030158043e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.6499543562531471e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.66997779160738e-06</td>
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
      <td width="280">9.199720807373524e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.700306691229343e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.100185707211494e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.699724614620209e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.699724614620209e-07</td>
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
      <td width="280">5.700276233255863e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((-1, 0), &#x27;small&#x27;)</td>
      <td width="280">5.500041879713535e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((0, 0), &#x27;big&#x27;)</td>
      <td width="280">5.500041879713535e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((0, 0), &#x27;small&#x27;)</td>
      <td width="280">5.599576979875565e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem(0, &#x27;big&#x27;)</td>
      <td width="280">5.300389602780342e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem(0, &#x27;small&#x27;)</td>
      <td width="280">5.399924702942371e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem([0, -1], &#x27;big&#x27;)</td>
      <td width="280">2.3500178940594196e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem([0, -1], &#x27;small&#x27;)</td>
      <td width="280">2.349959686398506e-06</td>
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
      <td width="280">1.609965693205595e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.6400008462369442e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.769978553056717e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int8&#x27;)</td>
      <td width="280">1.5299883671104908e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;intp&#x27;)</td>
      <td width="280">1.7400016076862812e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint16&#x27;)</td>
      <td width="280">1.6400008462369442e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint32&#x27;)</td>
      <td width="280">1.7400016076862812e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint64&#x27;)</td>
      <td width="280">1.7700367607176304e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint8&#x27;)</td>
      <td width="280">1.4799879863858223e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.6200356185436249e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.6799895092844963e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.8100254237651825e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int8&#x27;)</td>
      <td width="280">1.500011421740055e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;intp&#x27;)</td>
      <td width="280">1.7499551177024841e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint16&#x27;)</td>
      <td width="280">1.5900004655122757e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint32&#x27;)</td>
      <td width="280">1.6800477169454098e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint64&#x27;)</td>
      <td width="280">1.800013706088066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint8&#x27;)</td>
      <td width="280">1.500011421740055e-06</td>
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
      <td width="280">4.5995693653821945e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((-1, 0), &#x27;small&#x27;)</td>
      <td width="280">3.100140020251274e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((0, 0), &#x27;big&#x27;)</td>
      <td width="280">4.600151441991329e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((0, 0), &#x27;small&#x27;)</td>
      <td width="280">3.00002284348011e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem(0, &#x27;big&#x27;)</td>
      <td width="280">8.00006091594696e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem(0, &#x27;small&#x27;)</td>
      <td width="280">3.100140020251274e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem([0, -1], &#x27;big&#x27;)</td>
      <td width="280">2.600019797682762e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem([0, -1], &#x27;small&#x27;)</td>
      <td width="280">3.0995579436421394e-07</td>
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
      <td width="280">0.00010432000271975994</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_and&#x27;)</td>
      <td width="280">2.0780018530786037e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_count&#x27;)</td>
      <td width="280">2.7359987143427134e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_not&#x27;)</td>
      <td width="280">1.4580029528588057e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_or&#x27;)</td>
      <td width="280">2.0249979570508003e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_xor&#x27;)</td>
      <td width="280">2.0549981854856014e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;cbrt&#x27;)</td>
      <td width="280">0.0010441659833304584</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;ceil&#x27;)</td>
      <td width="280">5.9489975683391094e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;deg2rad&#x27;)</td>
      <td width="280">0.00012369995238259435</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;degrees&#x27;)</td>
      <td width="280">0.00012451998190954328</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;equal&#x27;)</td>
      <td width="280">0.00011979998089373112</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;exp2&#x27;)</td>
      <td width="280">0.0008579069981351495</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fabs&#x27;)</td>
      <td width="280">0.000125700025819242</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;floor&#x27;)</td>
      <td width="280">5.884002894163132e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;floor_divide&#x27;)</td>
      <td width="280">0.0003050590166822076</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fmax&#x27;)</td>
      <td width="280">0.000142398988828063</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fmin&#x27;)</td>
      <td width="280">0.00013940996723249555</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;greater&#x27;)</td>
      <td width="280">0.00013254903024062514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;greater_equal&#x27;)</td>
      <td width="280">0.00012743897968903184</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;invert&#x27;)</td>
      <td width="280">1.448002876713872e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isfinite&#x27;)</td>
      <td width="280">7.478002225980163e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isinf&#x27;)</td>
      <td width="280">7.941899821162224e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isnan&#x27;)</td>
      <td width="280">6.972899427637458e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isnat&#x27;)</td>
      <td width="280">3.399909473955631e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;left_shift&#x27;)</td>
      <td width="280">2.368004061281681e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;less&#x27;)</td>
      <td width="280">0.00012560898903757334</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;less_equal&#x27;)</td>
      <td width="280">0.00012808904284611344</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;log2&#x27;)</td>
      <td width="280">0.0012257559574209154</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_and&#x27;)</td>
      <td width="280">0.00015959003940224648</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_not&#x27;)</td>
      <td width="280">9.676901390776038e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_or&#x27;)</td>
      <td width="280">0.00014523998834192753</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_xor&#x27;)</td>
      <td width="280">0.00015292898751795292</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;minimum&#x27;)</td>
      <td width="280">0.00015191995771601796</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;negative&#x27;)</td>
      <td width="280">8.2580023445189e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;positive&#x27;)</td>
      <td width="280">8.59689898788929e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;rad2deg&#x27;)</td>
      <td width="280">0.00012666999828070402</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;radians&#x27;)</td>
      <td width="280">0.00012303999392315745</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;reciprocal&#x27;)</td>
      <td width="280">0.00018357997760176659</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;right_shift&#x27;)</td>
      <td width="280">2.719002077355981e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;rint&#x27;)</td>
      <td width="280">0.00011403998360037804</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;true_divide&#x27;)</td>
      <td width="280">0.00025262904819101095</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;trunc&#x27;)</td>
      <td width="280">5.8820005506277084e-05</td>
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
      <td width="280">0.0005667480290867388</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00028572900919243693</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001169825962278992</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004787790239788592</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017201640293933451</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0006916080019436777</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0018158640014007688</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006967270164750516</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0025209809537045658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0009902060264721513</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002700029988773167</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012186950189061463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0009664170211181045</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00041304901242256165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015565049834549427</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006325279828161001</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002064322994556278</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008151769870892167</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0022871820256114006</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0008585369796492159</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0028638700023293495</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001223645987920463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0030441390117630363</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014115949743427336</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006080679595470428</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00029356899904087186</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0011144059826619923</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00048232899280264974</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001691303972620517</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0007055280148051679</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001845883030910045</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007059979834593832</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0025176709750667214</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0009824670269154012</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0026768710231408477</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012497360003180802</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0009796269587241113</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004076089826412499</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015698240022175014</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006252379971556365</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002061452018097043</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008316969615407288</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.002236991946119815</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0008766470127739012</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00285748002352193</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012087860377505422</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.003049829974770546</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014198549906723201</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0011360060307197273</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00048039795365184546</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017647739732638001</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0007041179924272001</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001847082981839776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007280680001713336</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0025311310309916735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0009998759487643838</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0027249010163359344</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001216326025314629</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0009651369764469564</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00041773897828534245</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015780339599587023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000661937054246664</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0020129120093770325</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.000837027037050575</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.002283771988004446</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000870096031576395</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0028802399756386876</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012241260265000165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0030699289636686444</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014803039957769215</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006292980397120118</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00029341899789869785</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0011387260165065527</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004978589713573456</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017350540147162974</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0006910780211910605</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001881563977804035</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007252480136230588</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002522271010093391</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0010319859720766544</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0027215000009164214</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012680559884756804</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010071760043501854</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004274889943189919</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015656049945391715</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006383779691532254</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0020624420139938593</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008288869867101312</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0022920420160517097</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0008657769649289548</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0028766299947164953</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001224166015163064</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0030363190453499556</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014251149841584265</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004172680201008916</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003851180081255734</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007467669784091413</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00040655903285369277</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001226964988745749</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005618680152110755</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001458934973925352</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005489280447363853</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021102920291014016</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007745180046185851</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0025087210233323276</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010315760155208409</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004189389874227345</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003858989803120494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.000776377972215414</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00040392798837274313</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012178660253994167</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005658079753629863</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014388149720616639</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005381579976528883</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021076530101709068</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007367670186795294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.00246982101816684</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010084470268338919</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00041554798372089863</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00038560800021514297</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007142479880712926</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004094290197826922</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012049960205331445</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.000562878034543246</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014188550412654877</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005515390075743198</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020755630102939904</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007172879995778203</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024706210242584348</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0009957070578821003</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00043184804962947965</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003852290101349354</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007514670141972601</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004113190225325525</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001237385964486748</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005627879872918129</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014678550069220364</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005331680295057595</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002123632002621889</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008013980113901198</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002473760978318751</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010064960224553943</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007406870136037469</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004101790254935622</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001203026040457189</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005621080053970218</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014238249859772623</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005373079911805689</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002151181979570538</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007950669969432056</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002509581041522324</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001032806991133839</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004180080140940845</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00038771796971559525</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007340169977396727</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004095789627172053</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0011999959824606776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005672979750670493</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001442854991182685</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005326180253177881</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002106713014654815</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007446579984389246</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002508751000277698</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0009922159952111542</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004179090028628707</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00038784800563007593</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007309780339710414</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004067390109412372</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012280259979888797</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005615580012090504</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014638449647463858</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005546880420297384</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020812630536966026</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007772870012558997</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0025105809909291565</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001005275989882648</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004191389889456332</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00043562898645177484</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007263569859787822</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004707880434580147</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012003359734080732</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005694879801012576</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014612249797210097</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005668679950758815</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00210953300120309</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008032170007936656</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002523881965316832</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.000983497011475265</td>
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
      <td width="280">4.543998511508107e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.7128996811807156e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">4.98400186188519e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">8.278997847810388e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">8.26600007712841e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">5.5858981795609e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">5.776004400104284e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">4.930002614855766e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">8.220004383474588e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">8.526002056896687e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.4989981688559055e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.6639994252473116e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.740001168102026e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">7.57100060582161e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">7.569999434053898e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">5.626998608931899e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">5.6978955399245024e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.740001168102026e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">7.69889447838068e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">7.770897354930639e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.588998854160309e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.834902938455343e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">5.098001565784216e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">0.00011291896225884557</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00011374999303370714</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">5.6398974265903234e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">5.8380013797432184e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">5.082000279799104e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00011361896758899093</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00011223001638427377</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">4.529999569058418e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">4.702899605035782e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">4.6970031689852476e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">7.632002234458923e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">7.475900929421186e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">5.571998190134764e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">5.6940014474093914e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">4.7299021389335394e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">7.53789790906012e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">7.517996709793806e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.5849999878555536e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.8399961087852716e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">5.0640024710446596e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">0.00011384999379515648</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00011358899064362049</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">5.64999645575881e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">5.8470002841204405e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">5.0510047003626823e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">0.0001111599849537015</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00011289899703115225</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.508002893999219e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.5829976443201303e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.762999014928937e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">9.529996896162629e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">9.841995779424906e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">5.5629992857575417e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">5.607999628409743e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.796002758666873e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">9.794003563001752e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">9.754899656400084e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.576996434479952e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.7339999582618475e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">5.884998245164752e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">0.00013611995382234454</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00013485003728419542</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">5.6098971981555223e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">5.7240016758441925e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">5.92700089327991e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">0.0001363889896310866</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">0.0001362200127914548</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">5.530018825083971e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">9.070034138858318e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.0870007574558258e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.666899960488081e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">5.666998913511634e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">5.5800192058086395e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">9.209965355694294e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.0230014342814684e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">5.5649958085268736e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">5.515897646546364e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.564999835565686e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.7640001866966486e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">4.9479014705866575e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">8.358003105968237e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">8.408998837694526e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">5.588994827121496e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">5.7330005802214146e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">4.934996832162142e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">8.288997923955321e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">8.11200006864965e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.513002932071686e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.6829984057694674e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.744000034406781e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">7.745902985334396e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">7.392896804958582e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">5.5870041251182556e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">5.7800032664090395e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.7269975766539574e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">7.49800237827003e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">7.677997928112745e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.5970024075359106e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.787999205291271e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">5.053903441876173e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">0.00011262902989983559</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00011171004734933376</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">5.6409044191241264e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">5.8310048189014196e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">5.041999975219369e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00011131999781355262</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00011044897837564349</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">4.529999569058418e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">4.675996024161577e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">4.740001168102026e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">7.66600132919848e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">7.786002242937684e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">5.614000838249922e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">5.684001371264458e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">4.7389010433107615e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">7.458997424691916e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">7.464003283530474e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.583998816087842e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.780996823683381e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">5.089002661406994e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">0.0001126100542023778</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00011213903781026602</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">5.661003524437547e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">5.862000398337841e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">5.068001337349415e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00011288002133369446</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00011260900646448135</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.509999416768551e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.61999443359673e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.7918991185724735e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">9.877898264676332e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">9.925896301865578e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">5.5838958360254765e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">5.5750017054378986e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.78890142403543e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">9.524996858090162e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">9.938899893313646e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.573998739942908e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.723999882116914e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">5.821901140734553e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">0.00013518898049369454</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.0001346899662166834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">5.6540011428296566e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">5.761999636888504e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">5.931901978328824e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00013514998136088252</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00013584899716079235</td>
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
      <td width="280">1.2299860827624798e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5799887478351593e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.2199819795787334e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.400025889277458e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.3199903555214405e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.200009137392044e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5700352378189564e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.169981598854065e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.390014171600342e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.3999676816165447e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.2199743650853634e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5500118024647236e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.2199819795787334e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.490014933049679e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.369990736246109e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.2299860827624798e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5499535948038101e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.200016751885414e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.430002834647894e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.409979399293661e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.2389500625431538e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.0199804566800594e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.2500171326100826e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.3599790185689926e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.409979399293661e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.2399978004395962e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5799887478351593e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.1700398065149784e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.4199911169707775e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.409979399293661e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.2200325727462769e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5500118024647236e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.569984644651413e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.400025889277458e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.3999676816165447e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.2299860827624798e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5799887478351593e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.200016751885414e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.390014171600342e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.369990736246109e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">2.960034180432558e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.8199865482747555e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.600019797682762e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.360052455216646e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.740024451166391e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">2.9199873097240925e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.760032657533884e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.569984644651413e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">5.370005965232849e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.760047886520624e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.400010660290718e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.9000144675374031e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.029999788850546e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.800036549568176e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.7800131142139435e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.4199758879840374e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.8700375221669674e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.020046278834343e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.770001396536827e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.820001777261496e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3500102795660496e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.7799902707338333e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.8199865482747555e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.389963578432798e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.399975296109915e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3599637895822525e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.800013706088066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.8500217013061047e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.399975296109915e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.369998350739479e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.469976268708706e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.8900027498602867e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.9799994081258774e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.809990059584379e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.810048267245293e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.369975507259369e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.8799910321831703e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.0199880711734295e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.800036549568176e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.830013494938612e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.2500095181167126e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5400000847876072e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.3500178940594196e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.5299606174230576e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">5.530018825083971e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.2500095181167126e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5900004655122757e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.22999369725585e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">5.449983291327953e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">5.470006726682186e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">3.300025127828121e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">3.1900126487016678e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.8900103643536568e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.539972335100174e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">5.270005203783512e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">3.5199918784201145e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">3.6599813029170036e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.830005880445242e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">7.060007192194462e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">7.080030627548695e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.2200325727462769e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5400000847876072e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.2799940779805183e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.490014933049679e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.5599805414676666e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.1799857020378113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5700352378189564e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.2199819795787334e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.3400137908756733e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.5499688237905502e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.869979314506054e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.1700398065149784e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.8400099836289883e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.990018740296364e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.0199956856667995e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8400023691356182e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.1500163711607456e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.7599744498729706e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.9800070226192474e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.009983967989683e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8499558791518211e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.10996950045228e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.7599744498729706e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.990018740296364e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.9800070226192474e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8700375221669674e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.1799933165311813e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.8400099836289883e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.030007403343916e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.969995304942131e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8800492398440838e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.1500163711607456e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.7400092221796513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.039960913360119e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.990018740296364e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8900027498602867e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.1700398065149784e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.7899590097367764e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.959983587265015e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.959983587265015e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8999562598764896e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.180051524192095e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.959983587265015e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.9199949242174625e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8500140868127346e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.1900050342082977e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.8199865482747555e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.9800070226192474e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.049972631037235e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">3.029999788850546e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.9700458981096745e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.960034180432558e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.98996814712882e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.98996814712882e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">3.0400115065276623e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.9999646358191967e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.969987690448761e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.979956429451704e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">5.009991582483053e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.920037902891636e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.2199819795787334e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.00002284348011e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.54997643828392e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.620000254362822e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8700375221669674e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.2199819795787334e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.00002284348011e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.620000254362822e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.600035026669502e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.929991412907839e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.2799940779805183e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.069988451898098e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.759989678859711e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.709989298135042e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8900027498602867e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.2599706426262856e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.0800001695752144e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.690024070441723e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.740024451166391e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8500140868127346e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.260028850287199e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.9900111258029938e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.530011210590601e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.600035026669502e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8999562598764896e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.2100284695625305e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.069988451898098e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.620000254362822e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.599976819008589e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8400023691356182e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.1199812181293964e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.829998265951872e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">6.23002415522933e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">6.260001100599766e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8999562598764896e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.2199819795787334e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">6.1400351114571095e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">6.1800237745046616e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">3.3800024539232254e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">3.3499673008918762e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.2599782571196556e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.609996151179075e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">6.030022632330656e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">3.3599790185689926e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">3.300025127828121e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.830005880445242e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">5.67000824958086e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">5.679961759597063e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8500140868127346e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.1799933165311813e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.800021320581436e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.0199956856667995e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.00003045797348e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.869979314506054e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.1500163711607456e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.729997504502535e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.950030077248812e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.999972250312567e-06</td>
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
      <td width="280">0.0004362679901532829</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.000436758971773088</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004360289894975722</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0004531489685177803</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00043622899102047086</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000436878006439656</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000436128000728786</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.000436539005022496</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004360490129329264</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00045210798271000385</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0004371189861558378</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004367789952084422</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004218080430291593</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">9.689002763479948e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020964903524145484</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007482980145141482</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0006567480158992112</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003899980220012367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001308195001911372</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0006167279789224267</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005515679949894547</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017215539701282978</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005708370008505881</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007185079739429057</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.01956420100759715</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.023932865995448083</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.01952282094862312</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.019513320992700756</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.02391797595191747</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.01944268197985366</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.01951171102700755</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.023920365027152002</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.019457251008134335</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.01951872097561136</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.023903426015749574</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.01945824100403115</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00042208796367049217</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003055140026845038</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021113897673785686</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006776369991712272</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030600689933635294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00038996798684820533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001352444989606738</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030574389966204762</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005668780067935586</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015829750336706638</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003060998977161944</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000665478000883013</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013079760246910155</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003072289051488042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013075349852442741</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013148850412108004</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030808489536866546</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001306735968682915</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014894749619998038</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003075690008699894</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013323549646884203</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021759120281785727</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030811690376140177</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013350349618121982</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013113649911247194</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003067199024371803</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001307294995058328</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001316756010055542</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003078579029534012</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013064059894531965</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0015164550277404487</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030726889963261783</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001329505001194775</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002163483004551381</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003078359004575759</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013413849519565701</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0035711380187422037</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005703079979866743</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.003009170002769679</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0035531180328689516</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00570469000376761</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0030185990035533905</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0036284769885241985</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0057001200038939714</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0030205600196495652</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0036396480281837285</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00571100995875895</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0030291000148281455</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013077359762974083</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003060108982026577</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00130699499277398</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013104149838909507</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030635989969596267</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013075459864921868</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014800449716858566</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003059429000131786</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013454350410029292</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021690030116587877</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030661289929412305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00133636494865641</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004383989726193249</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00305533898063004</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002093999646604061</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006762580014765263</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00305846898118034</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003911879612132907</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013081050128675997</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030553689575754106</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00057430804008618</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016109549906104803</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003059228998608887</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006664070533588529</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00620306795462966</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006252958031836897</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.003664986987132579</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.006239728012587875</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0062595579656772316</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0036724969977512956</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.006216408044565469</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006256818014662713</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.003692096972372383</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.006232298037502915</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006269917997997254</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0037041770410723984</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007111169979907572</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.001305846031755209</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006722580292262137</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007494580349884927</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0013056459720246494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007359980372712016</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0011914659989997745</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0013055650051683187</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007155269850045443</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0012639560154639184</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0013078750343993306</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007898079929873347</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00034568802220746875</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0006528979865834117</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00017754995496943593</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.000748987018596381</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0006567779928445816</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00037467898800969124</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013038660399615765</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0006560879992321134</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005835969932377338</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017984730075113475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0006694180192425847</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003819690318778157</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00044575799256563187</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.000503018032759428</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004389879759401083</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007558870129287243</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005086780292913318</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00045140902511775494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014331049751490355</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005117289838381112</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000523118011187762</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020900029921904206</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005181780434213579</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007882370264269412</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013072349829599261</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003070180013310164</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013067150139249861</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013144459808245301</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003076258988585323</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001306285965256393</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001450593990739435</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003071590035688132</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013324450119398534</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021677829790860415</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030772589961998165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013410960091277957</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013071459834463894</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003072819032240659</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013067360268905759</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001315175963100046</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003078728972468525</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013074849848635495</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001461555017158389</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003073568979743868</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013318450073711574</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002160612028092146</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030794889898970723</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013390250387601554</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00042430899338796735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0025251609622500837</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002100690035149455</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007208380266092718</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0025306809693574905</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003995280130766332</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013478249893523753</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0025277420063503087</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005506779998540878</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017317740130238235</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00253238104050979</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007501280051656067</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00042234797729179263</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003054488974157721</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021044001914560795</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006750280153937638</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003058758971747011</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00038563902489840984</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013443450443446636</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030554590048268437</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005152980447746813</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016045349766500294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003059439011849463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000632517971098423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004220989649184048</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030511789955198765</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020972901256754994</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006621080101467669</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003059570037294179</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003903789911419153</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013069650158286095</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003057299996726215</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005431780009530485</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015886250184848905</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003060038958210498</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006190179847180843</td>
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
      <td width="280">0.0004361980245448649</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0004366379580460489</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00043630797881633043</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00045049795880913734</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00043629901483654976</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00043664901750162244</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004361980245448649</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0004366789944469929</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004363380139693618</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00045033800415694714</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00043667800491675735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004367680521681905</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00042176799615845084</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">9.49589884839952e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002105189487338066</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006689470028504729</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0006569079705514014</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00039144797483459115</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013916949974372983</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005694680148735642</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005549080087803304</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015929240034893155</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005805679829791188</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006365680019371212</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.01201515702996403</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.015557245002128184</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.011966528021730483</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.011950188025366515</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.015521316032391042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.01194260799093172</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.011951698048505932</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0161791630089283</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.011908357962965965</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.011951926979236305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.016174393007531762</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.011938897019717842</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00042336800834164023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030545699992217124</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021131004905328155</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006689780275337398</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00306071899831295</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003900189767591655</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013606860302388668</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003059009031858295</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000544338021427393</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015689340070821345</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030612790142185986</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006412079674191773</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013081959914416075</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003073709027376026</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013063360238447785</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013186659780330956</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030790690216235816</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001306966005358845</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014649649965576828</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003073789004702121</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013396849972195923</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001994532998651266</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003080368973314762</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013373949914239347</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013072260189801455</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030700789648108184</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013070550048723817</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001313654996920377</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030762599781155586</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013061250210739672</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014914139756001532</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003071799990721047</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013200449757277966</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020151130156591535</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030772589961998165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001340034999884665</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0031799590215086937</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006042029010131955</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0030371189932338893</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.003130199038423598</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0060524389846250415</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0030471489881165326</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.003222789033316076</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006039528991095722</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0030535790137946606</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0032232589437626302</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006046477996278554</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0029921800014562905</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013099859934300184</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003058109956327826</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013071459834463894</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013140750234015286</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003064528980758041</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013065259554423392</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014878750080242753</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003060489019844681</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013366949860937893</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020446520065888762</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003065258963033557</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013364250189624727</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004228890174999833</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030550090014003217</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002104190061800182</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006623069639317691</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030603790073655546</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003881689626723528</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013540250365622342</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003057349007576704</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005539180128835142</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015962039469741285</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003061089024413377</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006656079785898328</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.005785129964351654</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006908705981913954</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.004859482985921204</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00578885996947065</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006896375969517976</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.004863601992838085</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0058149489923380315</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006804965960327536</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.004919471975881606</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.005816440039779991</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006813425978180021</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.004925183020532131</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013072050060145557</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030696989852003753</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001307594997342676</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013145150151103735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003077158995438367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013064059894531965</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0015120639582164586</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00307251897174865</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001326096011325717</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020568930194713175</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030794990016147494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001342135015875101</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001308006001636386</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00307362899184227</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001308114966377616</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013134150067344308</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003080198948737234</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013065350358374417</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014627249911427498</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030756990308873355</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013263050350360572</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002019342966377735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030803189729340374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013311249786056578</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004228479810990393</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0025261009577661753</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021044001914560795</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006712870090268552</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0025326709728688</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003961680340580642</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013318650308065116</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.002527950971852988</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005548980552703142</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015688439598307014</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.002533491002395749</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006981370388530195</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00042365898843854666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00305471895262599</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020937900990247726</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006733369664289057</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030602390179410577</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00038750801468268037</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013790249940939248</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030570289818570018</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005529790068976581</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016031739651225507</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030602389597333968</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006407480104826391</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004241989809088409</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030554590048268437</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021167000522837043</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006700570229440928</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030611699912697077</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003858379786834121</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013047659886069596</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030567790381610394</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005448380252346396</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016090249991975725</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030614790157414973</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006396680255420506</td>
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
      <td width="280">0.024275014002341777</td>
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
      <td width="280">0.004387193999718875</td>
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
      <td width="280">0.013867871020920575</td>
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
      <td width="280">0.004262375005055219</td>
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
      <td width="280">0.007454013975802809</td>
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
      <td width="280">0.005219882004894316</td>
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
      <td width="280">0.005908478982746601</td>
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
      <td width="280">0.1068114530062303</td>
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
      <td width="280">0.02251670102123171</td>
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
      <td width="280">0.0704635709989816</td>
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
      <td width="280">2.8690032195299864e-05</td>
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
      <td width="280">0.006015928986016661</td>
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
      <td width="280">0.4164251089678146</td>
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
      <td width="280">0.061952082032803446</td>
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
      <td width="280">0.05727350799134001</td>
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
      <td width="280">0.11407826701179147</td>
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
      <td width="280">0.10328092495910823</td>
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
      <td width="280">0.061998881050385535</td>
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
      <td width="280">0.03262287500547245</td>
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
      <td width="280">0.14834029600024223</td>
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
      <td width="280">0.14833809598349035</td>
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
      <td width="280">0.003325957979541272</td>
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
      <td width="280">1.4089979231357574e-05</td>
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
      <td width="280">0.004286835028324276</td>
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
      <td width="280">0.1401542950188741</td>
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
      <td width="280">0.08837446803227067</td>
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
      <td width="280">0.2428067119908519</td>
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
      <td width="280">0.022801699000410736</td>
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
      <td width="280">0.031397579004988074</td>
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
      <td width="280">0.0296833660104312</td>
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
      <td width="280">0.11376029899111018</td>
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
      <td width="280">0.05797415494453162</td>
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
      <td width="280">0.061794201959855855</td>
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
      <td width="280">0.002085843007080257</td>
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
      <td width="280">0.06488497095415369</td>
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
      <td width="280">0.0227195990155451</td>
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
      <td width="280">0.004962252045515925</td>
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
      <td width="280">0.061878381005954</td>
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
      <td width="280">0.24550459295278415</td>
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
      <td width="280">0.04670413496205583</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
