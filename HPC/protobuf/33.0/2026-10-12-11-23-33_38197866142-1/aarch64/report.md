# protobuf 33.0 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`38197866142-1`

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
      <td width="1200">33.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">33.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-10-12T02:59:36Z</td>
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
      <td width="1200">2026-10-12T02:58:16Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">-</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="1200">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="1200">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="1200">6.6.0-159.4.14.168.oe2403sp4.aarch64</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 574945 MB<br>node 0 free: 341616 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 580594 MB<br>node 1 free: 419406 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 580594 MB<br>node 2 free: 431745 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 482782 MB<br>node 3 free: 329993 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">AccLibBenchmark/protobuf-benchmark</td>
      <td width="880">01d083c6633babb2fb1307d93f596f10dda36778</td>
    </tr>
    <tr>
      <td width="500">google-benchmark</td>
      <td width="880">1.8.3</td>
    </tr>
  </tbody>
</table>

## 性能指标

### 序列化 / Scalar（非 packed）

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="280">17.858066799310073</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">128.07887591492988</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">1168.965821643078</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">11562.724360032822</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">14.791213010165682</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">95.3531215234873</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">783.2879783342876</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">7763.0318449424885</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">32.51474350880832</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">257.80688032574955</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">2524.7534111532614</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">24865.10512110313</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">14.869848439385992</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">89.28414782526265</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">783.1360831943115</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">7725.69528069564</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">43.31269193676581</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">388.08586471584863</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">4135.589736425167</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">88145.24623853201</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">44.170023078214406</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">511.55059328338075</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">5380.447444223939</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">101816.45289624447</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">39.012780593697386</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">303.5775543290438</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">3527.7854498376278</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">89947.70583806667</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">63.19500204046087</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">570.1955470233436</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">6173.716205544133</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">121668.54583484854</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">32.46879585605707</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">252.39077478674045</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">2986.5704853607604</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">67837.91168304178</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">51.74535662680582</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">526.7302572468097</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">5659.001651477133</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">121276.17660571756</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### 反序列化 / Scalar（非 packed）

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="280">70.46374730567092</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">352.14473161253306</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">3172.25023439239</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">30114.16121349986</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">83.47932055413916</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">429.26790900552743</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">3394.9868833592836</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">35283.771808997284</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">65.58691405056707</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">424.67772299280944</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">3657.1438507165053</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">32255.86174987336</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">66.82048290624486</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">425.5978774547815</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">3658.5343675549443</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">35452.38757133599</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">79.44778231914742</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">422.72322870659116</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">3471.0992261787173</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">44250.70804082862</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">98.83841956253968</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">560.2964626043886</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">4888.5778808904</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">74599.3799195873</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">76.61758616040632</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">451.82662552110827</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">3758.9841107675834</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">50793.11769841557</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">112.97739760215784</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">613.5726247647451</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">5441.934114317136</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">81350.89617221968</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">75.43385813302334</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">414.25770371075026</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">3384.3531094331415</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">46498.44175297453</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">113.17702249407961</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">573.7812379798563</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">5085.058349443496</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">72218.54105736804</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### 序列化 / Repeated（packed）

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/10/cpu_time_median</td>
      <td width="280">9.235626380074136</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">17.92983490124735</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">90.56156493348469</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1220.1988333066354</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">8.657036685548196</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">11.896236033750094</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">44.70508858996754</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">339.30583065860776</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">35.21864243754525</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">362.9229339720437</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">4083.6394536818875</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">61761.02202735578</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">60.98006676273126</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">507.56131501623713</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">5465.840177065344</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">81902.25389418077</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">41.3613717511853</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">295.55024327623397</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">3664.3426926169573</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">59197.715219064754</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">66.85767105130121</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">633.8959402991763</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">6179.933288115393</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">99223.85620914707</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">31.549008838055254</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">263.23640353313465</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">2881.51952690083</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">46673.24655227309</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">48.183183994746265</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">538.6990856811658</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">5388.953158846734</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">91515.43453305462</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### 反序列化 / Repeated（packed）

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/10/cpu_time_median</td>
      <td width="280">31.976846997152357</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">46.8683106489362</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">129.10179856034736</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1119.2750942004639</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">31.23825041441805</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">39.46661396872103</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">80.49152019589387</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">394.28700778639296</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">76.63395672955399</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">432.92000181767423</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">3816.6312190030935</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">58550.01843710103</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">102.04476515930024</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">546.825489172588</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">5289.159963440696</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">72106.35144867636</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">87.44222926894697</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">446.8179446033377</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">4517.578273068913</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">57912.58529705917</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">105.64511463624592</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">651.221231618833</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">5905.3553160241745</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">80600.72874736937</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">73.58180796483165</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">447.4628955805359</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">3825.4490427198725</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">55313.68239673301</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">108.9165618169587</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">583.1134031389747</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">5277.532752491181</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">71345.92190772964</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### 序列化 / String 与 Bytes

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">BM_Serialize_Bytes/10/cpu_time_median</td>
      <td width="280">10.782198891487528</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/100/cpu_time_median</td>
      <td width="280">11.16733003173606</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/1000/cpu_time_median</td>
      <td width="280">22.25510439051314</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/10000/cpu_time_median</td>
      <td width="280">103.0104392726781</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">13.470350851228178</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">19.261589097128148</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">88.36967493133392</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">633.9024155280515</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">17.958612075359582</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">30.581204585610337</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">194.31372299018057</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1799.2931707951975</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### 反序列化 / String 与 Bytes

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">BM_Deserialize_Bytes/10/cpu_time_median</td>
      <td width="280">37.598094720680486</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/100/cpu_time_median</td>
      <td width="280">50.33645282659944</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/1000/cpu_time_median</td>
      <td width="280">65.22093526759993</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/10000/cpu_time_median</td>
      <td width="280">235.74829177598235</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">40.8121607771127</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">64.50744454917084</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">145.9378211458229</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">772.94429520556</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">46.54168289458786</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">78.52381291197108</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">249.32938358442038</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1938.202040028164</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
