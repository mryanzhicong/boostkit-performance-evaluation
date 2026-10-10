# faiss 1.14.3 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`38043065570-1`

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
      <td width="1200">1.14.3</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">1.14.3</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-10-10T10:00:17Z</td>
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
      <td width="1200">2026-10-10T09:54:59Z</td>
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
      <td width="1200">openEuler 24.03 (LTS-SP3)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="1200">6.6.0-132.0.0.111.oe2403sp3.x86_64</td>
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
      <td width="500">sra_test</td>
      <td width="880">9a941bc3fb72c1e0d8dc48e6deb7df33e3e23abf</td>
    </tr>
    <tr>
      <td width="500">faiss</td>
      <td width="880">与被测软件版本一致</td>
    </tr>
  </tbody>
</table>

## 性能指标

### sift-128-euclidean

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
      <td width="500">hnsw/sift-128-euclidean/build_time_s</td>
      <td width="280">22.0817</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/sift-128-euclidean/recall</td>
      <td width="280">0.99135</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/sift-128-euclidean/qps_wall</td>
      <td width="280">35061.9</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/sift-128-euclidean/qps_avg_thread</td>
      <td width="280">39498.7</td>
      <td width="200">queries/s</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

### glove-100-angular

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
      <td width="500">hnsw/glove-100-angular/build_time_s</td>
      <td width="280">86.9358</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/glove-100-angular/recall</td>
      <td width="280">0.99083</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/glove-100-angular/qps_wall</td>
      <td width="280">5367.63</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/glove-100-angular/qps_avg_thread</td>
      <td width="280">5081.87</td>
      <td width="200">queries/s</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

### deep-image-96-angular

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
      <td width="500">hnsw/deep-image-96-angular/build_time_s</td>
      <td width="280">221.316</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/deep-image-96-angular/recall</td>
      <td width="280">0.99089</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/deep-image-96-angular/qps_wall</td>
      <td width="280">30209.5</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/deep-image-96-angular/qps_avg_thread</td>
      <td width="280">29458.2</td>
      <td width="200">queries/s</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

### fashion-mnist-784-euclidean

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
      <td width="500">hnsw/fashion-mnist-784-euclidean/build_time_s</td>
      <td width="280">1.59961</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/fashion-mnist-784-euclidean/recall</td>
      <td width="280">0.99195</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/fashion-mnist-784-euclidean/qps_wall</td>
      <td width="280">119810.0</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/fashion-mnist-784-euclidean/qps_avg_thread</td>
      <td width="280">134565.0</td>
      <td width="200">queries/s</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>

### gist-960-euclidean

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
      <td width="500">hnsw/gist-960-euclidean/build_time_s</td>
      <td width="280">187.915</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/gist-960-euclidean/recall</td>
      <td width="280">0.9905</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/gist-960-euclidean/qps_wall</td>
      <td width="280">3375.32</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">hnsw/gist-960-euclidean/qps_avg_thread</td>
      <td width="280">3759.65</td>
      <td width="200">queries/s</td>
      <td width="400">仅展示</td>
    </tr>
  </tbody>
</table>
