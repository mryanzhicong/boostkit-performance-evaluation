# 性能测试汇总

- 任务总数：1
- 成功：1
- 失败：0
- 跨架构对比：0

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
      <td width="220">rust</td>
      <td width="160">1.99.1</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### rust 1.99.1

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
      <td width="600">N/A</td>
      <td width="600">1.99.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">N/A</td>
      <td width="600">1.99.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">N/A</td>
      <td width="600">2026-11-02T21:26:38Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">N/A</td>
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
      <td width="600">N/A</td>
      <td width="600">2026-11-02T21:23:46Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">N/A</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">N/A</td>
      <td width="600">Kunpeng 950 7592C To Be Filled By O.E.M. CPU @ 2.3GHz</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">N/A</td>
      <td width="600">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">N/A</td>
      <td width="600">openEuler 24.03 (LTS-SP3)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">N/A</td>
      <td width="600">6.6.0-132.0.0.111.oe2403sp3.aarch64</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="600">N/A</td>
      <td width="600">3.11.6</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="600">N/A</td>
      <td width="600">12.3.1</td>
    </tr>
    <tr>
      <td width="180">glibc 版本</td>
      <td width="600">N/A</td>
      <td width="600">glibc 2.38</td>
    </tr>
    <tr>
      <td width="180">NUMA</td>
      <td width="600">N/A</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 379562 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 385421 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387001 MB<br>node 2 free: 381248 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 384185 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">rustc-perf</td>
      <td width="880">0.1.0 (9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c)</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### aarch64

#### rust 1.99.1

##### compile

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
      <td width="280">1344592441.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/check/threads=1/wall-time</td>
      <td width="280">0.366124965</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/debug/threads=1/instructions</td>
      <td width="280">1514624634.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/debug/threads=1/wall-time</td>
      <td width="280">0.381708286</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/opt/threads=1/instructions</td>
      <td width="280">1902088657.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/opt/threads=1/wall-time</td>
      <td width="280">0.489029399</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=1/instructions</td>
      <td width="280">24349471786.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=1/wall-time</td>
      <td width="280">8.002765844</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=4/instructions</td>
      <td width="280">25165724449.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=4/wall-time</td>
      <td width="280">4.922507901</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=1/instructions</td>
      <td width="280">148145572174.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=1/wall-time</td>
      <td width="280">21.291689424</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=4/instructions</td>
      <td width="280">151294388628.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=4/wall-time</td>
      <td width="280">16.945671588</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=1/instructions</td>
      <td width="280">669217237109.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=1/wall-time</td>
      <td width="280">31.01730618</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=4/instructions</td>
      <td width="280">672030818015.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=4/wall-time</td>
      <td width="280">25.920180645</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/check/threads=1/instructions</td>
      <td width="280">2068044857.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/check/threads=1/wall-time</td>
      <td width="280">0.640888867</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/debug/threads=1/instructions</td>
      <td width="280">6640681934.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/debug/threads=1/wall-time</td>
      <td width="280">1.30436974</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/opt/threads=1/instructions</td>
      <td width="280">42175302466.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/opt/threads=1/wall-time</td>
      <td width="280">2.656147974</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/check/threads=1/instructions</td>
      <td width="280">15587822151.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/check/threads=1/wall-time</td>
      <td width="280">4.041046821</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/debug/threads=1/instructions</td>
      <td width="280">43968923283.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/debug/threads=1/wall-time</td>
      <td width="280">6.906032796</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/opt/threads=1/instructions</td>
      <td width="280">150802267910.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/opt/threads=1/wall-time</td>
      <td width="280">15.030193813</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/check/threads=1/instructions</td>
      <td width="280">24611303696.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/check/threads=1/wall-time</td>
      <td width="280">6.35387741</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/debug/threads=1/instructions</td>
      <td width="280">27898038650.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/debug/threads=1/wall-time</td>
      <td width="280">6.992978995</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/opt/threads=1/instructions</td>
      <td width="280">31438663923.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/opt/threads=1/wall-time</td>
      <td width="280">7.71347201</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/check/threads=1/instructions</td>
      <td width="280">4578267899.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/check/threads=1/wall-time</td>
      <td width="280">1.377720594</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/debug/threads=1/instructions</td>
      <td width="280">17017640694.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/debug/threads=1/wall-time</td>
      <td width="280">3.28678099</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/opt/threads=1/instructions</td>
      <td width="280">76399913211.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/opt/threads=1/wall-time</td>
      <td width="280">18.308036396</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/check/threads=1/instructions</td>
      <td width="280">15220019.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/check/threads=1/wall-time</td>
      <td width="280">0.085097556</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/debug/threads=1/instructions</td>
      <td width="280">437882904.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/debug/threads=1/wall-time</td>
      <td width="280">0.234251037</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/opt/threads=1/instructions</td>
      <td width="280">256668148.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/opt/threads=1/wall-time</td>
      <td width="280">0.197640092</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/check/threads=1/instructions</td>
      <td width="280">1693566136.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/check/threads=1/wall-time</td>
      <td width="280">0.525758183</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/debug/threads=1/instructions</td>
      <td width="280">2305204458.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/debug/threads=1/wall-time</td>
      <td width="280">0.616531918</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/opt/threads=1/instructions</td>
      <td width="280">3627475370.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/opt/threads=1/wall-time</td>
      <td width="280">0.891717105</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/check/threads=1/instructions</td>
      <td width="280">2012167342.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/check/threads=1/wall-time</td>
      <td width="280">0.74374815</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/debug/threads=1/instructions</td>
      <td width="280">4302639049.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/debug/threads=1/wall-time</td>
      <td width="280">1.003320743</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/opt/threads=1/instructions</td>
      <td width="280">9761702210.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/opt/threads=1/wall-time</td>
      <td width="280">2.834034848</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/check/threads=1/instructions</td>
      <td width="280">4164380730.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/check/threads=1/wall-time</td>
      <td width="280">1.335027351</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/debug/threads=1/instructions</td>
      <td width="280">23762929111.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/debug/threads=1/wall-time</td>
      <td width="280">3.34653682</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/opt/threads=1/instructions</td>
      <td width="280">198152116693.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/opt/threads=1/wall-time</td>
      <td width="280">8.375127663</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/check/threads=1/instructions</td>
      <td width="280">1474866852.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/check/threads=1/wall-time</td>
      <td width="280">0.392759783</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/debug/threads=1/instructions</td>
      <td width="280">1509842930.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/debug/threads=1/wall-time</td>
      <td width="280">0.407530138</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/opt/threads=1/instructions</td>
      <td width="280">1526351065.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/opt/threads=1/wall-time</td>
      <td width="280">0.414222523</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/check/threads=1/instructions</td>
      <td width="280">14266391162.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/check/threads=1/wall-time</td>
      <td width="280">3.959604871</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/debug/threads=1/instructions</td>
      <td width="280">15493288961.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/debug/threads=1/wall-time</td>
      <td width="280">4.256249549</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/opt/threads=1/instructions</td>
      <td width="280">21461282332.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/opt/threads=1/wall-time</td>
      <td width="280">5.724934738</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/check/threads=1/instructions</td>
      <td width="280">4605832858.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/check/threads=1/wall-time</td>
      <td width="280">1.496674506</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/debug/threads=1/instructions</td>
      <td width="280">14651984238.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/debug/threads=1/wall-time</td>
      <td width="280">2.534805501</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/opt/threads=1/instructions</td>
      <td width="280">51924876773.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/opt/threads=1/wall-time</td>
      <td width="280">3.811596407</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/check/threads=1/instructions</td>
      <td width="280">1393580856.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/check/threads=1/wall-time</td>
      <td width="280">0.488126002</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/debug/threads=1/instructions</td>
      <td width="280">16027493824.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/debug/threads=1/wall-time</td>
      <td width="280">2.504259543</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/opt/threads=1/instructions</td>
      <td width="280">80212891141.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/opt/threads=1/wall-time</td>
      <td width="280">4.411627596</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=1/instructions</td>
      <td width="280">5364142911.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=1/wall-time</td>
      <td width="280">1.463083909</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=4/instructions</td>
      <td width="280">5541172714.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=4/wall-time</td>
      <td width="280">1.025586261</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=1/instructions</td>
      <td width="280">6707188066.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=1/wall-time</td>
      <td width="280">1.762438936</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=4/instructions</td>
      <td width="280">6917560097.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=4/wall-time</td>
      <td width="280">1.169141442</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=1/instructions</td>
      <td width="280">7439629892.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=1/wall-time</td>
      <td width="280">1.964477372</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=4/instructions</td>
      <td width="280">7665710974.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=4/wall-time</td>
      <td width="280">1.297792838</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/check/threads=1/instructions</td>
      <td width="280">3540990032.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/check/threads=1/wall-time</td>
      <td width="280">1.023861677</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/debug/threads=1/instructions</td>
      <td width="280">10974024855.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/debug/threads=1/wall-time</td>
      <td width="280">1.969428554</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/opt/threads=1/instructions</td>
      <td width="280">45764301669.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/opt/threads=1/wall-time</td>
      <td width="280">3.430125052</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/check/threads=1/instructions</td>
      <td width="280">9708873083.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/check/threads=1/wall-time</td>
      <td width="280">2.686109883</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/debug/threads=1/instructions</td>
      <td width="280">10591809708.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/debug/threads=1/wall-time</td>
      <td width="280">2.933500392</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/opt/threads=1/instructions</td>
      <td width="280">11361698584.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/opt/threads=1/wall-time</td>
      <td width="280">3.120526333</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/check/threads=1/instructions</td>
      <td width="280">2640382334.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/check/threads=1/wall-time</td>
      <td width="280">0.848109955</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/debug/threads=1/instructions</td>
      <td width="280">7806436757.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/debug/threads=1/wall-time</td>
      <td width="280">1.381235461</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/opt/threads=1/instructions</td>
      <td width="280">39514005198.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/opt/threads=1/wall-time</td>
      <td width="280">2.218536486</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/check/threads=1/instructions</td>
      <td width="280">7764643629.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/check/threads=1/wall-time</td>
      <td width="280">2.523724452</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/debug/threads=1/instructions</td>
      <td width="280">16973084170.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/debug/threads=1/wall-time</td>
      <td width="280">3.616599845</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/opt/threads=1/instructions</td>
      <td width="280">33927087083.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/opt/threads=1/wall-time</td>
      <td width="280">4.24217733</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=1/instructions</td>
      <td width="280">2177354370.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=1/wall-time</td>
      <td width="280">0.506183405</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=4/instructions</td>
      <td width="280">2234935893.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=4/wall-time</td>
      <td width="280">0.457748254</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=1/instructions</td>
      <td width="280">2237500808.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=1/wall-time</td>
      <td width="280">0.522214786</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=4/instructions</td>
      <td width="280">2297547280.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=4/wall-time</td>
      <td width="280">0.43158084</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=1/instructions</td>
      <td width="280">2285446210.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=1/wall-time</td>
      <td width="280">0.526610689</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=4/instructions</td>
      <td width="280">2347422587.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=4/wall-time</td>
      <td width="280">0.443173337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/check/threads=1/instructions</td>
      <td width="280">1359858250.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/check/threads=1/wall-time</td>
      <td width="280">0.289064874</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/debug/threads=1/instructions</td>
      <td width="280">1511458178.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/debug/threads=1/wall-time</td>
      <td width="280">0.326870515</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/opt/threads=1/instructions</td>
      <td width="280">1870797384.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/opt/threads=1/wall-time</td>
      <td width="280">0.417550542</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### runtime

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
      <td width="280">7.604042</td>
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
      <td width="280">130.995268</td>
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
      <td width="280">5.769459</td>
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
      <td width="280">0.217569</td>
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
      <td width="280">0.217559</td>
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
      <td width="280">13.158151</td>
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
      <td width="280">22.303818</td>
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
      <td width="280">6.181897</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-compress/instructions</td>
      <td width="280">6017781655.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-compress/wall-time</td>
      <td width="280">763.727667</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-decompress/instructions</td>
      <td width="280">4120404074.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/brotli-decompress/wall-time</td>
      <td width="280">287.210382</td>
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
      <td width="280">107.958982</td>
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
      <td width="280">227.627361</td>
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
      <td width="280">135.206642</td>
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
      <td width="280">330.987361</td>
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
      <td width="280">32.49562</td>
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
      <td width="280">11.752636</td>
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
      <td width="280">14.469557</td>
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
      <td width="280">2.214452</td>
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
      <td width="280">38.106989</td>
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
      <td width="280">791.811382</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nom-json/instructions</td>
      <td width="280">2421092118.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nom-json/wall-time</td>
      <td width="280">253.507816</td>
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
      <td width="280">278.486814</td>
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
      <td width="280">776.433209</td>
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
      <td width="280">7.651942</td>
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
      <td width="280">130.710909</td>
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
      <td width="280">0.817527</td>
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
      <td width="280">0.217439</td>
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
      <td width="280">0.217399</td>
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
      <td width="280">2.366661</td>
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
      <td width="280">4.919032</td>
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
      <td width="280">1.817854</td>
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
      <td width="280">30.772397</td>
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
      <td width="280">7.377963</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-parse-1/instructions</td>
      <td width="280">5467499293.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-parse-1/wall-time</td>
      <td width="280">624.11048</td>
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
      <td width="280">185.099638</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
