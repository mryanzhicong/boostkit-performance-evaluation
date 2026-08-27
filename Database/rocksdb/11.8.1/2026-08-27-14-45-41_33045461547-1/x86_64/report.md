# rocksdb 11.8.1 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`33045461547-1`

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
      <td width="1200">11.8.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">11.8.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-27T06:22:13Z</td>
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
      <td width="1200">2026-08-27T06:19:53Z</td>
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
      <td width="500">db_bench</td>
      <td width="880">RocksDB 11.8.1</td>
    </tr>
  </tbody>
</table>

## 性能指标

### 64B key / 128B value

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
      <td width="500">64B key / 128B value: pre_fillseq 1 threads micros/op</td>
      <td width="280">0.725</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: pre_fillseq 1 threads ops/sec</td>
      <td width="280">1379805.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: pre_overwrite 1 threads micros/op</td>
      <td width="280">1.955</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: pre_overwrite 1 threads ops/sec</td>
      <td width="280">511618.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 1 threads micros/op</td>
      <td width="280">2.253</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 1 threads ops/sec</td>
      <td width="280">443927.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 16 threads micros/op</td>
      <td width="280">42.881</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: overwrite 16 threads ops/sec</td>
      <td width="280">373113.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 1 threads micros/op</td>
      <td width="280">763.99</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 1 threads ops/sec</td>
      <td width="280">1308.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 16 threads micros/op</td>
      <td width="280">1209.651</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandom 16 threads ops/sec</td>
      <td width="280">13203.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="280">160.523</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="280">6229.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="280">674.83</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 128B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="280">23691.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### 64B key / 512B value

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
      <td width="500">64B key / 512B value: pre_fillseq 1 threads micros/op</td>
      <td width="280">2.18</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: pre_fillseq 1 threads ops/sec</td>
      <td width="280">458775.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: pre_overwrite 1 threads micros/op</td>
      <td width="280">5.904</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: pre_overwrite 1 threads ops/sec</td>
      <td width="280">169373.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 1 threads micros/op</td>
      <td width="280">8.11</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 1 threads ops/sec</td>
      <td width="280">123296.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 16 threads micros/op</td>
      <td width="280">865.338</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: overwrite 16 threads ops/sec</td>
      <td width="280">18489.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 1 threads micros/op</td>
      <td width="280">1958.654</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 1 threads ops/sec</td>
      <td width="280">510.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 16 threads micros/op</td>
      <td width="280">2774.499</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandom 16 threads ops/sec</td>
      <td width="280">5726.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="280">456.883</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="280">2188.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="280">1194.818</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">64B key / 512B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="280">13373.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>

### 128B key / 1024B value

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
      <td width="500">128B key / 1024B value: pre_fillseq 1 threads micros/op</td>
      <td width="280">4.361</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: pre_fillseq 1 threads ops/sec</td>
      <td width="280">229280.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: pre_overwrite 1 threads micros/op</td>
      <td width="280">11.618</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: pre_overwrite 1 threads ops/sec</td>
      <td width="280">86072.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 1 threads micros/op</td>
      <td width="280">75.321</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 1 threads ops/sec</td>
      <td width="280">13276.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 16 threads micros/op</td>
      <td width="280">3348.078</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: overwrite 16 threads ops/sec</td>
      <td width="280">4771.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 1 threads micros/op</td>
      <td width="280">1316.746</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 1 threads ops/sec</td>
      <td width="280">759.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 16 threads micros/op</td>
      <td width="280">3382.185</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandom 16 threads ops/sec</td>
      <td width="280">4713.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 1 threads micros/op</td>
      <td width="280">904.872</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 1 threads ops/sec</td>
      <td width="280">1105.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 16 threads micros/op</td>
      <td width="280">2374.653</td>
      <td width="200">micros/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">128B key / 1024B value: readrandomwriterandom 16 threads ops/sec</td>
      <td width="280">6718.0</td>
      <td width="200">ops/sec</td>
      <td width="400">越大越好</td>
    </tr>
  </tbody>
</table>
