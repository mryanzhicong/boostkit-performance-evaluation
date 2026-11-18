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
      <td width="180">Acceleration</td>
      <td width="220">fbthrift</td>
      <td width="160">2022.11.14.00</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### fbthrift 2022.11.14.00

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
      <td width="600">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">N/A</td>
      <td width="600">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">N/A</td>
      <td width="600">2026-11-18T09:52:01Z</td>
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
      <td width="600">2026-11-18T09:47:41Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 352191 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 380690 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 296728 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 348693 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">Folly</td>
      <td width="880">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="500">Fizz</td>
      <td width="880">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="500">Wangle</td>
      <td width="880">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="500">fbthrift</td>
      <td width="880">2022.11.14.00</td>
    </tr>
    <tr>
      <td width="500">AccLibBenchmark</td>
      <td width="880">unknown</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### aarch64

#### fbthrift 2022.11.14.00

##### binary-1024B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">724.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">7717.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">169752.52</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">1469.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">165.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">58983.56</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">120418.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">963.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">7960.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">153023.98</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">1256.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">149.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">65413.89</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">119954.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">1513.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">7887.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">373327.35</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">3198.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">99.98</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">364.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">67019.35</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">132549.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">2648.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">20563.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">367994.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">3178.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.95</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">359.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">67956.33</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">135014.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2431.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">36891.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">565082.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4640.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">99.95</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">551.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">88613.16</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">159228.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">3413.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">23139.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">542292.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4606.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">529.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">92198.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">149525.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1544.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">11471.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">255250.73</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2377.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">249.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">78538.82</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">127965.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">3630.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">17561.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">537235.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4660.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">524.64</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">93128.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">154016.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">5874.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">41139136.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">554211.07</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">5585.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">61.78</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">541.22</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">144365.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">151640.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">149.41</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">548.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">78504.26</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">274.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">99.99</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">76.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">6275.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">13613.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">145.12</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">374.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">100144.93</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">363.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">97.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">12442.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">27823.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">150.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">101.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">83561.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">295.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">81.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">29928.27</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">57803.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">1573.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">100.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">417512.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">2290.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">407.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">11976.18</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">90359.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">1157.14</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">7166.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">418555.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">3370.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">99.99</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">408.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">29889.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">120129.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1455.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">17466.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">499259.38</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">4348.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">487.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">50183.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-1024B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">142446.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### binary-16384B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">1389.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">269368.44</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">2474.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">4208.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">37190.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">122687.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">2132.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">240926.85</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2346.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">3764.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">41563.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">122227.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">1621.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">376758.21</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">3577.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">5886.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">66356.25</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">137564.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">2602.52</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">338942.69</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">3379.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">5295.98</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">73724.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">132324.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2808.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">496009.45</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4722.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">7750.15</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">100826.43</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">152221.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">4187.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">485849.86</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4708.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">7591.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">102921.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">140798.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">2284.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">299841.64</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2811.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">4685.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">66682.57</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">126797.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">4225.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">524769.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4855.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">8199.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">95223.12</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">144207.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">7021.54</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">64987402.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">509872.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">6619.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">48.49</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">7966.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">140500.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">169424.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">131.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">53102.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">222.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">829.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">9416.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">17443.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">127.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">65715.03</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">264.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">1026.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">19022.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">37385.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">130.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">50972.24</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">200.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">796.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">49059.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">76679.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">1785.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">327624.34</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">1543.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">5119.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">15261.18</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">18894.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">1627.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">478120.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">3566.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">7470.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">26145.65</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">71865.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1731.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">330733.23</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">1478.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">5167.71</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">75609.87</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-16384B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">92670.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### binary-256B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">484.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">8003.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">148455.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">1312.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">36.24</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">67367.59</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">120043.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">992.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">6240.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">151553.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">1297.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">37.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">66113.12</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">120237.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">1147.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">16150.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">322869.69</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">2991.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">78.83</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">77593.71</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">131122.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">2104.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">17461.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">330850.97</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">2716.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">80.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">75738.98</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">132250.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2507.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">23648.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">508462.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4541.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">124.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">98523.39</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">157321.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">3533.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">25426.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">557587.36</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4624.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">136.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">89807.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">151994.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1864.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">13966.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">286211.02</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2296.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">69.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">70012.07</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">126987.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">3148.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">24153.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">559140.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4246.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">136.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">89431.97</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">149836.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">5967.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">37386478.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">609798.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">5707.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">66.19</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">148.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">140186.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">150175.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">155.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">306.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">115058.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">234.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">28.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">4321.18</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">6272.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">157.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">264.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">120588.55</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">241.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">29.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">10349.06</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">17318.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">157.36</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">99.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">121604.55</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">233.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">29.69</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">20562.26</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">31527.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">1739.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">53.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">380531.85</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">1783.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">92.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">13139.33</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">14362.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">1718.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">41.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">384386.33</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">1907.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">93.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">32520.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">34722.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1384.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">90.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">458965.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">4100.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">112.05</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">54475.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-256B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">147020.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### binary-4096B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">998.74</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">248772.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">2209.6</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">971.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">40234.12</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">122203.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1891.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">249040.48</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2176.6</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">972.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">40194.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">121613.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">1397.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">356238.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">3316.41</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">1391.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">70231.48</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">135022.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">2452.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">335358.34</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">3162.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">1309.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">74601.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">133072.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2219.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">495931.65</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4588.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">1937.23</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">100839.11</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">151316.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">3763.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">482609.09</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4624.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">1885.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">103614.82</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">143259.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1720.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">275470.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2578.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">1076.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">72619.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">128227.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">3865.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">488063.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4631.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">1906.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">102456.79</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">145633.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">6077.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">45833162.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">475730.99</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">5637.35</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">55.47</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">1858.32</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">148595.74</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">158488.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">142.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">56964.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">210.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">222.52</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">8777.93</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">13906.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">142.03</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">65804.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">242.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">257.05</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">18997.27</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">28986.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">146.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">60358.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">186.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">235.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">41426.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">53228.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">1715.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">427817.43</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">3089.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">1671.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">11687.03</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">17099.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">1009.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">350288.16</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">3079.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">1368.31</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">35720.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">124979.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1481.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">484660.74</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">4406.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">1893.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">51596.4</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-4096B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">139595.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### binary-8192B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">1297.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">253106.9</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">2396.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">1977.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">39554.91</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">123840.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1976.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">246146.2</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2263.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">1923.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">40641.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">122594.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">1297.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">348511.4</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">3308.05</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">2722.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">71777.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">135094.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">2750.53</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">355160.61</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">3414.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">2774.69</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">70394.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">132780.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2616.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">138.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">483010.88</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4595.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">3773.52</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">103546.82</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">152662.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">4011.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">495700.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4694.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">3872.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">100841.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">143886.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">2304.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">299853.28</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2884.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">2342.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">66698.41</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">127752.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">3779.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">509221.24</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4735.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">3978.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">98177.3</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">143185.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">6303.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">47299805.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">460441.46</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">5729.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">53.88</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">3597.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">148963.42</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">155928.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">138.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">67971.38</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">270.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">531.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">7357.09</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">14570.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">141.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">79092.8</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">272.67</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">617.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">15806.21</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">31801.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">139.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">66493.54</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">253.56</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">519.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">37605.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">62010.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">1776.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">368287.56</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">1918.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">2877.25</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">13575.97</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">15931.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">1189.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">365743.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">3368.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">2857.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">34189.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">122180.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1453.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">437472.72</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">3850.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">3417.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">57157.43</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">binary-8192B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">137876.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### double-512B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">589.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">6175.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">156475.98</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">1421.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">76.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">64087.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">120252.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1046.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">6718.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">153877.27</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">1371.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">75.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">65126.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">120377.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">1305.04</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">13723.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">346115.38</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">3073.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">169.0</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">72414.27</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">132375.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">1933.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">17259.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">318015.55</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">2586.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.95</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">155.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">78763.45</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">131179.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2190.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">21867.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">517233.17</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4570.06</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">252.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">96708.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">151271.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">3108.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">30712.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">529472.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4545.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">99.95</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">258.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">94586.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">149560.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1550.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">10798.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">260398.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2297.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">127.15</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">76970.84</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">126770.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">3465.65</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">29036.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">542548.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4627.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">264.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">92281.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">149783.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">5933.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">45735774.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">498586.07</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">5496.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">56.68</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">243.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">146412.14</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">154429.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">147.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">605.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">87365.58</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">312.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">99.99</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">42.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">5632.71</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">13360.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">152.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">426.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">77195.7</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">238.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">37.69</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">16127.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">33930.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">147.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">93.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">97726.79</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">339.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">47.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">25586.61</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">52997.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">1557.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">2255.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">444647.91</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">3653.47</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">217.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">11273.02</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">90112.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">924.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">7264.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">312120.32</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">2685.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">99.98</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">152.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">40152.99</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">122253.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1352.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">15126.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">456499.96</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">4124.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">222.9</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">54939.27</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">double-512B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">144668.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### i32-2048B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">626.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">5971.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">160545.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">1431.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">313.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">62466.6</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">120548.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">906.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">6221.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">147868.56</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">1301.33</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">288.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">67820.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">119917.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">1396.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">15616.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">358916.62</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">3187.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">701.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">69833.32</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">132830.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">1984.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">16265.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">317425.32</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">2774.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">619.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">78866.92</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">131067.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2325.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">27666.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">522225.58</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4648.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">1019.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">95898.84</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">153769.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">3296.75</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">21255.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">534318.5</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4693.73</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">1043.59</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">93546.83</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">149912.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1732.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">13955.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">268925.17</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2281.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">525.24</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">74486.99</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">127105.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">3311.82</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">28187.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">522815.58</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4740.43</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">1021.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">95823.59</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">147457.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">5929.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">42702258.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">454426.07</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">5458.66</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">56.08</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">887.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">151431.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">160504.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">148.32</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">442.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">81695.33</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">314.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">159.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">6058.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">13822.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">150.0</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">391.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">90055.01</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">343.7</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">175.89</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">13833.81</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">33497.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">148.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">114.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">97153.07</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">381.58</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">189.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">25736.73</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">52535.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">618.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">3878.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">193693.05</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">1531.61</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">99.98</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">378.31</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">25825.86</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">115856.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">1730.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">70.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">407861.75</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">2335.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">796.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">30648.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">37290.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1558.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">5252.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">484347.84</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">4420.55</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">99.99</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">945.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">51626.79</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i32-2048B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">142812.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### i64-1024B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">773.79</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">7216.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">170500.52</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">1612.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">166.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">58751.28</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">120740.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1059.44</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">2535.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">149617.76</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">1432.97</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.99</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">146.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">66932.87</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">120870.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">1333.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">14973.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">333588.59</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">3159.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">325.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">75103.51</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">132238.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">2522.27</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">16214.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">332864.08</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">3256.89</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">325.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">75248.68</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">134304.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2445.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">28492.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">486271.4</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4551.24</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">99.95</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">474.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">103115.95</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">149747.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">3687.68</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">20728.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">495216.89</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4629.12</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">483.61</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">101157.39</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">146499.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1632.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">10976.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">250360.19</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2388.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">244.49</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">80096.2</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">127551.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">3609.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">34021.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">500746.88</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4643.41</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.94</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">489.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">99936.46</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">146177.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">5958.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">45281368.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">537425.57</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">5661.29</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">58.75</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">524.83</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">143931.3</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">152432.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">151.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">496.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">109857.02</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">316.48</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">107.28</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">4496.79</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">6686.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">149.17</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">443.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">96058.21</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">345.62</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">93.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">12962.85</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">30946.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">148.96</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">95.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">98377.46</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">371.37</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">96.07</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">25417.11</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">56154.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">1721.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">54.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">358656.6</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">1681.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">350.25</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">13941.38</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">15222.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">1685.41</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">55.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">378759.47</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">2022.6</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">369.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">33003.76</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">75691.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1502.11</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">1053.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">457569.92</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">4279.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">446.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">54652.44</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">i64-1024B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">145099.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### list-i32-4096B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">999.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">251870.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">2279.49</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">983.87</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">39728.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">121770.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1984.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">253741.54</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2288.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">991.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">39480.33</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">121221.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">2426.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">456709.11</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">4331.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">1784.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">54741.77</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">143096.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">2585.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">348173.13</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">3302.26</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">1360.05</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">71805.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">134047.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2692.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">490405.56</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4600.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">1915.65</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">101950.22</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">163155.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">3801.57</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">489686.02</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4632.92</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">1912.84</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">102089.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">144155.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">2255.98</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">295016.82</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2779.34</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">1152.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">67807.03</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">128922.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">3859.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">491654.18</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4645.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">1920.52</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">101704.93</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">145380.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">6097.13</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">44622137.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">456891.75</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">5574.69</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">55.13</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">1784.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">150407.5</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">157779.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">142.71</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">64802.38</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">244.93</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">253.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">7716.13</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">13875.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">145.16</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">88368.28</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">299.17</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">345.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">14146.62</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">28162.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">145.81</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">92778.39</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">305.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">362.42</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">26947.17</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">54404.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">1762.08</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">364029.83</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">1810.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">1421.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">13734.75</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">15490.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">1453.3</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">433949.25</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">3468.12</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">1695.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">28805.74</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">111785.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1732.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">398521.88</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">2268.91</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">1556.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">62732.89</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i32-4096B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">69254.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### list-i64-2048B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">813.45</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">5471.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">173159.88</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">1641.12</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">338.2</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">57995.66</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">120797.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1114.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">6473.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">153497.48</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">1474.15</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">299.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">65314.67</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">121120.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">2311.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">17903.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">446179.12</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">4234.94</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">99.97</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">871.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">56061.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">138399.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">2593.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">15797.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">342309.3</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">3325.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">668.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">73158.19</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">133848.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2294.99</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">25086.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">492589.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4599.1</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">962.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">101757.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">147668.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">3733.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">21465.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">490567.47</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4667.09</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">958.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">102051.64</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">144399.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">1512.5</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">12429.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">247814.44</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2428.01</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">99.96</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">484.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">80941.88</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">127468.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">3868.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">31115.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">490757.51</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4667.95</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">99.95</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">958.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">101928.65</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">143025.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">5972.72</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">39308887.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">486185.42</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">5528.25</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">59.75</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">949.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">150103.54</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">158639.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">145.46</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">459.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">101596.65</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">371.87</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">198.43</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">4864.58</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">7593.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">150.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">308.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">107288.14</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">394.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">209.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">11618.25</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">19081.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">151.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">92.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">109067.32</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">386.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">213.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">22925.63</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">33736.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">1750.51</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">67.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">387208.03</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">2089.02</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">756.27</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">12912.94</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">15231.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">852.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">5697.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">290242.37</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">2617.18</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">99.98</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">566.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">43190.9</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">121940.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1667.88</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">56.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">454209.03</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">3675.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">887.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">55049.79</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">list-i64-2048B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">126883.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### string-8192B

<table width="1380">
  <thead>
    <tr>
      <th width="500">指标</th>
      <th width="280">数值</th>
      <th width="200">单位</th>
      <th width="400">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu20 :: Client CPU (%)</td>
      <td width="280">1257.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu20 :: QPS</td>
      <td width="280">270501.47</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu20 :: Server CPU (%)</td>
      <td width="280">2486.42</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu20 :: Throughput</td>
      <td width="280">2113.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu20 :: latencyAvg</td>
      <td width="280">37007.53</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu20 :: latencyP99</td>
      <td width="280">122234.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">2062.4</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu40 :: QPS</td>
      <td width="280">253024.27</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2288.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu40 :: Throughput</td>
      <td width="280">1976.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">39541.78</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd10-cpu40 :: latencyP99</td>
      <td width="280">120883.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu20 :: Client CPU (%)</td>
      <td width="280">1439.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu20 :: QPS</td>
      <td width="280">363770.81</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu20 :: Server CPU (%)</td>
      <td width="280">3315.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu20 :: Throughput</td>
      <td width="280">2841.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu20 :: latencyAvg</td>
      <td width="280">68741.08</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu20 :: latencyP99</td>
      <td width="280">135812.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">2313.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu40 :: QPS</td>
      <td width="280">340816.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">3092.63</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu40 :: Throughput</td>
      <td width="280">2662.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">73374.7</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd25-cpu40 :: latencyP99</td>
      <td width="280">131321.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu20 :: Client CPU (%)</td>
      <td width="280">2423.31</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu20 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu20 :: QPS</td>
      <td width="280">504716.75</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu20 :: Server CPU (%)</td>
      <td width="280">4635.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu20 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu20 :: Throughput</td>
      <td width="280">3943.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu20 :: latencyAvg</td>
      <td width="280">99054.19</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu20 :: latencyP99</td>
      <td width="280">153061.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">3866.28</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu40 :: QPS</td>
      <td width="280">487778.42</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">4646.22</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu40 :: Throughput</td>
      <td width="280">3810.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">102506.89</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn1000-qd50-cpu40 :: latencyP99</td>
      <td width="280">143310.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd10-cpu40 :: Client CPU (%)</td>
      <td width="280">2219.76</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd10-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd10-cpu40 :: QPS</td>
      <td width="280">296194.03</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd10-cpu40 :: Server CPU (%)</td>
      <td width="280">2785.64</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd10-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd10-cpu40 :: Throughput</td>
      <td width="280">2314.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd10-cpu40 :: latencyAvg</td>
      <td width="280">67512.98</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd10-cpu40 :: latencyP99</td>
      <td width="280">129035.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd25-cpu40 :: Client CPU (%)</td>
      <td width="280">4078.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd25-cpu40 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd25-cpu40 :: QPS</td>
      <td width="280">507075.87</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd25-cpu40 :: Server CPU (%)</td>
      <td width="280">4715.19</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd25-cpu40 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd25-cpu40 :: Throughput</td>
      <td width="280">3961.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd25-cpu40 :: latencyAvg</td>
      <td width="280">98610.99</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd25-cpu40 :: latencyP99</td>
      <td width="280">145167.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd50-cpu40 :: Client CPU (%)</td>
      <td width="280">6315.23</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd50-cpu40 :: Failed Requests</td>
      <td width="280">43784403.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd50-cpu40 :: QPS</td>
      <td width="280">485904.21</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd50-cpu40 :: Server CPU (%)</td>
      <td width="280">5720.59</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd50-cpu40 :: Success Rate</td>
      <td width="280">57.11</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd50-cpu40 :: Throughput</td>
      <td width="280">3796.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd50-cpu40 :: latencyAvg</td>
      <td width="280">148393.42</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn2000-qd50-cpu40 :: latencyP99</td>
      <td width="280">154914.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd10-cpu1 :: Client CPU (%)</td>
      <td width="280">137.39</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd10-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd10-cpu1 :: QPS</td>
      <td width="280">74162.32</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd10-cpu1 :: Server CPU (%)</td>
      <td width="280">280.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd10-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd10-cpu1 :: Throughput</td>
      <td width="280">579.39</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd10-cpu1 :: latencyAvg</td>
      <td width="280">6742.55</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd10-cpu1 :: latencyP99</td>
      <td width="280">13501.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd25-cpu1 :: Client CPU (%)</td>
      <td width="280">139.85</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd25-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd25-cpu1 :: QPS</td>
      <td width="280">69170.58</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd25-cpu1 :: Server CPU (%)</td>
      <td width="280">263.38</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd25-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd25-cpu1 :: Throughput</td>
      <td width="280">540.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd25-cpu1 :: latencyAvg</td>
      <td width="280">18073.23</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd25-cpu1 :: latencyP99</td>
      <td width="280">30177.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd50-cpu1 :: Client CPU (%)</td>
      <td width="280">137.6</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd50-cpu1 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd50-cpu1 :: QPS</td>
      <td width="280">75704.29</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd50-cpu1 :: Server CPU (%)</td>
      <td width="280">302.77</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd50-cpu1 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd50-cpu1 :: Throughput</td>
      <td width="280">591.44</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd50-cpu1 :: latencyAvg</td>
      <td width="280">33029.34</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn50-qd50-cpu1 :: latencyP99</td>
      <td width="280">58020.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd10-cpu10 :: Client CPU (%)</td>
      <td width="280">1798.9</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd10-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd10-cpu10 :: QPS</td>
      <td width="280">361863.53</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd10-cpu10 :: Server CPU (%)</td>
      <td width="280">1924.8</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd10-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd10-cpu10 :: Throughput</td>
      <td width="280">2827.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd10-cpu10 :: latencyAvg</td>
      <td width="280">13816.96</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd10-cpu10 :: latencyP99</td>
      <td width="280">16504.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd25-cpu10 :: Client CPU (%)</td>
      <td width="280">1622.21</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd25-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd25-cpu10 :: QPS</td>
      <td width="280">395278.22</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd25-cpu10 :: Server CPU (%)</td>
      <td width="280">2931.78</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd25-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd25-cpu10 :: Throughput</td>
      <td width="280">3088.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd25-cpu10 :: latencyAvg</td>
      <td width="280">31626.1</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd25-cpu10 :: latencyP99</td>
      <td width="280">107104.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd50-cpu10 :: Client CPU (%)</td>
      <td width="280">1758.83</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd50-cpu10 :: Failed Requests</td>
      <td width="280">0.0</td>
      <td width="200">requests</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd50-cpu10 :: QPS</td>
      <td width="280">362054.33</td>
      <td width="200">ops/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd50-cpu10 :: Server CPU (%)</td>
      <td width="280">1837.07</td>
      <td width="200">%</td>
      <td width="400">仅展示</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd50-cpu10 :: Success Rate</td>
      <td width="280">100.0</td>
      <td width="200">%</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd50-cpu10 :: Throughput</td>
      <td width="280">2828.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd50-cpu10 :: latencyAvg</td>
      <td width="280">69050.31</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">string-8192B-conn500-qd50-cpu10 :: latencyP99</td>
      <td width="280">72705.0</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
