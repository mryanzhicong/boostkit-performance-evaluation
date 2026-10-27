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
      <td width="180">Media</td>
      <td width="220">x264</td>
      <td width="160">0.165.3223</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### x264 0.165.3223

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
      <td width="600">0.165.3223</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">0.165.3223</td>
      <td width="600">N/A</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-10-27T09:11:00Z</td>
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
      <td width="600">2026-10-27T09:10:18Z</td>
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
      <td width="600">unknown</td>
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
      <td width="500">x264</td>
      <td width="880">0.165.3223</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### x264 0.165.3223

##### 单路

###### BQTerrace_1920x1080_60-dianbo

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

###### Film2012_1920x1080_25_8bit_8Mbps

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

###### messi_1920x1080_25_1000

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

##### 整机

###### BQTerrace_1920x1080_60-dianbo

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

###### Film2012_1920x1080_25_8bit_8Mbps

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

###### messi_1920x1080_25_1000

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
