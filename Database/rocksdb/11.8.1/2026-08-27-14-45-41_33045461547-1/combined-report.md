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
      <td width="180">Database</td>
      <td width="220">rocksdb</td>
      <td width="160">11.8.1</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Database</td>
      <td width="220">rocksdb</td>
      <td width="160">11.8.1</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### rocksdb 11.8.1

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
      <td width="600">11.8.1</td>
      <td width="600">11.8.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">11.8.1</td>
      <td width="600">11.8.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-08-27T06:22:13Z</td>
      <td width="600">2026-08-27T06:19:39Z</td>
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
      <td width="600">2026-08-27T06:19:53Z</td>
      <td width="600">2026-08-27T06:18:37Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 127960 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 123560 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 126983 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 127379 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
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
      <td width="500">db_bench</td>
      <td width="880">RocksDB 11.8.1</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### rocksdb 11.8.1

##### 64B key / 128B value

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
      <td width="500">64B key / 128B value: pre_fillseq 1 threads micros/op</td>
      <td width="280">0.725</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: pre_fillseq 1 threads ops/sec</td>
      <td width="280">1379805.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: pre_overwrite 1 threads micros/op</td>
      <td width="280">1.955</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: pre_overwrite 1 threads ops/sec</td>
      <td width="280">511618.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 1 threads micros/op</td>
      <td width="280">2.253</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 1 threads ops/sec</td>
      <td width="280">443927.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 16 threads micros/op</td>
      <td width="280">42.881</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 16 threads ops/sec</td>
      <td width="280">373113.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 1 threads micros/op</td>
      <td width="280">763.99</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 1 threads ops/sec</td>
      <td width="280">1308.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 16 threads micros/op</td>
      <td width="280">1209.651</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 16 threads ops/sec</td>
      <td width="280">13203.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="280">160.523</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="280">6229.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="280">674.83</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="280">23691.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 64B key / 512B value

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
      <td width="500">64B key / 512B value: pre_fillseq 1 threads micros/op</td>
      <td width="280">2.18</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: pre_fillseq 1 threads ops/sec</td>
      <td width="280">458775.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: pre_overwrite 1 threads micros/op</td>
      <td width="280">5.904</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: pre_overwrite 1 threads ops/sec</td>
      <td width="280">169373.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 1 threads micros/op</td>
      <td width="280">8.11</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 1 threads ops/sec</td>
      <td width="280">123296.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 16 threads micros/op</td>
      <td width="280">865.338</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 16 threads ops/sec</td>
      <td width="280">18489.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 1 threads micros/op</td>
      <td width="280">1958.654</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 1 threads ops/sec</td>
      <td width="280">510.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 16 threads micros/op</td>
      <td width="280">2774.499</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 16 threads ops/sec</td>
      <td width="280">5726.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="280">456.883</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="280">2188.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="280">1194.818</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="280">13373.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 128B key / 1024B value

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
      <td width="500">128B key / 1024B value: pre_fillseq 1 threads micros/op</td>
      <td width="280">4.361</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: pre_fillseq 1 threads ops/sec</td>
      <td width="280">229280.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: pre_overwrite 1 threads micros/op</td>
      <td width="280">11.618</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: pre_overwrite 1 threads ops/sec</td>
      <td width="280">86072.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 1 threads micros/op</td>
      <td width="280">75.321</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 1 threads ops/sec</td>
      <td width="280">13276.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 16 threads micros/op</td>
      <td width="280">3348.078</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 16 threads ops/sec</td>
      <td width="280">4771.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 1 threads micros/op</td>
      <td width="280">1316.746</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 1 threads ops/sec</td>
      <td width="280">759.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 16 threads micros/op</td>
      <td width="280">3382.185</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 16 threads ops/sec</td>
      <td width="280">4713.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="280">904.872</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="280">1105.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="280">2374.653</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="280">6718.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### rocksdb 11.8.1

##### 64B key / 128B value

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
      <td width="500">64B key / 128B value: pre_fillseq 1 threads micros/op</td>
      <td width="280">0.739</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: pre_fillseq 1 threads ops/sec</td>
      <td width="280">1353787.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: pre_overwrite 1 threads micros/op</td>
      <td width="280">1.786</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: pre_overwrite 1 threads ops/sec</td>
      <td width="280">560024.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 1 threads micros/op</td>
      <td width="280">1.865</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 1 threads ops/sec</td>
      <td width="280">536059.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 16 threads micros/op</td>
      <td width="280">35.527</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 16 threads ops/sec</td>
      <td width="280">450351.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 1 threads micros/op</td>
      <td width="280">462.9</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 1 threads ops/sec</td>
      <td width="280">2160.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 16 threads micros/op</td>
      <td width="280">561.207</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 16 threads ops/sec</td>
      <td width="280">28457.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="280">108.404</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="280">9224.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="280">374.894</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="280">42632.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 64B key / 512B value

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
      <td width="500">64B key / 512B value: pre_fillseq 1 threads micros/op</td>
      <td width="280">1.662</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: pre_fillseq 1 threads ops/sec</td>
      <td width="280">601840.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: pre_overwrite 1 threads micros/op</td>
      <td width="280">4.833</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: pre_overwrite 1 threads ops/sec</td>
      <td width="280">206897.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 1 threads micros/op</td>
      <td width="280">6.594</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 1 threads ops/sec</td>
      <td width="280">151664.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 16 threads micros/op</td>
      <td width="280">621.006</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 16 threads ops/sec</td>
      <td width="280">25764.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 1 threads micros/op</td>
      <td width="280">1095.789</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 1 threads ops/sec</td>
      <td width="280">912.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 16 threads micros/op</td>
      <td width="280">991.395</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 16 threads ops/sec</td>
      <td width="280">16114.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="280">220.196</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="280">4541.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="280">660.487</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="280">24169.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

##### 128B key / 1024B value

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
      <td width="500">128B key / 1024B value: pre_fillseq 1 threads micros/op</td>
      <td width="280">3.051</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: pre_fillseq 1 threads ops/sec</td>
      <td width="280">327755.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: pre_overwrite 1 threads micros/op</td>
      <td width="280">9.953</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: pre_overwrite 1 threads ops/sec</td>
      <td width="280">100473.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 1 threads micros/op</td>
      <td width="280">17.603</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 1 threads ops/sec</td>
      <td width="280">56809.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 16 threads micros/op</td>
      <td width="280">3331.583</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 16 threads ops/sec</td>
      <td width="280">4771.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 1 threads micros/op</td>
      <td width="280">1263.91</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 1 threads ops/sec</td>
      <td width="280">791.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 16 threads micros/op</td>
      <td width="280">1366.804</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 16 threads ops/sec</td>
      <td width="280">11691.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="280">885.173</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="280">1129.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="280">1007.7</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="280">15854.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### rocksdb 11.8.1

#### 64B key / 128B value

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
      <td width="380">64B key / 128B value: pre_fillseq 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">0.725</td>
      <td width="180">0.739</td>
      <td width="220">1.0193</td>
      <td width="220">0.9811</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: pre_fillseq 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">1379805.0</td>
      <td width="180">1353787.0</td>
      <td width="220">0.9811</td>
      <td width="220">0.9811</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: pre_overwrite 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">1.955</td>
      <td width="180">1.786</td>
      <td width="220">0.9136</td>
      <td width="220">1.0946</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: pre_overwrite 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">511618.0</td>
      <td width="180">560024.0</td>
      <td width="220">1.0946</td>
      <td width="220">1.0946</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: overwrite 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">2.253</td>
      <td width="180">1.865</td>
      <td width="220">0.8278</td>
      <td width="220">1.208</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: overwrite 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">443927.0</td>
      <td width="180">536059.0</td>
      <td width="220">1.2075</td>
      <td width="220">1.2075</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: overwrite 16 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">42.881</td>
      <td width="180">35.527</td>
      <td width="220">0.8285</td>
      <td width="220">1.207</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: overwrite 16 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">373113.0</td>
      <td width="180">450351.0</td>
      <td width="220">1.207</td>
      <td width="220">1.207</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: readrandom 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">763.99</td>
      <td width="180">462.9</td>
      <td width="220">0.6059</td>
      <td width="220">1.6504</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: readrandom 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">1308.0</td>
      <td width="180">2160.0</td>
      <td width="220">1.6514</td>
      <td width="220">1.6514</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: readrandom 16 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">1209.651</td>
      <td width="180">561.207</td>
      <td width="220">0.4639</td>
      <td width="220">2.1554</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: readrandom 16 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">13203.0</td>
      <td width="180">28457.0</td>
      <td width="220">2.1553</td>
      <td width="220">2.1553</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">160.523</td>
      <td width="180">108.404</td>
      <td width="220">0.6753</td>
      <td width="220">1.4808</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">6229.0</td>
      <td width="180">9224.0</td>
      <td width="220">1.4808</td>
      <td width="220">1.4808</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">674.83</td>
      <td width="180">374.894</td>
      <td width="220">0.5555</td>
      <td width="220">1.8001</td>
    </tr>
    <tr>
      <td width="380">64B key / 128B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">23691.0</td>
      <td width="180">42632.0</td>
      <td width="220">1.7995</td>
      <td width="220">1.7995</td>
    </tr>
  </tbody>
</table>

#### 64B key / 512B value

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
      <td width="380">64B key / 512B value: pre_fillseq 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">2.18</td>
      <td width="180">1.662</td>
      <td width="220">0.7624</td>
      <td width="220">1.3117</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: pre_fillseq 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">458775.0</td>
      <td width="180">601840.0</td>
      <td width="220">1.3118</td>
      <td width="220">1.3118</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: pre_overwrite 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">5.904</td>
      <td width="180">4.833</td>
      <td width="220">0.8186</td>
      <td width="220">1.2216</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: pre_overwrite 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">169373.0</td>
      <td width="180">206897.0</td>
      <td width="220">1.2215</td>
      <td width="220">1.2215</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: overwrite 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">8.11</td>
      <td width="180">6.594</td>
      <td width="220">0.8131</td>
      <td width="220">1.2299</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: overwrite 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">123296.0</td>
      <td width="180">151664.0</td>
      <td width="220">1.2301</td>
      <td width="220">1.2301</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: overwrite 16 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">865.338</td>
      <td width="180">621.006</td>
      <td width="220">0.7176</td>
      <td width="220">1.3934</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: overwrite 16 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">18489.0</td>
      <td width="180">25764.0</td>
      <td width="220">1.3935</td>
      <td width="220">1.3935</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: readrandom 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">1958.654</td>
      <td width="180">1095.789</td>
      <td width="220">0.5595</td>
      <td width="220">1.7874</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: readrandom 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">510.0</td>
      <td width="180">912.0</td>
      <td width="220">1.7882</td>
      <td width="220">1.7882</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: readrandom 16 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">2774.499</td>
      <td width="180">991.395</td>
      <td width="220">0.3573</td>
      <td width="220">2.7986</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: readrandom 16 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">5726.0</td>
      <td width="180">16114.0</td>
      <td width="220">2.8142</td>
      <td width="220">2.8142</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">456.883</td>
      <td width="180">220.196</td>
      <td width="220">0.482</td>
      <td width="220">2.0749</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">2188.0</td>
      <td width="180">4541.0</td>
      <td width="220">2.0754</td>
      <td width="220">2.0754</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">1194.818</td>
      <td width="180">660.487</td>
      <td width="220">0.5528</td>
      <td width="220">1.809</td>
    </tr>
    <tr>
      <td width="380">64B key / 512B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">13373.0</td>
      <td width="180">24169.0</td>
      <td width="220">1.8073</td>
      <td width="220">1.8073</td>
    </tr>
  </tbody>
</table>

#### 128B key / 1024B value

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
      <td width="380">128B key / 1024B value: pre_fillseq 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">4.361</td>
      <td width="180">3.051</td>
      <td width="220">0.6996</td>
      <td width="220">1.4294</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: pre_fillseq 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">229280.0</td>
      <td width="180">327755.0</td>
      <td width="220">1.4295</td>
      <td width="220">1.4295</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: pre_overwrite 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">11.618</td>
      <td width="180">9.953</td>
      <td width="220">0.8567</td>
      <td width="220">1.1673</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: pre_overwrite 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">86072.0</td>
      <td width="180">100473.0</td>
      <td width="220">1.1673</td>
      <td width="220">1.1673</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: overwrite 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">75.321</td>
      <td width="180">17.603</td>
      <td width="220">0.2337</td>
      <td width="220">4.2789</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: overwrite 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">13276.0</td>
      <td width="180">56809.0</td>
      <td width="220">4.2791</td>
      <td width="220">4.2791</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: overwrite 16 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">3348.078</td>
      <td width="180">3331.583</td>
      <td width="220">0.9951</td>
      <td width="220">1.005</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: overwrite 16 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">4771.0</td>
      <td width="180">4771.0</td>
      <td width="220">1.0</td>
      <td width="220">1.0</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: readrandom 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">1316.746</td>
      <td width="180">1263.91</td>
      <td width="220">0.9599</td>
      <td width="220">1.0418</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: readrandom 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">759.0</td>
      <td width="180">791.0</td>
      <td width="220">1.0422</td>
      <td width="220">1.0422</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: readrandom 16 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">3382.185</td>
      <td width="180">1366.804</td>
      <td width="220">0.4041</td>
      <td width="220">2.4745</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: readrandom 16 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">4713.0</td>
      <td width="180">11691.0</td>
      <td width="220">2.4806</td>
      <td width="220">2.4806</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">904.872</td>
      <td width="180">885.173</td>
      <td width="220">0.9782</td>
      <td width="220">1.0223</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">1105.0</td>
      <td width="180">1129.0</td>
      <td width="220">1.0217</td>
      <td width="220">1.0217</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="200">越小越好</td>
      <td width="180">2374.653</td>
      <td width="180">1007.7</td>
      <td width="220">0.4244</td>
      <td width="220">2.3565</td>
    </tr>
    <tr>
      <td width="380">128B key / 1024B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="200">越大越好</td>
      <td width="180">6718.0</td>
      <td width="180">15854.0</td>
      <td width="220">2.3599</td>
      <td width="220">2.3599</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
