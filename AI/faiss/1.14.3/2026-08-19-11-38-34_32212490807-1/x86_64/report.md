# faiss 1.14.3 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`32212490807-1`

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
      <td width="1200">1.14.3</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">1.14.3</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-19T03:35:39Z</td>
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
      <td width="1200">2026-08-19T03:32:28Z</td>
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
      <td width="1200">available: 1 nodes (0)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>node 0 size: 30886 MB<br>node 0 free: 17049 MB<br>node distances:<br>node   0 <br>  0:  10</td>
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
      <td width="500">IndexFlatL2/qps</td>
      <td width="280">10909.72319</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">IndexFlatL2/latency_per_query_us</td>
      <td width="280">91.661354</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">IndexFlatL2/recall_at_k</td>
      <td width="280">1.0</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">IndexFlatL2/build_time_s</td>
      <td width="280">0.009045</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">IndexIVFFlat/qps</td>
      <td width="280">158006.840405</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">IndexIVFFlat/latency_per_query_us</td>
      <td width="280">6.32884</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">IndexIVFFlat/recall_at_k</td>
      <td width="280">0.0576</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">IndexIVFFlat/build_time_s</td>
      <td width="280">0.111963</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">IndexHNSWFlat/qps</td>
      <td width="280">91357.063485</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">IndexHNSWFlat/latency_per_query_us</td>
      <td width="280">10.946061</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">IndexHNSWFlat/recall_at_k</td>
      <td width="280">0.2004</td>
      <td width="200">ratio</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">IndexHNSWFlat/build_time_s</td>
      <td width="280">1.96876</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">Kmeans/train/elapsed_s</td>
      <td width="280">0.139971</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">IndexFlatL2/add/vectors_per_second</td>
      <td width="280">10660263.781363</td>
      <td width="200">vectors/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">IndexFlatL2/search/single/latency_us</td>
      <td width="280">1150.150535</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">IndexFlatL2/search/batch/queries_per_second</td>
      <td width="280">11657.297731</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">IndexFlatL2/range_search/queries_per_second</td>
      <td width="280">4254.763124</td>
      <td width="200">queries/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">IndexPQ/add/vectors_per_second</td>
      <td width="280">694103.384354</td>
      <td width="200">vectors/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
