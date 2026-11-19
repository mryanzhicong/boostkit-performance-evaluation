# rust 1.99.1 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`44537761889-1`

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
      <td width="1200">2026-11-19T14:20:17Z</td>
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
      <td width="1200">2026-11-19T14:16:59Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 350190 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 379870 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 241836 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 347725 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">1344590556.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/check/threads=1/wall-time</td>
      <td width="280">0.271849036</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/debug/threads=1/instructions</td>
      <td width="280">1514626990.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/debug/threads=1/wall-time</td>
      <td width="280">0.266613754</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/opt/threads=1/instructions</td>
      <td width="280">1902066030.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/opt/threads=1/wall-time</td>
      <td width="280">0.352746082</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=1/instructions</td>
      <td width="280">24349453489.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=1/wall-time</td>
      <td width="280">6.118883944</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=4/instructions</td>
      <td width="280">25168775370.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=4/wall-time</td>
      <td width="280">3.45434486</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=1/instructions</td>
      <td width="280">148131727342.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=1/wall-time</td>
      <td width="280">16.486787157</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=4/instructions</td>
      <td width="280">151355363708.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=4/wall-time</td>
      <td width="280">12.650181936</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=1/instructions</td>
      <td width="280">669289337832.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=1/wall-time</td>
      <td width="280">24.603113362</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=4/instructions</td>
      <td width="280">671998549885.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=4/wall-time</td>
      <td width="280">19.735370696</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/check/threads=1/instructions</td>
      <td width="280">2068037544.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/check/threads=1/wall-time</td>
      <td width="280">0.449474802</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/debug/threads=1/instructions</td>
      <td width="280">6641332635.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/debug/threads=1/wall-time</td>
      <td width="280">0.977321058</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/opt/threads=1/instructions</td>
      <td width="280">42166842004.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/opt/threads=1/wall-time</td>
      <td width="280">2.091185733</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/check/threads=1/instructions</td>
      <td width="280">15585571302.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/check/threads=1/wall-time</td>
      <td width="280">2.961153126</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/debug/threads=1/instructions</td>
      <td width="280">43972016798.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/debug/threads=1/wall-time</td>
      <td width="280">5.208946147</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/opt/threads=1/instructions</td>
      <td width="280">150781308921.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/opt/threads=1/wall-time</td>
      <td width="280">11.364234776</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/check/threads=1/instructions</td>
      <td width="280">24611282033.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/check/threads=1/wall-time</td>
      <td width="280">4.650929723</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/debug/threads=1/instructions</td>
      <td width="280">27898028888.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/debug/threads=1/wall-time</td>
      <td width="280">5.157587351</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/opt/threads=1/instructions</td>
      <td width="280">31438678477.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/opt/threads=1/wall-time</td>
      <td width="280">5.716427422</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/check/threads=1/instructions</td>
      <td width="280">4578279220.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/check/threads=1/wall-time</td>
      <td width="280">1.008445533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/debug/threads=1/instructions</td>
      <td width="280">17017440637.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/debug/threads=1/wall-time</td>
      <td width="280">2.512299162</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/opt/threads=1/instructions</td>
      <td width="280">76364640829.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/opt/threads=1/wall-time</td>
      <td width="280">14.617769359</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/check/threads=1/instructions</td>
      <td width="280">15218432.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/check/threads=1/wall-time</td>
      <td width="280">0.033607726</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/debug/threads=1/instructions</td>
      <td width="280">437959744.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/debug/threads=1/wall-time</td>
      <td width="280">0.137041975</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/opt/threads=1/instructions</td>
      <td width="280">256743798.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/opt/threads=1/wall-time</td>
      <td width="280">0.114333481</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/check/threads=1/instructions</td>
      <td width="280">1693571003.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/check/threads=1/wall-time</td>
      <td width="280">0.400345809</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/debug/threads=1/instructions</td>
      <td width="280">2305206955.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/debug/threads=1/wall-time</td>
      <td width="280">0.451996214</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/opt/threads=1/instructions</td>
      <td width="280">3627480456.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/opt/threads=1/wall-time</td>
      <td width="280">0.662526798</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/check/threads=1/instructions</td>
      <td width="280">2012168008.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/check/threads=1/wall-time</td>
      <td width="280">0.52952173</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/debug/threads=1/instructions</td>
      <td width="280">4302779215.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/debug/threads=1/wall-time</td>
      <td width="280">0.754820205</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/opt/threads=1/instructions</td>
      <td width="280">9761827253.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/opt/threads=1/wall-time</td>
      <td width="280">2.250249442</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/check/threads=1/instructions</td>
      <td width="280">4164242376.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/check/threads=1/wall-time</td>
      <td width="280">1.006971378</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/debug/threads=1/instructions</td>
      <td width="280">23761490738.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/debug/threads=1/wall-time</td>
      <td width="280">2.541426573</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/opt/threads=1/instructions</td>
      <td width="280">198155480693.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/opt/threads=1/wall-time</td>
      <td width="280">6.612495436</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/check/threads=1/instructions</td>
      <td width="280">1474869416.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/check/threads=1/wall-time</td>
      <td width="280">0.278910252</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/debug/threads=1/instructions</td>
      <td width="280">1509822640.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/debug/threads=1/wall-time</td>
      <td width="280">0.290459642</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/opt/threads=1/instructions</td>
      <td width="280">1526340517.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/opt/threads=1/wall-time</td>
      <td width="280">0.296461452</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/check/threads=1/instructions</td>
      <td width="280">14266403269.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/check/threads=1/wall-time</td>
      <td width="280">2.937573856</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/debug/threads=1/instructions</td>
      <td width="280">15492263686.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/debug/threads=1/wall-time</td>
      <td width="280">3.172994916</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/opt/threads=1/instructions</td>
      <td width="280">21461268630.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/opt/threads=1/wall-time</td>
      <td width="280">4.258678236</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/check/threads=1/instructions</td>
      <td width="280">4606158998.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/check/threads=1/wall-time</td>
      <td width="280">1.143201255</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/debug/threads=1/instructions</td>
      <td width="280">14650386978.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/debug/threads=1/wall-time</td>
      <td width="280">1.909089451</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/opt/threads=1/instructions</td>
      <td width="280">51924145171.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/opt/threads=1/wall-time</td>
      <td width="280">2.888294534</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/check/threads=1/instructions</td>
      <td width="280">1393581242.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/check/threads=1/wall-time</td>
      <td width="280">0.368292749</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/debug/threads=1/instructions</td>
      <td width="280">16027958644.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/debug/threads=1/wall-time</td>
      <td width="280">1.869703646</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/opt/threads=1/instructions</td>
      <td width="280">80212947516.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/opt/threads=1/wall-time</td>
      <td width="280">3.362266022</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=1/instructions</td>
      <td width="280">5364151901.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=1/wall-time</td>
      <td width="280">1.115629458</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=4/instructions</td>
      <td width="280">5540220866.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=4/wall-time</td>
      <td width="280">0.719639554</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=1/instructions</td>
      <td width="280">6707189935.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=1/wall-time</td>
      <td width="280">1.257365756</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=4/instructions</td>
      <td width="280">6919209034.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=4/wall-time</td>
      <td width="280">0.828322695</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=1/instructions</td>
      <td width="280">7439521687.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=1/wall-time</td>
      <td width="280">1.405426723</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=4/instructions</td>
      <td width="280">7667126844.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=4/wall-time</td>
      <td width="280">0.901296067</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/check/threads=1/instructions</td>
      <td width="280">3540996561.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/check/threads=1/wall-time</td>
      <td width="280">0.717756511</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/debug/threads=1/instructions</td>
      <td width="280">10975413142.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/debug/threads=1/wall-time</td>
      <td width="280">1.435774771</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/opt/threads=1/instructions</td>
      <td width="280">45770076546.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/opt/threads=1/wall-time</td>
      <td width="280">2.615398811</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/check/threads=1/instructions</td>
      <td width="280">9708852248.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/check/threads=1/wall-time</td>
      <td width="280">1.891677711</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/debug/threads=1/instructions</td>
      <td width="280">10591804913.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/debug/threads=1/wall-time</td>
      <td width="280">2.098455428</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/opt/threads=1/instructions</td>
      <td width="280">11361701042.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/opt/threads=1/wall-time</td>
      <td width="280">2.223897651</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/check/threads=1/instructions</td>
      <td width="280">2640382494.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/check/threads=1/wall-time</td>
      <td width="280">0.581355364</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/debug/threads=1/instructions</td>
      <td width="280">7805737616.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/debug/threads=1/wall-time</td>
      <td width="280">0.974969477</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/opt/threads=1/instructions</td>
      <td width="280">39514429244.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/opt/threads=1/wall-time</td>
      <td width="280">1.596482164</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/check/threads=1/instructions</td>
      <td width="280">7764644258.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/check/threads=1/wall-time</td>
      <td width="280">1.849643524</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/debug/threads=1/instructions</td>
      <td width="280">16969340103.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/debug/threads=1/wall-time</td>
      <td width="280">2.653446351</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/opt/threads=1/instructions</td>
      <td width="280">33922721905.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/opt/threads=1/wall-time</td>
      <td width="280">3.360955307</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=1/instructions</td>
      <td width="280">2177296507.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=1/wall-time</td>
      <td width="280">0.357411795</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=4/instructions</td>
      <td width="280">2235461892.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=4/wall-time</td>
      <td width="280">0.262439358</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=1/instructions</td>
      <td width="280">2237403031.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=1/wall-time</td>
      <td width="280">0.37090754</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=4/instructions</td>
      <td width="280">2298136219.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=4/wall-time</td>
      <td width="280">0.263374085</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=1/instructions</td>
      <td width="280">2285350207.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=1/wall-time</td>
      <td width="280">0.376143422</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=4/instructions</td>
      <td width="280">2348574914.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=4/wall-time</td>
      <td width="280">0.266445294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/check/threads=1/instructions</td>
      <td width="280">1359838574.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/check/threads=1/wall-time</td>
      <td width="280">0.207605084</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/debug/threads=1/instructions</td>
      <td width="280">1511417883.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/debug/threads=1/wall-time</td>
      <td width="280">0.234504553</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/opt/threads=1/instructions</td>
      <td width="280">1870665893.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/opt/threads=1/wall-time</td>
      <td width="280">0.306840717</td>
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
      <td width="280">5.91545</td>
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
      <td width="280">103.818617</td>
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
      <td width="280">4.818373</td>
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
      <td width="280">0.192629</td>
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
      <td width="280">0.192619</td>
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
      <td width="280">11.421611</td>
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
      <td width="280">18.522047</td>
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
      <td width="280">5.081702</td>
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
      <td width="280">617.499741</td>
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
      <td width="280">255.502442</td>
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
      <td width="280">84.763012</td>
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
      <td width="280">157.330136</td>
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
      <td width="280">95.326676</td>
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
      <td width="280">210.067796</td>
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
      <td width="280">16.248975</td>
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
      <td width="280">6.950306</td>
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
      <td width="280">9.393728</td>
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
      <td width="280">1.774983</td>
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
      <td width="280">23.43643</td>
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
      <td width="280">586.437797</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nom-json/instructions</td>
      <td width="280">2452294998.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nom-json/wall-time</td>
      <td width="280">197.952287</td>
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
      <td width="280">234.333084</td>
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
      <td width="280">540.599013</td>
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
      <td width="280">6.14366</td>
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
      <td width="280">104.584365</td>
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
      <td width="280">0.688408</td>
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
      <td width="280">0.192609</td>
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
      <td width="280">0.192609</td>
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
      <td width="280">1.879274</td>
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
      <td width="280">4.242005</td>
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
      <td width="280">1.003007</td>
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
      <td width="280">27.155938</td>
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
      <td width="280">5.95921</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-parse-1/instructions</td>
      <td width="280">5467506613.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-parse-1/wall-time</td>
      <td width="280">490.392463</td>
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
      <td width="280">137.303344</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
