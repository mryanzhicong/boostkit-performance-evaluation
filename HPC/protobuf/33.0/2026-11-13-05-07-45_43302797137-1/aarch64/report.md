# protobuf 33.0 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`43302797137-1`

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
      <td width="1200">2026-11-12T20:46:14Z</td>
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
      <td width="1200">2026-11-12T20:44:51Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 378180 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 382791 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 379374 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 383969 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">17.7567098040368</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">128.5663114126108</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">1169.9958465826662</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">11569.263121364622</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">14.896875624652463</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">90.1904984456603</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">849.3230868319896</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">8122.637736614808</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">32.529039099220256</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">256.94481130666117</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">2659.766627171116</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">24879.977265057365</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">14.50402617332576</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">89.81503528506708</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">803.3003722707473</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">7712.810794136849</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">45.31065946483661</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">396.95443826259276</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">4163.646537970886</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">91165.47212165088</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">44.37655967770242</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">506.54860137156146</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">5600.975381450851</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">103544.90294351612</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">38.65345887901271</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">307.4066560839663</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">3544.558695963708</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">89692.98476407901</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">62.34998218323527</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">558.1721438636348</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">6323.858871097698</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">120815.34031882502</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">35.1150023929224</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">256.12541335251314</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">2936.602345811169</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">68587.65156070596</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">51.592347194414366</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">521.275685782683</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">5751.638998815781</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">121330.50810416935</td>
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
      <td width="280">89.90174243670477</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">370.65870143174544</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">3160.2656808085117</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">30161.541033766087</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">86.77988468236153</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">427.17903193071174</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">3364.598525355949</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">35402.75196929806</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">88.04954997231707</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">447.3104252441227</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">3593.4265491676492</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">37319.29187377212</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">66.81715342271315</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">427.8305463832181</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">3496.286872750906</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">35451.27534833973</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">94.61795625993635</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">440.10716964154153</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">3494.0563435380877</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">51055.133864437936</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">114.28387967585147</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">569.8089165999936</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">5767.31491364148</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">75788.98291480218</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">91.85738486115322</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">451.3503540254563</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">4129.853178737129</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">51295.21792021413</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">139.90726298162403</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">645.0936438731832</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">6278.7288245724185</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">81435.94160760596</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">93.06290778695212</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">431.9650448529505</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">3448.533655886585</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">48921.840335400724</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">134.0311088532022</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">596.0442522278113</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">5827.354473012613</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">73456.97020893086</td>
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
      <td width="280">9.239053745587752</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">18.127114287081366</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">111.95267330162255</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1054.067738933767</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">8.661947600635273</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">11.89318343337863</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">55.40796812127678</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">339.78518475903</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">39.38251461331728</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">360.35279464373997</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">4157.454263648252</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">61259.185076350186</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">59.171500800994835</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">492.2194821469418</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">5598.036788085419</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">82603.30778003216</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">42.656470672671034</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">318.2666470659131</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">3755.4113217018044</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">58076.17342577506</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">67.33601834231794</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">623.6495398706913</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">6328.242028466933</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">100496.50670912777</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">32.259370296071054</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">269.7190768694785</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">2956.819399836412</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">48861.12664397874</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">47.91546872427045</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">539.6267487572259</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">5664.989969909904</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">91648.87483085475</td>
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
      <td width="280">31.78151210279956</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">45.94270293764326</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">154.61542139484706</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1110.3695824208282</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">31.25815973499342</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">41.717325181563396</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">81.46040504552748</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">426.4614237107417</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">76.91638136239226</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">440.91834812659016</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">4374.117781385676</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">60876.46127701309</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">99.7207963084604</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">542.6933498965157</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">6101.161055584778</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">73675.21018254521</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">87.43718941268628</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">454.2645430559215</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">5074.019743225438</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">59311.7797521661</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">105.86850691406894</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">659.2122050684785</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">6826.097523925353</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">80564.11170564446</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">73.62943821660552</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">446.8501471331143</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">4434.404812310036</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">56290.132296458</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">107.40269152796891</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">580.6370254087655</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">6034.698020785391</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">73225.19473805603</td>
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
      <td width="280">10.781229311815487</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/100/cpu_time_median</td>
      <td width="280">11.162652607597382</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/1000/cpu_time_median</td>
      <td width="280">21.44649580785351</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/10000/cpu_time_median</td>
      <td width="280">133.05594355219884</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">13.476364888350298</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">19.77302141021845</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">88.5692388080281</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">684.8520932386626</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">17.948812157007655</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">30.72274123569304</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">195.2116944509343</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1851.691974142113</td>
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
      <td width="280">37.18249389664252</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/100/cpu_time_median</td>
      <td width="280">50.28609231211514</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/1000/cpu_time_median</td>
      <td width="280">64.82757261053517</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/10000/cpu_time_median</td>
      <td width="280">244.44807906677693</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">40.57196319679358</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">61.29999014297695</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">146.79871966436127</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">809.9850931183743</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">45.59140769751143</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">78.69427003666104</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">248.85152423955225</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1966.1588337931253</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
