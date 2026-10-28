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
      <td width="180">Database</td>
      <td width="220">mysql</td>
      <td width="160">8.0.43</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### mysql 8.0.43

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
      <td width="600">8.0.43</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">8.0.43</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-10-28T03:45:26Z</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">N/A</td>
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
      <td width="600">2026-10-28T03:45:00Z</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">AMD EPYC 9654 96-Core Processor</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">384</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0-159.4.3.154.oe2403sp4.x86_64</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="600">3.11.6</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="600">12.3.1</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">glibc 版本</td>
      <td width="600">glibc 2.38</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">NUMA</td>
      <td width="600">N/A</td>
      <td width="600">N/A</td>
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
      <td width="500">sysbench</td>
      <td width="880">1.0.20 (ebf1c90)</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### mysql 8.0.43

##### read_only

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">P95 latency（ms）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">1</td>
      <td width="400">854.84</td>
      <td width="400">13677.39</td>
      <td width="400">1.21</td>
    </tr>
    <tr>
      <td width="180">32</td>
      <td width="400">4650.04</td>
      <td width="400">74400.65</td>
      <td width="400">70.55</td>
    </tr>
    <tr>
      <td width="180">128</td>
      <td width="400">3133.78</td>
      <td width="400">50140.5</td>
      <td width="400">95.81</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">2300.47</td>
      <td width="400">36807.54</td>
      <td width="400">207.82</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 越大越好；P95 延迟越小越好。

##### read_write

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">P95 latency（ms）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">1</td>
      <td width="400">384.79</td>
      <td width="400">7695.81</td>
      <td width="400">4.91</td>
    </tr>
    <tr>
      <td width="180">32</td>
      <td width="400">1087.57</td>
      <td width="400">21751.36</td>
      <td width="400">77.19</td>
    </tr>
    <tr>
      <td width="180">128</td>
      <td width="400">679.13</td>
      <td width="400">13582.56</td>
      <td width="400">297.92</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">492.88</td>
      <td width="400">9857.55</td>
      <td width="400">877.61</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 越大越好；P95 延迟越小越好。

##### write_only

<table width="1380">
  <thead>
    <tr>
      <th width="180">线程数</th>
      <th width="400">TPS（transactions/s）</th>
      <th width="400">QPS（queries/s）</th>
      <th width="400">P95 latency（ms）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">1</td>
      <td width="400">576.58</td>
      <td width="400">3459.48</td>
      <td width="400">2.66</td>
    </tr>
    <tr>
      <td width="180">32</td>
      <td width="400">2076.46</td>
      <td width="400">12458.78</td>
      <td width="400">56.84</td>
    </tr>
    <tr>
      <td width="180">128</td>
      <td width="400">1462.22</td>
      <td width="400">8773.34</td>
      <td width="400">134.9</td>
    </tr>
    <tr>
      <td width="180">256</td>
      <td width="400">966.99</td>
      <td width="400">5801.96</td>
      <td width="400">404.61</td>
    </tr>
  </tbody>
</table>

> TPS、QPS 越大越好；P95 延迟越小越好。
