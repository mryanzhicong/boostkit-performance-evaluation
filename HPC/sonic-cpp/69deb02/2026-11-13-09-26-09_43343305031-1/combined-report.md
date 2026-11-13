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
      <td width="600">2026-11-13T01:16:37Z</td>
      <td width="600">2026-11-13T01:21:15Z</td>
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
      <td width="600">2026-11-13T01:15:26Z</td>
      <td width="600">2026-11-13T01:15:27Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">AMD EPYC 9654 96-Core Processor</td>
      <td width="600">Kunpeng 950 7592C To Be Filled By O.E.M. CPU @ 2.3GHz</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">384</td>
      <td width="600">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0</td>
      <td width="600">6.6.0-132.0.0.111.oe2403sp3.aarch64</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 175890 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 176814 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 176767 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 176516 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193481 MB<br>node 4 free: 176726 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193523 MB<br>node 5 free: 176907 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 76206 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 75636 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 378965 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 383171 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 379166 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 384201 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">15901.417383017106</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="280">9323.90881816708</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SonicOnDemand_NotFound</td>
      <td width="280">15780.113875634046</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_SonicDyn</td>
      <td width="280">254698.3271357093</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_SonicDyn</td>
      <td width="280">94366.47701949865</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_SonicDyn</td>
      <td width="280">579636.7489285218</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_SonicDyn</td>
      <td width="280">40719686.12790697</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_SonicDyn</td>
      <td width="280">485.56552921499906</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_SonicDyn</td>
      <td width="280">93726531.74358976</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_SonicDyn</td>
      <td width="280">783010.8014171172</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_SonicDyn</td>
      <td width="280">415844.17607446987</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_SonicDyn</td>
      <td width="280">579535.2338274004</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_SonicDyn</td>
      <td width="280">21904.598037170654</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_SonicDyn</td>
      <td width="280">2040248.7786407743</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_SonicDyn</td>
      <td width="280">134821.4846361534</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_SonicDyn</td>
      <td width="280">51622.004256491135</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_SonicDyn</td>
      <td width="280">275517.4736186661</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_SonicDyn</td>
      <td width="280">33230285.95200003</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_SonicDyn</td>
      <td width="280">349.382480986864</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_SonicDyn</td>
      <td width="280">83505512.44000001</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_SonicDyn</td>
      <td width="280">457711.43875326903</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_SonicDyn</td>
      <td width="280">480387.42174352123</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_SonicDyn</td>
      <td width="280">297895.03694440477</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_SonicDyn</td>
      <td width="280">11984.693147972925</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_SonicDyn</td>
      <td width="280">3716374.2753759488</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Stat_SonicDyn</td>
      <td width="280">44918.68383102465</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Find_SonicDyn</td>
      <td width="280">138608.24580046936</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Stat_SonicDyn</td>
      <td width="280">17162.72301549679</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Find_SonicDyn</td>
      <td width="280">51689.58186188866</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Stat_SonicDyn</td>
      <td width="280">135870.6686647971</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Find_SonicDyn</td>
      <td width="280">200597.09176537773</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Stat_SonicDyn</td>
      <td width="280">12395048.805309748</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Find_SonicDyn</td>
      <td width="280">22905567.737704907</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Stat_SonicDyn</td>
      <td width="280">88.08969348769782</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Find_SonicDyn</td>
      <td width="280">167.9052165975578</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Stat_SonicDyn</td>
      <td width="280">53223891.48101243</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Find_SonicDyn</td>
      <td width="280">666921878.4999961</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Stat_SonicDyn</td>
      <td width="280">100163.76952612631</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Find_SonicDyn</td>
      <td width="280">174660.43835787434</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Stat_SonicDyn</td>
      <td width="280">158052.61023297612</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Find_SonicDyn</td>
      <td width="280">225844.14016331878</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Stat_SonicDyn</td>
      <td width="280">57636.01935138572</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Find_SonicDyn</td>
      <td width="280">1014090.4047731587</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Stat_SonicDyn</td>
      <td width="280">4801.321402324736</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Find_SonicDyn</td>
      <td width="280">9126.695729660554</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Stat_SonicDyn</td>
      <td width="280">538793.7111139313</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Find_SonicDyn</td>
      <td width="280">486942.66063558124</td>
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
      <td width="280">31782.848221373762</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="280">16967.51897508322</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SonicOnDemand_NotFound</td>
      <td width="280">31446.391229630517</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_SonicDyn</td>
      <td width="280">388164.4226498891</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_SonicDyn</td>
      <td width="280">178759.74725087374</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_SonicDyn</td>
      <td width="280">1123131.7170366393</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_SonicDyn</td>
      <td width="280">58118064.925373115</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_SonicDyn</td>
      <td width="280">610.7506081666031</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_SonicDyn</td>
      <td width="280">121351398.12500006</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_SonicDyn</td>
      <td width="280">1531397.0573201897</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_SonicDyn</td>
      <td width="280">571212.9975362715</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_SonicDyn</td>
      <td width="280">1124858.0819716055</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_SonicDyn</td>
      <td width="280">41998.91208077172</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_SonicDyn</td>
      <td width="280">3743005.641711229</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_SonicDyn</td>
      <td width="280">167911.44664664642</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_SonicDyn</td>
      <td width="280">67563.12042323944</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_SonicDyn</td>
      <td width="280">408014.29029749165</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_SonicDyn</td>
      <td width="280">42654630.10309279</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_SonicDyn</td>
      <td width="280">455.2051289496073</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_SonicDyn</td>
      <td width="280">95149725.9090908</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_SonicDyn</td>
      <td width="280">628103.8848057606</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_SonicDyn</td>
      <td width="280">581556.4479354911</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_SonicDyn</td>
      <td width="280">587112.8154929575</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_SonicDyn</td>
      <td width="280">16266.767861015569</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_SonicDyn</td>
      <td width="280">4297888.741043998</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Stat_SonicDyn</td>
      <td width="280">50879.58413106173</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Find_SonicDyn</td>
      <td width="280">190328.7025187202</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Stat_SonicDyn</td>
      <td width="280">19123.3071163778</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Find_SonicDyn</td>
      <td width="280">71603.73871346172</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Stat_SonicDyn</td>
      <td width="280">147550.97698119804</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Find_SonicDyn</td>
      <td width="280">248201.2762062236</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Stat_SonicDyn</td>
      <td width="280">12351357.859237542</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Find_SonicDyn</td>
      <td width="280">28165485.033557065</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Stat_SonicDyn</td>
      <td width="280">92.16815142906285</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Find_SonicDyn</td>
      <td width="280">199.49383385863982</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Stat_SonicDyn</td>
      <td width="280">41546917.20000017</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Find_SonicDyn</td>
      <td width="280">985582092.4999961</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Stat_SonicDyn</td>
      <td width="280">101157.01311491178</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Find_SonicDyn</td>
      <td width="280">232606.69077361445</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Stat_SonicDyn</td>
      <td width="280">163252.4308277386</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Find_SonicDyn</td>
      <td width="280">266150.4377296328</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Stat_SonicDyn</td>
      <td width="280">62260.2048201707</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Find_SonicDyn</td>
      <td width="280">1419324.979702301</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Stat_SonicDyn</td>
      <td width="280">4301.538459175845</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Find_SonicDyn</td>
      <td width="280">13362.288038496781</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Stat_SonicDyn</td>
      <td width="280">470916.61842252954</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Find_SonicDyn</td>
      <td width="280">378052.72371464164</td>
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
      <td width="190">15901.417383017106</td>
      <td width="190">31782.848221373762</td>
      <td width="360">0.5003</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="190">越小越好</td>
      <td width="190">9323.90881816708</td>
      <td width="190">16967.51897508322</td>
      <td width="360">0.5495</td>
    </tr>
    <tr>
      <td width="450">twitter/SonicOnDemand_NotFound</td>
      <td width="190">越小越好</td>
      <td width="190">15780.113875634046</td>
      <td width="190">31446.391229630517</td>
      <td width="360">0.5018</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">254698.3271357093</td>
      <td width="190">388164.4226498891</td>
      <td width="360">0.6562</td>
    </tr>
    <tr>
      <td width="450">twitter/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">94366.47701949865</td>
      <td width="190">178759.74725087374</td>
      <td width="360">0.5279</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">579636.7489285218</td>
      <td width="190">1123131.7170366393</td>
      <td width="360">0.5161</td>
    </tr>
    <tr>
      <td width="450">fgo/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">40719686.12790697</td>
      <td width="190">58118064.925373115</td>
      <td width="360">0.7006</td>
    </tr>
    <tr>
      <td width="450">book/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">485.56552921499906</td>
      <td width="190">610.7506081666031</td>
      <td width="360">0.795</td>
    </tr>
    <tr>
      <td width="450">otfcc/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">93726531.74358976</td>
      <td width="190">121351398.12500006</td>
      <td width="360">0.7724</td>
    </tr>
    <tr>
      <td width="450">poet/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">783010.8014171172</td>
      <td width="190">1531397.0573201897</td>
      <td width="360">0.5113</td>
    </tr>
    <tr>
      <td width="450">lottie/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">415844.17607446987</td>
      <td width="190">571212.9975362715</td>
      <td width="360">0.728</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">579535.2338274004</td>
      <td width="190">1124858.0819716055</td>
      <td width="360">0.5152</td>
    </tr>
    <tr>
      <td width="450">github_events/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">21904.598037170654</td>
      <td width="190">41998.91208077172</td>
      <td width="360">0.5216</td>
    </tr>
    <tr>
      <td width="450">canada/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">2040248.7786407743</td>
      <td width="190">3743005.641711229</td>
      <td width="360">0.5451</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">134821.4846361534</td>
      <td width="190">167911.44664664642</td>
      <td width="360">0.8029</td>
    </tr>
    <tr>
      <td width="450">twitter/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">51622.004256491135</td>
      <td width="190">67563.12042323944</td>
      <td width="360">0.7641</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">275517.4736186661</td>
      <td width="190">408014.29029749165</td>
      <td width="360">0.6753</td>
    </tr>
    <tr>
      <td width="450">fgo/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">33230285.95200003</td>
      <td width="190">42654630.10309279</td>
      <td width="360">0.7791</td>
    </tr>
    <tr>
      <td width="450">book/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">349.382480986864</td>
      <td width="190">455.2051289496073</td>
      <td width="360">0.7675</td>
    </tr>
    <tr>
      <td width="450">otfcc/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">83505512.44000001</td>
      <td width="190">95149725.9090908</td>
      <td width="360">0.8776</td>
    </tr>
    <tr>
      <td width="450">poet/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">457711.43875326903</td>
      <td width="190">628103.8848057606</td>
      <td width="360">0.7287</td>
    </tr>
    <tr>
      <td width="450">lottie/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">480387.42174352123</td>
      <td width="190">581556.4479354911</td>
      <td width="360">0.826</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">297895.03694440477</td>
      <td width="190">587112.8154929575</td>
      <td width="360">0.5074</td>
    </tr>
    <tr>
      <td width="450">github_events/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">11984.693147972925</td>
      <td width="190">16266.767861015569</td>
      <td width="360">0.7368</td>
    </tr>
    <tr>
      <td width="450">canada/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">3716374.2753759488</td>
      <td width="190">4297888.741043998</td>
      <td width="360">0.8647</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">44918.68383102465</td>
      <td width="190">50879.58413106173</td>
      <td width="360">0.8828</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">138608.24580046936</td>
      <td width="190">190328.7025187202</td>
      <td width="360">0.7283</td>
    </tr>
    <tr>
      <td width="450">twitter/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">17162.72301549679</td>
      <td width="190">19123.3071163778</td>
      <td width="360">0.8975</td>
    </tr>
    <tr>
      <td width="450">twitter/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">51689.58186188866</td>
      <td width="190">71603.73871346172</td>
      <td width="360">0.7219</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">135870.6686647971</td>
      <td width="190">147550.97698119804</td>
      <td width="360">0.9208</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">200597.09176537773</td>
      <td width="190">248201.2762062236</td>
      <td width="360">0.8082</td>
    </tr>
    <tr>
      <td width="450">fgo/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">12395048.805309748</td>
      <td width="190">12351357.859237542</td>
      <td width="360">1.0035</td>
    </tr>
    <tr>
      <td width="450">fgo/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">22905567.737704907</td>
      <td width="190">28165485.033557065</td>
      <td width="360">0.8132</td>
    </tr>
    <tr>
      <td width="450">book/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">88.08969348769782</td>
      <td width="190">92.16815142906285</td>
      <td width="360">0.9557</td>
    </tr>
    <tr>
      <td width="450">book/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">167.9052165975578</td>
      <td width="190">199.49383385863982</td>
      <td width="360">0.8417</td>
    </tr>
    <tr>
      <td width="450">otfcc/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">53223891.48101243</td>
      <td width="190">41546917.20000017</td>
      <td width="360">1.2811</td>
    </tr>
    <tr>
      <td width="450">otfcc/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">666921878.4999961</td>
      <td width="190">985582092.4999961</td>
      <td width="360">0.6767</td>
    </tr>
    <tr>
      <td width="450">poet/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">100163.76952612631</td>
      <td width="190">101157.01311491178</td>
      <td width="360">0.9902</td>
    </tr>
    <tr>
      <td width="450">poet/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">174660.43835787434</td>
      <td width="190">232606.69077361445</td>
      <td width="360">0.7509</td>
    </tr>
    <tr>
      <td width="450">lottie/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">158052.61023297612</td>
      <td width="190">163252.4308277386</td>
      <td width="360">0.9681</td>
    </tr>
    <tr>
      <td width="450">lottie/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">225844.14016331878</td>
      <td width="190">266150.4377296328</td>
      <td width="360">0.8486</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">57636.01935138572</td>
      <td width="190">62260.2048201707</td>
      <td width="360">0.9257</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">1014090.4047731587</td>
      <td width="190">1419324.979702301</td>
      <td width="360">0.7145</td>
    </tr>
    <tr>
      <td width="450">github_events/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">4801.321402324736</td>
      <td width="190">4301.538459175845</td>
      <td width="360">1.1162</td>
    </tr>
    <tr>
      <td width="450">github_events/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">9126.695729660554</td>
      <td width="190">13362.288038496781</td>
      <td width="360">0.683</td>
    </tr>
    <tr>
      <td width="450">canada/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">538793.7111139313</td>
      <td width="190">470916.61842252954</td>
      <td width="360">1.1441</td>
    </tr>
    <tr>
      <td width="450">canada/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">486942.66063558124</td>
      <td width="190">378052.72371464164</td>
      <td width="360">1.288</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
