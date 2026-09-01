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
      <td width="180">Toolchain</td>
      <td width="220">golang</td>
      <td width="160">1.27.0</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">Toolchain</td>
      <td width="220">golang</td>
      <td width="160">1.27.0</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### golang 1.27.0

#### 构建信息

<table width="1380">
  <thead>
    <tr>
      <th width="180">项目</th>
      <th width="600">x86_64</th>
      <th width="600">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">请求软件版本</td>
      <td width="600">1.27.0</td>
      <td width="600">1.27.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.27.0</td>
      <td width="600">1.27.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-09-01T08:56:11Z</td>
      <td width="600">2026-09-01T08:54:28Z</td>
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
      <th width="600">x86_64</th>
      <th width="600">aarch64</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="180">采集时间</td>
      <td width="600">2026-09-01T08:56:06Z</td>
      <td width="600">2026-09-01T08:54:24Z</td>
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
      <td width="600">6.6.0-159.4.10.164.oe2403sp4.x86_64</td>
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
      <td width="600">N/A</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 128209 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 127412 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127166 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 127404 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
    </tr>
  </tbody>
</table>

#### 测试工具

<table width="1380">
  <thead>
    <tr>
      <th width="500">工具</th>
      <th width="880">版本</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="500">bent</td>
      <td width="880">latest</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### golang 1.27.0

##### git.sr.ht/~nelsam/gxui/interval

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
      <td width="500">git.sr.ht/~nelsam/gxui/interval :: BenchmarkGeneral-16 :: ns/op</td>
      <td width="280">202.8</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/IBM/sarama

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
      <td width="500">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-16 :: B/op</td>
      <td width="280">9749.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-16 :: allocs/op</td>
      <td width="280">4.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-16 :: ns/op</td>
      <td width="280">355807.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-16 :: B/op</td>
      <td width="280">16.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-16 :: ns/op</td>
      <td width="280">53.98</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Masterminds/semver/v3

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
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-16 :: ns/op</td>
      <td width="280">26.65</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-16 :: B/op</td>
      <td width="280">128.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-16 :: ns/op</td>
      <td width="280">91.43</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-16 :: B/op</td>
      <td width="280">189.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-16 :: allocs/op</td>
      <td width="280">7.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-16 :: ns/op</td>
      <td width="280">311.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/augmentedtree

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
      <td width="500">github.com/Workiva/go-datastructures/augmentedtree :: BenchmarkAddItems-16 :: ns/op</td>
      <td width="280">120551.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/bitarray

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
      <td width="500">github.com/Workiva/go-datastructures/bitarray :: BenchmarkCompressedIntersects-16 :: ns/op</td>
      <td width="280">29.92</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/btree/palm

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
      <td width="500">github.com/Workiva/go-datastructures/btree/palm :: BenchmarkBulkGet-16 :: ns/op</td>
      <td width="280">509602.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/queue

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
      <td width="500">github.com/Workiva/go-datastructures/queue :: BenchmarkPriorityQueue-16 :: ns/op</td>
      <td width="280">369.9</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/rangetree

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
      <td width="500">github.com/Workiva/go-datastructures/rangetree :: BenchmarkApply-16 :: ns/op</td>
      <td width="280">11043.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Workiva/go-datastructures/rangetree :: BenchmarkImmutableInsertSecondDimension-16 :: ns/op</td>
      <td width="280">12788815.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/rangetree/skiplist

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
      <td width="500">github.com/Workiva/go-datastructures/rangetree/skiplist :: BenchmarkMultiDimensionInsertAtZeroDimension-16 :: ns/op</td>
      <td width="280">939633.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/rtree/hilbert

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
      <td width="500">github.com/Workiva/go-datastructures/rtree/hilbert :: BenchmarkBulkUpdatePoints-16 :: ns/op</td>
      <td width="280">203245.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/set

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
      <td width="500">github.com/Workiva/go-datastructures/set :: BenchmarkClear-16 :: ns/op</td>
      <td width="280">27.71</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Workiva/go-datastructures/set :: BenchmarkExists-16 :: ns/op</td>
      <td width="280">14.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/tree/avl

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
      <td width="500">github.com/Workiva/go-datastructures/tree/avl :: BenchmarkImmutableInsert-16 :: ns/op</td>
      <td width="280">617.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/trie/yfast

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
      <td width="500">github.com/Workiva/go-datastructures/trie/yfast :: BenchmarkIterator-16 :: ns/op</td>
      <td width="280">2011.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/benhoyt/goawk/interp

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
      <td width="500">github.com/benhoyt/goawk/interp :: BenchmarkBuiltinGsubAmpersand-16 :: ns/op</td>
      <td width="280">8959.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/benhoyt/goawk/interp :: BenchmarkNativeFunc-16 :: ns/op</td>
      <td width="280">4538.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/benhoyt/goawk/interp :: BenchmarkRecursiveFunc-16 :: ns/op</td>
      <td width="280">6527.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/benhoyt/goawk/interp :: BenchmarkRepeatNew-16 :: ns/op</td>
      <td width="280">65.45</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/benhoyt/goawk/interp :: BenchmarkSimpleBuiltins-16 :: ns/op</td>
      <td width="280">455.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/bits-and-blooms/bitset

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
      <td width="500">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-16 :: ns/op</td>
      <td width="280">17.55</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/cespare/xxhash/v2

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
      <td width="500">github.com/cespare/xxhash/v2 :: BenchmarkDigestBytes/100B-16 :: MB/s</td>
      <td width="280">5125.31</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/cespare/xxhash/v2 :: BenchmarkDigestBytes/100B-16 :: ns/op</td>
      <td width="280">19.51</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/dustin/go-broadcast

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
      <td width="500">github.com/dustin/go-broadcast :: BenchmarkDirectSend-16 :: ns/op</td>
      <td width="280">224.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/dustin/go-broadcast :: BenchmarkParallelBrodcast-16 :: ns/op</td>
      <td width="280">357.7</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/dustin/go-humanize

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
      <td width="500">github.com/dustin/go-humanize :: BenchmarkBigCommas-16 :: ns/op</td>
      <td width="280">255.6</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/dustin/go-humanize :: BenchmarkCommaf-16 :: ns/op</td>
      <td width="280">151.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/dustin/go-humanize :: BenchmarkParseBytes-16 :: ns/op</td>
      <td width="280">59.06</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/dustin/go-humanize :: BenchmarkParseSI-16 :: ns/op</td>
      <td width="280">258.4</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/ericlagergren/decimal_benchmarks

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
      <td width="500">github.com/ericlagergren/decimal_benchmarks :: BenchmarkMandelbrot_decimal_GDA_9-16 :: ns/op</td>
      <td width="280">1477382819.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=apmckinlay/prec=19-16 :: ns/op</td>
      <td width="280">1405.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=cockroachdb/apd/prec=100-16 :: ns/op</td>
      <td width="280">3705054.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=go-inf/prec=100-16 :: ns/op</td>
      <td width="280">54775.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/ethereum/go-ethereum/consensus/ethash

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
      <td width="500">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-16 :: B/op</td>
      <td width="280">64.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-16 :: ns/op</td>
      <td width="280">49.49</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/ethereum/go-ethereum/crypto/ecies

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
      <td width="500">github.com/ethereum/go-ethereum/crypto/ecies :: BenchmarkGenSharedKeyP256-16 :: ns/op</td>
      <td width="280">52464.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/ethereum/go-ethereum/trie

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
      <td width="500">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-16 :: B/op</td>
      <td width="280">109.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-16 :: ns/op</td>
      <td width="280">76.91</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/ethereum/go-ethereum/whisper/whisperv6

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
      <td width="500">github.com/ethereum/go-ethereum/whisper/whisperv6 :: BenchmarkDecryptionAsymInvalid-16 :: ns/op</td>
      <td width="280">115217.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ethereum/go-ethereum/whisper/whisperv6 :: BenchmarkDecryptionSymInvalid-16 :: ns/op</td>
      <td width="280">52.61</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/flanglet/kanzi-go/v2/benchmark

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
      <td width="500">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkANS0-16 :: ns/op</td>
      <td width="280">1428786.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkBWTSmallBlock-16 :: ns/op</td>
      <td width="280">26849281.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkCM-16 :: ns/op</td>
      <td width="280">32577939.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkHuffman-16 :: ns/op</td>
      <td width="280">1304879.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/gohugoio/hugo/helpers

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
      <td width="500">github.com/gohugoio/hugo/helpers :: BenchmarkAbsURL/absurl-16 :: ns/op</td>
      <td width="280">3.838</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/gohugoio/hugo/helpers :: BenchmarkRelURL-16 :: ns/op</td>
      <td width="280">203.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/gohugoio/hugo/hugolib

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
      <td width="500">github.com/gohugoio/hugo/hugolib :: BenchmarkCreateShortcodePlaceholders-16 :: ns/op</td>
      <td width="280">39.27</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/google/uuid

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
      <td width="500">github.com/google/uuid :: BenchmarkNew-16 :: ns/op</td>
      <td width="280">644.6</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/google/uuid :: BenchmarkUUID_MarshalJSON-16 :: ns/op</td>
      <td width="280">175.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/google/uuid :: BenchmarkUUID_UnmarshalJSON-16 :: ns/op</td>
      <td width="280">246.1</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/minio/minio/cmd

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
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-16 :: MB/s</td>
      <td width="280">2901.32</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-16 :: ns/op</td>
      <td width="280">32.4</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-16 :: MB/s</td>
      <td width="280">5074.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-16 :: ns/op</td>
      <td width="280">89.66</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-16 :: MB/s</td>
      <td width="280">710.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-16 :: ns/op</td>
      <td width="280">323.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-16 :: MB/s</td>
      <td width="280">726.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-16 :: ns/op</td>
      <td width="280">625.9</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-16 :: MB/s</td>
      <td width="280">1702.47</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-16 :: ns/op</td>
      <td width="280">33.48</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-16 :: B/op</td>
      <td width="280">208.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-16 :: ns/op</td>
      <td width="280">65.03</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-16 :: MB/s</td>
      <td width="280">1262.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-16 :: ns/op</td>
      <td width="280">182.1</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-16 :: MB/s</td>
      <td width="280">1509.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-16 :: ns/op</td>
      <td width="280">301.4</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-16 :: MB/s</td>
      <td width="280">1997.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-16 :: ns/op</td>
      <td width="280">28.04</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/rcrowley/go-metrics

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
      <td width="500">github.com/rcrowley/go-metrics :: BenchmarkHistogram-16 :: ns/op</td>
      <td width="280">14.05</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/rcrowley/go-metrics :: BenchmarkTimer-16 :: ns/op</td>
      <td width="280">194.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/tetratelabs/wazero/internal/integration_test/bench

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
      <td width="500">github.com/tetratelabs/wazero/internal/integration_test/bench :: BenchmarkCompilation/without_extern_cache-16 :: ns/op</td>
      <td width="280">10054583.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/uber-go/tally/v4

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
      <td width="500">github.com/uber-go/tally/v4 :: BenchmarkScopeTaggedCachedSubscopes-16 :: ns/op</td>
      <td width="280">490.7</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/uber-go/tally/v4 :: BenchmarkTimerReport-16 :: ns/op</td>
      <td width="280">73.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gitlab.com/golang-commonmark/markdown

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
      <td width="500">gitlab.com/golang-commonmark/markdown :: BenchmarkRenderSpecNoHTML-16 :: ns/op</td>
      <td width="280">3815180.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### go.uber.org/thriftrw/gen

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
      <td width="500">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/ContainersOfContainers/Decode-16 :: ns/op</td>
      <td width="280">30250.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/ContainersOfContainers/Encode-16 :: ns/op</td>
      <td width="280">13258.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/PrimitiveOptionalStruct/Streaming_Decode-16 :: ns/op</td>
      <td width="280">560.7</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### go.uber.org/zap/zapcore

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
      <td width="500">go.uber.org/zap/zapcore :: BenchmarkJSONLogMarshalerFunc-16 :: ns/op</td>
      <td width="280">303.6</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gonum.org/v1/gonum/graph/community

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
      <td width="500">gonum.org/v1/gonum/graph/community :: BenchmarkNewDirectedLayers/graphSize=10,numGraphs=1-16 :: ns/op</td>
      <td width="280">691.4</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/graph/community :: BenchmarkNewDirectedLayers/graphSize=1000,numGraphs=1-16 :: ns/op</td>
      <td width="280">79438.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/graph/community :: BenchmarkNewUndirectedLayers/graphSize=1000,numGraphs=10-16 :: ns/op</td>
      <td width="280">934283.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gonum.org/v1/gonum/graph/topo

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
      <td width="500">gonum.org/v1/gonum/graph/topo :: BenchmarkSortStabilizedPath_100000-16 :: ns/op</td>
      <td width="280">78026452.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gonum.org/v1/gonum/graph/traverse

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
      <td width="500">gonum.org/v1/gonum/graph/traverse :: BenchmarkWalkAllDepthFirstGnp_100_half-16 :: ns/op</td>
      <td width="280">244697.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gonum.org/v1/gonum/lapack/gonum

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
      <td width="500">gonum.org/v1/gonum/lapack/gonum :: BenchmarkDgeev/Circulant5-16 :: ns/op</td>
      <td width="280">6602.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/lapack/gonum :: BenchmarkDlantb/FrobeniusLowerNonUnitN=10000K=2-16 :: ns/op</td>
      <td width="280">97420.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gonum.org/v1/gonum/mat

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
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkAddScaledVec10Inc1-16 :: ns/op</td>
      <td width="280">128.1</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkCholeskyFactorize/n=10-16 :: ns/op</td>
      <td width="280">2433.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkCholeskyInverseTo/n=100-16 :: ns/op</td>
      <td width="280">196680.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkMarshalToVecDense10-16 :: ns/op</td>
      <td width="280">290.3</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkPool100by100Uncleared-16 :: ns/op</td>
      <td width="280">14.39</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkTriMulDiag/BenchmarkTriMulDiag100-16 :: ns/op</td>
      <td width="280">32740.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkUnmarshalVecDense10-16 :: ns/op</td>
      <td width="280">175.3</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### google.golang.org/protobuf/encoding

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
      <td width="500">google.golang.org/protobuf/encoding :: BenchmarkTextDecode-16 :: ns/op</td>
      <td width="280">21130410.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### google.golang.org/protobuf/internal/benchmarks/micro

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
      <td width="500">google.golang.org/protobuf/internal/benchmarks/micro :: BenchmarkEmptyMessage/Wire/Marshal-16 :: ns/op</td>
      <td width="280">4.138</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/internal/benchmarks/micro :: BenchmarkExtension/Get/Set-16 :: ns/op</td>
      <td width="280">77.78</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### google.golang.org/protobuf/internal/encoding/json

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
      <td width="500">google.golang.org/protobuf/internal/encoding/json :: BenchmarkBool-16 :: ns/op</td>
      <td width="280">40.94</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/internal/encoding/json :: BenchmarkInt-16 :: ns/op</td>
      <td width="280">157.7</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### google.golang.org/protobuf/proto

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
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkDecode/basic_scalar_types_(*test.TestAllTypes)-16 :: ns/op</td>
      <td width="280">238.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkDecode/field_type_mismatch_(*test3.TestAllTypes)-16 :: ns/op</td>
      <td width="280">190.4</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkDecode/just_at_recursion_limit_(*test3.TestAllTypes)-16 :: ns/op</td>
      <td width="280">394.1</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkDecode/required_field_in_oneof_message_set_(*test.TestRequiredForeign)-16 :: ns/op</td>
      <td width="280">50.54</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkDecode/required_group_set_(*required_opaque.Group)-16 :: ns/op</td>
      <td width="280">28.02</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-16 :: ns/op</td>
      <td width="280">41058.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-16 :: ns/op</td>
      <td width="280">3.837</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### google.golang.org/protobuf/reflect/protoreflect

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
      <td width="500">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-16 :: B/op</td>
      <td width="280">16.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-16 :: ns/op</td>
      <td width="280">13.12</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### k8s.io/client-go/tools/cache

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
      <td width="500">k8s.io/client-go/tools/cache :: BenchmarkEachListItemWithAlloc/PodList-16 :: ns/op</td>
      <td width="280">36621.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### k8s.io/client-go/util/workqueue

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
      <td width="500">k8s.io/client-go/util/workqueue :: BenchmarkDelayingQueue_AddAfter-16 :: ns/op</td>
      <td width="280">1960.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### zombiezen.com/go/capnproto2

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
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-16 :: B/op</td>
      <td width="280">1648627.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-16 :: MB/s</td>
      <td width="280">110.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-16 :: allocs/op</td>
      <td width="280">21.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-16 :: ns/op</td>
      <td width="280">9474570.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-16 :: ns/op</td>
      <td width="280">249.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### golang 1.27.0

##### git.sr.ht/~nelsam/gxui/interval

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
      <td width="500">git.sr.ht/~nelsam/gxui/interval :: BenchmarkGeneral-256 :: ns/op</td>
      <td width="280">291.9</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/IBM/sarama

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
      <td width="500">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-256 :: B/op</td>
      <td width="280">11271.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-256 :: allocs/op</td>
      <td width="280">4.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-256 :: ns/op</td>
      <td width="280">439970.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-256 :: B/op</td>
      <td width="280">16.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-256 :: ns/op</td>
      <td width="280">91.55</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Masterminds/semver/v3

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
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-256 :: ns/op</td>
      <td width="280">39.22</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-256 :: B/op</td>
      <td width="280">128.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-256 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-256 :: ns/op</td>
      <td width="280">199.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-256 :: B/op</td>
      <td width="280">190.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-256 :: allocs/op</td>
      <td width="280">7.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-256 :: ns/op</td>
      <td width="280">629.1</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/augmentedtree

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
      <td width="500">github.com/Workiva/go-datastructures/augmentedtree :: BenchmarkAddItems-256 :: ns/op</td>
      <td width="280">199951.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/bitarray

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
      <td width="500">github.com/Workiva/go-datastructures/bitarray :: BenchmarkCompressedIntersects-256 :: ns/op</td>
      <td width="280">56.84</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/btree/palm

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
      <td width="500">github.com/Workiva/go-datastructures/btree/palm :: BenchmarkBulkGet-256 :: ns/op</td>
      <td width="280">722354.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/queue

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
      <td width="500">github.com/Workiva/go-datastructures/queue :: BenchmarkPriorityQueue-256 :: ns/op</td>
      <td width="280">670.1</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/rangetree

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
      <td width="500">github.com/Workiva/go-datastructures/rangetree :: BenchmarkApply-256 :: ns/op</td>
      <td width="280">14253.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Workiva/go-datastructures/rangetree :: BenchmarkImmutableInsertSecondDimension-256 :: ns/op</td>
      <td width="280">35179244.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/rangetree/skiplist

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
      <td width="500">github.com/Workiva/go-datastructures/rangetree/skiplist :: BenchmarkMultiDimensionInsertAtZeroDimension-256 :: ns/op</td>
      <td width="280">2668179.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/rtree/hilbert

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
      <td width="500">github.com/Workiva/go-datastructures/rtree/hilbert :: BenchmarkBulkUpdatePoints-256 :: ns/op</td>
      <td width="280">440549.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/set

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
      <td width="500">github.com/Workiva/go-datastructures/set :: BenchmarkClear-256 :: ns/op</td>
      <td width="280">84.89</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/Workiva/go-datastructures/set :: BenchmarkExists-256 :: ns/op</td>
      <td width="280">39.66</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/tree/avl

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
      <td width="500">github.com/Workiva/go-datastructures/tree/avl :: BenchmarkImmutableInsert-256 :: ns/op</td>
      <td width="280">964.6</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/Workiva/go-datastructures/trie/yfast

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
      <td width="500">github.com/Workiva/go-datastructures/trie/yfast :: BenchmarkIterator-256 :: ns/op</td>
      <td width="280">2705.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/benhoyt/goawk/interp

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
      <td width="500">github.com/benhoyt/goawk/interp :: BenchmarkBuiltinGsubAmpersand-256 :: ns/op</td>
      <td width="280">17363.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/benhoyt/goawk/interp :: BenchmarkNativeFunc-256 :: ns/op</td>
      <td width="280">7405.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/benhoyt/goawk/interp :: BenchmarkRecursiveFunc-256 :: ns/op</td>
      <td width="280">10712.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/benhoyt/goawk/interp :: BenchmarkRepeatNew-256 :: ns/op</td>
      <td width="280">99.68</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/benhoyt/goawk/interp :: BenchmarkSimpleBuiltins-256 :: ns/op</td>
      <td width="280">532.8</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/bits-and-blooms/bitset

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
      <td width="500">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-256 :: ns/op</td>
      <td width="280">17.01</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/cespare/xxhash/v2

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
      <td width="500">github.com/cespare/xxhash/v2 :: BenchmarkDigestBytes/100B-256 :: MB/s</td>
      <td width="280">3942.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/cespare/xxhash/v2 :: BenchmarkDigestBytes/100B-256 :: ns/op</td>
      <td width="280">25.37</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/dustin/go-broadcast

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
      <td width="500">github.com/dustin/go-broadcast :: BenchmarkDirectSend-256 :: ns/op</td>
      <td width="280">427.3</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/dustin/go-broadcast :: BenchmarkParallelBrodcast-256 :: ns/op</td>
      <td width="280">682.4</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/dustin/go-humanize

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
      <td width="500">github.com/dustin/go-humanize :: BenchmarkBigCommas-256 :: ns/op</td>
      <td width="280">505.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/dustin/go-humanize :: BenchmarkCommaf-256 :: ns/op</td>
      <td width="280">297.9</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/dustin/go-humanize :: BenchmarkParseBytes-256 :: ns/op</td>
      <td width="280">112.1</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/dustin/go-humanize :: BenchmarkParseSI-256 :: ns/op</td>
      <td width="280">441.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/ericlagergren/decimal_benchmarks

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
      <td width="500">github.com/ericlagergren/decimal_benchmarks :: BenchmarkMandelbrot_decimal_GDA_9-256 :: ns/op</td>
      <td width="280">1884592360.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=apmckinlay/prec=19-256 :: ns/op</td>
      <td width="280">2489.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=cockroachdb/apd/prec=100-256 :: ns/op</td>
      <td width="280">5074017.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=go-inf/prec=100-256 :: ns/op</td>
      <td width="280">111222.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/ethereum/go-ethereum/consensus/ethash

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
      <td width="500">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-256 :: B/op</td>
      <td width="280">64.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-256 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-256 :: ns/op</td>
      <td width="280">86.64</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/ethereum/go-ethereum/crypto/ecies

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
      <td width="500">github.com/ethereum/go-ethereum/crypto/ecies :: BenchmarkGenSharedKeyP256-256 :: ns/op</td>
      <td width="280">58652.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/ethereum/go-ethereum/trie

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
      <td width="500">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-256 :: B/op</td>
      <td width="280">109.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-256 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-256 :: ns/op</td>
      <td width="280">168.3</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/ethereum/go-ethereum/whisper/whisperv6

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
      <td width="500">github.com/ethereum/go-ethereum/whisper/whisperv6 :: BenchmarkDecryptionAsymInvalid-256 :: ns/op</td>
      <td width="280">106959.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/ethereum/go-ethereum/whisper/whisperv6 :: BenchmarkDecryptionSymInvalid-256 :: ns/op</td>
      <td width="280">196.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/flanglet/kanzi-go/v2/benchmark

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
      <td width="500">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkANS0-256 :: ns/op</td>
      <td width="280">1684810.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkBWTSmallBlock-256 :: ns/op</td>
      <td width="280">41795558.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkCM-256 :: ns/op</td>
      <td width="280">49882929.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkHuffman-256 :: ns/op</td>
      <td width="280">1871603.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/gohugoio/hugo/helpers

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
      <td width="500">github.com/gohugoio/hugo/helpers :: BenchmarkAbsURL/absurl-256 :: ns/op</td>
      <td width="280">4.49</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/gohugoio/hugo/helpers :: BenchmarkRelURL-256 :: ns/op</td>
      <td width="280">358.1</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/gohugoio/hugo/hugolib

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
      <td width="500">github.com/gohugoio/hugo/hugolib :: BenchmarkCreateShortcodePlaceholders-256 :: ns/op</td>
      <td width="280">52.8</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/google/uuid

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
      <td width="500">github.com/google/uuid :: BenchmarkNew-256 :: ns/op</td>
      <td width="280">374.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/google/uuid :: BenchmarkUUID_MarshalJSON-256 :: ns/op</td>
      <td width="280">352.8</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/google/uuid :: BenchmarkUUID_UnmarshalJSON-256 :: ns/op</td>
      <td width="280">382.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/minio/minio/cmd

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
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-256 :: MB/s</td>
      <td width="280">2310.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-256 :: ns/op</td>
      <td width="280">40.68</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-256 :: MB/s</td>
      <td width="280">3296.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-256 :: ns/op</td>
      <td width="280">138.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-256 :: MB/s</td>
      <td width="280">585.89</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-256 :: ns/op</td>
      <td width="280">392.6</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-256 :: MB/s</td>
      <td width="280">613.49</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-256 :: ns/op</td>
      <td width="280">741.7</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-256 :: MB/s</td>
      <td width="280">1014.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-256 :: ns/op</td>
      <td width="280">56.18</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-256 :: B/op</td>
      <td width="280">208.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-256 :: ns/op</td>
      <td width="280">122.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-256 :: MB/s</td>
      <td width="280">1028.71</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-256 :: ns/op</td>
      <td width="280">223.6</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-256 :: MB/s</td>
      <td width="280">1206.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-256 :: ns/op</td>
      <td width="280">377.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-256 :: MB/s</td>
      <td width="280">2189.5</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-256 :: ns/op</td>
      <td width="280">25.58</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/rcrowley/go-metrics

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
      <td width="500">github.com/rcrowley/go-metrics :: BenchmarkHistogram-256 :: ns/op</td>
      <td width="280">39.43</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/rcrowley/go-metrics :: BenchmarkTimer-256 :: ns/op</td>
      <td width="280">300.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/tetratelabs/wazero/internal/integration_test/bench

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
      <td width="500">github.com/tetratelabs/wazero/internal/integration_test/bench :: BenchmarkCompilation/without_extern_cache-256 :: ns/op</td>
      <td width="280">12695246.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/uber-go/tally/v4

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
      <td width="500">github.com/uber-go/tally/v4 :: BenchmarkScopeTaggedCachedSubscopes-256 :: ns/op</td>
      <td width="280">940.3</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/uber-go/tally/v4 :: BenchmarkTimerReport-256 :: ns/op</td>
      <td width="280">64.14</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gitlab.com/golang-commonmark/markdown

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
      <td width="500">gitlab.com/golang-commonmark/markdown :: BenchmarkRenderSpecNoHTML-256 :: ns/op</td>
      <td width="280">4923685.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### go.uber.org/thriftrw/gen

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
      <td width="500">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/ContainersOfContainers/Decode-256 :: ns/op</td>
      <td width="280">42865.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/ContainersOfContainers/Encode-256 :: ns/op</td>
      <td width="280">19233.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/PrimitiveOptionalStruct/Streaming_Decode-256 :: ns/op</td>
      <td width="280">921.7</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### go.uber.org/zap/zapcore

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
      <td width="500">go.uber.org/zap/zapcore :: BenchmarkJSONLogMarshalerFunc-256 :: ns/op</td>
      <td width="280">1596.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gonum.org/v1/gonum/graph/community

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
      <td width="500">gonum.org/v1/gonum/graph/community :: BenchmarkNewDirectedLayers/graphSize=10,numGraphs=1-256 :: ns/op</td>
      <td width="280">1204.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/graph/community :: BenchmarkNewDirectedLayers/graphSize=1000,numGraphs=1-256 :: ns/op</td>
      <td width="280">106883.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/graph/community :: BenchmarkNewUndirectedLayers/graphSize=1000,numGraphs=10-256 :: ns/op</td>
      <td width="280">1278009.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gonum.org/v1/gonum/graph/topo

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
      <td width="500">gonum.org/v1/gonum/graph/topo :: BenchmarkSortStabilizedPath_100000-256 :: ns/op</td>
      <td width="280">124991065.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gonum.org/v1/gonum/graph/traverse

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
      <td width="500">gonum.org/v1/gonum/graph/traverse :: BenchmarkWalkAllDepthFirstGnp_100_half-256 :: ns/op</td>
      <td width="280">399611.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gonum.org/v1/gonum/lapack/gonum

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
      <td width="500">gonum.org/v1/gonum/lapack/gonum :: BenchmarkDgeev/Circulant5-256 :: ns/op</td>
      <td width="280">9152.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/lapack/gonum :: BenchmarkDlantb/FrobeniusLowerNonUnitN=10000K=2-256 :: ns/op</td>
      <td width="280">102531.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### gonum.org/v1/gonum/mat

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
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkAddScaledVec10Inc1-256 :: ns/op</td>
      <td width="280">236.6</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkCholeskyFactorize/n=10-256 :: ns/op</td>
      <td width="280">2750.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkCholeskyInverseTo/n=100-256 :: ns/op</td>
      <td width="280">218623.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkMarshalToVecDense10-256 :: ns/op</td>
      <td width="280">492.6</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkPool100by100Uncleared-256 :: ns/op</td>
      <td width="280">18.79</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkTriMulDiag/BenchmarkTriMulDiag100-256 :: ns/op</td>
      <td width="280">40790.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">gonum.org/v1/gonum/mat :: BenchmarkUnmarshalVecDense10-256 :: ns/op</td>
      <td width="280">371.8</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### google.golang.org/protobuf/encoding

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
      <td width="500">google.golang.org/protobuf/encoding :: BenchmarkTextDecode-256 :: ns/op</td>
      <td width="280">36493096.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### google.golang.org/protobuf/internal/benchmarks/micro

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
      <td width="500">google.golang.org/protobuf/internal/benchmarks/micro :: BenchmarkEmptyMessage/Wire/Marshal-256 :: ns/op</td>
      <td width="280">0.397</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/internal/benchmarks/micro :: BenchmarkExtension/Get/Set-256 :: ns/op</td>
      <td width="280">164.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### google.golang.org/protobuf/internal/encoding/json

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
      <td width="500">google.golang.org/protobuf/internal/encoding/json :: BenchmarkBool-256 :: ns/op</td>
      <td width="280">40.47</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/internal/encoding/json :: BenchmarkInt-256 :: ns/op</td>
      <td width="280">232.8</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### google.golang.org/protobuf/proto

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
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkDecode/basic_scalar_types_(*test.TestAllTypes)-256 :: ns/op</td>
      <td width="280">2408.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkDecode/field_type_mismatch_(*test3.TestAllTypes)-256 :: ns/op</td>
      <td width="280">1173.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkDecode/just_at_recursion_limit_(*test3.TestAllTypes)-256 :: ns/op</td>
      <td width="280">2741.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkDecode/required_field_in_oneof_message_set_(*test.TestRequiredForeign)-256 :: ns/op</td>
      <td width="280">428.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkDecode/required_group_set_(*required_opaque.Group)-256 :: ns/op</td>
      <td width="280">104.8</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-256 :: ns/op</td>
      <td width="280">52571.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-256 :: ns/op</td>
      <td width="280">4.666</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### google.golang.org/protobuf/reflect/protoreflect

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
      <td width="500">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-256 :: B/op</td>
      <td width="280">16.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-256 :: ns/op</td>
      <td width="280">21.28</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### k8s.io/client-go/tools/cache

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
      <td width="500">k8s.io/client-go/tools/cache :: BenchmarkEachListItemWithAlloc/PodList-256 :: ns/op</td>
      <td width="280">66858.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### k8s.io/client-go/util/workqueue

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
      <td width="500">k8s.io/client-go/util/workqueue :: BenchmarkDelayingQueue_AddAfter-256 :: ns/op</td>
      <td width="280">3057.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### zombiezen.com/go/capnproto2

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
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-256 :: B/op</td>
      <td width="280">1648831.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-256 :: MB/s</td>
      <td width="280">74.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-256 :: allocs/op</td>
      <td width="280">21.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-256 :: ns/op</td>
      <td width="280">14099931.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-256 :: ns/op</td>
      <td width="280">461.8</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### golang 1.27.0

#### git.sr.ht/~nelsam/gxui/interval

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">git.sr.ht/~nelsam/gxui/interval :: BenchmarkGeneral-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">202.8</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">git.sr.ht/~nelsam/gxui/interval :: BenchmarkGeneral-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">291.9</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/IBM/sarama

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9749.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">4.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">355807.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">16.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">53.98</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">11271.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: BenchmarkZstdMemoryConsumption/no_drain-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">439970.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">16.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/IBM/sarama :: Benchmark_getMetricNameForTopic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">91.55</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Masterminds/semver/v3

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">26.65</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">128.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">91.43</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">189.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">7.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">311.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCheckVersionRange-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">39.22</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">128.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkCoerceNewVersionSimple-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">199.5</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">190.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">7.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Masterminds/semver/v3 :: BenchmarkValidateVersionRangeFail-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">629.1</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Workiva/go-datastructures/augmentedtree

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/augmentedtree :: BenchmarkAddItems-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">120551.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/augmentedtree :: BenchmarkAddItems-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">199951.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Workiva/go-datastructures/bitarray

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/bitarray :: BenchmarkCompressedIntersects-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">29.92</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/bitarray :: BenchmarkCompressedIntersects-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">56.84</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Workiva/go-datastructures/btree/palm

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/btree/palm :: BenchmarkBulkGet-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">509602.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/btree/palm :: BenchmarkBulkGet-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">722354.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Workiva/go-datastructures/queue

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/queue :: BenchmarkPriorityQueue-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">369.9</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/queue :: BenchmarkPriorityQueue-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">670.1</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Workiva/go-datastructures/rangetree

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/rangetree :: BenchmarkApply-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">11043.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/rangetree :: BenchmarkImmutableInsertSecondDimension-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">12788815.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/rangetree :: BenchmarkApply-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">14253.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/rangetree :: BenchmarkImmutableInsertSecondDimension-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">35179244.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Workiva/go-datastructures/rangetree/skiplist

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/rangetree/skiplist :: BenchmarkMultiDimensionInsertAtZeroDimension-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">939633.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/rangetree/skiplist :: BenchmarkMultiDimensionInsertAtZeroDimension-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2668179.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Workiva/go-datastructures/rtree/hilbert

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/rtree/hilbert :: BenchmarkBulkUpdatePoints-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">203245.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/rtree/hilbert :: BenchmarkBulkUpdatePoints-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">440549.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Workiva/go-datastructures/set

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/set :: BenchmarkClear-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">27.71</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/set :: BenchmarkExists-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">14.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/set :: BenchmarkClear-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">84.89</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/set :: BenchmarkExists-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">39.66</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Workiva/go-datastructures/tree/avl

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/tree/avl :: BenchmarkImmutableInsert-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">617.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/tree/avl :: BenchmarkImmutableInsert-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">964.6</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/Workiva/go-datastructures/trie/yfast

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/trie/yfast :: BenchmarkIterator-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2011.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/Workiva/go-datastructures/trie/yfast :: BenchmarkIterator-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2705.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/benhoyt/goawk/interp

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/benhoyt/goawk/interp :: BenchmarkBuiltinGsubAmpersand-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">8959.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/benhoyt/goawk/interp :: BenchmarkNativeFunc-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">4538.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/benhoyt/goawk/interp :: BenchmarkRecursiveFunc-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">6527.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/benhoyt/goawk/interp :: BenchmarkRepeatNew-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">65.45</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/benhoyt/goawk/interp :: BenchmarkSimpleBuiltins-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">455.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/benhoyt/goawk/interp :: BenchmarkBuiltinGsubAmpersand-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">17363.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/benhoyt/goawk/interp :: BenchmarkNativeFunc-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">7405.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/benhoyt/goawk/interp :: BenchmarkRecursiveFunc-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">10712.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/benhoyt/goawk/interp :: BenchmarkRepeatNew-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">99.68</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/benhoyt/goawk/interp :: BenchmarkSimpleBuiltins-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">532.8</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/bits-and-blooms/bitset

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">17.55</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bits-and-blooms/bitset :: BenchmarkBitSetExtractDeposit/size=64/fn=DepositTo-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">17.01</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/cespare/xxhash/v2

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/cespare/xxhash/v2 :: BenchmarkDigestBytes/100B-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">5125.31</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/cespare/xxhash/v2 :: BenchmarkDigestBytes/100B-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">19.51</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/cespare/xxhash/v2 :: BenchmarkDigestBytes/100B-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">3942.33</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/cespare/xxhash/v2 :: BenchmarkDigestBytes/100B-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">25.37</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/dustin/go-broadcast

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/dustin/go-broadcast :: BenchmarkDirectSend-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">224.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/dustin/go-broadcast :: BenchmarkParallelBrodcast-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">357.7</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/dustin/go-broadcast :: BenchmarkDirectSend-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">427.3</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/dustin/go-broadcast :: BenchmarkParallelBrodcast-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">682.4</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/dustin/go-humanize

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/dustin/go-humanize :: BenchmarkBigCommas-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">255.6</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/dustin/go-humanize :: BenchmarkCommaf-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">151.2</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/dustin/go-humanize :: BenchmarkParseBytes-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">59.06</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/dustin/go-humanize :: BenchmarkParseSI-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">258.4</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/dustin/go-humanize :: BenchmarkBigCommas-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">505.2</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/dustin/go-humanize :: BenchmarkCommaf-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">297.9</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/dustin/go-humanize :: BenchmarkParseBytes-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">112.1</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/dustin/go-humanize :: BenchmarkParseSI-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">441.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/ericlagergren/decimal_benchmarks

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/ericlagergren/decimal_benchmarks :: BenchmarkMandelbrot_decimal_GDA_9-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1477382819.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=apmckinlay/prec=19-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1405.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=cockroachdb/apd/prec=100-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">3705054.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=go-inf/prec=100-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">54775.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ericlagergren/decimal_benchmarks :: BenchmarkMandelbrot_decimal_GDA_9-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1884592360.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=apmckinlay/prec=19-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2489.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=cockroachdb/apd/prec=100-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">5074017.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ericlagergren/decimal_benchmarks :: BenchmarkPi/foo=go-inf/prec=100-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">111222.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/ethereum/go-ethereum/consensus/ethash

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">64.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">49.49</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">64.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/consensus/ethash :: BenchmarkDifficultyCalculator/u256-homestead-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">86.64</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/ethereum/go-ethereum/crypto/ecies

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/crypto/ecies :: BenchmarkGenSharedKeyP256-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">52464.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/crypto/ecies :: BenchmarkGenSharedKeyP256-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">58652.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/ethereum/go-ethereum/trie

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">109.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">3.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">76.91</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">109.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/trie :: BenchmarkDecodeShortNodeUnsafe-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">168.3</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/ethereum/go-ethereum/whisper/whisperv6

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/whisper/whisperv6 :: BenchmarkDecryptionAsymInvalid-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">115217.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/whisper/whisperv6 :: BenchmarkDecryptionSymInvalid-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">52.61</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/whisper/whisperv6 :: BenchmarkDecryptionAsymInvalid-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">106959.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/ethereum/go-ethereum/whisper/whisperv6 :: BenchmarkDecryptionSymInvalid-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">196.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/flanglet/kanzi-go/v2/benchmark

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkANS0-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1428786.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkBWTSmallBlock-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">26849281.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkCM-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">32577939.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkHuffman-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1304879.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkANS0-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1684810.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkBWTSmallBlock-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">41795558.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkCM-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">49882929.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/flanglet/kanzi-go/v2/benchmark :: BenchmarkHuffman-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1871603.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/gohugoio/hugo/helpers

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/gohugoio/hugo/helpers :: BenchmarkAbsURL/absurl-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">3.838</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/gohugoio/hugo/helpers :: BenchmarkRelURL-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">203.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/gohugoio/hugo/helpers :: BenchmarkAbsURL/absurl-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4.49</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/gohugoio/hugo/helpers :: BenchmarkRelURL-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">358.1</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/gohugoio/hugo/hugolib

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/gohugoio/hugo/hugolib :: BenchmarkCreateShortcodePlaceholders-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">39.27</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/gohugoio/hugo/hugolib :: BenchmarkCreateShortcodePlaceholders-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">52.8</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/google/uuid

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/google/uuid :: BenchmarkNew-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">644.6</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/google/uuid :: BenchmarkUUID_MarshalJSON-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">175.2</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/google/uuid :: BenchmarkUUID_UnmarshalJSON-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">246.1</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/google/uuid :: BenchmarkNew-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">374.2</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/google/uuid :: BenchmarkUUID_MarshalJSON-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">352.8</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/google/uuid :: BenchmarkUUID_UnmarshalJSON-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">382.5</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/minio/minio/cmd

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">2901.32</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">32.4</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">5074.56</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">89.66</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">710.94</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">323.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">726.99</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">625.9</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1702.47</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">33.48</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">208.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">65.03</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1262.85</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">182.1</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1509.45</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">301.4</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1997.21</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">28.04</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">2310.99</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBatchJobExpire-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">40.68</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">3296.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkAppendMsgBucketStats-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">138.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">585.89</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBatchJobKeyRotateV1-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">392.6</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">613.49</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkDecodeBucketStats-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">741.7</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">1014.57</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkEncodedataUsageCacheInfo-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">56.18</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">208.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkMarshalMsgBatchJobReplicateFlags-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">122.2</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">1028.71</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBatchJobKeyRotateV1-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">223.6</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">1206.82</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalBucketStats-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">377.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">2189.5</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/minio/minio/cmd :: BenchmarkUnmarshalReplicationMRFStats-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">25.58</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/rcrowley/go-metrics

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/rcrowley/go-metrics :: BenchmarkHistogram-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">14.05</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/rcrowley/go-metrics :: BenchmarkTimer-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">194.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/rcrowley/go-metrics :: BenchmarkHistogram-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">39.43</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/rcrowley/go-metrics :: BenchmarkTimer-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">300.2</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/tetratelabs/wazero/internal/integration_test/bench

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/tetratelabs/wazero/internal/integration_test/bench :: BenchmarkCompilation/without_extern_cache-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">10054583.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/tetratelabs/wazero/internal/integration_test/bench :: BenchmarkCompilation/without_extern_cache-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">12695246.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/uber-go/tally/v4

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">github.com/uber-go/tally/v4 :: BenchmarkScopeTaggedCachedSubscopes-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">490.7</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/uber-go/tally/v4 :: BenchmarkTimerReport-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">73.5</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/uber-go/tally/v4 :: BenchmarkScopeTaggedCachedSubscopes-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">940.3</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/uber-go/tally/v4 :: BenchmarkTimerReport-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">64.14</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### gitlab.com/golang-commonmark/markdown

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">gitlab.com/golang-commonmark/markdown :: BenchmarkRenderSpecNoHTML-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">3815180.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gitlab.com/golang-commonmark/markdown :: BenchmarkRenderSpecNoHTML-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4923685.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### go.uber.org/thriftrw/gen

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/ContainersOfContainers/Decode-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">30250.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/ContainersOfContainers/Encode-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">13258.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/PrimitiveOptionalStruct/Streaming_Decode-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">560.7</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/ContainersOfContainers/Decode-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">42865.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/ContainersOfContainers/Encode-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">19233.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">go.uber.org/thriftrw/gen :: BenchmarkRoundTrip/PrimitiveOptionalStruct/Streaming_Decode-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">921.7</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### go.uber.org/zap/zapcore

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">go.uber.org/zap/zapcore :: BenchmarkJSONLogMarshalerFunc-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">303.6</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">go.uber.org/zap/zapcore :: BenchmarkJSONLogMarshalerFunc-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1596.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### gonum.org/v1/gonum/graph/community

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">gonum.org/v1/gonum/graph/community :: BenchmarkNewDirectedLayers/graphSize=10,numGraphs=1-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">691.4</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/graph/community :: BenchmarkNewDirectedLayers/graphSize=1000,numGraphs=1-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">79438.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/graph/community :: BenchmarkNewUndirectedLayers/graphSize=1000,numGraphs=10-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">934283.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/graph/community :: BenchmarkNewDirectedLayers/graphSize=10,numGraphs=1-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1204.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/graph/community :: BenchmarkNewDirectedLayers/graphSize=1000,numGraphs=1-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">106883.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/graph/community :: BenchmarkNewUndirectedLayers/graphSize=1000,numGraphs=10-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1278009.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### gonum.org/v1/gonum/graph/topo

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">gonum.org/v1/gonum/graph/topo :: BenchmarkSortStabilizedPath_100000-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">78026452.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/graph/topo :: BenchmarkSortStabilizedPath_100000-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">124991065.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### gonum.org/v1/gonum/graph/traverse

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">gonum.org/v1/gonum/graph/traverse :: BenchmarkWalkAllDepthFirstGnp_100_half-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">244697.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/graph/traverse :: BenchmarkWalkAllDepthFirstGnp_100_half-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">399611.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### gonum.org/v1/gonum/lapack/gonum

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">gonum.org/v1/gonum/lapack/gonum :: BenchmarkDgeev/Circulant5-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">6602.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/lapack/gonum :: BenchmarkDlantb/FrobeniusLowerNonUnitN=10000K=2-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">97420.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/lapack/gonum :: BenchmarkDgeev/Circulant5-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9152.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/lapack/gonum :: BenchmarkDlantb/FrobeniusLowerNonUnitN=10000K=2-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">102531.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### gonum.org/v1/gonum/mat

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkAddScaledVec10Inc1-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">128.1</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkCholeskyFactorize/n=10-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2433.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkCholeskyInverseTo/n=100-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">196680.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkMarshalToVecDense10-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">290.3</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkPool100by100Uncleared-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">14.39</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkTriMulDiag/BenchmarkTriMulDiag100-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">32740.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkUnmarshalVecDense10-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">175.3</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkAddScaledVec10Inc1-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">236.6</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkCholeskyFactorize/n=10-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2750.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkCholeskyInverseTo/n=100-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">218623.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkMarshalToVecDense10-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">492.6</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkPool100by100Uncleared-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">18.79</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkTriMulDiag/BenchmarkTriMulDiag100-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">40790.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">gonum.org/v1/gonum/mat :: BenchmarkUnmarshalVecDense10-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">371.8</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### google.golang.org/protobuf/encoding

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">google.golang.org/protobuf/encoding :: BenchmarkTextDecode-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">21130410.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/encoding :: BenchmarkTextDecode-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">36493096.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### google.golang.org/protobuf/internal/benchmarks/micro

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">google.golang.org/protobuf/internal/benchmarks/micro :: BenchmarkEmptyMessage/Wire/Marshal-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">4.138</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/internal/benchmarks/micro :: BenchmarkExtension/Get/Set-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">77.78</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/internal/benchmarks/micro :: BenchmarkEmptyMessage/Wire/Marshal-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.397</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/internal/benchmarks/micro :: BenchmarkExtension/Get/Set-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">164.2</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### google.golang.org/protobuf/internal/encoding/json

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">google.golang.org/protobuf/internal/encoding/json :: BenchmarkBool-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">40.94</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/internal/encoding/json :: BenchmarkInt-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">157.7</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/internal/encoding/json :: BenchmarkBool-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">40.47</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/internal/encoding/json :: BenchmarkInt-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">232.8</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### google.golang.org/protobuf/proto

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkDecode/basic_scalar_types_(*test.TestAllTypes)-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">238.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkDecode/field_type_mismatch_(*test3.TestAllTypes)-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">190.4</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkDecode/just_at_recursion_limit_(*test3.TestAllTypes)-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">394.1</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkDecode/required_field_in_oneof_message_set_(*test.TestRequiredForeign)-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">50.54</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkDecode/required_group_set_(*required_opaque.Group)-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">28.02</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">41058.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">3.837</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkDecode/basic_scalar_types_(*test.TestAllTypes)-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2408.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkDecode/field_type_mismatch_(*test3.TestAllTypes)-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1173.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkDecode/just_at_recursion_limit_(*test3.TestAllTypes)-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2741.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkDecode/required_field_in_oneof_message_set_(*test.TestRequiredForeign)-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">428.5</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkDecode/required_group_set_(*required_opaque.Group)-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">104.8</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedEqual-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">52571.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/proto :: BenchmarkEqualWithDeeplyNestedIdenticalPtr-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4.666</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### google.golang.org/protobuf/reflect/protoreflect

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">16.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">13.12</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">16.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">google.golang.org/protobuf/reflect/protoreflect :: BenchmarkValue/Interface-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">21.28</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### k8s.io/client-go/tools/cache

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">k8s.io/client-go/tools/cache :: BenchmarkEachListItemWithAlloc/PodList-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">36621.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">k8s.io/client-go/tools/cache :: BenchmarkEachListItemWithAlloc/PodList-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">66858.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### k8s.io/client-go/util/workqueue

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">k8s.io/client-go/util/workqueue :: BenchmarkDelayingQueue_AddAfter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1960.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">k8s.io/client-go/util/workqueue :: BenchmarkDelayingQueue_AddAfter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3057.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### zombiezen.com/go/capnproto2

<table width="1380">
  <thead>
    <tr>
      <th width="400">指标</th>
      <th width="200">优化方向</th>
      <th width="200">x86_64</th>
      <th width="200">aarch64</th>
      <th width="380">相对性能</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">1648627.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">110.68</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">21.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">9474570.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">249.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1648831.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">74.37</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">21.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkGrowth_MultiSegment-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">14099931.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">zombiezen.com/go/capnproto2 :: BenchmarkUnmarshal_Reuse-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">461.8</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
