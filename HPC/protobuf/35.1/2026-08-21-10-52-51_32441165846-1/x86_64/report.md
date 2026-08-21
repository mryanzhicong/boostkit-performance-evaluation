# protobuf 35.1 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`32441165846-1`

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
      <td width="1200">35.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">35.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-21T02:51:20Z</td>
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
      <td width="1200">2026-08-21T02:49:08Z</td>
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
      <td width="1200">available: 1 nodes (0)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>node 0 size: 30886 MB<br>node 0 free: 16705 MB<br>node distances:<br>node   0 <br>  0:  10</td>
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
      <td width="500">results_summary.SimpleMessage.serialize_qps</td>
      <td width="280">6792635.878937954</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.SimpleMessage.deserialize_qps</td>
      <td width="280">4364692.59458284</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.SimpleMessage.serialize_latency_us</td>
      <td width="280">0.14721825486049056</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.SimpleMessage.deserialize_latency_us</td>
      <td width="280">0.22911120962817222</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedInt32.serialize_qps</td>
      <td width="280">5509990.687916542</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedInt32.deserialize_qps</td>
      <td width="280">1954186.7285045518</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedInt32.serialize_latency_us</td>
      <td width="280">0.18148850998841226</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedInt32.deserialize_latency_us</td>
      <td width="280">0.511721825459972</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedString.serialize_qps</td>
      <td width="280">1691718.680461789</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedString.deserialize_qps</td>
      <td width="280">648731.1848006767</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedString.serialize_latency_us</td>
      <td width="280">0.5911148298764601</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedString.deserialize_latency_us</td>
      <td width="280">1.5414705249713734</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.NestedMessage.serialize_qps</td>
      <td width="280">451848.17660889885</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.NestedMessage.deserialize_qps</td>
      <td width="280">327742.45183779555</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.NestedMessage.serialize_latency_us</td>
      <td width="280">2.213132755132392</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.NestedMessage.deserialize_latency_us</td>
      <td width="280">3.0511762952664867</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.LargeMessage.serialize_qps</td>
      <td width="280">2244370.795484512</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.LargeMessage.deserialize_qps</td>
      <td width="280">1024970.3320585456</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.LargeMessage.serialize_latency_us</td>
      <td width="280">0.4455591749865562</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.LargeMessage.deserialize_latency_us</td>
      <td width="280">0.9756379952887073</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.single_serialize.serialize_qps</td>
      <td width="280">6910293.416952971</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.single_serialize.serialize_latency_us</td>
      <td width="280">0.14471165544819087</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.single_deserialize.deserialize_qps</td>
      <td width="280">4282688.069128675</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.single_deserialize.deserialize_latency_us</td>
      <td width="280">0.23349821043666452</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.json_serialization.binary_serialize_qps</td>
      <td width="280">7139108.594805038</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.json_serialization.json_serialize_qps</td>
      <td width="280">90483.8491044991</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.large_message.serialize.serialize_qps</td>
      <td width="280">448898.2612614954</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.large_message.serialize.serialize_latency_us</td>
      <td width="280">2.22767626051791</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.large_message.deserialize.deserialize_qps</td>
      <td width="280">316006.40707979345</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.large_message.deserialize.deserialize_latency_us</td>
      <td width="280">3.164492800133303</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_serialize.threads_1.qps</td>
      <td width="280">7122704.7153891465</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_serialize.threads_2.qps</td>
      <td width="280">7076589.682917681</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_serialize.threads_4.qps</td>
      <td width="280">7065122.885259582</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_serialize.threads_8.qps</td>
      <td width="280">7032093.620227746</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_deserialize.threads_1.qps</td>
      <td width="280">4384416.719044427</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_deserialize.threads_2.qps</td>
      <td width="280">4388136.652213462</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_deserialize.threads_4.qps</td>
      <td width="280">4392071.2478530845</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_deserialize.threads_8.qps</td>
      <td width="280">4416037.342666258</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_10.serialize.serialize_qps</td>
      <td width="280">7437022.714286173</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_10.serialize.serialize_latency_us</td>
      <td width="280">0.1344624103512615</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_10.deserialize.deserialize_qps</td>
      <td width="280">4176648.68603285</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_10.deserialize.deserialize_latency_us</td>
      <td width="280">0.23942640982568264</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_50.serialize.serialize_qps</td>
      <td width="280">6426819.689386147</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_50.serialize.serialize_latency_us</td>
      <td width="280">0.1555979548720643</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_50.deserialize.deserialize_qps</td>
      <td width="280">2598009.114124303</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_50.deserialize.deserialize_latency_us</td>
      <td width="280">0.38491012004669756</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_100.serialize.serialize_qps</td>
      <td width="280">5481886.329279457</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_100.serialize.serialize_latency_us</td>
      <td width="280">0.18241895944811404</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_100.deserialize.deserialize_qps</td>
      <td width="280">1884380.53489582</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_100.deserialize.deserialize_latency_us</td>
      <td width="280">0.5306783749256283</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_500.serialize.serialize_qps</td>
      <td width="280">377194.83361918974</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_500.serialize.serialize_latency_us</td>
      <td width="280">2.6511497795581818</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_500.deserialize.deserialize_qps</td>
      <td width="280">429514.27805010113</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_500.deserialize.deserialize_latency_us</td>
      <td width="280">2.328211310086772</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_1000.serialize.serialize_qps</td>
      <td width="280">168868.0820744607</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_1000.serialize.serialize_latency_us</td>
      <td width="280">5.92178218474146</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_1000.deserialize.deserialize_qps</td>
      <td width="280">238579.88189556557</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_1000.deserialize.deserialize_latency_us</td>
      <td width="280">4.191468249773607</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
