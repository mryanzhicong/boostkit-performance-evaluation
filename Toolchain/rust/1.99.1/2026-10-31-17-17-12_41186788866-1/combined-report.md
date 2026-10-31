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
      <td width="600">2026-10-31T09:03:49Z</td>
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
      <td width="600">2026-10-31T09:00:58Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">N/A</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">N/A</td>
      <td width="600">-</td>
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
      <td width="600">unknown</td>
    </tr>
    <tr>
      <td width="180">glibc 版本</td>
      <td width="600">N/A</td>
      <td width="600">glibc 2.38</td>
    </tr>
    <tr>
      <td width="180">NUMA</td>
      <td width="600">N/A</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381384 MB<br>node 0 free: 379058 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387058 MB<br>node 1 free: 384186 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 381368 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 385957 MB<br>node 3 free: 383940 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="280">1344594439.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/check/threads=1/wall-time</td>
      <td width="280">0.380913144</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/debug/threads=1/instructions</td>
      <td width="280">1514629646.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/debug/threads=1/wall-time</td>
      <td width="280">0.380498535</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/opt/threads=1/instructions</td>
      <td width="280">1902073764.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/bitmaps-3.2.1/opt/threads=1/wall-time</td>
      <td width="280">0.487515659</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=1/instructions</td>
      <td width="280">24349446881.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=1/wall-time</td>
      <td width="280">8.02319524</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=4/instructions</td>
      <td width="280">25164405211.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/check/threads=4/wall-time</td>
      <td width="280">4.919889712</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=1/instructions</td>
      <td width="280">148169861842.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=1/wall-time</td>
      <td width="280">21.408325203</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=4/instructions</td>
      <td width="280">151295892551.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/debug/threads=4/wall-time</td>
      <td width="280">17.017456483</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=1/instructions</td>
      <td width="280">669258631802.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=1/wall-time</td>
      <td width="280">31.693428725</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=4/instructions</td>
      <td width="280">672106543942.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cargo-0.87.1/opt/threads=4/wall-time</td>
      <td width="280">25.900792317</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/check/threads=1/instructions</td>
      <td width="280">2068055431.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/check/threads=1/wall-time</td>
      <td width="280">0.650254751</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/debug/threads=1/instructions</td>
      <td width="280">6636990952.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/debug/threads=1/wall-time</td>
      <td width="280">1.327938048</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/opt/threads=1/instructions</td>
      <td width="280">42170888646.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/clap_derive-4.5.32/opt/threads=1/wall-time</td>
      <td width="280">2.642718667</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/check/threads=1/instructions</td>
      <td width="280">15587941348.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/check/threads=1/wall-time</td>
      <td width="280">4.016983419</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/debug/threads=1/instructions</td>
      <td width="280">43964130176.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/debug/threads=1/wall-time</td>
      <td width="280">6.890949568</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/opt/threads=1/instructions</td>
      <td width="280">150765057584.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/cranelift-codegen-0.119.0/opt/threads=1/wall-time</td>
      <td width="280">14.959054137</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/check/threads=1/instructions</td>
      <td width="280">24611291449.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/check/threads=1/wall-time</td>
      <td width="280">6.297007664</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/debug/threads=1/instructions</td>
      <td width="280">27898048765.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/debug/threads=1/wall-time</td>
      <td width="280">6.939665913</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/opt/threads=1/instructions</td>
      <td width="280">31437823154.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/diesel-2.2.10/opt/threads=1/wall-time</td>
      <td width="280">7.673061149</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/check/threads=1/instructions</td>
      <td width="280">4578234944.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/check/threads=1/wall-time</td>
      <td width="280">1.416382932</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/debug/threads=1/instructions</td>
      <td width="280">17017339231.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/debug/threads=1/wall-time</td>
      <td width="280">3.300762179</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/opt/threads=1/instructions</td>
      <td width="280">76403226851.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/eza-0.21.2/opt/threads=1/wall-time</td>
      <td width="280">18.27201897</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/check/threads=1/instructions</td>
      <td width="280">15222826.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/check/threads=1/wall-time</td>
      <td width="280">0.087198749</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/debug/threads=1/instructions</td>
      <td width="280">437886131.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/debug/threads=1/wall-time</td>
      <td width="280">0.225622334</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/opt/threads=1/instructions</td>
      <td width="280">256658070.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/helloworld/opt/threads=1/wall-time</td>
      <td width="280">0.208840257</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/check/threads=1/instructions</td>
      <td width="280">1693567899.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/check/threads=1/wall-time</td>
      <td width="280">0.52679083</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/debug/threads=1/instructions</td>
      <td width="280">2305207527.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/debug/threads=1/wall-time</td>
      <td width="280">0.610038594</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/opt/threads=1/instructions</td>
      <td width="280">3627669454.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/html5ever-0.31.0/opt/threads=1/wall-time</td>
      <td width="280">0.867263287</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/check/threads=1/instructions</td>
      <td width="280">2012176465.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/check/threads=1/wall-time</td>
      <td width="280">0.704681305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/debug/threads=1/instructions</td>
      <td width="280">4302652200.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/debug/threads=1/wall-time</td>
      <td width="280">1.001830757</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/opt/threads=1/instructions</td>
      <td width="280">9761703105.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/hyper-1.6.0/opt/threads=1/wall-time</td>
      <td width="280">2.806815564</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/check/threads=1/instructions</td>
      <td width="280">4164387162.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/check/threads=1/wall-time</td>
      <td width="280">1.335896388</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/debug/threads=1/instructions</td>
      <td width="280">23753024298.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/debug/threads=1/wall-time</td>
      <td width="280">3.333150245</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/opt/threads=1/instructions</td>
      <td width="280">198145734305.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/image-0.25.6/opt/threads=1/wall-time</td>
      <td width="280">8.322823652</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/check/threads=1/instructions</td>
      <td width="280">1474873638.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/check/threads=1/wall-time</td>
      <td width="280">0.391372144</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/debug/threads=1/instructions</td>
      <td width="280">1509846645.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/debug/threads=1/wall-time</td>
      <td width="280">0.404451545</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/opt/threads=1/instructions</td>
      <td width="280">1526355352.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/libc-0.2.172/opt/threads=1/wall-time</td>
      <td width="280">0.409205917</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/check/threads=1/instructions</td>
      <td width="280">14266390312.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/check/threads=1/wall-time</td>
      <td width="280">3.925405517</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/debug/threads=1/instructions</td>
      <td width="280">15492851963.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/debug/threads=1/wall-time</td>
      <td width="280">4.249143598</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/opt/threads=1/instructions</td>
      <td width="280">21461281173.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/nalgebra-0.33.0/opt/threads=1/wall-time</td>
      <td width="280">5.646935882</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/check/threads=1/instructions</td>
      <td width="280">4605850273.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/check/threads=1/wall-time</td>
      <td width="280">1.462118279</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/debug/threads=1/instructions</td>
      <td width="280">14652704421.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/debug/threads=1/wall-time</td>
      <td width="280">2.541448761</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/opt/threads=1/instructions</td>
      <td width="280">51926584883.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/regex-automata-0.4.8/opt/threads=1/wall-time</td>
      <td width="280">3.774122631</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/check/threads=1/instructions</td>
      <td width="280">1393576464.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/check/threads=1/wall-time</td>
      <td width="280">0.523610962</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/debug/threads=1/instructions</td>
      <td width="280">16030239656.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/debug/threads=1/wall-time</td>
      <td width="280">2.474701064</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/opt/threads=1/instructions</td>
      <td width="280">80216102900.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/ripgrep-14.1.1/opt/threads=1/wall-time</td>
      <td width="280">4.385522131</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=1/instructions</td>
      <td width="280">5364139274.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=1/wall-time</td>
      <td width="280">1.463191745</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=4/instructions</td>
      <td width="280">5540479895.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/check/threads=4/wall-time</td>
      <td width="280">1.021628781</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=1/instructions</td>
      <td width="280">6707219687.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=1/wall-time</td>
      <td width="280">1.768455986</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=4/instructions</td>
      <td width="280">6917099507.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/debug/threads=4/wall-time</td>
      <td width="280">1.20893872</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=1/instructions</td>
      <td width="280">7439587621.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=1/wall-time</td>
      <td width="280">1.931652756</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=4/instructions</td>
      <td width="280">7667709453.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde-1.0.219/opt/threads=4/wall-time</td>
      <td width="280">1.299430667</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/check/threads=1/instructions</td>
      <td width="280">3540984110.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/check/threads=1/wall-time</td>
      <td width="280">1.023960893</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/debug/threads=1/instructions</td>
      <td width="280">10974505396.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/debug/threads=1/wall-time</td>
      <td width="280">2.000801444</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/opt/threads=1/instructions</td>
      <td width="280">45769322797.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/serde_derive-1.0.219/opt/threads=1/wall-time</td>
      <td width="280">3.428477654</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/check/threads=1/instructions</td>
      <td width="280">9708870898.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/check/threads=1/wall-time</td>
      <td width="280">2.64965457</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/debug/threads=1/instructions</td>
      <td width="280">10591812062.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/debug/threads=1/wall-time</td>
      <td width="280">2.90544814</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/opt/threads=1/instructions</td>
      <td width="280">11361699247.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/stm32f4-0.15.1/opt/threads=1/wall-time</td>
      <td width="280">3.082532827</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/check/threads=1/instructions</td>
      <td width="280">2640381046.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/check/threads=1/wall-time</td>
      <td width="280">0.872766296</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/debug/threads=1/instructions</td>
      <td width="280">7805890272.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/debug/threads=1/wall-time</td>
      <td width="280">1.386907535</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/opt/threads=1/instructions</td>
      <td width="280">39515699386.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/syn-2.0.101/opt/threads=1/wall-time</td>
      <td width="280">2.122626401</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/check/threads=1/instructions</td>
      <td width="280">7764645620.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/check/threads=1/wall-time</td>
      <td width="280">2.54718915</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/debug/threads=1/instructions</td>
      <td width="280">16971058339.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/debug/threads=1/wall-time</td>
      <td width="280">3.612373145</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/opt/threads=1/instructions</td>
      <td width="280">33925221572.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/tokio-1.53.1/opt/threads=1/wall-time</td>
      <td width="280">4.229308234</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=1/instructions</td>
      <td width="280">2177359864.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=1/wall-time</td>
      <td width="280">0.565686922</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=4/instructions</td>
      <td width="280">2235075734.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/check/threads=4/wall-time</td>
      <td width="280">0.452305502</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=1/instructions</td>
      <td width="280">2237486321.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=1/wall-time</td>
      <td width="280">0.547344352</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=4/instructions</td>
      <td width="280">2297577909.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/debug/threads=4/wall-time</td>
      <td width="280">0.44788848</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=1/instructions</td>
      <td width="280">2285434145.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=1/wall-time</td>
      <td width="280">0.52666182</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=4/instructions</td>
      <td width="280">2348127235.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/typenum-1.18.0/opt/threads=4/wall-time</td>
      <td width="280">0.443545986</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/check/threads=1/instructions</td>
      <td width="280">1359858662.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/check/threads=1/wall-time</td>
      <td width="280">0.300816978</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/debug/threads=1/instructions</td>
      <td width="280">1511460487.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/debug/threads=1/wall-time</td>
      <td width="280">0.338372635</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/opt/threads=1/instructions</td>
      <td width="280">1870800382.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">compile/unicode-normalization-0.1.24/opt/threads=1/wall-time</td>
      <td width="280">0.451895844</td>
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
      <td width="280">7.586841</td>
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
      <td width="280">134.013721</td>
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
      <td width="280">5.773798</td>
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
      <td width="280">0.217089</td>
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
      <td width="280">0.217159</td>
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
      <td width="280">12.937691</td>
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
      <td width="280">22.305485</td>
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
      <td width="280">6.180506</td>
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
      <td width="280">763.502961</td>
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
      <td width="280">287.125</td>
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
      <td width="280">107.797271</td>
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
      <td width="280">227.558127</td>
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
      <td width="280">138.405904</td>
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
      <td width="280">331.596151</td>
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
      <td width="280">35.144907</td>
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
      <td width="280">11.734396</td>
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
      <td width="280">14.503645</td>
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
      <td width="280">2.225242</td>
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
      <td width="280">36.625151</td>
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
      <td width="280">791.877934</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nom-json/instructions</td>
      <td width="280">2421023076.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/nom-json/wall-time</td>
      <td width="280">252.408302</td>
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
      <td width="280">281.76092</td>
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
      <td width="280">776.891461</td>
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
      <td width="280">7.710831</td>
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
      <td width="280">136.468582</td>
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
      <td width="280">0.818797</td>
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
      <td width="280">0.2171</td>
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
      <td width="280">0.21721</td>
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
      <td width="280">2.183372</td>
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
      <td width="280">4.790622</td>
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
      <td width="280">1.800783</td>
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
      <td width="280">30.844023</td>
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
      <td width="280">7.361482</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-parse-1/instructions</td>
      <td width="280">5467512865.0</td>
      <td width="200">instructions</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">runtime/svg-parse-1/wall-time</td>
      <td width="280">623.630662</td>
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
      <td width="280">185.297627</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
