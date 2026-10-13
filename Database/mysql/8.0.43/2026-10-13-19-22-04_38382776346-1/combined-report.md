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
      <td width="180">Database</td>
      <td width="220">mysql</td>
      <td width="160">8.0.43</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Database</td>
      <td width="220">mysql</td>
      <td width="160">8.0.43</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### mysql 8.0.43

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
      <td width="600">8.0.43</td>
      <td width="600">8.0.43</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">8.0.43</td>
      <td width="600">8.0.43</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-10-13T10:21:34Z</td>
      <td width="600">2026-10-13T10:22:02Z</td>
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
      <td width="600">2026-10-13T10:21:09Z</td>
      <td width="600">2026-10-13T10:21:31Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 0 size: 192588 MB<br>node 0 free: 137064 MB<br>node 1 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 1 size: 193511 MB<br>node 1 free: 161358 MB<br>node 2 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 2 size: 193469 MB<br>node 2 free: 120628 MB<br>node 3 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 193443 MB<br>node 3 free: 93083 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  32  32 <br>  1:  12  10  32  32 <br>  2:  32  32  10  12 <br>  3:  32  32  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 574945 MB<br>node 0 free: 312703 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 580594 MB<br>node 1 free: 424328 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 580594 MB<br>node 2 free: 404040 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 482782 MB<br>node 3 free: 314046 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">sysbench</td>
      <td width="880">1.0.20 (ebf1c90)</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### mysql 8.0.43

##### read_only

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">P95 latency（ms）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">1</td>
      <td width="400">889.0</td>
      <td width="400">14224.07</td>
      <td width="400">1.16</td>
    </tr>
    <tr>
      <td width="180">32</td>
      <td width="400">8797.42</td>
      <td width="400">140758.66</td>
      <td width="400">4.57</td>
    </tr>
    <tr>
      <td width="180">128</td>
      <td width="400">2019.72</td>
      <td width="400">32315.5</td>
      <td width="400">90.78</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">1158.37</td>
      <td width="400">18533.89</td>
      <td width="400">325.98</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 越大越好；P95 延迟越小越好。

##### read_write

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">P95 latency（ms）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">1</td>
      <td width="400">275.55</td>
      <td width="400">5510.99</td>
      <td width="400">5.37</td>
    </tr>
    <tr>
      <td width="180">32</td>
      <td width="400">2490.43</td>
      <td width="400">49808.66</td>
      <td width="400">17.95</td>
    </tr>
    <tr>
      <td width="180">128</td>
      <td width="400">1292.24</td>
      <td width="400">25844.79</td>
      <td width="400">158.63</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">815.75</td>
      <td width="400">16314.99</td>
      <td width="400">458.96</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 越大越好；P95 延迟越小越好。

##### write_only

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">P95 latency（ms）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">1</td>
      <td width="400">799.8</td>
      <td width="400">4798.79</td>
      <td width="400">1.86</td>
    </tr>
    <tr>
      <td width="180">32</td>
      <td width="400">5591.68</td>
      <td width="400">33550.1</td>
      <td width="400">11.04</td>
    </tr>
    <tr>
      <td width="180">128</td>
      <td width="400">3652.28</td>
      <td width="400">21913.66</td>
      <td width="400">116.8</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">2170.14</td>
      <td width="400">13020.84</td>
      <td width="400">211.6</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 越大越好；P95 延迟越小越好。

### aarch64

#### mysql 8.0.43

##### read_only

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">P95 latency（ms）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">1</td>
      <td width="400">736.24</td>
      <td width="400">11779.78</td>
      <td width="400">1.44</td>
    </tr>
    <tr>
      <td width="180">32</td>
      <td width="400">3137.53</td>
      <td width="400">50200.54</td>
      <td width="400">13.95</td>
    </tr>
    <tr>
      <td width="180">128</td>
      <td width="400">1127.9</td>
      <td width="400">18046.42</td>
      <td width="400">164.45</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">681.99</td>
      <td width="400">10911.81</td>
      <td width="400">569.67</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 越大越好；P95 延迟越小越好。

##### read_write

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">P95 latency（ms）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">1</td>
      <td width="400">291.44</td>
      <td width="400">5828.76</td>
      <td width="400">6.55</td>
    </tr>
    <tr>
      <td width="180">32</td>
      <td width="400">1001.72</td>
      <td width="400">20034.42</td>
      <td width="400">43.39</td>
    </tr>
    <tr>
      <td width="180">128</td>
      <td width="400">699.59</td>
      <td width="400">13991.75</td>
      <td width="400">262.64</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">441.85</td>
      <td width="400">8836.92</td>
      <td width="400">831.46</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 越大越好；P95 延迟越小越好。

##### write_only

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">P95 latency（ms）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">1</td>
      <td width="400">589.79</td>
      <td width="400">3538.73</td>
      <td width="400">2.66</td>
    </tr>
    <tr>
      <td width="180">32</td>
      <td width="400">2497.24</td>
      <td width="400">14983.45</td>
      <td width="400">24.38</td>
    </tr>
    <tr>
      <td width="180">128</td>
      <td width="400">1797.03</td>
      <td width="400">10782.19</td>
      <td width="400">137.35</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">1108.33</td>
      <td width="400">6650.01</td>
      <td width="400">363.18</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 越大越好；P95 延迟越小越好。

## 跨架构指标

### mysql 8.0.43

#### read_only

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">1</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">889.0</td>
      <td width="190">736.24</td>
      <td width="360">0.8282</td>
    </tr>
    <tr>
      <td width="150">1</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">14224.07</td>
      <td width="190">11779.78</td>
      <td width="360">0.8282</td>
    </tr>
    <tr>
      <td width="150">1</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">1.16</td>
      <td width="190">1.44</td>
      <td width="360">0.8056</td>
    </tr>
    <tr>
      <td width="150">32</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">8797.42</td>
      <td width="190">3137.53</td>
      <td width="360">0.3566</td>
    </tr>
    <tr>
      <td width="150">32</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">140758.66</td>
      <td width="190">50200.54</td>
      <td width="360">0.3566</td>
    </tr>
    <tr>
      <td width="150">32</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">4.57</td>
      <td width="190">13.95</td>
      <td width="360">0.3276</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">2019.72</td>
      <td width="190">1127.9</td>
      <td width="360">0.5584</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">32315.5</td>
      <td width="190">18046.42</td>
      <td width="360">0.5584</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">90.78</td>
      <td width="190">164.45</td>
      <td width="360">0.552</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">1158.37</td>
      <td width="190">681.99</td>
      <td width="360">0.5887</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">18533.89</td>
      <td width="190">10911.81</td>
      <td width="360">0.5887</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">325.98</td>
      <td width="190">569.67</td>
      <td width="360">0.5722</td>
    </tr>
  </tbody>
</table>

#### read_write

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">1</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">275.55</td>
      <td width="190">291.44</td>
      <td width="360">1.0577</td>
    </tr>
    <tr>
      <td width="150">1</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">5510.99</td>
      <td width="190">5828.76</td>
      <td width="360">1.0577</td>
    </tr>
    <tr>
      <td width="150">1</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">5.37</td>
      <td width="190">6.55</td>
      <td width="360">0.8198</td>
    </tr>
    <tr>
      <td width="150">32</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">2490.43</td>
      <td width="190">1001.72</td>
      <td width="360">0.4022</td>
    </tr>
    <tr>
      <td width="150">32</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">49808.66</td>
      <td width="190">20034.42</td>
      <td width="360">0.4022</td>
    </tr>
    <tr>
      <td width="150">32</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">17.95</td>
      <td width="190">43.39</td>
      <td width="360">0.4137</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">1292.24</td>
      <td width="190">699.59</td>
      <td width="360">0.5414</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">25844.79</td>
      <td width="190">13991.75</td>
      <td width="360">0.5414</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">158.63</td>
      <td width="190">262.64</td>
      <td width="360">0.604</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">815.75</td>
      <td width="190">441.85</td>
      <td width="360">0.5416</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">16314.99</td>
      <td width="190">8836.92</td>
      <td width="360">0.5416</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">458.96</td>
      <td width="190">831.46</td>
      <td width="360">0.552</td>
    </tr>
  </tbody>
</table>

#### write_only

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">1</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">799.8</td>
      <td width="190">589.79</td>
      <td width="360">0.7374</td>
    </tr>
    <tr>
      <td width="150">1</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">4798.79</td>
      <td width="190">3538.73</td>
      <td width="360">0.7374</td>
    </tr>
    <tr>
      <td width="150">1</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">1.86</td>
      <td width="190">2.66</td>
      <td width="360">0.6992</td>
    </tr>
    <tr>
      <td width="150">32</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">5591.68</td>
      <td width="190">2497.24</td>
      <td width="360">0.4466</td>
    </tr>
    <tr>
      <td width="150">32</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">33550.1</td>
      <td width="190">14983.45</td>
      <td width="360">0.4466</td>
    </tr>
    <tr>
      <td width="150">32</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">11.04</td>
      <td width="190">24.38</td>
      <td width="360">0.4528</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">3652.28</td>
      <td width="190">1797.03</td>
      <td width="360">0.492</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">21913.66</td>
      <td width="190">10782.19</td>
      <td width="360">0.492</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">116.8</td>
      <td width="190">137.35</td>
      <td width="360">0.8504</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">2170.14</td>
      <td width="190">1108.33</td>
      <td width="360">0.5107</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">13020.84</td>
      <td width="190">6650.01</td>
      <td width="360">0.5107</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">P95 latency（ms）</td>
      <td width="190">越小越好</td>
      <td width="190">211.6</td>
      <td width="190">363.18</td>
      <td width="360">0.5826</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
