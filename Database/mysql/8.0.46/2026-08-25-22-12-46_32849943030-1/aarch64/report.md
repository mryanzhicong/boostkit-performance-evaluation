# mysql 8.0.46 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`32849943030-1`

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
      <td width="1200">8.0.46</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">8.0.46</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-25T12:51:23Z</td>
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
      <td width="1200">2026-08-25T12:50:53Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 127984 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 123668 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127331 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 127457 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
    </tr>
  </tbody>
</table>

### 测试工具

<table width="1380">
  <thead>
    <tr>
      <th width="500">工具</th>
      <th width="880">版本</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">database_blue</td>
      <td width="880">af4759227538961f0b0bed5ffc25434d65e7456b</td>
    </tr>
    <tr>
      <td width="500">sysbench</td>
      <td width="880">1.0.17 (d634bce)</td>
    </tr>
  </tbody>
</table>

## 性能指标

### delete

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">transactions（transactions）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">128</td>
      <td width="400">392.14</td>
      <td width="400">1568.57</td>
      <td width="400">23628.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">464.75</td>
      <td width="400">1858.99</td>
      <td width="400">28149.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">475.84</td>
      <td width="400">1903.35</td>
      <td width="400">28960.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">486.8</td>
      <td width="400">1950.86</td>
      <td width="400">29702.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

### distinct

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">transactions（transactions）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">128</td>
      <td width="400">13807.01</td>
      <td width="400">41421.03</td>
      <td width="400">828710.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">8738.83</td>
      <td width="400">26216.48</td>
      <td width="400">524674.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">6318.34</td>
      <td width="400">18955.02</td>
      <td width="400">379587.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">3389.39</td>
      <td width="400">10168.17</td>
      <td width="400">204151.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

### index

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">transactions（transactions）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">128</td>
      <td width="400">178.21</td>
      <td width="400">534.63</td>
      <td width="400">10805.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">182.86</td>
      <td width="400">548.59</td>
      <td width="400">11088.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">191.98</td>
      <td width="400">580.84</td>
      <td width="400">11712.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">177.03</td>
      <td width="400">546.0</td>
      <td width="400">10801.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

### mix

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">transactions（transactions）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">128</td>
      <td width="400">138.22</td>
      <td width="400">2764.44</td>
      <td width="400">8364.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">164.36</td>
      <td width="400">3287.28</td>
      <td width="400">9949.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">136.45</td>
      <td width="400">2858.41</td>
      <td width="400">8324.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">127.9</td>
      <td width="400">2669.73</td>
      <td width="400">7803.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

### nonindex

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">transactions（transactions）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">128</td>
      <td width="400">867.5</td>
      <td width="400">2602.51</td>
      <td width="400">52175.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">877.76</td>
      <td width="400">2633.27</td>
      <td width="400">52823.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">846.46</td>
      <td width="400">2539.38</td>
      <td width="400">50991.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">854.92</td>
      <td width="400">2564.76</td>
      <td width="400">52004.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

### order

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">transactions（transactions）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">128</td>
      <td width="400">14454.39</td>
      <td width="400">43363.18</td>
      <td width="400">867562.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">9106.93</td>
      <td width="400">27320.79</td>
      <td width="400">546783.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">5318.17</td>
      <td width="400">15954.52</td>
      <td width="400">319485.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">2582.24</td>
      <td width="400">7746.71</td>
      <td width="400">155619.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

### point

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">transactions（transactions）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">128</td>
      <td width="400">35878.05</td>
      <td width="400">107634.15</td>
      <td width="400">2153430.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">19819.31</td>
      <td width="400">59457.92</td>
      <td width="400">1189956.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">12606.88</td>
      <td width="400">37820.64</td>
      <td width="400">757329.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">6468.21</td>
      <td width="400">19404.63</td>
      <td width="400">389314.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

### simple

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">transactions（transactions）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">128</td>
      <td width="400">15556.85</td>
      <td width="400">46670.56</td>
      <td width="400">933743.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">9259.88</td>
      <td width="400">27779.63</td>
      <td width="400">555972.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">5476.67</td>
      <td width="400">16430.01</td>
      <td width="400">329000.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">3120.22</td>
      <td width="400">9360.66</td>
      <td width="400">187996.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

### sum

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">transactions（transactions）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">128</td>
      <td width="400">16793.49</td>
      <td width="400">50380.46</td>
      <td width="400">1007961.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">9610.82</td>
      <td width="400">28832.46</td>
      <td width="400">577056.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">5714.42</td>
      <td width="400">17143.26</td>
      <td width="400">343327.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">2866.56</td>
      <td width="400">8599.69</td>
      <td width="400">172700.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。
