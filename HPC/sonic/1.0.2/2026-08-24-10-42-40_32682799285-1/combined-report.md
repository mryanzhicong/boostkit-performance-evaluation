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
      <td width="220">sonic</td>
      <td width="160">1.0.2</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">sonic</td>
      <td width="160">1.0.2</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### sonic 1.0.2

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
      <td width="600">1.0.2</td>
      <td width="600">1.0.2</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.0.2</td>
      <td width="600">1.0.2</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-08-24T02:22:21Z</td>
      <td width="600">2026-08-24T02:22:35Z</td>
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
      <td width="600">2026-08-24T02:21:21Z</td>
      <td width="600">2026-08-24T02:20:50Z</td>
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
      <td width="600">available: 1 nodes (0)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>node 0 size: 30886 MB<br>node 0 free: 16295 MB<br>node distances:<br>node   0 <br>  0:  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 128008 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 124629 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127300 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 128423 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
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
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/SonicOnDemand_Normal</td>
      <td width="200">16048.888710601721</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/RapidjsonSaxOnDemand_Normal</td>
      <td width="200">325659.4186046509</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/SIMDjsonOnDemand_Normal</td>
      <td width="200">52170.023853894905</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="200">9403.920682394275</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/RapidjsonSaxOnDemand_Fronter</td>
      <td width="200">96683.20992522102</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/SIMDjsonOnDemand_Fronter</td>
      <td width="200">227859.69993476867</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/SonicOnDemand_NotFound</td>
      <td width="200">15952.886017682924</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/RapidjsonSaxOnDemand_NotFound</td>
      <td width="200">328488.91553261527</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/SIMDjsonOnDemand_NotFound</td>
      <td width="200">52142.32333806925</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Decode_SonicDyn</td>
      <td width="200">273229.6534267934</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Decode_Rapidjson</td>
      <td width="200">957589.3991989322</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Decode_YYjson</td>
      <td width="200">1019323.5953420701</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Decode_SIMDjson</td>
      <td width="200">369236.99208443175</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Decode_JsonCpp</td>
      <td width="200">25991595.92592604</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Decode_SonicDyn</td>
      <td width="200">101259.69771478168</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Decode_Rapidjson</td>
      <td width="200">362316.49767201516</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Decode_YYjson</td>
      <td width="200">324533.57904496934</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Decode_SIMDjson</td>
      <td width="200">81486.9635205552</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Decode_JsonCpp</td>
      <td width="200">9672229.999999907</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Decode_SonicDyn</td>
      <td width="200">812757.1528588008</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Decode_Rapidjson</td>
      <td width="200">4797759.178082215</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Decode_YYjson</td>
      <td width="200">2692740.0384615487</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Decode_SIMDjson</td>
      <td width="200">955336.2587904412</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Decode_JsonCpp</td>
      <td width="200">75440159.00000004</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Decode_SonicDyn</td>
      <td width="200">143494627.50000086</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Decode_Rapidjson</td>
      <td width="200">220256419.99999833</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Decode_YYjson</td>
      <td width="200">182755752.5000003</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Decode_SIMDjson</td>
      <td width="200">111404358.16666874</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Decode_JsonCpp</td>
      <td width="200">12630814559.000015</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Decode_SonicDyn</td>
      <td width="200">453780.4977375587</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Decode_Rapidjson</td>
      <td width="200">878204.4362744621</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Decode_YYjson</td>
      <td width="200">857415.1348039083</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Decode_SIMDjson</td>
      <td width="200">369682.2681121313</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Decode_JsonCpp</td>
      <td width="200">74418972.00000085</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Decode_SonicDyn</td>
      <td width="200">627929.9008115666</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Decode_Rapidjson</td>
      <td width="200">4482326.17834405</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Decode_YYjson</td>
      <td width="200">4306039.814814694</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Decode_SIMDjson</td>
      <td width="200">793039.5647193792</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Decode_JsonCpp</td>
      <td width="200">49938996.99999815</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Decode_SonicDyn</td>
      <td width="200">22332.853364771607</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Decode_Rapidjson</td>
      <td width="200">98928.13798954069</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Decode_YYjson</td>
      <td width="200">84278.62247353408</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Decode_SIMDjson</td>
      <td width="200">16905.668869699464</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Decode_JsonCpp</td>
      <td width="200">2232335.365079413</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Decode_SonicDyn</td>
      <td width="200">48299622.85714373</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Decode_Rapidjson</td>
      <td width="200">112125248.00000665</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Decode_YYjson</td>
      <td width="200">111941399.99999683</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Decode_SIMDjson</td>
      <td width="200">58566850.8333299</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Decode_JsonCpp</td>
      <td width="200">5736172839.999994</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Decode_SonicDyn</td>
      <td width="200">607935.2170139293</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Decode_Rapidjson</td>
      <td width="200">1600371.6113636622</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Decode_YYjson</td>
      <td width="200">2051966.568914891</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Decode_SIMDjson</td>
      <td width="200">593878.2088285468</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Decode_JsonCpp</td>
      <td width="200">62818529.91666881</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Decode_SonicDyn</td>
      <td width="200">2121648.23708214</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Decode_Rapidjson</td>
      <td width="200">3044944.130434764</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Decode_YYjson</td>
      <td width="200">7110193.163265306</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Decode_SIMDjson</td>
      <td width="200">2141053.944954167</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Decode_JsonCpp</td>
      <td width="200">314462544.9999978</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Decode_SonicDyn</td>
      <td width="200">495.7701261076692</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Decode_Rapidjson</td>
      <td width="200">919.5489135272941</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Decode_YYjson</td>
      <td width="200">813.1092370588777</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Decode_SIMDjson</td>
      <td width="200">444.05453873712804</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Decode_JsonCpp</td>
      <td width="200">69947.80597461876</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Encode_SonicDyn</td>
      <td width="200">137713.68379446532</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Encode_Rapidjson</td>
      <td width="200">523526.0687593378</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Encode_YYjson</td>
      <td width="200">432455.7286773759</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Encode_SIMDjson</td>
      <td width="200">317780.7242465152</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Encode_JsonCpp</td>
      <td width="200">11972650.172413658</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Encode_SonicDyn</td>
      <td width="200">51394.32807407131</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Encode_Rapidjson</td>
      <td width="200">225891.19009325514</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Encode_YYjson</td>
      <td width="200">151594.21645022256</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Encode_SIMDjson</td>
      <td width="200">136559.37695311592</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Encode_JsonCpp</td>
      <td width="200">4974909.500000583</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Encode_SonicDyn</td>
      <td width="200">506455.03249097115</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Encode_Rapidjson</td>
      <td width="200">2486190.141844047</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Encode_YYjson</td>
      <td width="200">1154925.2883031042</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Encode_SIMDjson</td>
      <td width="200">1283169.5978061603</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Encode_JsonCpp</td>
      <td width="200">61622436.363636136</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Encode_SonicDyn</td>
      <td width="200">76177007.77777575</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Encode_Rapidjson</td>
      <td width="200">136949600.00000265</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Encode_YYjson</td>
      <td width="200">134575731.9999848</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Encode_SIMDjson</td>
      <td width="200">120600763.33331914</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Encode_JsonCpp</td>
      <td width="200">5202643670.000044</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Encode_SonicDyn</td>
      <td width="200">479348.45099384186</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Encode_Rapidjson</td>
      <td width="200">794972.8213879718</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Encode_YYjson</td>
      <td width="200">940431.0872482803</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Encode_SIMDjson</td>
      <td width="200">664870.8550186565</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Encode_JsonCpp</td>
      <td width="200">27978467.60000084</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Encode_SonicDyn</td>
      <td width="200">356862.1854304712</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Encode_Rapidjson</td>
      <td width="200">2374083.355932456</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Encode_YYjson</td>
      <td width="200">2151006.3384616496</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Encode_SIMDjson</td>
      <td width="200">2942503.3054393632</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Encode_JsonCpp</td>
      <td width="200">35216325.999999754</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Encode_SonicDyn</td>
      <td width="200">12150.746279036994</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Encode_Rapidjson</td>
      <td width="200">54145.034498620174</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Encode_YYjson</td>
      <td width="200">30419.301830194483</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Encode_SIMDjson</td>
      <td width="200">33372.886947390725</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Encode_JsonCpp</td>
      <td width="200">1053016.1144578324</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Encode_SonicDyn</td>
      <td width="200">26596393.461536888</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Encode_Rapidjson</td>
      <td width="200">59666210.83333242</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Encode_YYjson</td>
      <td width="200">65162729.090905644</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Encode_SIMDjson</td>
      <td width="200">67880724.5454581</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Encode_JsonCpp</td>
      <td width="200">2295063030.000051</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Encode_SonicDyn</td>
      <td width="200">275680.16548465186</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Encode_Rapidjson</td>
      <td width="200">591411.6030534247</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Encode_YYjson</td>
      <td width="200">646968.0424746423</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Encode_SIMDjson</td>
      <td width="200">520254.710622694</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Encode_JsonCpp</td>
      <td width="200">23961944.82758441</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Encode_SonicDyn</td>
      <td width="200">3776130.5405404754</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Encode_Rapidjson</td>
      <td width="200">7407965.000000553</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Encode_YYjson</td>
      <td width="200">7237600.515463548</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Encode_SIMDjson</td>
      <td width="200">3472160.143564006</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Encode_JsonCpp</td>
      <td width="200">121283118.33333783</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Encode_SonicDyn</td>
      <td width="200">324.7221723045783</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Encode_Rapidjson</td>
      <td width="200">791.0853856745609</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Encode_YYjson</td>
      <td width="200">683.4312254411434</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Encode_SIMDjson</td>
      <td width="200">495.86343581117734</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Encode_JsonCpp</td>
      <td width="200">34280.972507581</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Stat_SonicDyn</td>
      <td width="200">46350.10129767184</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Find_SonicDyn</td>
      <td width="200">142624.1869502999</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Stat_Rapidjson</td>
      <td width="200">52157.82378394641</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Find_Rapidjson</td>
      <td width="200">176270.66918002948</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Stat_SonicDyn</td>
      <td width="200">18318.550699988285</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Find_SonicDyn</td>
      <td width="200">52679.653153158804</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Stat_Rapidjson</td>
      <td width="200">20050.356826304505</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Find_Rapidjson</td>
      <td width="200">59671.72746587525</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Stat_SonicDyn</td>
      <td width="200">115897.85903375647</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Find_SonicDyn</td>
      <td width="200">182754.66057441113</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Stat_Rapidjson</td>
      <td width="200">150149.87569653612</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Find_Rapidjson</td>
      <td width="200">168477.25391094573</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Stat_SonicDyn</td>
      <td width="200">58199956.66666955</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Find_SonicDyn</td>
      <td width="200">810134950.0000197</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Stat_Rapidjson</td>
      <td width="200">55411527.49999394</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Find_Rapidjson</td>
      <td width="200">1094134670.0000167</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Stat_SonicDyn</td>
      <td width="200">173269.6587030882</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Find_SonicDyn</td>
      <td width="200">234283.15947845267</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Stat_Rapidjson</td>
      <td width="200">161096.76686555104</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Find_Rapidjson</td>
      <td width="200">193195.1723194705</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Stat_SonicDyn</td>
      <td width="200">60155.53617460346</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Find_SonicDyn</td>
      <td width="200">1328744.9666665907</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Stat_Rapidjson</td>
      <td width="200">92455.71582490664</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Find_Rapidjson</td>
      <td width="200">1516164.6753248142</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Stat_SonicDyn</td>
      <td width="200">4319.330293339923</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Find_SonicDyn</td>
      <td width="200">9082.17097848171</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Stat_Rapidjson</td>
      <td width="200">4591.930276793411</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Find_Rapidjson</td>
      <td width="200">11112.328330714907</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Stat_SonicDyn</td>
      <td width="200">13389612.181818353</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Find_SonicDyn</td>
      <td width="200">23621324.333331965</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Stat_Rapidjson</td>
      <td width="200">13280090.75471845</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Find_Rapidjson</td>
      <td width="200">24254816.20689582</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Stat_SonicDyn</td>
      <td width="200">132802.56749209878</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Find_SonicDyn</td>
      <td width="200">214257.926717548</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Stat_Rapidjson</td>
      <td width="200">134935.81065318553</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Find_Rapidjson</td>
      <td width="200">202765.4106419931</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Stat_SonicDyn</td>
      <td width="200">607605.9513830013</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Find_SonicDyn</td>
      <td width="200">488506.362369374</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Stat_Rapidjson</td>
      <td width="200">566472.8003246373</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Find_Rapidjson</td>
      <td width="200">406596.97850085015</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Stat_SonicDyn</td>
      <td width="200">111.4258827426681</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Find_SonicDyn</td>
      <td width="200">166.7971845327386</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Stat_Rapidjson</td>
      <td width="200">128.21111475764934</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Find_Rapidjson</td>
      <td width="200">129.95218700129337</td>
      <td width="160">ns</td>
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
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/SonicOnDemand_Normal</td>
      <td width="200">34204.01005564775</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/RapidjsonSaxOnDemand_Normal</td>
      <td width="200">850724.9817739982</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/SIMDjsonOnDemand_Normal</td>
      <td width="200">78763.00710339384</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="200">18026.093013673944</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/RapidjsonSaxOnDemand_Fronter</td>
      <td width="200">164262.98615998172</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/SIMDjsonOnDemand_Fronter</td>
      <td width="200">342296.5281173593</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/SonicOnDemand_NotFound</td>
      <td width="200">34008.34556857396</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/RapidjsonSaxOnDemand_NotFound</td>
      <td width="200">850913.9659367418</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/SIMDjsonOnDemand_NotFound</td>
      <td width="200">78807.68822666245</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Decode_SonicDyn</td>
      <td width="200">413650.32505910343</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Decode_Rapidjson</td>
      <td width="200">1911144.153005459</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Decode_YYjson</td>
      <td width="200">2146443.6196319023</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Decode_SIMDjson</td>
      <td width="200">728507.0219435784</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Decode_JsonCpp</td>
      <td width="200">30054944.78260851</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Decode_SonicDyn</td>
      <td width="200">191061.08986615654</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Decode_Rapidjson</td>
      <td width="200">836174.169653526</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Decode_YYjson</td>
      <td width="200">800443.531428568</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Decode_SIMDjson</td>
      <td width="200">132753.5384615371</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Decode_JsonCpp</td>
      <td width="200">11503573.278688593</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Decode_SonicDyn</td>
      <td width="200">1524254.8583878085</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Decode_Rapidjson</td>
      <td width="200">13958770.40000016</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Decode_YYjson</td>
      <td width="200">6585659.2452829685</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Decode_SIMDjson</td>
      <td width="200">1739431.6120906784</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Decode_JsonCpp</td>
      <td width="200">86982900.00000004</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Decode_SonicDyn</td>
      <td width="200">169928782.49999776</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Decode_Rapidjson</td>
      <td width="200">286950685.0000008</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Decode_YYjson</td>
      <td width="200">308543190.0000018</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Decode_SIMDjson</td>
      <td width="200">126197840.00000088</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Decode_JsonCpp</td>
      <td width="200">14541668620.000025</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Decode_SonicDyn</td>
      <td width="200">688973.3992094558</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Decode_Rapidjson</td>
      <td width="200">1207166.7125645694</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Decode_YYjson</td>
      <td width="200">1844553.7467019346</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Decode_SIMDjson</td>
      <td width="200">552817.7179080982</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Decode_JsonCpp</td>
      <td width="200">87115502.50000499</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Decode_SonicDyn</td>
      <td width="200">1198926.6324786304</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Decode_Rapidjson</td>
      <td width="200">13031964.8148145</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Decode_YYjson</td>
      <td width="200">8098033.720930183</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Decode_SIMDjson</td>
      <td width="200">1298231.8773234414</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Decode_JsonCpp</td>
      <td width="200">57893922.30769426</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Decode_SonicDyn</td>
      <td width="200">44865.71730905178</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Decode_Rapidjson</td>
      <td width="200">223537.9001280313</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Decode_YYjson</td>
      <td width="200">178302.47706421773</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Decode_SIMDjson</td>
      <td width="200">28866.9002587209</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Decode_JsonCpp</td>
      <td width="200">2573254.835164794</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Decode_SonicDyn</td>
      <td width="200">69555158.74999918</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Decode_Rapidjson</td>
      <td width="200">195917713.33333933</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Decode_YYjson</td>
      <td width="200">201919809.99999258</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Decode_SIMDjson</td>
      <td width="200">61040556.66666852</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Decode_JsonCpp</td>
      <td width="200">6689287329.999956</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Decode_SonicDyn</td>
      <td width="200">1209177.979274654</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Decode_Rapidjson</td>
      <td width="200">2440363.240417966</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Decode_YYjson</td>
      <td width="200">5917354.067796392</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Decode_SIMDjson</td>
      <td width="200">752196.5980498013</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Decode_JsonCpp</td>
      <td width="200">71797844.00000244</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Decode_SonicDyn</td>
      <td width="200">4045774.4508670913</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Decode_Rapidjson</td>
      <td width="200">4146655.7396451114</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Decode_YYjson</td>
      <td width="200">13089401.698113186</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Decode_SIMDjson</td>
      <td width="200">2858815.5918367524</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Decode_JsonCpp</td>
      <td width="200">410459205.000052</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Decode_SonicDyn</td>
      <td width="200">721.1745638267902</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Decode_Rapidjson</td>
      <td width="200">1341.6198725605823</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Decode_YYjson</td>
      <td width="200">1634.1799044448828</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Decode_SIMDjson</td>
      <td width="200">696.9924148475571</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Decode_JsonCpp</td>
      <td width="200">88623.18049397743</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Encode_SonicDyn</td>
      <td width="200">289775.25206612854</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Encode_Rapidjson</td>
      <td width="200">1258670.1981982097</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Encode_YYjson</td>
      <td width="200">1148419.607201245</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Encode_SIMDjson</td>
      <td width="200">568033.7703583247</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Encode_JsonCpp</td>
      <td width="200">18008668.97435928</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Encode_SonicDyn</td>
      <td width="200">108032.72322798586</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Encode_Rapidjson</td>
      <td width="200">564960.1860841321</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Encode_YYjson</td>
      <td width="200">420786.32751353784</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Encode_SIMDjson</td>
      <td width="200">241897.71784233893</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Encode_JsonCpp</td>
      <td width="200">7568214.065933498</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Encode_SonicDyn</td>
      <td width="200">925225.8068781752</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Encode_Rapidjson</td>
      <td width="200">8320894.404762601</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Encode_YYjson</td>
      <td width="200">2581267.1955718943</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Encode_SIMDjson</td>
      <td width="200">2262145.1132687647</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Encode_JsonCpp</td>
      <td width="200">89687335.00000781</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Encode_SonicDyn</td>
      <td width="200">129355200.00000906</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Encode_Rapidjson</td>
      <td width="200">210231700.00000846</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Encode_YYjson</td>
      <td width="200">410980844.9999832</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Encode_SIMDjson</td>
      <td width="200">217108230.00000802</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Encode_JsonCpp</td>
      <td width="200">7405751479.999936</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Encode_SonicDyn</td>
      <td width="200">778470.3218645431</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Encode_Rapidjson</td>
      <td width="200">1302374.2085660934</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Encode_YYjson</td>
      <td width="200">3110305.4666669373</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Encode_SIMDjson</td>
      <td width="200">1101511.1811022907</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Encode_JsonCpp</td>
      <td width="200">38845357.77777703</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Encode_SonicDyn</td>
      <td width="200">642551.4456722026</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Encode_Rapidjson</td>
      <td width="200">7534220.7526881145</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Encode_YYjson</td>
      <td width="200">3987523.028571818</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Encode_SIMDjson</td>
      <td width="200">4930424.295775032</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Encode_JsonCpp</td>
      <td width="200">49839828.571423694</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Encode_SonicDyn</td>
      <td width="200">25742.233690212663</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Encode_Rapidjson</td>
      <td width="200">144366.2017742926</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Encode_YYjson</td>
      <td width="200">84789.54435287963</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Encode_SIMDjson</td>
      <td width="200">61080.024604561295</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Encode_JsonCpp</td>
      <td width="200">1534855.7675439492</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Encode_SonicDyn</td>
      <td width="200">58066361.666665986</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Encode_Rapidjson</td>
      <td width="200">139815132.00001246</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Encode_YYjson</td>
      <td width="200">206465946.66663986</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Encode_SIMDjson</td>
      <td width="200">108688988.33333182</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Encode_JsonCpp</td>
      <td width="200">3323575669.9999685</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Encode_SonicDyn</td>
      <td width="200">579018.4987277444</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Encode_Rapidjson</td>
      <td width="200">1241749.6447601372</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Encode_YYjson</td>
      <td width="200">2108464.93975893</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Encode_SIMDjson</td>
      <td width="200">1024541.2463343702</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Encode_JsonCpp</td>
      <td width="200">34337650.50000375</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Encode_SonicDyn</td>
      <td width="200">4256248.780487711</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Encode_Rapidjson</td>
      <td width="200">7992264.090909563</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Encode_YYjson</td>
      <td width="200">22184745.31250081</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Encode_SIMDjson</td>
      <td width="200">4641189.668873929</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Encode_JsonCpp</td>
      <td width="200">162094747.4999923</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Encode_SonicDyn</td>
      <td width="200">593.4214018408036</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Encode_Rapidjson</td>
      <td width="200">1192.1038453412114</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Encode_YYjson</td>
      <td width="200">2322.690556470292</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Encode_SIMDjson</td>
      <td width="200">989.5754209681909</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Encode_JsonCpp</td>
      <td width="200">49012.84193571157</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Stat_SonicDyn</td>
      <td width="200">62563.003403801355</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Find_SonicDyn</td>
      <td width="200">193501.8639380588</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Stat_Rapidjson</td>
      <td width="200">49984.93005236599</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitterescaped/Find_Rapidjson</td>
      <td width="200">186018.45664282533</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Stat_SonicDyn</td>
      <td width="200">23244.076789305043</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Find_SonicDyn</td>
      <td width="200">73131.68217459705</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Stat_Rapidjson</td>
      <td width="200">19273.515326461686</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">twitter/Find_Rapidjson</td>
      <td width="200">72447.20364427363</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Stat_SonicDyn</td>
      <td width="200">144110.03083248096</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Find_SonicDyn</td>
      <td width="200">298803.70590733906</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Stat_Rapidjson</td>
      <td width="200">267772.3156681851</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">poet/Find_Rapidjson</td>
      <td width="200">276859.2400155057</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Stat_SonicDyn</td>
      <td width="200">53709667.69230388</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Find_SonicDyn</td>
      <td width="200">1443872409.999926</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Stat_Rapidjson</td>
      <td width="200">45553698.00000335</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">otfcc/Find_Rapidjson</td>
      <td width="200">1096783200.0000043</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Stat_SonicDyn</td>
      <td width="200">207473.21523474238</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Find_SonicDyn</td>
      <td width="200">442888.29022075236</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Stat_Rapidjson</td>
      <td width="200">177831.7947421832</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">lottie/Find_Rapidjson</td>
      <td width="200">276436.10250296135</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Stat_SonicDyn</td>
      <td width="200">80643.88908066109</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Find_SonicDyn</td>
      <td width="200">2164680.1851851633</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Stat_Rapidjson</td>
      <td width="200">137338.91590274434</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">gsoc-2018/Find_Rapidjson</td>
      <td width="200">2093277.8851962003</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Stat_SonicDyn</td>
      <td width="200">5547.8865169439005</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Find_SonicDyn</td>
      <td width="200">14991.360507635123</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Stat_Rapidjson</td>
      <td width="200">4587.087580515684</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">github_events/Find_Rapidjson</td>
      <td width="200">11262.04813849506</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Stat_SonicDyn</td>
      <td width="200">15614733.863639105</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Find_SonicDyn</td>
      <td width="200">34258723.49999963</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Stat_Rapidjson</td>
      <td width="200">13015029.629627861</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">fgo/Find_Rapidjson</td>
      <td width="200">24181491.37931072</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Stat_SonicDyn</td>
      <td width="200">174141.99950319788</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Find_SonicDyn</td>
      <td width="200">338811.11813313566</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Stat_Rapidjson</td>
      <td width="200">155391.9603474979</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">citm_catalog/Find_Rapidjson</td>
      <td width="200">202372.9762245391</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Stat_SonicDyn</td>
      <td width="200">601220.6952790476</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Find_SonicDyn</td>
      <td width="200">520333.5267856413</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Stat_Rapidjson</td>
      <td width="200">485911.6620499161</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">canada/Find_Rapidjson</td>
      <td width="200">297612.0654483389</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Stat_SonicDyn</td>
      <td width="200">139.2232624508445</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Find_SonicDyn</td>
      <td width="200">267.67018588448815</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Stat_Rapidjson</td>
      <td width="200">117.13673603101704</td>
      <td width="160">ns</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">sonic</td>
      <td width="160">1.0.2</td>
      <td width="420">book/Find_Rapidjson</td>
      <td width="200">183.33140608304282</td>
      <td width="160">ns</td>
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
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/SonicOnDemand_Normal</td>
      <td width="180">越小越好</td>
      <td width="160">16048.888710601721</td>
      <td width="160">34204.01005564775</td>
      <td width="240">0.4692</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/RapidjsonSaxOnDemand_Normal</td>
      <td width="180">越小越好</td>
      <td width="160">325659.4186046509</td>
      <td width="160">850724.9817739982</td>
      <td width="240">0.3828</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/SIMDjsonOnDemand_Normal</td>
      <td width="180">越小越好</td>
      <td width="160">52170.023853894905</td>
      <td width="160">78763.00710339384</td>
      <td width="240">0.6624</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="180">越小越好</td>
      <td width="160">9403.920682394275</td>
      <td width="160">18026.093013673944</td>
      <td width="240">0.5217</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/RapidjsonSaxOnDemand_Fronter</td>
      <td width="180">越小越好</td>
      <td width="160">96683.20992522102</td>
      <td width="160">164262.98615998172</td>
      <td width="240">0.5886</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/SIMDjsonOnDemand_Fronter</td>
      <td width="180">越小越好</td>
      <td width="160">227859.69993476867</td>
      <td width="160">342296.5281173593</td>
      <td width="240">0.6657</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/SonicOnDemand_NotFound</td>
      <td width="180">越小越好</td>
      <td width="160">15952.886017682924</td>
      <td width="160">34008.34556857396</td>
      <td width="240">0.4691</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/RapidjsonSaxOnDemand_NotFound</td>
      <td width="180">越小越好</td>
      <td width="160">328488.91553261527</td>
      <td width="160">850913.9659367418</td>
      <td width="240">0.386</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/SIMDjsonOnDemand_NotFound</td>
      <td width="180">越小越好</td>
      <td width="160">52142.32333806925</td>
      <td width="160">78807.68822666245</td>
      <td width="240">0.6616</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">273229.6534267934</td>
      <td width="160">413650.32505910343</td>
      <td width="240">0.6605</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">957589.3991989322</td>
      <td width="160">1911144.153005459</td>
      <td width="240">0.5011</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">1019323.5953420701</td>
      <td width="160">2146443.6196319023</td>
      <td width="240">0.4749</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">369236.99208443175</td>
      <td width="160">728507.0219435784</td>
      <td width="240">0.5068</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">25991595.92592604</td>
      <td width="160">30054944.78260851</td>
      <td width="240">0.8648</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">101259.69771478168</td>
      <td width="160">191061.08986615654</td>
      <td width="240">0.53</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">362316.49767201516</td>
      <td width="160">836174.169653526</td>
      <td width="240">0.4333</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">324533.57904496934</td>
      <td width="160">800443.531428568</td>
      <td width="240">0.4054</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">81486.9635205552</td>
      <td width="160">132753.5384615371</td>
      <td width="240">0.6138</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">9672229.999999907</td>
      <td width="160">11503573.278688593</td>
      <td width="240">0.8408</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">812757.1528588008</td>
      <td width="160">1524254.8583878085</td>
      <td width="240">0.5332</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">4797759.178082215</td>
      <td width="160">13958770.40000016</td>
      <td width="240">0.3437</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">2692740.0384615487</td>
      <td width="160">6585659.2452829685</td>
      <td width="240">0.4089</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">955336.2587904412</td>
      <td width="160">1739431.6120906784</td>
      <td width="240">0.5492</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">75440159.00000004</td>
      <td width="160">86982900.00000004</td>
      <td width="240">0.8673</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">143494627.50000086</td>
      <td width="160">169928782.49999776</td>
      <td width="240">0.8444</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">220256419.99999833</td>
      <td width="160">286950685.0000008</td>
      <td width="240">0.7676</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">182755752.5000003</td>
      <td width="160">308543190.0000018</td>
      <td width="240">0.5923</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">111404358.16666874</td>
      <td width="160">126197840.00000088</td>
      <td width="240">0.8828</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">12630814559.000015</td>
      <td width="160">14541668620.000025</td>
      <td width="240">0.8686</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">453780.4977375587</td>
      <td width="160">688973.3992094558</td>
      <td width="240">0.6586</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">878204.4362744621</td>
      <td width="160">1207166.7125645694</td>
      <td width="240">0.7275</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">857415.1348039083</td>
      <td width="160">1844553.7467019346</td>
      <td width="240">0.4648</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">369682.2681121313</td>
      <td width="160">552817.7179080982</td>
      <td width="240">0.6687</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">74418972.00000085</td>
      <td width="160">87115502.50000499</td>
      <td width="240">0.8543</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">627929.9008115666</td>
      <td width="160">1198926.6324786304</td>
      <td width="240">0.5237</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">4482326.17834405</td>
      <td width="160">13031964.8148145</td>
      <td width="240">0.3439</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">4306039.814814694</td>
      <td width="160">8098033.720930183</td>
      <td width="240">0.5317</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">793039.5647193792</td>
      <td width="160">1298231.8773234414</td>
      <td width="240">0.6109</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">49938996.99999815</td>
      <td width="160">57893922.30769426</td>
      <td width="240">0.8626</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">22332.853364771607</td>
      <td width="160">44865.71730905178</td>
      <td width="240">0.4978</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">98928.13798954069</td>
      <td width="160">223537.9001280313</td>
      <td width="240">0.4426</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">84278.62247353408</td>
      <td width="160">178302.47706421773</td>
      <td width="240">0.4727</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">16905.668869699464</td>
      <td width="160">28866.9002587209</td>
      <td width="240">0.5856</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">2232335.365079413</td>
      <td width="160">2573254.835164794</td>
      <td width="240">0.8675</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">48299622.85714373</td>
      <td width="160">69555158.74999918</td>
      <td width="240">0.6944</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">112125248.00000665</td>
      <td width="160">195917713.33333933</td>
      <td width="240">0.5723</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">111941399.99999683</td>
      <td width="160">201919809.99999258</td>
      <td width="240">0.5544</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">58566850.8333299</td>
      <td width="160">61040556.66666852</td>
      <td width="240">0.9595</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">5736172839.999994</td>
      <td width="160">6689287329.999956</td>
      <td width="240">0.8575</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">607935.2170139293</td>
      <td width="160">1209177.979274654</td>
      <td width="240">0.5028</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">1600371.6113636622</td>
      <td width="160">2440363.240417966</td>
      <td width="240">0.6558</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">2051966.568914891</td>
      <td width="160">5917354.067796392</td>
      <td width="240">0.3468</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">593878.2088285468</td>
      <td width="160">752196.5980498013</td>
      <td width="240">0.7895</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">62818529.91666881</td>
      <td width="160">71797844.00000244</td>
      <td width="240">0.8749</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">2121648.23708214</td>
      <td width="160">4045774.4508670913</td>
      <td width="240">0.5244</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">3044944.130434764</td>
      <td width="160">4146655.7396451114</td>
      <td width="240">0.7343</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">7110193.163265306</td>
      <td width="160">13089401.698113186</td>
      <td width="240">0.5432</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">2141053.944954167</td>
      <td width="160">2858815.5918367524</td>
      <td width="240">0.7489</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">314462544.9999978</td>
      <td width="160">410459205.000052</td>
      <td width="240">0.7661</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Decode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">495.7701261076692</td>
      <td width="160">721.1745638267902</td>
      <td width="240">0.6874</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Decode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">919.5489135272941</td>
      <td width="160">1341.6198725605823</td>
      <td width="240">0.6854</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Decode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">813.1092370588777</td>
      <td width="160">1634.1799044448828</td>
      <td width="240">0.4976</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Decode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">444.05453873712804</td>
      <td width="160">696.9924148475571</td>
      <td width="240">0.6371</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Decode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">69947.80597461876</td>
      <td width="160">88623.18049397743</td>
      <td width="240">0.7893</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">137713.68379446532</td>
      <td width="160">289775.25206612854</td>
      <td width="240">0.4752</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">523526.0687593378</td>
      <td width="160">1258670.1981982097</td>
      <td width="240">0.4159</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">432455.7286773759</td>
      <td width="160">1148419.607201245</td>
      <td width="240">0.3766</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">317780.7242465152</td>
      <td width="160">568033.7703583247</td>
      <td width="240">0.5594</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">11972650.172413658</td>
      <td width="160">18008668.97435928</td>
      <td width="240">0.6648</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">51394.32807407131</td>
      <td width="160">108032.72322798586</td>
      <td width="240">0.4757</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">225891.19009325514</td>
      <td width="160">564960.1860841321</td>
      <td width="240">0.3998</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">151594.21645022256</td>
      <td width="160">420786.32751353784</td>
      <td width="240">0.3603</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">136559.37695311592</td>
      <td width="160">241897.71784233893</td>
      <td width="240">0.5645</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">4974909.500000583</td>
      <td width="160">7568214.065933498</td>
      <td width="240">0.6573</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">506455.03249097115</td>
      <td width="160">925225.8068781752</td>
      <td width="240">0.5474</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">2486190.141844047</td>
      <td width="160">8320894.404762601</td>
      <td width="240">0.2988</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">1154925.2883031042</td>
      <td width="160">2581267.1955718943</td>
      <td width="240">0.4474</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">1283169.5978061603</td>
      <td width="160">2262145.1132687647</td>
      <td width="240">0.5672</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">61622436.363636136</td>
      <td width="160">89687335.00000781</td>
      <td width="240">0.6871</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">76177007.77777575</td>
      <td width="160">129355200.00000906</td>
      <td width="240">0.5889</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">136949600.00000265</td>
      <td width="160">210231700.00000846</td>
      <td width="240">0.6514</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">134575731.9999848</td>
      <td width="160">410980844.9999832</td>
      <td width="240">0.3275</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">120600763.33331914</td>
      <td width="160">217108230.00000802</td>
      <td width="240">0.5555</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">5202643670.000044</td>
      <td width="160">7405751479.999936</td>
      <td width="240">0.7025</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">479348.45099384186</td>
      <td width="160">778470.3218645431</td>
      <td width="240">0.6158</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">794972.8213879718</td>
      <td width="160">1302374.2085660934</td>
      <td width="240">0.6104</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">940431.0872482803</td>
      <td width="160">3110305.4666669373</td>
      <td width="240">0.3024</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">664870.8550186565</td>
      <td width="160">1101511.1811022907</td>
      <td width="240">0.6036</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">27978467.60000084</td>
      <td width="160">38845357.77777703</td>
      <td width="240">0.7203</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">356862.1854304712</td>
      <td width="160">642551.4456722026</td>
      <td width="240">0.5554</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">2374083.355932456</td>
      <td width="160">7534220.7526881145</td>
      <td width="240">0.3151</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">2151006.3384616496</td>
      <td width="160">3987523.028571818</td>
      <td width="240">0.5394</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">2942503.3054393632</td>
      <td width="160">4930424.295775032</td>
      <td width="240">0.5968</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">35216325.999999754</td>
      <td width="160">49839828.571423694</td>
      <td width="240">0.7066</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">12150.746279036994</td>
      <td width="160">25742.233690212663</td>
      <td width="240">0.472</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">54145.034498620174</td>
      <td width="160">144366.2017742926</td>
      <td width="240">0.3751</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">30419.301830194483</td>
      <td width="160">84789.54435287963</td>
      <td width="240">0.3588</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">33372.886947390725</td>
      <td width="160">61080.024604561295</td>
      <td width="240">0.5464</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">1053016.1144578324</td>
      <td width="160">1534855.7675439492</td>
      <td width="240">0.6861</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">26596393.461536888</td>
      <td width="160">58066361.666665986</td>
      <td width="240">0.458</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">59666210.83333242</td>
      <td width="160">139815132.00001246</td>
      <td width="240">0.4268</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">65162729.090905644</td>
      <td width="160">206465946.66663986</td>
      <td width="240">0.3156</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">67880724.5454581</td>
      <td width="160">108688988.33333182</td>
      <td width="240">0.6245</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">2295063030.000051</td>
      <td width="160">3323575669.9999685</td>
      <td width="240">0.6905</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">275680.16548465186</td>
      <td width="160">579018.4987277444</td>
      <td width="240">0.4761</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">591411.6030534247</td>
      <td width="160">1241749.6447601372</td>
      <td width="240">0.4763</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">646968.0424746423</td>
      <td width="160">2108464.93975893</td>
      <td width="240">0.3068</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">520254.710622694</td>
      <td width="160">1024541.2463343702</td>
      <td width="240">0.5078</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">23961944.82758441</td>
      <td width="160">34337650.50000375</td>
      <td width="240">0.6978</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">3776130.5405404754</td>
      <td width="160">4256248.780487711</td>
      <td width="240">0.8872</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">7407965.000000553</td>
      <td width="160">7992264.090909563</td>
      <td width="240">0.9269</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">7237600.515463548</td>
      <td width="160">22184745.31250081</td>
      <td width="240">0.3262</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">3472160.143564006</td>
      <td width="160">4641189.668873929</td>
      <td width="240">0.7481</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">121283118.33333783</td>
      <td width="160">162094747.4999923</td>
      <td width="240">0.7482</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Encode_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">324.7221723045783</td>
      <td width="160">593.4214018408036</td>
      <td width="240">0.5472</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Encode_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">791.0853856745609</td>
      <td width="160">1192.1038453412114</td>
      <td width="240">0.6636</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Encode_YYjson</td>
      <td width="180">越小越好</td>
      <td width="160">683.4312254411434</td>
      <td width="160">2322.690556470292</td>
      <td width="240">0.2942</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Encode_SIMDjson</td>
      <td width="180">越小越好</td>
      <td width="160">495.86343581117734</td>
      <td width="160">989.5754209681909</td>
      <td width="240">0.5011</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Encode_JsonCpp</td>
      <td width="180">越小越好</td>
      <td width="160">34280.972507581</td>
      <td width="160">49012.84193571157</td>
      <td width="240">0.6994</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">46350.10129767184</td>
      <td width="160">62563.003403801355</td>
      <td width="240">0.7409</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">142624.1869502999</td>
      <td width="160">193501.8639380588</td>
      <td width="240">0.7371</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">52157.82378394641</td>
      <td width="160">49984.93005236599</td>
      <td width="240">1.0435</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitterescaped/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">176270.66918002948</td>
      <td width="160">186018.45664282533</td>
      <td width="240">0.9476</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">18318.550699988285</td>
      <td width="160">23244.076789305043</td>
      <td width="240">0.7881</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">52679.653153158804</td>
      <td width="160">73131.68217459705</td>
      <td width="240">0.7203</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">20050.356826304505</td>
      <td width="160">19273.515326461686</td>
      <td width="240">1.0403</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">twitter/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">59671.72746587525</td>
      <td width="160">72447.20364427363</td>
      <td width="240">0.8237</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">115897.85903375647</td>
      <td width="160">144110.03083248096</td>
      <td width="240">0.8042</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">182754.66057441113</td>
      <td width="160">298803.70590733906</td>
      <td width="240">0.6116</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">150149.87569653612</td>
      <td width="160">267772.3156681851</td>
      <td width="240">0.5607</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">poet/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">168477.25391094573</td>
      <td width="160">276859.2400155057</td>
      <td width="240">0.6085</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">58199956.66666955</td>
      <td width="160">53709667.69230388</td>
      <td width="240">1.0836</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">810134950.0000197</td>
      <td width="160">1443872409.999926</td>
      <td width="240">0.5611</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">55411527.49999394</td>
      <td width="160">45553698.00000335</td>
      <td width="240">1.2164</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">otfcc/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">1094134670.0000167</td>
      <td width="160">1096783200.0000043</td>
      <td width="240">0.9976</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">173269.6587030882</td>
      <td width="160">207473.21523474238</td>
      <td width="240">0.8351</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">234283.15947845267</td>
      <td width="160">442888.29022075236</td>
      <td width="240">0.529</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">161096.76686555104</td>
      <td width="160">177831.7947421832</td>
      <td width="240">0.9059</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">lottie/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">193195.1723194705</td>
      <td width="160">276436.10250296135</td>
      <td width="240">0.6989</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">60155.53617460346</td>
      <td width="160">80643.88908066109</td>
      <td width="240">0.7459</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">1328744.9666665907</td>
      <td width="160">2164680.1851851633</td>
      <td width="240">0.6138</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">92455.71582490664</td>
      <td width="160">137338.91590274434</td>
      <td width="240">0.6732</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">gsoc-2018/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">1516164.6753248142</td>
      <td width="160">2093277.8851962003</td>
      <td width="240">0.7243</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">4319.330293339923</td>
      <td width="160">5547.8865169439005</td>
      <td width="240">0.7786</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">9082.17097848171</td>
      <td width="160">14991.360507635123</td>
      <td width="240">0.6058</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">4591.930276793411</td>
      <td width="160">4587.087580515684</td>
      <td width="240">1.0011</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">github_events/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">11112.328330714907</td>
      <td width="160">11262.04813849506</td>
      <td width="240">0.9867</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">13389612.181818353</td>
      <td width="160">15614733.863639105</td>
      <td width="240">0.8575</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">23621324.333331965</td>
      <td width="160">34258723.49999963</td>
      <td width="240">0.6895</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">13280090.75471845</td>
      <td width="160">13015029.629627861</td>
      <td width="240">1.0204</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">fgo/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">24254816.20689582</td>
      <td width="160">24181491.37931072</td>
      <td width="240">1.003</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">132802.56749209878</td>
      <td width="160">174141.99950319788</td>
      <td width="240">0.7626</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">214257.926717548</td>
      <td width="160">338811.11813313566</td>
      <td width="240">0.6324</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">134935.81065318553</td>
      <td width="160">155391.9603474979</td>
      <td width="240">0.8684</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">citm_catalog/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">202765.4106419931</td>
      <td width="160">202372.9762245391</td>
      <td width="240">1.0019</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">607605.9513830013</td>
      <td width="160">601220.6952790476</td>
      <td width="240">1.0106</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">488506.362369374</td>
      <td width="160">520333.5267856413</td>
      <td width="240">0.9388</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">566472.8003246373</td>
      <td width="160">485911.6620499161</td>
      <td width="240">1.1658</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">canada/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">406596.97850085015</td>
      <td width="160">297612.0654483389</td>
      <td width="240">1.3662</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Stat_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">111.4258827426681</td>
      <td width="160">139.2232624508445</td>
      <td width="240">0.8003</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Find_SonicDyn</td>
      <td width="180">越小越好</td>
      <td width="160">166.7971845327386</td>
      <td width="160">267.67018588448815</td>
      <td width="240">0.6231</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Stat_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">128.21111475764934</td>
      <td width="160">117.13673603101704</td>
      <td width="240">1.0945</td>
    </tr>
    <tr>
      <td width="160">sonic</td>
      <td width="140">1.0.2</td>
      <td width="340">book/Find_Rapidjson</td>
      <td width="180">越小越好</td>
      <td width="160">129.95218700129337</td>
      <td width="160">183.33140608304282</td>
      <td width="240">0.7088</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
