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
      <td width="220">mysql</td>
      <td width="160">8.0.46</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Database</td>
      <td width="220">mysql</td>
      <td width="160">8.0.46</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### mysql 8.0.46

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
      <td width="600">8.0.46</td>
      <td width="600">8.0.46</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">8.0.46</td>
      <td width="600">8.0.46</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-08-25T12:52:20Z</td>
      <td width="600">2026-08-25T12:51:23Z</td>
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
      <td width="600">2026-08-25T12:51:54Z</td>
      <td width="600">2026-08-25T12:50:53Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 127984 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 123668 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127331 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 127457 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
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
      <td width="500">database_blue</td>
      <td width="880">af4759227538961f0b0bed5ffc25434d65e7456b</td>
    </tr>
    <tr>
      <td width="500">sysbench</td>
      <td width="880">1.0.17 (d634bce)</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### mysql 8.0.46

##### delete

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
      <td width="400">1385.85</td>
      <td width="400">5543.41</td>
      <td width="400">83225.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">1726.1</td>
      <td width="400">6904.38</td>
      <td width="400">103751.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">2303.28</td>
      <td width="400">9213.14</td>
      <td width="400">139319.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">2182.72</td>
      <td width="400">8730.87</td>
      <td width="400">132787.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

##### distinct

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
      <td width="400">32907.6</td>
      <td width="400">98722.81</td>
      <td width="400">1974853.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">30345.17</td>
      <td width="400">91035.51</td>
      <td width="400">1821493.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">29107.94</td>
      <td width="400">87323.81</td>
      <td width="400">1748013.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">28437.17</td>
      <td width="400">85311.5</td>
      <td width="400">1709195.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

##### index

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
      <td width="400">560.34</td>
      <td width="400">1681.01</td>
      <td width="400">33749.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">798.82</td>
      <td width="400">2396.46</td>
      <td width="400">48076.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">1332.87</td>
      <td width="400">3998.61</td>
      <td width="400">80610.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">1730.83</td>
      <td width="400">5192.5</td>
      <td width="400">104365.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

##### mix

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
      <td width="400">693.79</td>
      <td width="400">13875.79</td>
      <td width="400">41668.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">716.83</td>
      <td width="400">14336.68</td>
      <td width="400">43237.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">701.5</td>
      <td width="400">14030.09</td>
      <td width="400">42616.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">641.68</td>
      <td width="400">12833.7</td>
      <td width="400">39002.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

##### nonindex

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
      <td width="400">3617.74</td>
      <td width="400">10853.22</td>
      <td width="400">218333.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">3846.44</td>
      <td width="400">11539.33</td>
      <td width="400">230896.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">3955.13</td>
      <td width="400">11865.4</td>
      <td width="400">237582.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">4102.7</td>
      <td width="400">12308.1</td>
      <td width="400">246674.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

##### order

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
      <td width="400">31955.22</td>
      <td width="400">95865.66</td>
      <td width="400">1917804.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">33351.5</td>
      <td width="400">100054.51</td>
      <td width="400">2002027.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">32761.87</td>
      <td width="400">98285.6</td>
      <td width="400">1967657.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">31960.18</td>
      <td width="400">95880.54</td>
      <td width="400">1921175.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

##### point

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
      <td width="400">50841.98</td>
      <td width="400">152525.94</td>
      <td width="400">3051162.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">57829.98</td>
      <td width="400">173489.93</td>
      <td width="400">3471258.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">55144.1</td>
      <td width="400">165432.29</td>
      <td width="400">3311970.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">52024.56</td>
      <td width="400">156073.68</td>
      <td width="400">3126981.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

##### simple

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
      <td width="400">37216.69</td>
      <td width="400">111650.07</td>
      <td width="400">2233462.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">39630.29</td>
      <td width="400">118890.88</td>
      <td width="400">2379053.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">38896.54</td>
      <td width="400">116689.62</td>
      <td width="400">2336065.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">37527.52</td>
      <td width="400">112582.56</td>
      <td width="400">2255936.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

##### sum

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
      <td width="400">41156.6</td>
      <td width="400">123469.79</td>
      <td width="400">2469881.0</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">44269.99</td>
      <td width="400">132809.98</td>
      <td width="400">2657453.0</td>
    </tr>
    <tr>
      <td width="180">512</td>
      <td width="400">42436.69</td>
      <td width="400">127310.08</td>
      <td width="400">2548523.0</td>
    </tr>
    <tr>
      <td width="180">1024</td>
      <td width="400">40930.12</td>
      <td width="400">122790.36</td>
      <td width="400">2460592.0</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 和 transactions 均为越大越好。

### aarch64

#### mysql 8.0.46

##### delete

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

##### distinct

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

##### index

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

##### mix

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

##### nonindex

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

##### order

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

##### point

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

##### simple

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

##### sum

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

## 跨架构指标

### mysql 8.0.46

#### delete

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">1385.85</td>
      <td width="190">392.14</td>
      <td width="360">0.283</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">5543.41</td>
      <td width="190">1568.57</td>
      <td width="360">0.283</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">83225.0</td>
      <td width="190">23628.0</td>
      <td width="360">0.2839</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">1726.1</td>
      <td width="190">464.75</td>
      <td width="360">0.2692</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">6904.38</td>
      <td width="190">1858.99</td>
      <td width="360">0.2692</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">103751.0</td>
      <td width="190">28149.0</td>
      <td width="360">0.2713</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">2303.28</td>
      <td width="190">475.84</td>
      <td width="360">0.2066</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">9213.14</td>
      <td width="190">1903.35</td>
      <td width="360">0.2066</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">139319.0</td>
      <td width="190">28960.0</td>
      <td width="360">0.2079</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">2182.72</td>
      <td width="190">486.8</td>
      <td width="360">0.223</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">8730.87</td>
      <td width="190">1950.86</td>
      <td width="360">0.2234</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">132787.0</td>
      <td width="190">29702.0</td>
      <td width="360">0.2237</td>
    </tr>
  </tbody>
</table>

#### distinct

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">32907.6</td>
      <td width="190">13807.01</td>
      <td width="360">0.4196</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">98722.81</td>
      <td width="190">41421.03</td>
      <td width="360">0.4196</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">1974853.0</td>
      <td width="190">828710.0</td>
      <td width="360">0.4196</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">30345.17</td>
      <td width="190">8738.83</td>
      <td width="360">0.288</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">91035.51</td>
      <td width="190">26216.48</td>
      <td width="360">0.288</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">1821493.0</td>
      <td width="190">524674.0</td>
      <td width="360">0.288</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">29107.94</td>
      <td width="190">6318.34</td>
      <td width="360">0.2171</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">87323.81</td>
      <td width="190">18955.02</td>
      <td width="360">0.2171</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">1748013.0</td>
      <td width="190">379587.0</td>
      <td width="360">0.2172</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">28437.17</td>
      <td width="190">3389.39</td>
      <td width="360">0.1192</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">85311.5</td>
      <td width="190">10168.17</td>
      <td width="360">0.1192</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">1709195.0</td>
      <td width="190">204151.0</td>
      <td width="360">0.1194</td>
    </tr>
  </tbody>
</table>

#### index

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">560.34</td>
      <td width="190">178.21</td>
      <td width="360">0.318</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">1681.01</td>
      <td width="190">534.63</td>
      <td width="360">0.318</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">33749.0</td>
      <td width="190">10805.0</td>
      <td width="360">0.3202</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">798.82</td>
      <td width="190">182.86</td>
      <td width="360">0.2289</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">2396.46</td>
      <td width="190">548.59</td>
      <td width="360">0.2289</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">48076.0</td>
      <td width="190">11088.0</td>
      <td width="360">0.2306</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">1332.87</td>
      <td width="190">191.98</td>
      <td width="360">0.144</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">3998.61</td>
      <td width="190">580.84</td>
      <td width="360">0.1453</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">80610.0</td>
      <td width="190">11712.0</td>
      <td width="360">0.1453</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">1730.83</td>
      <td width="190">177.03</td>
      <td width="360">0.1023</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">5192.5</td>
      <td width="190">546.0</td>
      <td width="360">0.1052</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">104365.0</td>
      <td width="190">10801.0</td>
      <td width="360">0.1035</td>
    </tr>
  </tbody>
</table>

#### mix

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">693.79</td>
      <td width="190">138.22</td>
      <td width="360">0.1992</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">13875.79</td>
      <td width="190">2764.44</td>
      <td width="360">0.1992</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">41668.0</td>
      <td width="190">8364.0</td>
      <td width="360">0.2007</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">716.83</td>
      <td width="190">164.36</td>
      <td width="360">0.2293</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">14336.68</td>
      <td width="190">3287.28</td>
      <td width="360">0.2293</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">43237.0</td>
      <td width="190">9949.0</td>
      <td width="360">0.2301</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">701.5</td>
      <td width="190">136.45</td>
      <td width="360">0.1945</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">14030.09</td>
      <td width="190">2858.41</td>
      <td width="360">0.2037</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">42616.0</td>
      <td width="190">8324.0</td>
      <td width="360">0.1953</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">641.68</td>
      <td width="190">127.9</td>
      <td width="360">0.1993</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">12833.7</td>
      <td width="190">2669.73</td>
      <td width="360">0.208</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">39002.0</td>
      <td width="190">7803.0</td>
      <td width="360">0.2001</td>
    </tr>
  </tbody>
</table>

#### nonindex

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">3617.74</td>
      <td width="190">867.5</td>
      <td width="360">0.2398</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">10853.22</td>
      <td width="190">2602.51</td>
      <td width="360">0.2398</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">218333.0</td>
      <td width="190">52175.0</td>
      <td width="360">0.239</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">3846.44</td>
      <td width="190">877.76</td>
      <td width="360">0.2282</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">11539.33</td>
      <td width="190">2633.27</td>
      <td width="360">0.2282</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">230896.0</td>
      <td width="190">52823.0</td>
      <td width="360">0.2288</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">3955.13</td>
      <td width="190">846.46</td>
      <td width="360">0.214</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">11865.4</td>
      <td width="190">2539.38</td>
      <td width="360">0.214</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">237582.0</td>
      <td width="190">50991.0</td>
      <td width="360">0.2146</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">4102.7</td>
      <td width="190">854.92</td>
      <td width="360">0.2084</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">12308.1</td>
      <td width="190">2564.76</td>
      <td width="360">0.2084</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">246674.0</td>
      <td width="190">52004.0</td>
      <td width="360">0.2108</td>
    </tr>
  </tbody>
</table>

#### order

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">31955.22</td>
      <td width="190">14454.39</td>
      <td width="360">0.4523</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">95865.66</td>
      <td width="190">43363.18</td>
      <td width="360">0.4523</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">1917804.0</td>
      <td width="190">867562.0</td>
      <td width="360">0.4524</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">33351.5</td>
      <td width="190">9106.93</td>
      <td width="360">0.2731</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">100054.51</td>
      <td width="190">27320.79</td>
      <td width="360">0.2731</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">2002027.0</td>
      <td width="190">546783.0</td>
      <td width="360">0.2731</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">32761.87</td>
      <td width="190">5318.17</td>
      <td width="360">0.1623</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">98285.6</td>
      <td width="190">15954.52</td>
      <td width="360">0.1623</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">1967657.0</td>
      <td width="190">319485.0</td>
      <td width="360">0.1624</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">31960.18</td>
      <td width="190">2582.24</td>
      <td width="360">0.0808</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">95880.54</td>
      <td width="190">7746.71</td>
      <td width="360">0.0808</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">1921175.0</td>
      <td width="190">155619.0</td>
      <td width="360">0.081</td>
    </tr>
  </tbody>
</table>

#### point

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">50841.98</td>
      <td width="190">35878.05</td>
      <td width="360">0.7057</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">152525.94</td>
      <td width="190">107634.15</td>
      <td width="360">0.7057</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">3051162.0</td>
      <td width="190">2153430.0</td>
      <td width="360">0.7058</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">57829.98</td>
      <td width="190">19819.31</td>
      <td width="360">0.3427</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">173489.93</td>
      <td width="190">59457.92</td>
      <td width="360">0.3427</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">3471258.0</td>
      <td width="190">1189956.0</td>
      <td width="360">0.3428</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">55144.1</td>
      <td width="190">12606.88</td>
      <td width="360">0.2286</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">165432.29</td>
      <td width="190">37820.64</td>
      <td width="360">0.2286</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">3311970.0</td>
      <td width="190">757329.0</td>
      <td width="360">0.2287</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">52024.56</td>
      <td width="190">6468.21</td>
      <td width="360">0.1243</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">156073.68</td>
      <td width="190">19404.63</td>
      <td width="360">0.1243</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">3126981.0</td>
      <td width="190">389314.0</td>
      <td width="360">0.1245</td>
    </tr>
  </tbody>
</table>

#### simple

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">37216.69</td>
      <td width="190">15556.85</td>
      <td width="360">0.418</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">111650.07</td>
      <td width="190">46670.56</td>
      <td width="360">0.418</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">2233462.0</td>
      <td width="190">933743.0</td>
      <td width="360">0.4181</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">39630.29</td>
      <td width="190">9259.88</td>
      <td width="360">0.2337</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">118890.88</td>
      <td width="190">27779.63</td>
      <td width="360">0.2337</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">2379053.0</td>
      <td width="190">555972.0</td>
      <td width="360">0.2337</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">38896.54</td>
      <td width="190">5476.67</td>
      <td width="360">0.1408</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">116689.62</td>
      <td width="190">16430.01</td>
      <td width="360">0.1408</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">2336065.0</td>
      <td width="190">329000.0</td>
      <td width="360">0.1408</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">37527.52</td>
      <td width="190">3120.22</td>
      <td width="360">0.0831</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">112582.56</td>
      <td width="190">9360.66</td>
      <td width="360">0.0831</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">2255936.0</td>
      <td width="190">187996.0</td>
      <td width="360">0.0833</td>
    </tr>
  </tbody>
</table>

#### sum

<table width="1380">
  <thead>
    <tr>
      <th width="150">线程数</th>
      <th width="300">指标</th>
      <th width="190">优化方向</th>
      <th width="190">x86_64</th>
      <th width="190">aarch64</th>
      <th width="360">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="150">128</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">41156.6</td>
      <td width="190">16793.49</td>
      <td width="360">0.408</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">123469.79</td>
      <td width="190">50380.46</td>
      <td width="360">0.408</td>
    </tr>
    <tr>
      <td width="150">128</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">2469881.0</td>
      <td width="190">1007961.0</td>
      <td width="360">0.4081</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">44269.99</td>
      <td width="190">9610.82</td>
      <td width="360">0.2171</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">132809.98</td>
      <td width="190">28832.46</td>
      <td width="360">0.2171</td>
    </tr>
    <tr>
      <td width="150">256</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">2657453.0</td>
      <td width="190">577056.0</td>
      <td width="360">0.2171</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">42436.69</td>
      <td width="190">5714.42</td>
      <td width="360">0.1347</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">127310.08</td>
      <td width="190">17143.26</td>
      <td width="360">0.1347</td>
    </tr>
    <tr>
      <td width="150">512</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">2548523.0</td>
      <td width="190">343327.0</td>
      <td width="360">0.1347</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">TPS（transactions/s）</td>
      <td width="190">越大越好</td>
      <td width="190">40930.12</td>
      <td width="190">2866.56</td>
      <td width="360">0.07</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">QPS（queries/s）</td>
      <td width="190">越大越好</td>
      <td width="190">122790.36</td>
      <td width="190">8599.69</td>
      <td width="360">0.07</td>
    </tr>
    <tr>
      <td width="150">1024</td>
      <td width="300">transactions（transactions）</td>
      <td width="190">越大越好</td>
      <td width="190">2460592.0</td>
      <td width="190">172700.0</td>
      <td width="360">0.0702</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
