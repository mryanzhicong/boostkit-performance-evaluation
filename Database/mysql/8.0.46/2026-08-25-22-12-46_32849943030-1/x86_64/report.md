# mysql 8.0.46 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`32849943030-1`

## 测试环境

### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">x86_64</th>
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
      <td width="1200">2026-08-25T12:52:20Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">x86_64</td>
    </tr>
  </tbody>
</table>

### 系统信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">x86_64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="1200">2026-08-25T12:51:54Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">x86_64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">General Purpose Processor</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="1200">16</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="1200">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="1200">6.6.0-159.4.10.164.oe2403sp4.x86_64</td>
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
      <td width="1200">N/A</td>
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
