# folly 2022.11.14.00 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`43309743549-1`

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
      <td width="1200">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-12T21:43:46Z</td>
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
      <td width="1200">2026-11-12T21:40:31Z</td>
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
      <td width="1200">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 175995 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 176902 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 176920 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 176614 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193481 MB<br>node 4 free: 176842 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193523 MB<br>node 5 free: 177000 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 76327 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 75724 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
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
      <td width="280">30.31</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">4076.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">5772.0</td>
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
      <td width="280">138.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">314.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">124165.9</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">29.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">10451.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">17400.0</td>
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
      <td width="280">145.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">284.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">120310.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">162.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">7535.39</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">9821.0</td>
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
      <td width="280">1659.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">4880.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">663927.44</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">159.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">19117.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">23710.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">99.9999983011399</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">1</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1620.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">4919.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">654033.31</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">57.93</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">42736.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117209.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.9988105590513</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">254</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">766.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1407.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">237270.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">135.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">45986.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">126529.0</td>
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
      <td width="280">1795.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3303.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">556092.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">58.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">43419.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117988.0</td>
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
      <td width="280">1499.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1376.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">238116.06</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">112.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">56189.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">129208.0</td>
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
      <td width="280">2741.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2783.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=256B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">461012.41</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">88.47</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5613.91</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">7794.0</td>
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
      <td width="280">143.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">259.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">90593.28</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">102.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">12019.79</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">24206.0</td>
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
      <td width="280">146.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">277.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">104852.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">625.04</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">7817.74</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10038.0</td>
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
      <td width="280">1649.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">3330.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">640037.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">667.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">18296.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">24687.0</td>
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
      <td width="280">1599.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3929.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">683424.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">194.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">52178.53</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">116484.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99861236035831</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Failed Requests</td>
      <td width="280">249</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Client CPU (%)</td>
      <td width="280">556.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1113.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">199376.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">438.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">57538.71</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">125242.0</td>
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
      <td width="280">1281.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2543.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">449006.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">285.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">35170.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117232.0</td>
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
      <td width="280">1833.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1508.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">292736.46</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">484.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">51548.06</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">127248.0</td>
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
      <td width="280">2863.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2833.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">496405.46</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">320.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6102.93</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9874.0</td>
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
      <td width="280">134.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">237.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">81928.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">295.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">16548.56</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">21832.0</td>
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
      <td width="280">140.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">207.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">75546.66</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2272.3</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8594.62</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10642.0</td>
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
      <td width="280">1733.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1872.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">581709.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">2410.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">20252.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">25061.0</td>
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
      <td width="280">1740.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2242.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">617181.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2147.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">18190.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">112774.0</td>
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
      <td width="280">2156.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3410.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">549819.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2249.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">43411.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">130365.0</td>
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
      <td width="280">2040.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3436.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">575750.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1892.25</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">20660.55</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">116606.0</td>
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
      <td width="280">3857.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2862.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">484416.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2128.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">45873.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128222.0</td>
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
      <td width="280">3320.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3158.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">544978.6</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">568.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">6871.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">10992.0</td>
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
      <td width="280">135.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">253.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">72776.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">543.39</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">17974.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">23830.0</td>
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
      <td width="280">128.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">199.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">69554.38</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">4023.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9708.15</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">11931.0</td>
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
      <td width="280">1747.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1625.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">515012.24</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">3899.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">25048.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">74114.0</td>
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
      <td width="280">1568.6</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2616.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">499092.44</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">4695.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">16639.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">70161.0</td>
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
      <td width="280">2657.41</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4995.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">600984.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3710.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">52660.93</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">164821.0</td>
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
      <td width="280">1794.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4019.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">474985.06</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">3810.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">20497.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">115219.0</td>
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
      <td width="280">4116.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3430.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">487796.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3937.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">49626.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">129384.0</td>
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
      <td width="280">3491.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3389.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">503953.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Throughput</td>
      <td width="280">903.54</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8647.15</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13780.0</td>
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
      <td width="280">133.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">229.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">57826.53</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">844.36</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">23133.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">34846.0</td>
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
      <td width="280">146.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">183.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">54039.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6816.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">11460.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15525.0</td>
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
      <td width="280">1797.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1645.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">436241.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6768.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28856.3</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">37130.0</td>
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
      <td width="280">1790.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1683.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">433210.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">8338.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">18739.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">52630.0</td>
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
      <td width="280">2927.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3173.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">533677.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10717.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">36466.19</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">110318.0</td>
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
      <td width="280">3252.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">5596.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">685929.93</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">8183.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">19115.06</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">113599.0</td>
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
      <td width="280">4512.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3996.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">523730.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">8418.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">46439.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">136853.0</td>
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
      <td width="280">3983.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4426.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary payload / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">538759.86</td>
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
      <td width="280">224.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">4402.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">6297.0</td>
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
      <td width="280">139.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">264.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">115081.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">234.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">10466.62</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">17319.0</td>
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
      <td width="280">146.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">256.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">120208.77</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1131.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8637.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">13607.0</td>
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
      <td width="280">1700.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1862.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">579208.3</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">785.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">31399.97</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">95561.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">99.99970446888888</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">107</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">1083.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3649.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">402287.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">369.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">54501.9</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">116675.0</td>
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
      <td width="280">517.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1274.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">189330.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1394.23</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">35143.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">127741.0</td>
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
      <td width="280">2825.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4913.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">713847.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">654.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">30673.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117533.0</td>
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
      <td width="280">2979.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1825.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">335127.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">901.42</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">55996.33</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">129185.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">99.99849776416029</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">624</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">2516.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2755.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32 int / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">461527.34</td>
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
      <td width="280">110.52</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">4474.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8417.0</td>
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
      <td width="280">138.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">277.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">113171.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">118.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">10351.18</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">17370.0</td>
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
      <td width="280">149.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">230.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">121708.46</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">568.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8589.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10153.0</td>
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
      <td width="280">1700.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1559.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">582577.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">511.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">24096.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">114044.0</td>
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
      <td width="280">1115.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">3861.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">524053.27</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">498.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">20179.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">114394.0</td>
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
      <td width="280">1969.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3330.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">510135.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">524.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">47032.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">172283.0</td>
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
      <td width="280">1927.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4532.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">537154.1</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">268.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">37674.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">116259.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Success Rate</td>
      <td width="280">99.99899526831905</td>
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
      <td width="280">1535.12</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3364.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">275360.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">504.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">50321.89</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128704.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Failed Requests</td>
      <td width="280">0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Client CPU (%)</td>
      <td width="280">3141.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2847.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64 long / payload=1024B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">516676.32</td>
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
      <td width="280">49.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5006.7</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">8372.0</td>
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
      <td width="280">139.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">228.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">101027.47</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">53.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">11577.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">23254.0</td>
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
      <td width="280">145.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">229.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">108539.64</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">166.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">14787.59</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">34517.0</td>
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
      <td width="280">799.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">4147.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">341607.07</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">125.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">49179.87</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">96304.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Success Rate</td>
      <td width="280">99.99972743295186</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Failed Requests</td>
      <td width="280">63</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Client CPU (%)</td>
      <td width="280">645.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">4414.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">256816.84</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">125.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">39198.29</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">81623.0</td>
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
      <td width="280">824.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4392.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">257223.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">129.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">95062.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">193300.0</td>
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
      <td width="280">850.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4443.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">265851.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">129.17</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">39044.18</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117412.0</td>
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
      <td width="280">1739.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1833.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">264546.34</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">229.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">53725.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">140364.0</td>
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
      <td width="280">2542.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2971.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double / payload=512B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">469212.09</td>
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
      <td width="280">343.95</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5678.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9071.0</td>
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
      <td width="280">132.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">272.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">88051.84</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">391.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">12478.47</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">16687.0</td>
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
      <td width="280">141.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">243.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">100180.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2104.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9277.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10765.0</td>
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
      <td width="280">1791.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1511.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">538869.1</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1033.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">47248.55</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">88849.0</td>
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
      <td width="280">705.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">4486.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">264578.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2214.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">17640.74</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">67892.0</td>
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
      <td width="280">2389.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4965.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">566786.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2317.89</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">42130.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">157700.0</td>
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
      <td width="280">2288.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">4747.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">593380.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1386.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">28199.92</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">118807.0</td>
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
      <td width="280">2162.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2171.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">354931.59</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">1785.43</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">54726.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">127850.0</td>
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
      <td width="280">2745.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2842.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i32&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">457071.27</td>
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
      <td width="280">223.62</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">4421.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">6102.0</td>
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
      <td width="280">141.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">279.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">114494.0</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">229.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">10740.01</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">17613.0</td>
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
      <td width="280">151.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">255.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">117344.66</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">1051.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">9293.97</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10421.0</td>
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
      <td width="280">1720.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1652.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">538341.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">1171.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">20839.07</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">23148.0</td>
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
      <td width="280">1704.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2144.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">600012.79</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1468.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">13478.24</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">77508.0</td>
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
      <td width="280">2985.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4835.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">751876.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">997.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">50071.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">124621.0</td>
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
      <td width="280">1645.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3103.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">510961.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">482.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">41441.59</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">117193.0</td>
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
      <td width="280">1469.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">1406.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">247256.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">897.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">55523.71</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128248.0</td>
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
      <td width="280">3045.2</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2725.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;i64&gt; / payload=2048B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">459324.54</td>
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
      <td width="280">537.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">7269.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">11759.0</td>
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
      <td width="280">131.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">259.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">68782.9</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">537.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">18161.38</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">24732.0</td>
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
      <td width="280">139.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">255.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">68835.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">4437.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8802.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">10679.0</td>
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
      <td width="280">1797.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2195.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">567977.9</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">4489.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">21750.8</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">26460.0</td>
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
      <td width="280">1767.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">2218.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">574689.48</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2641.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">29609.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">115779.0</td>
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
      <td width="280">1188.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2115.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">338084.71</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">4375.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">44659.92</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">126467.0</td>
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
      <td width="280">2088.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3657.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">560068.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2877.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">27176.7</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">119759.0</td>
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
      <td width="280">2638.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2334.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">368271.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">3991.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">48945.79</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">126601.0</td>
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
      <td width="280">3344.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3390.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string / payload=8192B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">510863.59</td>
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
      <td width="280">910.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8580.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13477.0</td>
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
      <td width="280">138.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">225.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">58276.44</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">984.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">19841.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">25635.0</td>
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
      <td width="280">151.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">230.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">63004.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6194.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12611.91</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">15125.0</td>
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
      <td width="280">1786.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1742.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">396427.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6292.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">31038.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">37949.0</td>
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
      <td width="280">1794.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1756.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">402749.14</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">9983.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">15658.65</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">85323.0</td>
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
      <td width="280">3212.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4895.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">638949.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10800.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">36172.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">103988.0</td>
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
      <td width="280">3355.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">5354.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">691223.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">8254.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">18932.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">113253.0</td>
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
      <td width="280">4764.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4240.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">528263.49</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10266.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">38067.12</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">121942.0</td>
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
      <td width="280">5734.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">5714.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">657056.08</td>
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
      <td width="280">909.39</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">8592.35</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">13586.0</td>
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
      <td width="280">142.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">223.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">58201.01</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">951.98</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">20518.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">25846.0</td>
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
      <td width="280">146.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">197.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">60926.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">6226.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">12545.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">14826.0</td>
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
      <td width="280">1796.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">1532.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">398519.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">6773.31</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">28833.56</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">34473.0</td>
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
      <td width="280">1782.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1632.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">433491.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">10644.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">14677.12</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">16268.0</td>
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
      <td width="280">3485.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3385.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">681237.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">9796.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">39867.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">41326.0</td>
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
      <td width="280">3376.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">2934.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">626961.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">8782.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">17808.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">113071.0</td>
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
      <td width="280">4778.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">4075.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">562109.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">10704.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">36481.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">121376.0</td>
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
      <td width="280">5487.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">5258.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">set&lt;string&gt; / payload=16384B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">685110.14</td>
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
      <td width="280">333.93</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyAvg</td>
      <td width="280">5850.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / latencyP99</td>
      <td width="280">9419.0</td>
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
      <td width="280">144.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / Server CPU (%)</td>
      <td width="280">283.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=10 / QPS</td>
      <td width="280">85485.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Throughput</td>
      <td width="280">346.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyAvg</td>
      <td width="280">14109.04</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / latencyP99</td>
      <td width="280">19467.0</td>
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
      <td width="280">153.86</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / Server CPU (%)</td>
      <td width="280">273.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=1 / io=1 / connections=50 / qd=25 / QPS</td>
      <td width="280">88598.01</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Throughput</td>
      <td width="280">2309.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyAvg</td>
      <td width="280">8455.08</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / latencyP99</td>
      <td width="280">9863.0</td>
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
      <td width="280">1761.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / Server CPU (%)</td>
      <td width="280">2008.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=10 / QPS</td>
      <td width="280">591311.53</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Throughput</td>
      <td width="280">2046.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyAvg</td>
      <td width="280">23853.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / latencyP99</td>
      <td width="280">25753.0</td>
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
      <td width="280">1745.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / Server CPU (%)</td>
      <td width="280">1808.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=10 / io=10 / connections=500 / qd=25 / QPS</td>
      <td width="280">523946.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">2806.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">13919.67</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">49915.0</td>
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
      <td width="280">3045.17</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">3930.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=10 / QPS</td>
      <td width="280">718537.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2229.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">43821.18</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">128302.0</td>
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
      <td width="280">2023.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3516.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=20 / io=20 / connections=1000 / qd=25 / QPS</td>
      <td width="280">570674.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Throughput</td>
      <td width="280">1352.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyAvg</td>
      <td width="280">28915.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / latencyP99</td>
      <td width="280">119464.0</td>
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
      <td width="280">2317.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / Server CPU (%)</td>
      <td width="280">2105.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=10 / QPS</td>
      <td width="280">346137.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Throughput</td>
      <td width="280">2013.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyAvg</td>
      <td width="280">48520.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / latencyP99</td>
      <td width="280">129175.0</td>
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
      <td width="280">3222.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / Server CPU (%)</td>
      <td width="280">3203.59</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">map&lt;string, i64&gt; / payload=4096B / cpu=40 / io=40 / connections=1000 / qd=25 / QPS</td>
      <td width="280">515422.68</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
