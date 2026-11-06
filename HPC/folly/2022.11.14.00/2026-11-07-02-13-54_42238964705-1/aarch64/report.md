# folly 2022.11.14.00 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`42238964705-1`

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
      <td width="1200">2026-11-06T15:05:16Z</td>
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
      <td width="1200">2026-11-06T15:00:57Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 371013 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 384606 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 367081 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 351187 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">24.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5111.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8147.0</td>
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
      <td width="280">152.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">443.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">99465.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">10.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">27876.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">45138.0</td>
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
      <td width="280">154.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">226.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">45035.1</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">62.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">19436.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">114057.0</td>
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
      <td width="280">1142.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1865.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">257462.33</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">83.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">36495.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">46599.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">99.99999351469111</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">2</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1633.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2150.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">342654.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">47.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">53629.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123788.0</td>
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
      <td width="280">884.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1707.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">193700.88</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">86.83</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">71750.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">135643.0</td>
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
      <td width="280">1310.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3085.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">355640.6</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">35.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">70268.99</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121451.0</td>
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
      <td width="280">832.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1196.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">147036.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">75.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">83792.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">137755.0</td>
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
      <td width="280">1992.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2939.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">310450.73</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">91.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5457.72</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9002.0</td>
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
      <td width="280">151.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">494.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">93344.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">92.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">13258.82</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">21916.0</td>
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
      <td width="280">154.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">478.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">94904.4</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">320.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">15542.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">105186.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Client CPU (%)</td>
      <td width="280">1195.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">3187.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">327960.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">343.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">35544.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">122176.0</td>
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
      <td width="280">1216.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3444.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">351842.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">158.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">63855.72</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122363.0</td>
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
      <td width="280">667.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1508.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">162067.09</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">323.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">77936.53</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">138151.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99791841556632</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">621</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1264.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3180.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">331471.37</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">149.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">67532.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122281.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">965.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1292.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">153384.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">287.24</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">85820.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">135525.0</td>
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
      <td width="280">1644.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2759.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">294136.78</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">354.61</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5509.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">10186.0</td>
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
      <td width="280">149.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">556.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">90780.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">342.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14239.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">23929.0</td>
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
      <td width="280">150.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">544.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">87791.91</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">812.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">24046.99</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">117065.0</td>
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
      <td width="280">697.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1982.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">208068.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1014.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">48189.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">128618.0</td>
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
      <td width="280">712.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2604.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">259630.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1042.61</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">37491.27</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">125429.0</td>
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
      <td width="280">1601.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2629.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">266907.2</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1446.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">67506.52</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">143057.0</td>
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
      <td width="280">1671.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3589.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">370203.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">872.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">44841.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124170.0</td>
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
      <td width="280">1616.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2040.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">223458.4</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1255.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">77752.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136859.0</td>
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
      <td width="280">2119.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3082.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">321493.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">663.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5886.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">11637.0</td>
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
      <td width="280">147.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">488.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">84965.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">671.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14552.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">20622.0</td>
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
      <td width="280">147.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">469.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">85911.37</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2766.89</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14116.56</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">22985.0</td>
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
      <td width="280">1715.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2288.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">354162.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">3066.34</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">31850.62</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">45021.0</td>
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
      <td width="280">1750.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2998.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">392491.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1826.93</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">42819.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124108.0</td>
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
      <td width="280">986.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2203.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">233847.56</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3178.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">60935.3</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">144605.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.66048884544408</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">124755</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2161.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4078.17</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">406896.93</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1781.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43937.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124366.0</td>
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
      <td width="280">1725.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2039.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">227978.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2424.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">80591.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">137183.0</td>
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
      <td width="280">1884.6</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2982.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">310352.52</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">1142.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6840.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">11598.0</td>
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
      <td width="280">137.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">459.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">73101.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">1083.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">18030.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">24207.0</td>
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
      <td width="280">135.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">424.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">69340.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">5847.95</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13357.71</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">21138.0</td>
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
      <td width="280">1758.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2681.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">374268.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6346.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">30775.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">110579.0</td>
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
      <td width="280">1438.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">4280.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">406199.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3631.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43053.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123354.0</td>
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
      <td width="280">949.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2280.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">232447.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5662.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">69005.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">143518.0</td>
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
      <td width="280">1668.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3614.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">362429.2</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3820.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40925.38</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123628.0</td>
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
      <td width="280">1990.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2226.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">244516.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5028.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">77695.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136977.0</td>
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
      <td width="280">2295.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3187.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">321842.21</td>
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
      <td width="280">181.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5450.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9094.0</td>
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
      <td width="280">151.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">548.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">93065.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">184.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">13346.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">21891.0</td>
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
      <td width="280">152.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">520.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">94221.04</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">247.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">40791.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">117609.0</td>
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
      <td width="280">362.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1136.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">126860.39</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">491.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">51621.37</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">124862.0</td>
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
      <td width="280">673.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2393.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">251493.48</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">295.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">67428.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122313.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99999264770972</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">1</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">553.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1418.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">151124.48</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">678.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">73086.06</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">137315.0</td>
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
      <td width="280">1387.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3315.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">347509.2</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">295.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">68474.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121596.0</td>
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
      <td width="280">933.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1275.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">151052.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">626.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">80610.69</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136070.0</td>
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
      <td width="280">2213.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3064.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">320580.71</td>
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
      <td width="280">92.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5348.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8904.0</td>
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
      <td width="280">152.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">528.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">94750.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">97.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">12660.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">21211.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">99.99998881731473</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">1</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">154.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">522.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">99359.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">338.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14433.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">20943.0</td>
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
      <td width="280">1644.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2475.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">346875.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">336.05</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">36352.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">46358.0</td>
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
      <td width="280">1658.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2366.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">344116.98</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">224.26</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">45099.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123312.0</td>
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
      <td width="280">1211.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2183.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">229644.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">328.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">75348.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136971.0</td>
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
      <td width="280">1283.12</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3190.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">336513.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">147.95</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">68296.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122364.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">916.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1268.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">151504.52</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">286.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">87703.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136786.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99801827153644</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">524</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1661.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2740.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">293789.33</td>
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
      <td width="280">48.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5126.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8648.0</td>
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
      <td width="280">151.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">572.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">98884.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">51.34</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">11957.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">19962.0</td>
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
      <td width="280">153.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">538.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">105148.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">111.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">22231.53</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">115718.0</td>
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
      <td width="280">858.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1955.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">228489.02</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">162.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">37643.84</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">123763.0</td>
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
      <td width="280">1134.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3256.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">332326.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">69.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">72144.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121737.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">489.84</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1309.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">142792.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">158.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">79297.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">135789.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99788145779075</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">620</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">1119.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3028.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">325164.3</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">74.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">67849.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121835.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">997.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1349.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">152529.07</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">153.15</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">82318.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136279.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2052.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2965.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">313641.21</td>
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
      <td width="280">351.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5564.11</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">10254.0</td>
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
      <td width="280">152.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">517.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">89886.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">157.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">30933.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">39325.0</td>
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
      <td width="280">149.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">274.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">40413.6</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1175.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">16608.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">111326.0</td>
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
      <td width="280">1118.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2836.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">301032.37</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1159.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">42131.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">130646.0</td>
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
      <td width="280">915.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2866.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">296852.03</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">882.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">44336.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123360.0</td>
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
      <td width="280">807.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2154.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">225979.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1310.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">74617.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">139096.0</td>
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
      <td width="280">1234.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3183.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">335396.21</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">892.07</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43818.36</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124342.0</td>
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
      <td width="280">1792.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1975.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">228369.02</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1381.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">70722.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136707.0</td>
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
      <td width="280">2628.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3278.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">353563.34</td>
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
      <td width="280">185.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5332.72</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8979.0</td>
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
      <td width="280">152.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">524.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">95132.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">184.74</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">13305.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">21606.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Success Rate</td>
      <td width="280">99.9999882527671</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Failed Requests</td>
      <td width="280">1</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Client CPU (%)</td>
      <td width="280">154.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">490.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">94584.91</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">668.52</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14625.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">78076.0</td>
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
      <td width="280">1541.41</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2699.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">342281.73</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">667.17</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">36614.61</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">44679.0</td>
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
      <td width="280">1658.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2240.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">341591.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">707.62</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">28724.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">121050.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">2081.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3463.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">362303.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">824.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">59937.87</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">149046.0</td>
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
      <td width="280">2289.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4072.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">422304.63</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">351.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">57713.35</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">122508.0</td>
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
      <td width="280">1302.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1315.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">180060.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">640.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">78635.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">137966.0</td>
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
      <td width="280">2176.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3013.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">328078.68</td>
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
      <td width="280">683.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5718.52</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">10670.0</td>
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
      <td width="280">148.17</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">524.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">87460.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">647.49</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15084.5</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">32753.0</td>
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
      <td width="280">146.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">482.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">82878.94</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2618.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14919.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">98862.0</td>
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
      <td width="280">1586.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2674.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">335106.71</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">2585.46</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">37788.25</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">126084.0</td>
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
      <td width="280">1116.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3306.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">330939.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1959.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">39877.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">125816.0</td>
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
      <td width="280">1487.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2483.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">250778.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3382.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">57725.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">145074.0</td>
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
      <td width="280">2589.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4479.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">433013.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1782.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43831.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123774.0</td>
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
      <td width="280">1697.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2143.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">228204.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2620.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">74528.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136826.0</td>
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
      <td width="280">2590.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3325.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">335444.32</td>
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
      <td width="280">1086.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7192.11</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">14990.0</td>
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
      <td width="280">137.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">468.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">69541.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">956.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">20423.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">44714.0</td>
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
      <td width="280">135.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">413.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">61207.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">4494.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">17380.77</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">111498.0</td>
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
      <td width="280">1129.17</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2641.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">287666.88</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">5289.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">36929.29</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">59453.0</td>
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
      <td width="280">1662.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2308.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">338505.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3827.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">40872.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123278.0</td>
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
      <td width="280">1058.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2326.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">244977.32</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5694.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">68610.82</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">141196.0</td>
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
      <td width="280">1526.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3604.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">364477.33</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3522.24</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">44451.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124304.0</td>
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
      <td width="280">1766.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2183.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">225423.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">4939.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">79139.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">135705.0</td>
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
      <td width="280">1962.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3044.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">316114.26</td>
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
      <td width="280">1108.38</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7049.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">15693.0</td>
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
      <td width="280">137.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">472.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">70936.17</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">896.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">21782.48</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">44434.0</td>
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
      <td width="280">134.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">367.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">57395.79</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">5980.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">13062.3</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">92527.0</td>
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
      <td width="280">1535.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">3304.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">382745.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">4955.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">39417.89</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">49640.0</td>
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
      <td width="280">1746.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1887.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">317124.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3985.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">39225.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124344.0</td>
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
      <td width="280">1437.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2495.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">255093.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5751.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">67968.82</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">140903.0</td>
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
      <td width="280">1535.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3634.41</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">368100.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3561.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43873.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124135.0</td>
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
      <td width="280">1862.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2158.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">227909.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">5178.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">75400.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136240.0</td>
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
      <td width="280">2627.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3349.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">331420.22</td>
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
      <td width="280">346.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5644.29</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">10693.0</td>
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
      <td width="280">154.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">561.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">88610.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">314.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">15538.42</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">34044.0</td>
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
      <td width="280">151.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">523.6</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">80452.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1376.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14186.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">91781.0</td>
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
      <td width="280">1596.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2876.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">352423.91</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1300.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">37535.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">45907.0</td>
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
      <td width="280">1714.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2318.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">333016.39</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1167.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">33490.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">123771.0</td>
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
      <td width="280">1784.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2900.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">298820.24</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1387.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">70392.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">139798.0</td>
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
      <td width="280">1434.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3446.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">355123.71</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">858.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">45483.15</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">124137.0</td>
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
      <td width="280">1470.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2007.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">219877.58</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1366.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">71456.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136486.0</td>
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
      <td width="280">2724.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3367.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">349823.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
