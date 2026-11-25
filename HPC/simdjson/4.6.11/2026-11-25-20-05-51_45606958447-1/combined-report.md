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
      <td width="180">HPC</td>
      <td width="220">simdjson</td>
      <td width="160">4.6.11</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### simdjson 4.6.11

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
      <td width="600">4.6.11</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">N/A</td>
      <td width="600">4.6.11</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">N/A</td>
      <td width="600">2026-11-25T11:46:06Z</td>
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
      <td width="600">2026-11-25T11:45:02Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95<br>node 0 size: 381404 MB<br>node 0 free: 331418 MB<br>node 1 cpus: 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 1 size: 387001 MB<br>node 1 free: 381663 MB<br>node 2 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287<br>node 2 size: 387058 MB<br>node 2 free: 236656 MB<br>node 3 cpus: 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379 380 381 382 383<br>node 3 size: 386014 MB<br>node 3 free: 347087 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  15  20  20 <br>  1:  15  10  20  20 <br>  2:  20  20  10  15 <br>  3:  20  20  15  10</td>
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
      <td width="500">simdjson</td>
      <td width="880">4.6.11</td>
    </tr>
    <tr>
      <td width="500">google_benchmark</td>
      <td width="880">1.9.5</td>
    </tr>
    <tr>
      <td width="500">simdjson_data</td>
      <td width="880">351949906abde446f0314bf79606fb5d884f5be7</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### aarch64

#### simdjson 4.6.11

##### bench_dom_api

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
      <td width="500">bench_dom_api_error_code_twitter_count_ns</td>
      <td width="280">22.608604</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_error_code_twitter_default_profile_ns</td>
      <td width="280">18621.975026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_error_code_twitter_image_sizes_ns</td>
      <td width="280">7912.756699</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_exceptions_load_scan_ns</td>
      <td width="280">216097.024691</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_exceptions_load_size_scan_ns</td>
      <td width="280">184411.925711</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_exceptions_scan_ns</td>
      <td width="280">36704.968258</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_exceptions_size_scan_ns</td>
      <td width="280">5542.412778</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_load_scan_ns</td>
      <td width="280">230895.434211</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_load_size_scan_ns</td>
      <td width="280">226489.705549</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_scan_ns</td>
      <td width="280">51147.680926</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_size_scan_ns</td>
      <td width="280">47348.671428</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_type_exceptions_scan_ns</td>
      <td width="280">11874.637845</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_type_exceptions_size_scan_ns</td>
      <td width="280">6909.004851</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_type_scan_ns</td>
      <td width="280">57137.036477</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_numbers_type_size_scan_ns</td>
      <td width="280">41834.05424</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_parse_surrogate_pairs_ns</td>
      <td width="280">186.284018</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_recover_one_string_ns</td>
      <td width="280">1.53914</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_serialize_big_string_to_string_ns</td>
      <td width="280">30824.237459</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_serialize_twitter_ns</td>
      <td width="280">433324.760136</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_serialize_twitter_string_builder_ns</td>
      <td width="280">423497.160568</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_serialize_twitter_to_string_ns</td>
      <td width="280">433414.10908</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_twitter_count_ns</td>
      <td width="280">19.621803</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_twitter_default_profile_ns</td>
      <td width="280">14395.305345</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_dom_api_twitter_image_sizes_ns</td>
      <td width="280">5666.722744</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_ondemand

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
      <td width="500">bench_ondemand_accessor_deep_runtime_at_path_deep_ns</td>
      <td width="280">492.687768</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_accessor_nested_runtime_at_path_nested_ns</td>
      <td width="280">395.664147</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_accessor_simple_runtime_at_path_simple_ns</td>
      <td width="280">327.899638</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_amazon_cellphones_simdjson_dom_THREADED_ns</td>
      <td width="280">172108.448877</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_amazon_cellphones_simdjson_dom_UNTHREADED_ns</td>
      <td width="280">172519.92877</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_amazon_cellphones_simdjson_ondemand_THREADED_ns</td>
      <td width="280">130382.297211</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_amazon_cellphones_simdjson_ondemand_UNTHREADED_ns</td>
      <td width="280">130273.1645</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_distinct_user_id_simdjson_dom_json_pointer_ns</td>
      <td width="280">325997.198512</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_distinct_user_id_simdjson_dom_ns</td>
      <td width="280">320438.022659</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_distinct_user_id_simdjson_ondemand_json_pointer_ns</td>
      <td width="280">255903.539269</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_distinct_user_id_simdjson_ondemand_ns</td>
      <td width="280">242239.912434</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_find_tweet_simdjson_dom_ns</td>
      <td width="280">308613.446562</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_find_tweet_simdjson_ondemand_ns</td>
      <td width="280">188963.136509</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_json2msgpack_simdjson_dom_ns</td>
      <td width="280">519813.63252</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_json2msgpack_simdjson_ondemand_ns</td>
      <td width="280">429182.751572</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_kostya_simdjson_dom_ns</td>
      <td width="280">96491635.625</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_kostya_simdjson_ondemand_ns</td>
      <td width="280">73707941.428572</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_large_amazon_cellphones_simdjson_dom_THREADED_ns</td>
      <td width="280">4968967.096774</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_large_amazon_cellphones_simdjson_dom_UNTHREADED_ns</td>
      <td width="280">7223710.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_large_amazon_cellphones_simdjson_ondemand_THREADED_ns</td>
      <td width="280">3576034.932432</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_large_amazon_cellphones_simdjson_ondemand_UNTHREADED_ns</td>
      <td width="280">5550924.945055</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_large_random_simdjson_dom_ns</td>
      <td width="280">84618315.294118</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_large_random_simdjson_ondemand_ns</td>
      <td width="280">61501232.5</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_partial_tweets_simdjson_dom_ns</td>
      <td width="280">323259.490901</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_partial_tweets_simdjson_ondemand_ns</td>
      <td width="280">244172.909976</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_top_tweet_simdjson_dom_ns</td>
      <td width="280">316162.96673</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_top_tweet_simdjson_ondemand_forward_only_ns</td>
      <td width="280">241891.014075</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_ondemand_top_tweet_simdjson_ondemand_ns</td>
      <td width="280">242135.007187</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### bench_parse_call

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
      <td width="500">bench_parse_call_document_parse_error_code_ns</td>
      <td width="280">142.034597</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_parse_call_document_parse_exception_ns</td>
      <td width="280">142.411423</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_parse_call_fast_minify_gsoc_ns</td>
      <td width="280">638782.965328</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_parse_call_fast_minify_twitter_ns</td>
      <td width="280">121118.089776</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_parse_call_parse_gsoc_ns</td>
      <td width="280">1202019.856522</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_parse_call_parse_twitter_ns</td>
      <td width="280">279948.357503</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_parse_call_parser_parse_error_code_ns</td>
      <td width="280">43.817341</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_parse_call_parser_parse_exception_ns</td>
      <td width="280">43.516411</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_parse_call_unicode_validate_twitter_ns</td>
      <td width="280">33242.475424</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### dom_parse

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
      <td width="500">dom_parse_citm_catalog_gb_per_s</td>
      <td width="280">2.540424</td>
      <td width="200">GB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">dom_parse_citm_catalog_stage1_gb_per_s</td>
      <td width="280">4.543265</td>
      <td width="200">GB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">dom_parse_twitter_gb_per_s</td>
      <td width="280">2.220056</td>
      <td width="200">GB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">dom_parse_twitter_stage1_gb_per_s</td>
      <td width="280">3.96608</td>
      <td width="200">GB/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### dom_parse_stream

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
      <td width="500">dom_parse_stream_amazon_cellphones_gb_per_s</td>
      <td width="280">2.05868</td>
      <td width="200">GB/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
