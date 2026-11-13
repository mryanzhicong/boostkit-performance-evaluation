# folly 2022.11.14.00 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`43309743549-1`

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
      <td width="1200">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-12T21:43:58Z</td>
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
      <td width="1200">2026-11-12T21:40:31Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 379388 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 383595 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 379604 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 384662 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">AccLibBenchmark</td>
      <td width="880">unknown</td>
    </tr>
    <tr>
      <td width="500">fbthrift</td>
      <td width="880">2022.11.14.00</td>
    </tr>
  </tbody>
</table>

## 性能指标

### binary payload

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">28.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">4289.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">6071.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">150.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">229.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">117938.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">29.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">10249.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">17073.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">151.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">234.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">122695.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">106.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11463.08</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">77332.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1574.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2914.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">436484.14</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">95.46</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">31975.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">34520.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1676.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1936.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">391023.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">39.59</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">63821.67</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120249.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">632.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1469.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">162173.67</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">84.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">75445.07</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131270.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1335.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3254.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">344149.38</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">35.49</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">71115.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120511.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">954.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1399.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">145351.33</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">86.17</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">71316.39</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133407.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2560.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3142.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">352950.63</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">93.67</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5267.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13752.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">141.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">368.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">95918.41</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">51.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">23626.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">38401.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">151.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">184.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">53219.31</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">363.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13454.3</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">14757.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">99.99999402381087</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">2</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1668.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1794.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">371846.01</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">382.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">32694.67</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">86854.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1643.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2025.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">391251.41</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">157.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">64158.37</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120412.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">653.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1468.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">161050.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">358.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">70209.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132928.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1501.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3320.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">367051.93</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">139.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">72155.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120197.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99421094208098</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">745</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">875.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1284.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">142981.79</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">297.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">84999.49</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131441.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1921.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2835.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">304620.9</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">238.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8180.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14032.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">140.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">238.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">61133.59</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">236.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">20691.27</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">29256.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">141.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">205.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">60419.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1447.64</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13491.45</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15531.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1750.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1939.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">370595.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1320.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">36999.49</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">126466.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1022.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3099.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">337955.63</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">976.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40044.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123020.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1088.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2266.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">249879.64</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1641.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">59521.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">142232.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2042.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3911.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">420118.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">966.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40484.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120640.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1879.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2212.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">247391.59</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1435.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">68022.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132270.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2789.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3286.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">367552.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">529.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7373.38</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14313.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">139.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">246.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">67822.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">660.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14794.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">30370.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">138.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">299.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">84498.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">3139.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12441.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">16550.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1760.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2147.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">401888.73</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">3352.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">29132.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">111941.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1509.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3749.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">429108.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1915.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40810.43</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122682.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1025.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2221.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">245223.28</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3590.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">54419.97</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">143542.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2486.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4324.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">459596.63</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1905.59</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">41080.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121163.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2012.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2228.54</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">243915.04</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2642.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">73898.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132694.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2602.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3221.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">338222.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">878.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8897.77</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">16571.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">129.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">212.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">56204.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">1015.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">19237.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">36598.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">128.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">255.54</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">64985.51</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6647.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11752.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">22760.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1626.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2948.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">425445.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6826.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28614.45</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">104064.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1477.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3411.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">436875.64</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4243.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">36825.61</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122940.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1495.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2529.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">271572.93</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">7278.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">53667.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">141334.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2692.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4557.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">465805.41</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3730.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">41895.35</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122937.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2060.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2232.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">238769.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5701.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">68483.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">130601.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2964.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3226.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">364908.74</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### i32 int

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">146.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6722.53</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13853.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">145.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">272.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">75212.51</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">155.07</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15806.67</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">35569.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">145.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">287.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">79394.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">772.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12655.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15490.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1690.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2227.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">395312.59</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">742.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">32877.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">36990.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1686.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1977.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">380382.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">334.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">60425.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120421.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">761.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1610.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">171055.28</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">731.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">67652.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133896.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1595.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3539.59</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">374674.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">296.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">68376.08</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">119834.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">976.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1358.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">151699.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">650.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">78094.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131858.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2292.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3101.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">332809.64</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### i64 long

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">96.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5109.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">7913.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">144.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">374.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">98684.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">94.93</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">12920.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">30753.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">145.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">366.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">97205.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">385.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12660.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">16055.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1619.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2411.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">395124.24</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">307.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">39716.87</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">121042.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">907.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2821.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">314890.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">152.71</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">65192.71</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120229.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">592.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1457.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">156378.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">326.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">77457.11</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131331.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1138.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3109.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">334316.21</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">141.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">71159.48</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">119863.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99809489853612</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">249</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">895.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1353.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">145221.34</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">306.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">82648.93</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131393.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99778938484567</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">624</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1967.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2970.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">313631.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### double

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">46.04</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5349.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13667.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">143.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">330.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">94293.24</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">38.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15764.48</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">35590.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">146.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">258.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">79628.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">211.71</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11541.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15110.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1699.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2886.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">433582.71</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">210.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28954.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">36915.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1684.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2979.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">431851.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">77.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">65243.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120321.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99651630439497</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">498</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">613.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1464.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">158829.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">159.17</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">79591.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">131553.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1159.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3052.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">325970.67</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">69.95</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">72337.79</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120218.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99806888182208</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">249</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">871.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1343.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">143264.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">147.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">84029.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">130676.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99877376770446</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">334</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1798.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2753.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">302639.69</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### list<i32>

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">234.47</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8331.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14425.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">141.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">220.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">60023.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">210.65</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">23183.07</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">29573.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">144.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">177.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">53927.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1587.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12303.16</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">18403.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1615.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2970.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">406399.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1635.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">29874.39</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">113779.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1460.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3420.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">418701.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1050.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">37196.06</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121451.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1152.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2336.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">268948.42</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1545.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">63163.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">140168.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1842.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3636.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">395735.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">896.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43619.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123219.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1722.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2017.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">229444.31</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1333.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">73239.33</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133002.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2539.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3243.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">341450.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### list<i64>

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">153.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6412.16</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14034.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">145.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">306.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">78747.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">174.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14086.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">32882.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">144.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">329.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">89150.69</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">842.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11592.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">16714.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1687.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2599.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">431611.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">903.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">27020.59</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">113686.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1510.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3313.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">462802.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">513.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">39393.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">118961.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99895269014206</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">248</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1408.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2524.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">263105.2</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">740.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">67485.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133561.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1631.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3586.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">379247.98</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">294.38</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">68847.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">120224.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1000.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1422.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">150724.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">643.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">78436.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133860.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2285.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3196.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">329500.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### string

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">517.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7545.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14664.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">130.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">239.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">66278.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">637.32</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15324.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">29211.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">137.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">238.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">81577.27</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2812.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13886.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">16118.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1777.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1845.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">360050.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">3297.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">29621.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">109591.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1451.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3597.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">422018.58</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2057.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">37977.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123286.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1328.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2434.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">263347.0</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3150.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">62019.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">141329.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1910.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3804.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">403311.42</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1821.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">42910.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122554.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1655.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2174.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">233144.32</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2687.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">72703.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132727.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2689.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3338.59</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">344055.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### list<string>

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">858.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">9103.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">16822.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">126.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">233.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">54937.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">892.67</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">21884.43</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">39013.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">127.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">236.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">57130.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">5758.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13566.36</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">18573.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1753.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2047.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">368568.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">5596.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">34906.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">45059.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1711.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1936.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">358148.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4079.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">38319.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124036.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1437.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2477.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">261100.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">7207.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">54210.43</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">144262.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2766.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4541.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">461301.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3853.24</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40616.16</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122775.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1860.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2363.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">246607.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5283.22</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">73923.9</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132361.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2432.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3250.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">338126.31</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### set<string>

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">914.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8541.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">16141.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">128.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">240.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">58546.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">856.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">22810.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">37800.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">130.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">207.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">54809.84</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">5564.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14039.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">18645.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1777.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1733.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">356153.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6538.61</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">29873.5</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">46642.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1695.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2453.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">418471.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4227.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">36986.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123184.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1389.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2553.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">270577.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">6231.46</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">62736.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">138383.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1794.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3823.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">398813.42</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3495.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">44767.19</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123459.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1889.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2174.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">223705.42</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5275.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">74063.37</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">133190.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2727.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3323.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">337604.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### map<string, i64>

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">273.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7152.72</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13848.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Client CPU (%)</td>
      <td width="280">138.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">290.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">69908.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">269.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">18088.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">28946.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">141.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">293.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">69118.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1547.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12621.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">95271.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1529.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2837.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">396153.91</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1697.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28786.08</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">116517.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1420.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3571.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">434510.02</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1141.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">34232.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122849.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1523.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2677.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">292330.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1592.32</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">61349.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">142318.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1973.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3834.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">407634.53</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">923.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">42390.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122070.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">1829.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2195.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">236442.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1338.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">73005.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">132502.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2501.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3263.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">342551.66</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
