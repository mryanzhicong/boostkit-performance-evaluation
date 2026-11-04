# cmake

CMake 4.4.5 鏋勫缓宸ュ叿鎬ц兘鐢ㄤ緥銆傚畬鏁村彛寰勪负**绯荤粺鍖?configure/build 鐭╅樀 + 涓婃父 CMake 婧愮爜宸ョ▼璐熻浇**锛屾寮忔€ц兘璇佹嵁鍙栬嚜 GitHub Actions `Blue: Manual performance evaluation` 鐨?**aarch64** 杩愯銆?
## 1. 鐗堟湰涓庢潵婧?
| 椤?| 鍊?|
|---|---|
| 杞欢鐗堟湰 | **4.4.5** |
| 涓婃父鏍囩 | `Kitware/CMake` `v4.4.5`锛?026-10-27 鍙戝竷锛?|
| x86_64 瀹樻柟浜岃繘鍒?| `cmake-4.4.5-linux-x86_64.tar.gz`<br>`https://github.com/Kitware/CMake/releases/download/v4.4.5/cmake-4.4.5-linux-x86_64.tar.gz`<br>SHA-256 `ed85135c5a5135b45e50423cb406dea04ca3338da0b8ef3c9ede963559680be0` |
| aarch64 瀹樻柟浜岃繘鍒?| `cmake-4.4.5-linux-aarch64.tar.gz`<br>`https://github.com/Kitware/CMake/releases/download/v4.4.5/cmake-4.4.5-linux-aarch64.tar.gz`<br>SHA-256 `301d5063ab259577c1b57ce5490b1aab9ea5c56dc4c822f73499553dab94925f` |
| 婧愮爜鍒跺搧锛堜笂娓稿伐绋嬭礋杞斤級 | `cmake-4.4.5.tar.gz`<br>`https://github.com/Kitware/CMake/releases/download/v4.4.5/cmake-4.4.5.tar.gz`<br>SHA-256 `a0c54c88abb8078dd8eccadb717fc6bb194bf18e7d44c86309910288886e04e2` |
| 瀹樻柟鏍￠獙娓呭崟 | `cmake-4.4.5-SHA-256.txt`锛圫HA-256 `f502d7058129606f8e468d2373178a5b48eb2c5f9785641b706f45952956dd25`锛屽垪鍑轰笂杩颁袱涓簩杩涘埗褰掓。鐨勬牎楠屽€硷級 |
| C 缂栬瘧鍣?| Runner 绯荤粺 `cc`锛堢増鏈湭鍥哄畾锛岄€愭杩愯鍐欏叆 `build_info.json` 涓?`results.json`锛?|
| C++ 缂栬瘧鍣?| 涓婃父 CMake 婧愮爜 configure 闇€瑕?C++ 缂栬瘧鍣紱`build` 闃舵鎶?`c++` 绾冲叆蹇呴渶鍛戒护骞惰嚜鍔ㄥ畨瑁咃紙dnf: `gcc-c++` / apt: `g++`锛夛紝闅忓悗鐢ㄤ竴涓渶灏忕▼搴忓仛缂栬瘧鑷锛岀己澶卞嵆 `build` 澶辫触 |
| 涓嬭浇婧?| 瀹樻柟 `https://cmake.org/files/v4.4/` 浼樺厛锛孏itHub Releases 娆′箣锛堜笓鐢?Runner 璁块棶 github.com 涓嶇ǔ瀹氾級锛屼篃鍙敤 `PERF_CMAKE_MIRROR`锛涗笁鑰呴兘蹇呴』鍖归厤鍚屼竴 SHA-256 |

涓や釜鏋舵瀯浣跨敤**鍚勮嚜鏋舵瀯鐨勫畼鏂逛簩杩涘埗褰掓。**锛堜笉鍋氭簮鐮佽嚜涓撅級锛岃娴嬭兘鍔涙槸 configure/build锛屼笉鏄紪璇?CMake 鏈韩銆傛墍鏈夊綊妗ｅ湪瑙ｅ寘鍓嶅己鍒舵牳瀵?SHA-256锛氫笉鍖归厤銆佷笅杞藉け璐ャ€佽В鍖呭け璐ヤ竴寰?`build` 澶辫触锛堣繑鍥為潪闆讹級锛屼笉闄嶇骇銆佷笉璺宠繃銆傛簮鐮佸綊妗ｇ殑 SHA-256 鍙栬嚜 GitHub release 璧勪骇鍏冩暟鎹紙瀹樻柟 `SHA-256.txt` 涓嶅寘鍚簮鐮佸綊妗ｏ級锛屽凡鍦ㄥ彇寰楀綊妗ｆ椂鏈湴澶嶆牳銆?
绂荤嚎鍖呯害瀹氾細鎶婁笅鍒楁枃浠堕缃埌 `/home/runner/software/cmake/` 鏃朵紭鍏堜娇鐢ㄥ苟寮哄埗鏍￠獙锛岀己澶辨墠鑱旂綉涓嬭浇锛?
```text
cmake-4.4.5-linux-x86_64.tar.gz
cmake-4.4.5-linux-aarch64.tar.gz
cmake-4.4.5.tar.gz
cmake-4.4.5-SHA-256.txt          # 鍙€夛紝浠呬綔瀹¤鍙傝€?```

## 2. 瀹夎涓庢瀯寤?
`build` 闃舵锛坄scripts/builders/dispatch.sh` 鈫?`base.sh`锛夊畬鎴愶細

1. 鏍￠獙绯荤粺渚濊禆锛坄curl`銆乣tar`銆乣gzip`銆乣sha256sum`銆乣gawk`銆乣make`銆乣cc`銆乣c++`銆乣python3`锛夛紱Runner 閫氳繃 `sudo -n dnf`锛堟垨 `apt-get`锛夎ˉ榻愮己澶卞寘锛屼唬鐞嗘潵鑷?`PERF_PROXY`銆俙c++` 闅忓悗鐢ㄦ渶灏忕▼搴忕紪璇戣嚜妫€锛氫笂娓?CMake 婧愮爜 configure 蹇呴』鑳芥壘鍒?C++ 缂栬瘧鍣ㄣ€?2. 鍙栨湰鏋舵瀯瀹樻柟浜岃繘鍒跺綊妗ｏ紝鏍稿 SHA-256 鍚庤В鍖呭埌 `$PERF_WORK_DIR/cmake-install`锛沗cmake --version` 瑙ｆ瀽鍑虹殑鐗堟湰蹇呴』鏄?`4.4.5`锛屽惁鍒?`build` 澶辫触锛堟鏋舵嵁 `actual-version.txt` 寮哄埗鏍￠獙锛夈€?3. 鍙栧畼鏂规簮鐮佸綊妗ｅ苟瑙ｅ寘鍒?`$PERF_WORK_DIR/cmake-source`锛屼綔涓轰笂娓稿伐绋嬭礋杞姐€?4. 鐢ㄨ渚嬭嚜甯︾殑 `scripts/generate_project.py` 纭畾鎬х敓鎴?100 / 1,000 / 10,000 婧愭枃浠剁殑 C 宸ョ▼鍒?`$PERF_WORK_DIR/projects/`銆?5. 鍐掔儫鏍￠獙锛氫互鍥哄畾鍙傛暟 configure 骞跺畬鏁存瀯寤?100 婧愭枃浠跺伐绋嬶紝纭宸ュ叿閾惧湪杩涘叆娴嬮噺闃舵鍓嶅彲鐢紙涓嶈鍏ユ祴閲忥級銆?6. 閫€鍑哄墠鍐欏嚭 `build_variant.json`銆?
**娴嬮噺闃舵涓嶉渶瑕佺綉缁?*锛欳Make 鏈韩涓嶈仈缃戯紝宸ョ▼鐢辩敤渚嬬敓鎴愶紝涓婃父婧愮爜鏉ヨ嚜 build 闃舵褰掓。锛宍upstream_build` 棣栨瀹屾暣鏋勫缓涔熷彧鍦ㄦ祴閲忓熀绾垮噯澶囨椂杩涜锛屼笉涓嬭浇浠讳綍渚濊禆銆?
## 3. 瀹屾暣娴嬭瘯鍙ｅ緞

### 3.1 涓轰粈涔堜笉鐢?CTest 濂椾欢

CMake 娌℃湁涓婃父鎬ц兘鍩哄噯濂椾欢銆侰Test/`cmake` 鑷韩鐨?`Tests/` 鏄?*姝ｇ‘鎬ф祴璇?*锛堟暟鍗冧釜閫氳繃/澶辫触鐢ㄤ緥銆佷互瑕嗙洊鍔熻兘涓虹洰鏍囥€佹寜 CMake 鐗堟湰鑰﹀悎锛屽崟渚嬭€楁椂姣绾у埌绉掔骇涓嶇瓑涓斿ぇ閲忎緷璧栧閮ㄥ伐鍏凤級锛屾妸瀹冨綋鎬ц兘鍙ｅ緞浼氫骇鐢熶笉鍙鐜般€佷笉鍙В閲婄殑鏁板瓧锛涘洜姝ゆ湰鐢ㄤ緥涓嶉噰鐢?CTest 浣滀负璁℃椂璐熻浇锛屾敼鐢ㄥ彲瀛楄妭绾у鐜扮殑**绯荤粺鍖栫煩闃?+ 涓婃父宸ョ▼璐熻浇**銆?
### 3.2 鐭╅樀

姣忎釜鍦烘櫙 **1 娆￠鐑?+ 5 娆＄嫭绔嬫寮忔祴閲?*锛屾姤涓綅鏁帮紝鍚屾椂淇濈暀姣忔鏍锋湰銆佹渶灏忓€笺€佹渶澶у€笺€佸潎鍊笺€佹爣鍑嗗樊銆?
| 鍦烘櫙 | 浠诲姟 | 瑙勬ā | 璇存槑 |
|---|---|---|---|
| `configure_100` | `configure` | 100 婧愭枃浠?| 绌烘瀯寤虹洰褰曠殑棣栨閰嶇疆 |
| `clean_build_100` | `clean build` | 100 婧愭枃浠?| `--target clean` 鍚庡畬鏁存瀯寤?|
| `incremental_build_100` | `incremental build` | 100 婧愭枃浠?| 鏀?1 涓簮鏂囦欢鍚庢瀯寤?|
| `noop_build_100` | `no-op build` | 100 婧愭枃浠?| 鏃犱换浣曟敼鍔ㄥ悗鏋勫缓 |
| `configure_1000` | `configure` | 1,000 婧愭枃浠?| 绌烘瀯寤虹洰褰曠殑棣栨閰嶇疆 |
| `clean_build_1000` | `clean build` | 1,000 婧愭枃浠?| `--target clean` 鍚庡畬鏁存瀯寤?|
| `incremental_build_1000` | `incremental build` | 1,000 婧愭枃浠?| 鏀?1 涓簮鏂囦欢鍚庢瀯寤?|
| `noop_build_1000` | `no-op build` | 1,000 婧愭枃浠?| 鏃犱换浣曟敼鍔ㄥ悗鏋勫缓 |
| `configure_10000` | `configure` | 10,000 婧愭枃浠?| 绌烘瀯寤虹洰褰曠殑棣栨閰嶇疆 |
| `clean_build_10000` | `clean build` | 10,000 婧愭枃浠?| `--target clean` 鍚庡畬鏁存瀯寤?|
| `incremental_build_10000` | `incremental build` | 10,000 婧愭枃浠?| 鏀?1 涓簮鏂囦欢鍚庢瀯寤?|
| `noop_build_10000` | `no-op build` | 10,000 婧愭枃浠?| 鏃犱换浣曟敼鍔ㄥ悗鏋勫缓 |
| `upstream_configure` | `configure` | 涓婃父 CMake 4.4.5 婧愮爜鏍?| 绌烘瀯寤虹洰褰曠殑棣栨閰嶇疆锛堢湡瀹炲ぇ鍨嬪伐绋嬶級 |
| `upstream_build` | `clean build` | 涓婃父 CMake 4.4.5 婧愮爜鏍?| `--target clean` 鍚庢瀯寤?`cmake` 鐩爣 |
| `upstream_incremental_build` | `incremental build` | 涓婃父 CMake 4.4.5 婧愮爜鏍?| 鏀?1 涓彾瀛愭簮鏂囦欢鍚庢瀯寤?`cmake` 鐩爣 |
| `upstream_noop_build` | `no-op build` | 涓婃父 CMake 4.4.5 婧愮爜鏍?| 鏃犳敼鍔ㄦ瀯寤?`cmake` 鐩爣 |

鍏?16 涓満鏅?脳 2 椤规寚鏍?= 32 涓寚鏍囥€?
鐢熸垚宸ョ▼涓虹‘瀹氭€у崟鍙墽琛岀洰鏍囷細`CMakeLists.txt` 鏄惧紡鍒楀嚭鍏ㄩ儴 `src/unit_XXXXX.c` 鍔?`main.c`锛屾瘡涓炕璇戝崟鍏冨彧鍚竴涓父閲忕畻鏈嚱鏁帮紝`main` 璋冪敤鍏ㄩ儴鍑芥暟骞舵墦鍗扮粨鏋溿€傛樉寮忔簮鍒楄〃璁?`configure` 鐨勮€楁椂闆嗕腑鍦?CMake 鑷韩鐨?CMakeLists 瑙ｆ瀽銆佺洰鏍囧缓妯′笌 Makefile 鐢熸垚涓婏紙鑰屼笉鏄亶鍘嗘枃浠剁郴缁燂級锛涜緭鍏ュ畬鍏ㄥ彲澶嶇幇銆?
### 3.3 鍥哄畾鏉′欢

- 鏋勫缓骞惰搴?*鍥哄畾 `-j8`**锛坄cmake --build <dir> -j 8`锛夛紝涓や釜鏋舵瀯涓€鑷达紱涓嶄娇鐢?`$(nproc)`锛岄伩鍏嶆妸鏈哄櫒鏍告暟娣峰叆鎸囨爣銆俁unner 鏍告暟 鈮?8 鏃惰骞惰搴﹀彲琚畬鏁磋皟搴︺€?- 鏋勫缓绫诲瀷 `Release`锛岀紪璇戦€夐」鍥哄畾 `-O2 -DNDEBUG`锛堢敓鎴愬伐绋嬩笌涓婃父宸ョ▼涓€鑷达級銆?- 鏋勫缓宸ュ叿涓?CMake 榛樿鐨?**Unix Makefiles**锛涗笉棰濆瀹夎 Ninja锛岄伩鍏嶆妸鐢熸垚鍣ㄥ樊寮傚紩鍏ョ粨鏋溿€傝鐢熸垚鍣ㄤ负姣忎釜婧愭枃浠剁敓鎴愮嫭绔嬭鍒欙紝10,000 婧愭枃浠舵椂 `build.make` 绾?14 MB锛宍make` 姣忔璋冪敤閮借瑙ｆ瀽瀹冿紝鍥犳 10,000 瑙勬ā鐨?`incremental_build` / `noop_build` 浼氱ǔ瀹氬湴鍖呭惈绾?15 s 鐨?make 瑙ｆ瀽鏃堕棿锛堟湰鏈哄鐓э細鍚屽伐绋?Ninja 鐢熸垚鍣?no-op 绾?0.07 s锛夈€傝繖鏄?CMake 榛樿 Makefile 鐢熸垚鍣ㄥ湪瓒呭ぇ鍗曠洰鏍囦笅鐨勭湡瀹炶涓猴紝灞炶娴嬪彛寰勭殑涓€閮ㄥ垎锛屼笉浜轰负瑙勯伩锛汻EADME 绗?4 鑺備笌鎶ュ憡鍚屾椂鏍囨敞銆?- `configure` 鍦烘櫙姣忔閮藉湪**鍏ㄦ柊鐨勭┖鐩綍**涓繘琛岋紝娴嬮噺鐨勬槸"棣栨閰嶇疆"锛沗clean_build` 鍦烘櫙鍦ㄥ凡閰嶇疆鐩綍涓?`--target clean` 鍚庢瀯寤猴紙涓嶉噸澶嶈鍏?configure锛夛紱`incremental_build` 姣忔鍙敼 `src/unit_00001.c` 涓€涓枃浠讹紙涓婃父鍦烘櫙鍙敼 `Source/cmWorkingDirectory.cxx` 涓€涓彾瀛愭枃浠讹級锛沗noop_build` 涓嶅仛浠讳綍鏀瑰姩銆?- 涓婃父宸ョ▼鍥哄畾 `--target cmake`锛屽苟閰嶇疆 `-DBUILD_TESTING=OFF -DCMAKE_USE_OPENSSL=OFF`锛屼娇鏋勫缓宸ヤ綔閲忓彧渚濊禆鍥哄畾婧愮爜褰掓。锛屼笉寮曞叆绯荤粺 OpenSSL 鐗堟湰宸紓銆?- 娴嬮噺闃舵涓嶈仈缃戙€佷笉璁?`MAKEFLAGS`銆佷笉娉ㄥ叆缂栬瘧鍣ㄧ紦瀛橈紙`ccache` 绛夛級銆?- 鎸囨爣缁熻涓?5 娆＄嫭绔嬫祴閲忕殑**涓綅鏁?*锛涘師濮嬫牱鏈笌瀹屾暣 stdout+stderr 鍏ㄩ儴淇濈暀銆?
### 3.4 鍗曟灦鏋勮€楁椂

鏈満 x86_64锛圵SL2锛?0 閫昏緫鏍革紝`-j8`銆乣PERF_REPS=5`銆佺绾垮寘宸查缃級鍏樁娈靛疄娴嬶細`build` 绾?3 s锛宍test` 绾?**22.5 鍒嗛挓**锛屽叚闃舵鍚堣 **22.6 鍒嗛挓**銆傚叾涓腑浣嶆暟锛歚configure` 1000/10000 涓?0.21 s / 1.02 s锛宍clean_build_10000` 涓?31.6 s锛宍upstream_configure` 涓?17.0 s锛宍upstream_build` 涓?97.1 s锛宍upstream_incremental_build` 涓?1.32 s锛宍upstream_noop_build` 涓?0.26 s銆俛arch64 涓撶敤 Runner 棰勮 30鈥?5 鍒嗛挓锛屼綆浜庡崟鏋舵瀯 60 鍒嗛挓涓婇檺銆?
## 4. 鎸囨爣

| 鎸囨爣 | 鍗曚綅 | 鏂瑰悜 | 鏉ユ簮 |
|---|---|---|---|
| `<鍦烘櫙>` | `s` | 瓒婁綆瓒婂ソ | `scripts/run_timed.py` 娴嬪緱鐨勫崟娆?`cmake` 瀛愯繘绋嬪閽燂紝鍙?5 娆′腑浣嶆暟 |
| `<鍦烘櫙>_rss` | `MiB` | 瓒婁綆瓒婂ソ | 鍚屼竴瀛愯繘绋嬫爲锛坈make 鈫?make 鈫?cc锛夌殑 `ru_maxrss`锛屽彇 5 娆′腑浣嶆暟 |

鍏ㄩ儴 32 涓寚鏍囩敱 `scripts/results/parse_benchmark.py` 浠?`runs/<鍦烘櫙>/rep<i>.json` 涓?`rep<i>.log` 鑱氬悎锛涗换涓€鍦烘櫙缂烘牱鏈€乣exit_code != 0`銆佽秴鏃躲€佹暟鍊奸潪鏈夐檺鎴栭潪姝ｃ€佸師濮嬫棩蹇楃己澶卞嵆瑙ｆ瀽澶辫触锛宍test` 闃舵杩斿洖闈為浂锛?*涓嶈ˉ闆躲€佷笉浼扮畻**銆?
娉ㄦ剰锛歚clean_build` / `incremental_build` / `noop_build` 鐨勫閽熷寘鍚?Runner 绯荤粺 C 缂栬瘧鍣ㄧ殑缂栬瘧鏃堕棿锛堝挨鍏?10,000 瑙勬ā鐨勫叏閲忔瀯寤猴級锛宍configure` 鍦烘櫙鎵嶆槸绾?CMake 鑳藉姏鎸囨爣锛涜法鏋舵瀯瀵规瘮鏃跺閽熷悓鏃跺彈鍚勬灦鏋勭紪璇戝櫒涓庡崟鏍告€ц兘褰卞搷锛屾姤鍛婂彧鎸夊悓鍚嶅満鏅厤瀵癸紝涓嶆妸涓嶅悓璐熻浇鐩存帴鎺掑簭銆?
## 5. 鏋舵瀯涓庤瘉鎹竟鐣?
- **姝ｅ紡鎬ц兘璇佹嵁**锛欸itHub Actions `Blue: Manual performance evaluation`锛宍architecture=aarch64`銆?- **x86_64 鏈満 WSL**锛氬彧鐢ㄤ簬鍔熻兘涓庨摼璺獙璇侊紙鏋勫缓 鈫?杩愯 鈫?瑙ｆ瀽 鈫?鎶ュ憡锛夛紝浜у嚭**涓嶆槸**鎬ц兘缁撹銆?- 鑴氭湰淇濇寔鏋舵瀯鏃犲叧锛氬彧鐢?`uname -m` 閫夋嫨瀹樻柟浜岃繘鍒跺綊妗ｏ紝涓嶄娇鐢ㄤ换浣曟灦鏋勪笓鐢ㄧ紪璇戦€夐」锛涗袱涓灦鏋勪娇鐢ㄥ悓涓€浠界敓鎴愬櫒銆佸悓涓€濂楀浐瀹氬弬鏁颁笌鍚屼竴骞惰搴︺€?
## 6. 杩愯鏂瑰紡

Actions锛堟寮忥紝aarch64锛夛細

```text
Workflow: Blue: Manual performance evaluation
software: cmake
version: 4.4.5
architecture: aarch64
variant: base
update_baseline: false
```

鐙珛鍏ュ彛锛堟湰鏈?璋冭瘯锛夛細

```bash
export PERF_WORK_DIR=$HOME/cmake-work        # 鍙€夛紱榛樿 /home/runner/boostkit-perf
export PERF_REPS=5                          # 榛樿 5锛涙湰鏈洪摼璺獙璇佸彲涓存椂闄嶄綆骞惰褰?bash software/Toolchain/cmake/cmake_test.sh \
  --version 4.4.5 --variant base --results-dir "$HOME/cmake-results"
```

`optimized` 鍙樹綋灏氭湭瀹炵幇锛歚cmake_test.sh --variant optimized` 涓庢鏋剁殑 optimized 鏋勫缓绔嬪嵆鏄庣‘澶辫触锛堣繑鍥炵爜 30锛夛紝**涓嶄細**鍥為€€鍒?base锛屼篃涓嶅啓 `build_variant.json`銆?
鍙€夌幆澧冨彉閲忥細

| 鍙橀噺 | 浣滅敤 |
|---|---|
| `PERF_REPS` | 姣忎釜鍦烘櫙鐨勭嫭绔嬫祴閲忔鏁帮紝榛樿 5锛涙湰鏈洪摼璺獙璇佸彲涓存椂闄嶄綆骞跺湪璇佹嵁涓褰?|
| `PERF_CMAKE_JOBS` | 鍥哄畾鏋勫缓骞惰搴︼紝榛樿 8锛涙寮忚瘉鎹姹備笌榛樿鍊间竴鑷?|
| `PERF_CMAKE_OFFLINE_DIR` | 瑕嗙洊绂荤嚎鍖呯洰褰曪紝榛樿 `/home/runner/software/cmake` |
| `PERF_CMAKE_MIRROR` | GitHub 涓嬭浇 URL 鐨勫墠缂€闀滃儚锛堝鍙楅檺缃戠粶涓嬬殑 release 浠ｇ悊锛夛紱涓嶈缃椂鍙敤瀹樻柟鍦板潃 |

鐙珛鍏ュ彛浜у嚭锛歚results.json`銆乣status.json`銆乣normalized_result.json`銆乣report.md`銆乣actual-version.txt`銆乣build_info.json`銆乣system_info.json`銆乣runtime_before.json`銆乣runtime_after.json`銆乣results.log`銆乣runs/`锛堟瘡鍦烘櫙棰勭儹 + 5 娆℃祴閲忕殑瀹屾暣鍘熷鏃ュ織涓庤鏃?JSON锛夈€傛鏋跺叚闃舵杩愯鏃跺彟鏈?`raw-output.log`锛坄test` 闃舵瀹屾暣鎺у埗鍙拌緭鍑猴級銆?
## 7. 涓庢棫浜や粯"鍐掔儫璐熻浇"鐨勫叧绯?
鏈湴 43 娆句氦浠橈紙2026-10-30锛変腑鐨?CMake 璐熻浇鏄?鍥哄畾 100 涓?C 鏂囦欢宸ョ▼ configure/clean build/no-op锛宍-j1`锛? 娆℃牱鏈?锛屽睘浜?*閾捐矾鍐掔儫**锛屽彧鐢ㄤ簬楠岃瘉"瑁呭緱璧锋潵銆佽窇寰楄捣鏉ャ€佹寚鏍囪寰楀嚭鏉?锛屽叾 111 瀹炴祴鍊间笉杩佺Щ杩涗粨搴撱€佷笉浣滀负鎬ц兘缁撹銆傛湰鐢ㄤ緥鎶婂畠浣滀负鐭╅樀鐨勪竴涓瓙闆嗭紙`configure_100` / `clean_build_100` / `noop_build_100`锛変繚鐣欙紝浣嗙湡姝ｇ殑鎬ц兘璇佹嵁鏄寘鍚?1k/10k 瑙勬ā銆佸閲忔瀯寤恒€佷笂娓?CMake 婧愮爜宸ョ▼銆佸浐瀹?`-j8` 涓旀瘡鍦烘櫙 5 娆′腑浣嶆暟鐨勫畬鏁村彛寰勩€?
## 8. 瀹瑰櫒鍖栨墽琛?
姣忎釜闃舵閮藉湪**鏈浠诲姟涓撳睘鐨?openEuler 24.03 LTS SP4 瀹瑰櫒**鍐呮墽琛岋紙瀹瑰櫒杩愯鏃跺潡鐢?`adaptation/scripts/add-container-block.py` 浠庢ā鏉垮啓鍏?`scripts/common.sh`锛屽嬁鎵嬫敼鏍囪鍖猴級锛?
- **闀滃儚**锛氫紭鍏堜娇鐢ㄦ湰鍦板綊妗?  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`锛岀己澶辨椂鎵嶄粠
  `repo.openeuler.org` 涓嬭浇锛涘姞杞藉墠鏍￠獙 `.sha256sum`銆侀暅鍍忔灦鏋勶紙`x86_64`鈫抈amd64`銆?  `aarch64`鈫抈arm64`锛変互鍙?`/etc/os-release` 涓殑 `24.03`銆?- **瀹瑰櫒鍚?鏍囩**锛歚boostkit-cmake-<arch>-<run-id>`锛屾爣绛?`boostkit.cmake.run-id=<run-id>`锛?  鍒犻櫎鍓嶆牎楠屾爣绛撅紝鎷掔粷鍒犻櫎鍏朵粬浠诲姟鐨勫鍣紙杩斿洖 60锛夛紱鍚姩鏃舵竻鐞嗗悓鍓嶇紑銆乺un-id 涓嶅悓鐨勯檲鏃у鍣ㄣ€?- **鎸傝浇**锛歚PERF_WORK_DIR`銆乣RESULTS_DIR` 涓庣敤渚嬬洰褰曟寜鐩稿悓缁濆璺緞鎸傚叆锛堢敤渚嬬洰褰曞彧璇伙級锛?  瀹瑰櫒鍐呭璺緞涓€鑷达紱鍙︽寕 `/etc/passwd`銆乣/etc/group`銆傚鍣ㄥ唴浠?`dnf` 瀹夎 `gcc`銆乣gcc-c++`銆?  `make`銆乣tar`銆乣gzip`銆乣coreutils`銆乣findutils`銆乣diffutils`銆乣sed`銆乣gawk`銆乣grep`銆?  `util-linux`銆乣file`銆乣glibc-devel`銆乣binutils`銆乣python3`锛涘涓绘満鍙繚鐣?Docker 涓?  涓嬭浇/SHA-256 鏍￠獙宸ュ叿銆?- **鑱岃矗鍒掑垎**锛氬涓绘満璐熻矗 CMake 鍙戣鍖?婧愮爜鍖呯殑涓嬭浇涓?SHA-256 鏍￠獙銆佹瘡涓?scenario 鐨?  `runs/` 浜х墿鏍￠獙涓庝弗鏍艰В鏋愶紱瀹瑰櫒鍐呰礋璐ｈВ鍖呫€乣cmake --version` 鐗堟湰鍒ゅ畾銆丆++ 宸ュ叿閾捐嚜妫€銆?  宸ョ▼鐢熸垚锛坄generate_project.py`锛夈€佹瀯寤烘湡 smoke銆佷互鍙?*鍏ㄩ儴璁℃椂鏍锋湰**鈥斺€擿test` 闃舵鎶?  `run_timed.py` 鏀捐繘瀹瑰櫒锛坄cmake_container_exec_at`锛夛紝姣忎釜 `cmake` 瀛愯繘绋嬮兘鍦ㄥ鍣ㄥ唴杩愯锛?  `docker exec` 鐨勭鐞嗗紑閿€涓嶈惤鍦ㄦ祴閲忕獥鍙ｅ唴銆?- **娓呯悊**锛歚stop` 鍦?`initialize_runtime` 涔嬪悗鍏堣皟鐢?`remove_cmake_container`锛堝箓绛夛紝瀹瑰櫒
  涓嶅瓨鍦ㄨ繑鍥?0锛夛紝鍐嶆鏌ユ槸鍚︽畫鐣欒繍琛屾爣璁般€?- **鐙珛杩愯**锛氫粛闇€鑳借闂?Docker daemon锛涘涓绘満涓嶅啀闇€瑕?CMake銆乬cc 鎴?make 鍙備笌娴嬮噺銆?
## 9. 鏁呴殰鎺掓煡

| 鐜拌薄 | 鎺掓煡 |
|---|---|
| `build` 鎶?SHA-256 涓嶅尮閰?| 妫€鏌?`/home/runner/software/cmake/` 棰勭疆鍖呮槸鍚︿笌鏈枃妗ｆ牎楠屽€间竴鑷达紱鍒犻櫎鎹熷潖缂撳瓨閲嶈瘯 |
| `build` 鎶?`cmake --version` 涓嶆槸 4.4.5 | 棰勭疆鍖呯増鏈敊璇紝鎴?`$PERF_WORK_DIR/cmake-install` 娈嬬暀鏃цВ鍖咃紱娓呯悊璇ョ洰褰曢噸璇?|
| `build` 鎶ヤ笅杞藉け璐?| 渚濇灏濊瘯瀹樻柟 `cmake.org/files`銆丟itHub Releases 涓?`PERF_CMAKE_MIRROR`锛屼篃鍙缃绾垮寘锛涙棩蹇椾細鎵撳嵃灏濊瘯杩囩殑姣忎釜 URL 涓庡け璐ュ師鍥?|
| `test` 鎶?`No CMAKE_CXX_COMPILER could be found` | Runner 缂?C++ 缂栬瘧鍣紱鏈敤渚?`build` 闃舵宸叉妸 `c++` 绾冲叆蹇呴渶鍛戒护骞惰嚜鍔ㄥ畨瑁咃紙dnf `gcc-c++` / apt `g++`锛夛紝闅忓悗鍋氭渶灏忕▼搴忕紪璇戣嚜妫€锛屾甯告儏鍐典笅涓嶄細鍦ㄦ祴閲忛樁娈靛嚭鐜?|
| `test` 鎶ョ己鏍锋湰 | 鏌ョ湅 `runs/<鍦烘櫙>/` 涓嬫槸鍚?5 涓?`rep*.json`/`rep*.log`锛涘け璐ョ殑閭ｆ娴嬮噺浼氫繚鐣欏師濮嬫棩蹇?|
| `clean_build_10000` 寰堟參 | 10,000 涓炕璇戝崟鍏冪殑鍏ㄩ噺缂栬瘧鍔犻摼鎺ユ湰韬害鍗犺鍦烘櫙缁濆ぇ閮ㄥ垎澧欓挓锛屽睘姝ｅ父锛涙鏌ョ鐩樹笌鍐呭瓨浣欓噺 |
| `upstream_build` 寰堟參 | 涓婃父 CMake 婧愮爜棣栨瀹屾暣鏋勫缓 `cmake` 鐩爣闇€瑕佹暟鍒嗛挓锛坄-j8` 涓嬫湰鏈虹害 2 鍒嗛挓锛夛紝灞炴甯革紱瀹冨彧浣滀负鍩虹嚎鏋勫缓涓€娆★紝涓嶅啀閲嶅 |
| 娴嬮噺闃舵鍑虹幇缃戠粶璁块棶 | 涓嶅簲鍙戠敓锛涙鏌ユ槸鍚︿汉涓鸿缃簡 `MAKEFLAGS`/缂栬瘧鍣ㄥ皝瑁呰剼鏈?|

## 9. 璁稿彲璇?
CMake 閲囩敤 BSD 3-Clause License锛圞itware锛夈€傛湰鐢ㄤ緥鑷甫鐨勫伐绋嬬敓鎴愬櫒銆佽鏃朵笌瑙ｆ瀽/鎶ュ憡鑴氭湰涓烘湰浠撳簱鍘熷垱锛岄伒寰粨搴撴棦鏈夎鍙€?
