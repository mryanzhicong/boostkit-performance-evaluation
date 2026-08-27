# redis 8.0.6 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`33029591563-1`

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
      <td width="1200">8.0.6</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">8.0.6</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-27T01:17:39Z</td>
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
      <td width="1200">2026-08-27T01:17:12Z</td>
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

## 性能指标

### PING_INLINE

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
      <td width="500">PING_INLINE: requests per second</td>
      <td width="280">146149.69</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### PING_MBULK

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
      <td width="500">PING_MBULK: requests per second</td>
      <td width="280">146849.34</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### SET

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
      <td width="500">SET: requests per second</td>
      <td width="280">128340.05</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### GET

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
      <td width="500">GET: requests per second</td>
      <td width="280">133938.73</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### INCR

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
      <td width="500">INCR: requests per second</td>
      <td width="280">127908.31</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LPUSH

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
      <td width="500">LPUSH: requests per second</td>
      <td width="280">138700.11</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### RPUSH

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
      <td width="500">RPUSH: requests per second</td>
      <td width="280">141049.69</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LPOP

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
      <td width="500">LPOP: requests per second</td>
      <td width="280">139080.12</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### RPOP

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
      <td width="500">RPOP: requests per second</td>
      <td width="280">138727.05</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### SADD

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
      <td width="500">SADD: requests per second</td>
      <td width="280">129587.4</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### HSET

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
      <td width="500">HSET: requests per second</td>
      <td width="280">126736.29</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### SPOP

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
      <td width="500">SPOP: requests per second</td>
      <td width="280">127189.24</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### ZADD

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
      <td width="500">ZADD: requests per second</td>
      <td width="280">88281.51</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### ZPOPMIN

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
      <td width="500">ZPOPMIN: requests per second</td>
      <td width="280">133858.05</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LPUSH (needed to benchmark LRANGE)

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
      <td width="500">LPUSH (needed to benchmark LRANGE): requests per second</td>
      <td width="280">139653.09</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LRANGE_100 (first 100 elements)

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
      <td width="500">LRANGE_100 (first 100 elements): requests per second</td>
      <td width="280">105576.55</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LRANGE_300 (first 300 elements)

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
      <td width="500">LRANGE_300 (first 300 elements): requests per second</td>
      <td width="280">71665.58</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LRANGE_500 (first 500 elements)

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
      <td width="500">LRANGE_500 (first 500 elements): requests per second</td>
      <td width="280">53378.6</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### LRANGE_600 (first 600 elements)

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
      <td width="500">LRANGE_600 (first 600 elements): requests per second</td>
      <td width="280">47258.09</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### MSET (10 keys)

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
      <td width="500">MSET (10 keys): requests per second</td>
      <td width="280">70621.47</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### XADD

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
      <td width="500">XADD: requests per second</td>
      <td width="280">131281.84</td>
      <td width="200">requests/s</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
