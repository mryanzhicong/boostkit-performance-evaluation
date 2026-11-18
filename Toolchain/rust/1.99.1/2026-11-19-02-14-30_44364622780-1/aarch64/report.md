# rust 1.99.1 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`44364622780-1`

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
      <td width="1200">1.99.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">1.99.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-11-18T18:02:10Z</td>
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
      <td width="1200">2026-11-18T17:59:29Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 350122 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 380760 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 258975 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 347456 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">rustc-perf</td>
      <td width="880">0.1.0 (9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c)</td>
    </tr>
  </tbody>
</table>

## 性能指标

### compile

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
      <td width="500">compile/bitmaps-3.2.1/check/threads=1/instructions</td>
      <td width="280">1344594196.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/check/threads=1/wall-time</td>
      <td width="280">0.286505052</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/debug/threads=1/instructions</td>
      <td width="280">1514630942.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/debug/threads=1/wall-time</td>
      <td width="280">0.275682868</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/opt/threads=1/instructions</td>
      <td width="280">1902070710.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/opt/threads=1/wall-time</td>
      <td width="280">0.368934736</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=1/instructions</td>
      <td width="280">24349432604.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=1/wall-time</td>
      <td width="280">6.255183239</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=4/instructions</td>
      <td width="280">25167210708.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=4/wall-time</td>
      <td width="280">3.558717712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=1/instructions</td>
      <td width="280">148148816793.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=1/wall-time</td>
      <td width="280">16.625906528</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=4/instructions</td>
      <td width="280">151372163945.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=4/wall-time</td>
      <td width="280">12.767618708</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=1/instructions</td>
      <td width="280">669225173486.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=1/wall-time</td>
      <td width="280">24.814776717</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=4/instructions</td>
      <td width="280">672073884627.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=4/wall-time</td>
      <td width="280">19.65849417</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/check/threads=1/instructions</td>
      <td width="280">2068051030.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/check/threads=1/wall-time</td>
      <td width="280">0.438493203</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/debug/threads=1/instructions</td>
      <td width="280">6639647727.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/debug/threads=1/wall-time</td>
      <td width="280">0.972602786</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/opt/threads=1/instructions</td>
      <td width="280">42166026207.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/opt/threads=1/wall-time</td>
      <td width="280">2.113370899</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/check/threads=1/instructions</td>
      <td width="280">15585578160.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/check/threads=1/wall-time</td>
      <td width="280">2.999731402</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/debug/threads=1/instructions</td>
      <td width="280">43972864806.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/debug/threads=1/wall-time</td>
      <td width="280">5.194622658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/opt/threads=1/instructions</td>
      <td width="280">150826985620.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/opt/threads=1/wall-time</td>
      <td width="280">11.414080027</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/check/threads=1/instructions</td>
      <td width="280">24611289655.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/check/threads=1/wall-time</td>
      <td width="280">4.637943601</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/debug/threads=1/instructions</td>
      <td width="280">27898033297.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/debug/threads=1/wall-time</td>
      <td width="280">5.157924281</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/opt/threads=1/instructions</td>
      <td width="280">31438681730.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/opt/threads=1/wall-time</td>
      <td width="280">5.705813918</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/check/threads=1/instructions</td>
      <td width="280">4578250206.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/check/threads=1/wall-time</td>
      <td width="280">1.021068823</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/debug/threads=1/instructions</td>
      <td width="280">17020077821.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/debug/threads=1/wall-time</td>
      <td width="280">2.513818488</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/opt/threads=1/instructions</td>
      <td width="280">76378116736.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/opt/threads=1/wall-time</td>
      <td width="280">14.731615586</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/check/threads=1/instructions</td>
      <td width="280">15221366.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/check/threads=1/wall-time</td>
      <td width="280">0.034454575</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/debug/threads=1/instructions</td>
      <td width="280">437964767.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/debug/threads=1/wall-time</td>
      <td width="280">0.140786079</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/opt/threads=1/instructions</td>
      <td width="280">256726758.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/opt/threads=1/wall-time</td>
      <td width="280">0.118297945</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/check/threads=1/instructions</td>
      <td width="280">1693575678.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/check/threads=1/wall-time</td>
      <td width="280">0.380575346</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/debug/threads=1/instructions</td>
      <td width="280">2305170361.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/debug/threads=1/wall-time</td>
      <td width="280">0.454551759</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/opt/threads=1/instructions</td>
      <td width="280">3627551537.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/opt/threads=1/wall-time</td>
      <td width="280">0.664084047</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/check/threads=1/instructions</td>
      <td width="280">2012176138.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/check/threads=1/wall-time</td>
      <td width="280">0.539313935</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/debug/threads=1/instructions</td>
      <td width="280">4302782231.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/debug/threads=1/wall-time</td>
      <td width="280">0.759639038</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/opt/threads=1/instructions</td>
      <td width="280">9761824262.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/opt/threads=1/wall-time</td>
      <td width="280">2.255365963</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/check/threads=1/instructions</td>
      <td width="280">4164238914.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/check/threads=1/wall-time</td>
      <td width="280">0.993770214</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/debug/threads=1/instructions</td>
      <td width="280">23754546269.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/debug/threads=1/wall-time</td>
      <td width="280">2.550456425</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/opt/threads=1/instructions</td>
      <td width="280">198167770708.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/opt/threads=1/wall-time</td>
      <td width="280">6.591015435</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/check/threads=1/instructions</td>
      <td width="280">1474864171.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/check/threads=1/wall-time</td>
      <td width="280">0.278824317</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/debug/threads=1/instructions</td>
      <td width="280">1509846967.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/debug/threads=1/wall-time</td>
      <td width="280">0.289689291</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/opt/threads=1/instructions</td>
      <td width="280">1526344792.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/opt/threads=1/wall-time</td>
      <td width="280">0.338331578</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/check/threads=1/instructions</td>
      <td width="280">14266407166.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/check/threads=1/wall-time</td>
      <td width="280">2.951422214</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/debug/threads=1/instructions</td>
      <td width="280">15492275864.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/debug/threads=1/wall-time</td>
      <td width="280">3.202411294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/opt/threads=1/instructions</td>
      <td width="280">21461261334.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/opt/threads=1/wall-time</td>
      <td width="280">4.279803629</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/check/threads=1/instructions</td>
      <td width="280">4606163490.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/check/threads=1/wall-time</td>
      <td width="280">1.114948579</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/debug/threads=1/instructions</td>
      <td width="280">14650468597.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/debug/threads=1/wall-time</td>
      <td width="280">1.934587086</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/opt/threads=1/instructions</td>
      <td width="280">51923221359.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/opt/threads=1/wall-time</td>
      <td width="280">2.893389498</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/check/threads=1/instructions</td>
      <td width="280">1393583704.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/check/threads=1/wall-time</td>
      <td width="280">0.358432811</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/debug/threads=1/instructions</td>
      <td width="280">16027704136.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/debug/threads=1/wall-time</td>
      <td width="280">1.925196478</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/opt/threads=1/instructions</td>
      <td width="280">80206594474.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/opt/threads=1/wall-time</td>
      <td width="280">3.440929447</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=1/instructions</td>
      <td width="280">5364143258.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=1/wall-time</td>
      <td width="280">1.063369741</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=4/instructions</td>
      <td width="280">5543175220.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=4/wall-time</td>
      <td width="280">0.724299177</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=1/instructions</td>
      <td width="280">6707195106.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=1/wall-time</td>
      <td width="280">1.296498382</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=4/instructions</td>
      <td width="280">6917899286.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=4/wall-time</td>
      <td width="280">0.855837627</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=1/instructions</td>
      <td width="280">7439561280.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=1/wall-time</td>
      <td width="280">1.449670609</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=4/instructions</td>
      <td width="280">7668663508.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=4/wall-time</td>
      <td width="280">0.906943426</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/check/threads=1/instructions</td>
      <td width="280">3541007838.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/check/threads=1/wall-time</td>
      <td width="280">0.725694201</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/debug/threads=1/instructions</td>
      <td width="280">10975533873.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/debug/threads=1/wall-time</td>
      <td width="280">1.473033672</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/opt/threads=1/instructions</td>
      <td width="280">45769038155.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/opt/threads=1/wall-time</td>
      <td width="280">2.661007686</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/check/threads=1/instructions</td>
      <td width="280">9709020114.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/check/threads=1/wall-time</td>
      <td width="280">1.905716523</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/debug/threads=1/instructions</td>
      <td width="280">10591824253.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/debug/threads=1/wall-time</td>
      <td width="280">2.110581538</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/opt/threads=1/instructions</td>
      <td width="280">11361705835.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/opt/threads=1/wall-time</td>
      <td width="280">2.259110671</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/check/threads=1/instructions</td>
      <td width="280">2640375738.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/check/threads=1/wall-time</td>
      <td width="280">0.617609133</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/debug/threads=1/instructions</td>
      <td width="280">7806397524.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/debug/threads=1/wall-time</td>
      <td width="280">1.012823381</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/opt/threads=1/instructions</td>
      <td width="280">39514609330.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/opt/threads=1/wall-time</td>
      <td width="280">1.625201342</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/check/threads=1/instructions</td>
      <td width="280">7764649888.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/check/threads=1/wall-time</td>
      <td width="280">1.930152712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/debug/threads=1/instructions</td>
      <td width="280">16970324959.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/debug/threads=1/wall-time</td>
      <td width="280">2.775516873</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/opt/threads=1/instructions</td>
      <td width="280">33923128282.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/opt/threads=1/wall-time</td>
      <td width="280">3.333021937</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=1/instructions</td>
      <td width="280">2177296918.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=1/wall-time</td>
      <td width="280">0.352371531</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=4/instructions</td>
      <td width="280">2235347366.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=4/wall-time</td>
      <td width="280">0.287377248</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=1/instructions</td>
      <td width="280">2237401494.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=1/wall-time</td>
      <td width="280">0.368059218</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=4/instructions</td>
      <td width="280">2297658528.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=4/wall-time</td>
      <td width="280">0.299919096</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=1/instructions</td>
      <td width="280">2285354790.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=1/wall-time</td>
      <td width="280">0.376908468</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=4/instructions</td>
      <td width="280">2348468468.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=4/wall-time</td>
      <td width="280">0.311091669</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/check/threads=1/instructions</td>
      <td width="280">1359842306.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/check/threads=1/wall-time</td>
      <td width="280">0.231675485</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/debug/threads=1/instructions</td>
      <td width="280">1511422498.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/debug/threads=1/wall-time</td>
      <td width="280">0.236944018</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/opt/threads=1/instructions</td>
      <td width="280">1870671076.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/opt/threads=1/wall-time</td>
      <td width="280">0.309271726</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### runtime

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
      <td width="500">runtime/arc_alloc/instructions</td>
      <td width="280">101125855.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_alloc/wall-time</td>
      <td width="280">5.90724</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_alloc_slice/instructions</td>
      <td width="280">167967199.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_alloc_slice/wall-time</td>
      <td width="280">104.510941</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_decrement/instructions</td>
      <td width="280">7000065.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_decrement/wall-time</td>
      <td width="280">4.814774</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_deref/instructions</td>
      <td width="280">1500054.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_deref/wall-time</td>
      <td width="280">0.192279</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_deref_slice/instructions</td>
      <td width="280">1500056.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_deref_slice/wall-time</td>
      <td width="280">0.192239</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_downgrade_upgrade/instructions</td>
      <td width="280">30000093.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_downgrade_upgrade/wall-time</td>
      <td width="280">11.402462</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_drop/instructions</td>
      <td width="280">79999889.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_drop/wall-time</td>
      <td width="280">18.559918</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_increment/instructions</td>
      <td width="280">12000067.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_increment/wall-time</td>
      <td width="280">5.075303</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-compress/instructions</td>
      <td width="280">6017810757.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-compress/wall-time</td>
      <td width="280">617.856923</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-decompress/instructions</td>
      <td width="280">4120404084.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-decompress/wall-time</td>
      <td width="280">256.097633</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/bufreader_snappy/instructions</td>
      <td width="280">770555187.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/bufreader_snappy/wall-time</td>
      <td width="280">84.743936</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/css-parse-fb/instructions</td>
      <td width="280">1269653121.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/css-parse-fb/wall-time</td>
      <td width="280">158.26094</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/fmt-debug-derive/instructions</td>
      <td width="280">1513445774.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/fmt-debug-derive/wall-time</td>
      <td width="280">95.940029</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/fmt-write-str/instructions</td>
      <td width="280">3328430411.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/fmt-write-str/wall-time</td>
      <td width="280">211.975571</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_find_1m/instructions</td>
      <td width="280">56885312.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_find_1m/wall-time</td>
      <td width="280">18.606507</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_find_misses_1m/instructions</td>
      <td width="280">52550411.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_find_misses_1m/wall-time</td>
      <td width="280">6.972387</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_insert_1m/instructions</td>
      <td width="280">48000167.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_insert_1m/wall-time</td>
      <td width="280">9.265359</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_iterate_1m/instructions</td>
      <td width="280">23855157.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_iterate_1m/wall-time</td>
      <td width="280">1.782344</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_remove_1m/instructions</td>
      <td width="280">78905491.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_remove_1m/wall-time</td>
      <td width="280">22.221995</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nbody_5k/instructions</td>
      <td width="280">3630816869.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nbody_5k/wall-time</td>
      <td width="280">585.89358</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nom-json/instructions</td>
      <td width="280">2453227236.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nom-json/wall-time</td>
      <td width="280">198.055417</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/pinky-nes15/instructions</td>
      <td width="280">2365259411.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/pinky-nes15/wall-time</td>
      <td width="280">237.395956</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/raytracer/instructions</td>
      <td width="280">4820351861.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/raytracer/wall-time</td>
      <td width="280">540.444111</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_alloc/instructions</td>
      <td width="280">101126921.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_alloc/wall-time</td>
      <td width="280">6.14669</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_alloc_slice/instructions</td>
      <td width="280">178967198.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_alloc_slice/wall-time</td>
      <td width="280">104.995879</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_decrement/instructions</td>
      <td width="280">4500065.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_decrement/wall-time</td>
      <td width="280">0.687927</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_deref/instructions</td>
      <td width="280">1500054.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_deref/wall-time</td>
      <td width="280">0.192379</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_deref_slice/instructions</td>
      <td width="280">1500055.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_deref_slice/wall-time</td>
      <td width="280">0.19221</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_downgrade_upgrade/instructions</td>
      <td width="280">18500092.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_downgrade_upgrade/wall-time</td>
      <td width="280">1.879284</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_drop/instructions</td>
      <td width="280">70499889.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_drop/wall-time</td>
      <td width="280">4.239266</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_increment/instructions</td>
      <td width="280">10000084.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_increment/wall-time</td>
      <td width="280">1.002237</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/regex-capture-1/instructions</td>
      <td width="280">194834395.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/regex-capture-1/wall-time</td>
      <td width="280">27.10652</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/regex-search-1/instructions</td>
      <td width="280">49677761.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/regex-search-1/wall-time</td>
      <td width="280">5.98821</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-parse-1/instructions</td>
      <td width="280">5467485603.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-parse-1/wall-time</td>
      <td width="280">490.267499</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-render-1/instructions</td>
      <td width="280">1088770904.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-render-1/wall-time</td>
      <td width="280">137.59391</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
