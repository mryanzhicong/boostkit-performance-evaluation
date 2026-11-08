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
      <td width="180">Toolchain</td>
      <td width="220">python</td>
      <td width="160">3.14.3</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">python</td>
      <td width="160">3.14.3</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### python 3.14.3

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
      <td width="600">3.14.3</td>
      <td width="600">3.14.3</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">3.14.3</td>
      <td width="600">3.14.3</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-11-08T11:45:08Z</td>
      <td width="600">2026-11-08T11:47:09Z</td>
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
      <td width="600">2026-11-08T11:42:33Z</td>
      <td width="600">2026-11-08T11:42:33Z</td>
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
      <td width="600">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192622 MB<br>node 0 free: 62484 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 140673 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 168091 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 166238 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193523 MB<br>node 4 free: 134726 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193481 MB<br>node 5 free: 159625 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 169629 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 164099 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 365246 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 378249 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 346073 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 350209 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">pyperformance</td>
      <td width="880">1.13.0</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### python 3.14.3

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
      <td width="500">2to3</td>
      <td width="280">0.19296766724437475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">many_optionals</td>
      <td width="280">0.000620870191596623</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">subparsers</td>
      <td width="280">0.007506949259550311</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_generators</td>
      <td width="280">0.2781244767829776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_none</td>
      <td width="280">0.20587051240727305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_cpu_io_mixed</td>
      <td width="280">0.40471122204326093</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_cpu_io_mixed_tg</td>
      <td width="280">0.3907469704281539</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager</td>
      <td width="280">0.08429199305828661</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_cpu_io_mixed</td>
      <td width="280">0.3169507042039186</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_cpu_io_mixed_tg</td>
      <td width="280">0.36584706068970263</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_io</td>
      <td width="280">0.46808727108873427</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_io_tg</td>
      <td width="280">0.48761519859544933</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_memoization</td>
      <td width="280">0.17318628844805062</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_memoization_tg</td>
      <td width="280">0.21983544318936765</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_tg</td>
      <td width="280">0.16303750942461193</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_io</td>
      <td width="280">0.46604437357746065</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_io_tg</td>
      <td width="280">0.4652319187298417</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_memoization</td>
      <td width="280">0.24386226432397962</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_memoization_tg</td>
      <td width="280">0.24636126402765512</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_none_tg</td>
      <td width="280">0.20473597408272326</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_tcp</td>
      <td width="280">0.29610113985836506</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_tcp_ssl</td>
      <td width="280">1.1490519817452878</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_websockets</td>
      <td width="280">0.5134881029371172</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bpe_tokeniser</td>
      <td width="280">3.1219022704754025</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">chameleon</td>
      <td width="280">0.010349745411076583</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">chaos</td>
      <td width="280">0.0400394934695214</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">comprehensions</td>
      <td width="280">1.1905914860221856e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_mp_pool</td>
      <td width="280">0.007802194493706338</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_thread_pool</td>
      <td width="280">0.0010211215776507743</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">coroutines</td>
      <td width="280">0.017048052774043754</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">coverage</td>
      <td width="280">0.05504027788992971</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">crypto_pyaes</td>
      <td width="280">0.051510131801478565</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">dask</td>
      <td width="280">0.501984401838854</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy</td>
      <td width="280">0.0001923569184327789</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy_reduce</td>
      <td width="280">2.0924938688438033e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy_memo</td>
      <td width="280">2.1812530178522138e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deltablue</td>
      <td width="280">0.0023706579704594333</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">django_template</td>
      <td width="280">0.026289228990208358</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">docutils</td>
      <td width="280">1.87638269062154</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">dulwich_log</td>
      <td width="280">0.033006743353325874</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fannkuch</td>
      <td width="280">0.27051457529887557</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">float</td>
      <td width="280">0.04910399252548814</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">create_gc_cycles</td>
      <td width="280">0.0017766362507245503</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gc_traversal</td>
      <td width="280">0.004590546850522514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">generators</td>
      <td width="280">0.0219909762381576</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">genshi_text</td>
      <td width="280">0.017007633607136086</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">genshi_xml</td>
      <td width="280">0.0389839667477645</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">go</td>
      <td width="280">0.08463694446254522</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hexiom</td>
      <td width="280">0.004256860549503472</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">html5lib</td>
      <td width="280">0.038384074810892344</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">json_dumps</td>
      <td width="280">0.0075632619264069945</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">json_loads</td>
      <td width="280">1.7412063721167213e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_format</td>
      <td width="280">5.0115841986553274e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_silent</td>
      <td width="280">7.524671197245425e-08</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_simple</td>
      <td width="280">4.5734186301160665e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mako</td>
      <td width="280">0.008900666623958386</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mdp</td>
      <td width="280">0.8877324927598238</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">meteor_contest</td>
      <td width="280">0.07899854308925569</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nbody</td>
      <td width="280">0.08135314378887415</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">shortest_path</td>
      <td width="280">0.3716205982491374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">connected_components</td>
      <td width="280">0.35882520861923695</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">k_core</td>
      <td width="280">1.7342632480431348</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nqueens</td>
      <td width="280">0.060374669497832656</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pathlib</td>
      <td width="280">0.01636653472087346</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle</td>
      <td width="280">8.520645280896133e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_dict</td>
      <td width="280">2.152230504179897e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_list</td>
      <td width="280">3.034470643115128e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_pure_python</td>
      <td width="280">0.00022345472607412375</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pidigits</td>
      <td width="280">0.16739979293197393</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pprint_safe_repr</td>
      <td width="280">0.5400276030413806</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pprint_pformat</td>
      <td width="280">1.0952557679265738</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pyflate</td>
      <td width="280">0.3264338271692395</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">python_startup</td>
      <td width="280">0.009210504562361166</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">python_startup_no_site</td>
      <td width="280">0.00604462661431171</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">raytrace</td>
      <td width="280">0.18870233441703022</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_compile</td>
      <td width="280">0.07692178257275373</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_dna</td>
      <td width="280">0.13609630661085248</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_effbot</td>
      <td width="280">0.0022755594400223345</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_v8</td>
      <td width="280">0.017908831679960713</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">richards</td>
      <td width="280">0.030984134878963232</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">richards_super</td>
      <td width="280">0.035045813012402505</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_fft</td>
      <td width="280">0.25580171635374427</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_lu</td>
      <td width="280">0.08032395446207374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_monte_carlo</td>
      <td width="280">0.049770279321819544</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_sor</td>
      <td width="280">0.08768373040948063</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_sparse_mat_mult</td>
      <td width="280">0.004098417528439313</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">spectral_norm</td>
      <td width="280">0.07964522612746805</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sphinx</td>
      <td width="280">0.7098380231764168</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlalchemy_declarative</td>
      <td width="280">0.08180207875557244</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlalchemy_imperative</td>
      <td width="280">0.00828852791164536</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_normalize</td>
      <td width="280">0.07625406770966947</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_optimize</td>
      <td width="280">0.03676193201681599</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_parse</td>
      <td width="280">0.0009051716260728426</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_transpile</td>
      <td width="280">0.0011297361434117192</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlite_synth</td>
      <td width="280">1.7861973553578991e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_expand</td>
      <td width="280">0.2872435029130429</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_integrate</td>
      <td width="280">0.013427072379272431</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_sum</td>
      <td width="280">0.0899456349434331</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_str</td>
      <td width="280">0.1651413287036121</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">telco</td>
      <td width="280">0.005808172434626613</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">tomli_loads</td>
      <td width="280">1.5766534539870918</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">tornado_http</td>
      <td width="280">0.0931722124805674</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">typing_runtime_protocols</td>
      <td width="280">0.00011760535153371166</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpack_sequence</td>
      <td width="280">3.6740383961841874e-08</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle</td>
      <td width="280">1.0172441761824302e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle_list</td>
      <td width="280">3.5944961553013855e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle_pure_python</td>
      <td width="280">0.00015908503446553367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xdsl_constant_fold</td>
      <td width="280">0.02680119499564171</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_parse</td>
      <td width="280">0.09968035807833076</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_iterparse</td>
      <td width="280">0.062178172753192484</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_generate</td>
      <td width="280">0.06055435771122575</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_process</td>
      <td width="280">0.04362074920209125</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### python 3.14.3

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
      <td width="500">2to3</td>
      <td width="280">0.275538850488374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">many_optionals</td>
      <td width="280">0.0007854548066461575</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">subparsers</td>
      <td width="280">0.01115413287334377</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_generators</td>
      <td width="280">0.3792160370212514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_none</td>
      <td width="280">0.2687273294723127</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_cpu_io_mixed</td>
      <td width="280">0.5681606654834468</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_cpu_io_mixed_tg</td>
      <td width="280">0.5648566319723614</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager</td>
      <td width="280">0.11279193902737461</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_cpu_io_mixed</td>
      <td width="280">0.45122573600383475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_cpu_io_mixed_tg</td>
      <td width="280">0.5239137824974023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_io</td>
      <td width="280">0.6310484870045912</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_io_tg</td>
      <td width="280">0.615968410478672</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_memoization</td>
      <td width="280">0.21099052499630488</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_memoization_tg</td>
      <td width="280">0.29000599452410825</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_tg</td>
      <td width="280">0.20926377148134634</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_io</td>
      <td width="280">0.5912812859751284</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_io_tg</td>
      <td width="280">0.5815028504875954</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_memoization</td>
      <td width="280">0.3176761415088549</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_memoization_tg</td>
      <td width="280">0.31776190650998615</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_none_tg</td>
      <td width="280">0.2597897725063376</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_tcp</td>
      <td width="280">0.36586270047700964</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_tcp_ssl</td>
      <td width="280">1.6377682894817553</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_websockets</td>
      <td width="280">0.7036315464647487</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bpe_tokeniser</td>
      <td width="280">5.315853423002409</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">chameleon</td>
      <td width="280">0.014343072063638829</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">chaos</td>
      <td width="280">0.0653014077397529</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">comprehensions</td>
      <td width="280">1.9118962161002173e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_mp_pool</td>
      <td width="280">0.017932906182977604</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_thread_pool</td>
      <td width="280">0.0033019321563187987</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">coroutines</td>
      <td width="280">0.029027011747530196</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">coverage</td>
      <td width="280">0.10000123450299725</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">crypto_pyaes</td>
      <td width="280">0.08296524225443136</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">dask</td>
      <td width="280">0.8684563110000454</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy</td>
      <td width="280">0.00027936121091443056</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy_reduce</td>
      <td width="280">2.8848000717118794e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy_memo</td>
      <td width="280">3.312710143887898e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deltablue</td>
      <td width="280">0.003650839047622867</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">django_template</td>
      <td width="280">0.03891084661881905</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">docutils</td>
      <td width="280">2.6828474189387634</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">dulwich_log</td>
      <td width="280">0.043585600244114175</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fannkuch</td>
      <td width="280">0.44609579248935916</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">float</td>
      <td width="280">0.08122957524028607</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">create_gc_cycles</td>
      <td width="280">0.0033161780620503123</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gc_traversal</td>
      <td width="280">0.0064056430928758346</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">generators</td>
      <td width="280">0.03772526924876729</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">genshi_text</td>
      <td width="280">0.024422411748673767</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">genshi_xml</td>
      <td width="280">0.05273942349595018</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">go</td>
      <td width="280">0.12278553601936437</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hexiom</td>
      <td width="280">0.006680387001324561</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">html5lib</td>
      <td width="280">0.05274834974989062</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">json_dumps</td>
      <td width="280">0.01182017790779355</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">json_loads</td>
      <td width="280">3.0800386326745866e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_format</td>
      <td width="280">6.681673144726119e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_silent</td>
      <td width="280">1.2571143148676356e-07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_simple</td>
      <td width="280">6.185494969201955e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mako</td>
      <td width="280">0.01221766365597432</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mdp</td>
      <td width="280">1.398783574521076</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">meteor_contest</td>
      <td width="280">0.10924819848150946</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nbody</td>
      <td width="280">0.11571182601619512</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">shortest_path</td>
      <td width="280">0.5536279079969972</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">connected_components</td>
      <td width="280">0.5133410600246862</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">k_core</td>
      <td width="280">2.3930504845047835</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nqueens</td>
      <td width="280">0.09409483674971852</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pathlib</td>
      <td width="280">0.016794172373920446</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle</td>
      <td width="280">1.1683733006861985e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_dict</td>
      <td width="280">3.302484404343886e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_list</td>
      <td width="280">4.168015514949275e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_pure_python</td>
      <td width="280">0.00033584143593543556</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pidigits</td>
      <td width="280">0.24647592252586037</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pprint_safe_repr</td>
      <td width="280">0.7336427880218253</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pprint_pformat</td>
      <td width="280">1.5132551584974863</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pyflate</td>
      <td width="280">0.5044755889975931</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">python_startup</td>
      <td width="280">0.012700926872639684</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">python_startup_no_site</td>
      <td width="280">0.008575708687203587</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">raytrace</td>
      <td width="280">0.3000228629971389</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_compile</td>
      <td width="280">0.1130174555000849</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_dna</td>
      <td width="280">0.17673736551660113</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_effbot</td>
      <td width="280">0.003102576662786305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_v8</td>
      <td width="280">0.024755918748269323</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">richards</td>
      <td width="280">0.04785538074793294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">richards_super</td>
      <td width="280">0.05350344823091291</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_fft</td>
      <td width="280">0.3828261664893944</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_lu</td>
      <td width="280">0.13471538349404</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_monte_carlo</td>
      <td width="280">0.07469390574260615</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_sor</td>
      <td width="280">0.13450086399097927</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_sparse_mat_mult</td>
      <td width="280">0.005978931656500208</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">spectral_norm</td>
      <td width="280">0.12429975101258606</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sphinx</td>
      <td width="280">1.0314942429831717</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlalchemy_declarative</td>
      <td width="280">0.122037093504332</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlalchemy_imperative</td>
      <td width="280">0.013226685750851175</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_normalize</td>
      <td width="280">0.11434981602360494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_optimize</td>
      <td width="280">0.05633237575239036</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_parse</td>
      <td width="280">0.0013004654817905248</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_transpile</td>
      <td width="280">0.0016134236677771696</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlite_synth</td>
      <td width="280">2.293723121660207e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_expand</td>
      <td width="280">0.4262367580085993</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_integrate</td>
      <td width="280">0.018901679570262786</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_sum</td>
      <td width="280">0.13176119449781254</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_str</td>
      <td width="280">0.24883175001014024</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">telco</td>
      <td width="280">0.0076293267811706755</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">tomli_loads</td>
      <td width="280">2.2900890430028085</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">tornado_http</td>
      <td width="280">0.13851284948759712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">typing_runtime_protocols</td>
      <td width="280">0.00017785371048262277</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpack_sequence</td>
      <td width="280">4.75688943435415e-08</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle</td>
      <td width="280">1.5686227146716192e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle_list</td>
      <td width="280">6.273623756669622e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle_pure_python</td>
      <td width="280">0.00023164121016634455</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xdsl_constant_fold</td>
      <td width="280">0.04195191762119066</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_parse</td>
      <td width="280">0.16330349099007435</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_iterparse</td>
      <td width="280">0.11041112401289865</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_generate</td>
      <td width="280">0.0938631150056608</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_process</td>
      <td width="280">0.06678541599831078</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### python 3.14.3

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
      <td width="450">2to3</td>
      <td width="190">越小越好</td>
      <td width="190">0.19296766724437475</td>
      <td width="190">0.275538850488374</td>
      <td width="360">0.7003</td>
    </tr>
    <tr>
      <td width="450">many_optionals</td>
      <td width="190">越小越好</td>
      <td width="190">0.000620870191596623</td>
      <td width="190">0.0007854548066461575</td>
      <td width="360">0.7905</td>
    </tr>
    <tr>
      <td width="450">subparsers</td>
      <td width="190">越小越好</td>
      <td width="190">0.007506949259550311</td>
      <td width="190">0.01115413287334377</td>
      <td width="360">0.673</td>
    </tr>
    <tr>
      <td width="450">async_generators</td>
      <td width="190">越小越好</td>
      <td width="190">0.2781244767829776</td>
      <td width="190">0.3792160370212514</td>
      <td width="360">0.7334</td>
    </tr>
    <tr>
      <td width="450">async_tree_none</td>
      <td width="190">越小越好</td>
      <td width="190">0.20587051240727305</td>
      <td width="190">0.2687273294723127</td>
      <td width="360">0.7661</td>
    </tr>
    <tr>
      <td width="450">async_tree_cpu_io_mixed</td>
      <td width="190">越小越好</td>
      <td width="190">0.40471122204326093</td>
      <td width="190">0.5681606654834468</td>
      <td width="360">0.7123</td>
    </tr>
    <tr>
      <td width="450">async_tree_cpu_io_mixed_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.3907469704281539</td>
      <td width="190">0.5648566319723614</td>
      <td width="360">0.6918</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager</td>
      <td width="190">越小越好</td>
      <td width="190">0.08429199305828661</td>
      <td width="190">0.11279193902737461</td>
      <td width="360">0.7473</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_cpu_io_mixed</td>
      <td width="190">越小越好</td>
      <td width="190">0.3169507042039186</td>
      <td width="190">0.45122573600383475</td>
      <td width="360">0.7024</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_cpu_io_mixed_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.36584706068970263</td>
      <td width="190">0.5239137824974023</td>
      <td width="360">0.6983</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_io</td>
      <td width="190">越小越好</td>
      <td width="190">0.46808727108873427</td>
      <td width="190">0.6310484870045912</td>
      <td width="360">0.7418</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_io_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.48761519859544933</td>
      <td width="190">0.615968410478672</td>
      <td width="360">0.7916</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_memoization</td>
      <td width="190">越小越好</td>
      <td width="190">0.17318628844805062</td>
      <td width="190">0.21099052499630488</td>
      <td width="360">0.8208</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_memoization_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.21983544318936765</td>
      <td width="190">0.29000599452410825</td>
      <td width="360">0.758</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.16303750942461193</td>
      <td width="190">0.20926377148134634</td>
      <td width="360">0.7791</td>
    </tr>
    <tr>
      <td width="450">async_tree_io</td>
      <td width="190">越小越好</td>
      <td width="190">0.46604437357746065</td>
      <td width="190">0.5912812859751284</td>
      <td width="360">0.7882</td>
    </tr>
    <tr>
      <td width="450">async_tree_io_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.4652319187298417</td>
      <td width="190">0.5815028504875954</td>
      <td width="360">0.8001</td>
    </tr>
    <tr>
      <td width="450">async_tree_memoization</td>
      <td width="190">越小越好</td>
      <td width="190">0.24386226432397962</td>
      <td width="190">0.3176761415088549</td>
      <td width="360">0.7676</td>
    </tr>
    <tr>
      <td width="450">async_tree_memoization_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.24636126402765512</td>
      <td width="190">0.31776190650998615</td>
      <td width="360">0.7753</td>
    </tr>
    <tr>
      <td width="450">async_tree_none_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.20473597408272326</td>
      <td width="190">0.2597897725063376</td>
      <td width="360">0.7881</td>
    </tr>
    <tr>
      <td width="450">asyncio_tcp</td>
      <td width="190">越小越好</td>
      <td width="190">0.29610113985836506</td>
      <td width="190">0.36586270047700964</td>
      <td width="360">0.8093</td>
    </tr>
    <tr>
      <td width="450">asyncio_tcp_ssl</td>
      <td width="190">越小越好</td>
      <td width="190">1.1490519817452878</td>
      <td width="190">1.6377682894817553</td>
      <td width="360">0.7016</td>
    </tr>
    <tr>
      <td width="450">asyncio_websockets</td>
      <td width="190">越小越好</td>
      <td width="190">0.5134881029371172</td>
      <td width="190">0.7036315464647487</td>
      <td width="360">0.7298</td>
    </tr>
    <tr>
      <td width="450">bpe_tokeniser</td>
      <td width="190">越小越好</td>
      <td width="190">3.1219022704754025</td>
      <td width="190">5.315853423002409</td>
      <td width="360">0.5873</td>
    </tr>
    <tr>
      <td width="450">chameleon</td>
      <td width="190">越小越好</td>
      <td width="190">0.010349745411076583</td>
      <td width="190">0.014343072063638829</td>
      <td width="360">0.7216</td>
    </tr>
    <tr>
      <td width="450">chaos</td>
      <td width="190">越小越好</td>
      <td width="190">0.0400394934695214</td>
      <td width="190">0.0653014077397529</td>
      <td width="360">0.6131</td>
    </tr>
    <tr>
      <td width="450">comprehensions</td>
      <td width="190">越小越好</td>
      <td width="190">1.1905914860221856e-05</td>
      <td width="190">1.9118962161002173e-05</td>
      <td width="360">0.6227</td>
    </tr>
    <tr>
      <td width="450">bench_mp_pool</td>
      <td width="190">越小越好</td>
      <td width="190">0.007802194493706338</td>
      <td width="190">0.017932906182977604</td>
      <td width="360">0.4351</td>
    </tr>
    <tr>
      <td width="450">bench_thread_pool</td>
      <td width="190">越小越好</td>
      <td width="190">0.0010211215776507743</td>
      <td width="190">0.0033019321563187987</td>
      <td width="360">0.3092</td>
    </tr>
    <tr>
      <td width="450">coroutines</td>
      <td width="190">越小越好</td>
      <td width="190">0.017048052774043754</td>
      <td width="190">0.029027011747530196</td>
      <td width="360">0.5873</td>
    </tr>
    <tr>
      <td width="450">coverage</td>
      <td width="190">越小越好</td>
      <td width="190">0.05504027788992971</td>
      <td width="190">0.10000123450299725</td>
      <td width="360">0.5504</td>
    </tr>
    <tr>
      <td width="450">crypto_pyaes</td>
      <td width="190">越小越好</td>
      <td width="190">0.051510131801478565</td>
      <td width="190">0.08296524225443136</td>
      <td width="360">0.6209</td>
    </tr>
    <tr>
      <td width="450">dask</td>
      <td width="190">越小越好</td>
      <td width="190">0.501984401838854</td>
      <td width="190">0.8684563110000454</td>
      <td width="360">0.578</td>
    </tr>
    <tr>
      <td width="450">deepcopy</td>
      <td width="190">越小越好</td>
      <td width="190">0.0001923569184327789</td>
      <td width="190">0.00027936121091443056</td>
      <td width="360">0.6886</td>
    </tr>
    <tr>
      <td width="450">deepcopy_reduce</td>
      <td width="190">越小越好</td>
      <td width="190">2.0924938688438033e-06</td>
      <td width="190">2.8848000717118794e-06</td>
      <td width="360">0.7254</td>
    </tr>
    <tr>
      <td width="450">deepcopy_memo</td>
      <td width="190">越小越好</td>
      <td width="190">2.1812530178522138e-05</td>
      <td width="190">3.312710143887898e-05</td>
      <td width="360">0.6584</td>
    </tr>
    <tr>
      <td width="450">deltablue</td>
      <td width="190">越小越好</td>
      <td width="190">0.0023706579704594333</td>
      <td width="190">0.003650839047622867</td>
      <td width="360">0.6493</td>
    </tr>
    <tr>
      <td width="450">django_template</td>
      <td width="190">越小越好</td>
      <td width="190">0.026289228990208358</td>
      <td width="190">0.03891084661881905</td>
      <td width="360">0.6756</td>
    </tr>
    <tr>
      <td width="450">docutils</td>
      <td width="190">越小越好</td>
      <td width="190">1.87638269062154</td>
      <td width="190">2.6828474189387634</td>
      <td width="360">0.6994</td>
    </tr>
    <tr>
      <td width="450">dulwich_log</td>
      <td width="190">越小越好</td>
      <td width="190">0.033006743353325874</td>
      <td width="190">0.043585600244114175</td>
      <td width="360">0.7573</td>
    </tr>
    <tr>
      <td width="450">fannkuch</td>
      <td width="190">越小越好</td>
      <td width="190">0.27051457529887557</td>
      <td width="190">0.44609579248935916</td>
      <td width="360">0.6064</td>
    </tr>
    <tr>
      <td width="450">float</td>
      <td width="190">越小越好</td>
      <td width="190">0.04910399252548814</td>
      <td width="190">0.08122957524028607</td>
      <td width="360">0.6045</td>
    </tr>
    <tr>
      <td width="450">create_gc_cycles</td>
      <td width="190">越小越好</td>
      <td width="190">0.0017766362507245503</td>
      <td width="190">0.0033161780620503123</td>
      <td width="360">0.5357</td>
    </tr>
    <tr>
      <td width="450">gc_traversal</td>
      <td width="190">越小越好</td>
      <td width="190">0.004590546850522514</td>
      <td width="190">0.0064056430928758346</td>
      <td width="360">0.7166</td>
    </tr>
    <tr>
      <td width="450">generators</td>
      <td width="190">越小越好</td>
      <td width="190">0.0219909762381576</td>
      <td width="190">0.03772526924876729</td>
      <td width="360">0.5829</td>
    </tr>
    <tr>
      <td width="450">genshi_text</td>
      <td width="190">越小越好</td>
      <td width="190">0.017007633607136086</td>
      <td width="190">0.024422411748673767</td>
      <td width="360">0.6964</td>
    </tr>
    <tr>
      <td width="450">genshi_xml</td>
      <td width="190">越小越好</td>
      <td width="190">0.0389839667477645</td>
      <td width="190">0.05273942349595018</td>
      <td width="360">0.7392</td>
    </tr>
    <tr>
      <td width="450">go</td>
      <td width="190">越小越好</td>
      <td width="190">0.08463694446254522</td>
      <td width="190">0.12278553601936437</td>
      <td width="360">0.6893</td>
    </tr>
    <tr>
      <td width="450">hexiom</td>
      <td width="190">越小越好</td>
      <td width="190">0.004256860549503472</td>
      <td width="190">0.006680387001324561</td>
      <td width="360">0.6372</td>
    </tr>
    <tr>
      <td width="450">html5lib</td>
      <td width="190">越小越好</td>
      <td width="190">0.038384074810892344</td>
      <td width="190">0.05274834974989062</td>
      <td width="360">0.7277</td>
    </tr>
    <tr>
      <td width="450">json_dumps</td>
      <td width="190">越小越好</td>
      <td width="190">0.0075632619264069945</td>
      <td width="190">0.01182017790779355</td>
      <td width="360">0.6399</td>
    </tr>
    <tr>
      <td width="450">json_loads</td>
      <td width="190">越小越好</td>
      <td width="190">1.7412063721167213e-05</td>
      <td width="190">3.0800386326745866e-05</td>
      <td width="360">0.5653</td>
    </tr>
    <tr>
      <td width="450">logging_format</td>
      <td width="190">越小越好</td>
      <td width="190">5.0115841986553274e-06</td>
      <td width="190">6.681673144726119e-06</td>
      <td width="360">0.75</td>
    </tr>
    <tr>
      <td width="450">logging_silent</td>
      <td width="190">越小越好</td>
      <td width="190">7.524671197245425e-08</td>
      <td width="190">1.2571143148676356e-07</td>
      <td width="360">0.5986</td>
    </tr>
    <tr>
      <td width="450">logging_simple</td>
      <td width="190">越小越好</td>
      <td width="190">4.5734186301160665e-06</td>
      <td width="190">6.185494969201955e-06</td>
      <td width="360">0.7394</td>
    </tr>
    <tr>
      <td width="450">mako</td>
      <td width="190">越小越好</td>
      <td width="190">0.008900666623958386</td>
      <td width="190">0.01221766365597432</td>
      <td width="360">0.7285</td>
    </tr>
    <tr>
      <td width="450">mdp</td>
      <td width="190">越小越好</td>
      <td width="190">0.8877324927598238</td>
      <td width="190">1.398783574521076</td>
      <td width="360">0.6346</td>
    </tr>
    <tr>
      <td width="450">meteor_contest</td>
      <td width="190">越小越好</td>
      <td width="190">0.07899854308925569</td>
      <td width="190">0.10924819848150946</td>
      <td width="360">0.7231</td>
    </tr>
    <tr>
      <td width="450">nbody</td>
      <td width="190">越小越好</td>
      <td width="190">0.08135314378887415</td>
      <td width="190">0.11571182601619512</td>
      <td width="360">0.7031</td>
    </tr>
    <tr>
      <td width="450">shortest_path</td>
      <td width="190">越小越好</td>
      <td width="190">0.3716205982491374</td>
      <td width="190">0.5536279079969972</td>
      <td width="360">0.6712</td>
    </tr>
    <tr>
      <td width="450">connected_components</td>
      <td width="190">越小越好</td>
      <td width="190">0.35882520861923695</td>
      <td width="190">0.5133410600246862</td>
      <td width="360">0.699</td>
    </tr>
    <tr>
      <td width="450">k_core</td>
      <td width="190">越小越好</td>
      <td width="190">1.7342632480431348</td>
      <td width="190">2.3930504845047835</td>
      <td width="360">0.7247</td>
    </tr>
    <tr>
      <td width="450">nqueens</td>
      <td width="190">越小越好</td>
      <td width="190">0.060374669497832656</td>
      <td width="190">0.09409483674971852</td>
      <td width="360">0.6416</td>
    </tr>
    <tr>
      <td width="450">pathlib</td>
      <td width="190">越小越好</td>
      <td width="190">0.01636653472087346</td>
      <td width="190">0.016794172373920446</td>
      <td width="360">0.9745</td>
    </tr>
    <tr>
      <td width="450">pickle</td>
      <td width="190">越小越好</td>
      <td width="190">8.520645280896133e-06</td>
      <td width="190">1.1683733006861985e-05</td>
      <td width="360">0.7293</td>
    </tr>
    <tr>
      <td width="450">pickle_dict</td>
      <td width="190">越小越好</td>
      <td width="190">2.152230504179897e-05</td>
      <td width="190">3.302484404343886e-05</td>
      <td width="360">0.6517</td>
    </tr>
    <tr>
      <td width="450">pickle_list</td>
      <td width="190">越小越好</td>
      <td width="190">3.034470643115128e-06</td>
      <td width="190">4.168015514949275e-06</td>
      <td width="360">0.728</td>
    </tr>
    <tr>
      <td width="450">pickle_pure_python</td>
      <td width="190">越小越好</td>
      <td width="190">0.00022345472607412375</td>
      <td width="190">0.00033584143593543556</td>
      <td width="360">0.6654</td>
    </tr>
    <tr>
      <td width="450">pidigits</td>
      <td width="190">越小越好</td>
      <td width="190">0.16739979293197393</td>
      <td width="190">0.24647592252586037</td>
      <td width="360">0.6792</td>
    </tr>
    <tr>
      <td width="450">pprint_safe_repr</td>
      <td width="190">越小越好</td>
      <td width="190">0.5400276030413806</td>
      <td width="190">0.7336427880218253</td>
      <td width="360">0.7361</td>
    </tr>
    <tr>
      <td width="450">pprint_pformat</td>
      <td width="190">越小越好</td>
      <td width="190">1.0952557679265738</td>
      <td width="190">1.5132551584974863</td>
      <td width="360">0.7238</td>
    </tr>
    <tr>
      <td width="450">pyflate</td>
      <td width="190">越小越好</td>
      <td width="190">0.3264338271692395</td>
      <td width="190">0.5044755889975931</td>
      <td width="360">0.6471</td>
    </tr>
    <tr>
      <td width="450">python_startup</td>
      <td width="190">越小越好</td>
      <td width="190">0.009210504562361166</td>
      <td width="190">0.012700926872639684</td>
      <td width="360">0.7252</td>
    </tr>
    <tr>
      <td width="450">python_startup_no_site</td>
      <td width="190">越小越好</td>
      <td width="190">0.00604462661431171</td>
      <td width="190">0.008575708687203587</td>
      <td width="360">0.7049</td>
    </tr>
    <tr>
      <td width="450">raytrace</td>
      <td width="190">越小越好</td>
      <td width="190">0.18870233441703022</td>
      <td width="190">0.3000228629971389</td>
      <td width="360">0.629</td>
    </tr>
    <tr>
      <td width="450">regex_compile</td>
      <td width="190">越小越好</td>
      <td width="190">0.07692178257275373</td>
      <td width="190">0.1130174555000849</td>
      <td width="360">0.6806</td>
    </tr>
    <tr>
      <td width="450">regex_dna</td>
      <td width="190">越小越好</td>
      <td width="190">0.13609630661085248</td>
      <td width="190">0.17673736551660113</td>
      <td width="360">0.77</td>
    </tr>
    <tr>
      <td width="450">regex_effbot</td>
      <td width="190">越小越好</td>
      <td width="190">0.0022755594400223345</td>
      <td width="190">0.003102576662786305</td>
      <td width="360">0.7334</td>
    </tr>
    <tr>
      <td width="450">regex_v8</td>
      <td width="190">越小越好</td>
      <td width="190">0.017908831679960713</td>
      <td width="190">0.024755918748269323</td>
      <td width="360">0.7234</td>
    </tr>
    <tr>
      <td width="450">richards</td>
      <td width="190">越小越好</td>
      <td width="190">0.030984134878963232</td>
      <td width="190">0.04785538074793294</td>
      <td width="360">0.6475</td>
    </tr>
    <tr>
      <td width="450">richards_super</td>
      <td width="190">越小越好</td>
      <td width="190">0.035045813012402505</td>
      <td width="190">0.05350344823091291</td>
      <td width="360">0.655</td>
    </tr>
    <tr>
      <td width="450">scimark_fft</td>
      <td width="190">越小越好</td>
      <td width="190">0.25580171635374427</td>
      <td width="190">0.3828261664893944</td>
      <td width="360">0.6682</td>
    </tr>
    <tr>
      <td width="450">scimark_lu</td>
      <td width="190">越小越好</td>
      <td width="190">0.08032395446207374</td>
      <td width="190">0.13471538349404</td>
      <td width="360">0.5962</td>
    </tr>
    <tr>
      <td width="450">scimark_monte_carlo</td>
      <td width="190">越小越好</td>
      <td width="190">0.049770279321819544</td>
      <td width="190">0.07469390574260615</td>
      <td width="360">0.6663</td>
    </tr>
    <tr>
      <td width="450">scimark_sor</td>
      <td width="190">越小越好</td>
      <td width="190">0.08768373040948063</td>
      <td width="190">0.13450086399097927</td>
      <td width="360">0.6519</td>
    </tr>
    <tr>
      <td width="450">scimark_sparse_mat_mult</td>
      <td width="190">越小越好</td>
      <td width="190">0.004098417528439313</td>
      <td width="190">0.005978931656500208</td>
      <td width="360">0.6855</td>
    </tr>
    <tr>
      <td width="450">spectral_norm</td>
      <td width="190">越小越好</td>
      <td width="190">0.07964522612746805</td>
      <td width="190">0.12429975101258606</td>
      <td width="360">0.6408</td>
    </tr>
    <tr>
      <td width="450">sphinx</td>
      <td width="190">越小越好</td>
      <td width="190">0.7098380231764168</td>
      <td width="190">1.0314942429831717</td>
      <td width="360">0.6882</td>
    </tr>
    <tr>
      <td width="450">sqlalchemy_declarative</td>
      <td width="190">越小越好</td>
      <td width="190">0.08180207875557244</td>
      <td width="190">0.122037093504332</td>
      <td width="360">0.6703</td>
    </tr>
    <tr>
      <td width="450">sqlalchemy_imperative</td>
      <td width="190">越小越好</td>
      <td width="190">0.00828852791164536</td>
      <td width="190">0.013226685750851175</td>
      <td width="360">0.6267</td>
    </tr>
    <tr>
      <td width="450">sqlglot_v2_normalize</td>
      <td width="190">越小越好</td>
      <td width="190">0.07625406770966947</td>
      <td width="190">0.11434981602360494</td>
      <td width="360">0.6668</td>
    </tr>
    <tr>
      <td width="450">sqlglot_v2_optimize</td>
      <td width="190">越小越好</td>
      <td width="190">0.03676193201681599</td>
      <td width="190">0.05633237575239036</td>
      <td width="360">0.6526</td>
    </tr>
    <tr>
      <td width="450">sqlglot_v2_parse</td>
      <td width="190">越小越好</td>
      <td width="190">0.0009051716260728426</td>
      <td width="190">0.0013004654817905248</td>
      <td width="360">0.696</td>
    </tr>
    <tr>
      <td width="450">sqlglot_v2_transpile</td>
      <td width="190">越小越好</td>
      <td width="190">0.0011297361434117192</td>
      <td width="190">0.0016134236677771696</td>
      <td width="360">0.7002</td>
    </tr>
    <tr>
      <td width="450">sqlite_synth</td>
      <td width="190">越小越好</td>
      <td width="190">1.7861973553578991e-06</td>
      <td width="190">2.293723121660207e-06</td>
      <td width="360">0.7787</td>
    </tr>
    <tr>
      <td width="450">sympy_expand</td>
      <td width="190">越小越好</td>
      <td width="190">0.2872435029130429</td>
      <td width="190">0.4262367580085993</td>
      <td width="360">0.6739</td>
    </tr>
    <tr>
      <td width="450">sympy_integrate</td>
      <td width="190">越小越好</td>
      <td width="190">0.013427072379272431</td>
      <td width="190">0.018901679570262786</td>
      <td width="360">0.7104</td>
    </tr>
    <tr>
      <td width="450">sympy_sum</td>
      <td width="190">越小越好</td>
      <td width="190">0.0899456349434331</td>
      <td width="190">0.13176119449781254</td>
      <td width="360">0.6826</td>
    </tr>
    <tr>
      <td width="450">sympy_str</td>
      <td width="190">越小越好</td>
      <td width="190">0.1651413287036121</td>
      <td width="190">0.24883175001014024</td>
      <td width="360">0.6637</td>
    </tr>
    <tr>
      <td width="450">telco</td>
      <td width="190">越小越好</td>
      <td width="190">0.005808172434626613</td>
      <td width="190">0.0076293267811706755</td>
      <td width="360">0.7613</td>
    </tr>
    <tr>
      <td width="450">tomli_loads</td>
      <td width="190">越小越好</td>
      <td width="190">1.5766534539870918</td>
      <td width="190">2.2900890430028085</td>
      <td width="360">0.6885</td>
    </tr>
    <tr>
      <td width="450">tornado_http</td>
      <td width="190">越小越好</td>
      <td width="190">0.0931722124805674</td>
      <td width="190">0.13851284948759712</td>
      <td width="360">0.6727</td>
    </tr>
    <tr>
      <td width="450">typing_runtime_protocols</td>
      <td width="190">越小越好</td>
      <td width="190">0.00011760535153371166</td>
      <td width="190">0.00017785371048262277</td>
      <td width="360">0.6612</td>
    </tr>
    <tr>
      <td width="450">unpack_sequence</td>
      <td width="190">越小越好</td>
      <td width="190">3.6740383961841874e-08</td>
      <td width="190">4.75688943435415e-08</td>
      <td width="360">0.7724</td>
    </tr>
    <tr>
      <td width="450">unpickle</td>
      <td width="190">越小越好</td>
      <td width="190">1.0172441761824302e-05</td>
      <td width="190">1.5686227146716192e-05</td>
      <td width="360">0.6485</td>
    </tr>
    <tr>
      <td width="450">unpickle_list</td>
      <td width="190">越小越好</td>
      <td width="190">3.5944961553013855e-06</td>
      <td width="190">6.273623756669622e-06</td>
      <td width="360">0.573</td>
    </tr>
    <tr>
      <td width="450">unpickle_pure_python</td>
      <td width="190">越小越好</td>
      <td width="190">0.00015908503446553367</td>
      <td width="190">0.00023164121016634455</td>
      <td width="360">0.6868</td>
    </tr>
    <tr>
      <td width="450">xdsl_constant_fold</td>
      <td width="190">越小越好</td>
      <td width="190">0.02680119499564171</td>
      <td width="190">0.04195191762119066</td>
      <td width="360">0.6389</td>
    </tr>
    <tr>
      <td width="450">xml_etree_parse</td>
      <td width="190">越小越好</td>
      <td width="190">0.09968035807833076</td>
      <td width="190">0.16330349099007435</td>
      <td width="360">0.6104</td>
    </tr>
    <tr>
      <td width="450">xml_etree_iterparse</td>
      <td width="190">越小越好</td>
      <td width="190">0.062178172753192484</td>
      <td width="190">0.11041112401289865</td>
      <td width="360">0.5632</td>
    </tr>
    <tr>
      <td width="450">xml_etree_generate</td>
      <td width="190">越小越好</td>
      <td width="190">0.06055435771122575</td>
      <td width="190">0.0938631150056608</td>
      <td width="360">0.6451</td>
    </tr>
    <tr>
      <td width="450">xml_etree_process</td>
      <td width="190">越小越好</td>
      <td width="190">0.04362074920209125</td>
      <td width="190">0.06678541599831078</td>
      <td width="360">0.6531</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
