# rust 1.99.1 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`44537761889-1`

## 测试环境

### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">x86_64</th>
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
      <td width="1200">2026-11-19T14:20:04Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">x86_64</td>
    </tr>
  </tbody>
</table>

### 系统信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">x86_64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="1200">2026-11-19T14:17:30Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">x86_64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">AMD EPYC 9654 96-Core Processor</td>
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
      <td width="1200">6.6.0-132.0.0.111.oe2403sp3.x86_64</td>
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
      <td width="1200">available: 8 nodes (0-7)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215<br>node 0 size: 192620 MB<br>node 0 free: 77726 MB<br>node 1 cpus: 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239<br>node 1 size: 193523 MB<br>node 1 free: 170995 MB<br>node 2 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263<br>node 2 size: 193523 MB<br>node 2 free: 170822 MB<br>node 3 cpus: 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 3 size: 193523 MB<br>node 3 free: 171848 MB<br>node 4 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311<br>node 4 size: 193481 MB<br>node 4 free: 171984 MB<br>node 5 cpus: 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335<br>node 5 size: 193523 MB<br>node 5 free: 174012 MB<br>node 6 cpus: 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359<br>node 6 size: 193523 MB<br>node 6 free: 172743 MB<br>node 7 cpus: 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 7 size: 193455 MB<br>node 7 free: 172854 MB<br>node distances:<br>node   0   1   2   3   4   5   6   7 <br>  0:  10  12  12  12  32  32  32  32 <br>  1:  12  10  12  12  32  32  32  32 <br>  2:  12  12  10  12  32  32  32  32 <br>  3:  12  12  12  10  32  32  32  32 <br>  4:  32  32  32  32  10  12  12  12 <br>  5:  32  32  32  32  12  10  12  12 <br>  6:  32  32  32  32  12  12  10  12 <br>  7:  32  32  32  32  12  12  12  10</td>
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
      <td width="280">1392077931.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/check/threads=1/wall-time</td>
      <td width="280">0.221224373</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/debug/threads=1/instructions</td>
      <td width="280">1579731974.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/debug/threads=1/wall-time</td>
      <td width="280">0.235441622</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/opt/threads=1/instructions</td>
      <td width="280">2003031199.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/opt/threads=1/wall-time</td>
      <td width="280">0.316086199</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=1/instructions</td>
      <td width="280">25009606030.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=1/wall-time</td>
      <td width="280">5.274355418</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=4/instructions</td>
      <td width="280">25380729400.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=4/wall-time</td>
      <td width="280">2.874136276</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=1/instructions</td>
      <td width="280">149269669411.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=1/wall-time</td>
      <td width="280">14.719366524</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=4/instructions</td>
      <td width="280">150719863240.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=4/wall-time</td>
      <td width="280">10.885427433</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=1/instructions</td>
      <td width="280">674128520624.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=1/wall-time</td>
      <td width="280">21.702684251</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=4/instructions</td>
      <td width="280">675498329000.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=4/wall-time</td>
      <td width="280">16.397597518</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/check/threads=1/instructions</td>
      <td width="280">2119954976.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/check/threads=1/wall-time</td>
      <td width="280">0.372769298</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/debug/threads=1/instructions</td>
      <td width="280">5995830625.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/debug/threads=1/wall-time</td>
      <td width="280">0.638879056</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/opt/threads=1/instructions</td>
      <td width="280">42174206497.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/opt/threads=1/wall-time</td>
      <td width="280">1.615386174</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/check/threads=1/instructions</td>
      <td width="280">18728104481.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/check/threads=1/wall-time</td>
      <td width="280">3.0560602</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/debug/threads=1/instructions</td>
      <td width="280">50951454217.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/debug/threads=1/wall-time</td>
      <td width="280">5.374154753</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/opt/threads=1/instructions</td>
      <td width="280">180047275478.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/opt/threads=1/wall-time</td>
      <td width="280">10.751342466</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/check/threads=1/instructions</td>
      <td width="280">25612736874.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/check/threads=1/wall-time</td>
      <td width="280">3.860700801</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/debug/threads=1/instructions</td>
      <td width="280">29013309371.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/debug/threads=1/wall-time</td>
      <td width="280">4.309838943</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/opt/threads=1/instructions</td>
      <td width="280">32669066809.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/opt/threads=1/wall-time</td>
      <td width="280">4.80395538</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/check/threads=1/instructions</td>
      <td width="280">4664281651.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/check/threads=1/wall-time</td>
      <td width="280">0.854973881</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/debug/threads=1/instructions</td>
      <td width="280">13374737323.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/debug/threads=1/wall-time</td>
      <td width="280">1.601067495</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/opt/threads=1/instructions</td>
      <td width="280">73388826492.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/opt/threads=1/wall-time</td>
      <td width="280">11.952463106</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/check/threads=1/instructions</td>
      <td width="280">15691491.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/check/threads=1/wall-time</td>
      <td width="280">0.030501116</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/debug/threads=1/instructions</td>
      <td width="280">114242258.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/debug/threads=1/wall-time</td>
      <td width="280">0.070285052</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/opt/threads=1/instructions</td>
      <td width="280">81623496.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/opt/threads=1/wall-time</td>
      <td width="280">0.065390724</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/check/threads=1/instructions</td>
      <td width="280">1736895957.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/check/threads=1/wall-time</td>
      <td width="280">0.314248101</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/debug/threads=1/instructions</td>
      <td width="280">2313701991.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/debug/threads=1/wall-time</td>
      <td width="280">0.392888881</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/opt/threads=1/instructions</td>
      <td width="280">3692573020.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/opt/threads=1/wall-time</td>
      <td width="280">0.562673951</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/check/threads=1/instructions</td>
      <td width="280">2055391921.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/check/threads=1/wall-time</td>
      <td width="280">0.450340935</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/debug/threads=1/instructions</td>
      <td width="280">4330247244.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/debug/threads=1/wall-time</td>
      <td width="280">0.653748522</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/opt/threads=1/instructions</td>
      <td width="280">9783624015.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/opt/threads=1/wall-time</td>
      <td width="280">1.859409662</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/check/threads=1/instructions</td>
      <td width="280">4275106173.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/check/threads=1/wall-time</td>
      <td width="280">0.838458127</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/debug/threads=1/instructions</td>
      <td width="280">23375799356.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/debug/threads=1/wall-time</td>
      <td width="280">2.223989462</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/opt/threads=1/instructions</td>
      <td width="280">203008546494.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/opt/threads=1/wall-time</td>
      <td width="280">5.885893777</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/check/threads=1/instructions</td>
      <td width="280">1521499370.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/check/threads=1/wall-time</td>
      <td width="280">0.236560042</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/debug/threads=1/instructions</td>
      <td width="280">1555315407.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/debug/threads=1/wall-time</td>
      <td width="280">0.243881725</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/opt/threads=1/instructions</td>
      <td width="280">1574912388.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/opt/threads=1/wall-time</td>
      <td width="280">0.25104677</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/check/threads=1/instructions</td>
      <td width="280">14823455184.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/check/threads=1/wall-time</td>
      <td width="280">2.5085517</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/debug/threads=1/instructions</td>
      <td width="280">16100796227.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/debug/threads=1/wall-time</td>
      <td width="280">2.780169418</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/opt/threads=1/instructions</td>
      <td width="280">22033406146.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/opt/threads=1/wall-time</td>
      <td width="280">3.695912415</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/check/threads=1/instructions</td>
      <td width="280">4704012757.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/check/threads=1/wall-time</td>
      <td width="280">0.949244372</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/debug/threads=1/instructions</td>
      <td width="280">14056195138.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/debug/threads=1/wall-time</td>
      <td width="280">1.66828405</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/opt/threads=1/instructions</td>
      <td width="280">49363465960.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/opt/threads=1/wall-time</td>
      <td width="280">2.454560136</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/check/threads=1/instructions</td>
      <td width="280">1421265096.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/check/threads=1/wall-time</td>
      <td width="280">0.299607518</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/debug/threads=1/instructions</td>
      <td width="280">11985712720.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/debug/threads=1/wall-time</td>
      <td width="280">1.076191737</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/opt/threads=1/instructions</td>
      <td width="280">72991659324.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/opt/threads=1/wall-time</td>
      <td width="280">2.151363702</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=1/instructions</td>
      <td width="280">5513420393.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=1/wall-time</td>
      <td width="280">0.922489413</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=4/instructions</td>
      <td width="280">5600859821.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=4/wall-time</td>
      <td width="280">0.546117567</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=1/instructions</td>
      <td width="280">6855698827.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=1/wall-time</td>
      <td width="280">1.13335367</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=4/instructions</td>
      <td width="280">6961954448.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=4/wall-time</td>
      <td width="280">0.633580346</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=1/instructions</td>
      <td width="280">7644858230.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=1/wall-time</td>
      <td width="280">1.2769641</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=4/instructions</td>
      <td width="280">7761846675.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=4/wall-time</td>
      <td width="280">0.699122186</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/check/threads=1/instructions</td>
      <td width="280">3630005740.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/check/threads=1/wall-time</td>
      <td width="280">0.598881649</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/debug/threads=1/instructions</td>
      <td width="280">10595169146.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/debug/threads=1/wall-time</td>
      <td width="280">1.079906163</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/opt/threads=1/instructions</td>
      <td width="280">46749750134.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/opt/threads=1/wall-time</td>
      <td width="280">2.138572474</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/check/threads=1/instructions</td>
      <td width="280">9900477904.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/check/threads=1/wall-time</td>
      <td width="280">1.790725625</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/debug/threads=1/instructions</td>
      <td width="280">10804204413.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/debug/threads=1/wall-time</td>
      <td width="280">2.041210318</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/opt/threads=1/instructions</td>
      <td width="280">11588752375.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/opt/threads=1/wall-time</td>
      <td width="280">2.169245256</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/check/threads=1/instructions</td>
      <td width="280">2693529189.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/check/threads=1/wall-time</td>
      <td width="280">0.512349784</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/debug/threads=1/instructions</td>
      <td width="280">7769998340.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/debug/threads=1/wall-time</td>
      <td width="280">0.892396536</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/opt/threads=1/instructions</td>
      <td width="280">39602208216.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/opt/threads=1/wall-time</td>
      <td width="280">1.450440447</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/check/threads=1/instructions</td>
      <td width="280">7869512469.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/check/threads=1/wall-time</td>
      <td width="280">1.669444942</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/debug/threads=1/instructions</td>
      <td width="280">17031109188.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/debug/threads=1/wall-time</td>
      <td width="280">2.44931535</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/opt/threads=1/instructions</td>
      <td width="280">33800026623.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/opt/threads=1/wall-time</td>
      <td width="280">2.918238893</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=1/instructions</td>
      <td width="280">2244841779.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=1/wall-time</td>
      <td width="280">0.293428238</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=4/instructions</td>
      <td width="280">2280266777.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=4/wall-time</td>
      <td width="280">0.22617536</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=1/instructions</td>
      <td width="280">2306255233.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=1/wall-time</td>
      <td width="280">0.309701854</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=4/instructions</td>
      <td width="280">2343407041.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=4/wall-time</td>
      <td width="280">0.229872135</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=1/instructions</td>
      <td width="280">2354845336.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=1/wall-time</td>
      <td width="280">0.318191179</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=4/instructions</td>
      <td width="280">2393883961.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=4/wall-time</td>
      <td width="280">0.240594577</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/check/threads=1/instructions</td>
      <td width="280">1385440747.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/check/threads=1/wall-time</td>
      <td width="280">0.18856221</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/debug/threads=1/instructions</td>
      <td width="280">1532107687.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/debug/threads=1/wall-time</td>
      <td width="280">0.195584246</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/opt/threads=1/instructions</td>
      <td width="280">1902910420.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/opt/threads=1/wall-time</td>
      <td width="280">0.256976062</td>
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
      <td width="280">100875386.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_alloc/wall-time</td>
      <td width="280">5.453825</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_alloc_slice/instructions</td>
      <td width="280">152586338.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_alloc_slice/wall-time</td>
      <td width="280">165.128231</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_decrement/instructions</td>
      <td width="280">3500097.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_decrement/wall-time</td>
      <td width="280">1.102033</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_deref/instructions</td>
      <td width="280">1500065.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_deref/wall-time</td>
      <td width="280">0.135159</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_deref_slice/instructions</td>
      <td width="280">2000064.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_deref_slice/wall-time</td>
      <td width="280">0.135169</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_downgrade_upgrade/instructions</td>
      <td width="280">24000444.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_downgrade_upgrade/wall-time</td>
      <td width="280">2.805962</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_drop/instructions</td>
      <td width="280">58500772.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_drop/wall-time</td>
      <td width="280">3.058961</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_increment/instructions</td>
      <td width="280">8500431.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/arc_increment/wall-time</td>
      <td width="280">1.166963</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-compress/instructions</td>
      <td width="280">6480306446.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-compress/wall-time</td>
      <td width="280">494.945876</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-decompress/instructions</td>
      <td width="280">3894501893.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-decompress/wall-time</td>
      <td width="280">190.790106</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/bufreader_snappy/instructions</td>
      <td width="280">216532011.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/bufreader_snappy/wall-time</td>
      <td width="280">59.770316</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/css-parse-fb/instructions</td>
      <td width="280">1279636238.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/css-parse-fb/wall-time</td>
      <td width="280">170.792594</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/fmt-debug-derive/instructions</td>
      <td width="280">1659656592.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/fmt-debug-derive/wall-time</td>
      <td width="280">110.810309</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/fmt-write-str/instructions</td>
      <td width="280">3805258331.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/fmt-write-str/wall-time</td>
      <td width="280">235.52459</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_find_1m/instructions</td>
      <td width="280">67895382.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_find_1m/wall-time</td>
      <td width="280">16.547824</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_find_misses_1m/instructions</td>
      <td width="280">62534697.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_find_misses_1m/wall-time</td>
      <td width="280">3.986264</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_insert_1m/instructions</td>
      <td width="280">62000258.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_insert_1m/wall-time</td>
      <td width="280">15.422511</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_iterate_1m/instructions</td>
      <td width="280">23068732.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_iterate_1m/wall-time</td>
      <td width="280">1.383551</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_remove_1m/instructions</td>
      <td width="280">89915545.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/hashmap_remove_1m/wall-time</td>
      <td width="280">19.197856</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nbody_5k/instructions</td>
      <td width="280">7003518285.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nbody_5k/wall-time</td>
      <td width="280">987.529806</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nom-json/instructions</td>
      <td width="280">2663831816.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nom-json/wall-time</td>
      <td width="280">209.158428</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/pinky-nes15/instructions</td>
      <td width="280">2445018389.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/pinky-nes15/wall-time</td>
      <td width="280">246.510629</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/raytracer/instructions</td>
      <td width="280">6554158806.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/raytracer/wall-time</td>
      <td width="280">614.805017</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_alloc/instructions</td>
      <td width="280">100876229.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_alloc/wall-time</td>
      <td width="280">5.596245</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_alloc_slice/instructions</td>
      <td width="280">165586328.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_alloc_slice/wall-time</td>
      <td width="280">163.894369</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_decrement/instructions</td>
      <td width="280">3500075.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_decrement/wall-time</td>
      <td width="280">0.190378</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_deref/instructions</td>
      <td width="280">1500065.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_deref/wall-time</td>
      <td width="280">0.135159</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_deref_slice/instructions</td>
      <td width="280">2000064.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_deref_slice/wall-time</td>
      <td width="280">0.135159</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_downgrade_upgrade/instructions</td>
      <td width="280">17500108.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_downgrade_upgrade/wall-time</td>
      <td width="280">1.246392</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_drop/instructions</td>
      <td width="280">58499922.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_drop/wall-time</td>
      <td width="280">3.545687</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_increment/instructions</td>
      <td width="280">8500095.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/rc_increment/wall-time</td>
      <td width="280">0.684816</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/regex-capture-1/instructions</td>
      <td width="280">22443627.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/regex-capture-1/wall-time</td>
      <td width="280">1.506651</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/regex-search-1/instructions</td>
      <td width="280">52099224.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/regex-search-1/wall-time</td>
      <td width="280">3.829805</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-parse-1/instructions</td>
      <td width="280">5620041377.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-parse-1/wall-time</td>
      <td width="280">387.109327</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-render-1/instructions</td>
      <td width="280">1331255716.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-render-1/wall-time</td>
      <td width="280">133.187106</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
