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
      <td width="160">3.14.7</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">python</td>
      <td width="160">3.14.7</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### python 3.14.7

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
      <td width="600">3.14.7</td>
      <td width="600">3.14.7</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">3.14.7</td>
      <td width="600">3.14.7</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-10-11T00:33:36Z</td>
      <td width="600">2026-10-11T00:34:29Z</td>
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
      <td width="600">2026-10-11T00:30:17Z</td>
      <td width="600">2026-10-11T00:30:40Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 574945 MB<br>node 0 free: 353231 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 580594 MB<br>node 1 free: 419618 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 580594 MB<br>node 2 free: 432008 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 482782 MB<br>node 3 free: 330064 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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

#### python 3.14.7

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
      <td width="280">0.1937968814963824</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">many_optionals</td>
      <td width="280">0.0006084000761745756</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">subparsers</td>
      <td width="280">0.007564138718862523</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_generators</td>
      <td width="280">0.2888848875008989</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_none</td>
      <td width="280">0.2404618419968756</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_cpu_io_mixed</td>
      <td width="280">0.43477253449964337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_cpu_io_mixed_tg</td>
      <td width="280">0.4301598015008494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager</td>
      <td width="280">0.08194169575290289</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_cpu_io_mixed</td>
      <td width="280">0.32140030700247735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_cpu_io_mixed_tg</td>
      <td width="280">0.40867323899874464</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_io</td>
      <td width="280">0.6138383120051003</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_io_tg</td>
      <td width="280">0.6656392320073792</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_memoization</td>
      <td width="280">0.17341441099415533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_memoization_tg</td>
      <td width="280">0.27663599350489676</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_tg</td>
      <td width="280">0.2140117704984732</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_io</td>
      <td width="280">0.6083079620002536</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_io_tg</td>
      <td width="280">0.6426493725011824</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_memoization</td>
      <td width="280">0.2946225734995096</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_memoization_tg</td>
      <td width="280">0.3060687620018143</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_none_tg</td>
      <td width="280">0.23767856000631582</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_tcp</td>
      <td width="280">0.2346557334967656</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_tcp_ssl</td>
      <td width="280">1.0643831080014934</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_websockets</td>
      <td width="280">0.49585594050586224</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bpe_tokeniser</td>
      <td width="280">3.285662616501213</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">chameleon</td>
      <td width="280">0.010304481249931996</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">chaos</td>
      <td width="280">0.0406112141245103</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">comprehensions</td>
      <td width="280">1.2217828766036831e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_mp_pool</td>
      <td width="280">0.05713268762519874</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_thread_pool</td>
      <td width="280">0.0010906145233775533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">coroutines</td>
      <td width="280">0.0175512921250629</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">coverage</td>
      <td width="280">0.05502366375003476</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">crypto_pyaes</td>
      <td width="280">0.05205032374942675</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">dask</td>
      <td width="280">0.4724363019995508</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy</td>
      <td width="280">0.00019973076148005475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy_reduce</td>
      <td width="280">2.1361780014883536e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy_memo</td>
      <td width="280">2.2122353516174087e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deltablue</td>
      <td width="280">0.0023325033438368337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">django_template</td>
      <td width="280">0.026465418752195546</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">docutils</td>
      <td width="280">1.7510793485489557</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">dulwich_log</td>
      <td width="280">0.03282284399938362</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fannkuch</td>
      <td width="280">0.26965672399819596</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">float</td>
      <td width="280">0.050374693873891374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">create_gc_cycles</td>
      <td width="280">0.001575139788656088</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gc_traversal</td>
      <td width="280">0.0030440913827760596</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">generators</td>
      <td width="280">0.022210613749848562</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">genshi_text</td>
      <td width="280">0.017027854687512445</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">genshi_xml</td>
      <td width="280">0.039004123500490095</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">go</td>
      <td width="280">0.0867287450018921</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hexiom</td>
      <td width="280">0.0044202290155226365</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">html5lib</td>
      <td width="280">0.04255041100077506</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">json_dumps</td>
      <td width="280">0.007655249531126174</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">json_loads</td>
      <td width="280">1.724170400407843e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_format</td>
      <td width="280">4.987791503907602e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_silent</td>
      <td width="280">7.263747978103474e-08</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_simple</td>
      <td width="280">4.542137902596721e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mako</td>
      <td width="280">0.008911094968880207</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mdp</td>
      <td width="280">0.9076510999948368</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">meteor_contest</td>
      <td width="280">0.07917650300078094</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nbody</td>
      <td width="280">0.07420662674849154</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">shortest_path</td>
      <td width="280">0.37066771399986465</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">connected_components</td>
      <td width="280">0.3541623319979408</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">k_core</td>
      <td width="280">1.8658915615014848</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nqueens</td>
      <td width="280">0.06223942599535803</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pathlib</td>
      <td width="280">0.016220308312767884</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle</td>
      <td width="280">8.533387255837967e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_dict</td>
      <td width="280">2.048623759804968e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_list</td>
      <td width="280">3.4950781616416297e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_pure_python</td>
      <td width="280">0.0002330220085923429</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pidigits</td>
      <td width="280">0.1673008045036113</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pprint_safe_repr</td>
      <td width="280">0.5434452440022142</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pprint_pformat</td>
      <td width="280">1.111418220003543</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pyflate</td>
      <td width="280">0.3154637725019711</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">python_startup</td>
      <td width="280">0.010815944124715315</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">python_startup_no_site</td>
      <td width="280">0.006368060531258379</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">raytrace</td>
      <td width="280">0.18831041199882748</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_compile</td>
      <td width="280">0.0778451469996071</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_dna</td>
      <td width="280">0.14586239949858282</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_effbot</td>
      <td width="280">0.0022065439562538812</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_v8</td>
      <td width="280">0.01775382362484379</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">richards</td>
      <td width="280">0.03178223712529871</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">richards_super</td>
      <td width="280">0.03623623199928261</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_fft</td>
      <td width="280">0.25610569650598336</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_lu</td>
      <td width="280">0.08218339599989122</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_monte_carlo</td>
      <td width="280">0.04912392174992419</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_sor</td>
      <td width="280">0.08817394400102785</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_sparse_mat_mult</td>
      <td width="280">0.004200509421934839</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">spectral_norm</td>
      <td width="280">0.07431616574831423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sphinx</td>
      <td width="280">0.7731315040000482</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlalchemy_declarative</td>
      <td width="280">0.08286319350008853</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlalchemy_imperative</td>
      <td width="280">0.008068227249623305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_normalize</td>
      <td width="280">0.07679850924978382</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_optimize</td>
      <td width="280">0.037221973872874514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_parse</td>
      <td width="280">0.0009159811719996469</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_transpile</td>
      <td width="280">0.0011492262266301623</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlite_synth</td>
      <td width="280">1.7601318892390694e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_expand</td>
      <td width="280">0.2852309429945308</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_integrate</td>
      <td width="280">0.013567699066697969</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_sum</td>
      <td width="280">0.08949847424810287</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_str</td>
      <td width="280">0.164689871497103</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">telco</td>
      <td width="280">0.005631715375102431</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">tomli_loads</td>
      <td width="280">1.6077207060006913</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">tornado_http</td>
      <td width="280">0.08628957349719713</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">typing_runtime_protocols</td>
      <td width="280">0.00011712297900601243</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpack_sequence</td>
      <td width="280">3.683516906827222e-08</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle</td>
      <td width="280">1.0063152392802975e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle_list</td>
      <td width="280">3.2906743408389618e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle_pure_python</td>
      <td width="280">0.00016027900469453015</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xdsl_constant_fold</td>
      <td width="280">0.025648352499047178</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_parse</td>
      <td width="280">0.10137063499860233</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_iterparse</td>
      <td width="280">0.06384371099920827</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_generate</td>
      <td width="280">0.06258954149961937</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_process</td>
      <td width="280">0.04440150287337019</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### python 3.14.7

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
      <td width="280">0.2072165749850683</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">many_optionals</td>
      <td width="280">0.000604124785240856</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">subparsers</td>
      <td width="280">0.007659667498955969</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_generators</td>
      <td width="280">0.30020021001109853</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_none</td>
      <td width="280">0.23357344005489722</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_cpu_io_mixed</td>
      <td width="280">0.456909789936617</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_cpu_io_mixed_tg</td>
      <td width="280">0.45353624504059553</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager</td>
      <td width="280">0.07777171250199899</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_cpu_io_mixed</td>
      <td width="280">0.34740040998440236</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_cpu_io_mixed_tg</td>
      <td width="280">0.4289575050352141</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_io</td>
      <td width="280">0.5789555849623866</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_io_tg</td>
      <td width="280">0.6131204049452208</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_memoization</td>
      <td width="280">0.17646212497493252</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_memoization_tg</td>
      <td width="280">0.2639162000268698</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_tg</td>
      <td width="280">0.21373527502873912</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_io</td>
      <td width="280">0.6199355600401759</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_io_tg</td>
      <td width="280">0.6163282149354927</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_memoization</td>
      <td width="280">0.2862549699493684</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_memoization_tg</td>
      <td width="280">0.2980603499454446</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_none_tg</td>
      <td width="280">0.2294868000317365</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_tcp</td>
      <td width="280">0.2717533599352464</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_tcp_ssl</td>
      <td width="280">1.1988973900442943</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_websockets</td>
      <td width="280">0.5423515200382099</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bpe_tokeniser</td>
      <td width="280">4.080720999918412</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">chameleon</td>
      <td width="280">0.010331684061384294</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">chaos</td>
      <td width="280">0.04851946124108508</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">comprehensions</td>
      <td width="280">1.3830354603783235e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_mp_pool</td>
      <td width="280">0.0690482199715916</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_thread_pool</td>
      <td width="280">0.0010150714451810927</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">coroutines</td>
      <td width="280">0.021408766879176255</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">coverage</td>
      <td width="280">0.07354966248385608</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">crypto_pyaes</td>
      <td width="280">0.06488624998019077</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">dask</td>
      <td width="280">0.48052722500870004</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy</td>
      <td width="280">0.00019056683510143557</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy_reduce</td>
      <td width="280">1.993966445290596e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy_memo</td>
      <td width="280">2.2546318355409767e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deltablue</td>
      <td width="280">0.0025953128133551218</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">django_template</td>
      <td width="280">0.02715538500342518</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">docutils</td>
      <td width="280">1.8522889097221196</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">dulwich_log</td>
      <td width="280">0.03131059999577701</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fannkuch</td>
      <td width="280">0.3212521850364283</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">float</td>
      <td width="280">0.06201093251002021</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">create_gc_cycles</td>
      <td width="280">0.0022903839044374763</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gc_traversal</td>
      <td width="280">0.004191726240605931</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">generators</td>
      <td width="280">0.029673172495677136</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">genshi_text</td>
      <td width="280">0.017688688756607007</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">genshi_xml</td>
      <td width="280">0.03746698625036515</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">go</td>
      <td width="280">0.09157456748653203</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hexiom</td>
      <td width="280">0.0049063942169595975</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">html5lib</td>
      <td width="280">0.039463120003347285</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">json_dumps</td>
      <td width="280">0.007923862187453778</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">json_loads</td>
      <td width="280">2.1208963858043717e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_format</td>
      <td width="280">4.8048491208874115e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_silent</td>
      <td width="280">8.705588148139042e-08</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_simple</td>
      <td width="280">4.413369384792532e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mako</td>
      <td width="280">0.008999086559924763</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mdp</td>
      <td width="280">1.0261909349937923</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">meteor_contest</td>
      <td width="280">0.08675520250108093</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nbody</td>
      <td width="280">0.08942872501211241</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">shortest_path</td>
      <td width="280">0.39659378497162834</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">connected_components</td>
      <td width="280">0.36734799499390647</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">k_core</td>
      <td width="280">2.011543519969564</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nqueens</td>
      <td width="280">0.06802388248615898</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pathlib</td>
      <td width="280">0.011987698751909193</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle</td>
      <td width="280">8.492680422023113e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_dict</td>
      <td width="280">2.3491712886425377e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_list</td>
      <td width="280">3.8407083735592096e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_pure_python</td>
      <td width="280">0.00024113673443935114</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pidigits</td>
      <td width="280">0.2210028949775733</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pprint_safe_repr</td>
      <td width="280">0.5280383400386199</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pprint_pformat</td>
      <td width="280">1.0865615850198083</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pyflate</td>
      <td width="280">0.37278194003738463</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">python_startup</td>
      <td width="280">0.011257740312430542</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">python_startup_no_site</td>
      <td width="280">0.00675243187288288</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">raytrace</td>
      <td width="280">0.22380944498581812</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_compile</td>
      <td width="280">0.08377706000464968</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_dna</td>
      <td width="280">0.1506809850106947</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_effbot</td>
      <td width="280">0.0023450193752069023</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_v8</td>
      <td width="280">0.017901338746014517</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">richards</td>
      <td width="280">0.03640123375225812</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">richards_super</td>
      <td width="280">0.041392266255570576</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_fft</td>
      <td width="280">0.26901588001055643</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_lu</td>
      <td width="280">0.09940030000871047</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_monte_carlo</td>
      <td width="280">0.05415373749565333</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_sor</td>
      <td width="280">0.09491706502740271</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_sparse_mat_mult</td>
      <td width="280">0.004379986563435523</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">spectral_norm</td>
      <td width="280">0.09285055252257735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sphinx</td>
      <td width="280">0.8021337600657716</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlalchemy_declarative</td>
      <td width="280">0.09217313752742484</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlalchemy_imperative</td>
      <td width="280">0.009569823116180487</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_normalize</td>
      <td width="280">0.08017551497323439</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_optimize</td>
      <td width="280">0.040698281285585836</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_parse</td>
      <td width="280">0.00095406378250118</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_transpile</td>
      <td width="280">0.0012210611293994589</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlite_synth</td>
      <td width="280">1.6710652150919714e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_expand</td>
      <td width="280">0.3046102650114335</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_integrate</td>
      <td width="280">0.014389080635737628</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_sum</td>
      <td width="280">0.09819639500346966</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_str</td>
      <td width="280">0.1807795200147666</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">telco</td>
      <td width="280">0.005572494217631174</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">tomli_loads</td>
      <td width="280">1.6951442050049081</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">tornado_http</td>
      <td width="280">0.08699277002597228</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">typing_runtime_protocols</td>
      <td width="280">0.000127559194368132</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpack_sequence</td>
      <td width="280">3.530234526039066e-08</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle</td>
      <td width="280">1.1390831542712476e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle_list</td>
      <td width="280">4.683183350095988e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle_pure_python</td>
      <td width="280">0.00017277294527957566</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xdsl_constant_fold</td>
      <td width="280">0.02867492249060888</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_parse</td>
      <td width="280">0.12777634506346658</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_iterparse</td>
      <td width="280">0.08447786996839568</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_generate</td>
      <td width="280">0.06798335001803935</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_process</td>
      <td width="280">0.04895283000951167</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### python 3.14.7

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
      <td width="190">0.1937968814963824</td>
      <td width="190">0.2072165749850683</td>
      <td width="360">0.9352</td>
    </tr>
    <tr>
      <td width="450">many_optionals</td>
      <td width="190">越小越好</td>
      <td width="190">0.0006084000761745756</td>
      <td width="190">0.000604124785240856</td>
      <td width="360">1.0071</td>
    </tr>
    <tr>
      <td width="450">subparsers</td>
      <td width="190">越小越好</td>
      <td width="190">0.007564138718862523</td>
      <td width="190">0.007659667498955969</td>
      <td width="360">0.9875</td>
    </tr>
    <tr>
      <td width="450">async_generators</td>
      <td width="190">越小越好</td>
      <td width="190">0.2888848875008989</td>
      <td width="190">0.30020021001109853</td>
      <td width="360">0.9623</td>
    </tr>
    <tr>
      <td width="450">async_tree_none</td>
      <td width="190">越小越好</td>
      <td width="190">0.2404618419968756</td>
      <td width="190">0.23357344005489722</td>
      <td width="360">1.0295</td>
    </tr>
    <tr>
      <td width="450">async_tree_cpu_io_mixed</td>
      <td width="190">越小越好</td>
      <td width="190">0.43477253449964337</td>
      <td width="190">0.456909789936617</td>
      <td width="360">0.9516</td>
    </tr>
    <tr>
      <td width="450">async_tree_cpu_io_mixed_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.4301598015008494</td>
      <td width="190">0.45353624504059553</td>
      <td width="360">0.9485</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager</td>
      <td width="190">越小越好</td>
      <td width="190">0.08194169575290289</td>
      <td width="190">0.07777171250199899</td>
      <td width="360">1.0536</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_cpu_io_mixed</td>
      <td width="190">越小越好</td>
      <td width="190">0.32140030700247735</td>
      <td width="190">0.34740040998440236</td>
      <td width="360">0.9252</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_cpu_io_mixed_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.40867323899874464</td>
      <td width="190">0.4289575050352141</td>
      <td width="360">0.9527</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_io</td>
      <td width="190">越小越好</td>
      <td width="190">0.6138383120051003</td>
      <td width="190">0.5789555849623866</td>
      <td width="360">1.0603</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_io_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.6656392320073792</td>
      <td width="190">0.6131204049452208</td>
      <td width="360">1.0857</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_memoization</td>
      <td width="190">越小越好</td>
      <td width="190">0.17341441099415533</td>
      <td width="190">0.17646212497493252</td>
      <td width="360">0.9827</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_memoization_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.27663599350489676</td>
      <td width="190">0.2639162000268698</td>
      <td width="360">1.0482</td>
    </tr>
    <tr>
      <td width="450">async_tree_eager_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.2140117704984732</td>
      <td width="190">0.21373527502873912</td>
      <td width="360">1.0013</td>
    </tr>
    <tr>
      <td width="450">async_tree_io</td>
      <td width="190">越小越好</td>
      <td width="190">0.6083079620002536</td>
      <td width="190">0.6199355600401759</td>
      <td width="360">0.9812</td>
    </tr>
    <tr>
      <td width="450">async_tree_io_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.6426493725011824</td>
      <td width="190">0.6163282149354927</td>
      <td width="360">1.0427</td>
    </tr>
    <tr>
      <td width="450">async_tree_memoization</td>
      <td width="190">越小越好</td>
      <td width="190">0.2946225734995096</td>
      <td width="190">0.2862549699493684</td>
      <td width="360">1.0292</td>
    </tr>
    <tr>
      <td width="450">async_tree_memoization_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.3060687620018143</td>
      <td width="190">0.2980603499454446</td>
      <td width="360">1.0269</td>
    </tr>
    <tr>
      <td width="450">async_tree_none_tg</td>
      <td width="190">越小越好</td>
      <td width="190">0.23767856000631582</td>
      <td width="190">0.2294868000317365</td>
      <td width="360">1.0357</td>
    </tr>
    <tr>
      <td width="450">asyncio_tcp</td>
      <td width="190">越小越好</td>
      <td width="190">0.2346557334967656</td>
      <td width="190">0.2717533599352464</td>
      <td width="360">0.8635</td>
    </tr>
    <tr>
      <td width="450">asyncio_tcp_ssl</td>
      <td width="190">越小越好</td>
      <td width="190">1.0643831080014934</td>
      <td width="190">1.1988973900442943</td>
      <td width="360">0.8878</td>
    </tr>
    <tr>
      <td width="450">asyncio_websockets</td>
      <td width="190">越小越好</td>
      <td width="190">0.49585594050586224</td>
      <td width="190">0.5423515200382099</td>
      <td width="360">0.9143</td>
    </tr>
    <tr>
      <td width="450">bpe_tokeniser</td>
      <td width="190">越小越好</td>
      <td width="190">3.285662616501213</td>
      <td width="190">4.080720999918412</td>
      <td width="360">0.8052</td>
    </tr>
    <tr>
      <td width="450">chameleon</td>
      <td width="190">越小越好</td>
      <td width="190">0.010304481249931996</td>
      <td width="190">0.010331684061384294</td>
      <td width="360">0.9974</td>
    </tr>
    <tr>
      <td width="450">chaos</td>
      <td width="190">越小越好</td>
      <td width="190">0.0406112141245103</td>
      <td width="190">0.04851946124108508</td>
      <td width="360">0.837</td>
    </tr>
    <tr>
      <td width="450">comprehensions</td>
      <td width="190">越小越好</td>
      <td width="190">1.2217828766036831e-05</td>
      <td width="190">1.3830354603783235e-05</td>
      <td width="360">0.8834</td>
    </tr>
    <tr>
      <td width="450">bench_mp_pool</td>
      <td width="190">越小越好</td>
      <td width="190">0.05713268762519874</td>
      <td width="190">0.0690482199715916</td>
      <td width="360">0.8274</td>
    </tr>
    <tr>
      <td width="450">bench_thread_pool</td>
      <td width="190">越小越好</td>
      <td width="190">0.0010906145233775533</td>
      <td width="190">0.0010150714451810927</td>
      <td width="360">1.0744</td>
    </tr>
    <tr>
      <td width="450">coroutines</td>
      <td width="190">越小越好</td>
      <td width="190">0.0175512921250629</td>
      <td width="190">0.021408766879176255</td>
      <td width="360">0.8198</td>
    </tr>
    <tr>
      <td width="450">coverage</td>
      <td width="190">越小越好</td>
      <td width="190">0.05502366375003476</td>
      <td width="190">0.07354966248385608</td>
      <td width="360">0.7481</td>
    </tr>
    <tr>
      <td width="450">crypto_pyaes</td>
      <td width="190">越小越好</td>
      <td width="190">0.05205032374942675</td>
      <td width="190">0.06488624998019077</td>
      <td width="360">0.8022</td>
    </tr>
    <tr>
      <td width="450">dask</td>
      <td width="190">越小越好</td>
      <td width="190">0.4724363019995508</td>
      <td width="190">0.48052722500870004</td>
      <td width="360">0.9832</td>
    </tr>
    <tr>
      <td width="450">deepcopy</td>
      <td width="190">越小越好</td>
      <td width="190">0.00019973076148005475</td>
      <td width="190">0.00019056683510143557</td>
      <td width="360">1.0481</td>
    </tr>
    <tr>
      <td width="450">deepcopy_reduce</td>
      <td width="190">越小越好</td>
      <td width="190">2.1361780014883536e-06</td>
      <td width="190">1.993966445290596e-06</td>
      <td width="360">1.0713</td>
    </tr>
    <tr>
      <td width="450">deepcopy_memo</td>
      <td width="190">越小越好</td>
      <td width="190">2.2122353516174087e-05</td>
      <td width="190">2.2546318355409767e-05</td>
      <td width="360">0.9812</td>
    </tr>
    <tr>
      <td width="450">deltablue</td>
      <td width="190">越小越好</td>
      <td width="190">0.0023325033438368337</td>
      <td width="190">0.0025953128133551218</td>
      <td width="360">0.8987</td>
    </tr>
    <tr>
      <td width="450">django_template</td>
      <td width="190">越小越好</td>
      <td width="190">0.026465418752195546</td>
      <td width="190">0.02715538500342518</td>
      <td width="360">0.9746</td>
    </tr>
    <tr>
      <td width="450">docutils</td>
      <td width="190">越小越好</td>
      <td width="190">1.7510793485489557</td>
      <td width="190">1.8522889097221196</td>
      <td width="360">0.9454</td>
    </tr>
    <tr>
      <td width="450">dulwich_log</td>
      <td width="190">越小越好</td>
      <td width="190">0.03282284399938362</td>
      <td width="190">0.03131059999577701</td>
      <td width="360">1.0483</td>
    </tr>
    <tr>
      <td width="450">fannkuch</td>
      <td width="190">越小越好</td>
      <td width="190">0.26965672399819596</td>
      <td width="190">0.3212521850364283</td>
      <td width="360">0.8394</td>
    </tr>
    <tr>
      <td width="450">float</td>
      <td width="190">越小越好</td>
      <td width="190">0.050374693873891374</td>
      <td width="190">0.06201093251002021</td>
      <td width="360">0.8124</td>
    </tr>
    <tr>
      <td width="450">create_gc_cycles</td>
      <td width="190">越小越好</td>
      <td width="190">0.001575139788656088</td>
      <td width="190">0.0022903839044374763</td>
      <td width="360">0.6877</td>
    </tr>
    <tr>
      <td width="450">gc_traversal</td>
      <td width="190">越小越好</td>
      <td width="190">0.0030440913827760596</td>
      <td width="190">0.004191726240605931</td>
      <td width="360">0.7262</td>
    </tr>
    <tr>
      <td width="450">generators</td>
      <td width="190">越小越好</td>
      <td width="190">0.022210613749848562</td>
      <td width="190">0.029673172495677136</td>
      <td width="360">0.7485</td>
    </tr>
    <tr>
      <td width="450">genshi_text</td>
      <td width="190">越小越好</td>
      <td width="190">0.017027854687512445</td>
      <td width="190">0.017688688756607007</td>
      <td width="360">0.9626</td>
    </tr>
    <tr>
      <td width="450">genshi_xml</td>
      <td width="190">越小越好</td>
      <td width="190">0.039004123500490095</td>
      <td width="190">0.03746698625036515</td>
      <td width="360">1.041</td>
    </tr>
    <tr>
      <td width="450">go</td>
      <td width="190">越小越好</td>
      <td width="190">0.0867287450018921</td>
      <td width="190">0.09157456748653203</td>
      <td width="360">0.9471</td>
    </tr>
    <tr>
      <td width="450">hexiom</td>
      <td width="190">越小越好</td>
      <td width="190">0.0044202290155226365</td>
      <td width="190">0.0049063942169595975</td>
      <td width="360">0.9009</td>
    </tr>
    <tr>
      <td width="450">html5lib</td>
      <td width="190">越小越好</td>
      <td width="190">0.04255041100077506</td>
      <td width="190">0.039463120003347285</td>
      <td width="360">1.0782</td>
    </tr>
    <tr>
      <td width="450">json_dumps</td>
      <td width="190">越小越好</td>
      <td width="190">0.007655249531126174</td>
      <td width="190">0.007923862187453778</td>
      <td width="360">0.9661</td>
    </tr>
    <tr>
      <td width="450">json_loads</td>
      <td width="190">越小越好</td>
      <td width="190">1.724170400407843e-05</td>
      <td width="190">2.1208963858043717e-05</td>
      <td width="360">0.8129</td>
    </tr>
    <tr>
      <td width="450">logging_format</td>
      <td width="190">越小越好</td>
      <td width="190">4.987791503907602e-06</td>
      <td width="190">4.8048491208874115e-06</td>
      <td width="360">1.0381</td>
    </tr>
    <tr>
      <td width="450">logging_silent</td>
      <td width="190">越小越好</td>
      <td width="190">7.263747978103474e-08</td>
      <td width="190">8.705588148139042e-08</td>
      <td width="360">0.8344</td>
    </tr>
    <tr>
      <td width="450">logging_simple</td>
      <td width="190">越小越好</td>
      <td width="190">4.542137902596721e-06</td>
      <td width="190">4.413369384792532e-06</td>
      <td width="360">1.0292</td>
    </tr>
    <tr>
      <td width="450">mako</td>
      <td width="190">越小越好</td>
      <td width="190">0.008911094968880207</td>
      <td width="190">0.008999086559924763</td>
      <td width="360">0.9902</td>
    </tr>
    <tr>
      <td width="450">mdp</td>
      <td width="190">越小越好</td>
      <td width="190">0.9076510999948368</td>
      <td width="190">1.0261909349937923</td>
      <td width="360">0.8845</td>
    </tr>
    <tr>
      <td width="450">meteor_contest</td>
      <td width="190">越小越好</td>
      <td width="190">0.07917650300078094</td>
      <td width="190">0.08675520250108093</td>
      <td width="360">0.9126</td>
    </tr>
    <tr>
      <td width="450">nbody</td>
      <td width="190">越小越好</td>
      <td width="190">0.07420662674849154</td>
      <td width="190">0.08942872501211241</td>
      <td width="360">0.8298</td>
    </tr>
    <tr>
      <td width="450">shortest_path</td>
      <td width="190">越小越好</td>
      <td width="190">0.37066771399986465</td>
      <td width="190">0.39659378497162834</td>
      <td width="360">0.9346</td>
    </tr>
    <tr>
      <td width="450">connected_components</td>
      <td width="190">越小越好</td>
      <td width="190">0.3541623319979408</td>
      <td width="190">0.36734799499390647</td>
      <td width="360">0.9641</td>
    </tr>
    <tr>
      <td width="450">k_core</td>
      <td width="190">越小越好</td>
      <td width="190">1.8658915615014848</td>
      <td width="190">2.011543519969564</td>
      <td width="360">0.9276</td>
    </tr>
    <tr>
      <td width="450">nqueens</td>
      <td width="190">越小越好</td>
      <td width="190">0.06223942599535803</td>
      <td width="190">0.06802388248615898</td>
      <td width="360">0.915</td>
    </tr>
    <tr>
      <td width="450">pathlib</td>
      <td width="190">越小越好</td>
      <td width="190">0.016220308312767884</td>
      <td width="190">0.011987698751909193</td>
      <td width="360">1.3531</td>
    </tr>
    <tr>
      <td width="450">pickle</td>
      <td width="190">越小越好</td>
      <td width="190">8.533387255837967e-06</td>
      <td width="190">8.492680422023113e-06</td>
      <td width="360">1.0048</td>
    </tr>
    <tr>
      <td width="450">pickle_dict</td>
      <td width="190">越小越好</td>
      <td width="190">2.048623759804968e-05</td>
      <td width="190">2.3491712886425377e-05</td>
      <td width="360">0.8721</td>
    </tr>
    <tr>
      <td width="450">pickle_list</td>
      <td width="190">越小越好</td>
      <td width="190">3.4950781616416297e-06</td>
      <td width="190">3.8407083735592096e-06</td>
      <td width="360">0.91</td>
    </tr>
    <tr>
      <td width="450">pickle_pure_python</td>
      <td width="190">越小越好</td>
      <td width="190">0.0002330220085923429</td>
      <td width="190">0.00024113673443935114</td>
      <td width="360">0.9663</td>
    </tr>
    <tr>
      <td width="450">pidigits</td>
      <td width="190">越小越好</td>
      <td width="190">0.1673008045036113</td>
      <td width="190">0.2210028949775733</td>
      <td width="360">0.757</td>
    </tr>
    <tr>
      <td width="450">pprint_safe_repr</td>
      <td width="190">越小越好</td>
      <td width="190">0.5434452440022142</td>
      <td width="190">0.5280383400386199</td>
      <td width="360">1.0292</td>
    </tr>
    <tr>
      <td width="450">pprint_pformat</td>
      <td width="190">越小越好</td>
      <td width="190">1.111418220003543</td>
      <td width="190">1.0865615850198083</td>
      <td width="360">1.0229</td>
    </tr>
    <tr>
      <td width="450">pyflate</td>
      <td width="190">越小越好</td>
      <td width="190">0.3154637725019711</td>
      <td width="190">0.37278194003738463</td>
      <td width="360">0.8462</td>
    </tr>
    <tr>
      <td width="450">python_startup</td>
      <td width="190">越小越好</td>
      <td width="190">0.010815944124715315</td>
      <td width="190">0.011257740312430542</td>
      <td width="360">0.9608</td>
    </tr>
    <tr>
      <td width="450">python_startup_no_site</td>
      <td width="190">越小越好</td>
      <td width="190">0.006368060531258379</td>
      <td width="190">0.00675243187288288</td>
      <td width="360">0.9431</td>
    </tr>
    <tr>
      <td width="450">raytrace</td>
      <td width="190">越小越好</td>
      <td width="190">0.18831041199882748</td>
      <td width="190">0.22380944498581812</td>
      <td width="360">0.8414</td>
    </tr>
    <tr>
      <td width="450">regex_compile</td>
      <td width="190">越小越好</td>
      <td width="190">0.0778451469996071</td>
      <td width="190">0.08377706000464968</td>
      <td width="360">0.9292</td>
    </tr>
    <tr>
      <td width="450">regex_dna</td>
      <td width="190">越小越好</td>
      <td width="190">0.14586239949858282</td>
      <td width="190">0.1506809850106947</td>
      <td width="360">0.968</td>
    </tr>
    <tr>
      <td width="450">regex_effbot</td>
      <td width="190">越小越好</td>
      <td width="190">0.0022065439562538812</td>
      <td width="190">0.0023450193752069023</td>
      <td width="360">0.9409</td>
    </tr>
    <tr>
      <td width="450">regex_v8</td>
      <td width="190">越小越好</td>
      <td width="190">0.01775382362484379</td>
      <td width="190">0.017901338746014517</td>
      <td width="360">0.9918</td>
    </tr>
    <tr>
      <td width="450">richards</td>
      <td width="190">越小越好</td>
      <td width="190">0.03178223712529871</td>
      <td width="190">0.03640123375225812</td>
      <td width="360">0.8731</td>
    </tr>
    <tr>
      <td width="450">richards_super</td>
      <td width="190">越小越好</td>
      <td width="190">0.03623623199928261</td>
      <td width="190">0.041392266255570576</td>
      <td width="360">0.8754</td>
    </tr>
    <tr>
      <td width="450">scimark_fft</td>
      <td width="190">越小越好</td>
      <td width="190">0.25610569650598336</td>
      <td width="190">0.26901588001055643</td>
      <td width="360">0.952</td>
    </tr>
    <tr>
      <td width="450">scimark_lu</td>
      <td width="190">越小越好</td>
      <td width="190">0.08218339599989122</td>
      <td width="190">0.09940030000871047</td>
      <td width="360">0.8268</td>
    </tr>
    <tr>
      <td width="450">scimark_monte_carlo</td>
      <td width="190">越小越好</td>
      <td width="190">0.04912392174992419</td>
      <td width="190">0.05415373749565333</td>
      <td width="360">0.9071</td>
    </tr>
    <tr>
      <td width="450">scimark_sor</td>
      <td width="190">越小越好</td>
      <td width="190">0.08817394400102785</td>
      <td width="190">0.09491706502740271</td>
      <td width="360">0.929</td>
    </tr>
    <tr>
      <td width="450">scimark_sparse_mat_mult</td>
      <td width="190">越小越好</td>
      <td width="190">0.004200509421934839</td>
      <td width="190">0.004379986563435523</td>
      <td width="360">0.959</td>
    </tr>
    <tr>
      <td width="450">spectral_norm</td>
      <td width="190">越小越好</td>
      <td width="190">0.07431616574831423</td>
      <td width="190">0.09285055252257735</td>
      <td width="360">0.8004</td>
    </tr>
    <tr>
      <td width="450">sphinx</td>
      <td width="190">越小越好</td>
      <td width="190">0.7731315040000482</td>
      <td width="190">0.8021337600657716</td>
      <td width="360">0.9638</td>
    </tr>
    <tr>
      <td width="450">sqlalchemy_declarative</td>
      <td width="190">越小越好</td>
      <td width="190">0.08286319350008853</td>
      <td width="190">0.09217313752742484</td>
      <td width="360">0.899</td>
    </tr>
    <tr>
      <td width="450">sqlalchemy_imperative</td>
      <td width="190">越小越好</td>
      <td width="190">0.008068227249623305</td>
      <td width="190">0.009569823116180487</td>
      <td width="360">0.8431</td>
    </tr>
    <tr>
      <td width="450">sqlglot_v2_normalize</td>
      <td width="190">越小越好</td>
      <td width="190">0.07679850924978382</td>
      <td width="190">0.08017551497323439</td>
      <td width="360">0.9579</td>
    </tr>
    <tr>
      <td width="450">sqlglot_v2_optimize</td>
      <td width="190">越小越好</td>
      <td width="190">0.037221973872874514</td>
      <td width="190">0.040698281285585836</td>
      <td width="360">0.9146</td>
    </tr>
    <tr>
      <td width="450">sqlglot_v2_parse</td>
      <td width="190">越小越好</td>
      <td width="190">0.0009159811719996469</td>
      <td width="190">0.00095406378250118</td>
      <td width="360">0.9601</td>
    </tr>
    <tr>
      <td width="450">sqlglot_v2_transpile</td>
      <td width="190">越小越好</td>
      <td width="190">0.0011492262266301623</td>
      <td width="190">0.0012210611293994589</td>
      <td width="360">0.9412</td>
    </tr>
    <tr>
      <td width="450">sqlite_synth</td>
      <td width="190">越小越好</td>
      <td width="190">1.7601318892390694e-06</td>
      <td width="190">1.6710652150919714e-06</td>
      <td width="360">1.0533</td>
    </tr>
    <tr>
      <td width="450">sympy_expand</td>
      <td width="190">越小越好</td>
      <td width="190">0.2852309429945308</td>
      <td width="190">0.3046102650114335</td>
      <td width="360">0.9364</td>
    </tr>
    <tr>
      <td width="450">sympy_integrate</td>
      <td width="190">越小越好</td>
      <td width="190">0.013567699066697969</td>
      <td width="190">0.014389080635737628</td>
      <td width="360">0.9429</td>
    </tr>
    <tr>
      <td width="450">sympy_sum</td>
      <td width="190">越小越好</td>
      <td width="190">0.08949847424810287</td>
      <td width="190">0.09819639500346966</td>
      <td width="360">0.9114</td>
    </tr>
    <tr>
      <td width="450">sympy_str</td>
      <td width="190">越小越好</td>
      <td width="190">0.164689871497103</td>
      <td width="190">0.1807795200147666</td>
      <td width="360">0.911</td>
    </tr>
    <tr>
      <td width="450">telco</td>
      <td width="190">越小越好</td>
      <td width="190">0.005631715375102431</td>
      <td width="190">0.005572494217631174</td>
      <td width="360">1.0106</td>
    </tr>
    <tr>
      <td width="450">tomli_loads</td>
      <td width="190">越小越好</td>
      <td width="190">1.6077207060006913</td>
      <td width="190">1.6951442050049081</td>
      <td width="360">0.9484</td>
    </tr>
    <tr>
      <td width="450">tornado_http</td>
      <td width="190">越小越好</td>
      <td width="190">0.08628957349719713</td>
      <td width="190">0.08699277002597228</td>
      <td width="360">0.9919</td>
    </tr>
    <tr>
      <td width="450">typing_runtime_protocols</td>
      <td width="190">越小越好</td>
      <td width="190">0.00011712297900601243</td>
      <td width="190">0.000127559194368132</td>
      <td width="360">0.9182</td>
    </tr>
    <tr>
      <td width="450">unpack_sequence</td>
      <td width="190">越小越好</td>
      <td width="190">3.683516906827222e-08</td>
      <td width="190">3.530234526039066e-08</td>
      <td width="360">1.0434</td>
    </tr>
    <tr>
      <td width="450">unpickle</td>
      <td width="190">越小越好</td>
      <td width="190">1.0063152392802975e-05</td>
      <td width="190">1.1390831542712476e-05</td>
      <td width="360">0.8834</td>
    </tr>
    <tr>
      <td width="450">unpickle_list</td>
      <td width="190">越小越好</td>
      <td width="190">3.2906743408389618e-06</td>
      <td width="190">4.683183350095988e-06</td>
      <td width="360">0.7027</td>
    </tr>
    <tr>
      <td width="450">unpickle_pure_python</td>
      <td width="190">越小越好</td>
      <td width="190">0.00016027900469453015</td>
      <td width="190">0.00017277294527957566</td>
      <td width="360">0.9277</td>
    </tr>
    <tr>
      <td width="450">xdsl_constant_fold</td>
      <td width="190">越小越好</td>
      <td width="190">0.025648352499047178</td>
      <td width="190">0.02867492249060888</td>
      <td width="360">0.8945</td>
    </tr>
    <tr>
      <td width="450">xml_etree_parse</td>
      <td width="190">越小越好</td>
      <td width="190">0.10137063499860233</td>
      <td width="190">0.12777634506346658</td>
      <td width="360">0.7933</td>
    </tr>
    <tr>
      <td width="450">xml_etree_iterparse</td>
      <td width="190">越小越好</td>
      <td width="190">0.06384371099920827</td>
      <td width="190">0.08447786996839568</td>
      <td width="360">0.7557</td>
    </tr>
    <tr>
      <td width="450">xml_etree_generate</td>
      <td width="190">越小越好</td>
      <td width="190">0.06258954149961937</td>
      <td width="190">0.06798335001803935</td>
      <td width="360">0.9207</td>
    </tr>
    <tr>
      <td width="450">xml_etree_process</td>
      <td width="190">越小越好</td>
      <td width="190">0.04440150287337019</td>
      <td width="190">0.04895283000951167</td>
      <td width="360">0.907</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
