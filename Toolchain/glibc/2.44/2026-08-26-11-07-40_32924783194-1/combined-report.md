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
      <td width="600">2026-08-26T03:02:00Z</td>
      <td width="600">2026-08-26T03:00:22Z</td>
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
      <td width="600">2026-08-26T03:00:23Z</td>
      <td width="600">2026-08-26T02:59:16Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 127955 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 123633 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127031 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 127429 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
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
      <td width="200">4498.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_inl.inf/nan.mean</td>
      <td width="200">2244.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_builtin.inf/nan.mean</td>
      <td width="200">1960.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnan.inf/nan.mean</td>
      <td width="200">1956.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf.inf/nan.mean</td>
      <td width="200">4761.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns2.inf/nan.mean</td>
      <td width="200">1953.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns_builtin.inf/nan.mean</td>
      <td width="200">2230.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_builtin.inf/nan.mean</td>
      <td width="200">2235.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isinf.inf/nan.mean</td>
      <td width="200">2231.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite.inf/nan.mean</td>
      <td width="200">4217.0</td>
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
      <td width="200">1407.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isfinite.inf/nan.mean</td>
      <td width="200">1406.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_inl.inf/nan.mean</td>
      <td width="200">4495.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_builtin.inf/nan.mean</td>
      <td width="200">1405.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnormal.inf/nan.mean</td>
      <td width="200">1408.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify.inf/nan.mean</td>
      <td width="200">1970.0</td>
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
      <td width="200">5742.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test2.inf/nan.mean</td>
      <td width="200">5613.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan.normal.mean</td>
      <td width="200">3123.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_inl.normal.mean</td>
      <td width="200">2004.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_builtin.normal.mean</td>
      <td width="200">1430.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnan.normal.mean</td>
      <td width="200">1432.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf.normal.mean</td>
      <td width="200">4506.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns2.normal.mean</td>
      <td width="200">1707.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns_builtin.normal.mean</td>
      <td width="200">1986.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_builtin.normal.mean</td>
      <td width="200">1985.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isinf.normal.mean</td>
      <td width="200">1984.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite.normal.mean</td>
      <td width="200">3951.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite_inl.normal.mean</td>
      <td width="200">1993.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isfinite_builtin.normal.mean</td>
      <td width="200">1433.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isfinite.normal.mean</td>
      <td width="200">1433.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_inl.normal.mean</td>
      <td width="200">3226.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_builtin.normal.mean</td>
      <td width="200">1781.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnormal.normal.mean</td>
      <td width="200">1786.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify.normal.mean</td>
      <td width="200">2056.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify_builtin.normal.mean</td>
      <td width="200">2312.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.fpclassify.normal.mean</td>
      <td width="200">2584.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test1.normal.mean</td>
      <td width="200">6274.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test2.normal.mean</td>
      <td width="200">6556.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">sprintf.positional.mean</td>
      <td width="200">297.657</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">sprintf.non-positional.mean</td>
      <td width="200">164.472</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">fclose.duration</td>
      <td width="200">35331.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">random.single-threaded</td>
      <td width="200">3.43454</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">random.multi-threaded</td>
      <td width="200">4.37934</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=0].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="200">101.40733333333333</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=1].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="200">102.64466666666665</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">memmove.results[length=4096,align1=0,align2=32].timings[ifuncs=&#x27;generic_memmove&#x27;].arithmetic_mean</td>
      <td width="200">95.08635</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">memset.results[length=4096,alignment=0,char=0].timings[ifuncs=&#x27;generic_memset&#x27;].arithmetic_mean</td>
      <td width="200">69.2158</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">strlen.results[length=4096,alignment=0].timings[ifuncs=&#x27;generic_strlen&#x27;].arithmetic_mean</td>
      <td width="200">258.694</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">strcmp.results[length=4096,align1=0,align2=0].timings[ifuncs=&#x27;generic_strcmp&#x27;].arithmetic_mean</td>
      <td width="200">289.4304</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">strstr.results[len_haystack=4096,len_needle=64,align_haystack=1,align_needle=11,fail=0].timings[ifuncs=&#x27;twoway_strstr&#x27;].arithmetic_mean</td>
      <td width="200">790.312</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">malloc-simple.results[malloc_block_size=64].main_arena_st_allocs_0100_time</td>
      <td width="200">18.0323</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">malloc-tcache.simple[alloc_size=64].time_per_iteration</td>
      <td width="200">5.44163</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">malloc-tcache.optimized[alloc_size=64].time_per_iteration</td>
      <td width="200">4.92903</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">malloc-thread.results[threads=8].time_per_iteration</td>
      <td width="200">8.41609</td>
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
      <td width="200">6122.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_inl.inf/nan.mean</td>
      <td width="200">2065.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan_builtin.inf/nan.mean</td>
      <td width="200">2465.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnan.inf/nan.mean</td>
      <td width="200">2081.0</td>
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
      <td width="200">2143.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns_builtin.inf/nan.mean</td>
      <td width="200">2217.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_builtin.inf/nan.mean</td>
      <td width="200">2060.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isinf.inf/nan.mean</td>
      <td width="200">2228.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite.inf/nan.mean</td>
      <td width="200">2499.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite_inl.inf/nan.mean</td>
      <td width="200">1423.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isfinite_builtin.inf/nan.mean</td>
      <td width="200">1424.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isfinite.inf/nan.mean</td>
      <td width="200">1425.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_inl.inf/nan.mean</td>
      <td width="200">2849.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_builtin.inf/nan.mean</td>
      <td width="200">1425.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnormal.inf/nan.mean</td>
      <td width="200">1423.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify.inf/nan.mean</td>
      <td width="200">2129.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify_builtin.inf/nan.mean</td>
      <td width="200">2093.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.fpclassify.inf/nan.mean</td>
      <td width="200">2142.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test1.inf/nan.mean</td>
      <td width="200">9040.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test2.inf/nan.mean</td>
      <td width="200">8798.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnan.normal.mean</td>
      <td width="200">2531.0</td>
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
      <td width="200">1117.0</td>
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
      <td width="200">2595.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns2.normal.mean</td>
      <td width="200">1113.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isinf_ns_builtin.normal.mean</td>
      <td width="200">1461.0</td>
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
      <td width="200">1461.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite.normal.mean</td>
      <td width="200">2549.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__finite_inl.normal.mean</td>
      <td width="200">1196.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isfinite_builtin.normal.mean</td>
      <td width="200">1203.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isfinite.normal.mean</td>
      <td width="200">1214.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_inl.normal.mean</td>
      <td width="200">4317.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__isnormal_builtin.normal.mean</td>
      <td width="200">2440.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.isnormal.normal.mean</td>
      <td width="200">2415.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify.normal.mean</td>
      <td width="200">3555.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.__fpclassify_builtin.normal.mean</td>
      <td width="200">2850.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.fpclassify.normal.mean</td>
      <td width="200">2845.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test1.normal.mean</td>
      <td width="200">8125.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">math-inlines.remainder_test2.normal.mean</td>
      <td width="200">8225.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">sprintf.positional.mean</td>
      <td width="200">458.349</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">sprintf.non-positional.mean</td>
      <td width="200">243.507</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">fclose.duration</td>
      <td width="200">24740.0</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">random.single-threaded</td>
      <td width="200">3.68242</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">random.multi-threaded</td>
      <td width="200">21.4239</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=0].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="200">114.59166666666665</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=1].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="200">114.367</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">memmove.results[length=4096,align1=0,align2=32].timings[ifuncs=&#x27;generic_memmove&#x27;].arithmetic_mean</td>
      <td width="200">105.245</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">memset.results[length=4096,alignment=0,char=0].timings[ifuncs=&#x27;generic_memset&#x27;].arithmetic_mean</td>
      <td width="200">55.2979</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">strlen.results[length=4096,alignment=0].timings[ifuncs=&#x27;generic_strlen&#x27;].arithmetic_mean</td>
      <td width="200">195.494</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">strcmp.results[length=4096,align1=0,align2=0].timings[ifuncs=&#x27;generic_strcmp&#x27;].arithmetic_mean</td>
      <td width="200">365.4688</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">strstr.results[len_haystack=4096,len_needle=64,align_haystack=1,align_needle=11,fail=0].timings[ifuncs=&#x27;twoway_strstr&#x27;].arithmetic_mean</td>
      <td width="200">1224.06</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">malloc-simple.results[malloc_block_size=64].main_arena_st_allocs_0100_time</td>
      <td width="200">19.218</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">malloc-tcache.simple[alloc_size=64].time_per_iteration</td>
      <td width="200">6.42287</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">malloc-tcache.optimized[alloc_size=64].time_per_iteration</td>
      <td width="200">5.81633</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">glibc</td>
      <td width="160">2.44</td>
      <td width="420">malloc-thread.results[threads=8].time_per_iteration</td>
      <td width="200">9.75522</td>
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
      <td width="160">4498.0</td>
      <td width="160">6122.0</td>
      <td width="240">0.7347</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan_inl.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2244.0</td>
      <td width="160">2065.0</td>
      <td width="240">1.0867</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1960.0</td>
      <td width="160">2465.0</td>
      <td width="240">0.7951</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isnan.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1956.0</td>
      <td width="160">2081.0</td>
      <td width="240">0.9399</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">4761.0</td>
      <td width="160">6540.0</td>
      <td width="240">0.728</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_ns2.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1953.0</td>
      <td width="160">2143.0</td>
      <td width="240">0.9113</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_ns_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2230.0</td>
      <td width="160">2217.0</td>
      <td width="240">1.0059</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2235.0</td>
      <td width="160">2060.0</td>
      <td width="240">1.085</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isinf.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2231.0</td>
      <td width="160">2228.0</td>
      <td width="240">1.0013</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__finite.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">4217.0</td>
      <td width="160">2499.0</td>
      <td width="240">1.6875</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__finite_inl.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1968.0</td>
      <td width="160">1423.0</td>
      <td width="240">1.383</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isfinite_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1407.0</td>
      <td width="160">1424.0</td>
      <td width="240">0.9881</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isfinite.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1406.0</td>
      <td width="160">1425.0</td>
      <td width="240">0.9867</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnormal_inl.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">4495.0</td>
      <td width="160">2849.0</td>
      <td width="240">1.5777</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnormal_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1405.0</td>
      <td width="160">1425.0</td>
      <td width="240">0.986</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isnormal.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1408.0</td>
      <td width="160">1423.0</td>
      <td width="240">0.9895</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__fpclassify.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1970.0</td>
      <td width="160">2129.0</td>
      <td width="240">0.9253</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__fpclassify_builtin.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2331.0</td>
      <td width="160">2093.0</td>
      <td width="240">1.1137</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.fpclassify.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2605.0</td>
      <td width="160">2142.0</td>
      <td width="240">1.2162</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.remainder_test1.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">5742.0</td>
      <td width="160">9040.0</td>
      <td width="240">0.6352</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.remainder_test2.inf/nan.mean</td>
      <td width="180">越小越好</td>
      <td width="160">5613.0</td>
      <td width="160">8798.0</td>
      <td width="240">0.638</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">3123.0</td>
      <td width="160">2531.0</td>
      <td width="240">1.2339</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan_inl.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2004.0</td>
      <td width="160">1458.0</td>
      <td width="240">1.3745</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnan_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1430.0</td>
      <td width="160">1117.0</td>
      <td width="240">1.2802</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isnan.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1432.0</td>
      <td width="160">1109.0</td>
      <td width="240">1.2913</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">4506.0</td>
      <td width="160">2595.0</td>
      <td width="240">1.7364</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_ns2.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1707.0</td>
      <td width="160">1113.0</td>
      <td width="240">1.5337</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_ns_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1986.0</td>
      <td width="160">1461.0</td>
      <td width="240">1.3593</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isinf_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1985.0</td>
      <td width="160">1461.0</td>
      <td width="240">1.3587</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isinf.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1984.0</td>
      <td width="160">1461.0</td>
      <td width="240">1.358</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__finite.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">3951.0</td>
      <td width="160">2549.0</td>
      <td width="240">1.55</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__finite_inl.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1993.0</td>
      <td width="160">1196.0</td>
      <td width="240">1.6664</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isfinite_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1433.0</td>
      <td width="160">1203.0</td>
      <td width="240">1.1912</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isfinite.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1433.0</td>
      <td width="160">1214.0</td>
      <td width="240">1.1804</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnormal_inl.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">3226.0</td>
      <td width="160">4317.0</td>
      <td width="240">0.7473</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__isnormal_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1781.0</td>
      <td width="160">2440.0</td>
      <td width="240">0.7299</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.isnormal.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">1786.0</td>
      <td width="160">2415.0</td>
      <td width="240">0.7395</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__fpclassify.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2056.0</td>
      <td width="160">3555.0</td>
      <td width="240">0.5783</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.__fpclassify_builtin.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2312.0</td>
      <td width="160">2850.0</td>
      <td width="240">0.8112</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.fpclassify.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">2584.0</td>
      <td width="160">2845.0</td>
      <td width="240">0.9083</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.remainder_test1.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">6274.0</td>
      <td width="160">8125.0</td>
      <td width="240">0.7722</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">math-inlines.remainder_test2.normal.mean</td>
      <td width="180">越小越好</td>
      <td width="160">6556.0</td>
      <td width="160">8225.0</td>
      <td width="240">0.7971</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">sprintf.positional.mean</td>
      <td width="180">越小越好</td>
      <td width="160">297.657</td>
      <td width="160">458.349</td>
      <td width="240">0.6494</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">sprintf.non-positional.mean</td>
      <td width="180">越小越好</td>
      <td width="160">164.472</td>
      <td width="160">243.507</td>
      <td width="240">0.6754</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">fclose.duration</td>
      <td width="180">越小越好</td>
      <td width="160">35331.0</td>
      <td width="160">24740.0</td>
      <td width="240">1.4281</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">random.single-threaded</td>
      <td width="180">越小越好</td>
      <td width="160">3.43454</td>
      <td width="160">3.68242</td>
      <td width="240">0.9327</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">random.multi-threaded</td>
      <td width="180">越小越好</td>
      <td width="160">4.37934</td>
      <td width="160">21.4239</td>
      <td width="240">0.2044</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=0].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="180">越小越好</td>
      <td width="160">101.40733333333333</td>
      <td width="160">114.59166666666665</td>
      <td width="240">0.8849</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=1].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="180">越小越好</td>
      <td width="160">102.64466666666665</td>
      <td width="160">114.367</td>
      <td width="240">0.8975</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">memmove.results[length=4096,align1=0,align2=32].timings[ifuncs=&#x27;generic_memmove&#x27;].arithmetic_mean</td>
      <td width="180">越小越好</td>
      <td width="160">95.08635</td>
      <td width="160">105.245</td>
      <td width="240">0.9035</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">memset.results[length=4096,alignment=0,char=0].timings[ifuncs=&#x27;generic_memset&#x27;].arithmetic_mean</td>
      <td width="180">越小越好</td>
      <td width="160">69.2158</td>
      <td width="160">55.2979</td>
      <td width="240">1.2517</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">strlen.results[length=4096,alignment=0].timings[ifuncs=&#x27;generic_strlen&#x27;].arithmetic_mean</td>
      <td width="180">越小越好</td>
      <td width="160">258.694</td>
      <td width="160">195.494</td>
      <td width="240">1.3233</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">strcmp.results[length=4096,align1=0,align2=0].timings[ifuncs=&#x27;generic_strcmp&#x27;].arithmetic_mean</td>
      <td width="180">越小越好</td>
      <td width="160">289.4304</td>
      <td width="160">365.4688</td>
      <td width="240">0.7919</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">strstr.results[len_haystack=4096,len_needle=64,align_haystack=1,align_needle=11,fail=0].timings[ifuncs=&#x27;twoway_strstr&#x27;].arithmetic_mean</td>
      <td width="180">越小越好</td>
      <td width="160">790.312</td>
      <td width="160">1224.06</td>
      <td width="240">0.6456</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">malloc-simple.results[malloc_block_size=64].main_arena_st_allocs_0100_time</td>
      <td width="180">越小越好</td>
      <td width="160">18.0323</td>
      <td width="160">19.218</td>
      <td width="240">0.9383</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">malloc-tcache.simple[alloc_size=64].time_per_iteration</td>
      <td width="180">越小越好</td>
      <td width="160">5.44163</td>
      <td width="160">6.42287</td>
      <td width="240">0.8472</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">malloc-tcache.optimized[alloc_size=64].time_per_iteration</td>
      <td width="180">越小越好</td>
      <td width="160">4.92903</td>
      <td width="160">5.81633</td>
      <td width="240">0.8474</td>
    </tr>
    <tr>
      <td width="160">glibc</td>
      <td width="140">2.44</td>
      <td width="340">malloc-thread.results[threads=8].time_per_iteration</td>
      <td width="180">越小越好</td>
      <td width="160">8.41609</td>
      <td width="160">9.75522</td>
      <td width="240">0.8627</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
