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
      <td width="180">AI</td>
      <td width="220">faiss</td>
      <td width="160">1.14.3</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">AI</td>
      <td width="220">faiss</td>
      <td width="160">1.14.3</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### faiss 1.14.3

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
      <td width="600">1.14.3</td>
      <td width="600">1.14.3</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.14.3</td>
      <td width="600">1.14.3</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-08-19T03:35:39Z</td>
      <td width="600">2026-08-19T03:37:07Z</td>
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
      <td width="600">2026-08-19T03:32:28Z</td>
      <td width="600">2026-08-19T03:32:38Z</td>
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
      <td width="600">available: 1 nodes (0)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>node 0 size: 30886 MB<br>node 0 free: 17049 MB<br>node distances:<br>node   0 <br>  0:  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 128039 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 125070 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127324 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 128464 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
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
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/qps</td>
      <td width="200">10909.72319</td>
      <td width="160">queries/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/latency_per_query_us</td>
      <td width="200">91.661354</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/recall_at_k</td>
      <td width="200">1.0</td>
      <td width="160">ratio</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/build_time_s</td>
      <td width="200">0.009045</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexIVFFlat/qps</td>
      <td width="200">158006.840405</td>
      <td width="160">queries/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexIVFFlat/latency_per_query_us</td>
      <td width="200">6.32884</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexIVFFlat/recall_at_k</td>
      <td width="200">0.0576</td>
      <td width="160">ratio</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexIVFFlat/build_time_s</td>
      <td width="200">0.111963</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexHNSWFlat/qps</td>
      <td width="200">91357.063485</td>
      <td width="160">queries/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexHNSWFlat/latency_per_query_us</td>
      <td width="200">10.946061</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexHNSWFlat/recall_at_k</td>
      <td width="200">0.2004</td>
      <td width="160">ratio</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexHNSWFlat/build_time_s</td>
      <td width="200">1.96876</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">Kmeans/train/elapsed_s</td>
      <td width="200">0.139971</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/add/vectors_per_second</td>
      <td width="200">10660263.781363</td>
      <td width="160">vectors/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/search/single/latency_us</td>
      <td width="200">1150.150535</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/search/batch/queries_per_second</td>
      <td width="200">11657.297731</td>
      <td width="160">queries/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/range_search/queries_per_second</td>
      <td width="200">4254.763124</td>
      <td width="160">queries/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexPQ/add/vectors_per_second</td>
      <td width="200">694103.384354</td>
      <td width="160">vectors/s</td>
      <td width="260">越大越好</td>
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
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/qps</td>
      <td width="200">3127.713487</td>
      <td width="160">queries/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/latency_per_query_us</td>
      <td width="200">319.72238</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/recall_at_k</td>
      <td width="200">1.0</td>
      <td width="160">ratio</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/build_time_s</td>
      <td width="200">0.003807</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexIVFFlat/qps</td>
      <td width="200">88602.525693</td>
      <td width="160">queries/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexIVFFlat/latency_per_query_us</td>
      <td width="200">11.28636</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexIVFFlat/recall_at_k</td>
      <td width="200">0.0576</td>
      <td width="160">ratio</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexIVFFlat/build_time_s</td>
      <td width="200">0.21439</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexHNSWFlat/qps</td>
      <td width="200">245606.704273</td>
      <td width="160">queries/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexHNSWFlat/latency_per_query_us</td>
      <td width="200">4.07155</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexHNSWFlat/recall_at_k</td>
      <td width="200">0.1934</td>
      <td width="160">ratio</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexHNSWFlat/build_time_s</td>
      <td width="200">0.254811</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">Kmeans/train/elapsed_s</td>
      <td width="200">0.318325</td>
      <td width="160">s</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/add/vectors_per_second</td>
      <td width="200">25227425.48051</td>
      <td width="160">vectors/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/search/single/latency_us</td>
      <td width="200">2015.78976</td>
      <td width="160">us</td>
      <td width="260">越小越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/search/batch/queries_per_second</td>
      <td width="200">2784.43955</td>
      <td width="160">queries/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexFlatL2/range_search/queries_per_second</td>
      <td width="200">8154.631398</td>
      <td width="160">queries/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">faiss</td>
      <td width="160">1.14.3</td>
      <td width="420">IndexPQ/add/vectors_per_second</td>
      <td width="200">1539862.101018</td>
      <td width="160">vectors/s</td>
      <td width="260">越大越好</td>
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
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexFlatL2/qps</td>
      <td width="180">越大越好</td>
      <td width="160">10909.72319</td>
      <td width="160">3127.713487</td>
      <td width="240">0.2867</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexFlatL2/latency_per_query_us</td>
      <td width="180">越小越好</td>
      <td width="160">91.661354</td>
      <td width="160">319.72238</td>
      <td width="240">0.2867</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexFlatL2/recall_at_k</td>
      <td width="180">越大越好</td>
      <td width="160">1.0</td>
      <td width="160">1.0</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexFlatL2/build_time_s</td>
      <td width="180">越小越好</td>
      <td width="160">0.009045</td>
      <td width="160">0.003807</td>
      <td width="240">2.3759</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexIVFFlat/qps</td>
      <td width="180">越大越好</td>
      <td width="160">158006.840405</td>
      <td width="160">88602.525693</td>
      <td width="240">0.5608</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexIVFFlat/latency_per_query_us</td>
      <td width="180">越小越好</td>
      <td width="160">6.32884</td>
      <td width="160">11.28636</td>
      <td width="240">0.5608</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexIVFFlat/recall_at_k</td>
      <td width="180">越大越好</td>
      <td width="160">0.0576</td>
      <td width="160">0.0576</td>
      <td width="240">1.0</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexIVFFlat/build_time_s</td>
      <td width="180">越小越好</td>
      <td width="160">0.111963</td>
      <td width="160">0.21439</td>
      <td width="240">0.5222</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexHNSWFlat/qps</td>
      <td width="180">越大越好</td>
      <td width="160">91357.063485</td>
      <td width="160">245606.704273</td>
      <td width="240">2.6884</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexHNSWFlat/latency_per_query_us</td>
      <td width="180">越小越好</td>
      <td width="160">10.946061</td>
      <td width="160">4.07155</td>
      <td width="240">2.6884</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexHNSWFlat/recall_at_k</td>
      <td width="180">越大越好</td>
      <td width="160">0.2004</td>
      <td width="160">0.1934</td>
      <td width="240">0.9651</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexHNSWFlat/build_time_s</td>
      <td width="180">越小越好</td>
      <td width="160">1.96876</td>
      <td width="160">0.254811</td>
      <td width="240">7.7264</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">Kmeans/train/elapsed_s</td>
      <td width="180">越小越好</td>
      <td width="160">0.139971</td>
      <td width="160">0.318325</td>
      <td width="240">0.4397</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexFlatL2/add/vectors_per_second</td>
      <td width="180">越大越好</td>
      <td width="160">10660263.781363</td>
      <td width="160">25227425.48051</td>
      <td width="240">2.3665</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexFlatL2/search/single/latency_us</td>
      <td width="180">越小越好</td>
      <td width="160">1150.150535</td>
      <td width="160">2015.78976</td>
      <td width="240">0.5706</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexFlatL2/search/batch/queries_per_second</td>
      <td width="180">越大越好</td>
      <td width="160">11657.297731</td>
      <td width="160">2784.43955</td>
      <td width="240">0.2389</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexFlatL2/range_search/queries_per_second</td>
      <td width="180">越大越好</td>
      <td width="160">4254.763124</td>
      <td width="160">8154.631398</td>
      <td width="240">1.9166</td>
    </tr>
    <tr>
      <td width="160">faiss</td>
      <td width="140">1.14.3</td>
      <td width="340">IndexPQ/add/vectors_per_second</td>
      <td width="180">越大越好</td>
      <td width="160">694103.384354</td>
      <td width="160">1539862.101018</td>
      <td width="240">2.2185</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
