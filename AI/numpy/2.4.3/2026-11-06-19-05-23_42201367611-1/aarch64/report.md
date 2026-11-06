# numpy 2.4.3 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`42201367611-1`

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
      <td width="1200">2026-11-06T10:51:33Z</td>
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
      <td width="1200">2026-11-06T10:16:57Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 378631 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 383973 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 377234 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 350826 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">0.0060690289828926325</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduce.time_axis_1</td>
      <td width="280">0.004115515970624983</td>
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
      <td width="280">0.00014194997493177652</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;float64&#x27;)</td>
      <td width="280">0.00022455898579210043</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int16&#x27;)</td>
      <td width="280">0.0003793989890255034</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int32&#x27;)</td>
      <td width="280">0.00039681902853772044</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int64&#x27;)</td>
      <td width="280">0.00024728901917114854</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;float32&#x27;)</td>
      <td width="280">0.00023594900267198682</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;float64&#x27;)</td>
      <td width="280">0.00024313904577866197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int16&#x27;)</td>
      <td width="280">0.00037285900907590985</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int32&#x27;)</td>
      <td width="280">0.0003870790242217481</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int64&#x27;)</td>
      <td width="280">0.00024121900787577033</td>
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
      <td width="280">1.3999524526298046e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_all_slow</td>
      <td width="280">5.970010533928871e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_any_fast</td>
      <td width="280">1.4199758879840374e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_any_slow</td>
      <td width="280">5.67000824958086e-06</td>
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
      <td width="280">7.98999099060893e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">5.173002136871219e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">0.00011200900189578533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">1.7910031601786613e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">3.226002445444465e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">7.049000123515725e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">1.0140007361769676e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">1.7460028175264597e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">3.19399987347424e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">6.816996028646827e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">1.0240008123219013e-05</td>
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
      <td width="280">3.0900118872523308e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.FMinMax.time_min(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">3.200024366378784e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.FMinMax.time_min(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">4.640023689717054e-06</td>
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
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;float32&#x27;)</td>
      <td width="280">2.820044755935669e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;uint64&#x27;)</td>
      <td width="280">2.8799986466765404e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;bool_&#x27;)</td>
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;float32&#x27;)</td>
      <td width="280">2.8199865482747555e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;float64&#x27;)</td>
      <td width="280">2.900022082030773e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;int64&#x27;)</td>
      <td width="280">2.809974830597639e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;uint64&#x27;)</td>
      <td width="280">2.8799986466765404e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;bool_&#x27;)</td>
      <td width="280">3.3100368455052376e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;float32&#x27;)</td>
      <td width="280">2.9799994081258774e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;float64&#x27;)</td>
      <td width="280">2.9799994081258774e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;int64&#x27;)</td>
      <td width="280">2.960034180432558e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;uint64&#x27;)</td>
      <td width="280">2.9799994081258774e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;bool_&#x27;)</td>
      <td width="280">1.179997343569994e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;float32&#x27;)</td>
      <td width="280">1.223996514454484e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;float64&#x27;)</td>
      <td width="280">9.890005458146334e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;int64&#x27;)</td>
      <td width="280">1.111003803089261e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;uint64&#x27;)</td>
      <td width="280">1.1209980584681034e-05</td>
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
      <td width="280">0.006101749022491276</td>
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
      <td width="280">3.840017598122358e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">9.139999747276306e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">1.631001941859722e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">4.830013494938612e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">8.759961929172277e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">1.6089994460344315e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.769986167550087e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">4.770001396536827e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">8.829985745251179e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">1.5669967979192734e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">2.709974069148302e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">3.0500232242047787e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">7.760012522339821e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">1.2789969332516193e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">4.389963578432798e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">7.700000423938036e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">1.2730015441775322e-05</td>
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
      <td width="280">4.310044459998608e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">7.630034815520048e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">1.279998105019331e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">3.1800009310245514e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">3.0900118872523308e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">7.629976607859135e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">1.2499978765845299e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">4.349974915385246e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">7.619964890182018e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">1.2539967428892851e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">3.0800001695752144e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">4.400033503770828e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">7.6700234785676e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">1.2630014680325985e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">3.1800009310245514e-06</td>
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
      <td width="280">4.7299545258283615e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, -8)</td>
      <td width="280">4.720001015812159e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, 43)</td>
      <td width="280">4.730012733489275e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, 8)</td>
      <td width="280">4.730012733489275e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, -43)</td>
      <td width="280">8.539995178580284e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, -8)</td>
      <td width="280">8.660019375383854e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, 43)</td>
      <td width="280">8.639995940029621e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, 8)</td>
      <td width="280">8.700008038431406e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, -43)</td>
      <td width="280">6.301997927948833e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, -8)</td>
      <td width="280">6.345997098833323e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, 43)</td>
      <td width="280">6.31499569863081e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, 8)</td>
      <td width="280">6.326002767309546e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, -43)</td>
      <td width="280">3.0899536795914173e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, -8)</td>
      <td width="280">3.1400122679769993e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, 43)</td>
      <td width="280">3.1500239856541157e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, 8)</td>
      <td width="280">3.149965777993202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, -43)</td>
      <td width="280">6.325001595541835e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, -8)</td>
      <td width="280">6.286997813731432e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, 43)</td>
      <td width="280">6.326904986053705e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, 8)</td>
      <td width="280">6.295001367107034e-05</td>
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
      <td width="280">2.9900111258029938e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint16&#x27;&gt;, 8)</td>
      <td width="280">2.9900111258029938e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint32&#x27;&gt;, 43)</td>
      <td width="280">4.600035026669502e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint32&#x27;&gt;, 8)</td>
      <td width="280">4.610046744346619e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint64&#x27;&gt;, 43)</td>
      <td width="280">1.1639029253274202e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint64&#x27;&gt;, 8)</td>
      <td width="280">1.1709984391927719e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint8&#x27;&gt;, 43)</td>
      <td width="280">2.2400054149329662e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint8&#x27;&gt;, 8)</td>
      <td width="280">2.22999369725585e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.ulonglong&#x27;&gt;, 43)</td>
      <td width="280">1.1809985153377056e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.ulonglong&#x27;&gt;, 8)</td>
      <td width="280">1.156999496743083e-05</td>
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
      <td width="280">8.200295269489288e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">8.499482646584511e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">8.600181899964809e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">8.599599823355675e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">8.899951353669167e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">8.500064723193645e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">8.500064723193645e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">8.500064723193645e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">8.399947546422482e-07</td>
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
      <td width="280">9.09960363060236e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">8.700299076735973e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">8.00006091594696e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">8.399947546422482e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">8.599599823355675e-07</td>
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
      <td width="280">9.200302883982658e-07</td>
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
      <td width="280">9.700306691229343e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.899958968162537e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.199720807373524e-07</td>
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
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.499490261077881e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.00006853044033e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.400537237524986e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.60018951445818e-07</td>
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
      <td width="280">9.199720807373524e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.400537237524986e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.799841791391373e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.00006853044033e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
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
      <td width="280">9.699724614620209e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.00006853044033e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
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
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.09960363060236e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.100185707211494e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.699724614620209e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.699724614620209e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.699724614620209e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.500072337687016e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.800423868000507e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">9.799841791391373e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.399955160915852e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">1.6900012269616127e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">1.6999547369778156e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.6499543562531471e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.6299891285598278e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.6400008462369442e-06</td>
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
      <td width="280">9.00006853044033e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.00006853044033e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.199720807373524e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.09960363060236e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">8.799834176898003e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.200302883982658e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">9.09960363060236e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">9.00006853044033e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">9.299837984144688e-07</td>
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
      <td width="280">5.500041879713535e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((-1, 0), &#x27;small&#x27;)</td>
      <td width="280">5.200272426009178e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((0, 0), &#x27;big&#x27;)</td>
      <td width="280">5.399924702942371e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((0, 0), &#x27;small&#x27;)</td>
      <td width="280">5.199690349400043e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem(0, &#x27;big&#x27;)</td>
      <td width="280">5.400506779551506e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem(0, &#x27;small&#x27;)</td>
      <td width="280">5.200272426009178e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem([0, -1], &#x27;big&#x27;)</td>
      <td width="280">2.3400061763823032e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem([0, -1], &#x27;small&#x27;)</td>
      <td width="280">2.360029611736536e-06</td>
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
      <td width="280">1.6199774108827114e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.7199781723320484e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int8&#x27;)</td>
      <td width="280">1.4400575309991837e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;intp&#x27;)</td>
      <td width="280">1.6599660739302635e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint16&#x27;)</td>
      <td width="280">1.609965693205595e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint32&#x27;)</td>
      <td width="280">1.6300473362207413e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint64&#x27;)</td>
      <td width="280">1.8299906514585018e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint8&#x27;)</td>
      <td width="280">1.4399993233382702e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.600012183189392e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.6400008462369442e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.709966454654932e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int8&#x27;)</td>
      <td width="280">1.4300458133220673e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;intp&#x27;)</td>
      <td width="280">1.66997779160738e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint16&#x27;)</td>
      <td width="280">1.5400000847876072e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint32&#x27;)</td>
      <td width="280">1.6700359992682934e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint64&#x27;)</td>
      <td width="280">1.7900019884109497e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint8&#x27;)</td>
      <td width="280">1.4800461940467358e-06</td>
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
      <td width="280">4.3999170884490013e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((-1, 0), &#x27;small&#x27;)</td>
      <td width="280">2.900487743318081e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((0, 0), &#x27;big&#x27;)</td>
      <td width="280">4.300381988286972e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((0, 0), &#x27;small&#x27;)</td>
      <td width="280">3.100140020251274e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem(0, &#x27;big&#x27;)</td>
      <td width="280">7.600174285471439e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem(0, &#x27;small&#x27;)</td>
      <td width="280">2.899905666708946e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem([0, -1], &#x27;big&#x27;)</td>
      <td width="280">2.5100307539105415e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem([0, -1], &#x27;small&#x27;)</td>
      <td width="280">2.899905666708946e-07</td>
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
      <td width="280">0.00010626896983012557</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_and&#x27;)</td>
      <td width="280">2.0459992811083794e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_count&#x27;)</td>
      <td width="280">2.6969995815306902e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_not&#x27;)</td>
      <td width="280">1.4110002666711807e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_or&#x27;)</td>
      <td width="280">2.047000452876091e-05</td>
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
      <td width="280">0.001039345981553197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;ceil&#x27;)</td>
      <td width="280">5.889899330213666e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;deg2rad&#x27;)</td>
      <td width="280">0.00012534897541627288</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;degrees&#x27;)</td>
      <td width="280">0.0001273200032301247</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;equal&#x27;)</td>
      <td width="280">0.00011801003711298108</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;exp2&#x27;)</td>
      <td width="280">0.000859067018609494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fabs&#x27;)</td>
      <td width="280">0.00012707902351394296</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;floor&#x27;)</td>
      <td width="280">6.038998253643513e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;floor_divide&#x27;)</td>
      <td width="280">0.0003043190226890147</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fmax&#x27;)</td>
      <td width="280">0.00014841899974271655</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fmin&#x27;)</td>
      <td width="280">0.00014839996583759785</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;greater&#x27;)</td>
      <td width="280">0.00012523902114480734</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;greater_equal&#x27;)</td>
      <td width="280">0.00012722896644845605</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;invert&#x27;)</td>
      <td width="280">1.3940036296844482e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isfinite&#x27;)</td>
      <td width="280">7.579900557175279e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isinf&#x27;)</td>
      <td width="280">7.925997488200665e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isnan&#x27;)</td>
      <td width="280">6.888998905196786e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isnat&#x27;)</td>
      <td width="280">3.200257197022438e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;left_shift&#x27;)</td>
      <td width="280">2.4039996787905693e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;less&#x27;)</td>
      <td width="280">0.00012512999819591641</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;less_equal&#x27;)</td>
      <td width="280">0.0001241000136360526</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;log2&#x27;)</td>
      <td width="280">0.0012256749905645847</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_and&#x27;)</td>
      <td width="280">0.00016471900744363666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_not&#x27;)</td>
      <td width="280">9.708997095003724e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_or&#x27;)</td>
      <td width="280">0.00014558900147676468</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_xor&#x27;)</td>
      <td width="280">0.00015509896911680698</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;minimum&#x27;)</td>
      <td width="280">0.0001457299804314971</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;negative&#x27;)</td>
      <td width="280">8.283997885882854e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;positive&#x27;)</td>
      <td width="280">8.714897558093071e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;rad2deg&#x27;)</td>
      <td width="280">0.00012788898311555386</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;radians&#x27;)</td>
      <td width="280">0.00012464000610634685</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;reciprocal&#x27;)</td>
      <td width="280">0.0001851900015026331</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;right_shift&#x27;)</td>
      <td width="280">2.7130008675158024e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;rint&#x27;)</td>
      <td width="280">0.00011863000690937042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;true_divide&#x27;)</td>
      <td width="280">0.0002552390214987099</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;trunc&#x27;)</td>
      <td width="280">5.970901111140847e-05</td>
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
      <td width="280">0.0006364979781210423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002889989991672337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001145916001405567</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004802490002475679</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001743834000080824</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0007227279711514711</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0018920429865829647</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007372979889623821</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002563240996096283</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0010231569758616388</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002747630001977086</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012336060171946883</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0009987660450860858</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004186580190435052</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015680139767937362</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006395779782906175</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0020767030073329806</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008421470411121845</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0022855320130474865</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0008997170371003449</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002863159985281527</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0011944359866902232</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0030454390216618776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014148050104267895</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000590968003962189</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000287829025182873</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001109456003177911</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004778080037795007</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017144840094260871</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0006770379841327667</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001869024010375142</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007294270326383412</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0025282909628003836</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0009906860068440437</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0027535100234672427</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012011359794996679</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0009892259840853512</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004060590290464461</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015633039874956012</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006153580034151673</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0020869720028713346</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.000854356971103698</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.002321282052434981</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000868707022164017</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0028653699555434287</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012200860073789954</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0030410089530050755</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014484249986708164</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001153096032794565</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000489857979118824</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017615639953874052</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0007006769883446395</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0018625130178406835</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007123179966583848</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0025339609710499644</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0010433060233481228</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002700550016015768</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0012488249922171235</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0009785860311239958</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000435677997302264</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015759540256112814</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006151979905553162</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0021012030192650855</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008420980302616954</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0022964419913478196</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0008664769702591002</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0028814499964937568</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012527360231615603</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.003037989023141563</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014775749878026545</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0006178379990160465</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002901490079239011</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0011097759706899524</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004899589694105089</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017088539898395538</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0006918280269019306</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0018731339951045811</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007325870101340115</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002529291028622538</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0010413059499114752</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0027255110326223075</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.001227825996465981</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010244370205327868</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00042584905168041587</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001571625005453825</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006761780241504312</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002087122993543744</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008541670395061374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0023282619658857584</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0009076870046555996</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002879590028896928</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0012446659966371953</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.003054319997318089</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0014631639933213592</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004146090359427035</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003798289690166712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007287370390258729</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00040699902456253767</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012566559598781168</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005586679908446968</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001476114965043962</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005170879885554314</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020723030320368707</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007835270371288061</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024510109797120094</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.000982597004622221</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004156390205025673</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00038089900044724345</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007283270242623985</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00040305801667273045</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012261460069566965</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005613079993054271</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014422450331039727</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005255280411802232</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021142630139365792</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007294469978660345</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024975420092232525</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0009817659738473594</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004135679919272661</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00038029899587854743</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007021269993856549</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004005380324088037</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012067659990862012</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005678480374626815</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001431584998499602</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005567580228671432</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020759330363944173</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007478779880329967</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024702519876882434</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.000993807043414563</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004161489778198302</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000380788987968117</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007143469993025064</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00040787900798022747</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012653760495595634</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005608979845419526</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0015027850167825818</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000570718024391681</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002096682961564511</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007994769839569926</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024847619934007525</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010141259990632534</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007506170077249408</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004076380282640457</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012672849697992206</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005714480066671968</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0015014339587651193</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005627980572171509</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021332730539143085</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008504569996148348</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024666909594088793</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010687459725886583</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004237180110067129</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003800690174102783</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007743869791738689</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00040618900675326586</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012937950086779892</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005911280168220401</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014604550087824464</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006061680032871664</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021329320152290165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007736480329185724</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0025156610063277185</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010384370107203722</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004203380085527897</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00038184900768101215</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007516269688494503</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004037990001961589</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013160050148144364</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005857979995198548</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0015040540019981563</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005584780010394752</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00209473300492391</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007336079725064337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0025172620080411434</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010424659703858197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00042195897549390793</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00038118899101391435</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007278469856828451</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00041028897976502776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0012507059727795422</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005622180178761482</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014648750075139105</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005373579915612936</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002095901989378035</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0008034870261326432</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0025308519834652543</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0010073570301756263</td>
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
      <td width="280">4.534999607130885e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.6530039981007576e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">4.862999776378274e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">8.425000123679638e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">8.448900189250708e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">5.7030003517866135e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">5.701999180018902e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">4.872999852523208e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">7.98800028860569e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">8.22200090624392e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.4970016460865736e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.562997492030263e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.683900624513626e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">7.89299956522882e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">7.467000978067517e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">5.5800017435103655e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">5.641003372147679e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.717003321275115e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">7.398996967822313e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">7.608998566865921e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.627997986972332e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.675000673159957e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">5.071901250630617e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">0.0001142490073107183</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00011356902541592717</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">5.6469987612217665e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">5.715899169445038e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">5.047995364293456e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00011406000703573227</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00011557998368516564</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">4.501000512391329e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">4.597997758537531e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">4.6689994633197784e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">7.730000652372837e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">7.796904537826777e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">5.638995207846165e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">5.6559976655989885e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">4.6810018830001354e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">7.46200093999505e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">7.683003786951303e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.613999044522643e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.706898471340537e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">5.054997745901346e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">9.222899097949266e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00011456903303042054</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">5.754898302257061e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">5.7330005802214146e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">5.093001527711749e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00011331902351230383</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00011378899216651917</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.5160006266087294e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.622002597898245e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.791002720594406e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">9.730999590829015e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">9.980902541428804e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">5.670898826792836e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">5.7190016377717257e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.831998376175761e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">9.682896779850125e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">0.00010205997386947274</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.6079978346824646e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.736997652798891e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">6.1030033975839615e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">0.0001363889896310866</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00013619899982586503</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">5.595001857727766e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">5.773903103545308e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">5.994999082759023e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00013569998554885387</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00013667898019775748</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">5.759997293353081e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">9.229988791048527e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.0480016246438026e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.56100276298821e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">5.646003410220146e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">5.9800222516059875e-06</td>
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
      <td width="280">2.1230021957308054e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">5.6590011809021235e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">5.61299966648221e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.5460008550435305e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.6629982534796e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">4.857894964516163e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">8.326000533998013e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">7.963000098243356e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">5.650898674502969e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">5.656899884343147e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">4.86989738419652e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">8.153996895998716e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">8.52800440043211e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.509999416768551e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.5639986637979746e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.6639994252473116e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">7.664004806429148e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">7.526896661147475e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">5.678000161424279e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">5.574995884671807e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.7149951569736004e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">7.645896403118968e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">7.434998406097293e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.608999006450176e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.678900586441159e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">5.063996650278568e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">0.00011489901226013899</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00011451996397227049</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">5.688000237569213e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">5.770003190264106e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">5.077000241726637e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00011282000923529267</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00011384999379515648</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">4.536000778898597e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">4.586001159623265e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">4.675996024161577e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">7.756997365504503e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">7.39090028218925e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">5.603901809081435e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">5.584000609815121e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">4.727998748421669e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">7.508997805416584e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">7.687998004257679e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">4.591001197695732e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">4.6949018724262714e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">5.060998955741525e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">0.00011372898006811738</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00011335895396769047</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">5.684996722266078e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">5.743000656366348e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">5.0359987653791904e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00011164997704327106</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">0.0001137200160883367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">4.513002932071686e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">4.5689987018704414e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.92599792778492e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">9.724003029987216e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">9.914999827742577e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">5.640997551381588e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">5.6060031056404114e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.8839021474123e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">0.0001011500135064125</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">9.878003038465977e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">4.60590235888958e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">4.701002035290003e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">5.948002217337489e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">0.0001366700162179768</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.0001329490332864225</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">5.6200020480901e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">5.745899397879839e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">6.0079037211835384e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00013579899678006768</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">0.0001374190323986113</td>
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
      <td width="280">1.2199743650853634e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5199766494333744e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.1799933165311813e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.2999669201672077e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.3899559639394283e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.2500095181167126e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.568987499922514e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.200016751885414e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.3700489439070225e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.4500262700021267e-06</td>
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
      <td width="280">1.5299883671104908e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.209970261901617e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.4500262700021267e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.5199918784201145e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.2300442904233932e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.6100239008665085e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.2100284695625305e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.3800024539232254e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.400025889277458e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.2199743650853634e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.029992174357176e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.1799933165311813e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.390014171600342e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.3999676816165447e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.260021235793829e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5200348570942879e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.2199819795787334e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.400025889277458e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.3500255085527897e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.2100208550691605e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5700352378189564e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.1799933165311813e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.5400153137743473e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.3499673008918762e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.2200325727462769e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.6500125639140606e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.2400054149329662e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.4500262700021267e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.630004357546568e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">2.9199873097240925e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.799031790345907e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.6199850253760815e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.390029400587082e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.7800131142139435e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">2.929999027401209e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.7599744498729706e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.6500201784074306e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">5.400041118264198e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.740024451166391e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.4299876056611538e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.8599675968289375e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.969987690448761e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.740024451166391e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.700035788118839e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3999524526298046e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.8500140868127346e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.00002284348011e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.730012733489275e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.749977961182594e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3299868442118168e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.7999554984271526e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.7900096029043198e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.299974534660578e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.309986252337694e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3499520719051361e-06</td>
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
      <td width="280">4.300032742321491e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.299974534660578e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.500011421740055e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.8499558791518211e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.009976353496313e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.77995490655303e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.720001015812159e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.4300458133220673e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.8900027498602867e-06</td>
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
      <td width="280">4.67000063508749e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.709989298135042e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.2399978004395962e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5799887478351593e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.2400054149329662e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.45999500900507e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">5.469948519021273e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.2399978004395962e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.609965693205595e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.2500171326100826e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">5.500041879713535e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">5.479960236698389e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">3.2500247471034527e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">3.149965777993202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.8500217013061047e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.379959475249052e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">5.279958713799715e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">3.490014933049679e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">3.6800047382712364e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.7999707274138927e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">7.090042345225811e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">7.099995855242014e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.1899974197149277e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5700352378189564e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.149958163499832e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.4500262700021267e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.430002834647894e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.2199743650853634e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5500118024647236e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.22999369725585e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.609980922192335e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.5500270314514637e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8400023691356182e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.1400046534836292e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.7100322768092155e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.959983587265015e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.92901711165905e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8199789337813854e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.129992935806513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.040019121021032e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.0199956856667995e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8500140868127346e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.100015990436077e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.7400092221796513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.930006641894579e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.950030077248812e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8200371414422989e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.129992935806513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.939960151910782e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.130008164793253e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8500140868127346e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.160028088837862e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.769986167550087e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.9199949242174625e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.930006641894579e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8700375221669674e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.1400046534836292e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.760040272027254e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.049972631037235e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.0199956856667995e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.8799910321831703e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.129992935806513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.769986167550087e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.990018740296364e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.969995304942131e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.860025804489851e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.1400046534836292e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.7199857868254185e-06</td>
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
      <td width="280">4.009983967989683e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">3.0800001695752144e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.949964255094528e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.929999027401209e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.030015017837286e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.91004902869463e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">3.069988451898098e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.969987690448761e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.9199873097240925e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">5.02000330016017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.970002919435501e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.9100261852145195e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.2400054149329662e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.9900111258029938e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.458997864276171e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.430010449141264e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8400023691356182e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.2799940779805183e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.0100345611572266e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.489964339882135e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.5299530029296875e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.9000144675374031e-06</td>
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
      <td width="280">3.23000131174922e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.589965101331472e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.599976819008589e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.909967977553606e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.260028850287199e-06</td>
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
      <td width="280">4.699977580457926e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.750036168843508e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.9000144675374031e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.2400054149329662e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.009976353496313e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.5199994929134846e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.439963959157467e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8599675968289375e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.2599706426262856e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.009976353496313e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.510045982897282e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.490022547543049e-06</td>
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
      <td width="280">2.1500163711607456e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.869986928999424e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">6.0800230130553246e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">6.12996518611908e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8799910321831703e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">2.1400046534836292e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.800021320581436e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">6.10999995842576e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">6.099988240748644e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">3.360037226229906e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">3.3299438655376434e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">3.23000131174922e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.640031304210424e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">6.018963176757097e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">3.3800024539232254e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">3.290013410151005e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.769993782043457e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">5.599984433501959e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">5.7299621403217316e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.869979314506054e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">2.129992935806513e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.7500209398567677e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.949971869587898e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.209985490888357e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.8400023691356182e-06</td>
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
      <td width="280">2.7700443752110004e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.00003045797348e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.950030077248812e-06</td>
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
      <td width="280">0.00043647794518619776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.000436839007306844</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00043594796443358064</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0004518379573710263</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00043681799434125423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00043673900654539466</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000436578004155308</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0004369380185380578</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00043604796519503</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00045261799823492765</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00043678900692611933</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00043666799319908023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00041963800322264433</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">9.615003364160657e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020878895884379745</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007144969422370195</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0006573779974132776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00039039901457726955</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013078849879093468</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005632980028167367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005545679596252739</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0017290640389546752</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0006656469777226448</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007015470182523131</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.019541731977369636</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.023888805997557938</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0195528719923459</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.01950936100911349</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.02389057702384889</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.01944558200193569</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.019507902034092695</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.023925936955492944</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0194477720069699</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.01954907097388059</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.023895777005236596</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.01945790200261399</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004217979731038213</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003051720035728067</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021048897178843617</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006690180161967874</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030579299782402813</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000390278990380466</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013044949737377465</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030526790069416165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005480379913933575</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016157249920070171</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030569389928132296</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006162080098874867</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013082150253467262</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030666590319015086</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013054559822194278</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013124459655955434</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003073339001275599</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00130663497839123</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014616649714298546</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030715499888174236</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013327950146049261</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021633730502799153</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003075368993449956</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013489449629560113</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013084850506857038</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030653089634142816</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001305465993937105</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013115049805492163</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003073759959079325</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00130722502944991</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0015064749750308692</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003068290010560304</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001334316038992256</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002170021994970739</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030741989612579346</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013438559835776687</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00355952704558149</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005706440017092973</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0030040289857424796</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0035577969974838197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005706500029191375</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0030211099656298757</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.003623436961788684</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.005701980029698461</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0030219790060073137</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.003640668001025915</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.005707190022803843</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0030332590104080737</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013079450000077486</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030544499750249088</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013052860158495605</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013114649918861687</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030611089896410704</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013069449923932552</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001509674999397248</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030557289719581604</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001356405031401664</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0021737320348620415</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030607700464315712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001334285014308989</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004235990345478058</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003051389998290688</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021053897216916084</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006919080042280257</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003056169021874666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00038593902718275785</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013301749713718891</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030524299945682287</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005805279943160713</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001634185027796775</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003057038993574679</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006585780065506697</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.006209468003362417</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006256298976950347</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.003661106980871409</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.006224497978109866</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006258108012843877</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0036773569881916046</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.006216977955773473</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006256228021811694</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.003687717020511627</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.006239648966584355</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0062623179983347654</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0037202969542704523</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000712788023520261</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0013056749594397843</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000672466994728893</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007434370345436037</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0013055459712632</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007463869987986982</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0012082059984095395</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.001306775026023388</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007280179997906089</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013216760125942528</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0013073849841021001</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007912979926913977</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003381979768164456</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0006014980026520789</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00017793901497498155</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007209769682958722</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0006072879768908024</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00037495902506634593</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001374634972307831</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0006060280138626695</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005397879867814481</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0018720340449362993</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.000640737998764962</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000386058003641665</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00044107798021286726</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005030179745517671</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00043645803816616535</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.000756756984628737</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005087280296720564</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00044907897245138884</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014523650170303881</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005090879858471453</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005051589687354863</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002098043041769415</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005204489571042359</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000816916988696903</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001310435007326305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030669390107505023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001306746038608253</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013115759938955307</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00307551899459213</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001307935977820307</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014976849779486656</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003070578968618065</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013270950294099748</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002158643037546426</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003075669053941965</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001335625012870878</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013076150207780302</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030679700430482626</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013065449893474579</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013122360105626285</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030753290047869086</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001307866012211889</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0015223349910229445</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003071789047680795</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013265149900689721</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00216736295260489</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030780190136283636</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013351559755392373</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004221490235067904</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.002529001038055867</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021051900694146752</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.000743987038731575</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0025375009863637388</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00039754901081323624</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013388950028456748</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0025326110189780593</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005726779927499592</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001762534026056528</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.002536591957323253</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007634179783053696</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00042371900053694844</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003053748980164528</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020989897893741727</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007033279980532825</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003059340000618249</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00038673903327435255</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001335775014013052</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030550090014003217</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005704879877157509</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016148040303960443</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030594589770771563</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000627957982942462</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004254989908076823</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030534990364685655</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021032901713624597</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006795980152674019</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003057539986912161</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003852389636449516</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013553149765357375</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003055719018448144</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000553307996597141</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016079139895737171</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003060890012420714</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000694767979439348</td>
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
      <td width="280">0.0004359180456958711</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00043681799434125423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00043569901026785374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0004506880068220198</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0004362679901532829</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00043668795842677355</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00043594802264124155</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00043631799053400755</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00043564802035689354</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.000452787964604795</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0004362589679658413</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00043680804083123803</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004218280082568526</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">9.498000144958496e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020850897999480367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006793279899284244</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0006574279977940023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003847290063276887</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013829750241711736</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0006035179831087589</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005421480163931847</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015947039937600493</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0006605680100619793</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006208980339579284</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.011971018044278026</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.015567875991109759</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.011980598035734147</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.012027228018268943</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.015536385995801538</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.011985018034465611</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.011899329023435712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.01618608395801857</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.011926678009331226</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.011905877967365086</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.016192762996070087</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.01200444798450917</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00042432796908542514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030536289559677243</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020966900046914816</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0007089480059221387</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003058259026147425</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000387219013646245</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013682160060852766</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003054180007893592</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005988479824736714</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015997439622879028</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030597199802286923</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006208079867064953</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013058349722996354</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003067299025133252</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013065060484223068</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013106249971315265</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003077640023548156</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013070349814370275</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014871550374664366</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030707899713888764</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013286250177770853</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020304929930716753</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030784689588472247</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013365359627641737</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013075449969619513</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030700890347361565</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013056559837423265</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001311565050855279</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003073128988035023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013071650173515081</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014824139652773738</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030702489893883467</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001335586013738066</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020195430261082947</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030754789477214217</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.001338765025138855</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.003091150021646172</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0060445990529842675</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0029713499825447798</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0031182290404103696</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006053249002434313</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.002984398975968361</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0031425090273842216</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0060416089836508036</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0029857890331186354</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0031767089967615902</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006033569050487131</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0029983489657752216</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013056150055490434</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003054058994166553</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013055449817329645</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013158959918655455</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003058939997572452</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013070160057395697</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014663150068372488</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030558599974028766</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013335050316527486</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020050129969604313</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003060988965444267</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013362549943849444</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004237490356899798</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003049728984478861</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020922895055264235</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006731869652867317</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003056588990148157</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00048602797323837876</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013595559867098927</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030514090321958065</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005795980105176568</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016064640367403626</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030587890069000423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006484980112873018</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.005793290038127452</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006907806033268571</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.004853253019973636</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.005794778990093619</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006822076044045389</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.004869262978900224</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.005805289023555815</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0068038959871046245</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.004946391971316189</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.005812240007799119</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.006789126025978476</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.004926982976030558</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013063059886917472</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003067499026656151</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013056049938313663</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013119849609211087</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030740700312890112</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013067360268905759</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014891839819028974</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030667189857922494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013308650231920183</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0019865630310960114</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003075668995734304</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013342960155569017</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00130849500419572</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003065109020099044</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013051049900241196</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0013124849647283554</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030735990148968995</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013068760163150728</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014814450405538082</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.003068809979595244</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0013313749805092812</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0020479029626585543</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030764989787712693</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0013378949952311814</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00042515795212239027</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.002528700977563858</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00019598996732383966</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006724679842591286</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0025350310024805367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00039681902853772044</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013832649565301836</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0025321709690615535</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005547180189751089</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015970650129020214</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.002536310988944024</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007542870007455349</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004255989915691316</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030502700246870518</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00021064002066850662</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006856370018795133</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00305719900643453</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003903780016116798</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013561450177803636</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030522599699907005</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005791080184280872</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015954350237734616</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003056818968616426</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006626279791817069</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004233289510011673</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030524390167556703</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00020873895846307278</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006714279879815876</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030566289788112044</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00038692797534167767</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013302360312081873</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0030520990258082747</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005534380325116217</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016044939984567463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0030561889871023595</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006566279917024076</td>
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
      <td width="280">0.023974677023943514</td>
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
      <td width="280">0.004348994989413768</td>
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
      <td width="280">0.013955060974694788</td>
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
      <td width="280">0.0042359260260127485</td>
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
      <td width="280">0.007473614008631557</td>
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
      <td width="280">0.005248411034699529</td>
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
      <td width="280">0.0059172489563934505</td>
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
      <td width="280">0.10704883601283655</td>
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
      <td width="280">0.022890570980962366</td>
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
      <td width="280">0.07044319401029497</td>
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
      <td width="280">2.8009992092847824e-05</td>
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
      <td width="280">0.0059399790479801595</td>
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
      <td width="280">0.41573617997346446</td>
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
      <td width="280">0.06145497603574768</td>
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
      <td width="280">0.05843321600696072</td>
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
      <td width="280">0.11205361899919808</td>
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
      <td width="280">0.10261194198392332</td>
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
      <td width="280">0.06098697695415467</td>
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
      <td width="280">0.03267483599483967</td>
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
      <td width="280">0.14900763001060113</td>
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
      <td width="280">0.14905772998463362</td>
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
      <td width="280">0.0032922980026341975</td>
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
      <td width="280">1.444999361410737e-05</td>
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
      <td width="280">0.00467563298298046</td>
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
      <td width="280">0.14002326101763174</td>
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
      <td width="280">0.08802269300213084</td>
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
      <td width="280">0.24247506400570273</td>
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
      <td width="280">0.023400989011861384</td>
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
      <td width="280">0.03162058995803818</td>
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
      <td width="280">0.030023994971998036</td>
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
      <td width="280">0.11205769900698215</td>
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
      <td width="280">0.05766217899508774</td>
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
      <td width="280">0.061288127035368234</td>
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
      <td width="280">0.0020681030000559986</td>
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
      <td width="280">0.0643867559847422</td>
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
      <td width="280">0.02294415998039767</td>
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
      <td width="280">0.005058121983893216</td>
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
      <td width="280">0.06100504699861631</td>
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
      <td width="280">0.2450991949881427</td>
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
      <td width="280">0.04634508799063042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
