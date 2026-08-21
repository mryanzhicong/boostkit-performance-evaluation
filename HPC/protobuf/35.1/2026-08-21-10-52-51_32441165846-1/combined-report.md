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
      <td width="220">protobuf</td>
      <td width="160">35.1</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">protobuf</td>
      <td width="160">35.1</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### protobuf 35.1

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
      <td width="600">35.1</td>
      <td width="600">35.1</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">35.1</td>
      <td width="600">35.1</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-08-21T02:51:20Z</td>
      <td width="600">2026-08-21T02:50:23Z</td>
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
      <td width="600">2026-08-21T02:49:08Z</td>
      <td width="600">2026-08-21T02:48:58Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="600">x86_64</td>
      <td width="600">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="600">General Purpose Processor</td>
      <td width="600">Kunpeng 920 7270Z To be filled by O.E.M. CPU @ 2.9GHz</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="600">16</td>
      <td width="600">256</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
      <td width="600">openEuler 24.03 (LTS-SP4)</td>
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
      <td width="600">available: 1 nodes (0)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>node 0 size: 30886 MB<br>node 0 free: 16705 MB<br>node distances:<br>node   0 <br>  0:  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 128025 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 124680 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127294 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 128459 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
    </tr>
  </tbody>
</table>

## 单架构指标

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
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.SimpleMessage.serialize_qps</td>
      <td width="200">6792635.878937954</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.SimpleMessage.deserialize_qps</td>
      <td width="200">4364692.59458284</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.SimpleMessage.serialize_latency_us</td>
      <td width="200">0.14721825486049056</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.SimpleMessage.deserialize_latency_us</td>
      <td width="200">0.22911120962817222</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedInt32.serialize_qps</td>
      <td width="200">5509990.687916542</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedInt32.deserialize_qps</td>
      <td width="200">1954186.7285045518</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedInt32.serialize_latency_us</td>
      <td width="200">0.18148850998841226</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedInt32.deserialize_latency_us</td>
      <td width="200">0.511721825459972</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedString.serialize_qps</td>
      <td width="200">1691718.680461789</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedString.deserialize_qps</td>
      <td width="200">648731.1848006767</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedString.serialize_latency_us</td>
      <td width="200">0.5911148298764601</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedString.deserialize_latency_us</td>
      <td width="200">1.5414705249713734</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.NestedMessage.serialize_qps</td>
      <td width="200">451848.17660889885</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.NestedMessage.deserialize_qps</td>
      <td width="200">327742.45183779555</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.NestedMessage.serialize_latency_us</td>
      <td width="200">2.213132755132392</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.NestedMessage.deserialize_latency_us</td>
      <td width="200">3.0511762952664867</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.LargeMessage.serialize_qps</td>
      <td width="200">2244370.795484512</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.LargeMessage.deserialize_qps</td>
      <td width="200">1024970.3320585456</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.LargeMessage.serialize_latency_us</td>
      <td width="200">0.4455591749865562</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.LargeMessage.deserialize_latency_us</td>
      <td width="200">0.9756379952887073</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.single_serialize.serialize_qps</td>
      <td width="200">6910293.416952971</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.single_serialize.serialize_latency_us</td>
      <td width="200">0.14471165544819087</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.single_deserialize.deserialize_qps</td>
      <td width="200">4282688.069128675</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.single_deserialize.deserialize_latency_us</td>
      <td width="200">0.23349821043666452</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.json_serialization.binary_serialize_qps</td>
      <td width="200">7139108.594805038</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.json_serialization.json_serialize_qps</td>
      <td width="200">90483.8491044991</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.large_message.serialize.serialize_qps</td>
      <td width="200">448898.2612614954</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.large_message.serialize.serialize_latency_us</td>
      <td width="200">2.22767626051791</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.large_message.deserialize.deserialize_qps</td>
      <td width="200">316006.40707979345</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.large_message.deserialize.deserialize_latency_us</td>
      <td width="200">3.164492800133303</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_serialize.threads_1.qps</td>
      <td width="200">7122704.7153891465</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_serialize.threads_2.qps</td>
      <td width="200">7076589.682917681</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_serialize.threads_4.qps</td>
      <td width="200">7065122.885259582</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_serialize.threads_8.qps</td>
      <td width="200">7032093.620227746</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_deserialize.threads_1.qps</td>
      <td width="200">4384416.719044427</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_deserialize.threads_2.qps</td>
      <td width="200">4388136.652213462</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_deserialize.threads_4.qps</td>
      <td width="200">4392071.2478530845</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_deserialize.threads_8.qps</td>
      <td width="200">4416037.342666258</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_10.serialize.serialize_qps</td>
      <td width="200">7437022.714286173</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_10.serialize.serialize_latency_us</td>
      <td width="200">0.1344624103512615</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_10.deserialize.deserialize_qps</td>
      <td width="200">4176648.68603285</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_10.deserialize.deserialize_latency_us</td>
      <td width="200">0.23942640982568264</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_50.serialize.serialize_qps</td>
      <td width="200">6426819.689386147</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_50.serialize.serialize_latency_us</td>
      <td width="200">0.1555979548720643</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_50.deserialize.deserialize_qps</td>
      <td width="200">2598009.114124303</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_50.deserialize.deserialize_latency_us</td>
      <td width="200">0.38491012004669756</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_100.serialize.serialize_qps</td>
      <td width="200">5481886.329279457</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_100.serialize.serialize_latency_us</td>
      <td width="200">0.18241895944811404</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_100.deserialize.deserialize_qps</td>
      <td width="200">1884380.53489582</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_100.deserialize.deserialize_latency_us</td>
      <td width="200">0.5306783749256283</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_500.serialize.serialize_qps</td>
      <td width="200">377194.83361918974</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_500.serialize.serialize_latency_us</td>
      <td width="200">2.6511497795581818</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_500.deserialize.deserialize_qps</td>
      <td width="200">429514.27805010113</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_500.deserialize.deserialize_latency_us</td>
      <td width="200">2.328211310086772</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_1000.serialize.serialize_qps</td>
      <td width="200">168868.0820744607</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_1000.serialize.serialize_latency_us</td>
      <td width="200">5.92178218474146</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_1000.deserialize.deserialize_qps</td>
      <td width="200">238579.88189556557</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_1000.deserialize.deserialize_latency_us</td>
      <td width="200">4.191468249773607</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
  </tbody>
</table>

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
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.SimpleMessage.serialize_qps</td>
      <td width="200">3974163.958616489</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.SimpleMessage.deserialize_qps</td>
      <td width="200">2545391.65103907</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.SimpleMessage.serialize_latency_us</td>
      <td width="200">0.2516252500936389</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.SimpleMessage.deserialize_latency_us</td>
      <td width="200">0.3928668500157073</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedInt32.serialize_qps</td>
      <td width="200">3165822.7876955485</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedInt32.deserialize_qps</td>
      <td width="200">1232163.4331071523</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedInt32.serialize_latency_us</td>
      <td width="200">0.31587365025188774</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedInt32.deserialize_latency_us</td>
      <td width="200">0.8115806500427425</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedString.serialize_qps</td>
      <td width="200">1356606.735333511</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedString.deserialize_qps</td>
      <td width="200">491526.899628101</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedString.serialize_latency_us</td>
      <td width="200">0.7371333002811298</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.RepeatedString.deserialize_latency_us</td>
      <td width="200">2.034476649714634</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.NestedMessage.serialize_qps</td>
      <td width="200">381967.78231078567</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.NestedMessage.deserialize_qps</td>
      <td width="200">241145.92062043448</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.NestedMessage.serialize_latency_us</td>
      <td width="200">2.618021849775687</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.NestedMessage.deserialize_latency_us</td>
      <td width="200">4.146866749506444</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.LargeMessage.serialize_qps</td>
      <td width="200">1658892.4049382212</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.LargeMessage.deserialize_qps</td>
      <td width="200">749595.4900832964</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.LargeMessage.serialize_latency_us</td>
      <td width="200">0.6028118502581492</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results_summary.LargeMessage.deserialize_latency_us</td>
      <td width="200">1.3340528501430526</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.single_serialize.serialize_qps</td>
      <td width="200">4310160.893309373</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.single_serialize.serialize_latency_us</td>
      <td width="200">0.2320099005009979</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.single_deserialize.deserialize_qps</td>
      <td width="200">2683804.728086668</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.single_deserialize.deserialize_latency_us</td>
      <td width="200">0.3726053499849513</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.json_serialization.binary_serialize_qps</td>
      <td width="200">4279958.9671878135</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.json_serialization.json_serialize_qps</td>
      <td width="200">66559.14192774918</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.large_message.serialize.serialize_qps</td>
      <td width="200">390636.0553012649</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.large_message.serialize.serialize_latency_us</td>
      <td width="200">2.5599275500280783</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.large_message.deserialize.deserialize_qps</td>
      <td width="200">234096.70199745355</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.large_message.deserialize.deserialize_latency_us</td>
      <td width="200">4.271738950046711</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_serialize.threads_1.qps</td>
      <td width="200">4341101.154718958</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_serialize.threads_2.qps</td>
      <td width="200">4301975.450617706</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_serialize.threads_4.qps</td>
      <td width="200">4336512.506015474</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_serialize.threads_8.qps</td>
      <td width="200">4362360.3319906425</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_deserialize.threads_1.qps</td>
      <td width="200">2454997.1389276925</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_deserialize.threads_2.qps</td>
      <td width="200">2481231.9635232207</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_deserialize.threads_4.qps</td>
      <td width="200">2460356.581048771</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.multithread_deserialize.threads_8.qps</td>
      <td width="200">2516667.575925956</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_10.serialize.serialize_qps</td>
      <td width="200">4666743.1942318985</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_10.serialize.serialize_latency_us</td>
      <td width="200">0.21428220032248646</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_10.deserialize.deserialize_qps</td>
      <td width="200">2476966.381443642</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_10.deserialize.deserialize_latency_us</td>
      <td width="200">0.4037196497665718</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_50.serialize.serialize_qps</td>
      <td width="200">4020269.394125555</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_50.serialize.serialize_latency_us</td>
      <td width="200">0.24873955000657588</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_50.deserialize.deserialize_qps</td>
      <td width="200">1586546.8432353449</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_50.deserialize.deserialize_latency_us</td>
      <td width="200">0.6302997004240751</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_100.serialize.serialize_qps</td>
      <td width="200">3458070.547962141</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_100.serialize.serialize_latency_us</td>
      <td width="200">0.2891786000691354</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_100.deserialize.deserialize_qps</td>
      <td width="200">1257533.7271997507</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_100.deserialize.deserialize_latency_us</td>
      <td width="200">0.7952073001069948</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_500.serialize.serialize_qps</td>
      <td width="200">708492.773732315</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_500.serialize.serialize_latency_us</td>
      <td width="200">1.4114469999913126</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_500.deserialize.deserialize_qps</td>
      <td width="200">396598.64311767265</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_500.deserialize.deserialize_latency_us</td>
      <td width="200">2.5214408000465482</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_1000.serialize.serialize_qps</td>
      <td width="200">361608.30649449414</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_1000.serialize.serialize_latency_us</td>
      <td width="200">2.765423199743964</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_1000.deserialize.deserialize_qps</td>
      <td width="200">220985.40618810226</td>
      <td width="160">messages/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">protobuf</td>
      <td width="160">35.1</td>
      <td width="420">results.size_parameter_sweep.size_1000.deserialize.deserialize_latency_us</td>
      <td width="200">4.525185700040311</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
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
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.SimpleMessage.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">6792635.878937954</td>
      <td width="160">3974163.958616489</td>
      <td width="240">0.5851</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.SimpleMessage.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">4364692.59458284</td>
      <td width="160">2545391.65103907</td>
      <td width="240">0.5832</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.SimpleMessage.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.14721825486049056</td>
      <td width="160">0.2516252500936389</td>
      <td width="240">0.5851</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.SimpleMessage.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.22911120962817222</td>
      <td width="160">0.3928668500157073</td>
      <td width="240">0.5832</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.RepeatedInt32.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">5509990.687916542</td>
      <td width="160">3165822.7876955485</td>
      <td width="240">0.5746</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.RepeatedInt32.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">1954186.7285045518</td>
      <td width="160">1232163.4331071523</td>
      <td width="240">0.6305</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.RepeatedInt32.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.18148850998841226</td>
      <td width="160">0.31587365025188774</td>
      <td width="240">0.5746</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.RepeatedInt32.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.511721825459972</td>
      <td width="160">0.8115806500427425</td>
      <td width="240">0.6305</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.RepeatedString.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">1691718.680461789</td>
      <td width="160">1356606.735333511</td>
      <td width="240">0.8019</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.RepeatedString.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">648731.1848006767</td>
      <td width="160">491526.899628101</td>
      <td width="240">0.7577</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.RepeatedString.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.5911148298764601</td>
      <td width="160">0.7371333002811298</td>
      <td width="240">0.8019</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.RepeatedString.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">1.5414705249713734</td>
      <td width="160">2.034476649714634</td>
      <td width="240">0.7577</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.NestedMessage.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">451848.17660889885</td>
      <td width="160">381967.78231078567</td>
      <td width="240">0.8453</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.NestedMessage.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">327742.45183779555</td>
      <td width="160">241145.92062043448</td>
      <td width="240">0.7358</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.NestedMessage.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">2.213132755132392</td>
      <td width="160">2.618021849775687</td>
      <td width="240">0.8453</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.NestedMessage.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">3.0511762952664867</td>
      <td width="160">4.146866749506444</td>
      <td width="240">0.7358</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.LargeMessage.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">2244370.795484512</td>
      <td width="160">1658892.4049382212</td>
      <td width="240">0.7391</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.LargeMessage.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">1024970.3320585456</td>
      <td width="160">749595.4900832964</td>
      <td width="240">0.7313</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.LargeMessage.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.4455591749865562</td>
      <td width="160">0.6028118502581492</td>
      <td width="240">0.7391</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results_summary.LargeMessage.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.9756379952887073</td>
      <td width="160">1.3340528501430526</td>
      <td width="240">0.7313</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.single_serialize.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">6910293.416952971</td>
      <td width="160">4310160.893309373</td>
      <td width="240">0.6237</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.single_serialize.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.14471165544819087</td>
      <td width="160">0.2320099005009979</td>
      <td width="240">0.6237</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.single_deserialize.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">4282688.069128675</td>
      <td width="160">2683804.728086668</td>
      <td width="240">0.6267</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.single_deserialize.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.23349821043666452</td>
      <td width="160">0.3726053499849513</td>
      <td width="240">0.6267</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.json_serialization.binary_serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">7139108.594805038</td>
      <td width="160">4279958.9671878135</td>
      <td width="240">0.5995</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.json_serialization.json_serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">90483.8491044991</td>
      <td width="160">66559.14192774918</td>
      <td width="240">0.7356</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.large_message.serialize.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">448898.2612614954</td>
      <td width="160">390636.0553012649</td>
      <td width="240">0.8702</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.large_message.serialize.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">2.22767626051791</td>
      <td width="160">2.5599275500280783</td>
      <td width="240">0.8702</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.large_message.deserialize.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">316006.40707979345</td>
      <td width="160">234096.70199745355</td>
      <td width="240">0.7408</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.large_message.deserialize.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">3.164492800133303</td>
      <td width="160">4.271738950046711</td>
      <td width="240">0.7408</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.multithread_serialize.threads_1.qps</td>
      <td width="180">越大越好</td>
      <td width="160">7122704.7153891465</td>
      <td width="160">4341101.154718958</td>
      <td width="240">0.6095</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.multithread_serialize.threads_2.qps</td>
      <td width="180">越大越好</td>
      <td width="160">7076589.682917681</td>
      <td width="160">4301975.450617706</td>
      <td width="240">0.6079</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.multithread_serialize.threads_4.qps</td>
      <td width="180">越大越好</td>
      <td width="160">7065122.885259582</td>
      <td width="160">4336512.506015474</td>
      <td width="240">0.6138</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.multithread_serialize.threads_8.qps</td>
      <td width="180">越大越好</td>
      <td width="160">7032093.620227746</td>
      <td width="160">4362360.3319906425</td>
      <td width="240">0.6204</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.multithread_deserialize.threads_1.qps</td>
      <td width="180">越大越好</td>
      <td width="160">4384416.719044427</td>
      <td width="160">2454997.1389276925</td>
      <td width="240">0.5599</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.multithread_deserialize.threads_2.qps</td>
      <td width="180">越大越好</td>
      <td width="160">4388136.652213462</td>
      <td width="160">2481231.9635232207</td>
      <td width="240">0.5654</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.multithread_deserialize.threads_4.qps</td>
      <td width="180">越大越好</td>
      <td width="160">4392071.2478530845</td>
      <td width="160">2460356.581048771</td>
      <td width="240">0.5602</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.multithread_deserialize.threads_8.qps</td>
      <td width="180">越大越好</td>
      <td width="160">4416037.342666258</td>
      <td width="160">2516667.575925956</td>
      <td width="240">0.5699</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_10.serialize.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">7437022.714286173</td>
      <td width="160">4666743.1942318985</td>
      <td width="240">0.6275</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_10.serialize.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.1344624103512615</td>
      <td width="160">0.21428220032248646</td>
      <td width="240">0.6275</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_10.deserialize.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">4176648.68603285</td>
      <td width="160">2476966.381443642</td>
      <td width="240">0.5931</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_10.deserialize.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.23942640982568264</td>
      <td width="160">0.4037196497665718</td>
      <td width="240">0.5931</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_50.serialize.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">6426819.689386147</td>
      <td width="160">4020269.394125555</td>
      <td width="240">0.6255</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_50.serialize.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.1555979548720643</td>
      <td width="160">0.24873955000657588</td>
      <td width="240">0.6255</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_50.deserialize.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">2598009.114124303</td>
      <td width="160">1586546.8432353449</td>
      <td width="240">0.6107</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_50.deserialize.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.38491012004669756</td>
      <td width="160">0.6302997004240751</td>
      <td width="240">0.6107</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_100.serialize.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">5481886.329279457</td>
      <td width="160">3458070.547962141</td>
      <td width="240">0.6308</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_100.serialize.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.18241895944811404</td>
      <td width="160">0.2891786000691354</td>
      <td width="240">0.6308</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_100.deserialize.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">1884380.53489582</td>
      <td width="160">1257533.7271997507</td>
      <td width="240">0.6673</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_100.deserialize.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">0.5306783749256283</td>
      <td width="160">0.7952073001069948</td>
      <td width="240">0.6673</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_500.serialize.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">377194.83361918974</td>
      <td width="160">708492.773732315</td>
      <td width="240">1.8783</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_500.serialize.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">2.6511497795581818</td>
      <td width="160">1.4114469999913126</td>
      <td width="240">1.8783</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_500.deserialize.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">429514.27805010113</td>
      <td width="160">396598.64311767265</td>
      <td width="240">0.9234</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_500.deserialize.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">2.328211310086772</td>
      <td width="160">2.5214408000465482</td>
      <td width="240">0.9234</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_1000.serialize.serialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">168868.0820744607</td>
      <td width="160">361608.30649449414</td>
      <td width="240">2.1414</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_1000.serialize.serialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">5.92178218474146</td>
      <td width="160">2.765423199743964</td>
      <td width="240">2.1414</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_1000.deserialize.deserialize_qps</td>
      <td width="180">越大越好</td>
      <td width="160">238579.88189556557</td>
      <td width="160">220985.40618810226</td>
      <td width="240">0.9263</td>
    </tr>
    <tr>
      <td width="160">protobuf</td>
      <td width="140">35.1</td>
      <td width="340">results.size_parameter_sweep.size_1000.deserialize.deserialize_latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">4.191468249773607</td>
      <td width="160">4.525185700040311</td>
      <td width="240">0.9263</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
