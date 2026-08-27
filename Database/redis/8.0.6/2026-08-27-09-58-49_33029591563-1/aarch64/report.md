# redis 8.0.6 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`33029591563-1`

## 测试环境

### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">请求软件版本</td>
      <td width="1200">8.0.6</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">8.0.6</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-27T01:16:30Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">aarch64</td>
    </tr>
  </tbody>
</table>

### 系统信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="1200">2026-08-27T01:16:02Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">Kunpeng 920 7270Z To be filled by O.E.M. CPU @ 2.9GHz</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="1200">256</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="1200">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="1200">6.6.0-159.4.3.154.oe2403sp4.aarch64</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 128036 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 123576 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127035 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 127429 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
    </tr>
  </tbody>
</table>

## 性能指标

### PING_INLINE

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
      <td width="500">PING_INLINE: requests per second</td>
      <td width="280">110830.34</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### PING_MBULK

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
      <td width="500">PING_MBULK: requests per second</td>
      <td width="280">115717.97</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### SET

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
      <td width="500">SET: requests per second</td>
      <td width="280">103977.12</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### GET

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
      <td width="500">GET: requests per second</td>
      <td width="280">108867.23</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### INCR

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
      <td width="500">INCR: requests per second</td>
      <td width="280">105120.41</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LPUSH

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
      <td width="500">LPUSH: requests per second</td>
      <td width="280">111282.98</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### RPUSH

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
      <td width="500">RPUSH: requests per second</td>
      <td width="280">111533.7</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LPOP

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
      <td width="500">LPOP: requests per second</td>
      <td width="280">108770.14</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### RPOP

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
      <td width="500">RPOP: requests per second</td>
      <td width="280">109751.41</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### SADD

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
      <td width="500">SADD: requests per second</td>
      <td width="280">106169.51</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### HSET

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
      <td width="500">HSET: requests per second</td>
      <td width="280">104307.91</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### SPOP

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
      <td width="500">SPOP: requests per second</td>
      <td width="280">101319.18</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### ZADD

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
      <td width="500">ZADD: requests per second</td>
      <td width="280">76463.7</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### ZPOPMIN

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
      <td width="500">ZPOPMIN: requests per second</td>
      <td width="280">106170.63</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LPUSH (needed to benchmark LRANGE)

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
      <td width="500">LPUSH (needed to benchmark LRANGE): requests per second</td>
      <td width="280">110902.86</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LRANGE_100 (first 100 elements)

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
      <td width="500">LRANGE_100 (first 100 elements): requests per second</td>
      <td width="280">87532.72</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LRANGE_300 (first 300 elements)

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
      <td width="500">LRANGE_300 (first 300 elements): requests per second</td>
      <td width="280">60959.25</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LRANGE_500 (first 500 elements)

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
      <td width="500">LRANGE_500 (first 500 elements): requests per second</td>
      <td width="280">45924.23</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LRANGE_600 (first 600 elements)

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
      <td width="500">LRANGE_600 (first 600 elements): requests per second</td>
      <td width="280">44312.69</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### MSET (10 keys)

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
      <td width="500">MSET (10 keys): requests per second</td>
      <td width="280">60468.26</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### XADD

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
      <td width="500">XADD: requests per second</td>
      <td width="280">103153.4</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
