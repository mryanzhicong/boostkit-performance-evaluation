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
      <td width="180">Media</td>
      <td width="220">x264</td>
      <td width="160">0.165.3223</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Media</td>
      <td width="220">x264</td>
      <td width="160">0.165.3223</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### x264 0.165.3223

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
      <td width="600">0.165.3223</td>
      <td width="600">0.165.3223</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">0.165.3223</td>
      <td width="600">0.165.3223</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-10-27T09:11:00Z</td>
      <td width="600">2026-10-26T07:46:51Z</td>
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
      <td width="600">2026-10-27T09:10:18Z</td>
      <td width="600">2026-10-26T07:46:39Z</td>
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
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0-159.4.3.154.oe2403sp4.x86_64</td>
      <td width="600">6.6.0-159.4.14.168.oe2403sp4.aarch64</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="600">3.11.6</td>
      <td width="600">3.11.6</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="600">unknown</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 574945 MB<br>node 0 free: 33643 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 580594 MB<br>node 1 free: 326695 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 580594 MB<br>node 2 free: 306505 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 482782 MB<br>node 3 free: 315691 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">x264</td>
      <td width="880">0.165.3223</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### x264 0.165.3223

##### 单路

###### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="500">2000k/total_fps</td>
      <td width="280">23.2</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">19.45</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">17.14</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">15.57</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### BQTerrace_1920x1080_60-dianbo

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
      <td width="500">2000k/total_fps</td>
      <td width="280">30.16</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">26.95</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">24.77</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">22.84</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### messi_1920x1080_25_1000

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
      <td width="500">2000k/total_fps</td>
      <td width="280">28.67</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">24.13</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">21.82</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">20.26</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 整机

###### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="500">2000k/total_fps</td>
      <td width="280">834.39</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">702.99</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">619.54</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">562.3</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### BQTerrace_1920x1080_60-dianbo

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
      <td width="500">2000k/total_fps</td>
      <td width="280">1122.49</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">999.14</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">908.66</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">832.77</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### messi_1920x1080_25_1000

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
      <td width="500">2000k/total_fps</td>
      <td width="280">1034.28</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">873.75</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">789.87</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">734.15</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### x264 0.165.3223

##### 单路

###### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="500">2000k/total_fps</td>
      <td width="280">17.97</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">14.99</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">13.2</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">11.97</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### BQTerrace_1920x1080_60-dianbo

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
      <td width="500">2000k/total_fps</td>
      <td width="280">23.42</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">20.94</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">19.0</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">17.28</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### messi_1920x1080_25_1000

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
      <td width="500">2000k/total_fps</td>
      <td width="280">22.27</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">18.59</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">16.77</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">15.57</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 整机

###### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="500">2000k/total_fps</td>
      <td width="280">692.23</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">578.01</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">509.62</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">464.25</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### BQTerrace_1920x1080_60-dianbo

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
      <td width="500">2000k/total_fps</td>
      <td width="280">943.43</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">832.37</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">753.13</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">687.73</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

###### messi_1920x1080_25_1000

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
      <td width="500">2000k/total_fps</td>
      <td width="280">867.01</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">724.58</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">654.8</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">609.17</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### x264 0.165.3223

#### 单路

##### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">23.2</td>
      <td width="200">17.97</td>
      <td width="380">0.7746</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">19.45</td>
      <td width="200">14.99</td>
      <td width="380">0.7707</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">17.14</td>
      <td width="200">13.2</td>
      <td width="380">0.7701</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">15.57</td>
      <td width="200">11.97</td>
      <td width="380">0.7688</td>
    </tr>
  </tbody>
</table>

##### BQTerrace_1920x1080_60-dianbo

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">30.16</td>
      <td width="200">23.42</td>
      <td width="380">0.7765</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">26.95</td>
      <td width="200">20.94</td>
      <td width="380">0.777</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">24.77</td>
      <td width="200">19.0</td>
      <td width="380">0.7671</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">22.84</td>
      <td width="200">17.28</td>
      <td width="380">0.7566</td>
    </tr>
  </tbody>
</table>

##### messi_1920x1080_25_1000

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">28.67</td>
      <td width="200">22.27</td>
      <td width="380">0.7768</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">24.13</td>
      <td width="200">18.59</td>
      <td width="380">0.7704</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">21.82</td>
      <td width="200">16.77</td>
      <td width="380">0.7686</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">20.26</td>
      <td width="200">15.57</td>
      <td width="380">0.7685</td>
    </tr>
  </tbody>
</table>

#### 整机

##### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">834.39</td>
      <td width="200">692.23</td>
      <td width="380">0.8296</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">702.99</td>
      <td width="200">578.01</td>
      <td width="380">0.8222</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">619.54</td>
      <td width="200">509.62</td>
      <td width="380">0.8226</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">562.3</td>
      <td width="200">464.25</td>
      <td width="380">0.8256</td>
    </tr>
  </tbody>
</table>

##### BQTerrace_1920x1080_60-dianbo

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">1122.49</td>
      <td width="200">943.43</td>
      <td width="380">0.8405</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">999.14</td>
      <td width="200">832.37</td>
      <td width="380">0.8331</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">908.66</td>
      <td width="200">753.13</td>
      <td width="380">0.8288</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">832.77</td>
      <td width="200">687.73</td>
      <td width="380">0.8258</td>
    </tr>
  </tbody>
</table>

##### messi_1920x1080_25_1000

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
      <td width="400">2000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">1034.28</td>
      <td width="200">867.01</td>
      <td width="380">0.8383</td>
    </tr>
    <tr>
      <td width="400">4000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">873.75</td>
      <td width="200">724.58</td>
      <td width="380">0.8293</td>
    </tr>
    <tr>
      <td width="400">6000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">789.87</td>
      <td width="200">654.8</td>
      <td width="380">0.829</td>
    </tr>
    <tr>
      <td width="400">8000k/total_fps</td>
      <td width="200">越大越好</td>
      <td width="200">734.15</td>
      <td width="200">609.17</td>
      <td width="380">0.8298</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
