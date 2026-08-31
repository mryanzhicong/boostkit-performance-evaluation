# envoy 1.39.1 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`33368362497-1`

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
      <td width="1200">1.39.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">1.39.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-31T07:26:34Z</td>
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
      <td width="1200">2026-08-31T07:26:29Z</td>
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
      <td width="500">k6</td>
      <td width="880">2.2.0</td>
    </tr>
  </tbody>
</table>

## 性能指标

### HTTPS direct response

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
      <td width="500">direct_response :: http_reqs.count</td>
      <td width="280">153905.0</td>
      <td width="200">requests</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">direct_response :: http_reqs.rate</td>
      <td width="280">7693.405068764686</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">direct_response :: http_req_duration.avg</td>
      <td width="280">1.397815928520842</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">direct_response :: http_req_duration.p(95)</td>
      <td width="280">3.9897359999999997</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### HTTPS reverse proxy

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
      <td width="500">reverse_proxy :: http_reqs.count</td>
      <td width="280">139850.0</td>
      <td width="200">requests</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reverse_proxy :: http_reqs.rate</td>
      <td width="280">6991.351662099878</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">reverse_proxy :: http_req_duration.avg</td>
      <td width="280">2.005362793972103</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">reverse_proxy :: http_req_duration.p(95)</td>
      <td width="280">5.868132499999999</td>
      <td width="200">ms</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
