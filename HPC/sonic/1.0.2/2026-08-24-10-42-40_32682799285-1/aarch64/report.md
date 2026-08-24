# sonic 1.0.2 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`32682799285-1`

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
      <td width="1200">1.0.2</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">1.0.2</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-24T02:22:35Z</td>
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
      <td width="1200">2026-08-24T02:20:50Z</td>
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
      <td width="1200">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 128008 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 124629 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127300 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 128423 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
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
      <td width="500">twitter/SonicOnDemand_Normal</td>
      <td width="280">34204.01005564775</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/RapidjsonSaxOnDemand_Normal</td>
      <td width="280">850724.9817739982</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SIMDjsonOnDemand_Normal</td>
      <td width="280">78763.00710339384</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/SonicOnDemand_Fronter</td>
      <td width="280">18026.093013673944</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/RapidjsonSaxOnDemand_Fronter</td>
      <td width="280">164262.98615998172</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/SIMDjsonOnDemand_Fronter</td>
      <td width="280">342296.5281173593</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SonicOnDemand_NotFound</td>
      <td width="280">34008.34556857396</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/RapidjsonSaxOnDemand_NotFound</td>
      <td width="280">850913.9659367418</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/SIMDjsonOnDemand_NotFound</td>
      <td width="280">78807.68822666245</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_SonicDyn</td>
      <td width="280">413650.32505910343</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_Rapidjson</td>
      <td width="280">1911144.153005459</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_YYjson</td>
      <td width="280">2146443.6196319023</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_SIMDjson</td>
      <td width="280">728507.0219435784</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Decode_JsonCpp</td>
      <td width="280">30054944.78260851</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_SonicDyn</td>
      <td width="280">191061.08986615654</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_Rapidjson</td>
      <td width="280">836174.169653526</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_YYjson</td>
      <td width="280">800443.531428568</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_SIMDjson</td>
      <td width="280">132753.5384615371</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Decode_JsonCpp</td>
      <td width="280">11503573.278688593</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_SonicDyn</td>
      <td width="280">1524254.8583878085</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_Rapidjson</td>
      <td width="280">13958770.40000016</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_YYjson</td>
      <td width="280">6585659.2452829685</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_SIMDjson</td>
      <td width="280">1739431.6120906784</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Decode_JsonCpp</td>
      <td width="280">86982900.00000004</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_SonicDyn</td>
      <td width="280">169928782.49999776</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_Rapidjson</td>
      <td width="280">286950685.0000008</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_YYjson</td>
      <td width="280">308543190.0000018</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_SIMDjson</td>
      <td width="280">126197840.00000088</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Decode_JsonCpp</td>
      <td width="280">14541668620.000025</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_SonicDyn</td>
      <td width="280">688973.3992094558</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_Rapidjson</td>
      <td width="280">1207166.7125645694</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_YYjson</td>
      <td width="280">1844553.7467019346</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_SIMDjson</td>
      <td width="280">552817.7179080982</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Decode_JsonCpp</td>
      <td width="280">87115502.50000499</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_SonicDyn</td>
      <td width="280">1198926.6324786304</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_Rapidjson</td>
      <td width="280">13031964.8148145</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_YYjson</td>
      <td width="280">8098033.720930183</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_SIMDjson</td>
      <td width="280">1298231.8773234414</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Decode_JsonCpp</td>
      <td width="280">57893922.30769426</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_SonicDyn</td>
      <td width="280">44865.71730905178</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_Rapidjson</td>
      <td width="280">223537.9001280313</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_YYjson</td>
      <td width="280">178302.47706421773</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_SIMDjson</td>
      <td width="280">28866.9002587209</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Decode_JsonCpp</td>
      <td width="280">2573254.835164794</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_SonicDyn</td>
      <td width="280">69555158.74999918</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_Rapidjson</td>
      <td width="280">195917713.33333933</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_YYjson</td>
      <td width="280">201919809.99999258</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_SIMDjson</td>
      <td width="280">61040556.66666852</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Decode_JsonCpp</td>
      <td width="280">6689287329.999956</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_SonicDyn</td>
      <td width="280">1209177.979274654</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_Rapidjson</td>
      <td width="280">2440363.240417966</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_YYjson</td>
      <td width="280">5917354.067796392</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_SIMDjson</td>
      <td width="280">752196.5980498013</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Decode_JsonCpp</td>
      <td width="280">71797844.00000244</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_SonicDyn</td>
      <td width="280">4045774.4508670913</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_Rapidjson</td>
      <td width="280">4146655.7396451114</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_YYjson</td>
      <td width="280">13089401.698113186</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_SIMDjson</td>
      <td width="280">2858815.5918367524</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Decode_JsonCpp</td>
      <td width="280">410459205.000052</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_SonicDyn</td>
      <td width="280">721.1745638267902</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_Rapidjson</td>
      <td width="280">1341.6198725605823</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_YYjson</td>
      <td width="280">1634.1799044448828</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_SIMDjson</td>
      <td width="280">696.9924148475571</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Decode_JsonCpp</td>
      <td width="280">88623.18049397743</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_SonicDyn</td>
      <td width="280">289775.25206612854</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_Rapidjson</td>
      <td width="280">1258670.1981982097</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_YYjson</td>
      <td width="280">1148419.607201245</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_SIMDjson</td>
      <td width="280">568033.7703583247</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Encode_JsonCpp</td>
      <td width="280">18008668.97435928</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_SonicDyn</td>
      <td width="280">108032.72322798586</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_Rapidjson</td>
      <td width="280">564960.1860841321</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_YYjson</td>
      <td width="280">420786.32751353784</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_SIMDjson</td>
      <td width="280">241897.71784233893</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Encode_JsonCpp</td>
      <td width="280">7568214.065933498</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_SonicDyn</td>
      <td width="280">925225.8068781752</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_Rapidjson</td>
      <td width="280">8320894.404762601</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_YYjson</td>
      <td width="280">2581267.1955718943</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_SIMDjson</td>
      <td width="280">2262145.1132687647</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Encode_JsonCpp</td>
      <td width="280">89687335.00000781</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_SonicDyn</td>
      <td width="280">129355200.00000906</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_Rapidjson</td>
      <td width="280">210231700.00000846</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_YYjson</td>
      <td width="280">410980844.9999832</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_SIMDjson</td>
      <td width="280">217108230.00000802</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Encode_JsonCpp</td>
      <td width="280">7405751479.999936</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_SonicDyn</td>
      <td width="280">778470.3218645431</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_Rapidjson</td>
      <td width="280">1302374.2085660934</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_YYjson</td>
      <td width="280">3110305.4666669373</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_SIMDjson</td>
      <td width="280">1101511.1811022907</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Encode_JsonCpp</td>
      <td width="280">38845357.77777703</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_SonicDyn</td>
      <td width="280">642551.4456722026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_Rapidjson</td>
      <td width="280">7534220.7526881145</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_YYjson</td>
      <td width="280">3987523.028571818</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_SIMDjson</td>
      <td width="280">4930424.295775032</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Encode_JsonCpp</td>
      <td width="280">49839828.571423694</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_SonicDyn</td>
      <td width="280">25742.233690212663</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_Rapidjson</td>
      <td width="280">144366.2017742926</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_YYjson</td>
      <td width="280">84789.54435287963</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_SIMDjson</td>
      <td width="280">61080.024604561295</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Encode_JsonCpp</td>
      <td width="280">1534855.7675439492</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_SonicDyn</td>
      <td width="280">58066361.666665986</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_Rapidjson</td>
      <td width="280">139815132.00001246</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_YYjson</td>
      <td width="280">206465946.66663986</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_SIMDjson</td>
      <td width="280">108688988.33333182</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Encode_JsonCpp</td>
      <td width="280">3323575669.9999685</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_SonicDyn</td>
      <td width="280">579018.4987277444</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_Rapidjson</td>
      <td width="280">1241749.6447601372</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_YYjson</td>
      <td width="280">2108464.93975893</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_SIMDjson</td>
      <td width="280">1024541.2463343702</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Encode_JsonCpp</td>
      <td width="280">34337650.50000375</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_SonicDyn</td>
      <td width="280">4256248.780487711</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_Rapidjson</td>
      <td width="280">7992264.090909563</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_YYjson</td>
      <td width="280">22184745.31250081</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_SIMDjson</td>
      <td width="280">4641189.668873929</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Encode_JsonCpp</td>
      <td width="280">162094747.4999923</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_SonicDyn</td>
      <td width="280">593.4214018408036</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_Rapidjson</td>
      <td width="280">1192.1038453412114</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_YYjson</td>
      <td width="280">2322.690556470292</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_SIMDjson</td>
      <td width="280">989.5754209681909</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Encode_JsonCpp</td>
      <td width="280">49012.84193571157</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Stat_SonicDyn</td>
      <td width="280">62563.003403801355</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Find_SonicDyn</td>
      <td width="280">193501.8639380588</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Stat_Rapidjson</td>
      <td width="280">49984.93005236599</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitterescaped/Find_Rapidjson</td>
      <td width="280">186018.45664282533</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Stat_SonicDyn</td>
      <td width="280">23244.076789305043</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Find_SonicDyn</td>
      <td width="280">73131.68217459705</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Stat_Rapidjson</td>
      <td width="280">19273.515326461686</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">twitter/Find_Rapidjson</td>
      <td width="280">72447.20364427363</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Stat_SonicDyn</td>
      <td width="280">144110.03083248096</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Find_SonicDyn</td>
      <td width="280">298803.70590733906</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Stat_Rapidjson</td>
      <td width="280">267772.3156681851</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">poet/Find_Rapidjson</td>
      <td width="280">276859.2400155057</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Stat_SonicDyn</td>
      <td width="280">53709667.69230388</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Find_SonicDyn</td>
      <td width="280">1443872409.999926</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Stat_Rapidjson</td>
      <td width="280">45553698.00000335</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">otfcc/Find_Rapidjson</td>
      <td width="280">1096783200.0000043</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Stat_SonicDyn</td>
      <td width="280">207473.21523474238</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Find_SonicDyn</td>
      <td width="280">442888.29022075236</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Stat_Rapidjson</td>
      <td width="280">177831.7947421832</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">lottie/Find_Rapidjson</td>
      <td width="280">276436.10250296135</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Stat_SonicDyn</td>
      <td width="280">80643.88908066109</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Find_SonicDyn</td>
      <td width="280">2164680.1851851633</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Stat_Rapidjson</td>
      <td width="280">137338.91590274434</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gsoc-2018/Find_Rapidjson</td>
      <td width="280">2093277.8851962003</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Stat_SonicDyn</td>
      <td width="280">5547.8865169439005</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Find_SonicDyn</td>
      <td width="280">14991.360507635123</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Stat_Rapidjson</td>
      <td width="280">4587.087580515684</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github_events/Find_Rapidjson</td>
      <td width="280">11262.04813849506</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Stat_SonicDyn</td>
      <td width="280">15614733.863639105</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Find_SonicDyn</td>
      <td width="280">34258723.49999963</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Stat_Rapidjson</td>
      <td width="280">13015029.629627861</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">fgo/Find_Rapidjson</td>
      <td width="280">24181491.37931072</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Stat_SonicDyn</td>
      <td width="280">174141.99950319788</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Find_SonicDyn</td>
      <td width="280">338811.11813313566</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Stat_Rapidjson</td>
      <td width="280">155391.9603474979</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">citm_catalog/Find_Rapidjson</td>
      <td width="280">202372.9762245391</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Stat_SonicDyn</td>
      <td width="280">601220.6952790476</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Find_SonicDyn</td>
      <td width="280">520333.5267856413</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Stat_Rapidjson</td>
      <td width="280">485911.6620499161</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">canada/Find_Rapidjson</td>
      <td width="280">297612.0654483389</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Stat_SonicDyn</td>
      <td width="280">139.2232624508445</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Find_SonicDyn</td>
      <td width="280">267.67018588448815</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Stat_Rapidjson</td>
      <td width="280">117.13673603101704</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">book/Find_Rapidjson</td>
      <td width="280">183.33140608304282</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
