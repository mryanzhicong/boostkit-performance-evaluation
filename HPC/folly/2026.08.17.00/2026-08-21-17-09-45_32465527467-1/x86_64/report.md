# folly 2026.08.17.00 性能报告

- 架构：`x86_64`
- 状态：`passed`
- Run ID：`32465527467-1`

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
      <td width="1200">2026.08.17.00</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">2026.08.17.00</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-08-21T08:59:31Z</td>
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
      <td width="1200">2026-08-21T08:56:42Z</td>
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
      <td width="1200">available: 1 nodes (0)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>node 0 size: 30886 MB<br>node 0 free: 16331 MB<br>node distances:<br>node   0 <br>  0:  10</td>
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
      <td width="500">container/test/container_bit_iterator_bench/SimpleFFSTest</td>
      <td width="280">117576015.86369014</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">container/test/container_bit_iterator_bench/RealFFSTest</td>
      <td width="280">7561140.863690138</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="280">88.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="280">87.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="280">86.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="280">146.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="280">145.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="280">145.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="280">12.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="280">12.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="280">12.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="280">8.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="280">8.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="280">7.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="280">20.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="280">20.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="280">20.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="280">17.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="280">17.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="280">17.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="280">16.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="280">16.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="280">16.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="280">8.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="280">8.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="280">8.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="280">5.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="280">5.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="280">5.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="280">10.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="280">10.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="280">9.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="280">11.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="280">11.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="280">11.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- empty/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="280">57.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="280">56.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="280">55.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=1/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="280">90.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="280">88.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="280">86.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="280">184.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="280">162.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="280">148.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="280">27.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="280">24.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="280">18.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="280">18.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="280">15.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="280">7.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="280">23.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="280">32.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="280">31.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="280">29.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="280">31.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="280">31.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="280">31.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="280">16.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="280">12.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="280">5.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="280">5.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="280">5.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="280">7.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="280">7.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="280">7.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="280">14.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="280">14.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="280">14.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- empty/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="280">6.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="280">56.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="280">56.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="280">55.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="280">144.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="280">142.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="280">142.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="280">142.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="280">142.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="280">142.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=4/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="280">141.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Max time (ns/op)</td>
      <td width="280">157.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Avg time (ns/op)</td>
      <td width="280">142.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- empty/Min time (ns/op)</td>
      <td width="280">132.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Max time (ns/op)</td>
      <td width="280">277.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Avg time (ns/op)</td>
      <td width="280">253.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM ctor/dtor -- 1 item/Min time (ns/op)</td>
      <td width="280">242.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Max time (ns/op)</td>
      <td width="280">31.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Avg time (ns/op)</td>
      <td width="280">24.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 10M items/Min time (ns/op)</td>
      <td width="280">17.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Max time (ns/op)</td>
      <td width="280">33.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Avg time (ns/op)</td>
      <td width="280">26.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM find() -- 1 of 10M items/Min time (ns/op)</td>
      <td width="280">14.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Max time (ns/op)</td>
      <td width="280">11.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Avg time (ns/op)</td>
      <td width="280">8.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- empty/Min time (ns/op)</td>
      <td width="280">8.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Max time (ns/op)</td>
      <td width="280">38.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Avg time (ns/op)</td>
      <td width="280">32.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 1 item/Min time (ns/op)</td>
      <td width="280">22.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Max time (ns/op)</td>
      <td width="280">39.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Avg time (ns/op)</td>
      <td width="280">33.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10K items/Min time (ns/op)</td>
      <td width="280">22.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Max time (ns/op)</td>
      <td width="280">35.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Avg time (ns/op)</td>
      <td width="280">31.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM begin() -- 10M items/Min time (ns/op)</td>
      <td width="280">25.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Max time (ns/op)</td>
      <td width="280">11.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Avg time (ns/op)</td>
      <td width="280">9.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- empty/Min time (ns/op)</td>
      <td width="280">8.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Max time (ns/op)</td>
      <td width="280">44.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Avg time (ns/op)</td>
      <td width="280">36.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1 item/Min time (ns/op)</td>
      <td width="280">31.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Max time (ns/op)</td>
      <td width="280">37.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Avg time (ns/op)</td>
      <td width="280">31.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10 items/Min time (ns/op)</td>
      <td width="280">25.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Max time (ns/op)</td>
      <td width="280">35.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Avg time (ns/op)</td>
      <td width="280">32.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100 items/Min time (ns/op)</td>
      <td width="280">24.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Max time (ns/op)</td>
      <td width="280">17.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Avg time (ns/op)</td>
      <td width="280">15.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1K items/Min time (ns/op)</td>
      <td width="280">12.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Max time (ns/op)</td>
      <td width="280">12.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Avg time (ns/op)</td>
      <td width="280">9.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10K items/Min time (ns/op)</td>
      <td width="280">8.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Max time (ns/op)</td>
      <td width="280">10.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Avg time (ns/op)</td>
      <td width="280">8.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 100K items/Min time (ns/op)</td>
      <td width="280">7.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Max time (ns/op)</td>
      <td width="280">17.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Avg time (ns/op)</td>
      <td width="280">14.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 1M items/Min time (ns/op)</td>
      <td width="280">11.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Max time (ns/op)</td>
      <td width="280">20.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Avg time (ns/op)</td>
      <td width="280">19.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM iterate -- 10M items/Min time (ns/op)</td>
      <td width="280">18.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Max time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Avg time (ns/op)</td>
      <td width="280">3.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- empty/Min time (ns/op)</td>
      <td width="280">2.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Max time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Avg time (ns/op)</td>
      <td width="280">3.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 1 item/Min time (ns/op)</td>
      <td width="280">2.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Max time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Avg time (ns/op)</td>
      <td width="280">3.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10K items/Min time (ns/op)</td>
      <td width="280">2.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Max time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Avg time (ns/op)</td>
      <td width="280">3.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM empty() -- 10M items/Min time (ns/op)</td>
      <td width="280">2.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Max time (ns/op)</td>
      <td width="280">2.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Avg time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- empty/Min time (ns/op)</td>
      <td width="280">1.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Max time (ns/op)</td>
      <td width="280">4.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Avg time (ns/op)</td>
      <td width="280">3.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1 item/Min time (ns/op)</td>
      <td width="280">2.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Max time (ns/op)</td>
      <td width="280">18.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Avg time (ns/op)</td>
      <td width="280">13.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10 items/Min time (ns/op)</td>
      <td width="280">12.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Max time (ns/op)</td>
      <td width="280">128.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Avg time (ns/op)</td>
      <td width="280">118.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100 items/Min time (ns/op)</td>
      <td width="280">110.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Max time (ns/op)</td>
      <td width="280">301.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Avg time (ns/op)</td>
      <td width="280">289.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1K items/Min time (ns/op)</td>
      <td width="280">282.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Max time (ns/op)</td>
      <td width="280">301.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Avg time (ns/op)</td>
      <td width="280">287.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10K items/Min time (ns/op)</td>
      <td width="280">282.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Max time (ns/op)</td>
      <td width="280">297.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Avg time (ns/op)</td>
      <td width="280">290.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 100K items/Min time (ns/op)</td>
      <td width="280">282.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Max time (ns/op)</td>
      <td width="280">317.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Avg time (ns/op)</td>
      <td width="280">288.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 1M items/Min time (ns/op)</td>
      <td width="280">282.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Max time (ns/op)</td>
      <td width="280">300.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Avg time (ns/op)</td>
      <td width="280">287.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">concurrency/test/concurrency_concurrent_hash_map_bench/threads=16/CHM size() -- 10M items/Min time (ns/op)</td>
      <td width="280">282.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/constantFuture</td>
      <td width="280">15.962965488433838</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%promiseAndFuture</td>
      <td width="280">35.58347940444946</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%withThen</td>
      <td width="280">96.20817422866821</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/oneThen</td>
      <td width="280">70.14250040054321</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%twoThens</td>
      <td width="280">126.41508340835571</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%fourThens</td>
      <td width="280">236.6042923927307</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%hundredThens</td>
      <td width="280">5471.504194736481</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%fourThensOnThread</td>
      <td width="280">27476.11356973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%fourThensOnThreadInline</td>
      <td width="280">27133.14481973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%hundredThensOnThread</td>
      <td width="280">41522.98856973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%hundredThensOnThreadInline</td>
      <td width="280">28017.05106973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/no_contention</td>
      <td width="280">1550356.8635697365</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%contention</td>
      <td width="280">1195305.8635697365</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/throwAndCatch</td>
      <td width="280">3417.7541947364807</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%throwAndCatchWrapped</td>
      <td width="280">1490.8010697364807</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%throwWrappedAndCatch</td>
      <td width="280">2184.6487259864807</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%throwWrappedAndCatchWrapped</td>
      <td width="280">197.3159623146057</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/throwAndCatchContended</td>
      <td width="280">35536083.86356974</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%throwAndCatchWrappedContended</td>
      <td width="280">15766261.863569736</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%throwWrappedAndCatchContended</td>
      <td width="280">15656582.863569736</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%throwWrappedAndCatchWrappedContended</td>
      <td width="280">3360511.8635697365</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/lvalue_get</td>
      <td width="280">126.66093301773071</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%rvalue_get</td>
      <td width="280">125.67338418960571</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/complexUnit</td>
      <td width="280">24511.11356973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%complexBlob4</td>
      <td width="280">24497.83231973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%complexBlob8</td>
      <td width="280">23825.01981973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%complexBlob64</td>
      <td width="280">26054.23856973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%complexBlob128</td>
      <td width="280">27157.67606973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%complexBlob256</td>
      <td width="280">29098.30106973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%complexBlob512</td>
      <td width="280">36205.17606973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%complexBlob1024</td>
      <td width="280">45243.92606973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%complexBlob2048</td>
      <td width="280">51500.17606973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">futures/test/futures_benchmark/%complexBlob4096</td>
      <td width="280">83093.61356973648</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_8</td>
      <td width="280">5.037438869476318</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_16</td>
      <td width="280">5.580995082855225</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_32</td>
      <td width="280">6.683480739593506</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_64</td>
      <td width="280">8.860909938812256</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_128</td>
      <td width="280">12.658212184906006</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_256</td>
      <td width="280">21.38570547103882</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_512</td>
      <td width="280">38.83764028549194</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_1024</td>
      <td width="280">73.74059438705444</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_2048</td>
      <td width="280">143.61608266830444</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_4096</td>
      <td width="280">283.22570180892944</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_8192</td>
      <td width="280">562.3880553245544</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_16384</td>
      <td width="280">1121.9046568870544</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_32768</td>
      <td width="280">2237.8519225120544</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_65536</td>
      <td width="280">4477.519891262054</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_131072</td>
      <td width="280">8957.051141262054</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_262144</td>
      <td width="280">17891.426141262054</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32_524288</td>
      <td width="280">35768.301141262054</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_8</td>
      <td width="280">3.138749599456787</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_16</td>
      <td width="280">3.9670348167419434</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_32</td>
      <td width="280">3.966691493988037</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_64</td>
      <td width="280">4.231126308441162</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_128</td>
      <td width="280">7.509667873382568</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_256</td>
      <td width="280">12.833306789398193</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_512</td>
      <td width="280">23.28603506088257</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_1024</td>
      <td width="280">41.00469350814819</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_2048</td>
      <td width="280">75.77123403549194</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_4096</td>
      <td width="280">150.24816274642944</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_8192</td>
      <td width="280">440.04186391830444</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_16384</td>
      <td width="280">823.1448912620544</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_32768</td>
      <td width="280">1587.8323912620544</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_65536</td>
      <td width="280">3114.8831725120544</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_131072</td>
      <td width="280">6172.051141262054</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_262144</td>
      <td width="280">12258.066766262054</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">hash/test/hash_checksum_benchmark/crc32c_524288</td>
      <td width="280">24406.269891262054</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroy</td>
      <td width="280">13.75613808631897</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/cloneOneBenchmark</td>
      <td width="280">12.73532509803772</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/cloneOneIntoBenchmark</td>
      <td width="280">7.77255654335022</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/cloneBenchmark</td>
      <td width="280">14.812504053115845</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/cloneIntoBenchmark</td>
      <td width="280">8.043102502822876</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/moveBenchmark</td>
      <td width="280">8.04385781288147</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/copyBenchmark</td>
      <td width="280">11.355938196182251</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/copyBufferFromStringBenchmark</td>
      <td width="280">20.016056299209595</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/copyBufferFromStringPieceBenchmark</td>
      <td width="280">17.032352685928345</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/cloneCoalescedBaseline</td>
      <td width="280">148.54037880897522</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/%cloneCoalescedBenchmark</td>
      <td width="280">28.91055703163147</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/takeOwnershipBenchmark</td>
      <td width="280">17.093998193740845</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(64)</td>
      <td width="280">18399.394870996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(256)</td>
      <td width="280">18433.926120996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(1024)</td>
      <td width="280">31892.363620996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(4096)</td>
      <td width="280">33928.926120996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(5000)</td>
      <td width="280">33482.676120996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(5120)</td>
      <td width="280">36799.863620996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(8192)</td>
      <td width="280">34491.113620996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(10000)</td>
      <td width="280">34211.426120996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(10240)</td>
      <td width="280">34494.863620996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(16384)</td>
      <td width="280">35121.738620996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">io/test/io_iobuf_benchmark/createAndDestroyMulti(17000)</td>
      <td width="280">35035.488620996475</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/libc_tolower</td>
      <td width="280">698.2229578495026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/folly_toLowerAscii</td>
      <td width="280">14.585415124893188</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/folly_toUpperAscii</td>
      <td width="280">15.153347253799438</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/stringPrintfOutputSize(1)</td>
      <td width="280">65.60247445106506</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/stringPrintfOutputSize(4)</td>
      <td width="280">77.75884652137756</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/stringPrintfOutputSize(16)</td>
      <td width="280">77.33465218544006</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/stringPrintfOutputSize(64)</td>
      <td width="280">78.59502816200256</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/stringPrintfOutputSize(256)</td>
      <td width="280">170.86529183387756</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/stringPrintfOutputSize(1024)</td>
      <td width="280">230.31353402137756</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/stringPrintfAppendfBenchmark</td>
      <td width="280">9035845.86358285</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/fmtOutputSize(1)</td>
      <td width="280">47.83068490028381</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/fmtOutputSize(4)</td>
      <td width="280">59.33489632606506</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/fmtOutputSize(16)</td>
      <td width="280">59.36938118934631</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/fmtOutputSize(64)</td>
      <td width="280">59.05382943153381</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/fmtOutputSize(256)</td>
      <td width="280">59.91045784950256</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/fmtOutputSize(1024)</td>
      <td width="280">97.17779183387756</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/fmtAppendfBenchmark</td>
      <td width="280">2744559.8635828495</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/follyFmtOutputSize(1)</td>
      <td width="280">64.72539925575256</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/follyFmtOutputSize(4)</td>
      <td width="280">85.85821175575256</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/follyFmtOutputSize(16)</td>
      <td width="280">85.36504769325256</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/follyFmtOutputSize(64)</td>
      <td width="280">85.11791634559631</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/follyFmtOutputSize(256)</td>
      <td width="280">85.20757699012756</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/follyFmtOutputSize(1024)</td>
      <td width="280">114.87615609169006</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/BM_cEscape</td>
      <td width="280">181027.3635828495</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/BM_cUnescape</td>
      <td width="280">127733.6135828495</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/BM_uriEscape</td>
      <td width="280">1359.4631922245026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/BM_uriUnescape</td>
      <td width="280">753.1887781620026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/BM_unhexlify</td>
      <td width="280">0.20695090293884277</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/splitOnSingleChar</td>
      <td width="280">632.2073328495026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/splitOnSingleCharFixed</td>
      <td width="280">161.17828011512756</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/splitOnSingleCharFixedAllowExtra</td>
      <td width="280">135.17120003700256</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/splitStr</td>
      <td width="280">1373.7317469120026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/splitStrFixed</td>
      <td width="280">254.29961800575256</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/boost_splitOnSingleChar</td>
      <td width="280">1257.6575281620026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/joinCharStr</td>
      <td width="280">692.5198328495026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/joinStrStr</td>
      <td width="280">636.5676844120026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">test/string_benchmark/joinInt</td>
      <td width="280">847.7493250370026</td>
      <td width="200">ns</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
