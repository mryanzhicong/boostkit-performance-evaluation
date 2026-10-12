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
      <td width="220">sonic-cpp</td>
      <td width="160">69deb02</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">sonic-cpp</td>
      <td width="160">69deb02</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### sonic-cpp 69deb02

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
      <td width="600">69deb02</td>
      <td width="600">69deb02</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">69deb02</td>
      <td width="600">69deb02</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-10-12T01:43:41Z</td>
      <td width="600">2026-10-12T01:44:04Z</td>
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
      <td width="600">2026-10-12T01:41:44Z</td>
      <td width="600">2026-10-12T01:42:05Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 574945 MB<br>node 0 free: 343576 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 580594 MB<br>node 1 free: 419333 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 580594 MB<br>node 2 free: 431863 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 482782 MB<br>node 3 free: 330070 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">bench</td>
      <td width="880">69deb02</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### sonic-cpp 69deb02

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
      <td width="500">twitter/SonicOnDemand_Normal</td>
      <td width="280">15940.121738701999</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="280">9349.159206210097</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SonicOnDemand_NotFound</td>
      <td width="280">15804.047497863592</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_SonicDyn</td>
      <td width="280">21738.11659422806</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_SonicDyn</td>
      <td width="280">943044.1263054189</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_SonicDyn</td>
      <td width="280">57036067.815384574</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_SonicDyn</td>
      <td width="280">724.0258825585522</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_SonicDyn</td>
      <td width="280">794815.6236105792</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_SonicDyn</td>
      <td width="280">585648.4945116028</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_SonicDyn</td>
      <td width="280">747105.0490229698</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_SonicDyn</td>
      <td width="280">122618.1436841606</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_SonicDyn</td>
      <td width="280">3302336.3899999936</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_SonicDyn</td>
      <td width="280">346950.06498088787</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_SonicDyn</td>
      <td width="280">120554729.7499998</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_SonicDyn</td>
      <td width="280">14792.329432622764</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_SonicDyn</td>
      <td width="280">469112.3546705269</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_SonicDyn</td>
      <td width="280">44277014.34831469</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_SonicDyn</td>
      <td width="280">340.9384148789565</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_SonicDyn</td>
      <td width="280">268587.2380222305</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_SonicDyn</td>
      <td width="280">452731.41419035365</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_SonicDyn</td>
      <td width="280">288392.61308127583</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_SonicDyn</td>
      <td width="280">46634.1987382756</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_SonicDyn</td>
      <td width="280">3744395.1531611695</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_SonicDyn</td>
      <td width="280">128319.2609908437</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_SonicDyn</td>
      <td width="280">115375918.07843164</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Stat_SonicDyn</td>
      <td width="280">5707.326373203687</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Find_SonicDyn</td>
      <td width="280">15976.071709185388</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Stat_SonicDyn</td>
      <td width="280">105647.02829770715</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Find_SonicDyn</td>
      <td width="280">176445.10174321104</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Stat_SonicDyn</td>
      <td width="280">13291567.097178698</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Find_SonicDyn</td>
      <td width="280">25844566.87654324</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Stat_SonicDyn</td>
      <td width="280">91.2901770782347</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Find_SonicDyn</td>
      <td width="280">166.2341186612599</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Stat_SonicDyn</td>
      <td width="280">134882.56321986252</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Find_SonicDyn</td>
      <td width="280">205045.45552254954</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Stat_SonicDyn</td>
      <td width="280">185602.62700653324</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Find_SonicDyn</td>
      <td width="280">225382.6148571438</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Stat_SonicDyn</td>
      <td width="280">57771.69277638713</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Find_SonicDyn</td>
      <td width="280">1157503.7154650532</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Stat_SonicDyn</td>
      <td width="280">17098.948472497603</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Find_SonicDyn</td>
      <td width="280">63815.843310980694</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Stat_SonicDyn</td>
      <td width="280">579057.9866427983</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Find_SonicDyn</td>
      <td width="280">490120.64365281997</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Stat_SonicDyn</td>
      <td width="280">45178.361278597506</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Find_SonicDyn</td>
      <td width="280">172225.6732076773</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Stat_SonicDyn</td>
      <td width="280">81433522.48529404</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Find_SonicDyn</td>
      <td width="280">713817606.8333355</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### sonic-cpp 69deb02

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
      <td width="500">twitter/SonicOnDemand_Normal</td>
      <td width="280">33436.56232197158</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="280">16965.825563325565</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SonicOnDemand_NotFound</td>
      <td width="280">30872.682240587692</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_SonicDyn</td>
      <td width="280">42133.758723828476</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_SonicDyn</td>
      <td width="280">1516241.0838150291</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_SonicDyn</td>
      <td width="280">58382359.6491228</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_SonicDyn</td>
      <td width="280">623.873982752446</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_SonicDyn</td>
      <td width="280">1119940.922213311</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_SonicDyn</td>
      <td width="280">582136.9522354896</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_SonicDyn</td>
      <td width="280">1136412.4363143647</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_SonicDyn</td>
      <td width="280">178619.3744152417</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_SonicDyn</td>
      <td width="280">3758104.4186046496</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_SonicDyn</td>
      <td width="280">386751.39747255825</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_SonicDyn</td>
      <td width="280">121548882.49999996</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_SonicDyn</td>
      <td width="280">16273.436249883725</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_SonicDyn</td>
      <td width="280">539961.3305880836</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_SonicDyn</td>
      <td width="280">42565336.28865978</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_SonicDyn</td>
      <td width="280">443.57585355525805</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_SonicDyn</td>
      <td width="280">407062.9407198994</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_SonicDyn</td>
      <td width="280">575832.7801457443</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_SonicDyn</td>
      <td width="280">476769.5697820387</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_SonicDyn</td>
      <td width="280">68187.82915424317</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_SonicDyn</td>
      <td width="280">4307120.471311483</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_SonicDyn</td>
      <td width="280">163744.4995125756</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_SonicDyn</td>
      <td width="280">95189258.18181823</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Stat_SonicDyn</td>
      <td width="280">4336.0590808881025</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Find_SonicDyn</td>
      <td width="280">13290.025768218919</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Stat_SonicDyn</td>
      <td width="280">101094.9458587998</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Find_SonicDyn</td>
      <td width="280">228175.31861028835</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Stat_SonicDyn</td>
      <td width="280">12337215.250737434</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Find_SonicDyn</td>
      <td width="280">28127038.25503356</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Stat_SonicDyn</td>
      <td width="280">92.32181226358736</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Find_SonicDyn</td>
      <td width="280">199.6368351271745</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Stat_SonicDyn</td>
      <td width="280">148466.85186493403</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Find_SonicDyn</td>
      <td width="280">248059.2049417742</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Stat_SonicDyn</td>
      <td width="280">162377.64541863484</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Find_SonicDyn</td>
      <td width="280">264901.49337539583</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Stat_SonicDyn</td>
      <td width="280">62629.91474901632</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Find_SonicDyn</td>
      <td width="280">1470179.9754987739</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Stat_SonicDyn</td>
      <td width="280">19147.079767405783</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Find_SonicDyn</td>
      <td width="280">71754.06026461844</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Stat_SonicDyn</td>
      <td width="280">470242.56490599766</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Find_SonicDyn</td>
      <td width="280">374600.6228312137</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Stat_SonicDyn</td>
      <td width="280">51934.41820333315</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Find_SonicDyn</td>
      <td width="280">189395.25417623538</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Stat_SonicDyn</td>
      <td width="280">41815914.24242417</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Find_SonicDyn</td>
      <td width="280">990811887.5000014</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### sonic-cpp 69deb02

<table width="1380">
  <thead>
    <tr>
      <th width="450">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="450">twitter/SonicOnDemand_Normal</td>
      <td width="190">越小越好</td>
      <td width="190">15940.121738701999</td>
      <td width="190">33436.56232197158</td>
      <td width="360">0.4767</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="190">越小越好</td>
      <td width="190">9349.159206210097</td>
      <td width="190">16965.825563325565</td>
      <td width="360">0.5511</td>
    </tr>
    <tr>
      <td width="450">twitter/SonicOnDemand_NotFound</td>
      <td width="190">越小越好</td>
      <td width="190">15804.047497863592</td>
      <td width="190">30872.682240587692</td>
      <td width="360">0.5119</td>
    </tr>
    <tr>
      <td width="450">github_events/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">21738.11659422806</td>
      <td width="190">42133.758723828476</td>
      <td width="360">0.5159</td>
    </tr>
    <tr>
      <td width="450">poet/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">943044.1263054189</td>
      <td width="190">1516241.0838150291</td>
      <td width="360">0.622</td>
    </tr>
    <tr>
      <td width="450">fgo/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">57036067.815384574</td>
      <td width="190">58382359.6491228</td>
      <td width="360">0.9769</td>
    </tr>
    <tr>
      <td width="450">book/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">724.0258825585522</td>
      <td width="190">623.873982752446</td>
      <td width="360">1.1605</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">794815.6236105792</td>
      <td width="190">1119940.922213311</td>
      <td width="360">0.7097</td>
    </tr>
    <tr>
      <td width="450">lottie/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">585648.4945116028</td>
      <td width="190">582136.9522354896</td>
      <td width="360">1.006</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">747105.0490229698</td>
      <td width="190">1136412.4363143647</td>
      <td width="360">0.6574</td>
    </tr>
    <tr>
      <td width="450">twitter/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">122618.1436841606</td>
      <td width="190">178619.3744152417</td>
      <td width="360">0.6865</td>
    </tr>
    <tr>
      <td width="450">canada/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">3302336.3899999936</td>
      <td width="190">3758104.4186046496</td>
      <td width="360">0.8787</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">346950.06498088787</td>
      <td width="190">386751.39747255825</td>
      <td width="360">0.8971</td>
    </tr>
    <tr>
      <td width="450">otfcc/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">120554729.7499998</td>
      <td width="190">121548882.49999996</td>
      <td width="360">0.9918</td>
    </tr>
    <tr>
      <td width="450">github_events/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">14792.329432622764</td>
      <td width="190">16273.436249883725</td>
      <td width="360">0.909</td>
    </tr>
    <tr>
      <td width="450">poet/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">469112.3546705269</td>
      <td width="190">539961.3305880836</td>
      <td width="360">0.8688</td>
    </tr>
    <tr>
      <td width="450">fgo/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">44277014.34831469</td>
      <td width="190">42565336.28865978</td>
      <td width="360">1.0402</td>
    </tr>
    <tr>
      <td width="450">book/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">340.9384148789565</td>
      <td width="190">443.57585355525805</td>
      <td width="360">0.7686</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">268587.2380222305</td>
      <td width="190">407062.9407198994</td>
      <td width="360">0.6598</td>
    </tr>
    <tr>
      <td width="450">lottie/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">452731.41419035365</td>
      <td width="190">575832.7801457443</td>
      <td width="360">0.7862</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">288392.61308127583</td>
      <td width="190">476769.5697820387</td>
      <td width="360">0.6049</td>
    </tr>
    <tr>
      <td width="450">twitter/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">46634.1987382756</td>
      <td width="190">68187.82915424317</td>
      <td width="360">0.6839</td>
    </tr>
    <tr>
      <td width="450">canada/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">3744395.1531611695</td>
      <td width="190">4307120.471311483</td>
      <td width="360">0.8693</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">128319.2609908437</td>
      <td width="190">163744.4995125756</td>
      <td width="360">0.7837</td>
    </tr>
    <tr>
      <td width="450">otfcc/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">115375918.07843164</td>
      <td width="190">95189258.18181823</td>
      <td width="360">1.2121</td>
    </tr>
    <tr>
      <td width="450">github_events/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">5707.326373203687</td>
      <td width="190">4336.0590808881025</td>
      <td width="360">1.3162</td>
    </tr>
    <tr>
      <td width="450">github_events/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">15976.071709185388</td>
      <td width="190">13290.025768218919</td>
      <td width="360">1.2021</td>
    </tr>
    <tr>
      <td width="450">poet/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">105647.02829770715</td>
      <td width="190">101094.9458587998</td>
      <td width="360">1.045</td>
    </tr>
    <tr>
      <td width="450">poet/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">176445.10174321104</td>
      <td width="190">228175.31861028835</td>
      <td width="360">0.7733</td>
    </tr>
    <tr>
      <td width="450">fgo/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">13291567.097178698</td>
      <td width="190">12337215.250737434</td>
      <td width="360">1.0774</td>
    </tr>
    <tr>
      <td width="450">fgo/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">25844566.87654324</td>
      <td width="190">28127038.25503356</td>
      <td width="360">0.9189</td>
    </tr>
    <tr>
      <td width="450">book/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">91.2901770782347</td>
      <td width="190">92.32181226358736</td>
      <td width="360">0.9888</td>
    </tr>
    <tr>
      <td width="450">book/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">166.2341186612599</td>
      <td width="190">199.6368351271745</td>
      <td width="360">0.8327</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">134882.56321986252</td>
      <td width="190">148466.85186493403</td>
      <td width="360">0.9085</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">205045.45552254954</td>
      <td width="190">248059.2049417742</td>
      <td width="360">0.8266</td>
    </tr>
    <tr>
      <td width="450">lottie/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">185602.62700653324</td>
      <td width="190">162377.64541863484</td>
      <td width="360">1.143</td>
    </tr>
    <tr>
      <td width="450">lottie/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">225382.6148571438</td>
      <td width="190">264901.49337539583</td>
      <td width="360">0.8508</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">57771.69277638713</td>
      <td width="190">62629.91474901632</td>
      <td width="360">0.9224</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">1157503.7154650532</td>
      <td width="190">1470179.9754987739</td>
      <td width="360">0.7873</td>
    </tr>
    <tr>
      <td width="450">twitter/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">17098.948472497603</td>
      <td width="190">19147.079767405783</td>
      <td width="360">0.893</td>
    </tr>
    <tr>
      <td width="450">twitter/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">63815.843310980694</td>
      <td width="190">71754.06026461844</td>
      <td width="360">0.8894</td>
    </tr>
    <tr>
      <td width="450">canada/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">579057.9866427983</td>
      <td width="190">470242.56490599766</td>
      <td width="360">1.2314</td>
    </tr>
    <tr>
      <td width="450">canada/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">490120.64365281997</td>
      <td width="190">374600.6228312137</td>
      <td width="360">1.3084</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">45178.361278597506</td>
      <td width="190">51934.41820333315</td>
      <td width="360">0.8699</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">172225.6732076773</td>
      <td width="190">189395.25417623538</td>
      <td width="360">0.9093</td>
    </tr>
    <tr>
      <td width="450">otfcc/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">81433522.48529404</td>
      <td width="190">41815914.24242417</td>
      <td width="360">1.9474</td>
    </tr>
    <tr>
      <td width="450">otfcc/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">713817606.8333355</td>
      <td width="190">990811887.5000014</td>
      <td width="360">0.7204</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
