# git 2.56.0 性能报告

- 架构：`aarch64`
- 状态：`passed`
- Run ID：`41178777022-1`

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
      <td width="1200">2.56.0</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="1200">2.56.0</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="1200">2026-10-31T07:02:06Z</td>
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
      <td width="1200">2026-10-31T07:00:35Z</td>
    </tr>
    <tr>
      <td width="180">系统架构</td>
      <td width="1200">aarch64</td>
    </tr>
    <tr>
      <td width="180">CPU 型号</td>
      <td width="1200">-</td>
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
      <td width="1200">6.6.0-132.0.0.111.oe2403sp3.aarch64</td>
    </tr>
    <tr>
      <td width="180">Python 版本</td>
      <td width="1200">3.11.6</td>
    </tr>
    <tr>
      <td width="180">GCC 版本</td>
      <td width="1200">unknown</td>
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
      <td width="500">git_perf_suite</td>
      <td width="880">与被测软件版本一致 (a018953688f1b10bddf91bff8747068f5f4746a4)</td>
    </tr>
    <tr>
      <td width="500">gnu_time</td>
      <td width="880">unknown</td>
    </tr>
  </tbody>
</table>

## 性能指标

### p0002-read-cache

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
      <td width="500">p0002-read-cache.1: read_cache/discard_cache 1000 times</td>
      <td width="280">0.15</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### p0003-delta-base-cache

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
      <td width="500">p0003-delta-base-cache.1: log --raw</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0003-delta-base-cache.2: log -S</td>
      <td width="280">0.26</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### p0004-lazy-init-name-hash

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
      <td width="500">p0004-lazy-init-name-hash.3: single-threaded, 5078 entries, 1000 rounds</td>
      <td width="280">0.61</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0004-lazy-init-name-hash.4: multi-threaded, 5078 entries, 1000 rounds</td>
      <td width="280">1.34</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### p0005-status

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
      <td width="500">p0005-status.2: read-tree status br_ballast (4854)</td>
      <td width="280">0.03</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### p0007-write-cache

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
      <td width="500">p0007-write-cache.2: write_locked_index 3 times (4854 files)</td>
      <td width="280">0.02</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### p0008-odb-fsync

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
      <td width="500">p0008-odb-fsync.1: add 500 files (fsyncMethod=none)</td>
      <td width="280">0.04</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.2: add 500 files (fsyncMethod=fsync)</td>
      <td width="280">0.16</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.3: add 500 files (fsyncMethod=batch)</td>
      <td width="280">0.11</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.4: add 500 files (fsyncMethod=writeout-only)</td>
      <td width="280">0.07</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.5: stash 500 files (fsyncMethod=none)</td>
      <td width="280">0.09</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.6: stash 500 files (fsyncMethod=fsync)</td>
      <td width="280">0.29</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.7: stash 500 files (fsyncMethod=batch)</td>
      <td width="280">0.17</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.8: stash 500 files (fsyncMethod=writeout-only)</td>
      <td width="280">0.13</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.9: unpack 500 files (fsyncMethod=none)</td>
      <td width="280">0.04</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.10: unpack 500 files (fsyncMethod=fsync)</td>
      <td width="280">0.25</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.11: unpack 500 files (fsyncMethod=batch)</td>
      <td width="280">0.11</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.12: unpack 500 files (fsyncMethod=writeout-only)</td>
      <td width="280">0.09</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.13: commit 500 files (fsyncMethod=none)</td>
      <td width="280">0.04</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.14: commit 500 files (fsyncMethod=fsync)</td>
      <td width="280">0.25</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.15: commit 500 files (fsyncMethod=batch)</td>
      <td width="280">0.17</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0008-odb-fsync.16: commit 500 files (fsyncMethod=writeout-only)</td>
      <td width="280">0.12</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### p0009-diff-pathspec

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
      <td width="500">p0009-diff-pathspec.2: diff pathspec subtree</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### p0071-sort

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
      <td width="500">p0071-sort.2: sort(1) unsorted</td>
      <td width="280">0.17</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0071-sort.4: sort(1) sorted</td>
      <td width="280">0.1</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0071-sort.5: sort(1) reversed</td>
      <td width="280">0.09</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0071-sort.6: string_list_sort() unsorted</td>
      <td width="280">0.38</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0071-sort.8: string_list_sort() sorted</td>
      <td width="280">0.17</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0071-sort.10: string_list_sort() reversed</td>
      <td width="280">0.16</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0071-sort.12: DEFINE_LIST_SORT unsorted</td>
      <td width="280">0.44</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0071-sort.14: DEFINE_LIST_SORT sorted</td>
      <td width="280">0.15</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0071-sort.16: DEFINE_LIST_SORT reversed</td>
      <td width="280">0.15</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### p0090-cache-tree

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
      <td width="500">p0090-cache-tree.2: no-op, clean</td>
      <td width="280">0.34</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.3: prime_cache_tree, clean</td>
      <td width="280">0.48</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.4: cache_tree_update, clean</td>
      <td width="280">0.34</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.5: no-op, invalidate 2</td>
      <td width="280">0.34</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.6: prime_cache_tree, invalidate 2</td>
      <td width="280">0.49</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.7: cache_tree_update, invalidate 2</td>
      <td width="280">0.43</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.8: no-op, invalidate 50</td>
      <td width="280">0.34</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.9: prime_cache_tree, invalidate 50</td>
      <td width="280">0.48</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.10: cache_tree_update, invalidate 50</td>
      <td width="280">0.51</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.11: no-op, empty</td>
      <td width="280">0.34</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.12: prime_cache_tree, empty</td>
      <td width="280">0.48</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0090-cache-tree.13: cache_tree_update, empty</td>
      <td width="280">0.55</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### p0100-globbing

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
      <td width="500">p0100-globbing.2: refglob((a*)^nb) against tag (a^100).t; n = 1</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.3: refglob((a*)^nb) against tag (a^100).t; n = 2</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.4: refglob((a*)^nb) against tag (a^100).t; n = 3</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.5: refglob((a*)^nb) against tag (a^100).t; n = 4</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.6: refglob((a*)^nb) against tag (a^100).t; n = 5</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.7: refglob((a*)^nb) against tag (a^100).t; n = 6</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.8: fileglob((a*)^nb) against file (a^100).t; n = 1</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.9: fileglob((a*)^nb) against file (a^100).t; n = 2</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.10: fileglob((a*)^nb) against file (a^100).t; n = 3</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.11: fileglob((a*)^nb) against file (a^100).t; n = 4</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.12: fileglob((a*)^nb) against file (a^100).t; n = 5</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">p0100-globbing.13: fileglob((a*)^nb) against file (a^100).t; n = 6</td>
      <td width="280">0.01</td>
      <td width="200">s</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>
