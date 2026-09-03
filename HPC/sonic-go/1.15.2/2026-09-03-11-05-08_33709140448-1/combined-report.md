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
      <td width="220">sonic-go</td>
      <td width="160">1.15.2</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">sonic-go</td>
      <td width="160">1.15.2</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### sonic-go 1.15.2

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
      <td width="600">1.15.2</td>
      <td width="600">1.15.2</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.15.2</td>
      <td width="600">1.15.2</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-09-03T02:50:59Z</td>
      <td width="600">2026-09-03T02:49:02Z</td>
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
      <td width="600">2026-09-03T02:50:50Z</td>
      <td width="600">2026-09-03T02:48:47Z</td>
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
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 128160 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 127727 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 126987 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 127724 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
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
      <td width="500">go</td>
      <td width="880">1.27.0</td>
    </tr>
  </tbody>
</table>

## 单架构指标

### x86_64

#### sonic-go 1.15.2

##### github.com/bytedance/sonic/ast

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
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: B/op</td>
      <td width="280">13584.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: MB/s</td>
      <td width="280">8404.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: ns/op</td>
      <td width="280">1550.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: MB/s</td>
      <td width="280">6825471.7</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: ns/op</td>
      <td width="280">1.908</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: B/op</td>
      <td width="280">13591.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: MB/s</td>
      <td width="280">9402.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: ns/op</td>
      <td width="280">1385.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: MB/s</td>
      <td width="280">1317.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: ns/op</td>
      <td width="280">9884.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: B/op</td>
      <td width="280">56.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: MB/s</td>
      <td width="280">6097.74</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: ns/op</td>
      <td width="280">2136.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: B/op</td>
      <td width="280">56.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: MB/s</td>
      <td width="280">777.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: ns/op</td>
      <td width="280">16756.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: MB/s</td>
      <td width="280">6116.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: ns/op</td>
      <td width="280">2129.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: MB/s</td>
      <td width="280">778.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: ns/op</td>
      <td width="280">16721.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: MB/s</td>
      <td width="280">304.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: ns/op</td>
      <td width="280">2302.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-16 :: ns/op</td>
      <td width="280">17.62</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapGet-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapGet-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapGet-16 :: ns/op</td>
      <td width="280">9.602</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-16 :: ns/op</td>
      <td width="280">39.04</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapSet-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapSet-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapSet-16 :: ns/op</td>
      <td width="280">11.9</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-16 :: ns/op</td>
      <td width="280">9.116</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-16 :: ns/op</td>
      <td width="280">12.49</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-16 :: B/op</td>
      <td width="280">576.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-16 :: ns/op</td>
      <td width="280">121.7</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-16 :: ns/op</td>
      <td width="280">22.76</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-16 :: ns/op</td>
      <td width="280">8.774</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-16 :: ns/op</td>
      <td width="280">6.918</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-16 :: ns/op</td>
      <td width="280">21.95</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-16 :: ns/op</td>
      <td width="280">22.03</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-16 :: ns/op</td>
      <td width="280">25.52</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: B/op</td>
      <td width="280">1100.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: MB/s</td>
      <td width="280">4341.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: allocs/op</td>
      <td width="280">4.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: ns/op</td>
      <td width="280">2999.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: B/op</td>
      <td width="280">1096.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: MB/s</td>
      <td width="280">574.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: allocs/op</td>
      <td width="280">4.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: ns/op</td>
      <td width="280">22657.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: B/op</td>
      <td width="280">1056.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: MB/s</td>
      <td width="280">5002.91</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: ns/op</td>
      <td width="280">2603.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: B/op</td>
      <td width="280">1056.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: MB/s</td>
      <td width="280">657.22</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: ns/op</td>
      <td width="280">19815.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-16 :: ns/op</td>
      <td width="280">19.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-16 :: ns/op</td>
      <td width="280">2.218</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-16 :: ns/op</td>
      <td width="280">0.2748</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-16 :: ns/op</td>
      <td width="280">0.5547</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-16 :: ns/op</td>
      <td width="280">1.704</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-16 :: ns/op</td>
      <td width="280">1.411</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-16 :: ns/op</td>
      <td width="280">0.2737</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-16 :: ns/op</td>
      <td width="280">0.275</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/bytedance/sonic/decoder

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
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: B/op</td>
      <td width="280">55736.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: MB/s</td>
      <td width="280">217.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: allocs/op</td>
      <td width="280">85.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: ns/op</td>
      <td width="280">59809.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="280">55737.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="280">217.65</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">85.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="280">59891.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: B/op</td>
      <td width="280">8919.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: MB/s</td>
      <td width="280">335.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: ns/op</td>
      <td width="280">38899.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: B/op</td>
      <td width="280">96202.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: MB/s</td>
      <td width="280">101.13</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: allocs/op</td>
      <td width="280">946.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: ns/op</td>
      <td width="280">128895.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="280">96207.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="280">100.83</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">946.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="280">129275.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: B/op</td>
      <td width="280">49405.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: MB/s</td>
      <td width="280">122.38</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: ns/op</td>
      <td width="280">106511.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: B/op</td>
      <td width="280">56832.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: MB/s</td>
      <td width="280">445.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: allocs/op</td>
      <td width="280">95.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: ns/op</td>
      <td width="280">29265.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="280">56852.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="280">440.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">95.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="280">29563.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: B/op</td>
      <td width="280">8943.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: MB/s</td>
      <td width="280">1540.72</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: ns/op</td>
      <td width="280">8460.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: B/op</td>
      <td width="280">97955.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: MB/s</td>
      <td width="280">206.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: allocs/op</td>
      <td width="280">966.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: ns/op</td>
      <td width="280">63273.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="280">97960.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="280">205.12</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">966.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="280">63549.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: B/op</td>
      <td width="280">49485.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: MB/s</td>
      <td width="280">327.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: ns/op</td>
      <td width="280">39845.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/bytedance/sonic/encoder

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
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: B/op</td>
      <td width="280">9511.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: MB/s</td>
      <td width="280">843.01</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: ns/op</td>
      <td width="280">15462.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="280">9511.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="280">839.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="280">15533.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: B/op</td>
      <td width="280">9510.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: MB/s</td>
      <td width="280">844.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: ns/op</td>
      <td width="280">15427.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: B/op</td>
      <td width="280">9592.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: MB/s</td>
      <td width="280">344.74</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: ns/op</td>
      <td width="280">37811.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="280">9593.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="280">343.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="280">37945.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: B/op</td>
      <td width="280">9592.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: MB/s</td>
      <td width="280">345.6</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: ns/op</td>
      <td width="280">37717.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: B/op</td>
      <td width="280">9531.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: MB/s</td>
      <td width="280">3191.09</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: ns/op</td>
      <td width="280">4085.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="280">9532.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="280">3137.15</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="280">4155.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: B/op</td>
      <td width="280">9530.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: MB/s</td>
      <td width="280">3127.4</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: ns/op</td>
      <td width="280">4168.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: B/op</td>
      <td width="280">9646.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: MB/s</td>
      <td width="280">1688.94</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: ns/op</td>
      <td width="280">7718.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="280">9650.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="280">1660.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="280">7849.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: B/op</td>
      <td width="280">9648.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: MB/s</td>
      <td width="280">1641.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: ns/op</td>
      <td width="280">7940.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/bytedance/sonic/external_jsonlib_test/benchmark_test

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
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: B/op</td>
      <td width="280">21957.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: MB/s</td>
      <td width="280">661.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: allocs/op</td>
      <td width="280">49.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: ns/op</td>
      <td width="280">19695.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: B/op</td>
      <td width="280">14538.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: MB/s</td>
      <td width="280">443.96</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: allocs/op</td>
      <td width="280">379.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: ns/op</td>
      <td width="280">29361.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: B/op</td>
      <td width="280">8913.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: MB/s</td>
      <td width="280">333.59</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: ns/op</td>
      <td width="280">39074.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: B/op</td>
      <td width="280">64885.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: MB/s</td>
      <td width="280">244.69</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: allocs/op</td>
      <td width="280">996.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: ns/op</td>
      <td width="280">53272.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: B/op</td>
      <td width="280">54223.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: MB/s</td>
      <td width="280">227.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: allocs/op</td>
      <td width="280">1085.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: ns/op</td>
      <td width="280">57222.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: B/op</td>
      <td width="280">49375.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: MB/s</td>
      <td width="280">124.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: ns/op</td>
      <td width="280">105051.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: B/op</td>
      <td width="280">21970.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: MB/s</td>
      <td width="280">3416.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: allocs/op</td>
      <td width="280">49.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: ns/op</td>
      <td width="280">3815.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: B/op</td>
      <td width="280">14537.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: MB/s</td>
      <td width="280">3021.35</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: allocs/op</td>
      <td width="280">379.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: ns/op</td>
      <td width="280">4314.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: B/op</td>
      <td width="280">8915.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: MB/s</td>
      <td width="280">2530.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: ns/op</td>
      <td width="280">5152.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: B/op</td>
      <td width="280">64890.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: MB/s</td>
      <td width="280">1097.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: allocs/op</td>
      <td width="280">996.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: ns/op</td>
      <td width="280">11880.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: B/op</td>
      <td width="280">54222.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: MB/s</td>
      <td width="280">1143.77</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: allocs/op</td>
      <td width="280">1085.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: ns/op</td>
      <td width="280">11396.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: B/op</td>
      <td width="280">49376.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: MB/s</td>
      <td width="280">796.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: ns/op</td>
      <td width="280">16369.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: B/op</td>
      <td width="280">9474.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: MB/s</td>
      <td width="280">2270.63</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: ns/op</td>
      <td width="280">5741.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: B/op</td>
      <td width="280">9481.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: MB/s</td>
      <td width="280">1124.35</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: ns/op</td>
      <td width="280">11593.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: B/op</td>
      <td width="280">26720.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: MB/s</td>
      <td width="280">279.34</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: allocs/op</td>
      <td width="280">53.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: ns/op</td>
      <td width="280">46663.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: B/op</td>
      <td width="280">17986.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: MB/s</td>
      <td width="280">466.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: allocs/op</td>
      <td width="280">153.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: ns/op</td>
      <td width="280">27927.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: B/op</td>
      <td width="280">9480.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: MB/s</td>
      <td width="280">10443.52</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: ns/op</td>
      <td width="280">1248.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: B/op</td>
      <td width="280">9487.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: MB/s</td>
      <td width="280">6292.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: ns/op</td>
      <td width="280">2071.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: B/op</td>
      <td width="280">26604.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: MB/s</td>
      <td width="280">1452.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: allocs/op</td>
      <td width="280">53.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: ns/op</td>
      <td width="280">8974.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: B/op</td>
      <td width="280">17993.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: MB/s</td>
      <td width="280">2664.57</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: allocs/op</td>
      <td width="280">153.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: ns/op</td>
      <td width="280">4892.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: MB/s</td>
      <td width="280">1060.83</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: ns/op</td>
      <td width="280">12288.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: MB/s</td>
      <td width="280">601.83</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: ns/op</td>
      <td width="280">21659.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: B/op</td>
      <td width="280">86136.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: MB/s</td>
      <td width="280">509.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: allocs/op</td>
      <td width="280">152.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: ns/op</td>
      <td width="280">25594.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: MB/s</td>
      <td width="280">2027.78</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: ns/op</td>
      <td width="280">6428.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: B/op</td>
      <td width="280">27668.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: MB/s</td>
      <td width="280">314.92</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: allocs/op</td>
      <td width="280">635.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: ns/op</td>
      <td width="280">41391.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: B/op</td>
      <td width="280">86136.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: MB/s</td>
      <td width="280">1132.29</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: allocs/op</td>
      <td width="280">152.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: ns/op</td>
      <td width="280">11512.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: MB/s</td>
      <td width="280">17729.55</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: ns/op</td>
      <td width="280">735.2</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: B/op</td>
      <td width="280">27666.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: MB/s</td>
      <td width="280">1945.69</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: allocs/op</td>
      <td width="280">635.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: ns/op</td>
      <td width="280">6699.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: MB/s</td>
      <td width="280">6121.11</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: ns/op</td>
      <td width="280">2130.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: MB/s</td>
      <td width="280">777.69</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: ns/op</td>
      <td width="280">16761.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: B/op</td>
      <td width="280">40586.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: MB/s</td>
      <td width="280">197.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: allocs/op</td>
      <td width="280">335.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: ns/op</td>
      <td width="280">65915.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: B/op</td>
      <td width="280">86724.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: MB/s</td>
      <td width="280">155.62</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: allocs/op</td>
      <td width="280">1401.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: ns/op</td>
      <td width="280">83760.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: B/op</td>
      <td width="280">40586.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: MB/s</td>
      <td width="280">1131.64</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: allocs/op</td>
      <td width="280">335.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: ns/op</td>
      <td width="280">11519.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: B/op</td>
      <td width="280">54223.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: MB/s</td>
      <td width="280">1111.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: allocs/op</td>
      <td width="280">1085.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: ns/op</td>
      <td width="280">11730.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: B/op</td>
      <td width="280">45126.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: MB/s</td>
      <td width="280">213.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: allocs/op</td>
      <td width="280">952.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: ns/op</td>
      <td width="280">61037.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: B/op</td>
      <td width="280">45124.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: MB/s</td>
      <td width="280">1237.85</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: allocs/op</td>
      <td width="280">952.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: ns/op</td>
      <td width="280">10530.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: B/op</td>
      <td width="280">52169.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: MB/s</td>
      <td width="280">2080.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: allocs/op</td>
      <td width="280">10.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: ns/op</td>
      <td width="280">6265.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: B/op</td>
      <td width="280">52161.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: MB/s</td>
      <td width="280">583.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: allocs/op</td>
      <td width="280">10.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: ns/op</td>
      <td width="280">22352.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

### aarch64

#### sonic-go 1.15.2

##### github.com/bytedance/sonic/ast

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
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-256 :: B/op</td>
      <td width="280">13655.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-256 :: MB/s</td>
      <td width="280">2888.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-256 :: ns/op</td>
      <td width="280">4508.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-256 :: MB/s</td>
      <td width="280">5343865.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-256 :: ns/op</td>
      <td width="280">2.437</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-256 :: B/op</td>
      <td width="280">13637.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-256 :: MB/s</td>
      <td width="280">3389.98</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-256 :: ns/op</td>
      <td width="280">3842.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-256 :: MB/s</td>
      <td width="280">817.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-256 :: ns/op</td>
      <td width="280">15937.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-256 :: B/op</td>
      <td width="280">56.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-256 :: MB/s</td>
      <td width="280">41745.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-256 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-256 :: ns/op</td>
      <td width="280">312.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-256 :: B/op</td>
      <td width="280">56.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-256 :: MB/s</td>
      <td width="280">529.19</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-256 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-256 :: ns/op</td>
      <td width="280">24609.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-256 :: B/op</td>
      <td width="280">33.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-256 :: MB/s</td>
      <td width="280">45862.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-256 :: ns/op</td>
      <td width="280">284.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-256 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-256 :: MB/s</td>
      <td width="280">531.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-256 :: ns/op</td>
      <td width="280">24508.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-256 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-256 :: MB/s</td>
      <td width="280">149.73</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-256 :: ns/op</td>
      <td width="280">4682.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-256 :: ns/op</td>
      <td width="280">24.7</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapGet-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapGet-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapGet-256 :: ns/op</td>
      <td width="280">10.04</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-256 :: ns/op</td>
      <td width="280">55.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapSet-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapSet-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapSet-256 :: ns/op</td>
      <td width="280">12.69</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-256 :: ns/op</td>
      <td width="280">9.554</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-256 :: ns/op</td>
      <td width="280">13.5</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-256 :: B/op</td>
      <td width="280">576.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-256 :: ns/op</td>
      <td width="280">514.9</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-256 :: ns/op</td>
      <td width="280">21.61</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-256 :: ns/op</td>
      <td width="280">41.64</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-256 :: ns/op</td>
      <td width="280">6.564</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-256 :: ns/op</td>
      <td width="280">22.01</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-256 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-256 :: ns/op</td>
      <td width="280">67.72</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-256 :: ns/op</td>
      <td width="280">24.43</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-256 :: B/op</td>
      <td width="280">1153.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-256 :: MB/s</td>
      <td width="280">7271.95</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-256 :: allocs/op</td>
      <td width="280">4.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-256 :: ns/op</td>
      <td width="280">1791.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-256 :: B/op</td>
      <td width="280">1096.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-256 :: MB/s</td>
      <td width="280">402.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-256 :: allocs/op</td>
      <td width="280">4.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-256 :: ns/op</td>
      <td width="280">32335.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-256 :: B/op</td>
      <td width="280">1056.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-256 :: MB/s</td>
      <td width="280">9890.42</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-256 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-256 :: ns/op</td>
      <td width="280">1317.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-256 :: B/op</td>
      <td width="280">1056.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-256 :: MB/s</td>
      <td width="280">444.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-256 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-256 :: ns/op</td>
      <td width="280">29302.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-256 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-256 :: ns/op</td>
      <td width="280">37.48</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-256 :: ns/op</td>
      <td width="280">4.366</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-256 :: ns/op</td>
      <td width="280">0.3448</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-256 :: ns/op</td>
      <td width="280">0.8634</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-256 :: ns/op</td>
      <td width="280">4.838</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-256 :: ns/op</td>
      <td width="280">36.81</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-256 :: ns/op</td>
      <td width="280">0.3465</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-256 :: ns/op</td>
      <td width="280">0.3459</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/bytedance/sonic/decoder

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
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-256 :: B/op</td>
      <td width="280">56049.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-256 :: MB/s</td>
      <td width="280">135.07</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-256 :: allocs/op</td>
      <td width="280">85.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-256 :: ns/op</td>
      <td width="280">96504.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-256 :: B/op</td>
      <td width="280">56052.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-256 :: MB/s</td>
      <td width="280">134.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-256 :: allocs/op</td>
      <td width="280">85.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-256 :: ns/op</td>
      <td width="280">96640.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-256 :: B/op</td>
      <td width="280">8978.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-256 :: MB/s</td>
      <td width="280">209.8</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-256 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-256 :: ns/op</td>
      <td width="280">62130.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-256 :: B/op</td>
      <td width="280">96815.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-256 :: MB/s</td>
      <td width="280">62.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-256 :: allocs/op</td>
      <td width="280">946.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-256 :: ns/op</td>
      <td width="280">209769.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-256 :: B/op</td>
      <td width="280">96809.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-256 :: MB/s</td>
      <td width="280">61.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-256 :: allocs/op</td>
      <td width="280">946.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-256 :: ns/op</td>
      <td width="280">211909.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-256 :: B/op</td>
      <td width="280">49736.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-256 :: MB/s</td>
      <td width="280">73.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-256 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-256 :: ns/op</td>
      <td width="280">178058.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-256 :: B/op</td>
      <td width="280">56749.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-256 :: MB/s</td>
      <td width="280">358.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-256 :: allocs/op</td>
      <td width="280">94.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-256 :: ns/op</td>
      <td width="280">36327.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-256 :: B/op</td>
      <td width="280">56758.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-256 :: MB/s</td>
      <td width="280">358.07</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-256 :: allocs/op</td>
      <td width="280">94.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-256 :: ns/op</td>
      <td width="280">36404.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: B/op</td>
      <td width="280">8964.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: MB/s</td>
      <td width="280">1970.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: ns/op</td>
      <td width="280">6615.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-256 :: B/op</td>
      <td width="280">97537.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-256 :: MB/s</td>
      <td width="280">179.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-256 :: allocs/op</td>
      <td width="280">961.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-256 :: ns/op</td>
      <td width="280">72814.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-256 :: B/op</td>
      <td width="280">97583.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-256 :: MB/s</td>
      <td width="280">167.06</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-256 :: allocs/op</td>
      <td width="280">962.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-256 :: ns/op</td>
      <td width="280">78024.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: B/op</td>
      <td width="280">49508.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: MB/s</td>
      <td width="280">275.56</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: ns/op</td>
      <td width="280">47304.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/bytedance/sonic/encoder

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
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-256 :: B/op</td>
      <td width="280">9577.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-256 :: MB/s</td>
      <td width="280">473.51</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-256 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-256 :: ns/op</td>
      <td width="280">27528.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-256 :: B/op</td>
      <td width="280">9575.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-256 :: MB/s</td>
      <td width="280">475.08</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-256 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-256 :: ns/op</td>
      <td width="280">27437.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-256 :: B/op</td>
      <td width="280">9572.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-256 :: MB/s</td>
      <td width="280">476.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-256 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-256 :: ns/op</td>
      <td width="280">27345.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-256 :: B/op</td>
      <td width="280">9724.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-256 :: MB/s</td>
      <td width="280">239.35</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-256 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-256 :: ns/op</td>
      <td width="280">54459.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-256 :: B/op</td>
      <td width="280">9720.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-256 :: MB/s</td>
      <td width="280">237.88</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-256 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-256 :: ns/op</td>
      <td width="280">54796.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-256 :: B/op</td>
      <td width="280">9717.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-256 :: MB/s</td>
      <td width="280">236.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-256 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-256 :: ns/op</td>
      <td width="280">55007.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-256 :: B/op</td>
      <td width="280">9601.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-256 :: MB/s</td>
      <td width="280">6688.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-256 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-256 :: ns/op</td>
      <td width="280">1949.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-256 :: B/op</td>
      <td width="280">9604.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-256 :: MB/s</td>
      <td width="280">5108.33</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-256 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-256 :: ns/op</td>
      <td width="280">2552.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-256 :: B/op</td>
      <td width="280">9603.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-256 :: MB/s</td>
      <td width="280">5902.76</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-256 :: allocs/op</td>
      <td width="280">3.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-256 :: ns/op</td>
      <td width="280">2208.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-256 :: B/op</td>
      <td width="280">9757.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-256 :: MB/s</td>
      <td width="280">2832.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-256 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-256 :: ns/op</td>
      <td width="280">4602.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-256 :: B/op</td>
      <td width="280">9726.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-256 :: MB/s</td>
      <td width="280">3541.1</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-256 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-256 :: ns/op</td>
      <td width="280">3681.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-256 :: B/op</td>
      <td width="280">9718.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-256 :: MB/s</td>
      <td width="280">3443.68</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-256 :: allocs/op</td>
      <td width="280">8.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-256 :: ns/op</td>
      <td width="280">3785.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

##### github.com/bytedance/sonic/external_jsonlib_test/benchmark_test

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
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-256 :: B/op</td>
      <td width="280">22146.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-256 :: MB/s</td>
      <td width="280">432.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-256 :: allocs/op</td>
      <td width="280">49.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-256 :: ns/op</td>
      <td width="280">30133.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-256 :: B/op</td>
      <td width="280">14559.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-256 :: MB/s</td>
      <td width="280">298.58</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-256 :: allocs/op</td>
      <td width="280">379.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-256 :: ns/op</td>
      <td width="280">43657.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-256 :: B/op</td>
      <td width="280">8927.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-256 :: MB/s</td>
      <td width="280">214.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-256 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-256 :: ns/op</td>
      <td width="280">60903.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-256 :: B/op</td>
      <td width="280">65080.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-256 :: MB/s</td>
      <td width="280">142.62</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-256 :: allocs/op</td>
      <td width="280">996.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-256 :: ns/op</td>
      <td width="280">91397.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-256 :: B/op</td>
      <td width="280">54306.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-256 :: MB/s</td>
      <td width="280">128.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-256 :: allocs/op</td>
      <td width="280">1085.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-256 :: ns/op</td>
      <td width="280">101056.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-256 :: B/op</td>
      <td width="280">49451.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-256 :: MB/s</td>
      <td width="280">78.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-256 :: allocs/op</td>
      <td width="280">931.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-256 :: ns/op</td>
      <td width="280">165381.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-256 :: B/op</td>
      <td width="280">22222.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-256 :: MB/s</td>
      <td width="280">1435.05</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-256 :: allocs/op</td>
      <td width="280">50.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-256 :: ns/op</td>
      <td width="280">9083.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-256 :: B/op</td>
      <td width="280">14559.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-256 :: MB/s</td>
      <td width="280">929.18</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-256 :: allocs/op</td>
      <td width="280">379.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-256 :: ns/op</td>
      <td width="280">14029.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: B/op</td>
      <td width="280">8988.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: MB/s</td>
      <td width="280">1382.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: allocs/op</td>
      <td width="280">70.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: ns/op</td>
      <td width="280">9427.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-256 :: B/op</td>
      <td width="280">65101.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-256 :: MB/s</td>
      <td width="280">244.75</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-256 :: allocs/op</td>
      <td width="280">997.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-256 :: ns/op</td>
      <td width="280">53258.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-256 :: B/op</td>
      <td width="280">54305.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-256 :: MB/s</td>
      <td width="280">198.65</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-256 :: allocs/op</td>
      <td width="280">1085.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-256 :: ns/op</td>
      <td width="280">65619.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: B/op</td>
      <td width="280">49544.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: MB/s</td>
      <td width="280">222.02</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: allocs/op</td>
      <td width="280">932.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: ns/op</td>
      <td width="280">58711.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-256 :: B/op</td>
      <td width="280">9484.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-256 :: MB/s</td>
      <td width="280">1415.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-256 :: ns/op</td>
      <td width="280">9206.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-256 :: B/op</td>
      <td width="280">9493.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-256 :: MB/s</td>
      <td width="280">489.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-256 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-256 :: ns/op</td>
      <td width="280">26648.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-256 :: B/op</td>
      <td width="280">26970.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-256 :: MB/s</td>
      <td width="280">156.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-256 :: allocs/op</td>
      <td width="280">55.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-256 :: ns/op</td>
      <td width="280">83303.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-256 :: B/op</td>
      <td width="280">18010.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-256 :: MB/s</td>
      <td width="280">222.37</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-256 :: allocs/op</td>
      <td width="280">153.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-256 :: ns/op</td>
      <td width="280">58618.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-256 :: B/op</td>
      <td width="280">9584.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-256 :: MB/s</td>
      <td width="280">6721.41</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-256 :: ns/op</td>
      <td width="280">1939.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-256 :: B/op</td>
      <td width="280">9577.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-256 :: MB/s</td>
      <td width="280">5061.81</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-256 :: allocs/op</td>
      <td width="280">2.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-256 :: ns/op</td>
      <td width="280">2575.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-256 :: B/op</td>
      <td width="280">27343.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-256 :: MB/s</td>
      <td width="280">824.14</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-256 :: allocs/op</td>
      <td width="280">56.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-256 :: ns/op</td>
      <td width="280">15817.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-256 :: B/op</td>
      <td width="280">18090.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-256 :: MB/s</td>
      <td width="280">1066.48</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-256 :: allocs/op</td>
      <td width="280">153.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-256 :: ns/op</td>
      <td width="280">12222.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-256 :: MB/s</td>
      <td width="280">738.03</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-256 :: ns/op</td>
      <td width="280">17662.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-256 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-256 :: MB/s</td>
      <td width="280">412.59</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-256 :: ns/op</td>
      <td width="280">31593.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-256 :: B/op</td>
      <td width="280">86136.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-256 :: MB/s</td>
      <td width="280">259.45</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-256 :: allocs/op</td>
      <td width="280">152.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-256 :: ns/op</td>
      <td width="280">50240.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-256 :: MB/s</td>
      <td width="280">1678.65</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-256 :: ns/op</td>
      <td width="280">7765.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-256 :: B/op</td>
      <td width="280">27709.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-256 :: MB/s</td>
      <td width="280">198.66</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-256 :: allocs/op</td>
      <td width="280">635.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-256 :: ns/op</td>
      <td width="280">65615.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-256 :: B/op</td>
      <td width="280">86136.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-256 :: MB/s</td>
      <td width="280">352.21</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-256 :: allocs/op</td>
      <td width="280">152.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-256 :: ns/op</td>
      <td width="280">37009.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-256 :: B/op</td>
      <td width="280">0.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-256 :: MB/s</td>
      <td width="280">198222.16</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-256 :: allocs/op</td>
      <td width="280">0.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-256 :: ns/op</td>
      <td width="280">65.76</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-256 :: B/op</td>
      <td width="280">27694.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-256 :: MB/s</td>
      <td width="280">548.82</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-256 :: allocs/op</td>
      <td width="280">635.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-256 :: ns/op</td>
      <td width="280">23751.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-256 :: B/op</td>
      <td width="280">33.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-256 :: MB/s</td>
      <td width="280">70080.65</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-256 :: ns/op</td>
      <td width="280">186.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-256 :: B/op</td>
      <td width="280">32.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-256 :: MB/s</td>
      <td width="280">524.79</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-256 :: allocs/op</td>
      <td width="280">1.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-256 :: ns/op</td>
      <td width="280">24839.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-256 :: B/op</td>
      <td width="280">40585.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-256 :: MB/s</td>
      <td width="280">143.97</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-256 :: allocs/op</td>
      <td width="280">335.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-256 :: ns/op</td>
      <td width="280">90538.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-256 :: B/op</td>
      <td width="280">86853.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-256 :: MB/s</td>
      <td width="280">95.05</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-256 :: allocs/op</td>
      <td width="280">1401.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-256 :: ns/op</td>
      <td width="280">137140.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-256 :: B/op</td>
      <td width="280">40715.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-256 :: MB/s</td>
      <td width="280">387.99</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-256 :: allocs/op</td>
      <td width="280">335.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-256 :: ns/op</td>
      <td width="280">33596.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-256 :: B/op</td>
      <td width="280">54368.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-256 :: MB/s</td>
      <td width="280">172.23</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-256 :: allocs/op</td>
      <td width="280">1085.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-256 :: ns/op</td>
      <td width="280">75682.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-256 :: B/op</td>
      <td width="280">45185.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-256 :: MB/s</td>
      <td width="280">123.86</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-256 :: allocs/op</td>
      <td width="280">952.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-256 :: ns/op</td>
      <td width="280">105240.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-256 :: B/op</td>
      <td width="280">45173.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-256 :: MB/s</td>
      <td width="280">320.89</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-256 :: allocs/op</td>
      <td width="280">952.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-256 :: ns/op</td>
      <td width="280">40622.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-256 :: B/op</td>
      <td width="280">52234.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-256 :: MB/s</td>
      <td width="280">835.53</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-256 :: allocs/op</td>
      <td width="280">10.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-256 :: ns/op</td>
      <td width="280">15601.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-256 :: B/op</td>
      <td width="280">52224.0</td>
      <td width="200">B/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-256 :: MB/s</td>
      <td width="280">403.38</td>
      <td width="200">MB/s</td>
      <td width="400">越大越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-256 :: allocs/op</td>
      <td width="280">10.0</td>
      <td width="200">allocs/op</td>
      <td width="400">越小越好</td>
    </tr>
    <tr>
      <td width="500">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-256 :: ns/op</td>
      <td width="280">32314.0</td>
      <td width="200">ns/op</td>
      <td width="400">越小越好</td>
    </tr>
  </tbody>
</table>

## 跨架构指标

### sonic-go 1.15.2

#### github.com/bytedance/sonic/ast

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
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">13584.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">8404.56</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1550.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">6825471.7</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.908</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">13591.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">9402.75</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1385.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1317.56</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">9884.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">56.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">6097.74</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2136.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">56.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">777.21</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">16756.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">32.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">6116.77</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2129.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">32.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">778.85</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">16721.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">32.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">304.57</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2302.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">17.62</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapGet-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapGet-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapGet-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">9.602</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">39.04</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapSet-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapSet-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapSet-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">11.9</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">9.116</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">12.49</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">576.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">121.7</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">22.76</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">8.774</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">6.918</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">21.95</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">32.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">22.03</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">25.52</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">1100.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">4341.88</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">4.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2999.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">1096.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">574.78</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">4.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">22657.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">1056.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">5002.91</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2603.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">1056.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">657.22</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">19815.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">32.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">19.2</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.218</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.2748</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.5547</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.704</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.411</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.2737</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.275</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">13655.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">2888.79</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeLoad_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4508.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">5343865.41</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeRaw_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2.437</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">13637.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">3389.98</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkEncodeSkip_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3842.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">817.14</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetFull_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">15937.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">56.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">41745.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Parallel_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">312.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">56.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">529.19</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOneSafe_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">24609.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">33.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">45862.48</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Parallel_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">284.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">32.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">531.37</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetOne_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">24508.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">32.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">149.73</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkGetWithManyCompare_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4682.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapAdd-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">24.7</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapGet-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapGet-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapGet-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">10.04</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapIndex-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">55.5</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapSet-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapSet-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapSet-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">12.69</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkMapUnset-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9.554</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodUnsetByIndex-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">13.5</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">576.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeAdd-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">514.9</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGet-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">21.61</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeGetByPath-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">41.64</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeIndex-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">6.564</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSet-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">22.01</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">32.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeSetByIndex-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">67.72</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkNodeUnset-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">24.43</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1153.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">7271.95</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Parallel_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1791.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1096.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">402.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkParser_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">32335.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1056.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">9890.42</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Parallel_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1317.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1056.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">444.45</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSetOne_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">29302.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">32.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceAdd-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">37.48</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceGet-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4.366</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceIndex-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.3448</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceSetByIndex-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.8634</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkSliceUnsetByIndex-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4.838</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructGetByPath-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">36.81</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructIndex-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.3465</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/ast :: BenchmarkStructSetByIndex-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.3459</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/bytedance/sonic/decoder

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
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">55736.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">217.94</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">85.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">59809.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">55737.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">217.65</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">85.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">59891.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">8919.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">335.1</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">70.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">38899.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">96202.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">101.13</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">946.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">128895.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">96207.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">100.83</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">946.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">129275.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">49405.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">122.38</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">931.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">106511.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">56832.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">445.41</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">95.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">29265.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">56852.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">440.92</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">95.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">29563.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">8943.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1540.72</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">70.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">8460.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">97955.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">206.01</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">966.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">63273.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">97960.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">205.12</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">966.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">63549.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">49485.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">327.14</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">931.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">39845.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">56049.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">135.07</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">85.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">96504.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">56052.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">134.88</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">85.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_Sonic_Fast-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">96640.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">8978.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">209.8</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">70.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Binding_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">62130.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">96815.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">62.14</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">946.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">209769.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">96809.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">61.51</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">946.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_Sonic_Fast-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">211909.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">49736.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">73.21</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">931.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Generic_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">178058.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">56749.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">358.82</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">94.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">36327.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">56758.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">358.07</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">94.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_Sonic_Fast-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">36404.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">8964.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">1970.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">70.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">6615.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">97537.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">179.02</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">961.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">72814.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">97583.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">167.06</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">962.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_Sonic_Fast-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">78024.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">49508.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">275.56</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">931.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/decoder :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">47304.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/bytedance/sonic/encoder

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
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9511.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">843.01</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">3.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">15462.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9511.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">839.18</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">3.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">15533.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9510.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">844.97</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">3.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">15427.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9592.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">344.74</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">8.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">37811.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9593.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">343.53</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">8.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">37945.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9592.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">345.6</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">8.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">37717.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9531.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">3191.09</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">3.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">4085.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9532.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">3137.15</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">3.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">4155.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9530.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">3127.4</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">3.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">4168.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9646.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1688.94</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">8.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">7718.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9650.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1660.79</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">8.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">7849.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9648.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1641.77</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">8.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">7940.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9577.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">473.51</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">27528.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9575.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">475.08</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_Sonic_Fast-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">27437.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9572.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">476.68</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Binding_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">27345.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9724.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">239.35</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">8.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">54459.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9720.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">237.88</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">8.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_Sonic_Fast-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">54796.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9717.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">236.97</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">8.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Generic_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">55007.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9601.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">6688.45</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1949.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9604.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">5108.33</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_Sonic_Fast-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2552.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9603.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">5902.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Binding_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2208.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9757.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">2832.66</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">8.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">4602.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9726.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">3541.1</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">8.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_Sonic_Fast-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3681.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9718.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">3443.68</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">8.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/encoder :: BenchmarkEncoder_Parallel_Generic_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">3785.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

#### github.com/bytedance/sonic/external_jsonlib_test/benchmark_test

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
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">21957.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">661.86</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">49.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">19695.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">14538.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">443.96</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">379.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">29361.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">8913.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">333.59</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">70.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">39074.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">64885.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">244.69</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">996.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">53272.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">54223.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">227.8</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1085.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">57222.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">49375.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">124.08</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">931.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">105051.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">21970.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">3416.97</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">49.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">3815.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">14537.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">3021.35</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">379.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">4314.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">8915.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">2530.08</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">70.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">5152.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">64890.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1097.19</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">996.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">11880.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">54222.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1143.77</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1085.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">11396.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">49376.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">796.33</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">931.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">16369.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9474.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">2270.63</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">5741.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9481.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1124.35</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">11593.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">26720.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">279.34</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">53.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">46663.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">17986.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">466.75</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">153.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">27927.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9480.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">10443.52</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">1248.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">9487.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">6292.73</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">2.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2071.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">26604.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1452.53</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">53.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">8974.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">17993.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">2664.57</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">153.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">4892.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1060.83</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">12288.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">32.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">601.83</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">21659.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">86136.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">509.29</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">152.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">25594.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">2027.78</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">6428.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">27668.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">314.92</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">635.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">41391.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">86136.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1132.29</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">152.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">11512.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">17729.55</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">0.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">735.2</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">27666.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1945.69</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">635.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">6699.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">32.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">6121.11</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">2130.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">32.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">777.69</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">16761.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">40586.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">197.76</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">335.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">65915.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">86724.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">155.62</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1401.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">83760.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">40586.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1131.64</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">335.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">11519.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">54223.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1111.21</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">1085.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">11730.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">45126.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">213.56</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">952.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">61037.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">45124.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">1237.85</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">952.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">10530.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">52169.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">2080.56</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">10.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">6265.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">52161.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">583.16</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">10.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-16 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">22352.0</td>
      <td width="200">N/A</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">22146.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">432.58</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">49.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_GoJson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">30133.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">14559.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">298.58</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">379.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_JsonIter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">43657.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">8927.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">214.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">70.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Binding_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">60903.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">65080.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">142.62</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">996.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_GoJson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">91397.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">54306.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">128.99</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1085.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_JsonIter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">101056.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">49451.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">78.82</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">931.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Generic_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">165381.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">22222.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">1435.05</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">50.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_GoJson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9083.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">14559.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">929.18</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">379.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_JsonIter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">14029.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">8988.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">1382.75</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">70.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Binding_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9427.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">65101.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">244.75</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">997.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_GoJson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">53258.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">54305.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">198.65</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1085.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_JsonIter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">65619.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">49544.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">222.02</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">932.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkDecoder_Parallel_Generic_StdLib-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">58711.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9484.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">1415.86</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_GoJson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9206.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9493.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">489.16</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Binding_JsonIter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">26648.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">26970.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">156.48</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">55.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_GoJson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">83303.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">18010.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">222.37</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">153.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Generic_JsonIter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">58618.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9584.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">6721.41</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_GoJson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1939.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">9577.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">5061.81</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Binding_JsonIter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">2575.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">27343.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">824.14</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">56.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_GoJson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">15817.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">18090.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">1066.48</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">153.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkEncoder_Parallel_Generic_JsonIter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">12222.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">738.03</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_JsonParser-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">17662.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">32.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">412.59</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetByKeys_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">31593.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">86136.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">259.45</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">152.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Fastjson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">50240.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">1678.65</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Gjson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">7765.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">27709.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">198.66</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">635.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Jsoniter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">65615.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">86136.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">352.21</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">152.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Fastjson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">37009.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">198222.16</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">0.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Gjson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">65.76</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">27694.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">548.82</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">635.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Jsoniter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">23751.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">33.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">70080.65</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Parallel_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">186.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">32.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">524.79</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkGetOne_Sonic-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">24839.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">40585.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">143.97</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">335.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Gjson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">90538.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">86853.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">95.05</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1401.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Jsoniter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">137140.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">40715.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">387.99</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">335.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Gjson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">33596.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">54368.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">172.23</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">1085.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkParser_Parallel_Jsoniter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">75682.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">45185.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">123.86</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">952.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Jsoniter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">105240.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">45173.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">320.89</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">952.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Jsoniter-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">40622.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">52234.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">835.53</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">10.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Parallel_Sjson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">15601.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-256 :: B/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">52224.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-256 :: MB/s</td>
      <td width="200">越大越好</td>
      <td width="200">N/A</td>
      <td width="200">403.38</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-256 :: allocs/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">10.0</td>
      <td width="380">N/A</td>
    </tr>
    <tr>
      <td width="400">github.com/bytedance/sonic/external_jsonlib_test/benchmark_test :: BenchmarkSetOne_Sjson-256 :: ns/op</td>
      <td width="200">越小越好</td>
      <td width="200">N/A</td>
      <td width="200">32314.0</td>
      <td width="380">N/A</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
