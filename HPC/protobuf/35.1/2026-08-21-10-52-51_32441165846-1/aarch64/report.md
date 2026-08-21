# protobuf 35.1 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`32441165846-1`

## 测试环境

### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">aarch64</th>
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
      <td width="1200">2026-08-21T02:50:23Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">aarch64</td>
    </tr>
  </tbody>
</table>

### 系统信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="1200">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="1200">2026-08-21T02:48:58Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">Kunpeng 920 7270Z To be filled by O.E.M. CPU @ 2.9GHz</td>
    </tr>
    <tr>
      <td width="180">CPU 核数</td>
      <td width="1200">256</td>
    </tr>
    <tr>
      <td width="180">操作系统</td>
      <td width="1200">openEuler 24.03 (LTS-SP4)</td>
    </tr>
    <tr>
      <td width="180">内核</td>
      <td width="1200">6.6.0-159.4.3.154.oe2403sp4.aarch64</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 128025 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 124680 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127294 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 128459 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
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
      <td width="280">3974163.958616489</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.SimpleMessage.deserialize_qps</td>
      <td width="280">2545391.65103907</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.SimpleMessage.serialize_latency_us</td>
      <td width="280">0.2516252500936389</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.SimpleMessage.deserialize_latency_us</td>
      <td width="280">0.3928668500157073</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedInt32.serialize_qps</td>
      <td width="280">3165822.7876955485</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedInt32.deserialize_qps</td>
      <td width="280">1232163.4331071523</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedInt32.serialize_latency_us</td>
      <td width="280">0.31587365025188774</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedInt32.deserialize_latency_us</td>
      <td width="280">0.8115806500427425</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedString.serialize_qps</td>
      <td width="280">1356606.735333511</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedString.deserialize_qps</td>
      <td width="280">491526.899628101</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedString.serialize_latency_us</td>
      <td width="280">0.7371333002811298</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.RepeatedString.deserialize_latency_us</td>
      <td width="280">2.034476649714634</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.NestedMessage.serialize_qps</td>
      <td width="280">381967.78231078567</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.NestedMessage.deserialize_qps</td>
      <td width="280">241145.92062043448</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.NestedMessage.serialize_latency_us</td>
      <td width="280">2.618021849775687</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.NestedMessage.deserialize_latency_us</td>
      <td width="280">4.146866749506444</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.LargeMessage.serialize_qps</td>
      <td width="280">1658892.4049382212</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.LargeMessage.deserialize_qps</td>
      <td width="280">749595.4900832964</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.LargeMessage.serialize_latency_us</td>
      <td width="280">0.6028118502581492</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results_summary.LargeMessage.deserialize_latency_us</td>
      <td width="280">1.3340528501430526</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.single_serialize.serialize_qps</td>
      <td width="280">4310160.893309373</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.single_serialize.serialize_latency_us</td>
      <td width="280">0.2320099005009979</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.single_deserialize.deserialize_qps</td>
      <td width="280">2683804.728086668</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.single_deserialize.deserialize_latency_us</td>
      <td width="280">0.3726053499849513</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.json_serialization.binary_serialize_qps</td>
      <td width="280">4279958.9671878135</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.json_serialization.json_serialize_qps</td>
      <td width="280">66559.14192774918</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.large_message.serialize.serialize_qps</td>
      <td width="280">390636.0553012649</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.large_message.serialize.serialize_latency_us</td>
      <td width="280">2.5599275500280783</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.large_message.deserialize.deserialize_qps</td>
      <td width="280">234096.70199745355</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.large_message.deserialize.deserialize_latency_us</td>
      <td width="280">4.271738950046711</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_serialize.threads_1.qps</td>
      <td width="280">4341101.154718958</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_serialize.threads_2.qps</td>
      <td width="280">4301975.450617706</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_serialize.threads_4.qps</td>
      <td width="280">4336512.506015474</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_serialize.threads_8.qps</td>
      <td width="280">4362360.3319906425</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_deserialize.threads_1.qps</td>
      <td width="280">2454997.1389276925</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_deserialize.threads_2.qps</td>
      <td width="280">2481231.9635232207</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_deserialize.threads_4.qps</td>
      <td width="280">2460356.581048771</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.multithread_deserialize.threads_8.qps</td>
      <td width="280">2516667.575925956</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_10.serialize.serialize_qps</td>
      <td width="280">4666743.1942318985</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_10.serialize.serialize_latency_us</td>
      <td width="280">0.21428220032248646</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_10.deserialize.deserialize_qps</td>
      <td width="280">2476966.381443642</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_10.deserialize.deserialize_latency_us</td>
      <td width="280">0.4037196497665718</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_50.serialize.serialize_qps</td>
      <td width="280">4020269.394125555</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_50.serialize.serialize_latency_us</td>
      <td width="280">0.24873955000657588</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_50.deserialize.deserialize_qps</td>
      <td width="280">1586546.8432353449</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_50.deserialize.deserialize_latency_us</td>
      <td width="280">0.6302997004240751</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_100.serialize.serialize_qps</td>
      <td width="280">3458070.547962141</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_100.serialize.serialize_latency_us</td>
      <td width="280">0.2891786000691354</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_100.deserialize.deserialize_qps</td>
      <td width="280">1257533.7271997507</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_100.deserialize.deserialize_latency_us</td>
      <td width="280">0.7952073001069948</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_500.serialize.serialize_qps</td>
      <td width="280">708492.773732315</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_500.serialize.serialize_latency_us</td>
      <td width="280">1.4114469999913126</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_500.deserialize.deserialize_qps</td>
      <td width="280">396598.64311767265</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_500.deserialize.deserialize_latency_us</td>
      <td width="280">2.5214408000465482</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_1000.serialize.serialize_qps</td>
      <td width="280">361608.30649449414</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_1000.serialize.serialize_latency_us</td>
      <td width="280">2.765423199743964</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_1000.deserialize.deserialize_qps</td>
      <td width="280">220985.40618810226</td>
      <td width="200">messages/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">results.size_parameter_sweep.size_1000.deserialize.deserialize_latency_us</td>
      <td width="280">4.525185700040311</td>
      <td width="200">us</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
