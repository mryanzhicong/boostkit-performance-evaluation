# x264 0.165.3223 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`40478446346-1`

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
      <td width="1200">0.165.3223</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">0.165.3223</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-10-27T09:11:00Z</td>
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
      <td width="1200">2026-10-27T09:10:18Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">x86_64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">AMD EPYC 9654 96-Core Processor</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="1200">384</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="1200">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="1200">6.6.0-159.4.3.154.oe2403sp4.x86_64</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="1200">3.11.6</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="1200">unknown</td>
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
      <td width="500">x264</td>
      <td width="880">0.165.3223</td>
    </tr>
  </tbody>
</table>

## 性能指标

### 单路

#### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="500">2000k/total_fps</td>
      <td width="280">23.2</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">19.45</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">17.14</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">15.57</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

#### BQTerrace_1920x1080_60-dianbo

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
      <td width="500">2000k/total_fps</td>
      <td width="280">30.16</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">26.95</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">24.77</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">22.84</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

#### messi_1920x1080_25_1000

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
      <td width="500">2000k/total_fps</td>
      <td width="280">28.67</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">24.13</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">21.82</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">20.26</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### 整机

#### Film2012_1920x1080_25_8bit_8Mbps

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
      <td width="500">2000k/total_fps</td>
      <td width="280">834.39</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">702.99</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">619.54</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">562.3</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

#### BQTerrace_1920x1080_60-dianbo

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
      <td width="500">2000k/total_fps</td>
      <td width="280">1122.49</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">999.14</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">908.66</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">832.77</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

#### messi_1920x1080_25_1000

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
      <td width="500">2000k/total_fps</td>
      <td width="280">1034.28</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">4000k/total_fps</td>
      <td width="280">873.75</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">6000k/total_fps</td>
      <td width="280">789.87</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">8000k/total_fps</td>
      <td width="280">734.15</td>
      <td width="200">fps</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
