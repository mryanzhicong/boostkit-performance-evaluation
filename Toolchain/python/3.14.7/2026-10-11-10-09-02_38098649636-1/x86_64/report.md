# python 3.14.7 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`38098649636-1`

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
      <td width="1200">3.14.7</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">3.14.7</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-10-11T00:33:36Z</td>
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
      <td width="1200">2026-10-11T00:30:17Z</td>
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
      <td width="500">pyperformance</td>
      <td width="880">1.13.0</td>
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
      <td width="500">2to3</td>
      <td width="280">0.1937968814963824</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">many_optionals</td>
      <td width="280">0.0006084000761745756</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">subparsers</td>
      <td width="280">0.007564138718862523</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_generators</td>
      <td width="280">0.2888848875008989</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_none</td>
      <td width="280">0.2404618419968756</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_cpu_io_mixed</td>
      <td width="280">0.43477253449964337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_cpu_io_mixed_tg</td>
      <td width="280">0.4301598015008494</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager</td>
      <td width="280">0.08194169575290289</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_cpu_io_mixed</td>
      <td width="280">0.32140030700247735</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_cpu_io_mixed_tg</td>
      <td width="280">0.40867323899874464</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_io</td>
      <td width="280">0.6138383120051003</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_io_tg</td>
      <td width="280">0.6656392320073792</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_memoization</td>
      <td width="280">0.17341441099415533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_memoization_tg</td>
      <td width="280">0.27663599350489676</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_eager_tg</td>
      <td width="280">0.2140117704984732</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_io</td>
      <td width="280">0.6083079620002536</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_io_tg</td>
      <td width="280">0.6426493725011824</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_memoization</td>
      <td width="280">0.2946225734995096</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_memoization_tg</td>
      <td width="280">0.3060687620018143</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">async_tree_none_tg</td>
      <td width="280">0.23767856000631582</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_tcp</td>
      <td width="280">0.2346557334967656</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_tcp_ssl</td>
      <td width="280">1.0643831080014934</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">asyncio_websockets</td>
      <td width="280">0.49585594050586224</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bpe_tokeniser</td>
      <td width="280">3.285662616501213</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">chameleon</td>
      <td width="280">0.010304481249931996</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">chaos</td>
      <td width="280">0.0406112141245103</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">comprehensions</td>
      <td width="280">1.2217828766036831e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_mp_pool</td>
      <td width="280">0.05713268762519874</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">bench_thread_pool</td>
      <td width="280">0.0010906145233775533</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">coroutines</td>
      <td width="280">0.0175512921250629</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">coverage</td>
      <td width="280">0.05502366375003476</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">crypto_pyaes</td>
      <td width="280">0.05205032374942675</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">dask</td>
      <td width="280">0.4724363019995508</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy</td>
      <td width="280">0.00019973076148005475</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy_reduce</td>
      <td width="280">2.1361780014883536e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deepcopy_memo</td>
      <td width="280">2.2122353516174087e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">deltablue</td>
      <td width="280">0.0023325033438368337</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">django_template</td>
      <td width="280">0.026465418752195546</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">docutils</td>
      <td width="280">1.7510793485489557</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">dulwich_log</td>
      <td width="280">0.03282284399938362</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fannkuch</td>
      <td width="280">0.26965672399819596</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">float</td>
      <td width="280">0.050374693873891374</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">create_gc_cycles</td>
      <td width="280">0.001575139788656088</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gc_traversal</td>
      <td width="280">0.0030440913827760596</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">generators</td>
      <td width="280">0.022210613749848562</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">genshi_text</td>
      <td width="280">0.017027854687512445</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">genshi_xml</td>
      <td width="280">0.039004123500490095</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">go</td>
      <td width="280">0.0867287450018921</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hexiom</td>
      <td width="280">0.0044202290155226365</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">html5lib</td>
      <td width="280">0.04255041100077506</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">json_dumps</td>
      <td width="280">0.007655249531126174</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">json_loads</td>
      <td width="280">1.724170400407843e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_format</td>
      <td width="280">4.987791503907602e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_silent</td>
      <td width="280">7.263747978103474e-08</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">logging_simple</td>
      <td width="280">4.542137902596721e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mako</td>
      <td width="280">0.008911094968880207</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">mdp</td>
      <td width="280">0.9076510999948368</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">meteor_contest</td>
      <td width="280">0.07917650300078094</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nbody</td>
      <td width="280">0.07420662674849154</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">shortest_path</td>
      <td width="280">0.37066771399986465</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">connected_components</td>
      <td width="280">0.3541623319979408</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">k_core</td>
      <td width="280">1.8658915615014848</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">nqueens</td>
      <td width="280">0.06223942599535803</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pathlib</td>
      <td width="280">0.016220308312767884</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle</td>
      <td width="280">8.533387255837967e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_dict</td>
      <td width="280">2.048623759804968e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_list</td>
      <td width="280">3.4950781616416297e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pickle_pure_python</td>
      <td width="280">0.0002330220085923429</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pidigits</td>
      <td width="280">0.1673008045036113</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pprint_safe_repr</td>
      <td width="280">0.5434452440022142</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pprint_pformat</td>
      <td width="280">1.111418220003543</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">pyflate</td>
      <td width="280">0.3154637725019711</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">python_startup</td>
      <td width="280">0.010815944124715315</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">python_startup_no_site</td>
      <td width="280">0.006368060531258379</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">raytrace</td>
      <td width="280">0.18831041199882748</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_compile</td>
      <td width="280">0.0778451469996071</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_dna</td>
      <td width="280">0.14586239949858282</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_effbot</td>
      <td width="280">0.0022065439562538812</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">regex_v8</td>
      <td width="280">0.01775382362484379</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">richards</td>
      <td width="280">0.03178223712529871</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">richards_super</td>
      <td width="280">0.03623623199928261</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_fft</td>
      <td width="280">0.25610569650598336</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_lu</td>
      <td width="280">0.08218339599989122</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_monte_carlo</td>
      <td width="280">0.04912392174992419</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_sor</td>
      <td width="280">0.08817394400102785</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">scimark_sparse_mat_mult</td>
      <td width="280">0.004200509421934839</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">spectral_norm</td>
      <td width="280">0.07431616574831423</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sphinx</td>
      <td width="280">0.7731315040000482</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlalchemy_declarative</td>
      <td width="280">0.08286319350008853</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlalchemy_imperative</td>
      <td width="280">0.008068227249623305</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_normalize</td>
      <td width="280">0.07679850924978382</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_optimize</td>
      <td width="280">0.037221973872874514</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_parse</td>
      <td width="280">0.0009159811719996469</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlglot_v2_transpile</td>
      <td width="280">0.0011492262266301623</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sqlite_synth</td>
      <td width="280">1.7601318892390694e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_expand</td>
      <td width="280">0.2852309429945308</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_integrate</td>
      <td width="280">0.013567699066697969</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_sum</td>
      <td width="280">0.08949847424810287</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">sympy_str</td>
      <td width="280">0.164689871497103</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">telco</td>
      <td width="280">0.005631715375102431</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">tomli_loads</td>
      <td width="280">1.6077207060006913</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">tornado_http</td>
      <td width="280">0.08628957349719713</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">typing_runtime_protocols</td>
      <td width="280">0.00011712297900601243</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpack_sequence</td>
      <td width="280">3.683516906827222e-08</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle</td>
      <td width="280">1.0063152392802975e-05</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle_list</td>
      <td width="280">3.2906743408389618e-06</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">unpickle_pure_python</td>
      <td width="280">0.00016027900469453015</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xdsl_constant_fold</td>
      <td width="280">0.025648352499047178</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_parse</td>
      <td width="280">0.10137063499860233</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_iterparse</td>
      <td width="280">0.06384371099920827</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_generate</td>
      <td width="280">0.06258954149961937</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">xml_etree_process</td>
      <td width="280">0.04440150287337019</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
