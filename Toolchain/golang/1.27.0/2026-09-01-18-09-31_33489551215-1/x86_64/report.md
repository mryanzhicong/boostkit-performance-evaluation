# golang 1.27.0 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`33489551215-1`

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
      <td width="1200">1.27.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">1.27.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-09-01T08:56:11Z</td>
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
      <td width="1200">2026-09-01T08:56:06Z</td>
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
      <td width="500">bent</td>
      <td width="880">latest</td>
    </tr>
  </tbody>
</table>

## 性能指标

### git.sr.ht/~nelsam/gxui/interval

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

### github.com/IBM/sarama

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

### github.com/Masterminds/semver/v3

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

### github.com/Workiva/go-datastructures/augmentedtree

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

### github.com/Workiva/go-datastructures/bitarray

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

### github.com/Workiva/go-datastructures/btree/palm

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

### github.com/Workiva/go-datastructures/queue

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

### github.com/Workiva/go-datastructures/rangetree

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

### github.com/Workiva/go-datastructures/rangetree/skiplist

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

### github.com/Workiva/go-datastructures/rtree/hilbert

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

### github.com/Workiva/go-datastructures/set

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

### github.com/Workiva/go-datastructures/tree/avl

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

### github.com/Workiva/go-datastructures/trie/yfast

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

### github.com/benhoyt/goawk/interp

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

### github.com/bits-and-blooms/bitset

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

### github.com/cespare/xxhash/v2

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

### github.com/dustin/go-broadcast

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

### github.com/dustin/go-humanize

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

### github.com/ericlagergren/decimal_benchmarks

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

### github.com/ethereum/go-ethereum/consensus/ethash

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

### github.com/ethereum/go-ethereum/crypto/ecies

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

### github.com/ethereum/go-ethereum/trie

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

### github.com/ethereum/go-ethereum/whisper/whisperv6

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

### github.com/flanglet/kanzi-go/v2/benchmark

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

### github.com/gohugoio/hugo/helpers

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

### github.com/gohugoio/hugo/hugolib

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

### github.com/google/uuid

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

### github.com/minio/minio/cmd

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

### github.com/rcrowley/go-metrics

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

### github.com/tetratelabs/wazero/internal/integration_test/bench

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

### github.com/uber-go/tally/v4

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

### gitlab.com/golang-commonmark/markdown

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

### go.uber.org/thriftrw/gen

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

### go.uber.org/zap/zapcore

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

### gonum.org/v1/gonum/graph/community

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

### gonum.org/v1/gonum/graph/topo

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

### gonum.org/v1/gonum/graph/traverse

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

### gonum.org/v1/gonum/lapack/gonum

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

### gonum.org/v1/gonum/mat

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

### google.golang.org/protobuf/encoding

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

### google.golang.org/protobuf/internal/benchmarks/micro

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

### google.golang.org/protobuf/internal/encoding/json

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

### google.golang.org/protobuf/proto

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

### google.golang.org/protobuf/reflect/protoreflect

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

### k8s.io/client-go/tools/cache

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

### k8s.io/client-go/util/workqueue

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

### zombiezen.com/go/capnproto2

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
