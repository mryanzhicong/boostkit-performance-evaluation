# glibc 2.44 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`32921061163-1`

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
      <td width="1200">2.44</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">2.44</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-26T02:01:58Z</td>
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
      <td width="1200">2026-08-26T02:00:20Z</td>
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
      <td width="500">math-inlines.__isnan.inf/nan.mean</td>
      <td width="280">4483.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnan_inl.inf/nan.mean</td>
      <td width="280">2243.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnan_builtin.inf/nan.mean</td>
      <td width="280">1958.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isnan.inf/nan.mean</td>
      <td width="280">1953.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf.inf/nan.mean</td>
      <td width="280">4760.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_ns2.inf/nan.mean</td>
      <td width="280">1954.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_ns_builtin.inf/nan.mean</td>
      <td width="280">2235.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_builtin.inf/nan.mean</td>
      <td width="280">2238.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isinf.inf/nan.mean</td>
      <td width="280">2234.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__finite.inf/nan.mean</td>
      <td width="280">4216.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__finite_inl.inf/nan.mean</td>
      <td width="280">1968.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isfinite_builtin.inf/nan.mean</td>
      <td width="280">1406.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isfinite.inf/nan.mean</td>
      <td width="280">1408.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnormal_inl.inf/nan.mean</td>
      <td width="280">4496.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnormal_builtin.inf/nan.mean</td>
      <td width="280">1407.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isnormal.inf/nan.mean</td>
      <td width="280">1406.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__fpclassify.inf/nan.mean</td>
      <td width="280">1967.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__fpclassify_builtin.inf/nan.mean</td>
      <td width="280">2331.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.fpclassify.inf/nan.mean</td>
      <td width="280">2605.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.remainder_test1.inf/nan.mean</td>
      <td width="280">5870.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.remainder_test2.inf/nan.mean</td>
      <td width="280">5757.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnan.normal.mean</td>
      <td width="280">4233.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnan_inl.normal.mean</td>
      <td width="280">2002.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnan_builtin.normal.mean</td>
      <td width="280">1434.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isnan.normal.mean</td>
      <td width="280">1434.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf.normal.mean</td>
      <td width="280">3389.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_ns2.normal.mean</td>
      <td width="280">1708.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_ns_builtin.normal.mean</td>
      <td width="280">1987.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_builtin.normal.mean</td>
      <td width="280">1989.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isinf.normal.mean</td>
      <td width="280">1987.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__finite.normal.mean</td>
      <td width="280">3959.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__finite_inl.normal.mean</td>
      <td width="280">2000.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isfinite_builtin.normal.mean</td>
      <td width="280">1438.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isfinite.normal.mean</td>
      <td width="280">1434.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnormal_inl.normal.mean</td>
      <td width="280">3213.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnormal_builtin.normal.mean</td>
      <td width="280">1805.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isnormal.normal.mean</td>
      <td width="280">1788.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__fpclassify.normal.mean</td>
      <td width="280">2055.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__fpclassify_builtin.normal.mean</td>
      <td width="280">2091.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.fpclassify.normal.mean</td>
      <td width="280">2367.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.remainder_test1.normal.mean</td>
      <td width="280">7591.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.remainder_test2.normal.mean</td>
      <td width="280">7948.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sprintf.positional.mean</td>
      <td width="280">299.164</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sprintf.non-positional.mean</td>
      <td width="280">168.296</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fclose.duration</td>
      <td width="280">36051.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">random.single-threaded</td>
      <td width="280">4.52894</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">random.multi-threaded</td>
      <td width="280">4.37428</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
