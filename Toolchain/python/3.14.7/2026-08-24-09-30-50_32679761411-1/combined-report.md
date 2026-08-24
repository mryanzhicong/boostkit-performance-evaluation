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
      <th width="600">x86</th>
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
      <td width="600">2026-08-24T01:27:27Z</td>
      <td width="600">2026-08-24T01:26:24Z</td>
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
      <th width="600">x86</th>
      <th width="600">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="600">2026-08-24T01:26:38Z</td>
      <td width="600">2026-08-24T01:25:23Z</td>
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
      <td width="600">6.6.0-159.4.3.154.oe2403sp4.x86_64</td>
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
      <td width="600">available: 1 nodes (0)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>node 0 size: 30886 MB<br>node 0 free: 16352 MB<br>node distances:<br>node   0 <br>  0:  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 128005 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 124680 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127324 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 128424 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
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
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">fannkuch</td>
      <td width="200">0.32196139555890113</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">json_dumps</td>
      <td width="200">0.009668483624409419</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">json_loads</td>
      <td width="200">2.114871094818227e-05</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">meteor_contest</td>
      <td width="200">0.08496937149902806</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">nbody</td>
      <td width="200">0.09196124924346805</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">regex_v8</td>
      <td width="200">0.019457916510873474</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">telco</td>
      <td width="200">0.007065380967105739</td>
      <td width="160">s</td>
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
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">fannkuch</td>
      <td width="200">0.47410822997335345</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">json_dumps</td>
      <td width="200">0.013310188121977262</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">json_loads</td>
      <td width="200">3.294399218702893e-05</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">meteor_contest</td>
      <td width="200">0.10761254990939051</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">nbody</td>
      <td width="200">0.10750846983864903</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">regex_v8</td>
      <td width="200">0.025427209373447113</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">python</td>
      <td width="160">3.14.7</td>
      <td width="420">telco</td>
      <td width="200">0.011483862814202439</td>
      <td width="160">s</td>
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
      <td width="160">python</td>
      <td width="140">3.14.7</td>
      <td width="340">fannkuch</td>
      <td width="180">越小越好</td>
      <td width="160">0.32196139555890113</td>
      <td width="160">0.47410822997335345</td>
      <td width="240">0.6791</td>
    </tr>
    <tr>
      <td width="160">python</td>
      <td width="140">3.14.7</td>
      <td width="340">json_dumps</td>
      <td width="180">越小越好</td>
      <td width="160">0.009668483624409419</td>
      <td width="160">0.013310188121977262</td>
      <td width="240">0.7264</td>
    </tr>
    <tr>
      <td width="160">python</td>
      <td width="140">3.14.7</td>
      <td width="340">json_loads</td>
      <td width="180">越小越好</td>
      <td width="160">2.114871094818227e-05</td>
      <td width="160">3.294399218702893e-05</td>
      <td width="240">0.642</td>
    </tr>
    <tr>
      <td width="160">python</td>
      <td width="140">3.14.7</td>
      <td width="340">meteor_contest</td>
      <td width="180">越小越好</td>
      <td width="160">0.08496937149902806</td>
      <td width="160">0.10761254990939051</td>
      <td width="240">0.7896</td>
    </tr>
    <tr>
      <td width="160">python</td>
      <td width="140">3.14.7</td>
      <td width="340">nbody</td>
      <td width="180">越小越好</td>
      <td width="160">0.09196124924346805</td>
      <td width="160">0.10750846983864903</td>
      <td width="240">0.8554</td>
    </tr>
    <tr>
      <td width="160">python</td>
      <td width="140">3.14.7</td>
      <td width="340">regex_v8</td>
      <td width="180">越小越好</td>
      <td width="160">0.019457916510873474</td>
      <td width="160">0.025427209373447113</td>
      <td width="240">0.7652</td>
    </tr>
    <tr>
      <td width="160">python</td>
      <td width="140">3.14.7</td>
      <td width="340">telco</td>
      <td width="180">越小越好</td>
      <td width="160">0.007065380967105739</td>
      <td width="160">0.011483862814202439</td>
      <td width="240">0.6152</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
