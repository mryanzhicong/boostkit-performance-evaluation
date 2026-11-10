# oceanbase 4.2.5.6 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`42912889291-1`

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
      <td width="1200">4.2.5.6</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">4.2.5.6</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-10T22:19:06Z</td>
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
      <td width="1200">2026-11-10T22:16:19Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 336311 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 373756 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 378895 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 380437 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">sysbench</td>
      <td width="880">1.0.20</td>
    </tr>
    <tr>
      <td width="500">obproxy</td>
      <td width="880">4.3.6.1</td>
    </tr>
  </tbody>
</table>

## 性能指标

### read_only

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
      <td width="500">read_only :: threads=1 :: tps</td>
      <td width="280">560.85</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=1 :: qps</td>
      <td width="280">8973.63</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=1 :: avg_latency_ms</td>
      <td width="280">1.78</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=1 :: p95_latency_ms</td>
      <td width="280">1.89</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: tps</td>
      <td width="280">20720.71</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: qps</td>
      <td width="280">331531.33</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: avg_latency_ms</td>
      <td width="280">3.09</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=64 :: p95_latency_ms</td>
      <td width="280">3.55</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: tps</td>
      <td width="280">32045.24</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: qps</td>
      <td width="280">512723.88</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: avg_latency_ms</td>
      <td width="280">7.99</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_only :: threads=256 :: p95_latency_ms</td>
      <td width="280">9.73</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### insert

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
      <td width="500">insert :: threads=1 :: tps</td>
      <td width="280">3012.12</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=1 :: qps</td>
      <td width="280">3012.12</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=1 :: avg_latency_ms</td>
      <td width="280">0.33</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=1 :: p95_latency_ms</td>
      <td width="280">0.41</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: tps</td>
      <td width="280">107590.86</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: qps</td>
      <td width="280">107590.86</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: avg_latency_ms</td>
      <td width="280">0.59</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=64 :: p95_latency_ms</td>
      <td width="280">0.73</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: tps</td>
      <td width="280">70762.18</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: qps</td>
      <td width="280">70762.18</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: avg_latency_ms</td>
      <td width="280">3.61</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">insert :: threads=256 :: p95_latency_ms</td>
      <td width="280">6.79</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### read_write

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
      <td width="500">read_write :: threads=1 :: tps</td>
      <td width="280">302.49</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=1 :: qps</td>
      <td width="280">6049.82</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=1 :: avg_latency_ms</td>
      <td width="280">3.31</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=1 :: p95_latency_ms</td>
      <td width="280">3.82</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: tps</td>
      <td width="280">12419.65</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: qps</td>
      <td width="280">248393.09</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: avg_latency_ms</td>
      <td width="280">5.15</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=64 :: p95_latency_ms</td>
      <td width="280">5.99</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: tps</td>
      <td width="280">21392.53</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: qps</td>
      <td width="280">427850.64</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: avg_latency_ms</td>
      <td width="280">11.96</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">read_write :: threads=256 :: p95_latency_ms</td>
      <td width="280">13.95</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### write_only

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
      <td width="500">write_only :: threads=1 :: tps</td>
      <td width="280">774.99</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=1 :: qps</td>
      <td width="280">4649.92</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=1 :: avg_latency_ms</td>
      <td width="280">1.29</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=1 :: p95_latency_ms</td>
      <td width="280">1.52</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: tps</td>
      <td width="280">36776.1</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: qps</td>
      <td width="280">220656.57</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: avg_latency_ms</td>
      <td width="280">1.74</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=64 :: p95_latency_ms</td>
      <td width="280">2.07</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: tps</td>
      <td width="280">68973.44</td>
      <td width="200">transactions/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: qps</td>
      <td width="280">413840.64</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: avg_latency_ms</td>
      <td width="280">3.71</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">write_only :: threads=256 :: p95_latency_ms</td>
      <td width="280">4.49</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
