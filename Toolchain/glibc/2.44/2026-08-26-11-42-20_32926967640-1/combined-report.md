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
      <td width="600">2026-08-26T03:36:40Z</td>
      <td width="600">2026-08-26T03:35:11Z</td>
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
      <td width="600">2026-08-26T03:35:03Z</td>
      <td width="600">2026-08-26T03:34:05Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 127949 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 123648 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127029 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 127442 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### glibc 2.44

##### 数学函数

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
      <td width="500">math-inlines.isnan.normal.mean</td>
      <td width="280">1434.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isinf.normal.mean</td>
      <td width="280">1990.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isfinite.normal.mean</td>
      <td width="280">1434.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isnormal.normal.mean</td>
      <td width="280">1784.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 标准 I/O

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
      <td width="500">sprintf.positional.mean</td>
      <td width="280">298.436</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sprintf.non-positional.mean</td>
      <td width="280">167.781</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fclose.duration</td>
      <td width="280">35041.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 随机数锁

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
      <td width="500">random.single-threaded</td>
      <td width="280">4.52691</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">random.multi-threaded</td>
      <td width="280">4.3746</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 字符串与内存

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
      <td width="500">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=0].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="280">100.77266666666667</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">memmove.results[length=4096,align1=0,align2=32].timings[ifuncs=&#x27;generic_memmove&#x27;].arithmetic_mean</td>
      <td width="280">95.3566</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">memset.results[length=4096,alignment=0,char=0].timings[ifuncs=&#x27;generic_memset&#x27;].arithmetic_mean</td>
      <td width="280">69.8274</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">strlen.results[length=4096,alignment=0].timings[ifuncs=&#x27;generic_strlen&#x27;].arithmetic_mean</td>
      <td width="280">258.4635</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">strcmp.results[length=4096,align1=0,align2=0].timings[ifuncs=&#x27;generic_strcmp&#x27;].arithmetic_mean</td>
      <td width="280">288.9718</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">strstr.results[len_haystack=4096,len_needle=64,align_haystack=1,align_needle=11,fail=0].timings[ifuncs=&#x27;twoway_strstr&#x27;].arithmetic_mean</td>
      <td width="280">787.531</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 内存分配

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
      <td width="500">malloc-simple.results[malloc_block_size=64].main_arena_st_allocs_0100_time</td>
      <td width="280">18.0777</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">malloc-tcache.optimized[alloc_size=64].time_per_iteration</td>
      <td width="280">6.02668</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">malloc-thread.results[threads=8].time_per_iteration</td>
      <td width="280">8.50041</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### glibc 2.44

##### 数学函数

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
      <td width="500">math-inlines.isnan.normal.mean</td>
      <td width="280">1108.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isinf.normal.mean</td>
      <td width="280">1461.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isfinite.normal.mean</td>
      <td width="280">1217.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isnormal.normal.mean</td>
      <td width="280">2382.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 标准 I/O

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
      <td width="500">sprintf.positional.mean</td>
      <td width="280">461.904</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sprintf.non-positional.mean</td>
      <td width="280">244.67</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fclose.duration</td>
      <td width="280">27790.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 随机数锁

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
      <td width="500">random.single-threaded</td>
      <td width="280">3.67917</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">random.multi-threaded</td>
      <td width="280">21.4221</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 字符串与内存

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
      <td width="500">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=0].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="280">114.371</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">memmove.results[length=4096,align1=0,align2=32].timings[ifuncs=&#x27;generic_memmove&#x27;].arithmetic_mean</td>
      <td width="280">105.24000000000001</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">memset.results[length=4096,alignment=0,char=0].timings[ifuncs=&#x27;generic_memset&#x27;].arithmetic_mean</td>
      <td width="280">55.293</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">strlen.results[length=4096,alignment=0].timings[ifuncs=&#x27;generic_strlen&#x27;].arithmetic_mean</td>
      <td width="280">196.3495</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">strcmp.results[length=4096,align1=0,align2=0].timings[ifuncs=&#x27;generic_strcmp&#x27;].arithmetic_mean</td>
      <td width="280">363.9838</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">strstr.results[len_haystack=4096,len_needle=64,align_haystack=1,align_needle=11,fail=0].timings[ifuncs=&#x27;twoway_strstr&#x27;].arithmetic_mean</td>
      <td width="280">1206.25</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### 内存分配

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
      <td width="500">malloc-simple.results[malloc_block_size=64].main_arena_st_allocs_0100_time</td>
      <td width="280">19.4139</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">malloc-tcache.optimized[alloc_size=64].time_per_iteration</td>
      <td width="280">5.82084</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">malloc-thread.results[threads=8].time_per_iteration</td>
      <td width="280">9.7655</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### glibc 2.44

#### 数学函数

<table width="1380">
  <thead>
    <tr>
      <th width="380">指标</th>
      <th width="200">优化方向</th>
      <th width="180">x86_64</th>
      <th width="180">aarch64</th>
      <th width="220">ARM/x86 原始比值</th>
      <th width="220">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="380">math-inlines.isnan.normal.mean</td>
      <td width="200">越小越好</td>
      <td width="180">1434.0</td>
      <td width="180">1108.0</td>
      <td width="220">0.7727</td>
      <td width="220">1.2942</td>
    </tr>
    <tr>
      <td width="380">math-inlines.isinf.normal.mean</td>
      <td width="200">越小越好</td>
      <td width="180">1990.0</td>
      <td width="180">1461.0</td>
      <td width="220">0.7342</td>
      <td width="220">1.3621</td>
    </tr>
    <tr>
      <td width="380">math-inlines.isfinite.normal.mean</td>
      <td width="200">越小越好</td>
      <td width="180">1434.0</td>
      <td width="180">1217.0</td>
      <td width="220">0.8487</td>
      <td width="220">1.1783</td>
    </tr>
    <tr>
      <td width="380">math-inlines.isnormal.normal.mean</td>
      <td width="200">越小越好</td>
      <td width="180">1784.0</td>
      <td width="180">2382.0</td>
      <td width="220">1.3352</td>
      <td width="220">0.749</td>
    </tr>
  </tbody>
</table>

#### 标准 I/O

<table width="1380">
  <thead>
    <tr>
      <th width="380">指标</th>
      <th width="200">优化方向</th>
      <th width="180">x86_64</th>
      <th width="180">aarch64</th>
      <th width="220">ARM/x86 原始比值</th>
      <th width="220">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="380">sprintf.positional.mean</td>
      <td width="200">越小越好</td>
      <td width="180">298.436</td>
      <td width="180">461.904</td>
      <td width="220">1.5477</td>
      <td width="220">0.6461</td>
    </tr>
    <tr>
      <td width="380">sprintf.non-positional.mean</td>
      <td width="200">越小越好</td>
      <td width="180">167.781</td>
      <td width="180">244.67</td>
      <td width="220">1.4583</td>
      <td width="220">0.6857</td>
    </tr>
    <tr>
      <td width="380">fclose.duration</td>
      <td width="200">越小越好</td>
      <td width="180">35041.0</td>
      <td width="180">27790.0</td>
      <td width="220">0.7931</td>
      <td width="220">1.2609</td>
    </tr>
  </tbody>
</table>

#### 随机数锁

<table width="1380">
  <thead>
    <tr>
      <th width="380">指标</th>
      <th width="200">优化方向</th>
      <th width="180">x86_64</th>
      <th width="180">aarch64</th>
      <th width="220">ARM/x86 原始比值</th>
      <th width="220">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="380">random.single-threaded</td>
      <td width="200">越小越好</td>
      <td width="180">4.52691</td>
      <td width="180">3.67917</td>
      <td width="220">0.8127</td>
      <td width="220">1.2304</td>
    </tr>
    <tr>
      <td width="380">random.multi-threaded</td>
      <td width="200">越小越好</td>
      <td width="180">4.3746</td>
      <td width="180">21.4221</td>
      <td width="220">4.8969</td>
      <td width="220">0.2042</td>
    </tr>
  </tbody>
</table>

#### 字符串与内存

<table width="1380">
  <thead>
    <tr>
      <th width="380">指标</th>
      <th width="200">优化方向</th>
      <th width="180">x86_64</th>
      <th width="180">aarch64</th>
      <th width="220">ARM/x86 原始比值</th>
      <th width="220">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="380">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=0].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="200">越小越好</td>
      <td width="180">100.77266666666667</td>
      <td width="180">114.371</td>
      <td width="220">1.1349</td>
      <td width="220">0.8811</td>
    </tr>
    <tr>
      <td width="380">memmove.results[length=4096,align1=0,align2=32].timings[ifuncs=&#x27;generic_memmove&#x27;].arithmetic_mean</td>
      <td width="200">越小越好</td>
      <td width="180">95.3566</td>
      <td width="180">105.24000000000001</td>
      <td width="220">1.1036</td>
      <td width="220">0.9061</td>
    </tr>
    <tr>
      <td width="380">memset.results[length=4096,alignment=0,char=0].timings[ifuncs=&#x27;generic_memset&#x27;].arithmetic_mean</td>
      <td width="200">越小越好</td>
      <td width="180">69.8274</td>
      <td width="180">55.293</td>
      <td width="220">0.7919</td>
      <td width="220">1.2629</td>
    </tr>
    <tr>
      <td width="380">strlen.results[length=4096,alignment=0].timings[ifuncs=&#x27;generic_strlen&#x27;].arithmetic_mean</td>
      <td width="200">越小越好</td>
      <td width="180">258.4635</td>
      <td width="180">196.3495</td>
      <td width="220">0.7597</td>
      <td width="220">1.3163</td>
    </tr>
    <tr>
      <td width="380">strcmp.results[length=4096,align1=0,align2=0].timings[ifuncs=&#x27;generic_strcmp&#x27;].arithmetic_mean</td>
      <td width="200">越小越好</td>
      <td width="180">288.9718</td>
      <td width="180">363.9838</td>
      <td width="220">1.2596</td>
      <td width="220">0.7939</td>
    </tr>
    <tr>
      <td width="380">strstr.results[len_haystack=4096,len_needle=64,align_haystack=1,align_needle=11,fail=0].timings[ifuncs=&#x27;twoway_strstr&#x27;].arithmetic_mean</td>
      <td width="200">越小越好</td>
      <td width="180">787.531</td>
      <td width="180">1206.25</td>
      <td width="220">1.5317</td>
      <td width="220">0.6529</td>
    </tr>
  </tbody>
</table>

#### 内存分配

<table width="1380">
  <thead>
    <tr>
      <th width="380">指标</th>
      <th width="200">优化方向</th>
      <th width="180">x86_64</th>
      <th width="180">aarch64</th>
      <th width="220">ARM/x86 原始比值</th>
      <th width="220">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="380">malloc-simple.results[malloc_block_size=64].main_arena_st_allocs_0100_time</td>
      <td width="200">越小越好</td>
      <td width="180">18.0777</td>
      <td width="180">19.4139</td>
      <td width="220">1.0739</td>
      <td width="220">0.9312</td>
    </tr>
    <tr>
      <td width="380">malloc-tcache.optimized[alloc_size=64].time_per_iteration</td>
      <td width="200">越小越好</td>
      <td width="180">6.02668</td>
      <td width="180">5.82084</td>
      <td width="220">0.9658</td>
      <td width="220">1.0354</td>
    </tr>
    <tr>
      <td width="380">malloc-thread.results[threads=8].time_per_iteration</td>
      <td width="200">越小越好</td>
      <td width="180">8.50041</td>
      <td width="180">9.7655</td>
      <td width="220">1.1488</td>
      <td width="220">0.8705</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
