# sonic-go 1.15.2 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`33709140448-1`

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
      <td width="1200">1.15.2</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">1.15.2</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-09-03T02:50:59Z</td>
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
      <td width="1200">2026-09-03T02:50:50Z</td>
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
      <td width="500">go</td>
      <td width="880">1.27.0</td>
    </tr>
  </tbody>
</table>

## 性能指标

### github.com/bytedance/sonic/ast

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
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: B/op</td>
      <td width="280">13584.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: MB/s</td>
      <td width="280">8404.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: ns/op</td>
      <td width="280">1550.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: MB/s</td>
      <td width="280">6825471.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: ns/op</td>
      <td width="280">1.908</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: B/op</td>
      <td width="280">13591.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: MB/s</td>
      <td width="280">9402.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: ns/op</td>
      <td width="280">1385.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: MB/s</td>
      <td width="280">1317.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: ns/op</td>
      <td width="280">9884.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: B/op</td>
      <td width="280">56.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: MB/s</td>
      <td width="280">6097.74</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: ns/op</td>
      <td width="280">2136.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: B/op</td>
      <td width="280">56.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: MB/s</td>
      <td width="280">777.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: ns/op</td>
      <td width="280">16756.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: MB/s</td>
      <td width="280">6116.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: ns/op</td>
      <td width="280">2129.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: MB/s</td>
      <td width="280">778.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: ns/op</td>
      <td width="280">16721.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: MB/s</td>
      <td width="280">304.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: ns/op</td>
      <td width="280">2302.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-16 :: ns/op</td>
      <td width="280">17.62</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapGet-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapGet-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapGet-16 :: ns/op</td>
      <td width="280">9.602</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-16 :: ns/op</td>
      <td width="280">39.04</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapSet-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapSet-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapSet-16 :: ns/op</td>
      <td width="280">11.9</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-16 :: ns/op</td>
      <td width="280">9.116</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-16 :: ns/op</td>
      <td width="280">12.49</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-16 :: B/op</td>
      <td width="280">576.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-16 :: ns/op</td>
      <td width="280">121.7</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-16 :: ns/op</td>
      <td width="280">22.76</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-16 :: ns/op</td>
      <td width="280">8.774</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-16 :: ns/op</td>
      <td width="280">6.918</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-16 :: ns/op</td>
      <td width="280">21.95</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-16 :: ns/op</td>
      <td width="280">22.03</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-16 :: ns/op</td>
      <td width="280">25.52</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: B/op</td>
      <td width="280">1100.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: MB/s</td>
      <td width="280">4341.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: allocs/op</td>
      <td width="280">4.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: ns/op</td>
      <td width="280">2999.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: B/op</td>
      <td width="280">1096.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: MB/s</td>
      <td width="280">574.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: allocs/op</td>
      <td width="280">4.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: ns/op</td>
      <td width="280">22657.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: B/op</td>
      <td width="280">1056.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: MB/s</td>
      <td width="280">5002.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: ns/op</td>
      <td width="280">2603.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: B/op</td>
      <td width="280">1056.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: MB/s</td>
      <td width="280">657.22</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: ns/op</td>
      <td width="280">19815.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-16 :: ns/op</td>
      <td width="280">19.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-16 :: ns/op</td>
      <td width="280">2.218</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-16 :: ns/op</td>
      <td width="280">0.2748</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-16 :: ns/op</td>
      <td width="280">0.5547</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-16 :: ns/op</td>
      <td width="280">1.704</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-16 :: ns/op</td>
      <td width="280">1.411</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-16 :: ns/op</td>
      <td width="280">0.2737</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-16 :: ns/op</td>
      <td width="280">0.275</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### github.com/bytedance/sonic/decoder

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
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: B/op</td>
      <td width="280">55736.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: MB/s</td>
      <td width="280">217.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: allocs/op</td>
      <td width="280">85.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: ns/op</td>
      <td width="280">59809.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="280">55737.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="280">217.65</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">85.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="280">59891.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: B/op</td>
      <td width="280">8919.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: MB/s</td>
      <td width="280">335.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: ns/op</td>
      <td width="280">38899.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: B/op</td>
      <td width="280">96202.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: MB/s</td>
      <td width="280">101.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: allocs/op</td>
      <td width="280">946.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: ns/op</td>
      <td width="280">128895.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="280">96207.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="280">100.83</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">946.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="280">129275.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: B/op</td>
      <td width="280">49405.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: MB/s</td>
      <td width="280">122.38</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: ns/op</td>
      <td width="280">106511.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: B/op</td>
      <td width="280">56832.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: MB/s</td>
      <td width="280">445.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: allocs/op</td>
      <td width="280">95.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: ns/op</td>
      <td width="280">29265.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="280">56852.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="280">440.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">95.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="280">29563.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: B/op</td>
      <td width="280">8943.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: MB/s</td>
      <td width="280">1540.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: ns/op</td>
      <td width="280">8460.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: B/op</td>
      <td width="280">97955.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: MB/s</td>
      <td width="280">206.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: allocs/op</td>
      <td width="280">966.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: ns/op</td>
      <td width="280">63273.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="280">97960.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="280">205.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">966.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="280">63549.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: B/op</td>
      <td width="280">49485.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: MB/s</td>
      <td width="280">327.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: ns/op</td>
      <td width="280">39845.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### github.com/bytedance/sonic/encoder

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
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: B/op</td>
      <td width="280">9511.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: MB/s</td>
      <td width="280">843.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: ns/op</td>
      <td width="280">15462.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="280">9511.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="280">839.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="280">15533.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: B/op</td>
      <td width="280">9510.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: MB/s</td>
      <td width="280">844.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: ns/op</td>
      <td width="280">15427.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: B/op</td>
      <td width="280">9592.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: MB/s</td>
      <td width="280">344.74</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: ns/op</td>
      <td width="280">37811.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="280">9593.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="280">343.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="280">37945.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: B/op</td>
      <td width="280">9592.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: MB/s</td>
      <td width="280">345.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: ns/op</td>
      <td width="280">37717.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: B/op</td>
      <td width="280">9531.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: MB/s</td>
      <td width="280">3191.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: ns/op</td>
      <td width="280">4085.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="280">9532.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="280">3137.15</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="280">4155.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: B/op</td>
      <td width="280">9530.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: MB/s</td>
      <td width="280">3127.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: ns/op</td>
      <td width="280">4168.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: B/op</td>
      <td width="280">9646.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: MB/s</td>
      <td width="280">1688.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: ns/op</td>
      <td width="280">7718.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="280">9650.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="280">1660.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="280">7849.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: B/op</td>
      <td width="280">9648.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: MB/s</td>
      <td width="280">1641.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: ns/op</td>
      <td width="280">7940.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### github.com/bytedance/sonic/external_jsonlib_test/benchmark_test

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
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: B/op</td>
      <td width="280">21957.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: MB/s</td>
      <td width="280">661.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: allocs/op</td>
      <td width="280">49.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: ns/op</td>
      <td width="280">19695.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: B/op</td>
      <td width="280">14538.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: MB/s</td>
      <td width="280">443.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: allocs/op</td>
      <td width="280">379.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: ns/op</td>
      <td width="280">29361.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: B/op</td>
      <td width="280">8913.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: MB/s</td>
      <td width="280">333.59</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: ns/op</td>
      <td width="280">39074.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: B/op</td>
      <td width="280">64885.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: MB/s</td>
      <td width="280">244.69</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: allocs/op</td>
      <td width="280">996.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: ns/op</td>
      <td width="280">53272.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: B/op</td>
      <td width="280">54223.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: MB/s</td>
      <td width="280">227.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: allocs/op</td>
      <td width="280">1085.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: ns/op</td>
      <td width="280">57222.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: B/op</td>
      <td width="280">49375.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: MB/s</td>
      <td width="280">124.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: ns/op</td>
      <td width="280">105051.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: B/op</td>
      <td width="280">21970.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: MB/s</td>
      <td width="280">3416.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: allocs/op</td>
      <td width="280">49.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: ns/op</td>
      <td width="280">3815.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: B/op</td>
      <td width="280">14537.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: MB/s</td>
      <td width="280">3021.35</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: allocs/op</td>
      <td width="280">379.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: ns/op</td>
      <td width="280">4314.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: B/op</td>
      <td width="280">8915.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: MB/s</td>
      <td width="280">2530.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: ns/op</td>
      <td width="280">5152.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: B/op</td>
      <td width="280">64890.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: MB/s</td>
      <td width="280">1097.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: allocs/op</td>
      <td width="280">996.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: ns/op</td>
      <td width="280">11880.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: B/op</td>
      <td width="280">54222.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: MB/s</td>
      <td width="280">1143.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: allocs/op</td>
      <td width="280">1085.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: ns/op</td>
      <td width="280">11396.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: B/op</td>
      <td width="280">49376.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: MB/s</td>
      <td width="280">796.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: ns/op</td>
      <td width="280">16369.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: B/op</td>
      <td width="280">9474.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: MB/s</td>
      <td width="280">2270.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: ns/op</td>
      <td width="280">5741.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: B/op</td>
      <td width="280">9481.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: MB/s</td>
      <td width="280">1124.35</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: ns/op</td>
      <td width="280">11593.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: B/op</td>
      <td width="280">26720.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: MB/s</td>
      <td width="280">279.34</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: allocs/op</td>
      <td width="280">53.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: ns/op</td>
      <td width="280">46663.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: B/op</td>
      <td width="280">17986.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: MB/s</td>
      <td width="280">466.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: allocs/op</td>
      <td width="280">153.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: ns/op</td>
      <td width="280">27927.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: B/op</td>
      <td width="280">9480.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: MB/s</td>
      <td width="280">10443.52</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: ns/op</td>
      <td width="280">1248.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: B/op</td>
      <td width="280">9487.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: MB/s</td>
      <td width="280">6292.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: ns/op</td>
      <td width="280">2071.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: B/op</td>
      <td width="280">26604.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: MB/s</td>
      <td width="280">1452.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: allocs/op</td>
      <td width="280">53.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: ns/op</td>
      <td width="280">8974.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: B/op</td>
      <td width="280">17993.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: MB/s</td>
      <td width="280">2664.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: allocs/op</td>
      <td width="280">153.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: ns/op</td>
      <td width="280">4892.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: MB/s</td>
      <td width="280">1060.83</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: ns/op</td>
      <td width="280">12288.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: MB/s</td>
      <td width="280">601.83</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: ns/op</td>
      <td width="280">21659.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: B/op</td>
      <td width="280">86136.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: MB/s</td>
      <td width="280">509.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: allocs/op</td>
      <td width="280">152.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: ns/op</td>
      <td width="280">25594.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: MB/s</td>
      <td width="280">2027.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: ns/op</td>
      <td width="280">6428.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: B/op</td>
      <td width="280">27668.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: MB/s</td>
      <td width="280">314.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: allocs/op</td>
      <td width="280">635.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: ns/op</td>
      <td width="280">41391.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: B/op</td>
      <td width="280">86136.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: MB/s</td>
      <td width="280">1132.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: allocs/op</td>
      <td width="280">152.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: ns/op</td>
      <td width="280">11512.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: MB/s</td>
      <td width="280">17729.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: ns/op</td>
      <td width="280">735.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: B/op</td>
      <td width="280">27666.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: MB/s</td>
      <td width="280">1945.69</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: allocs/op</td>
      <td width="280">635.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: ns/op</td>
      <td width="280">6699.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: MB/s</td>
      <td width="280">6121.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: ns/op</td>
      <td width="280">2130.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: MB/s</td>
      <td width="280">777.69</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: ns/op</td>
      <td width="280">16761.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: B/op</td>
      <td width="280">40586.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: MB/s</td>
      <td width="280">197.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: allocs/op</td>
      <td width="280">335.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: ns/op</td>
      <td width="280">65915.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: B/op</td>
      <td width="280">86724.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: MB/s</td>
      <td width="280">155.62</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: allocs/op</td>
      <td width="280">1401.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: ns/op</td>
      <td width="280">83760.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: B/op</td>
      <td width="280">40586.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: MB/s</td>
      <td width="280">1131.64</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: allocs/op</td>
      <td width="280">335.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: ns/op</td>
      <td width="280">11519.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: B/op</td>
      <td width="280">54223.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: MB/s</td>
      <td width="280">1111.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: allocs/op</td>
      <td width="280">1085.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: ns/op</td>
      <td width="280">11730.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: B/op</td>
      <td width="280">45126.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: MB/s</td>
      <td width="280">213.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: allocs/op</td>
      <td width="280">952.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: ns/op</td>
      <td width="280">61037.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: B/op</td>
      <td width="280">45124.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: MB/s</td>
      <td width="280">1237.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: allocs/op</td>
      <td width="280">952.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: ns/op</td>
      <td width="280">10530.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: B/op</td>
      <td width="280">52169.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: MB/s</td>
      <td width="280">2080.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: allocs/op</td>
      <td width="280">10.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: ns/op</td>
      <td width="280">6265.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: B/op</td>
      <td width="280">52161.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: MB/s</td>
      <td width="280">583.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: allocs/op</td>
      <td width="280">10.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: ns/op</td>
      <td width="280">22352.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
