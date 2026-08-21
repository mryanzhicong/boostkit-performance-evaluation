# protobuf 35.1 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`32439734023-1`

## 测试环境

### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">x86</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">请求软件版本</td>
      <td width="1200">35.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">35.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-21T02:27:17Z</td>
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
      <th width="1200">x86</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="1200">2026-08-21T02:24:22Z</td>
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
      <td width="1200">6.6.0-159.4.3.154.oe2403sp4.x86_64</td>
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
      <td width="1200">available: 1 nodes (0)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>node 0 size: 30886 MB<br>node 0 free: 16729 MB<br>node distances:<br>node   0 <br>  0:  10</td>
    </tr>
  </tbody>
</table>

## 性能指标

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
      <td width="500">avg_serialize_qps_size100</td>
      <td width="280">2776472.61</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">max_serialize_qps_size100</td>
      <td width="280">5151441.91</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">avg_deserialize_qps_size100</td>
      <td width="280">1336095.26</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">max_deserialize_qps_size100</td>
      <td width="280">2843595.93</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">avg_fidelity_size100</td>
      <td width="280">1.0</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">avg_serialize_latency_us_size100</td>
      <td width="280">0.752</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">max_serialize_latency_us_size100</td>
      <td width="280">2.2844</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">single_serialize_qps</td>
      <td width="280">4264671.07</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">single_deserialize_qps</td>
      <td width="280">2736010.44</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">multithread_serialize_scaling_ratio</td>
      <td width="280">0.76</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">multithread_deserialize_scaling_ratio</td>
      <td width="280">1.58</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">binary_vs_json_qps_ratio</td>
      <td width="280">78.24</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
