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
      <td width="160">1.0.2</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">sonic-cpp</td>
      <td width="160">1.0.2</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### sonic-cpp 1.0.2

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
      <td width="600">1.0.2</td>
      <td width="600">1.0.2</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.0.2</td>
      <td width="600">1.0.2</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-09-08T03:02:05Z</td>
      <td width="600">2026-09-08T03:03:36Z</td>
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
      <td width="600">2026-09-08T03:00:40Z</td>
      <td width="600">2026-09-08T03:01:20Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">AMD EPYC 9654 96-Core Processor</td>
      <td width="600">unknown</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">384</td>
      <td width="600">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
      <td width="600">openEuler 24.03 (LTS-SP2)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0-132.0.0.111.oe2403sp3.x86_64</td>
      <td width="600">6.6.0-cc</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 0 size: 192588 MB<br>node 0 free: 189030 MB<br>node 1 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 1 size: 193469 MB<br>node 1 free: 191504 MB<br>node 2 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 2 size: 193511 MB<br>node 2 free: 191155 MB<br>node 3 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 193443 MB<br>node 3 free: 189839 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  32  32 <br>  1:  12  10  32  32 <br>  2:  32  32  10  12 <br>  3:  32  32  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 171090 MB<br>node 0 free: 150620 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 193522 MB<br>node 1 free: 157222 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 193522 MB<br>node 2 free: 181702 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 192478 MB<br>node 3 free: 183318 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### sonic-cpp 1.0.2

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
      <td width="280">15918.171873934876</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/RapidjsonSaxOnDemand_Normal</td>
      <td width="280">311454.5983971502</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SIMDjsonOnDemand_Normal</td>
      <td width="280">51717.99216903078</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="280">9314.145271260022</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/RapidjsonSaxOnDemand_Fronter</td>
      <td width="280">94176.90974192668</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/SIMDjsonOnDemand_Fronter</td>
      <td width="280">220182.07041810764</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SonicOnDemand_NotFound</td>
      <td width="280">15800.82774655195</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/RapidjsonSaxOnDemand_NotFound</td>
      <td width="280">314191.9201077203</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SIMDjsonOnDemand_NotFound</td>
      <td width="280">51734.75221526697</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_SonicDyn</td>
      <td width="280">47035392.99999956</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_Rapidjson</td>
      <td width="280">98825828.16666624</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_YYjson</td>
      <td width="280">107917212.1428574</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_SIMDjson</td>
      <td width="280">54603546.53846184</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_JsonCpp</td>
      <td width="280">5639604084.000012</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_SonicDyn</td>
      <td width="280">263998.89958475134</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_Rapidjson</td>
      <td width="280">897982.1108280219</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_YYjson</td>
      <td width="280">998293.4428571509</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_SIMDjson</td>
      <td width="280">355217.2672764217</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_JsonCpp</td>
      <td width="280">25326881.035713967</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_SonicDyn</td>
      <td width="280">2107523.048047975</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_Rapidjson</td>
      <td width="280">3052679.810344815</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_YYjson</td>
      <td width="280">6696767.586538281</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_SIMDjson</td>
      <td width="280">2117603.8121212465</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_JsonCpp</td>
      <td width="280">313125279.00000477</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_SonicDyn</td>
      <td width="280">427675.40537239675</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_Rapidjson</td>
      <td width="280">837212.9294947291</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_YYjson</td>
      <td width="280">870724.9067164222</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_SIMDjson</td>
      <td width="280">342421.51024390815</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_JsonCpp</td>
      <td width="280">73764049.49999937</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_SonicDyn</td>
      <td width="280">458.8251189821711</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_Rapidjson</td>
      <td width="280">895.3204042698962</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_YYjson</td>
      <td width="280">872.3899706992482</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_SIMDjson</td>
      <td width="280">448.02596752086646</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_JsonCpp</td>
      <td width="280">69717.58014127826</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_SonicDyn</td>
      <td width="280">590801.37298214</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_Rapidjson</td>
      <td width="280">4390968.905660352</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_YYjson</td>
      <td width="280">4189931.982035952</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_SIMDjson</td>
      <td width="280">754391.6239130634</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_JsonCpp</td>
      <td width="280">49647157.214284986</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_SonicDyn</td>
      <td width="280">96312.36612548042</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_Rapidjson</td>
      <td width="280">347635.78196233616</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_YYjson</td>
      <td width="280">311797.24899777817</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_SIMDjson</td>
      <td width="280">77803.19340878625</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_JsonCpp</td>
      <td width="280">9513709.054054111</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_SonicDyn</td>
      <td width="280">22638.657508565644</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_Rapidjson</td>
      <td width="280">90822.5122775136</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_YYjson</td>
      <td width="280">81681.41297246664</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_SIMDjson</td>
      <td width="280">16905.396052281358</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_JsonCpp</td>
      <td width="280">2198104.6489029042</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_SonicDyn</td>
      <td width="280">800215.3729977165</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_Rapidjson</td>
      <td width="280">4772373.183673417</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_YYjson</td>
      <td width="280">2669921.261538487</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_SIMDjson</td>
      <td width="280">941980.3243606815</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_JsonCpp</td>
      <td width="280">75084112.10000077</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_SonicDyn</td>
      <td width="280">106835167.62500033</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_Rapidjson</td>
      <td width="280">168794221.24999622</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_YYjson</td>
      <td width="280">162311981.4000006</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_SIMDjson</td>
      <td width="280">96525778.37500331</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_JsonCpp</td>
      <td width="280">12331173924.999973</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_SonicDyn</td>
      <td width="280">598944.9341317166</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_Rapidjson</td>
      <td width="280">1582714.5146726188</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_YYjson</td>
      <td width="280">2024087.3468209181</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_SIMDjson</td>
      <td width="280">578379.3399504168</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_JsonCpp</td>
      <td width="280">61958427.076923236</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_SonicDyn</td>
      <td width="280">26195530.333333645</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_Rapidjson</td>
      <td width="280">58848495.000001825</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_YYjson</td>
      <td width="280">64029624.09090791</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_SIMDjson</td>
      <td width="280">74691022.77778146</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_JsonCpp</td>
      <td width="280">2259704013.0000324</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_SonicDyn</td>
      <td width="280">135597.33410852196</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_Rapidjson</td>
      <td width="280">515058.87426473276</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_YYjson</td>
      <td width="280">421152.03309267724</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_SIMDjson</td>
      <td width="280">300181.3522336317</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_JsonCpp</td>
      <td width="280">11783991.79660974</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_SonicDyn</td>
      <td width="280">3745239.604277741</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_Rapidjson</td>
      <td width="280">7350679.610526879</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_YYjson</td>
      <td width="280">7177839.84536015</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_SIMDjson</td>
      <td width="280">3431196.0245099277</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_JsonCpp</td>
      <td width="280">117897388.83334167</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_SonicDyn</td>
      <td width="280">462534.33267196297</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_Rapidjson</td>
      <td width="280">727438.3242392556</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_YYjson</td>
      <td width="280">911647.3459530079</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_SIMDjson</td>
      <td width="280">633100.4341636095</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_JsonCpp</td>
      <td width="280">27855494.83999603</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_SonicDyn</td>
      <td width="280">336.94520314225053</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_Rapidjson</td>
      <td width="280">780.0476753707838</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_YYjson</td>
      <td width="280">697.7851880107</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_SIMDjson</td>
      <td width="280">490.5488096280727</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_JsonCpp</td>
      <td width="280">34170.36792545122</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_SonicDyn</td>
      <td width="280">417998.4814814689</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_Rapidjson</td>
      <td width="280">2462090.545774617</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_YYjson</td>
      <td width="280">2162538.7901234077</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_SIMDjson</td>
      <td width="280">2878686.5925924685</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_JsonCpp</td>
      <td width="280">34773986.64999782</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_SonicDyn</td>
      <td width="280">50300.808165911105</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_Rapidjson</td>
      <td width="280">215239.54083204726</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_YYjson</td>
      <td width="280">146135.34983291646</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_SIMDjson</td>
      <td width="280">131950.5920706691</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_JsonCpp</td>
      <td width="280">4932958.683098886</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_SonicDyn</td>
      <td width="280">12131.83548297689</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_Rapidjson</td>
      <td width="280">48905.99022346724</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_YYjson</td>
      <td width="280">29609.4396971112</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_SIMDjson</td>
      <td width="280">32224.588448317012</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_JsonCpp</td>
      <td width="280">1033226.3372607144</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_SonicDyn</td>
      <td width="280">481576.0413223747</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_Rapidjson</td>
      <td width="280">2340429.5719063515</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_YYjson</td>
      <td width="280">1053561.7590361987</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_SIMDjson</td>
      <td width="280">1260887.1384891784</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_JsonCpp</td>
      <td width="280">60708225.63636242</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_SonicDyn</td>
      <td width="280">72164810.09999143</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_Rapidjson</td>
      <td width="280">134485615.00001687</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_YYjson</td>
      <td width="280">136069856.79998615</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_SIMDjson</td>
      <td width="280">120591251.49998334</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_JsonCpp</td>
      <td width="280">5104447955.999945</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_SonicDyn</td>
      <td width="280">267878.47216889187</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_Rapidjson</td>
      <td width="280">575176.9111842907</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_YYjson</td>
      <td width="280">634335.401996346</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_SIMDjson</td>
      <td width="280">513012.7960954181</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_JsonCpp</td>
      <td width="280">23971399.68965395</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Stat_SonicDyn</td>
      <td width="280">12024492.000000464</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Find_SonicDyn</td>
      <td width="280">22934165.290320702</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Stat_Rapidjson</td>
      <td width="280">12900397.351851704</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Find_Rapidjson</td>
      <td width="280">23585352.699997958</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Stat_SonicDyn</td>
      <td width="280">44695.59367226284</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Find_SonicDyn</td>
      <td width="280">138237.1797708558</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Stat_Rapidjson</td>
      <td width="280">51660.1016986684</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Find_Rapidjson</td>
      <td width="280">164740.5168671758</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Stat_SonicDyn</td>
      <td width="280">582298.0124481863</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Find_SonicDyn</td>
      <td width="280">524244.7219731535</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Stat_Rapidjson</td>
      <td width="280">530746.0832072524</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Find_Rapidjson</td>
      <td width="280">406297.8316889155</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Stat_SonicDyn</td>
      <td width="280">167812.6848807679</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Find_SonicDyn</td>
      <td width="280">225724.94390714998</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Stat_Rapidjson</td>
      <td width="280">158725.15150829055</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Find_Rapidjson</td>
      <td width="280">189413.86693659812</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Stat_SonicDyn</td>
      <td width="280">110.60694770599052</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Find_SonicDyn</td>
      <td width="280">170.3306811709838</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Stat_Rapidjson</td>
      <td width="280">127.16137829506108</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Find_Rapidjson</td>
      <td width="280">128.32704737021564</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Stat_SonicDyn</td>
      <td width="280">59544.45712097897</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Find_SonicDyn</td>
      <td width="280">1048916.1019490191</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Stat_Rapidjson</td>
      <td width="280">83575.9918834988</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Find_Rapidjson</td>
      <td width="280">1505304.1376343386</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Stat_SonicDyn</td>
      <td width="280">17094.04005076533</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Find_SonicDyn</td>
      <td width="280">51502.98424965135</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Stat_Rapidjson</td>
      <td width="280">19810.914017029318</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Find_Rapidjson</td>
      <td width="280">56320.972730142894</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Stat_SonicDyn</td>
      <td width="280">4665.573981714662</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Find_SonicDyn</td>
      <td width="280">8974.227467975381</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Stat_Rapidjson</td>
      <td width="280">4428.687271689335</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Find_Rapidjson</td>
      <td width="280">10620.076590318156</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Stat_SonicDyn</td>
      <td width="280">114486.2042518328</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Find_SonicDyn</td>
      <td width="280">175406.1629945116</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Stat_Rapidjson</td>
      <td width="280">148531.7015495806</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Find_Rapidjson</td>
      <td width="280">163527.89556074992</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Stat_SonicDyn</td>
      <td width="280">54296774.53846055</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Find_SonicDyn</td>
      <td width="280">672383498.9999205</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Stat_Rapidjson</td>
      <td width="280">51744262.23077087</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Find_Rapidjson</td>
      <td width="280">1080693231.0000548</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Stat_SonicDyn</td>
      <td width="280">127352.19616704396</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Find_SonicDyn</td>
      <td width="280">201308.80063202378</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Stat_Rapidjson</td>
      <td width="280">132188.12592033588</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Find_Rapidjson</td>
      <td width="280">199681.95782274607</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### sonic-cpp 1.0.2

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
      <td width="280">45425.747215747215</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/RapidjsonSaxOnDemand_Normal</td>
      <td width="280">774542.6077348066</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SIMDjsonOnDemand_Normal</td>
      <td width="280">113227.90485500148</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="280">22118.209897988156</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/RapidjsonSaxOnDemand_Fronter</td>
      <td width="280">173474.2913096695</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/SIMDjsonOnDemand_Fronter</td>
      <td width="280">513190.5081001469</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SonicOnDemand_NotFound</td>
      <td width="280">45094.24991906752</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/RapidjsonSaxOnDemand_NotFound</td>
      <td width="280">807408.0023364498</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SIMDjsonOnDemand_NotFound</td>
      <td width="280">113190.36195422846</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_SonicDyn</td>
      <td width="280">82070608.57142982</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_Rapidjson</td>
      <td width="280">209549890.00000054</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_YYjson</td>
      <td width="280">269538413.3333316</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_SIMDjson</td>
      <td width="280">84688892.49999912</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_JsonCpp</td>
      <td width="280">5759468720.000001</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_SonicDyn</td>
      <td width="280">452619.30609598104</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_Rapidjson</td>
      <td width="280">1964570.198300299</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_YYjson</td>
      <td width="280">2485254.7330960934</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_SIMDjson</td>
      <td width="280">866732.853598004</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_JsonCpp</td>
      <td width="280">27728449.19999955</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_SonicDyn</td>
      <td width="280">5218214.887217794</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_Rapidjson</td>
      <td width="280">5288238.333333318</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_YYjson</td>
      <td width="280">14729731.914893035</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_SIMDjson</td>
      <td width="280">3857675.0561798634</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_JsonCpp</td>
      <td width="280">315313044.9999821</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_SonicDyn</td>
      <td width="280">754774.8966267799</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_Rapidjson</td>
      <td width="280">1285164.140480583</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_YYjson</td>
      <td width="280">2408828.5172414826</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_SIMDjson</td>
      <td width="280">715177.9568788019</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_JsonCpp</td>
      <td width="280">70911811.99999711</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_SonicDyn</td>
      <td width="280">831.332824206278</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_Rapidjson</td>
      <td width="280">1539.5307199849833</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_YYjson</td>
      <td width="280">2172.779949272683</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_SIMDjson</td>
      <td width="280">853.818863599036</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_JsonCpp</td>
      <td width="280">72117.83008155624</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_SonicDyn</td>
      <td width="280">1304196.3157894628</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_Rapidjson</td>
      <td width="280">11286685.000000363</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_YYjson</td>
      <td width="280">9621623.611111198</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_SIMDjson</td>
      <td width="280">1688376.992665087</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_JsonCpp</td>
      <td width="280">57052403.84615378</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_SonicDyn</td>
      <td width="280">205200.00586682808</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_Rapidjson</td>
      <td width="280">807426.5272938188</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_YYjson</td>
      <td width="280">981790.4781996943</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_SIMDjson</td>
      <td width="280">170837.88856305162</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_JsonCpp</td>
      <td width="280">10457127.205881989</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_SonicDyn</td>
      <td width="280">48000.95073346465</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_Rapidjson</td>
      <td width="280">217219.25340767793</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_YYjson</td>
      <td width="280">218897.66990290387</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_SIMDjson</td>
      <td width="280">37085.02472220633</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_JsonCpp</td>
      <td width="280">2360472.7609426538</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_SonicDyn</td>
      <td width="280">1736941.4640198653</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_Rapidjson</td>
      <td width="280">11854663.05084747</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_YYjson</td>
      <td width="280">8762756.624999924</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_SIMDjson</td>
      <td width="280">2384089.3814432314</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_JsonCpp</td>
      <td width="280">80666487.77778104</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_SonicDyn</td>
      <td width="280">148602283.99999756</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_Rapidjson</td>
      <td width="280">264327196.6666608</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_YYjson</td>
      <td width="280">432084649.999993</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_SIMDjson</td>
      <td width="280">156311501.9999998</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_JsonCpp</td>
      <td width="280">12007083499.999994</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_SonicDyn</td>
      <td width="280">1278359.380692175</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_Rapidjson</td>
      <td width="280">2620996.4044943764</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_YYjson</td>
      <td width="280">7155903.804347752</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_SIMDjson</td>
      <td width="280">1040592.3759398533</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_JsonCpp</td>
      <td width="280">61590971.66666665</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_SonicDyn</td>
      <td width="280">45612211.333332196</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_Rapidjson</td>
      <td width="280">165756105.00001404</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_YYjson</td>
      <td width="280">280003833.3333153</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_SIMDjson</td>
      <td width="280">91985399.99999866</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_JsonCpp</td>
      <td width="280">2807113549.99994</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_SonicDyn</td>
      <td width="280">235925.18506056428</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_Rapidjson</td>
      <td width="280">1718961.246882841</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_YYjson</td>
      <td width="280">1502370.9032257397</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_SIMDjson</td>
      <td width="280">498732.58435030404</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_JsonCpp</td>
      <td width="280">15924198.181817347</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_SonicDyn</td>
      <td width="280">5265992.348484767</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_Rapidjson</td>
      <td width="280">9350248.933333205</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_YYjson</td>
      <td width="280">28771415.416665982</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_SIMDjson</td>
      <td width="280">6017567.758620685</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_JsonCpp</td>
      <td width="280">150356712.00000706</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_SonicDyn</td>
      <td width="280">713940.6673510722</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_Rapidjson</td>
      <td width="280">1369627.7131783576</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_YYjson</td>
      <td width="280">4047465.3757227226</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_SIMDjson</td>
      <td width="280">944025.8783783792</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_JsonCpp</td>
      <td width="280">32364396.363639317</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_SonicDyn</td>
      <td width="280">533.2542314012007</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_Rapidjson</td>
      <td width="280">1372.2910495688725</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_YYjson</td>
      <td width="280">2978.881096945285</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_SIMDjson</td>
      <td width="280">776.9289060071955</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_JsonCpp</td>
      <td width="280">39328.036637441546</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_SonicDyn</td>
      <td width="280">844993.9806996882</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_Rapidjson</td>
      <td width="280">11899227.457628498</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_YYjson</td>
      <td width="280">4959422.765957197</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_SIMDjson</td>
      <td width="280">4411693.29113978</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_JsonCpp</td>
      <td width="280">53881989.23076987</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_SonicDyn</td>
      <td width="280">90231.48421324366</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_Rapidjson</td>
      <td width="280">778801.1273957144</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_YYjson</td>
      <td width="280">551430.1886792706</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_SIMDjson</td>
      <td width="280">213387.79308235255</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_JsonCpp</td>
      <td width="280">6702639.619048308</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_SonicDyn</td>
      <td width="280">20518.540955630335</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_Rapidjson</td>
      <td width="280">204394.6492515392</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_YYjson</td>
      <td width="280">110320.72804800172</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_SIMDjson</td>
      <td width="280">49506.81606107861</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_JsonCpp</td>
      <td width="280">1421033.0346233137</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_SonicDyn</td>
      <td width="280">929112.9188481249</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_Rapidjson</td>
      <td width="280">12937025.185185239</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_YYjson</td>
      <td width="280">3011944.009009304</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_SIMDjson</td>
      <td width="280">2117211.903323152</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_JsonCpp</td>
      <td width="280">76221686.6666626</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_SonicDyn</td>
      <td width="280">110608283.3333441</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_Rapidjson</td>
      <td width="280">239582366.66665775</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_YYjson</td>
      <td width="280">549772730.0000861</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_SIMDjson</td>
      <td width="280">161278687.5000154</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_JsonCpp</td>
      <td width="280">5872418629.99997</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_SonicDyn</td>
      <td width="280">549709.8325358971</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_Rapidjson</td>
      <td width="280">1512705.0755939663</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_YYjson</td>
      <td width="280">2899228.7136928504</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_SIMDjson</td>
      <td width="280">785363.831460784</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_JsonCpp</td>
      <td width="280">27639249.19999681</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Stat_SonicDyn</td>
      <td width="280">18887069.189190697</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Find_SonicDyn</td>
      <td width="280">38495752.22221802</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Stat_Rapidjson</td>
      <td width="280">16904249.512194615</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Find_Rapidjson</td>
      <td width="280">25718264.444444012</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Stat_SonicDyn</td>
      <td width="280">77868.05295949559</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Find_SonicDyn</td>
      <td width="280">248128.50815025187</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Stat_Rapidjson</td>
      <td width="280">69155.8068703829</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Find_Rapidjson</td>
      <td width="280">229421.2487708875</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Stat_SonicDyn</td>
      <td width="280">863671.0123456104</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Find_SonicDyn</td>
      <td width="280">588631.6304347352</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Stat_Rapidjson</td>
      <td width="280">646014.7407407416</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Find_Rapidjson</td>
      <td width="280">399333.7513812669</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Stat_SonicDyn</td>
      <td width="280">257792.81861832849</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Find_SonicDyn</td>
      <td width="280">410622.2131147382</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Stat_Rapidjson</td>
      <td width="280">223743.33545108247</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Find_Rapidjson</td>
      <td width="280">288102.74107510544</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Stat_SonicDyn</td>
      <td width="280">175.45665901534522</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Find_SonicDyn</td>
      <td width="280">278.914812040795</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Stat_Rapidjson</td>
      <td width="280">156.56533931801974</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Find_Rapidjson</td>
      <td width="280">179.6862519568452</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Stat_SonicDyn</td>
      <td width="280">105198.90676691728</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Find_SonicDyn</td>
      <td width="280">2399788.247422666</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Stat_Rapidjson</td>
      <td width="280">122519.70914129114</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Find_Rapidjson</td>
      <td width="280">2196124.716981229</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Stat_SonicDyn</td>
      <td width="280">29763.218796515994</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Find_SonicDyn</td>
      <td width="280">92868.8406369233</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Stat_Rapidjson</td>
      <td width="280">24707.64770395458</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Find_Rapidjson</td>
      <td width="280">83630.21435337368</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Stat_SonicDyn</td>
      <td width="280">6683.473917008363</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Find_SonicDyn</td>
      <td width="280">17730.3258259414</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Stat_Rapidjson</td>
      <td width="280">5547.553725838612</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Find_Rapidjson</td>
      <td width="280">13001.900853942832</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Stat_SonicDyn</td>
      <td width="280">190538.64608721278</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Find_SonicDyn</td>
      <td width="280">317374.17991820874</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Stat_Rapidjson</td>
      <td width="280">224311.420308466</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Find_Rapidjson</td>
      <td width="280">221346.42671853848</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Stat_SonicDyn</td>
      <td width="280">59842441.81818418</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Find_SonicDyn</td>
      <td width="280">1796990670.0000138</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Stat_Rapidjson</td>
      <td width="280">53801121.538465574</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Find_Rapidjson</td>
      <td width="280">1104624519.9999022</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Stat_SonicDyn</td>
      <td width="280">230330.28839920237</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Find_SonicDyn</td>
      <td width="280">351088.12090677035</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Stat_Rapidjson</td>
      <td width="280">212396.37212014748</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Find_Rapidjson</td>
      <td width="280">221597.70621823933</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### sonic-cpp 1.0.2

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
      <td width="190">15918.171873934876</td>
      <td width="190">45425.747215747215</td>
      <td width="360">0.3504</td>
    </tr>
    <tr>
      <td width="450">twitter/RapidjsonSaxOnDemand_Normal</td>
      <td width="190">越小越好</td>
      <td width="190">311454.5983971502</td>
      <td width="190">774542.6077348066</td>
      <td width="360">0.4021</td>
    </tr>
    <tr>
      <td width="450">twitter/SIMDjsonOnDemand_Normal</td>
      <td width="190">越小越好</td>
      <td width="190">51717.99216903078</td>
      <td width="190">113227.90485500148</td>
      <td width="360">0.4568</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="190">越小越好</td>
      <td width="190">9314.145271260022</td>
      <td width="190">22118.209897988156</td>
      <td width="360">0.4211</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/RapidjsonSaxOnDemand_Fronter</td>
      <td width="190">越小越好</td>
      <td width="190">94176.90974192668</td>
      <td width="190">173474.2913096695</td>
      <td width="360">0.5429</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/SIMDjsonOnDemand_Fronter</td>
      <td width="190">越小越好</td>
      <td width="190">220182.07041810764</td>
      <td width="190">513190.5081001469</td>
      <td width="360">0.429</td>
    </tr>
    <tr>
      <td width="450">twitter/SonicOnDemand_NotFound</td>
      <td width="190">越小越好</td>
      <td width="190">15800.82774655195</td>
      <td width="190">45094.24991906752</td>
      <td width="360">0.3504</td>
    </tr>
    <tr>
      <td width="450">twitter/RapidjsonSaxOnDemand_NotFound</td>
      <td width="190">越小越好</td>
      <td width="190">314191.9201077203</td>
      <td width="190">807408.0023364498</td>
      <td width="360">0.3891</td>
    </tr>
    <tr>
      <td width="450">twitter/SIMDjsonOnDemand_NotFound</td>
      <td width="190">越小越好</td>
      <td width="190">51734.75221526697</td>
      <td width="190">113190.36195422846</td>
      <td width="360">0.4571</td>
    </tr>
    <tr>
      <td width="450">fgo/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">47035392.99999956</td>
      <td width="190">82070608.57142982</td>
      <td width="360">0.5731</td>
    </tr>
    <tr>
      <td width="450">fgo/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">98825828.16666624</td>
      <td width="190">209549890.00000054</td>
      <td width="360">0.4716</td>
    </tr>
    <tr>
      <td width="450">fgo/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">107917212.1428574</td>
      <td width="190">269538413.3333316</td>
      <td width="360">0.4004</td>
    </tr>
    <tr>
      <td width="450">fgo/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">54603546.53846184</td>
      <td width="190">84688892.49999912</td>
      <td width="360">0.6448</td>
    </tr>
    <tr>
      <td width="450">fgo/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">5639604084.000012</td>
      <td width="190">5759468720.000001</td>
      <td width="360">0.9792</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">263998.89958475134</td>
      <td width="190">452619.30609598104</td>
      <td width="360">0.5833</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">897982.1108280219</td>
      <td width="190">1964570.198300299</td>
      <td width="360">0.4571</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">998293.4428571509</td>
      <td width="190">2485254.7330960934</td>
      <td width="360">0.4017</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">355217.2672764217</td>
      <td width="190">866732.853598004</td>
      <td width="360">0.4098</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">25326881.035713967</td>
      <td width="190">27728449.19999955</td>
      <td width="360">0.9134</td>
    </tr>
    <tr>
      <td width="450">canada/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">2107523.048047975</td>
      <td width="190">5218214.887217794</td>
      <td width="360">0.4039</td>
    </tr>
    <tr>
      <td width="450">canada/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">3052679.810344815</td>
      <td width="190">5288238.333333318</td>
      <td width="360">0.5773</td>
    </tr>
    <tr>
      <td width="450">canada/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">6696767.586538281</td>
      <td width="190">14729731.914893035</td>
      <td width="360">0.4546</td>
    </tr>
    <tr>
      <td width="450">canada/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">2117603.8121212465</td>
      <td width="190">3857675.0561798634</td>
      <td width="360">0.5489</td>
    </tr>
    <tr>
      <td width="450">canada/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">313125279.00000477</td>
      <td width="190">315313044.9999821</td>
      <td width="360">0.9931</td>
    </tr>
    <tr>
      <td width="450">lottie/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">427675.40537239675</td>
      <td width="190">754774.8966267799</td>
      <td width="360">0.5666</td>
    </tr>
    <tr>
      <td width="450">lottie/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">837212.9294947291</td>
      <td width="190">1285164.140480583</td>
      <td width="360">0.6514</td>
    </tr>
    <tr>
      <td width="450">lottie/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">870724.9067164222</td>
      <td width="190">2408828.5172414826</td>
      <td width="360">0.3615</td>
    </tr>
    <tr>
      <td width="450">lottie/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">342421.51024390815</td>
      <td width="190">715177.9568788019</td>
      <td width="360">0.4788</td>
    </tr>
    <tr>
      <td width="450">lottie/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">73764049.49999937</td>
      <td width="190">70911811.99999711</td>
      <td width="360">1.0402</td>
    </tr>
    <tr>
      <td width="450">book/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">458.8251189821711</td>
      <td width="190">831.332824206278</td>
      <td width="360">0.5519</td>
    </tr>
    <tr>
      <td width="450">book/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">895.3204042698962</td>
      <td width="190">1539.5307199849833</td>
      <td width="360">0.5816</td>
    </tr>
    <tr>
      <td width="450">book/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">872.3899706992482</td>
      <td width="190">2172.779949272683</td>
      <td width="360">0.4015</td>
    </tr>
    <tr>
      <td width="450">book/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">448.02596752086646</td>
      <td width="190">853.818863599036</td>
      <td width="360">0.5247</td>
    </tr>
    <tr>
      <td width="450">book/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">69717.58014127826</td>
      <td width="190">72117.83008155624</td>
      <td width="360">0.9667</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">590801.37298214</td>
      <td width="190">1304196.3157894628</td>
      <td width="360">0.453</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">4390968.905660352</td>
      <td width="190">11286685.000000363</td>
      <td width="360">0.389</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">4189931.982035952</td>
      <td width="190">9621623.611111198</td>
      <td width="360">0.4355</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">754391.6239130634</td>
      <td width="190">1688376.992665087</td>
      <td width="360">0.4468</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">49647157.214284986</td>
      <td width="190">57052403.84615378</td>
      <td width="360">0.8702</td>
    </tr>
    <tr>
      <td width="450">twitter/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">96312.36612548042</td>
      <td width="190">205200.00586682808</td>
      <td width="360">0.4694</td>
    </tr>
    <tr>
      <td width="450">twitter/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">347635.78196233616</td>
      <td width="190">807426.5272938188</td>
      <td width="360">0.4305</td>
    </tr>
    <tr>
      <td width="450">twitter/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">311797.24899777817</td>
      <td width="190">981790.4781996943</td>
      <td width="360">0.3176</td>
    </tr>
    <tr>
      <td width="450">twitter/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">77803.19340878625</td>
      <td width="190">170837.88856305162</td>
      <td width="360">0.4554</td>
    </tr>
    <tr>
      <td width="450">twitter/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">9513709.054054111</td>
      <td width="190">10457127.205881989</td>
      <td width="360">0.9098</td>
    </tr>
    <tr>
      <td width="450">github_events/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">22638.657508565644</td>
      <td width="190">48000.95073346465</td>
      <td width="360">0.4716</td>
    </tr>
    <tr>
      <td width="450">github_events/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">90822.5122775136</td>
      <td width="190">217219.25340767793</td>
      <td width="360">0.4181</td>
    </tr>
    <tr>
      <td width="450">github_events/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">81681.41297246664</td>
      <td width="190">218897.66990290387</td>
      <td width="360">0.3731</td>
    </tr>
    <tr>
      <td width="450">github_events/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">16905.396052281358</td>
      <td width="190">37085.02472220633</td>
      <td width="360">0.4559</td>
    </tr>
    <tr>
      <td width="450">github_events/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">2198104.6489029042</td>
      <td width="190">2360472.7609426538</td>
      <td width="360">0.9312</td>
    </tr>
    <tr>
      <td width="450">poet/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">800215.3729977165</td>
      <td width="190">1736941.4640198653</td>
      <td width="360">0.4607</td>
    </tr>
    <tr>
      <td width="450">poet/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">4772373.183673417</td>
      <td width="190">11854663.05084747</td>
      <td width="360">0.4026</td>
    </tr>
    <tr>
      <td width="450">poet/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">2669921.261538487</td>
      <td width="190">8762756.624999924</td>
      <td width="360">0.3047</td>
    </tr>
    <tr>
      <td width="450">poet/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">941980.3243606815</td>
      <td width="190">2384089.3814432314</td>
      <td width="360">0.3951</td>
    </tr>
    <tr>
      <td width="450">poet/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">75084112.10000077</td>
      <td width="190">80666487.77778104</td>
      <td width="360">0.9308</td>
    </tr>
    <tr>
      <td width="450">otfcc/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">106835167.62500033</td>
      <td width="190">148602283.99999756</td>
      <td width="360">0.7189</td>
    </tr>
    <tr>
      <td width="450">otfcc/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">168794221.24999622</td>
      <td width="190">264327196.6666608</td>
      <td width="360">0.6386</td>
    </tr>
    <tr>
      <td width="450">otfcc/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">162311981.4000006</td>
      <td width="190">432084649.999993</td>
      <td width="360">0.3756</td>
    </tr>
    <tr>
      <td width="450">otfcc/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">96525778.37500331</td>
      <td width="190">156311501.9999998</td>
      <td width="360">0.6175</td>
    </tr>
    <tr>
      <td width="450">otfcc/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">12331173924.999973</td>
      <td width="190">12007083499.999994</td>
      <td width="360">1.027</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Decode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">598944.9341317166</td>
      <td width="190">1278359.380692175</td>
      <td width="360">0.4685</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Decode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">1582714.5146726188</td>
      <td width="190">2620996.4044943764</td>
      <td width="360">0.6039</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Decode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">2024087.3468209181</td>
      <td width="190">7155903.804347752</td>
      <td width="360">0.2829</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Decode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">578379.3399504168</td>
      <td width="190">1040592.3759398533</td>
      <td width="360">0.5558</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Decode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">61958427.076923236</td>
      <td width="190">61590971.66666665</td>
      <td width="360">1.006</td>
    </tr>
    <tr>
      <td width="450">fgo/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">26195530.333333645</td>
      <td width="190">45612211.333332196</td>
      <td width="360">0.5743</td>
    </tr>
    <tr>
      <td width="450">fgo/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">58848495.000001825</td>
      <td width="190">165756105.00001404</td>
      <td width="360">0.355</td>
    </tr>
    <tr>
      <td width="450">fgo/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">64029624.09090791</td>
      <td width="190">280003833.3333153</td>
      <td width="360">0.2287</td>
    </tr>
    <tr>
      <td width="450">fgo/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">74691022.77778146</td>
      <td width="190">91985399.99999866</td>
      <td width="360">0.812</td>
    </tr>
    <tr>
      <td width="450">fgo/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">2259704013.0000324</td>
      <td width="190">2807113549.99994</td>
      <td width="360">0.805</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">135597.33410852196</td>
      <td width="190">235925.18506056428</td>
      <td width="360">0.5747</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">515058.87426473276</td>
      <td width="190">1718961.246882841</td>
      <td width="360">0.2996</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">421152.03309267724</td>
      <td width="190">1502370.9032257397</td>
      <td width="360">0.2803</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">300181.3522336317</td>
      <td width="190">498732.58435030404</td>
      <td width="360">0.6019</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">11783991.79660974</td>
      <td width="190">15924198.181817347</td>
      <td width="360">0.74</td>
    </tr>
    <tr>
      <td width="450">canada/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">3745239.604277741</td>
      <td width="190">5265992.348484767</td>
      <td width="360">0.7112</td>
    </tr>
    <tr>
      <td width="450">canada/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">7350679.610526879</td>
      <td width="190">9350248.933333205</td>
      <td width="360">0.7861</td>
    </tr>
    <tr>
      <td width="450">canada/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">7177839.84536015</td>
      <td width="190">28771415.416665982</td>
      <td width="360">0.2495</td>
    </tr>
    <tr>
      <td width="450">canada/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">3431196.0245099277</td>
      <td width="190">6017567.758620685</td>
      <td width="360">0.5702</td>
    </tr>
    <tr>
      <td width="450">canada/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">117897388.83334167</td>
      <td width="190">150356712.00000706</td>
      <td width="360">0.7841</td>
    </tr>
    <tr>
      <td width="450">lottie/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">462534.33267196297</td>
      <td width="190">713940.6673510722</td>
      <td width="360">0.6479</td>
    </tr>
    <tr>
      <td width="450">lottie/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">727438.3242392556</td>
      <td width="190">1369627.7131783576</td>
      <td width="360">0.5311</td>
    </tr>
    <tr>
      <td width="450">lottie/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">911647.3459530079</td>
      <td width="190">4047465.3757227226</td>
      <td width="360">0.2252</td>
    </tr>
    <tr>
      <td width="450">lottie/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">633100.4341636095</td>
      <td width="190">944025.8783783792</td>
      <td width="360">0.6706</td>
    </tr>
    <tr>
      <td width="450">lottie/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">27855494.83999603</td>
      <td width="190">32364396.363639317</td>
      <td width="360">0.8607</td>
    </tr>
    <tr>
      <td width="450">book/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">336.94520314225053</td>
      <td width="190">533.2542314012007</td>
      <td width="360">0.6319</td>
    </tr>
    <tr>
      <td width="450">book/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">780.0476753707838</td>
      <td width="190">1372.2910495688725</td>
      <td width="360">0.5684</td>
    </tr>
    <tr>
      <td width="450">book/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">697.7851880107</td>
      <td width="190">2978.881096945285</td>
      <td width="360">0.2342</td>
    </tr>
    <tr>
      <td width="450">book/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">490.5488096280727</td>
      <td width="190">776.9289060071955</td>
      <td width="360">0.6314</td>
    </tr>
    <tr>
      <td width="450">book/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">34170.36792545122</td>
      <td width="190">39328.036637441546</td>
      <td width="360">0.8689</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">417998.4814814689</td>
      <td width="190">844993.9806996882</td>
      <td width="360">0.4947</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">2462090.545774617</td>
      <td width="190">11899227.457628498</td>
      <td width="360">0.2069</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">2162538.7901234077</td>
      <td width="190">4959422.765957197</td>
      <td width="360">0.436</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">2878686.5925924685</td>
      <td width="190">4411693.29113978</td>
      <td width="360">0.6525</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">34773986.64999782</td>
      <td width="190">53881989.23076987</td>
      <td width="360">0.6454</td>
    </tr>
    <tr>
      <td width="450">twitter/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">50300.808165911105</td>
      <td width="190">90231.48421324366</td>
      <td width="360">0.5575</td>
    </tr>
    <tr>
      <td width="450">twitter/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">215239.54083204726</td>
      <td width="190">778801.1273957144</td>
      <td width="360">0.2764</td>
    </tr>
    <tr>
      <td width="450">twitter/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">146135.34983291646</td>
      <td width="190">551430.1886792706</td>
      <td width="360">0.265</td>
    </tr>
    <tr>
      <td width="450">twitter/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">131950.5920706691</td>
      <td width="190">213387.79308235255</td>
      <td width="360">0.6184</td>
    </tr>
    <tr>
      <td width="450">twitter/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">4932958.683098886</td>
      <td width="190">6702639.619048308</td>
      <td width="360">0.736</td>
    </tr>
    <tr>
      <td width="450">github_events/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">12131.83548297689</td>
      <td width="190">20518.540955630335</td>
      <td width="360">0.5913</td>
    </tr>
    <tr>
      <td width="450">github_events/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">48905.99022346724</td>
      <td width="190">204394.6492515392</td>
      <td width="360">0.2393</td>
    </tr>
    <tr>
      <td width="450">github_events/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">29609.4396971112</td>
      <td width="190">110320.72804800172</td>
      <td width="360">0.2684</td>
    </tr>
    <tr>
      <td width="450">github_events/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">32224.588448317012</td>
      <td width="190">49506.81606107861</td>
      <td width="360">0.6509</td>
    </tr>
    <tr>
      <td width="450">github_events/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">1033226.3372607144</td>
      <td width="190">1421033.0346233137</td>
      <td width="360">0.7271</td>
    </tr>
    <tr>
      <td width="450">poet/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">481576.0413223747</td>
      <td width="190">929112.9188481249</td>
      <td width="360">0.5183</td>
    </tr>
    <tr>
      <td width="450">poet/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">2340429.5719063515</td>
      <td width="190">12937025.185185239</td>
      <td width="360">0.1809</td>
    </tr>
    <tr>
      <td width="450">poet/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">1053561.7590361987</td>
      <td width="190">3011944.009009304</td>
      <td width="360">0.3498</td>
    </tr>
    <tr>
      <td width="450">poet/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">1260887.1384891784</td>
      <td width="190">2117211.903323152</td>
      <td width="360">0.5955</td>
    </tr>
    <tr>
      <td width="450">poet/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">60708225.63636242</td>
      <td width="190">76221686.6666626</td>
      <td width="360">0.7965</td>
    </tr>
    <tr>
      <td width="450">otfcc/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">72164810.09999143</td>
      <td width="190">110608283.3333441</td>
      <td width="360">0.6524</td>
    </tr>
    <tr>
      <td width="450">otfcc/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">134485615.00001687</td>
      <td width="190">239582366.66665775</td>
      <td width="360">0.5613</td>
    </tr>
    <tr>
      <td width="450">otfcc/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">136069856.79998615</td>
      <td width="190">549772730.0000861</td>
      <td width="360">0.2475</td>
    </tr>
    <tr>
      <td width="450">otfcc/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">120591251.49998334</td>
      <td width="190">161278687.5000154</td>
      <td width="360">0.7477</td>
    </tr>
    <tr>
      <td width="450">otfcc/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">5104447955.999945</td>
      <td width="190">5872418629.99997</td>
      <td width="360">0.8692</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Encode_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">267878.47216889187</td>
      <td width="190">549709.8325358971</td>
      <td width="360">0.4873</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Encode_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">575176.9111842907</td>
      <td width="190">1512705.0755939663</td>
      <td width="360">0.3802</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Encode_YYjson</td>
      <td width="190">越小越好</td>
      <td width="190">634335.401996346</td>
      <td width="190">2899228.7136928504</td>
      <td width="360">0.2188</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Encode_SIMDjson</td>
      <td width="190">越小越好</td>
      <td width="190">513012.7960954181</td>
      <td width="190">785363.831460784</td>
      <td width="360">0.6532</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Encode_JsonCpp</td>
      <td width="190">越小越好</td>
      <td width="190">23971399.68965395</td>
      <td width="190">27639249.19999681</td>
      <td width="360">0.8673</td>
    </tr>
    <tr>
      <td width="450">fgo/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">12024492.000000464</td>
      <td width="190">18887069.189190697</td>
      <td width="360">0.6367</td>
    </tr>
    <tr>
      <td width="450">fgo/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">22934165.290320702</td>
      <td width="190">38495752.22221802</td>
      <td width="360">0.5958</td>
    </tr>
    <tr>
      <td width="450">fgo/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">12900397.351851704</td>
      <td width="190">16904249.512194615</td>
      <td width="360">0.7631</td>
    </tr>
    <tr>
      <td width="450">fgo/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">23585352.699997958</td>
      <td width="190">25718264.444444012</td>
      <td width="360">0.9171</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">44695.59367226284</td>
      <td width="190">77868.05295949559</td>
      <td width="360">0.574</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">138237.1797708558</td>
      <td width="190">248128.50815025187</td>
      <td width="360">0.5571</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">51660.1016986684</td>
      <td width="190">69155.8068703829</td>
      <td width="360">0.747</td>
    </tr>
    <tr>
      <td width="450">twitterescaped/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">164740.5168671758</td>
      <td width="190">229421.2487708875</td>
      <td width="360">0.7181</td>
    </tr>
    <tr>
      <td width="450">canada/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">582298.0124481863</td>
      <td width="190">863671.0123456104</td>
      <td width="360">0.6742</td>
    </tr>
    <tr>
      <td width="450">canada/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">524244.7219731535</td>
      <td width="190">588631.6304347352</td>
      <td width="360">0.8906</td>
    </tr>
    <tr>
      <td width="450">canada/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">530746.0832072524</td>
      <td width="190">646014.7407407416</td>
      <td width="360">0.8216</td>
    </tr>
    <tr>
      <td width="450">canada/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">406297.8316889155</td>
      <td width="190">399333.7513812669</td>
      <td width="360">1.0174</td>
    </tr>
    <tr>
      <td width="450">lottie/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">167812.6848807679</td>
      <td width="190">257792.81861832849</td>
      <td width="360">0.651</td>
    </tr>
    <tr>
      <td width="450">lottie/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">225724.94390714998</td>
      <td width="190">410622.2131147382</td>
      <td width="360">0.5497</td>
    </tr>
    <tr>
      <td width="450">lottie/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">158725.15150829055</td>
      <td width="190">223743.33545108247</td>
      <td width="360">0.7094</td>
    </tr>
    <tr>
      <td width="450">lottie/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">189413.86693659812</td>
      <td width="190">288102.74107510544</td>
      <td width="360">0.6575</td>
    </tr>
    <tr>
      <td width="450">book/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">110.60694770599052</td>
      <td width="190">175.45665901534522</td>
      <td width="360">0.6304</td>
    </tr>
    <tr>
      <td width="450">book/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">170.3306811709838</td>
      <td width="190">278.914812040795</td>
      <td width="360">0.6107</td>
    </tr>
    <tr>
      <td width="450">book/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">127.16137829506108</td>
      <td width="190">156.56533931801974</td>
      <td width="360">0.8122</td>
    </tr>
    <tr>
      <td width="450">book/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">128.32704737021564</td>
      <td width="190">179.6862519568452</td>
      <td width="360">0.7142</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">59544.45712097897</td>
      <td width="190">105198.90676691728</td>
      <td width="360">0.566</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">1048916.1019490191</td>
      <td width="190">2399788.247422666</td>
      <td width="360">0.4371</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">83575.9918834988</td>
      <td width="190">122519.70914129114</td>
      <td width="360">0.6821</td>
    </tr>
    <tr>
      <td width="450">gsoc-2018/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">1505304.1376343386</td>
      <td width="190">2196124.716981229</td>
      <td width="360">0.6854</td>
    </tr>
    <tr>
      <td width="450">twitter/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">17094.04005076533</td>
      <td width="190">29763.218796515994</td>
      <td width="360">0.5743</td>
    </tr>
    <tr>
      <td width="450">twitter/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">51502.98424965135</td>
      <td width="190">92868.8406369233</td>
      <td width="360">0.5546</td>
    </tr>
    <tr>
      <td width="450">twitter/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">19810.914017029318</td>
      <td width="190">24707.64770395458</td>
      <td width="360">0.8018</td>
    </tr>
    <tr>
      <td width="450">twitter/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">56320.972730142894</td>
      <td width="190">83630.21435337368</td>
      <td width="360">0.6735</td>
    </tr>
    <tr>
      <td width="450">github_events/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">4665.573981714662</td>
      <td width="190">6683.473917008363</td>
      <td width="360">0.6981</td>
    </tr>
    <tr>
      <td width="450">github_events/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">8974.227467975381</td>
      <td width="190">17730.3258259414</td>
      <td width="360">0.5062</td>
    </tr>
    <tr>
      <td width="450">github_events/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">4428.687271689335</td>
      <td width="190">5547.553725838612</td>
      <td width="360">0.7983</td>
    </tr>
    <tr>
      <td width="450">github_events/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">10620.076590318156</td>
      <td width="190">13001.900853942832</td>
      <td width="360">0.8168</td>
    </tr>
    <tr>
      <td width="450">poet/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">114486.2042518328</td>
      <td width="190">190538.64608721278</td>
      <td width="360">0.6009</td>
    </tr>
    <tr>
      <td width="450">poet/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">175406.1629945116</td>
      <td width="190">317374.17991820874</td>
      <td width="360">0.5527</td>
    </tr>
    <tr>
      <td width="450">poet/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">148531.7015495806</td>
      <td width="190">224311.420308466</td>
      <td width="360">0.6622</td>
    </tr>
    <tr>
      <td width="450">poet/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">163527.89556074992</td>
      <td width="190">221346.42671853848</td>
      <td width="360">0.7388</td>
    </tr>
    <tr>
      <td width="450">otfcc/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">54296774.53846055</td>
      <td width="190">59842441.81818418</td>
      <td width="360">0.9073</td>
    </tr>
    <tr>
      <td width="450">otfcc/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">672383498.9999205</td>
      <td width="190">1796990670.0000138</td>
      <td width="360">0.3742</td>
    </tr>
    <tr>
      <td width="450">otfcc/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">51744262.23077087</td>
      <td width="190">53801121.538465574</td>
      <td width="360">0.9618</td>
    </tr>
    <tr>
      <td width="450">otfcc/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">1080693231.0000548</td>
      <td width="190">1104624519.9999022</td>
      <td width="360">0.9783</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Stat_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">127352.19616704396</td>
      <td width="190">230330.28839920237</td>
      <td width="360">0.5529</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Find_SonicDyn</td>
      <td width="190">越小越好</td>
      <td width="190">201308.80063202378</td>
      <td width="190">351088.12090677035</td>
      <td width="360">0.5734</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Stat_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">132188.12592033588</td>
      <td width="190">212396.37212014748</td>
      <td width="360">0.6224</td>
    </tr>
    <tr>
      <td width="450">citm_catalog/Find_Rapidjson</td>
      <td width="190">越小越好</td>
      <td width="190">199681.95782274607</td>
      <td width="190">221597.70621823933</td>
      <td width="360">0.9011</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
