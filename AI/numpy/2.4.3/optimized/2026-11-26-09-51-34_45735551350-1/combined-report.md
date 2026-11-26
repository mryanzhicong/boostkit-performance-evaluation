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
      <td width="180">AI</td>
      <td width="220">numpy</td>
      <td width="160">2.4.3</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### numpy 2.4.3

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
      <td width="600">2.4.3</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">N/A</td>
      <td width="600">2.4.3</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">N/A</td>
      <td width="600">2026-11-26T01:38:16Z</td>
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
      <td width="600">2026-11-26T01:25:38Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">N/A</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">N/A</td>
      <td width="600">Kunpeng 950 7592C To Be Filled By O.E.M. CPU @ 2.3GHz</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 331481 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 368477 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 235717 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 347084 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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

## 单架构指标

### aarch64

#### numpy 2.4.3

##### aggregate_950.bench_reduce3.AddReduce

<table width="1380">
  <thead>
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
      <td width="280">0.017961580073460937</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_reduce3.AnyAll

<table width="1380">
  <thead>
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
      <td width="280">0.001686373958364129</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_reduce3.Argmin

<table width="1380">
  <thead>
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
      <td width="280">0.005338731920346618</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_reduce3.Max

<table width="1380">
  <thead>
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
      <td width="280">0.0023569620680063963</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_reduce3.Min

<table width="1380">
  <thead>
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
      <td width="280">0.004174296045675874</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_reduce3.Prod

<table width="1380">
  <thead>
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
      <td width="280">0.003285139100626111</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_reduce3.Var

<table width="1380">
  <thead>
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
      <td width="280">0.002032084157690406</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Abs

<table width="1380">
  <thead>
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
      <td width="280">0.06369707896374166</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Add

<table width="1380">
  <thead>
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
      <td width="280">0.01806075102649629</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Bitwise

<table width="1380">
  <thead>
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
      <td width="280">0.055528605822473764</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.BitwiseCount

<table width="1380">
  <thead>
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
      <td width="280">1.7449958249926567e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Broadcast

<table width="1380">
  <thead>
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
      <td width="280">0.004464035155251622</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Cbrt

<table width="1380">
  <thead>
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
      <td width="280">0.07106679491698742</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Ceil

<table width="1380">
  <thead>
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
      <td width="280">0.03172856499440968</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Comparison

<table width="1380">
  <thead>
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
      <td width="280">0.0422516199760139</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Deg

<table width="1380">
  <thead>
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
      <td width="280">0.05808805697597563</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Exp2

<table width="1380">
  <thead>
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
      <td width="280">0.07926328806206584</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Floor

<table width="1380">
  <thead>
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
      <td width="280">0.03202674398198724</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.FloorDivide

<table width="1380">
  <thead>
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
      <td width="280">0.0187291179317981</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Fmax

<table width="1380">
  <thead>
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
      <td width="280">0.11685163318179548</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Fmin

<table width="1380">
  <thead>
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
      <td width="280">0.1171518920455128</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Getitem

<table width="1380">
  <thead>
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
      <td width="280">0.0017491839826107025</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Invert

<table width="1380">
  <thead>
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
      <td width="280">1.103011891245842e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Is

<table width="1380">
  <thead>
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
      <td width="280">0.0031779389828443527</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Log2

<table width="1380">
  <thead>
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
      <td width="280">0.08198139909654856</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Logical

<table width="1380">
  <thead>
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
      <td width="280">0.05797637696377933</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Minimum

<table width="1380">
  <thead>
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
      <td width="280">0.1901086801663041</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Mul

<table width="1380">
  <thead>
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
      <td width="280">0.018411389086395502</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Neg

<table width="1380">
  <thead>
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
      <td width="280">0.025632974924519658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Pos

<table width="1380">
  <thead>
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
      <td width="280">0.023865930968895555</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Rad

<table width="1380">
  <thead>
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
      <td width="280">0.0582121170591563</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Reciprocal

<table width="1380">
  <thead>
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
      <td width="280">0.03213753295131028</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Rint

<table width="1380">
  <thead>
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
      <td width="280">0.03177644405514002</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Setitem

<table width="1380">
  <thead>
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
      <td width="280">0.0011859061196446419</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Shift

<table width="1380">
  <thead>
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
      <td width="280">0.04148446302860975</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Sub

<table width="1380">
  <thead>
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
      <td width="280">0.018169770017266273</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Truediv

<table width="1380">
  <thead>
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
      <td width="280">0.0035622180439531803</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc3.Trunc

<table width="1380">
  <thead>
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
      <td width="280">0.031691834796220064</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc_strides3.Maximum

<table width="1380">
  <thead>
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
      <td width="280">0.1916717749554664</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### aggregate_950.bench_ufunc_strides3.OnesLike

<table width="1380">
  <thead>
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
      <td width="280">0.038812071084976196</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_reduce.AddReduce

<table width="1380">
  <thead>
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
      <td width="280">0.004823773866519332</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduce.time_axis_1</td>
      <td width="280">0.0033081991132348776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_reduce.AddReduceSeparate

<table width="1380">
  <thead>
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
      <td width="280">9.43599734455347e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;float64&#x27;)</td>
      <td width="280">0.00021401885896921158</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int16&#x27;)</td>
      <td width="280">0.00010978011414408684</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int32&#x27;)</td>
      <td width="280">0.0001249699853360653</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(0, &#x27;int64&#x27;)</td>
      <td width="280">0.00019014999270439148</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;float32&#x27;)</td>
      <td width="280">7.918989285826683e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;float64&#x27;)</td>
      <td width="280">0.00017141993157565594</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int16&#x27;)</td>
      <td width="280">0.0002975589595735073</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int32&#x27;)</td>
      <td width="280">0.0003255489282310009</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AddReduceSeparate.time_reduce(1, &#x27;int64&#x27;)</td>
      <td width="280">0.0002089391928166151</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_reduce.AnyAll

<table width="1380">
  <thead>
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
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_all_slow</td>
      <td width="280">2.2801104933023453e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_any_fast</td>
      <td width="280">7.099006325006485e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.AnyAll.time_any_slow</td>
      <td width="280">2.349959686398506e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_reduce.ArgMin

<table width="1380">
  <thead>
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
      <td width="280">4.010042175650597e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">1.6479985788464546e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">4.740990698337555e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">7.180031388998032e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">1.6330042853951454e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">4.880898632109165e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">3.940192982554436e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">7.230089977383614e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">1.6248784959316254e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.ArgMin.time_argmin(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">4.988000728189945e-05</td>
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

##### bench_reduce.FMinMax

<table width="1380">
  <thead>
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
      <td width="280">1.90013088285923e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.FMinMax.time_min(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">1.8998980522155762e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.FMinMax.time_min(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">2.8600916266441345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_reduce.StatsReductions

<table width="1380">
  <thead>
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
      <td width="280">1.5799887478351593e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;float32&#x27;)</td>
      <td width="280">1.600012183189392e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_max(&#x27;uint64&#x27;)</td>
      <td width="280">1.669861376285553e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;bool_&#x27;)</td>
      <td width="280">1.5299301594495773e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;float32&#x27;)</td>
      <td width="280">1.5900004655122757e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;float64&#x27;)</td>
      <td width="280">1.6598496586084366e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;int64&#x27;)</td>
      <td width="280">1.600012183189392e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_min(&#x27;uint64&#x27;)</td>
      <td width="280">1.6598496586084366e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;bool_&#x27;)</td>
      <td width="280">2.489890903234482e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;float32&#x27;)</td>
      <td width="280">1.7900019884109497e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;float64&#x27;)</td>
      <td width="280">1.7499551177024841e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;int64&#x27;)</td>
      <td width="280">1.7799902707338333e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_prod(&#x27;uint64&#x27;)</td>
      <td width="280">1.800013706088066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;bool_&#x27;)</td>
      <td width="280">4.519941285252571e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;float32&#x27;)</td>
      <td width="280">4.159985110163689e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;float64&#x27;)</td>
      <td width="280">4.119006916880608e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;int64&#x27;)</td>
      <td width="280">3.719935193657875e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_reduce.StatsReductions.time_var(&#x27;uint64&#x27;)</td>
      <td width="280">3.769993782043457e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.Broadcast

<table width="1380">
  <thead>
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
      <td width="280">0.004638924030587077</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.CustomComparison

<table width="1380">
  <thead>
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
      <td width="280">2.550194039940834e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">6.090151146054268e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">1.2958887964487076e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">3.43983992934227e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">5.770009011030197e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">1.279008574783802e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.349959686398506e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">3.590015694499016e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">6.1800237745046616e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">1.3140030205249786e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_binary(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">2.119923010468483e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">2.420041710138321e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">5.109934136271477e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">9.089941158890724e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">3.050081431865692e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">5.170004442334175e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">9.139999747276306e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.400018274784088e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">3.149965777993202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">5.2300747483968735e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">9.34000127017498e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar1(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">2.45007686316967e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.bool&#x27;&gt;)</td>
      <td width="280">2.420041710138321e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.float32&#x27;&gt;)</td>
      <td width="280">5.2300747483968735e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.float64&#x27;&gt;)</td>
      <td width="280">9.269919246435165e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int16&#x27;&gt;)</td>
      <td width="280">3.0801165848970413e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int32&#x27;&gt;)</td>
      <td width="280">5.220063030719757e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int64&#x27;&gt;)</td>
      <td width="280">9.299954399466515e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.int8&#x27;&gt;)</td>
      <td width="280">2.4298205971717834e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint16&#x27;&gt;)</td>
      <td width="280">3.2100360840559006e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint32&#x27;&gt;)</td>
      <td width="280">5.290145054459572e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint64&#x27;&gt;)</td>
      <td width="280">9.159790351986885e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomComparison.time_less_than_scalar2(&lt;class &#x27;numpy.uint8&#x27;&gt;)</td>
      <td width="280">3.6901328712701797e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.CustomScalarFloorDivideInt

<table width="1380">
  <thead>
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
      <td width="280">3.79001721739769e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, -8)</td>
      <td width="280">3.769993782043457e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, 43)</td>
      <td width="280">3.719935193657875e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int16&#x27;&gt;, 8)</td>
      <td width="280">3.7299469113349915e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, -43)</td>
      <td width="280">4.509929567575455e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, -8)</td>
      <td width="280">4.519941285252571e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, 43)</td>
      <td width="280">4.519941285252571e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int32&#x27;&gt;, 8)</td>
      <td width="280">4.520174115896225e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, -43)</td>
      <td width="280">7.630093023180962e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, -8)</td>
      <td width="280">7.529975846409798e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, 43)</td>
      <td width="280">7.639871910214424e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int64&#x27;&gt;, 8)</td>
      <td width="280">7.509952411055565e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, -43)</td>
      <td width="280">2.4100299924612045e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, -8)</td>
      <td width="280">2.4801120162010193e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, 43)</td>
      <td width="280">2.4598557502031326e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.int8&#x27;&gt;, 8)</td>
      <td width="280">2.4598557502031326e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, -43)</td>
      <td width="280">7.4801500886678696e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, -8)</td>
      <td width="280">7.509952411055565e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, 43)</td>
      <td width="280">7.4801500886678696e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideInt.time_floor_divide_int(&lt;class &#x27;numpy.longlong&#x27;&gt;, 8)</td>
      <td width="280">7.45011493563652e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.CustomScalarFloorDivideUInt

<table width="1380">
  <thead>
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
      <td width="280">2.320157364010811e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint16&#x27;&gt;, 8)</td>
      <td width="280">2.320157364010811e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint32&#x27;&gt;, 43)</td>
      <td width="280">1.949956640601158e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint32&#x27;&gt;, 8)</td>
      <td width="280">2.0100269466638565e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint64&#x27;&gt;, 43)</td>
      <td width="280">9.950017556548119e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint64&#x27;&gt;, 8)</td>
      <td width="280">9.960029274225235e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint8&#x27;&gt;, 43)</td>
      <td width="280">1.7499551177024841e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.uint8&#x27;&gt;, 8)</td>
      <td width="280">1.7499551177024841e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.ulonglong&#x27;&gt;, 43)</td>
      <td width="280">9.990064427256584e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.CustomScalarFloorDivideUInt.time_floor_divide_uint(&lt;class &#x27;numpy.ulonglong&#x27;&gt;, 8)</td>
      <td width="280">9.960029274225235e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.MethodsV0

<table width="1380">
  <thead>
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
      <td width="280">5.799811333417892e-07</td>
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
      <td width="280">6.400514394044876e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.700865924358368e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__abs__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.398186087608337e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.100162863731384e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">6.200280040502548e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.00004568696022e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.00004568696022e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__neg__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.100162863731384e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.898771971464157e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">6.600748747587204e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV0.time_ndarray_meth(&#x27;__pos__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.200280040502548e-07</td>
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
      <td width="280">6.100162863731384e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.MethodsV1

<table width="1380">
  <thead>
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
      <td width="280">7.499475032091141e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.901100277900696e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.099006325006485e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__add__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.901100277900696e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.099006325006485e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.898771971464157e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.299240678548813e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__eq__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.201451808214188e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
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
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ge__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.099006325006485e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.099006325006485e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.299240678548813e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.901100277900696e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.299240678548813e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__gt__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.499475032091141e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__le__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.00121745467186e-07</td>
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
      <td width="280">7.299240678548813e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.00121745467186e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.800983101129532e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.00121745467186e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__lt__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.00121745467186e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.201451808214188e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__mul__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.599592208862305e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.299240678548813e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.299240678548813e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.201451808214188e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.00121745467186e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__ne__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">7.101334631443024e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">7.399357855319977e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">7.199123501777649e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">7.099006325006485e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__sub__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">7.301568984985352e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;float32&#x27;)</td>
      <td width="280">1.2100208550691605e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;float64&#x27;)</td>
      <td width="280">1.1899974197149277e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.1802185326814651e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.1799857020378113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1.time_ndarray_meth(&#x27;__truediv__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.2300442904233932e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.MethodsV1IntOnly

<table width="1380">
  <thead>
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
      <td width="280">6.498303264379501e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.698537617921829e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__and__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.898771971464157e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.800983101129532e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__or__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.901100277900696e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">6.898771971464157e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.MethodsV1IntOnly.time_ndarray_meth(&#x27;__xor__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">6.998889148235321e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.NDArrayGetItem

<table width="1380">
  <thead>
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
      <td width="280">3.6996789276599884e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((-1, 0), &#x27;small&#x27;)</td>
      <td width="280">3.6996789276599884e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((0, 0), &#x27;big&#x27;)</td>
      <td width="280">4.00003045797348e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem((0, 0), &#x27;small&#x27;)</td>
      <td width="280">3.8999132812023163e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem(0, &#x27;big&#x27;)</td>
      <td width="280">3.7997961044311523e-07</td>
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
      <td width="280">9.699724614620209e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayGetItem.time_methods_getitem([0, -1], &#x27;small&#x27;)</td>
      <td width="280">9.599607437849045e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.NDArrayLRShifts

<table width="1380">
  <thead>
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
      <td width="280">1.2600794434547424e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.2498348951339722e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;int8&#x27;)</td>
      <td width="280">1.1399388313293457e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;intp&#x27;)</td>
      <td width="280">1.3201497495174408e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint16&#x27;)</td>
      <td width="280">1.2400560081005096e-06</td>
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
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__lshift__&#x27;, &#x27;uint8&#x27;)</td>
      <td width="280">1.1101365089416504e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int16&#x27;)</td>
      <td width="280">1.2400560081005096e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int32&#x27;)</td>
      <td width="280">1.2801028788089752e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int64&#x27;)</td>
      <td width="280">1.3899989426136017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;int8&#x27;)</td>
      <td width="280">1.1399388313293457e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;intp&#x27;)</td>
      <td width="280">1.3399403542280197e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint16&#x27;)</td>
      <td width="280">1.2100208550691605e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint32&#x27;)</td>
      <td width="280">1.2901145964860916e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint64&#x27;)</td>
      <td width="280">1.400010660290718e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArrayLRShifts.time_ndarray_meth(&#x27;__rshift__&#x27;, &#x27;uint8&#x27;)</td>
      <td width="280">1.0998919606208801e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.NDArraySetItem

<table width="1380">
  <thead>
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
      <td width="280">3.0011869966983795e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((-1, 0), &#x27;small&#x27;)</td>
      <td width="280">2.00001522898674e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((0, 0), &#x27;big&#x27;)</td>
      <td width="280">2.9010698199272156e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem((0, 0), &#x27;small&#x27;)</td>
      <td width="280">2.100132405757904e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem(0, &#x27;big&#x27;)</td>
      <td width="280">5.699694156646729e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem(0, &#x27;small&#x27;)</td>
      <td width="280">1.8998980522155762e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem([0, -1], &#x27;big&#x27;)</td>
      <td width="280">1.1301599442958832e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.NDArraySetItem.time_methods_setitem([0, -1], &#x27;small&#x27;)</td>
      <td width="280">2.200249582529068e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc.UFunc

<table width="1380">
  <thead>
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
      <td width="280">6.884988397359848e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_and&#x27;)</td>
      <td width="280">1.4399876818060875e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_count&#x27;)</td>
      <td width="280">1.6910023987293243e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_not&#x27;)</td>
      <td width="280">1.0489951819181442e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_or&#x27;)</td>
      <td width="280">1.4459947124123573e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;bitwise_xor&#x27;)</td>
      <td width="280">1.458008773624897e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;cbrt&#x27;)</td>
      <td width="280">0.00017492915503680706</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;ceil&#x27;)</td>
      <td width="280">1.9459985196590424e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;deg2rad&#x27;)</td>
      <td width="280">2.4499837309122086e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;degrees&#x27;)</td>
      <td width="280">4.314887337386608e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;equal&#x27;)</td>
      <td width="280">8.989009074866772e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;exp2&#x27;)</td>
      <td width="280">0.0006265980191528797</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fabs&#x27;)</td>
      <td width="280">2.3409957066178322e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;floor&#x27;)</td>
      <td width="280">1.952890306711197e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;floor_divide&#x27;)</td>
      <td width="280">0.00019164918921887875</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fmax&#x27;)</td>
      <td width="280">0.00010476005263626575</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;fmin&#x27;)</td>
      <td width="280">0.00010521919466555119</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;greater&#x27;)</td>
      <td width="280">9.356904774904251e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;greater_equal&#x27;)</td>
      <td width="280">9.394902735948563e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;invert&#x27;)</td>
      <td width="280">1.0159099474549294e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isfinite&#x27;)</td>
      <td width="280">5.902000702917576e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isinf&#x27;)</td>
      <td width="280">5.672895349562168e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isnan&#x27;)</td>
      <td width="280">5.3560128435492516e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;isnat&#x27;)</td>
      <td width="280">2.300366759300232e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;left_shift&#x27;)</td>
      <td width="280">1.5849946066737175e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;less&#x27;)</td>
      <td width="280">9.094993583858013e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;less_equal&#x27;)</td>
      <td width="280">9.336997754871845e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;log2&#x27;)</td>
      <td width="280">0.0008345171809196472</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_and&#x27;)</td>
      <td width="280">0.00011948985047638416</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_not&#x27;)</td>
      <td width="280">4.876009188592434e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_or&#x27;)</td>
      <td width="280">0.00011096987873315811</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;logical_xor&#x27;)</td>
      <td width="280">0.0001113000325858593</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;minimum&#x27;)</td>
      <td width="280">8.249888196587563e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;negative&#x27;)</td>
      <td width="280">5.897902883589268e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;positive&#x27;)</td>
      <td width="280">6.438908167183399e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;rad2deg&#x27;)</td>
      <td width="280">2.4270033463835716e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;radians&#x27;)</td>
      <td width="280">4.190998151898384e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;reciprocal&#x27;)</td>
      <td width="280">5.707982927560806e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;right_shift&#x27;)</td>
      <td width="280">1.6750069335103035e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;rint&#x27;)</td>
      <td width="280">6.271013990044594e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;true_divide&#x27;)</td>
      <td width="280">0.00013274885714054108</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc.UFunc.time_ufunc_types(&#x27;trunc&#x27;)</td>
      <td width="280">1.9690021872520447e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc_strides.BinaryFP

<table width="1380">
  <thead>
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
      <td width="280">0.00047321803867816925</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00023512891493737698</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0009076769929379225</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003676291089504957</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013466950040310621</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005385780241340399</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014515649527311325</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005490980111062527</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0019903441425412893</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007904770318418741</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024232419673353434</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0009539669845253229</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007601280231028795</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00031623896211385727</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0012650659773498774</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005046878941357136</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.001706243958324194</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0006570180412381887</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017563439905643463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006804880686104298</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002275332110002637</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0009314871858805418</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0027929909992963076</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0011516869999468327</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00048380810767412186</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0002266201190650463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008889769669622183</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00036774901673197746</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013258459512144327</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005380578804761171</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0013917060568928719</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005298389587551355</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0019770939834415913</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000771556980907917</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024380218237638474</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0009443769231438637</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007759069558233023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003116689622402191</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0012414657976478338</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005082990974187851</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0016880249604582787</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0006663079839199781</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001747654052451253</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0007124671246856451</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.002289782976731658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0009413270745426416</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0027477210387587547</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0011251959949731827</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008934170473366976</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003802988212555647</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013487259857356548</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005382881499826908</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0014256350696086884</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000534979160875082</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0019457940943539143</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007689879275858402</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024033519439399242</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0009708160068839788</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007553671021014452</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00032872799783945084</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0012644550297409296</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005192579701542854</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017438640352338552</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0006335480138659477</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017682639881968498</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006650278810411692</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0022746731992810965</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0009517171420156956</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002759551163762808</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0011220260057598352</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0004832278937101364</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00023582903668284416</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0008880468085408211</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003696491476148367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0013311549555510283</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0005351579748094082</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001421045046299696</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0005607081111520529</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0019871739204972982</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0007754871621727943</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0024652420543134212</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0009705869015306234</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0007394279818981886</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00031493883579969406</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0012641160283237696</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000494958832859993</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0017225539777427912</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0006359580438584089</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0017145241145044565</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0006813579238951206</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0023134821094572544</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0009356669615954161</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002784420968964696</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0011412468738853931</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003150990232825279</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00017474894411861897</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005746381357312202</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003193388693034649</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0010040861088782549</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00044382805936038494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010875770822167397</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00043924804776906967</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016519639175385237</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006198480259627104</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0020852829329669476</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.000793596962466836</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003144489601254463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0001748991198837757</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005667777732014656</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00031379912979900837</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0009733070619404316</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0004395588766783476</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001137186074629426</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004395581781864166</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016311050858348608</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006104279309511185</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0021093529649078846</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmax&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008086070884019136</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003089990932494402</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00017506000585854053</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005747578106820583</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00031410902738571167</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0009691370651125908</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00043718889355659485</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0011079059913754463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003974991850554943</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016130940057337284</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005612680688500404</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0020688530057668686</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0007754580583423376</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00031488901004195213</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00018186005763709545</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005757680628448725</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00031594885513186455</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.00098675605840981</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00043585803359746933</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010882560163736343</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00044332793913781643</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001627525081858039</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006368870381265879</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002076792996376753</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;fmin&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008118872065097094</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005864980630576611</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00031959894113242626</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0009844559244811535</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0004387879744172096</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0011177759151905775</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00041837897151708603</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016462651547044516</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006459068972617388</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0020841029472649097</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.000790187856182456</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00031276908703148365</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0001767298672348261</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.000556678045541048</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00031622895039618015</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0009568571113049984</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0004404778592288494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0011126059107482433</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004199279937893152</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016300550196319818</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005829089786857367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002064173109829426</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00080710812471807</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003061089664697647</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00018975883722305298</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005773380398750305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00031715910881757736</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0009471871890127659</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.00044132815673947334</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001098256092518568</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00041730795055627823</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016199040692299604</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005743079818785191</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.002096393145620823</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008037278894335032</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003074989654123783</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0001775489654392004</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005795578472316265</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00032170885242521763</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0009596669115126133</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0004364491906017065</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010866071097552776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00043382798321545124</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016488651745021343</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006179078482091427</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;d&#x27;)</td>
      <td width="280">0.0021205528173595667</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryFP.time_binary_scalar_in0(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 4, 4, &#x27;f&#x27;)</td>
      <td width="280">0.0008250870741903782</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc_strides.BinaryInt

<table width="1380">
  <thead>
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
      <td width="280">3.5789795219898224e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">3.590993583202362e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">4.2049912735819817e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">6.862008012831211e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">7.050903514027596e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">3.5929959267377853e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">3.607012331485748e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">4.170997999608517e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">6.751017645001411e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">6.963987834751606e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">3.5709934309124947e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">3.605987876653671e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.037912003695965e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">6.392993964254856e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">6.122910417616367e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">3.56798991560936e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">3.6120181903243065e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.0049897506833076e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">6.093992851674557e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">5.988008342683315e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">3.5869888961315155e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">3.653019666671753e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">4.1869934648275375e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">9.157019667327404e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">9.253993630409241e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">3.5899924114346504e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">3.648991696536541e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">4.1950028389692307e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">9.153992868959904e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 1, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">9.097903966903687e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">3.557000309228897e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">3.600004129111767e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">4.0140002965927124e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">6.402004510164261e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">6.434996612370014e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">3.571901470422745e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">3.6079902201890945e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">4.016002640128136e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">6.184889934957027e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">6.128009408712387e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">3.584008663892746e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">3.660004585981369e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">4.1999854147434235e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">9.175995364785194e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">9.069009684026241e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">3.582984209060669e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">3.679003566503525e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">4.191999323666096e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">9.247008711099625e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">9.088916704058647e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">3.582006320357323e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">3.667990677058697e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.088995046913624e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">8.329004049301147e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">8.499901741743088e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">3.569992259144783e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">3.637000918388367e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.1040126234292984e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">8.177896961569786e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">8.520996198058128e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">3.597000613808632e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">3.684987314045429e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">4.745996557176113e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">0.00010480009950697422</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00010508904233574867</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">3.620004281401634e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">3.70789784938097e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">4.7669047489762306e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00010586995631456375</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;maximum&#x27;&gt;, 2, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00010488880798220634</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">3.959983587265015e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">6.67991116642952e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.862994395196438e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.657008685171604e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">5.036010406911373e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">3.930181264877319e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">7.109949365258217e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.6629928722977638e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.462897777557373e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">5.029002204537392e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">3.574998117983341e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">3.6088982596993446e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">4.16699331253767e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">7.0229172706604e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">6.961985491216183e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">3.578001633286476e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">3.62698920071125e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">4.191999323666096e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">7.18201044946909e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">7.158983498811722e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">3.564916551113129e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">3.60200647264719e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.016002640128136e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">6.156903691589832e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">6.019999273121357e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">3.580981865525246e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">3.577978350222111e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.0049897506833076e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">6.083003245294094e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">6.0660066083073616e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">3.5899924114346504e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">3.6250101402401924e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">4.189019091427326e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">9.17601864784956e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">9.154900908470154e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">3.5798875615000725e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">3.652903251349926e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">4.1950028389692307e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">9.116018190979958e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 1, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">9.161001071333885e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">3.572017885744572e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">3.6079902201890945e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">4.0190061554312706e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">6.288010627031326e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">6.242911331355572e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">3.5770004615187645e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">3.60200647264719e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.996002487838268e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">6.232899613678455e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">6.057904101908207e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;B&#x27;)</td>
      <td width="280">3.582984209060669e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;H&#x27;)</td>
      <td width="280">3.629992716014385e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;I&#x27;)</td>
      <td width="280">4.222989082336426e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;L&#x27;)</td>
      <td width="280">9.122909978032112e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;Q&#x27;)</td>
      <td width="280">8.99790320545435e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;b&#x27;)</td>
      <td width="280">3.589899279177189e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;h&#x27;)</td>
      <td width="280">3.63900326192379e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;i&#x27;)</td>
      <td width="280">4.208995960652828e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;l&#x27;)</td>
      <td width="280">9.101000614464283e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 1, 2, &#x27;q&#x27;)</td>
      <td width="280">9.206985123455524e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;B&#x27;)</td>
      <td width="280">3.578001633286476e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;H&#x27;)</td>
      <td width="280">3.621005453169346e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;I&#x27;)</td>
      <td width="280">4.0899962186813354e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;L&#x27;)</td>
      <td width="280">8.413009345531464e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;Q&#x27;)</td>
      <td width="280">8.449004963040352e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;b&#x27;)</td>
      <td width="280">3.627012483775616e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;h&#x27;)</td>
      <td width="280">3.614998422563076e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;i&#x27;)</td>
      <td width="280">4.046992398798466e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;l&#x27;)</td>
      <td width="280">8.361903019249439e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 1, &#x27;q&#x27;)</td>
      <td width="280">8.59301071614027e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;B&#x27;)</td>
      <td width="280">3.590993583202362e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;H&#x27;)</td>
      <td width="280">3.691995516419411e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;I&#x27;)</td>
      <td width="280">4.755007103085518e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;L&#x27;)</td>
      <td width="280">0.0001062699593603611</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;Q&#x27;)</td>
      <td width="280">0.00010560010559856892</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;b&#x27;)</td>
      <td width="280">3.584008663892746e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;h&#x27;)</td>
      <td width="280">3.732996992766857e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;i&#x27;)</td>
      <td width="280">4.763016477227211e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;l&#x27;)</td>
      <td width="280">0.00010608998127281666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryInt.time_binary(&lt;ufunc &#x27;minimum&#x27;&gt;, 2, 2, 2, &#x27;q&#x27;)</td>
      <td width="280">0.00010357005521655083</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc_strides.BinaryIntContig

<table width="1380">
  <thead>
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
      <td width="280">9.099021553993225e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1699739843606949e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.6700942069292068e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.6300549507141113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.6300549507141113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.099021553993225e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.150183379650116e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.6398262232542038e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.669868990778923e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.6300549507141113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">8.998904377222061e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1599622666835785e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.6901176422834396e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.6598572731018066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.6097986847162247e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.101349860429764e-07</td>
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
      <td width="280">1.6798730939626694e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.650078386068344e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.6400666683912277e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">8.901115506887436e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1899974197149277e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.6901176422834396e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.7299392968416214e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.670101821422577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.0100193321704865e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.1899974197149277e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.6700942069292068e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.669868990778923e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.670101821422577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">8.998904377222061e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.1399388313293457e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.7099082469940186e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.6798807084560394e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.7101486921310425e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.101349860429764e-07</td>
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
      <td width="280">1.6700942069292068e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.650078386068344e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.7099158614873886e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.301584213972092e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.3099052011966705e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.90013088285923e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.539957106113434e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.539964720606804e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.499490261077881e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.3099052011966705e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.9101426005363464e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.420049324631691e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.54997643828392e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.0100193321704865e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.3899989426136017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.149958163499832e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.79001721739769e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.620050847530365e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.0100193321704865e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.149958163499832e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.6498531699180603e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.590015694499016e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.699724614620209e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.300126314163208e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.969980075955391e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.2801181077957153e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.470107913017273e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.799841791391373e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.3399403542280197e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.9900035113096237e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.3800024539232254e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.2901298254728317e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.0300427675247192e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.119923010468483e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.6100391298532486e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.6100391298532486e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.019798219203949e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.1399464458227158e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.6100391298532486e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.6400742828845978e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">8.998904377222061e-07</td>
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
      <td width="280">1.6998965293169022e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">4.0298327803611755e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.059867933392525e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.099021553993225e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.6600824892520905e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.650070771574974e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.040077328681946e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">4.059867933392525e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">9.899958968162537e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.3299286365509033e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.0600855350494385e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.970220521092415e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.5800115913152695e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.00000761449337e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.3899989426136017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.7799978852272034e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.4100376069545746e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">5.420064553618431e-06</td>
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
      <td width="280">1.1599622666835785e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.669861376285553e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.6598572731018066e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">2.6901252567768097e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">9.199138730764389e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.1802185326814651e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.6801059246063232e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">2.6400666683912277e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">2.6600901037454605e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.4100223779678345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.650070771574974e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.1799933165311813e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.169989213347435e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.149965777993202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.6600824892520905e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.1399464458227158e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.149965777993202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;add&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.170222043991089e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.650070771574974e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.169981598854065e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.149965777993202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.149965777993202e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3599637895822525e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.650070771574974e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.1399464458227158e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.200024366378784e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.2100360840559006e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.650070771574974e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.1799933165311813e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.2300595194101334e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.139954060316086e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.419801265001297e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.6398262232542038e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.1602027118206024e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.2600946724414825e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.1800009310245514e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.4097895473241806e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.6400590538978577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.1399464458227158e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.1401868909597397e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.220047801733017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.6801059246063232e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.1900050342082977e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.1299423426389694e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;bitwise_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.239838406443596e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.6400590538978577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.2801104933023453e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.6999117583036423e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.689900040626526e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.419801265001297e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5900004655122757e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.2600870579481125e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.689900040626526e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;left_shift&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.6798883229494095e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.4300458133220673e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.7399434000253677e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.349959686398506e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.6400742828845978e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.620050847530365e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.4200340956449509e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.6998965293169022e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.349959686398506e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.619818016886711e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_and&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.639841452240944e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.5099067240953445e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.250067725777626e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">1.319916918873787e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">1.2998934835195541e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">1.2898817658424377e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.4801044017076492e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.3299286365509033e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">1.300126314163208e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">1.2998934835195541e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_or&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">1.2798700481653214e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.4598481357097626e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.7499551177024841e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.3900065571069717e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.5800039768218994e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.600027412176132e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.4598481357097626e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.7499551177024841e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.369983121752739e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.590015694499016e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;logical_xor&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.6498531699180603e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3899989426136017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.6298145055770874e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.1599698811769485e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">5.250098183751106e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">5.290145054459572e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.6400590538978577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.170214429497719e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">4.270114004611969e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;multiply&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">5.249865353107452e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.3899989426136017e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.5799887478351593e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.420041710138321e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">2.8598587960004807e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">4.200031980872154e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.4100223779678345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.5799887478351593e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;right_shift&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">3.100140020251274e-06</td>
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
      <td width="280">4.149973392486572e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;B&#x27;)</td>
      <td width="280">1.4100223779678345e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;H&#x27;)</td>
      <td width="280">1.6398262232542038e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;I&#x27;)</td>
      <td width="280">2.1099112927913666e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;L&#x27;)</td>
      <td width="280">3.1401868909597397e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;Q&#x27;)</td>
      <td width="280">3.1599774956703186e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;b&#x27;)</td>
      <td width="280">1.3799872249364853e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;h&#x27;)</td>
      <td width="280">1.6400590538978577e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;i&#x27;)</td>
      <td width="280">2.200016751885414e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;l&#x27;)</td>
      <td width="280">3.1800009310245514e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.BinaryIntContig.time_binary_scalar_in0(&lt;ufunc &#x27;subtract&#x27;&gt;, 1, 1, 1, &#x27;q&#x27;)</td>
      <td width="280">3.120163455605507e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc_strides.UnaryFP

<table width="1380">
  <thead>
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
      <td width="280">0.000385708874091506</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003854690585285425</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00038558896631002426</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0003861989825963974</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00038579897955060005</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00038617895916104317</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003854490350931883</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003855989780277014</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003853989765048027</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00038590910844504833</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00038578896783292294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003857689443975687</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002906189765781164</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.569021545350552e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014343997463583946</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005960881244391203</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005361379589885473</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002712300047278404</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010906558018177748</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005031989421695471</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004495191387832165</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016173450276255608</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.000514838146045804</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006413580849766731</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0035742581821978092</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.002021342981606722</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016120951622724533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0037352570798248053</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.002014503115788102</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0024254119489341974</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.003758847014978528</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0025598108768463135</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0024567418731749058</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00378195708617568</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.002550640841946006</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.002463461132720113</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00029427907429635525</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.72690400481224e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014721998013556004</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005277278833091259</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00028134905733168125</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00026419898495078087</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001065337099134922</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00032715918496251106</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00042857788503170013</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015083849430084229</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005733580328524113</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005842479877173901</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000309778843075037</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00011677015572786331</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0001542489044368267</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005898680537939072</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00035730889067053795</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00026792893186211586</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001066346187144518</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00032477895729243755</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004126389976590872</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016317241825163364</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0008438769727945328</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006232180166989565</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00031020911410450935</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0019221140537410975</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00015222979709506035</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005960278213024139</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0019267040770500898</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000269508920609951</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010480859782546759</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0019252730999141932</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004256481770426035</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016453750431537628</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0019243941642343998</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000613468000665307</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001749795163050294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0013544049579650164</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0015260148793458939</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0018377238884568214</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.004534275038167834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0015823750291019678</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.002602161141112447</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.002773549873381853</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.002321511972695589</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0025933110155165195</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0016970050055533648</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0023173829540610313</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002924390137195587</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.335003465414047e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014505884610116482</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0006041079759597778</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005793778691440821</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002768689300864935</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00108269602060318</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005038080271333456</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.000430879183113575</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016044049989432096</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005207080394029617</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006611880380660295</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002962290309369564</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.736985571682453e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0001476991456001997</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005416478961706161</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.000280959066003561</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002622290048748255</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010814869310706854</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00032820901833474636</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004519089125096798</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015456348191946745</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005741380155086517</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005508780013769865</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0033690291456878185</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0015193349681794643</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001535884803161025</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0034285890869796276</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.002763870870694518</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0015814751386642456</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0034633679315447807</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0027706208638846874</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.001670704921707511</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.003461088053882122</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.003879767144098878</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0017593740485608578</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00019434886053204536</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">6.299000233411789e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">9.212992154061794e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0004150089807808399</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00028790906071662903</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00040896888822317123</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0009504370391368866</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.000281098997220397</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00044280895963311195</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00101747689768672</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00029378896579146385</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;logical_not&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0004478190094232559</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00030905893072485924</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005759280174970627</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014261901378631592</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005770178977400064</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005804779939353466</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002661591861397028</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010812070686370134</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005793590098619461</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004539978690445423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016426949296146631</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005872079636901617</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;negative&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002649391535669565</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00039288890548050404</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0004347790963947773</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0003864988684654236</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005911081098020077</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00044718803837895393</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00038773915730416775</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010974460747092962</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0004403679631650448</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004105791449546814</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016771750524640083</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00045359903015196323</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;positive&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006274881307035685</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003106691874563694</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00011706002987921238</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00015527987852692604</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005754788871854544</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0003549989778548479</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00026942905969917774</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010399760212749243</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003244390245527029</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00041577895171940327</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016394141130149364</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0008426571730524302</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000607397872954607</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00031061796471476555</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.001924613956362009</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0001546698622405529</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005779480561614037</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0019248239696025848</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002688488457351923</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010696770623326302</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0019253031350672245</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00042208796367049217</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001661744900047779</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0019295827951282263</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000630037859082222</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00029403879307210445</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.632002234458923e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014825910329818726</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005992481019347906</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0002963789738714695</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002707098610699177</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010470559354871511</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00032782903872430325</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00040984898805618286</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0016480039339512587</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005802679806947708</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006154379807412624</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002943389117717743</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.72201456129551e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0001474190503358841</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005177180282771587</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0002808889839798212</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00026252889074385166</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010520960204303265</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003273589536547661</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004212388303130865</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015222150832414627</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005667679943144321</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00059853820130229</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002947188913822174</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.676007226109505e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014731893315911293</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005259988829493523</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00028092903085052967</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002639889717102051</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010303868912160397</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003265792038291693</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004779091104865074</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015163249336183071</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005729380063712597</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFP.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005764181260019541</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ufunc_strides.UnaryFPSpecial

<table width="1380">
  <thead>
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
      <td width="280">0.0003853288944810629</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003854988608509302</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00038867793045938015</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.000386078841984272</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0003859279677271843</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003857780247926712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003855079412460327</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00038531795144081116</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00038543902337551117</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0003862988669425249</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0003859789576381445</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;_ones_like&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0003857880365103483</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.000290268799290061</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.635005749762058e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014525000005960464</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005360080394893885</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005798579659312963</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00026356917805969715</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010693259537220001</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.000502187991514802</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00042432895861566067</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001513184979557991</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005395079497247934</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;absolute&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005872580222785473</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0035625079181045294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.002023233100771904</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0016165750566869974</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.003732278011739254</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0020229830406606197</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.002451632171869278</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0037574870511889458</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.002559112152084708</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.002445052145048976</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.003775268094614148</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.002550791949033737</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;cbrt&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.002452132059261203</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002949789632111788</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.665995508432388e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014424906112253666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005585979670286179</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00028055906295776367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002653091214597225</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010837160516530275</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003271191380918026</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004541280213743448</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015369451139122248</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.000567578012123704</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;ceil&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006194980815052986</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00030726916156709194</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00011665909551084042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00015546893700957298</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005423380061984062</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00035444903187453747</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002645289059728384</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010778859723359346</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00032793893478810787</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004463891964405775</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001478525111451745</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0008451179601252079</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;deg2rad&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006054379045963287</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003093089908361435</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0019280428532510996</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00015499908477067947</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005260689649730921</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0019300428684800863</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002623989712446928</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010664770379662514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.001925113843753934</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00045081903226673603</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015222150832414627</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00192697299644351</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;degrees&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005609279032796621</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.004391596186906099</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00242432183586061</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.005105342948809266</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0045313050504773855</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.007975633023306727</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.005505352048203349</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0024255921598523855</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.006183760007843375</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.002378622069954872</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0024230920244008303</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0028240911196917295</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;exp2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0023789219558238983</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00029293913394212723</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.456005550920963e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014579994603991508</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005233578849583864</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005797778721898794</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002634290140122175</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010649159085005522</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0005786980036646128</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00042742909863591194</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015255750622600317</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005147689953446388</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;fabs&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005720981862396002</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00029876898042857647</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.823901250958443e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014771008864045143</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005211180541664362</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0002809688448905945</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00026280898600816727</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010702258441597223</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003269489388912916</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004319788422435522</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015142648480832577</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005699880421161652</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;floor&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006006190087646246</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00533268298022449</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.001523435115814209</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0032808189280331135</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.005428812000900507</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0027659100014716387</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.003368417965248227</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.005474200937896967</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.002772110980004072</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00347776897251606</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.00548177189193666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00387755804695189</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;log2&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.003540999023243785</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0003163190558552742</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00011672894470393658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00015406915917992592</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005327381659299135</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00035491911694407463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00026482902467250824</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0011057360097765923</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00032387906685471535</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004554979968816042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015359949320554733</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.000839337008073926</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rad2deg&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005935779772698879</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00030874903313815594</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0019279439002275467</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00015383888967335224</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005181580781936646</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0019250127952545881</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00026328908279538155</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010705359745770693</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0019283040892332792</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004282488953322172</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.001504214946180582</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0019298039842396975</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;radians&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005614289548248053</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00029445881955325603</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.698009721934795e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014726887457072735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005198682192713022</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00029575894586741924</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0002697391901165247</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0010770659428089857</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00032798899337649345</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004293280653655529</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015108350198715925</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005776779726147652</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;reciprocal&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0006141078192740679</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0002952190116047859</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.66401644796133e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014725886285305023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005169089417904615</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.000281098997220397</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.00026292912662029266</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.001066816970705986</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.0003278690855950117</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004046980757266283</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015138648450374603</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005664080381393433</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;rint&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.0005700080655515194</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;d&#x27;)</td>
      <td width="280">0.00029529910534620285</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;e&#x27;)</td>
      <td width="280">7.72201456129551e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 1, &#x27;f&#x27;)</td>
      <td width="280">0.00014786887913942337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0005279090255498886</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;e&#x27;)</td>
      <td width="280">0.00028057885356247425</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 1, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000267059076577425</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;d&#x27;)</td>
      <td width="280">0.0011080359108746052</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;e&#x27;)</td>
      <td width="280">0.00032711890526115894</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 1, &#x27;f&#x27;)</td>
      <td width="280">0.0004295189864933491</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;d&#x27;)</td>
      <td width="280">0.0015288349241018295</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;e&#x27;)</td>
      <td width="280">0.0005676280707120895</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ufunc_strides.UnaryFPSpecial.time_unary(&lt;ufunc &#x27;trunc&#x27;&gt;, 4, 2, &#x27;f&#x27;)</td>
      <td width="280">0.000591787975281477</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
