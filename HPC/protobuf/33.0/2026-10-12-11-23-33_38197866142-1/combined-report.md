# 性能测试汇总

- 任务总数：2
- 成功：2
- 失败：0
- 跨架构对比：1

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
      <td width="180">HPC</td>
      <td width="220">protobuf</td>
      <td width="160">33.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">protobuf</td>
      <td width="160">33.0</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### protobuf 33.0

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
      <td width="600">33.0</td>
      <td width="600">33.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">33.0</td>
      <td width="600">33.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-10-12T02:59:25Z</td>
      <td width="600">2026-10-12T02:59:36Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
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
      <td width="600">2026-10-12T02:57:55Z</td>
      <td width="600">2026-10-12T02:58:16Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">AMD EPYC 9654 96-Core Processor</td>
      <td width="600">-</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">384</td>
      <td width="600">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0-132.0.0.111.oe2403sp3.x86_64</td>
      <td width="600">6.6.0-159.4.14.168.oe2403sp4.aarch64</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="600">3.11.6</td>
      <td width="600">3.11.6</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="600">12.3.1</td>
      <td width="600">12.3.1</td>
    </tr>
    <tr>
      <td width="180">glibc 版本</td>
      <td width="600">glibc 2.38</td>
      <td width="600">glibc 2.38</td>
    </tr>
    <tr>
      <td width="180">NUMA</td>
      <td width="600">N/A</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 574945 MB<br>node 0 free: 341616 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 580594 MB<br>node 1 free: 419406 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 580594 MB<br>node 2 free: 431745 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 482782 MB<br>node 3 free: 329993 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">AccLibBenchmark/protobuf-benchmark</td>
      <td width="880">01d083c6633babb2fb1307d93f596f10dda36778</td>
    </tr>
    <tr>
      <td width="500">google-benchmark</td>
      <td width="880">1.8.3</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### protobuf 33.0

##### 序列化 / Scalar（非 packed）

<table width="1380">
  <thead>
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
      <td width="280">12.730802415389249</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">62.30242941506076</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">555.90264165955</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">5440.39465851169</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">15.521614178759508</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">113.5037447118371</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">1095.4090240505752</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">10847.674747505976</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">32.579116166205914</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">261.9391635165149</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">2420.9168850888705</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">25511.756107789275</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">15.528044353264333</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">113.50297374229858</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">1095.297066453881</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">10846.354666522831</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">39.58685943654013</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">346.58716764593464</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">3487.1021685503165</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">36036.95293845204</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">39.80427505810899</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">419.6560146257696</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">4199.526010298544</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">42826.360692334</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">44.29390472641847</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">407.1195164244171</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">4423.831226761075</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">45136.89083939897</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">53.09349190239119</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">485.65146410175095</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">4860.579503931422</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">48698.207095511345</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">37.80986832501881</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">318.87454892679983</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">3620.74600392486</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">36716.711456229415</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">51.41597668666759</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">463.1694899117606</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">5177.100213180108</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">51224.05058009751</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 反序列化 / Scalar（非 packed）

<table width="1380">
  <thead>
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
      <td width="280">58.314168267418104</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">217.2813953333487</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">1502.3405605085848</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">14093.152839439219</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">72.25869045883226</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">201.5764047557181</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">1320.2322536156494</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">13347.022975827089</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">60.23366956555907</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">211.79791638848207</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">1311.467428604642</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">12276.709940997212</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">52.336614669140765</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">174.5817704318639</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">1114.1861847475857</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">10590.230706847069</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">67.69643902313894</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">281.4166458565572</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">2510.73247065524</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">24476.730688460248</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">81.54142366712352</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">373.61692894179396</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">3178.262684109637</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">32066.777759992714</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">65.29657308153983</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">319.457257480275</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">2625.8198636623333</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">27766.224773186328</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">83.65244482581883</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">372.28148470578407</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">3051.2541898649447</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">29963.27692472407</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">63.74255051891661</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">282.30968812238274</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">2495.2839257593328</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">24420.336170658327</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">87.1754710780835</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">376.83390489230175</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">3300.4718344865605</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">32522.609497025056</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 序列化 / Repeated（packed）

<table width="1380">
  <thead>
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
      <td width="280">10.292970688887142</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">16.803404526583467</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">87.10188294831264</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1417.1168299046033</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">10.5638098182478</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">12.917665137451367</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">49.69510324900162</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">724.0970214879504</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">33.34097384260901</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">313.12737597392135</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">3543.327486485141</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">36425.25079414448</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">47.159034568265895</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">359.082796082213</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">4092.489738170606</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">41232.97182349776</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">43.43663619639812</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">336.59858980868876</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">3869.741170161719</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">38297.988865788604</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">53.75834583480516</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">469.3211760579024</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">4743.633497205431</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">47804.11243295473</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">33.87513443712681</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">296.2234127725062</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">3390.659181028648</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">34420.38423151051</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">41.008772757404365</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">384.87106172237395</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">4236.362570243617</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">41683.67215532847</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 反序列化 / Repeated（packed）

<table width="1380">
  <thead>
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
      <td width="280">28.17929512755131</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">35.12388808317133</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">115.15504727150437</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1453.5831042922287</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">27.365944913556866</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">30.10973489511689</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">75.72701403321469</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">759.2753212408709</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">63.077038196323535</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">285.2882988998803</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">2896.091156707272</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">29753.80087968982</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">77.980200431885</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">407.2545626239596</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">4322.2463487381465</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">43554.694457412195</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">67.20615479659492</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">285.67208574456197</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">3335.8397766375906</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">31830.10457367779</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">82.0925831624184</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">469.23781780229876</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">4640.334032336113</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">46818.77938716688</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">65.03329332770764</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">294.8451180334301</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">3025.1553835288023</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">29877.501621577398</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">83.6405613406426</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">432.64358268245576</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">4382.062668227094</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">44852.53943890859</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 序列化 / String 与 Bytes

<table width="1380">
  <thead>
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
      <td width="280">10.834853580672254</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/100/cpu_time_median</td>
      <td width="280">11.376544996407345</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/1000/cpu_time_median</td>
      <td width="280">20.37298280842831</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/10000/cpu_time_median</td>
      <td width="280">108.27022994519953</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">15.440598568402969</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">18.42185277419368</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">75.14357000415232</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">635.2673826255109</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">17.60967853709346</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">29.588674799549715</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">178.0475670283737</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1646.1563197584178</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 反序列化 / String 与 Bytes

<table width="1380">
  <thead>
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
      <td width="280">38.47571286339389</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/100/cpu_time_median</td>
      <td width="280">47.15359066548778</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/1000/cpu_time_median</td>
      <td width="280">52.655009614237656</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/10000/cpu_time_median</td>
      <td width="280">234.25719362032603</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">43.356336925572855</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">55.96474633394462</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">110.54830403096229</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">790.8865353495446</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">46.704383425785174</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">63.54322524315966</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">219.29941785297547</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1783.351909791547</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### protobuf 33.0

##### 序列化 / Scalar（非 packed）

<table width="1380">
  <thead>
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

##### 反序列化 / Scalar（非 packed）

<table width="1380">
  <thead>
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

##### 序列化 / Repeated（packed）

<table width="1380">
  <thead>
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

##### 反序列化 / Repeated（packed）

<table width="1380">
  <thead>
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

##### 序列化 / String 与 Bytes

<table width="1380">
  <thead>
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

##### 反序列化 / String 与 Bytes

<table width="1380">
  <thead>
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

## 跨架构指标

### protobuf 33.0

#### 序列化 / Scalar（非 packed）

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">BM_Serialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">12.730802415389249</td>
      <td width="200">17.858066799310073</td>
      <td width="380">0.7129</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">62.30242941506076</td>
      <td width="200">128.07887591492988</td>
      <td width="380">0.4864</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">555.90264165955</td>
      <td width="200">1168.965821643078</td>
      <td width="380">0.4756</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">5440.39465851169</td>
      <td width="200">11562.724360032822</td>
      <td width="380">0.4705</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Double/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">15.521614178759508</td>
      <td width="200">14.791213010165682</td>
      <td width="380">1.0494</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Double/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">113.5037447118371</td>
      <td width="200">95.3531215234873</td>
      <td width="380">1.1904</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1095.4090240505752</td>
      <td width="200">783.2879783342876</td>
      <td width="380">1.3985</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10847.674747505976</td>
      <td width="200">7763.0318449424885</td>
      <td width="380">1.3974</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">32.579116166205914</td>
      <td width="200">32.51474350880832</td>
      <td width="380">1.002</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">261.9391635165149</td>
      <td width="200">257.80688032574955</td>
      <td width="380">1.016</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">2420.9168850888705</td>
      <td width="200">2524.7534111532614</td>
      <td width="380">0.9589</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">25511.756107789275</td>
      <td width="200">24865.10512110313</td>
      <td width="380">1.026</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Float/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">15.528044353264333</td>
      <td width="200">14.869848439385992</td>
      <td width="380">1.0443</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Float/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">113.50297374229858</td>
      <td width="200">89.28414782526265</td>
      <td width="380">1.2713</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1095.297066453881</td>
      <td width="200">783.1360831943115</td>
      <td width="380">1.3986</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10846.354666522831</td>
      <td width="200">7725.69528069564</td>
      <td width="380">1.4039</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">39.58685943654013</td>
      <td width="200">43.31269193676581</td>
      <td width="380">0.914</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">346.58716764593464</td>
      <td width="200">388.08586471584863</td>
      <td width="380">0.8931</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3487.1021685503165</td>
      <td width="200">4135.589736425167</td>
      <td width="380">0.8432</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">36036.95293845204</td>
      <td width="200">88145.24623853201</td>
      <td width="380">0.4088</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">39.80427505810899</td>
      <td width="200">44.170023078214406</td>
      <td width="380">0.9012</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">419.6560146257696</td>
      <td width="200">511.55059328338075</td>
      <td width="380">0.8204</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4199.526010298544</td>
      <td width="200">5380.447444223939</td>
      <td width="380">0.7805</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">42826.360692334</td>
      <td width="200">101816.45289624447</td>
      <td width="380">0.4206</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">44.29390472641847</td>
      <td width="200">39.012780593697386</td>
      <td width="380">1.1354</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">407.1195164244171</td>
      <td width="200">303.5775543290438</td>
      <td width="380">1.3411</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4423.831226761075</td>
      <td width="200">3527.7854498376278</td>
      <td width="380">1.254</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">45136.89083939897</td>
      <td width="200">89947.70583806667</td>
      <td width="380">0.5018</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">53.09349190239119</td>
      <td width="200">63.19500204046087</td>
      <td width="380">0.8402</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">485.65146410175095</td>
      <td width="200">570.1955470233436</td>
      <td width="380">0.8517</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4860.579503931422</td>
      <td width="200">6173.716205544133</td>
      <td width="380">0.7873</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">48698.207095511345</td>
      <td width="200">121668.54583484854</td>
      <td width="380">0.4003</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">37.80986832501881</td>
      <td width="200">32.46879585605707</td>
      <td width="380">1.1645</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">318.87454892679983</td>
      <td width="200">252.39077478674045</td>
      <td width="380">1.2634</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3620.74600392486</td>
      <td width="200">2986.5704853607604</td>
      <td width="380">1.2123</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">36716.711456229415</td>
      <td width="200">67837.91168304178</td>
      <td width="380">0.5412</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">51.41597668666759</td>
      <td width="200">51.74535662680582</td>
      <td width="380">0.9936</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">463.1694899117606</td>
      <td width="200">526.7302572468097</td>
      <td width="380">0.8793</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">5177.100213180108</td>
      <td width="200">5659.001651477133</td>
      <td width="380">0.9148</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">51224.05058009751</td>
      <td width="200">121276.17660571756</td>
      <td width="380">0.4224</td>
    </tr>
  </tbody>
</table>

#### 反序列化 / Scalar（非 packed）

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">58.314168267418104</td>
      <td width="200">70.46374730567092</td>
      <td width="380">0.8276</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">217.2813953333487</td>
      <td width="200">352.14473161253306</td>
      <td width="380">0.617</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1502.3405605085848</td>
      <td width="200">3172.25023439239</td>
      <td width="380">0.4736</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">14093.152839439219</td>
      <td width="200">30114.16121349986</td>
      <td width="380">0.468</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Double/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">72.25869045883226</td>
      <td width="200">83.47932055413916</td>
      <td width="380">0.8656</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Double/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">201.5764047557181</td>
      <td width="200">429.26790900552743</td>
      <td width="380">0.4696</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1320.2322536156494</td>
      <td width="200">3394.9868833592836</td>
      <td width="380">0.3889</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">13347.022975827089</td>
      <td width="200">35283.771808997284</td>
      <td width="380">0.3783</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">60.23366956555907</td>
      <td width="200">65.58691405056707</td>
      <td width="380">0.9184</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">211.79791638848207</td>
      <td width="200">424.67772299280944</td>
      <td width="380">0.4987</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1311.467428604642</td>
      <td width="200">3657.1438507165053</td>
      <td width="380">0.3586</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">12276.709940997212</td>
      <td width="200">32255.86174987336</td>
      <td width="380">0.3806</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Float/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">52.336614669140765</td>
      <td width="200">66.82048290624486</td>
      <td width="380">0.7832</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Float/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">174.5817704318639</td>
      <td width="200">425.5978774547815</td>
      <td width="380">0.4102</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1114.1861847475857</td>
      <td width="200">3658.5343675549443</td>
      <td width="380">0.3045</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10590.230706847069</td>
      <td width="200">35452.38757133599</td>
      <td width="380">0.2987</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">67.69643902313894</td>
      <td width="200">79.44778231914742</td>
      <td width="380">0.8521</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">281.4166458565572</td>
      <td width="200">422.72322870659116</td>
      <td width="380">0.6657</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">2510.73247065524</td>
      <td width="200">3471.0992261787173</td>
      <td width="380">0.7233</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">24476.730688460248</td>
      <td width="200">44250.70804082862</td>
      <td width="380">0.5531</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">81.54142366712352</td>
      <td width="200">98.83841956253968</td>
      <td width="380">0.825</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">373.61692894179396</td>
      <td width="200">560.2964626043886</td>
      <td width="380">0.6668</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3178.262684109637</td>
      <td width="200">4888.5778808904</td>
      <td width="380">0.6501</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">32066.777759992714</td>
      <td width="200">74599.3799195873</td>
      <td width="380">0.4299</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">65.29657308153983</td>
      <td width="200">76.61758616040632</td>
      <td width="380">0.8522</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">319.457257480275</td>
      <td width="200">451.82662552110827</td>
      <td width="380">0.707</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">2625.8198636623333</td>
      <td width="200">3758.9841107675834</td>
      <td width="380">0.6985</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">27766.224773186328</td>
      <td width="200">50793.11769841557</td>
      <td width="380">0.5467</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">83.65244482581883</td>
      <td width="200">112.97739760215784</td>
      <td width="380">0.7404</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">372.28148470578407</td>
      <td width="200">613.5726247647451</td>
      <td width="380">0.6067</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3051.2541898649447</td>
      <td width="200">5441.934114317136</td>
      <td width="380">0.5607</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">29963.27692472407</td>
      <td width="200">81350.89617221968</td>
      <td width="380">0.3683</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">63.74255051891661</td>
      <td width="200">75.43385813302334</td>
      <td width="380">0.845</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">282.30968812238274</td>
      <td width="200">414.25770371075026</td>
      <td width="380">0.6815</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">2495.2839257593328</td>
      <td width="200">3384.3531094331415</td>
      <td width="380">0.7373</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">24420.336170658327</td>
      <td width="200">46498.44175297453</td>
      <td width="380">0.5252</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">87.1754710780835</td>
      <td width="200">113.17702249407961</td>
      <td width="380">0.7703</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">376.83390489230175</td>
      <td width="200">573.7812379798563</td>
      <td width="380">0.6568</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3300.4718344865605</td>
      <td width="200">5085.058349443496</td>
      <td width="380">0.6491</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">32522.609497025056</td>
      <td width="200">72218.54105736804</td>
      <td width="380">0.4503</td>
    </tr>
  </tbody>
</table>

#### 序列化 / Repeated（packed）

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">BM_Serialize_Repeated_Double/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10.292970688887142</td>
      <td width="200">9.235626380074136</td>
      <td width="380">1.1145</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Double/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">16.803404526583467</td>
      <td width="200">17.92983490124735</td>
      <td width="380">0.9372</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">87.10188294831264</td>
      <td width="200">90.56156493348469</td>
      <td width="380">0.9618</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1417.1168299046033</td>
      <td width="200">1220.1988333066354</td>
      <td width="380">1.1614</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Float/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10.5638098182478</td>
      <td width="200">8.657036685548196</td>
      <td width="380">1.2203</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Float/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">12.917665137451367</td>
      <td width="200">11.896236033750094</td>
      <td width="380">1.0859</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">49.69510324900162</td>
      <td width="200">44.70508858996754</td>
      <td width="380">1.1116</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">724.0970214879504</td>
      <td width="200">339.30583065860776</td>
      <td width="380">2.1341</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">33.34097384260901</td>
      <td width="200">35.21864243754525</td>
      <td width="380">0.9467</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">313.12737597392135</td>
      <td width="200">362.9229339720437</td>
      <td width="380">0.8628</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3543.327486485141</td>
      <td width="200">4083.6394536818875</td>
      <td width="380">0.8677</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">36425.25079414448</td>
      <td width="200">61761.02202735578</td>
      <td width="380">0.5898</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">47.159034568265895</td>
      <td width="200">60.98006676273126</td>
      <td width="380">0.7734</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">359.082796082213</td>
      <td width="200">507.56131501623713</td>
      <td width="380">0.7075</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4092.489738170606</td>
      <td width="200">5465.840177065344</td>
      <td width="380">0.7487</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">41232.97182349776</td>
      <td width="200">81902.25389418077</td>
      <td width="380">0.5034</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">43.43663619639812</td>
      <td width="200">41.3613717511853</td>
      <td width="380">1.0502</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">336.59858980868876</td>
      <td width="200">295.55024327623397</td>
      <td width="380">1.1389</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3869.741170161719</td>
      <td width="200">3664.3426926169573</td>
      <td width="380">1.0561</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">38297.988865788604</td>
      <td width="200">59197.715219064754</td>
      <td width="380">0.647</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">53.75834583480516</td>
      <td width="200">66.85767105130121</td>
      <td width="380">0.8041</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">469.3211760579024</td>
      <td width="200">633.8959402991763</td>
      <td width="380">0.7404</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4743.633497205431</td>
      <td width="200">6179.933288115393</td>
      <td width="380">0.7676</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">47804.11243295473</td>
      <td width="200">99223.85620914707</td>
      <td width="380">0.4818</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">33.87513443712681</td>
      <td width="200">31.549008838055254</td>
      <td width="380">1.0737</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">296.2234127725062</td>
      <td width="200">263.23640353313465</td>
      <td width="380">1.1253</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3390.659181028648</td>
      <td width="200">2881.51952690083</td>
      <td width="380">1.1767</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">34420.38423151051</td>
      <td width="200">46673.24655227309</td>
      <td width="380">0.7375</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">41.008772757404365</td>
      <td width="200">48.183183994746265</td>
      <td width="380">0.8511</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">384.87106172237395</td>
      <td width="200">538.6990856811658</td>
      <td width="380">0.7144</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4236.362570243617</td>
      <td width="200">5388.953158846734</td>
      <td width="380">0.7861</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">41683.67215532847</td>
      <td width="200">91515.43453305462</td>
      <td width="380">0.4555</td>
    </tr>
  </tbody>
</table>

#### 反序列化 / Repeated（packed）

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Double/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">28.17929512755131</td>
      <td width="200">31.976846997152357</td>
      <td width="380">0.8812</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Double/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">35.12388808317133</td>
      <td width="200">46.8683106489362</td>
      <td width="380">0.7494</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">115.15504727150437</td>
      <td width="200">129.10179856034736</td>
      <td width="380">0.892</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1453.5831042922287</td>
      <td width="200">1119.2750942004639</td>
      <td width="380">1.2987</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Float/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">27.365944913556866</td>
      <td width="200">31.23825041441805</td>
      <td width="380">0.876</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Float/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">30.10973489511689</td>
      <td width="200">39.46661396872103</td>
      <td width="380">0.7629</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">75.72701403321469</td>
      <td width="200">80.49152019589387</td>
      <td width="380">0.9408</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">759.2753212408709</td>
      <td width="200">394.28700778639296</td>
      <td width="380">1.9257</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">63.077038196323535</td>
      <td width="200">76.63395672955399</td>
      <td width="380">0.8231</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">285.2882988998803</td>
      <td width="200">432.92000181767423</td>
      <td width="380">0.659</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">2896.091156707272</td>
      <td width="200">3816.6312190030935</td>
      <td width="380">0.7588</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">29753.80087968982</td>
      <td width="200">58550.01843710103</td>
      <td width="380">0.5082</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">77.980200431885</td>
      <td width="200">102.04476515930024</td>
      <td width="380">0.7642</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">407.2545626239596</td>
      <td width="200">546.825489172588</td>
      <td width="380">0.7448</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4322.2463487381465</td>
      <td width="200">5289.159963440696</td>
      <td width="380">0.8172</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">43554.694457412195</td>
      <td width="200">72106.35144867636</td>
      <td width="380">0.604</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">67.20615479659492</td>
      <td width="200">87.44222926894697</td>
      <td width="380">0.7686</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">285.67208574456197</td>
      <td width="200">446.8179446033377</td>
      <td width="380">0.6393</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3335.8397766375906</td>
      <td width="200">4517.578273068913</td>
      <td width="380">0.7384</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">31830.10457367779</td>
      <td width="200">57912.58529705917</td>
      <td width="380">0.5496</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">82.0925831624184</td>
      <td width="200">105.64511463624592</td>
      <td width="380">0.7771</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">469.23781780229876</td>
      <td width="200">651.221231618833</td>
      <td width="380">0.7206</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4640.334032336113</td>
      <td width="200">5905.3553160241745</td>
      <td width="380">0.7858</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">46818.77938716688</td>
      <td width="200">80600.72874736937</td>
      <td width="380">0.5809</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">65.03329332770764</td>
      <td width="200">73.58180796483165</td>
      <td width="380">0.8838</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">294.8451180334301</td>
      <td width="200">447.4628955805359</td>
      <td width="380">0.6589</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">3025.1553835288023</td>
      <td width="200">3825.4490427198725</td>
      <td width="380">0.7908</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">29877.501621577398</td>
      <td width="200">55313.68239673301</td>
      <td width="380">0.5401</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">83.6405613406426</td>
      <td width="200">108.9165618169587</td>
      <td width="380">0.7679</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">432.64358268245576</td>
      <td width="200">583.1134031389747</td>
      <td width="380">0.742</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">4382.062668227094</td>
      <td width="200">5277.532752491181</td>
      <td width="380">0.8303</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">44852.53943890859</td>
      <td width="200">71345.92190772964</td>
      <td width="380">0.6287</td>
    </tr>
  </tbody>
</table>

#### 序列化 / String 与 Bytes

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">BM_Serialize_Bytes/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">10.834853580672254</td>
      <td width="200">10.782198891487528</td>
      <td width="380">1.0049</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Bytes/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">11.376544996407345</td>
      <td width="200">11.16733003173606</td>
      <td width="380">1.0187</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Bytes/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">20.37298280842831</td>
      <td width="200">22.25510439051314</td>
      <td width="380">0.9154</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_Bytes/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">108.27022994519953</td>
      <td width="200">103.0104392726781</td>
      <td width="380">1.0511</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_ASCII/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">15.440598568402969</td>
      <td width="200">13.470350851228178</td>
      <td width="380">1.1463</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_ASCII/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">18.42185277419368</td>
      <td width="200">19.261589097128148</td>
      <td width="380">0.9564</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_ASCII/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">75.14357000415232</td>
      <td width="200">88.36967493133392</td>
      <td width="380">0.8503</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_ASCII/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">635.2673826255109</td>
      <td width="200">633.9024155280515</td>
      <td width="380">1.0022</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_Chinese/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">17.60967853709346</td>
      <td width="200">17.958612075359582</td>
      <td width="380">0.9806</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_Chinese/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">29.588674799549715</td>
      <td width="200">30.581204585610337</td>
      <td width="380">0.9675</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_Chinese/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">178.0475670283737</td>
      <td width="200">194.31372299018057</td>
      <td width="380">0.9163</td>
    </tr>
    <tr>
      <td width="400">BM_Serialize_String_Chinese/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1646.1563197584178</td>
      <td width="200">1799.2931707951975</td>
      <td width="380">0.9149</td>
    </tr>
  </tbody>
</table>

#### 反序列化 / String 与 Bytes

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">BM_Deserialize_Bytes/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">38.47571286339389</td>
      <td width="200">37.598094720680486</td>
      <td width="380">1.0233</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Bytes/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">47.15359066548778</td>
      <td width="200">50.33645282659944</td>
      <td width="380">0.9368</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Bytes/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">52.655009614237656</td>
      <td width="200">65.22093526759993</td>
      <td width="380">0.8073</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_Bytes/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">234.25719362032603</td>
      <td width="200">235.74829177598235</td>
      <td width="380">0.9937</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_ASCII/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">43.356336925572855</td>
      <td width="200">40.8121607771127</td>
      <td width="380">1.0623</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_ASCII/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">55.96474633394462</td>
      <td width="200">64.50744454917084</td>
      <td width="380">0.8676</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_ASCII/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">110.54830403096229</td>
      <td width="200">145.9378211458229</td>
      <td width="380">0.7575</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_ASCII/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">790.8865353495446</td>
      <td width="200">772.94429520556</td>
      <td width="380">1.0232</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_Chinese/10/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">46.704383425785174</td>
      <td width="200">46.54168289458786</td>
      <td width="380">1.0035</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_Chinese/100/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">63.54322524315966</td>
      <td width="200">78.52381291197108</td>
      <td width="380">0.8092</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_Chinese/1000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">219.29941785297547</td>
      <td width="200">249.32938358442038</td>
      <td width="380">0.8796</td>
    </tr>
    <tr>
      <td width="400">BM_Deserialize_String_Chinese/10000/cpu_time_median</td>
      <td width="200">越小越好</td>
      <td width="200">1783.351909791547</td>
      <td width="200">1938.202040028164</td>
      <td width="380">0.9201</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
