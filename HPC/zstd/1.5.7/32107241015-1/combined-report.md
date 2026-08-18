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
      <td width="220">zstd</td>
      <td width="160">1.5.7</td>
      <td width="220">aarch64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
    <tr>
      <td width="180">HPC</td>
      <td width="220">zstd</td>
      <td width="160">1.5.7</td>
      <td width="220">x86_64</td>
      <td width="240">passed</td>
      <td width="360">passed</td>
    </tr>
  </tbody>
</table>

## 测试环境

### zstd 1.5.7

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
      <td width="600">1.5.7</td>
      <td width="600">1.5.7</td>
    </tr>
    <tr>
      <td width="180">实际软件版本</td>
      <td width="600">1.5.7</td>
      <td width="600">1.5.7</td>
    </tr>
    <tr>
      <td width="180">构建信息记录时间</td>
      <td width="600">2026-08-18T06:31:20Z</td>
      <td width="600">2026-08-18T06:31:42Z</td>
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
      <td width="600">2026-08-18T06:30:54Z</td>
      <td width="600">2026-08-18T06:30:52Z</td>
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
      <td width="600">available: 1 nodes (0)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15<br>node 0 size: 30886 MB<br>node 0 free: 18283 MB<br>node distances:<br>node   0 <br>  0:  10</td>
      <td width="600">available: 4 nodes (0-3)<br>node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63<br>node 0 size: 128886 MB<br>node 0 free: 128071 MB<br>node 1 cpus: 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127<br>node 1 size: 128457 MB<br>node 1 free: 125665 MB<br>node 2 cpus: 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191<br>node 2 size: 127923 MB<br>node 2 free: 127341 MB<br>node 3 cpus: 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255<br>node 3 size: 129014 MB<br>node 3 free: 128470 MB<br>node distances:<br>node   0   1   2   3 <br>  0:  10  12  35  37 <br>  1:  12  10  37  40 <br>  2:  35  37  10  12 <br>  3:  37  40  12  10</td>
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
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compress</td>
      <td width="200">309.9</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decompress</td>
      <td width="200">1368.0</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compress_freshCCtx</td>
      <td width="200">308.5</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decompressDCtx</td>
      <td width="200">1358.6</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressContinue</td>
      <td width="200">308.3</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressContinue_extDict</td>
      <td width="200">308.0</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decompressContinue</td>
      <td width="200">1359.3</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream</td>
      <td width="200">284.2</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream_freshCCtx</td>
      <td width="200">284.5</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decompressStream</td>
      <td width="200">1363.5</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compress2</td>
      <td width="200">309.6</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream2, end</td>
      <td width="200">309.8</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream2, end &amp; short</td>
      <td width="200">307.8</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream2, continue</td>
      <td width="200">283.8</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream2, -T2, continue</td>
      <td width="200">518.9</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream2, -T2, end</td>
      <td width="200">523.9</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressSequences</td>
      <td width="200">818.3</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressSequencesAndLiterals</td>
      <td width="200">923.7</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">convertSequences (1st block)</td>
      <td width="200">10831.5</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">get1BlockSummary (1st block)</td>
      <td width="200">24193.2</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decodeLiteralsHeader (1st block</td>
      <td width="200">183664.9</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decodeLiteralsBlock (1st block)</td>
      <td width="200">12461.2</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decodeSeqHeaders (1st block)</td>
      <td width="200">51687.4</td>
      <td width="160">MB/s</td>
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
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compress</td>
      <td width="200">247.3</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decompress</td>
      <td width="200">863.9</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compress_freshCCtx</td>
      <td width="200">249.4</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decompressDCtx</td>
      <td width="200">864.4</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressContinue</td>
      <td width="200">249.2</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressContinue_extDict</td>
      <td width="200">248.6</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decompressContinue</td>
      <td width="200">863.5</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream</td>
      <td width="200">233.1</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream_freshCCtx</td>
      <td width="200">233.3</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decompressStream</td>
      <td width="200">863.8</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compress2</td>
      <td width="200">249.3</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream2, end</td>
      <td width="200">248.9</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream2, end &amp; short</td>
      <td width="200">247.7</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream2, continue</td>
      <td width="200">233.2</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream2, -T2, continue</td>
      <td width="200">422.0</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressStream2, -T2, end</td>
      <td width="200">422.0</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressSequences</td>
      <td width="200">642.7</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">compressSequencesAndLiterals</td>
      <td width="200">707.4</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">convertSequences (1st block)</td>
      <td width="200">8590.0</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">get1BlockSummary (1st block)</td>
      <td width="200">15726.8</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decodeLiteralsHeader (1st block</td>
      <td width="200">140434.8</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decodeLiteralsBlock (1st block)</td>
      <td width="200">7647.6</td>
      <td width="160">MB/s</td>
      <td width="260">越大越好</td>
    </tr>
    <tr>
      <td width="180">zstd</td>
      <td width="160">1.5.7</td>
      <td width="420">decodeSeqHeaders (1st block)</td>
      <td width="200">41714.0</td>
      <td width="160">MB/s</td>
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
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compress</td>
      <td width="180">越大越好</td>
      <td width="160">309.9</td>
      <td width="160">247.3</td>
      <td width="240">0.798</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">decompress</td>
      <td width="180">越大越好</td>
      <td width="160">1368.0</td>
      <td width="160">863.9</td>
      <td width="240">0.6315</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compress_freshCCtx</td>
      <td width="180">越大越好</td>
      <td width="160">308.5</td>
      <td width="160">249.4</td>
      <td width="240">0.8084</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">decompressDCtx</td>
      <td width="180">越大越好</td>
      <td width="160">1358.6</td>
      <td width="160">864.4</td>
      <td width="240">0.6362</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressContinue</td>
      <td width="180">越大越好</td>
      <td width="160">308.3</td>
      <td width="160">249.2</td>
      <td width="240">0.8083</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressContinue_extDict</td>
      <td width="180">越大越好</td>
      <td width="160">308.0</td>
      <td width="160">248.6</td>
      <td width="240">0.8071</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">decompressContinue</td>
      <td width="180">越大越好</td>
      <td width="160">1359.3</td>
      <td width="160">863.5</td>
      <td width="240">0.6353</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressStream</td>
      <td width="180">越大越好</td>
      <td width="160">284.2</td>
      <td width="160">233.1</td>
      <td width="240">0.8202</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressStream_freshCCtx</td>
      <td width="180">越大越好</td>
      <td width="160">284.5</td>
      <td width="160">233.3</td>
      <td width="240">0.82</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">decompressStream</td>
      <td width="180">越大越好</td>
      <td width="160">1363.5</td>
      <td width="160">863.8</td>
      <td width="240">0.6335</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compress2</td>
      <td width="180">越大越好</td>
      <td width="160">309.6</td>
      <td width="160">249.3</td>
      <td width="240">0.8052</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressStream2, end</td>
      <td width="180">越大越好</td>
      <td width="160">309.8</td>
      <td width="160">248.9</td>
      <td width="240">0.8034</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressStream2, end &amp; short</td>
      <td width="180">越大越好</td>
      <td width="160">307.8</td>
      <td width="160">247.7</td>
      <td width="240">0.8047</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressStream2, continue</td>
      <td width="180">越大越好</td>
      <td width="160">283.8</td>
      <td width="160">233.2</td>
      <td width="240">0.8217</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressStream2, -T2, continue</td>
      <td width="180">越大越好</td>
      <td width="160">518.9</td>
      <td width="160">422.0</td>
      <td width="240">0.8133</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressStream2, -T2, end</td>
      <td width="180">越大越好</td>
      <td width="160">523.9</td>
      <td width="160">422.0</td>
      <td width="240">0.8055</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressSequences</td>
      <td width="180">越大越好</td>
      <td width="160">818.3</td>
      <td width="160">642.7</td>
      <td width="240">0.7854</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">compressSequencesAndLiterals</td>
      <td width="180">越大越好</td>
      <td width="160">923.7</td>
      <td width="160">707.4</td>
      <td width="240">0.7658</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">convertSequences (1st block)</td>
      <td width="180">越大越好</td>
      <td width="160">10831.5</td>
      <td width="160">8590.0</td>
      <td width="240">0.7931</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">get1BlockSummary (1st block)</td>
      <td width="180">越大越好</td>
      <td width="160">24193.2</td>
      <td width="160">15726.8</td>
      <td width="240">0.6501</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">decodeLiteralsHeader (1st block</td>
      <td width="180">越大越好</td>
      <td width="160">183664.9</td>
      <td width="160">140434.8</td>
      <td width="240">0.7646</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">decodeLiteralsBlock (1st block)</td>
      <td width="180">越大越好</td>
      <td width="160">12461.2</td>
      <td width="160">7647.6</td>
      <td width="240">0.6137</td>
    </tr>
    <tr>
      <td width="160">zstd</td>
      <td width="140">1.5.7</td>
      <td width="340">decodeSeqHeaders (1st block)</td>
      <td width="180">越大越好</td>
      <td width="160">51687.4</td>
      <td width="160">41714.0</td>
      <td width="240">0.807</td>
    </tr>
  </tbody>
</table>

> 相对性能大于 1 表示 aarch64 更优；越小越好的指标已经反向换算。
