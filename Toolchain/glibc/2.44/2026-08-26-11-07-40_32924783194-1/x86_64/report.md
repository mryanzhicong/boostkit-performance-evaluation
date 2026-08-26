# glibc 2.44 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`32924783194-1`

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
      <td width="1200">2026-08-26T03:02:00Z</td>
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
      <td width="1200">2026-08-26T03:00:23Z</td>
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
      <td width="280">4498.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnan_inl.inf/nan.mean</td>
      <td width="280">2244.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnan_builtin.inf/nan.mean</td>
      <td width="280">1960.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isnan.inf/nan.mean</td>
      <td width="280">1956.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf.inf/nan.mean</td>
      <td width="280">4761.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_ns2.inf/nan.mean</td>
      <td width="280">1953.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_ns_builtin.inf/nan.mean</td>
      <td width="280">2230.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_builtin.inf/nan.mean</td>
      <td width="280">2235.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isinf.inf/nan.mean</td>
      <td width="280">2231.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__finite.inf/nan.mean</td>
      <td width="280">4217.0</td>
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
      <td width="280">1407.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isfinite.inf/nan.mean</td>
      <td width="280">1406.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnormal_inl.inf/nan.mean</td>
      <td width="280">4495.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnormal_builtin.inf/nan.mean</td>
      <td width="280">1405.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isnormal.inf/nan.mean</td>
      <td width="280">1408.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__fpclassify.inf/nan.mean</td>
      <td width="280">1970.0</td>
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
      <td width="280">5742.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.remainder_test2.inf/nan.mean</td>
      <td width="280">5613.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnan.normal.mean</td>
      <td width="280">3123.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnan_inl.normal.mean</td>
      <td width="280">2004.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnan_builtin.normal.mean</td>
      <td width="280">1430.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isnan.normal.mean</td>
      <td width="280">1432.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf.normal.mean</td>
      <td width="280">4506.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_ns2.normal.mean</td>
      <td width="280">1707.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_ns_builtin.normal.mean</td>
      <td width="280">1986.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isinf_builtin.normal.mean</td>
      <td width="280">1985.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isinf.normal.mean</td>
      <td width="280">1984.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__finite.normal.mean</td>
      <td width="280">3951.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__finite_inl.normal.mean</td>
      <td width="280">1993.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isfinite_builtin.normal.mean</td>
      <td width="280">1433.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isfinite.normal.mean</td>
      <td width="280">1433.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnormal_inl.normal.mean</td>
      <td width="280">3226.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__isnormal_builtin.normal.mean</td>
      <td width="280">1781.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.isnormal.normal.mean</td>
      <td width="280">1786.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__fpclassify.normal.mean</td>
      <td width="280">2056.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.__fpclassify_builtin.normal.mean</td>
      <td width="280">2312.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.fpclassify.normal.mean</td>
      <td width="280">2584.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.remainder_test1.normal.mean</td>
      <td width="280">6274.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">math-inlines.remainder_test2.normal.mean</td>
      <td width="280">6556.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sprintf.positional.mean</td>
      <td width="280">297.657</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sprintf.non-positional.mean</td>
      <td width="280">164.472</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fclose.duration</td>
      <td width="280">35331.0</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">random.single-threaded</td>
      <td width="280">3.43454</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">random.multi-threaded</td>
      <td width="280">4.37934</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=0].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="280">101.40733333333333</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">memcpy.results[length=4096,align1=0,align2=0,dst &gt; src=1].timings[ifuncs=&#x27;generic_memcpy&#x27;].arithmetic_mean</td>
      <td width="280">102.64466666666665</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">memmove.results[length=4096,align1=0,align2=32].timings[ifuncs=&#x27;generic_memmove&#x27;].arithmetic_mean</td>
      <td width="280">95.08635</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">memset.results[length=4096,alignment=0,char=0].timings[ifuncs=&#x27;generic_memset&#x27;].arithmetic_mean</td>
      <td width="280">69.2158</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">strlen.results[length=4096,alignment=0].timings[ifuncs=&#x27;generic_strlen&#x27;].arithmetic_mean</td>
      <td width="280">258.694</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">strcmp.results[length=4096,align1=0,align2=0].timings[ifuncs=&#x27;generic_strcmp&#x27;].arithmetic_mean</td>
      <td width="280">289.4304</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">strstr.results[len_haystack=4096,len_needle=64,align_haystack=1,align_needle=11,fail=0].timings[ifuncs=&#x27;twoway_strstr&#x27;].arithmetic_mean</td>
      <td width="280">790.312</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">malloc-simple.results[malloc_block_size=64].main_arena_st_allocs_0100_time</td>
      <td width="280">18.0323</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">malloc-tcache.simple[alloc_size=64].time_per_iteration</td>
      <td width="280">5.44163</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">malloc-tcache.optimized[alloc_size=64].time_per_iteration</td>
      <td width="280">4.92903</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">malloc-thread.results[threads=8].time_per_iteration</td>
      <td width="280">8.41609</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
