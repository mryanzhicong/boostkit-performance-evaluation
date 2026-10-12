# protobuf 33.0 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`38197866142-1`

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
      <td width="1200">33.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">33.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-10-12T02:59:25Z</td>
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
      <td width="1200">2026-10-12T02:57:55Z</td>
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
      <td width="500">AccLibBenchmark/protobuf-benchmark</td>
      <td width="880">01d083c6633babb2fb1307d93f596f10dda36778</td>
    </tr>
    <tr>
      <td width="500">google-benchmark</td>
      <td width="880">1.8.3</td>
    </tr>
  </tbody>
</table>

## 性能指标

### 序列化 / Scalar（非 packed）

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
      <td width="500">BM_Serialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="280">12.730802415389249</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">62.30242941506076</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">555.90264165955</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">5440.39465851169</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">15.521614178759508</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">113.5037447118371</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">1095.4090240505752</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">10847.674747505976</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">32.579116166205914</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">261.9391635165149</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">2420.9168850888705</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">25511.756107789275</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">15.528044353264333</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">113.50297374229858</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">1095.297066453881</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">10846.354666522831</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">39.58685943654013</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">346.58716764593464</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">3487.1021685503165</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">36036.95293845204</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">39.80427505810899</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">419.6560146257696</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">4199.526010298544</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">42826.360692334</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">44.29390472641847</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">407.1195164244171</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">4423.831226761075</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">45136.89083939897</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">53.09349190239119</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">485.65146410175095</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">4860.579503931422</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">48698.207095511345</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">37.80986832501881</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">318.87454892679983</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">3620.74600392486</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">36716.711456229415</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">51.41597668666759</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">463.1694899117606</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">5177.100213180108</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">51224.05058009751</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### 反序列化 / Scalar（非 packed）

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
      <td width="500">BM_Deserialize_Scalar_Bool/10/cpu_time_median</td>
      <td width="280">58.314168267418104</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/100/cpu_time_median</td>
      <td width="280">217.2813953333487</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/1000/cpu_time_median</td>
      <td width="280">1502.3405605085848</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Bool/10000/cpu_time_median</td>
      <td width="280">14093.152839439219</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10/cpu_time_median</td>
      <td width="280">72.25869045883226</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/100/cpu_time_median</td>
      <td width="280">201.5764047557181</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/1000/cpu_time_median</td>
      <td width="280">1320.2322536156494</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Double/10000/cpu_time_median</td>
      <td width="280">13347.022975827089</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10/cpu_time_median</td>
      <td width="280">60.23366956555907</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/100/cpu_time_median</td>
      <td width="280">211.79791638848207</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/1000/cpu_time_median</td>
      <td width="280">1311.467428604642</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Enum/10000/cpu_time_median</td>
      <td width="280">12276.709940997212</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10/cpu_time_median</td>
      <td width="280">52.336614669140765</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/100/cpu_time_median</td>
      <td width="280">174.5817704318639</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/1000/cpu_time_median</td>
      <td width="280">1114.1861847475857</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Float/10000/cpu_time_median</td>
      <td width="280">10590.230706847069</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10/cpu_time_median</td>
      <td width="280">67.69643902313894</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/100/cpu_time_median</td>
      <td width="280">281.4166458565572</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/1000/cpu_time_median</td>
      <td width="280">2510.73247065524</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int32/10000/cpu_time_median</td>
      <td width="280">24476.730688460248</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10/cpu_time_median</td>
      <td width="280">81.54142366712352</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/100/cpu_time_median</td>
      <td width="280">373.61692894179396</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/1000/cpu_time_median</td>
      <td width="280">3178.262684109637</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_Int64/10000/cpu_time_median</td>
      <td width="280">32066.777759992714</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10/cpu_time_median</td>
      <td width="280">65.29657308153983</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/100/cpu_time_median</td>
      <td width="280">319.457257480275</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/1000/cpu_time_median</td>
      <td width="280">2625.8198636623333</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt32/10000/cpu_time_median</td>
      <td width="280">27766.224773186328</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10/cpu_time_median</td>
      <td width="280">83.65244482581883</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/100/cpu_time_median</td>
      <td width="280">372.28148470578407</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/1000/cpu_time_median</td>
      <td width="280">3051.2541898649447</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_SInt64/10000/cpu_time_median</td>
      <td width="280">29963.27692472407</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10/cpu_time_median</td>
      <td width="280">63.74255051891661</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/100/cpu_time_median</td>
      <td width="280">282.30968812238274</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/1000/cpu_time_median</td>
      <td width="280">2495.2839257593328</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt32/10000/cpu_time_median</td>
      <td width="280">24420.336170658327</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10/cpu_time_median</td>
      <td width="280">87.1754710780835</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/100/cpu_time_median</td>
      <td width="280">376.83390489230175</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/1000/cpu_time_median</td>
      <td width="280">3300.4718344865605</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Scalar_UInt64/10000/cpu_time_median</td>
      <td width="280">32522.609497025056</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### 序列化 / Repeated（packed）

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
      <td width="500">BM_Serialize_Repeated_Double/10/cpu_time_median</td>
      <td width="280">10.292970688887142</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">16.803404526583467</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">87.10188294831264</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1417.1168299046033</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">10.5638098182478</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">12.917665137451367</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">49.69510324900162</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">724.0970214879504</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">33.34097384260901</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">313.12737597392135</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">3543.327486485141</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">36425.25079414448</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">47.159034568265895</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">359.082796082213</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">4092.489738170606</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">41232.97182349776</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">43.43663619639812</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">336.59858980868876</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">3869.741170161719</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">38297.988865788604</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">53.75834583480516</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">469.3211760579024</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">4743.633497205431</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">47804.11243295473</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">33.87513443712681</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">296.2234127725062</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">3390.659181028648</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">34420.38423151051</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">41.008772757404365</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">384.87106172237395</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">4236.362570243617</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">41683.67215532847</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### 反序列化 / Repeated（packed）

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
      <td width="500">BM_Deserialize_Repeated_Double/10/cpu_time_median</td>
      <td width="280">28.17929512755131</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/100/cpu_time_median</td>
      <td width="280">35.12388808317133</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/1000/cpu_time_median</td>
      <td width="280">115.15504727150437</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Double/10000/cpu_time_median</td>
      <td width="280">1453.5831042922287</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10/cpu_time_median</td>
      <td width="280">27.365944913556866</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/100/cpu_time_median</td>
      <td width="280">30.10973489511689</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/1000/cpu_time_median</td>
      <td width="280">75.72701403321469</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Float/10000/cpu_time_median</td>
      <td width="280">759.2753212408709</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10/cpu_time_median</td>
      <td width="280">63.077038196323535</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/100/cpu_time_median</td>
      <td width="280">285.2882988998803</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/1000/cpu_time_median</td>
      <td width="280">2896.091156707272</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int32/10000/cpu_time_median</td>
      <td width="280">29753.80087968982</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10/cpu_time_median</td>
      <td width="280">77.980200431885</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/100/cpu_time_median</td>
      <td width="280">407.2545626239596</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/1000/cpu_time_median</td>
      <td width="280">4322.2463487381465</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_Int64/10000/cpu_time_median</td>
      <td width="280">43554.694457412195</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10/cpu_time_median</td>
      <td width="280">67.20615479659492</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/100/cpu_time_median</td>
      <td width="280">285.67208574456197</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/1000/cpu_time_median</td>
      <td width="280">3335.8397766375906</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt32/10000/cpu_time_median</td>
      <td width="280">31830.10457367779</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10/cpu_time_median</td>
      <td width="280">82.0925831624184</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/100/cpu_time_median</td>
      <td width="280">469.23781780229876</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/1000/cpu_time_median</td>
      <td width="280">4640.334032336113</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_SInt64/10000/cpu_time_median</td>
      <td width="280">46818.77938716688</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10/cpu_time_median</td>
      <td width="280">65.03329332770764</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/100/cpu_time_median</td>
      <td width="280">294.8451180334301</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/1000/cpu_time_median</td>
      <td width="280">3025.1553835288023</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt32/10000/cpu_time_median</td>
      <td width="280">29877.501621577398</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10/cpu_time_median</td>
      <td width="280">83.6405613406426</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/100/cpu_time_median</td>
      <td width="280">432.64358268245576</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/1000/cpu_time_median</td>
      <td width="280">4382.062668227094</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Repeated_UInt64/10000/cpu_time_median</td>
      <td width="280">44852.53943890859</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### 序列化 / String 与 Bytes

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
      <td width="500">BM_Serialize_Bytes/10/cpu_time_median</td>
      <td width="280">10.834853580672254</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/100/cpu_time_median</td>
      <td width="280">11.376544996407345</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/1000/cpu_time_median</td>
      <td width="280">20.37298280842831</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_Bytes/10000/cpu_time_median</td>
      <td width="280">108.27022994519953</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">15.440598568402969</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">18.42185277419368</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">75.14357000415232</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">635.2673826255109</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">17.60967853709346</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">29.588674799549715</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">178.0475670283737</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Serialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1646.1563197584178</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### 反序列化 / String 与 Bytes

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
      <td width="500">BM_Deserialize_Bytes/10/cpu_time_median</td>
      <td width="280">38.47571286339389</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/100/cpu_time_median</td>
      <td width="280">47.15359066548778</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/1000/cpu_time_median</td>
      <td width="280">52.655009614237656</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_Bytes/10000/cpu_time_median</td>
      <td width="280">234.25719362032603</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10/cpu_time_median</td>
      <td width="280">43.356336925572855</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/100/cpu_time_median</td>
      <td width="280">55.96474633394462</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/1000/cpu_time_median</td>
      <td width="280">110.54830403096229</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_ASCII/10000/cpu_time_median</td>
      <td width="280">790.8865353495446</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10/cpu_time_median</td>
      <td width="280">46.704383425785174</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/100/cpu_time_median</td>
      <td width="280">63.54322524315966</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/1000/cpu_time_median</td>
      <td width="280">219.29941785297547</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">BM_Deserialize_String_Chinese/10000/cpu_time_median</td>
      <td width="280">1783.351909791547</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
