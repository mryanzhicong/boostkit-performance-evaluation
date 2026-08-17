# 性能测试汇总

- 任务总数：2
- 成功：2
- 失败：0
- 跨架构对比：1

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
      <td width="180">HPC</td>
      <td width="220">lz4</td>
      <td width="160">1.10.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">lz4</td>
      <td width="160">1.10.0</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### lz4 1.10.0

#### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="600">x86</th>
      <th width="600">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">请求软件版本</td>
      <td width="600">1.10.0</td>
      <td width="600">1.10.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.10.0</td>
      <td width="600">1.10.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-08-17T09:40:47Z</td>
      <td width="600">2026-08-17T09:41:07Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
  </tbody>
</table>

#### 系统信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="600">x86</th>
      <th width="600">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="600">2026-08-17T09:40:35Z</td>
      <td width="600">2026-08-17T09:40:50Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">0</td>
      <td width="600">0</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">16</td>
      <td width="600">256</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">Linux-6.6.0-159.4.3.154.oe2403sp4.x86_64-x86_64-with-glibc2.38</td>
      <td width="600">Linux-6.6.0-159.4.3.154.oe2403sp4.aarch64-aarch64-with-glibc2.38</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="600">6.6.0-159.4.3.154.oe2403sp4.x86_64</td>
      <td width="600">6.6.0-159.4.3.154.oe2403sp4.aarch64</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="600">3.11.6</td>
      <td width="600">3.11.6</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="600">12.3.1</td>
      <td width="600">12.3.1</td>
    </tr>
    <tr>
      <td width="180">glibc 版本</td>
      <td width="600">glibc 2.38</td>
      <td width="600">glibc 2.38</td>
    </tr>
    <tr>
      <td width="180">NUMA</td>
      <td width="600">N/A</td>
      <td width="600">N/A</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### aarch64

<table width="1380">
  <thead>
    <tr>
      <th width="180">软件</th>
      <th width="160">版本</th>
      <th width="420">指标</th>
      <th width="200">数值</th>
      <th width="160">单位</th>
      <th width="260">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">lz4</td>
      <td width="160">1.10.0</td>
      <td width="420">compress_speed_4m</td>
      <td width="200">528.6</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">lz4</td>
      <td width="160">1.10.0</td>
      <td width="420">compress_speed_64k</td>
      <td width="200">480.2</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">lz4</td>
      <td width="160">1.10.0</td>
      <td width="420">decompress_speed_4m</td>
      <td width="200">3343.6</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">lz4</td>
      <td width="160">1.10.0</td>
      <td width="420">decompress_speed_64k</td>
      <td width="200">2682.0</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
  </tbody>
</table>

### x86_64

<table width="1380">
  <thead>
    <tr>
      <th width="180">软件</th>
      <th width="160">版本</th>
      <th width="420">指标</th>
      <th width="200">数值</th>
      <th width="160">单位</th>
      <th width="260">优化方向</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">lz4</td>
      <td width="160">1.10.0</td>
      <td width="420">compress_speed_4m</td>
      <td width="200">678.9</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">lz4</td>
      <td width="160">1.10.0</td>
      <td width="420">compress_speed_64k</td>
      <td width="200">649.4</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">lz4</td>
      <td width="160">1.10.0</td>
      <td width="420">decompress_speed_4m</td>
      <td width="200">4368.1</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">lz4</td>
      <td width="160">1.10.0</td>
      <td width="420">decompress_speed_64k</td>
      <td width="200">3478.2</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

<table width="1380">
  <thead>
    <tr>
      <th width="160">软件</th>
      <th width="140">版本</th>
      <th width="340">指标</th>
      <th width="180">优化方向</th>
      <th width="160">x86_64</th>
      <th width="160">aarch64</th>
      <th width="240">aarch64 相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="160">lz4</td>
      <td width="140">1.10.0</td>
      <td width="340">compress_speed_4m</td>
      <td width="180">越大越好</td>
      <td width="160">678.9</td>
      <td width="160">528.6</td>
      <td width="240">0.7786</td>
    </tr>
    <tr>
      <td width="160">lz4</td>
      <td width="140">1.10.0</td>
      <td width="340">compress_speed_64k</td>
      <td width="180">越大越好</td>
      <td width="160">649.4</td>
      <td width="160">480.2</td>
      <td width="240">0.7395</td>
    </tr>
    <tr>
      <td width="160">lz4</td>
      <td width="140">1.10.0</td>
      <td width="340">decompress_speed_4m</td>
      <td width="180">越大越好</td>
      <td width="160">4368.1</td>
      <td width="160">3343.6</td>
      <td width="240">0.7655</td>
    </tr>
    <tr>
      <td width="160">lz4</td>
      <td width="140">1.10.0</td>
      <td width="340">decompress_speed_64k</td>
      <td width="180">越大越好</td>
      <td width="160">3478.2</td>
      <td width="160">2682.0</td>
      <td width="240">0.7711</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
