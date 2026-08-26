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
      <td width="220">glibc</td>
      <td width="160">2.44</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">glibc</td>
      <td width="160">2.44</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### glibc 2.44

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
      <td width="600">2.44</td>
      <td width="600">2.44</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">2.44</td>
      <td width="600">2.44</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-08-26T02:01:58Z</td>
      <td width="600">2026-08-26T02:00:18Z</td>
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
      <td width="600">2026-08-26T02:00:20Z</td>
      <td width="600">2026-08-26T01:59:12Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">General Purpose Processor</td>
      <td width="600">Kunpeng 920 7270Z To be filled by O.E.M. CPU @ 2.9GHz</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">16</td>
      <td width="600">256</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0-159.4.10.164.oe2403sp4.x86_64</td>
      <td width="600">6.6.0-159.4.3.154.oe2403sp4.aarch64</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 127952 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 123601 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127002 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 127442 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

<table width="1380">
  <thead>
    <tr>
      <th width="180">软件</th>
      <th width="160">版本</th>
      <th width="420">指标</th>
      <th width="200">数值</th>
      <th width="160">单位</th>
      <th width="260">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan.inf/nan.mean</td>
      <td width="200">4483.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_inl.inf/nan.mean</td>
      <td width="200">2243.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_builtin.inf/nan.mean</td>
      <td width="200">1958.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnan.inf/nan.mean</td>
      <td width="200">1953.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf.inf/nan.mean</td>
      <td width="200">4760.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns2.inf/nan.mean</td>
      <td width="200">1954.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns_builtin.inf/nan.mean</td>
      <td width="200">2235.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_builtin.inf/nan.mean</td>
      <td width="200">2238.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isinf.inf/nan.mean</td>
      <td width="200">2234.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite.inf/nan.mean</td>
      <td width="200">4216.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite_inl.inf/nan.mean</td>
      <td width="200">1968.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isfinite_builtin.inf/nan.mean</td>
      <td width="200">1406.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isfinite.inf/nan.mean</td>
      <td width="200">1408.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_inl.inf/nan.mean</td>
      <td width="200">4496.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_builtin.inf/nan.mean</td>
      <td width="200">1407.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnormal.inf/nan.mean</td>
      <td width="200">1406.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify.inf/nan.mean</td>
      <td width="200">1967.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify_builtin.inf/nan.mean</td>
      <td width="200">2331.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.fpclassify.inf/nan.mean</td>
      <td width="200">2605.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test1.inf/nan.mean</td>
      <td width="200">5870.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test2.inf/nan.mean</td>
      <td width="200">5757.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan.normal.mean</td>
      <td width="200">4233.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_inl.normal.mean</td>
      <td width="200">2002.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_builtin.normal.mean</td>
      <td width="200">1434.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnan.normal.mean</td>
      <td width="200">1434.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf.normal.mean</td>
      <td width="200">3389.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns2.normal.mean</td>
      <td width="200">1708.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns_builtin.normal.mean</td>
      <td width="200">1987.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_builtin.normal.mean</td>
      <td width="200">1989.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isinf.normal.mean</td>
      <td width="200">1987.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite.normal.mean</td>
      <td width="200">3959.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite_inl.normal.mean</td>
      <td width="200">2000.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isfinite_builtin.normal.mean</td>
      <td width="200">1438.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isfinite.normal.mean</td>
      <td width="200">1434.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_inl.normal.mean</td>
      <td width="200">3213.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_builtin.normal.mean</td>
      <td width="200">1805.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnormal.normal.mean</td>
      <td width="200">1788.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify.normal.mean</td>
      <td width="200">2055.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify_builtin.normal.mean</td>
      <td width="200">2091.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.fpclassify.normal.mean</td>
      <td width="200">2367.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test1.normal.mean</td>
      <td width="200">7591.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test2.normal.mean</td>
      <td width="200">7948.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">sprintf.positional.mean</td>
      <td width="200">299.164</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">sprintf.non-positional.mean</td>
      <td width="200">168.296</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">fclose.duration</td>
      <td width="200">36051.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">random.single-threaded</td>
      <td width="200">4.52894</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">random.multi-threaded</td>
      <td width="200">4.37428</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

<table width="1380">
  <thead>
    <tr>
      <th width="180">软件</th>
      <th width="160">版本</th>
      <th width="420">指标</th>
      <th width="200">数值</th>
      <th width="160">单位</th>
      <th width="260">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan.inf/nan.mean</td>
      <td width="200">6094.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_inl.inf/nan.mean</td>
      <td width="200">2119.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_builtin.inf/nan.mean</td>
      <td width="200">2486.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnan.inf/nan.mean</td>
      <td width="200">2146.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf.inf/nan.mean</td>
      <td width="200">6540.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns2.inf/nan.mean</td>
      <td width="200">2164.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns_builtin.inf/nan.mean</td>
      <td width="200">2158.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_builtin.inf/nan.mean</td>
      <td width="200">2072.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isinf.inf/nan.mean</td>
      <td width="200">2326.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite.inf/nan.mean</td>
      <td width="200">2501.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite_inl.inf/nan.mean</td>
      <td width="200">1422.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isfinite_builtin.inf/nan.mean</td>
      <td width="200">1425.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isfinite.inf/nan.mean</td>
      <td width="200">1422.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_inl.inf/nan.mean</td>
      <td width="200">2846.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_builtin.inf/nan.mean</td>
      <td width="200">1420.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnormal.inf/nan.mean</td>
      <td width="200">1421.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify.inf/nan.mean</td>
      <td width="200">2131.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify_builtin.inf/nan.mean</td>
      <td width="200">2038.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.fpclassify.inf/nan.mean</td>
      <td width="200">2187.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test1.inf/nan.mean</td>
      <td width="200">9051.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test2.inf/nan.mean</td>
      <td width="200">8786.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan.normal.mean</td>
      <td width="200">2537.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_inl.normal.mean</td>
      <td width="200">1458.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_builtin.normal.mean</td>
      <td width="200">1112.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnan.normal.mean</td>
      <td width="200">1109.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf.normal.mean</td>
      <td width="200">2558.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns2.normal.mean</td>
      <td width="200">1114.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns_builtin.normal.mean</td>
      <td width="200">1462.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_builtin.normal.mean</td>
      <td width="200">1461.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isinf.normal.mean</td>
      <td width="200">1460.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite.normal.mean</td>
      <td width="200">2556.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite_inl.normal.mean</td>
      <td width="200">1207.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isfinite_builtin.normal.mean</td>
      <td width="200">1197.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isfinite.normal.mean</td>
      <td width="200">1217.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_inl.normal.mean</td>
      <td width="200">4307.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_builtin.normal.mean</td>
      <td width="200">2423.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnormal.normal.mean</td>
      <td width="200">2388.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify.normal.mean</td>
      <td width="200">3554.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify_builtin.normal.mean</td>
      <td width="200">2834.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.fpclassify.normal.mean</td>
      <td width="200">2853.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test1.normal.mean</td>
      <td width="200">8044.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test2.normal.mean</td>
      <td width="200">8166.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">sprintf.positional.mean</td>
      <td width="200">461.238</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">sprintf.non-positional.mean</td>
      <td width="200">245.105</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">fclose.duration</td>
      <td width="200">26800.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">random.single-threaded</td>
      <td width="200">3.68272</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">random.multi-threaded</td>
      <td width="200">21.4263</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

<table width="1380">
  <thead>
    <tr>
      <th width="160">软件</th>
      <th width="140">版本</th>
      <th width="340">指标</th>
      <th width="180">优化方向</th>
      <th width="160">x86_64</th>
      <th width="160">aarch64</th>
      <th width="240">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">4483.0</td>
      <td width="160">6094.0</td>
      <td width="240">0.7356</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan_inl.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2243.0</td>
      <td width="160">2119.0</td>
      <td width="240">1.0585</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1958.0</td>
      <td width="160">2486.0</td>
      <td width="240">0.7876</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isnan.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1953.0</td>
      <td width="160">2146.0</td>
      <td width="240">0.9101</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">4760.0</td>
      <td width="160">6540.0</td>
      <td width="240">0.7278</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_ns2.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1954.0</td>
      <td width="160">2164.0</td>
      <td width="240">0.903</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_ns_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2235.0</td>
      <td width="160">2158.0</td>
      <td width="240">1.0357</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2238.0</td>
      <td width="160">2072.0</td>
      <td width="240">1.0801</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isinf.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2234.0</td>
      <td width="160">2326.0</td>
      <td width="240">0.9604</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__finite.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">4216.0</td>
      <td width="160">2501.0</td>
      <td width="240">1.6857</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__finite_inl.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1968.0</td>
      <td width="160">1422.0</td>
      <td width="240">1.384</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isfinite_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1406.0</td>
      <td width="160">1425.0</td>
      <td width="240">0.9867</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isfinite.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1408.0</td>
      <td width="160">1422.0</td>
      <td width="240">0.9902</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnormal_inl.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">4496.0</td>
      <td width="160">2846.0</td>
      <td width="240">1.5798</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnormal_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1407.0</td>
      <td width="160">1420.0</td>
      <td width="240">0.9908</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isnormal.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1406.0</td>
      <td width="160">1421.0</td>
      <td width="240">0.9894</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__fpclassify.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1967.0</td>
      <td width="160">2131.0</td>
      <td width="240">0.923</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__fpclassify_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2331.0</td>
      <td width="160">2038.0</td>
      <td width="240">1.1438</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.fpclassify.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2605.0</td>
      <td width="160">2187.0</td>
      <td width="240">1.1911</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.remainder_test1.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">5870.0</td>
      <td width="160">9051.0</td>
      <td width="240">0.6485</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.remainder_test2.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">5757.0</td>
      <td width="160">8786.0</td>
      <td width="240">0.6552</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">4233.0</td>
      <td width="160">2537.0</td>
      <td width="240">1.6685</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan_inl.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2002.0</td>
      <td width="160">1458.0</td>
      <td width="240">1.3731</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1434.0</td>
      <td width="160">1112.0</td>
      <td width="240">1.2896</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isnan.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1434.0</td>
      <td width="160">1109.0</td>
      <td width="240">1.2931</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">3389.0</td>
      <td width="160">2558.0</td>
      <td width="240">1.3249</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_ns2.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1708.0</td>
      <td width="160">1114.0</td>
      <td width="240">1.5332</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_ns_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1987.0</td>
      <td width="160">1462.0</td>
      <td width="240">1.3591</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1989.0</td>
      <td width="160">1461.0</td>
      <td width="240">1.3614</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isinf.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1987.0</td>
      <td width="160">1460.0</td>
      <td width="240">1.361</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__finite.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">3959.0</td>
      <td width="160">2556.0</td>
      <td width="240">1.5489</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__finite_inl.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2000.0</td>
      <td width="160">1207.0</td>
      <td width="240">1.657</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isfinite_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1438.0</td>
      <td width="160">1197.0</td>
      <td width="240">1.2013</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isfinite.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1434.0</td>
      <td width="160">1217.0</td>
      <td width="240">1.1783</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnormal_inl.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">3213.0</td>
      <td width="160">4307.0</td>
      <td width="240">0.746</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnormal_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1805.0</td>
      <td width="160">2423.0</td>
      <td width="240">0.7449</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isnormal.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1788.0</td>
      <td width="160">2388.0</td>
      <td width="240">0.7487</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__fpclassify.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2055.0</td>
      <td width="160">3554.0</td>
      <td width="240">0.5782</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__fpclassify_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2091.0</td>
      <td width="160">2834.0</td>
      <td width="240">0.7378</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.fpclassify.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2367.0</td>
      <td width="160">2853.0</td>
      <td width="240">0.8297</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.remainder_test1.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">7591.0</td>
      <td width="160">8044.0</td>
      <td width="240">0.9437</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.remainder_test2.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">7948.0</td>
      <td width="160">8166.0</td>
      <td width="240">0.9733</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">sprintf.positional.mean</td>
      <td width="180">越小越好</td>
      <td width="160">299.164</td>
      <td width="160">461.238</td>
      <td width="240">0.6486</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">sprintf.non-positional.mean</td>
      <td width="180">越小越好</td>
      <td width="160">168.296</td>
      <td width="160">245.105</td>
      <td width="240">0.6866</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">fclose.duration</td>
      <td width="180">越小越好</td>
      <td width="160">36051.0</td>
      <td width="160">26800.0</td>
      <td width="240">1.3452</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">random.single-threaded</td>
      <td width="180">越小越好</td>
      <td width="160">4.52894</td>
      <td width="160">3.68272</td>
      <td width="240">1.2298</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">random.multi-threaded</td>
      <td width="180">越小越好</td>
      <td width="160">4.37428</td>
      <td width="160">21.4263</td>
      <td width="240">0.2042</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
