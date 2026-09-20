#!/usr/bin/env bash
# =============================================================================
# sonic_bench.sh —— sonic 库 parser/encoder/decoder 基准测试（stage4 性能用例）
# stage4-test/scripts/go/ 用例脚本，由 test.sh 驱动（参数以 --key value 传入）。
#
# 测试对象（3 类，环境变量控制测试模式，模式名仅用于结果标识）：
#   encoder/decoder（6 种模式组合，两类共用同一张环境变量表）：
#     DYN+JIT : SONIC_USE_SVE_WRAPGOC=1 SONIC_USE_SVE_LINKNAME=0 SONIC_ENCODER_USE_VM=""
#     SVE+JIT : SONIC_USE_SVE_WRAPGOC=0 SONIC_USE_SVE_LINKNAME=1 SONIC_ENCODER_USE_VM=""
#     NEON+JIT: SONIC_USE_SVE_WRAPGOC=0 SONIC_USE_SVE_LINKNAME=0 SONIC_ENCODER_USE_VM=""
#     DYN+VM  : SONIC_USE_SVE_WRAPGOC=1 SONIC_USE_SVE_LINKNAME=0 SONIC_ENCODER_USE_VM=1
#     SVE+VM  : SONIC_USE_SVE_WRAPGOC=0 SONIC_USE_SVE_LINKNAME=1 SONIC_ENCODER_USE_VM=1
#     NEON+VM : SONIC_USE_SVE_WRAPGOC=0 SONIC_USE_SVE_LINKNAME=0 SONIC_ENCODER_USE_VM=1
#     bench 包：encoder → ./encoder、decoder → ./decoder（公共 API 包，各 12 个
#     Benchmark<Type>_{Generic,Binding,Parallel}_{Sonic,Sonic_Fast,StdLib}）；
#     bench: -run=^$ -benchmem -benchtime=5s -bench "^(BenchmarkEncoder_.*)$"
#            （decoder 同理，首字母大写由 sonic_type 生成）。
#     注意：v1.15.2 中不存在 JsonLarge/JsonSmall 数据集，这两个包的基准固定
#     用 TwitterJson（encoder|decoder/testdata_test.go）；跨库对比包
#     external_jsonlib_test/benchmark_test 里也没有 Sonic 的 encoder/decoder 基准，
#     故数据集维度以实际存在的基准为准。
#   parser（3 种模式）：
#     DYN: WRAPGOC=1 LINKNAME=0 / SVE: WRAPGOC=0 LINKNAME=1 / NEON: WRAPGOC=0 LINKNAME=0
#     bench 包 ./internal/native（自带子基准 BenchmarkParseWithPadding/{Complex,
#     Medium} 与 BenchmarkGetByPath）：-run=^$ -benchmem -benchtime=5s -bench=.
#
# 维度说明：SONIC_* 是运行时开关（internal/native/dispatch_arm64.go init、
#   internal/encoder/vars/const.go，os.Getenv 读取），模式间编译产物相同、仅执行
#   路径不同；goexperiment/goarm64/gcflags/ldflags 才是构建期维度。
#   SVE/DYN/NEON 分派仅存在于 arm64（dispatch_arm64.go）；x86_64 上这些开关
#   不被读取，各模式执行同一条 amd64 路径——双架构跑同一模式矩阵是为了指标
#   集合可比，不代表 x86_64 上模式间存在实现差异。
#   环境注入统一走 env 命令前缀且未传即显式置空（GOEXPERIMENT/GOARM64），脚本
#   不受测试机这两项全局残留影响；GOFLAGS 继承全局环境（调用方按需设置）；
#   SONIC_NO_ASYNC_GC=1 固定注入（关闭后台 GC 循环，降噪）。
#
# 每个模式执行前先 go clean -testcache（用户约定：不同测试之间清测试缓存）。
# 固定注入 SONIC_NO_ASYNC_GC=1：关闭 sonic 部分测试包 TestMain 默认启动的后台
#   runtime.GC() 循环 goroutine（持续消耗 CPU 干扰基准），与 sonic 官方跑法一致
#   （internal/native/dispatch_test.go 自带的示例命令同样带此开关）。
#
# 用法：
#   bash sonic_bench.sh --toolchain <target> [--sonic_dir <path>]
#        [--encoder_pkg ./encoder] [--decoder_pkg ./decoder]
#        [--parser_pkg ./internal/native]
#        [--goexperiment "a,b"] [--goarm64 v9.0]
#        [--gcflags "all=-N -l"] [--ldflags "-s"] --result <json>
#
#   --toolchain    工具链 target 名（$BIN_DIR/<target>，须含 bin/go）
#   --sonic_dir    sonic 源码目录（默认 $OBJECTS/go/src/sonic；go test 产物只进
#                  构建缓存，不写源码树）
#   --encoder_pkg / --decoder_pkg / --parser_pkg
#                  三类 subject 的 bench 包路径（默认 ./encoder、./decoder、
#                  ./internal/native，从 sonic_dir 起）
#   --goexperiment / --goarm64 / --gcflags / --ldflags
#                  go test 构建期生效的开关：前两者经 env 命令前缀注入
#                  （env GOEXPERIMENT=<值> GOARM64=<值> go test ...，作用域仅
#                  该条命令，不经 export）；未传时同样显式置空——屏蔽全局环境
#                  残留，置空等价于未设置，go 回落到工具链烘焙默认（zbootstrap.go）。
#                  后两者按 go test 惯用法直接作为命令行 flag 追加
#                  （-gcflags=<值> / -ldflags=<值>，值作为一个 argv 元素传递，
#                  可含空格，如 "all=-N -l"；不经 GOFLAGS 环境变量）。
#                  普通 go test 不重链 pkg/tool，任何组合都不会污染工具链
#                  （与 run.bash -rebuild 的 dist 路径不同）。
#   --result       结果 JSON 输出路径（test.sh 固定追加）
#
# 输出 JSON（必含 date）：{cell_id, date, type:"bent", toolchain_id,
#   toolchain_version, test_cmd, env:{host,cpu_bind,goexperiment,goarm64,gcflags,
#   ldflags,sonic_no_async_gc,sonic_dir,encoder_pkg,decoder_pkg,parser_pkg}, runs:[{subject,mode,exit_code,bench_count,
#   duration_sec,raw_log}], results:[{subject,mode,benchmark,iterations,ns_per_op,
#   bytes_per_op,allocs_per_op}], duration_sec, exit_code}
#   原始输出逐模式落 $RESULTS/logs/<用例名>/sonic-bench-<subject>-<mode>.raw.log
#   （<用例名>由 --result 文件名派生，同一 run 目录多个 sonic 用例互不覆写）。
#
# 说明：退出码恒为 0（脚本自身执行成功；各模式的成败与 go test 退出码由 JSON
#   的 runs[].exit_code 表达，某模式失败继续其余模式）。
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib_cpu.sh
source "$SCRIPT_DIR/../lib_cpu.sh"
# shellcheck source=../lib_gocache.sh
source "$SCRIPT_DIR/../lib_gocache.sh"

BENCHTIME="5s"

# ---- 参数解析 ----
TOOLCHAIN_TARGET="tc-default"
SONIC_DIR=""
ENCODER_PKG="./encoder"
DECODER_PKG="./decoder"
PARSER_PKG="./internal/native"
GOEXPERIMENT_ARG=""
GOARM64_ARG=""
GCFLAGS_ARGS=()
LDFLAGS_ARGS=()
RESULT_JSON=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --toolchain)     TOOLCHAIN_TARGET="$2"; shift 2 ;;
    --sonic_dir)     SONIC_DIR="$2"; shift 2 ;;
    --encoder_pkg)   ENCODER_PKG="$2"; shift 2 ;;
    --decoder_pkg)   DECODER_PKG="$2"; shift 2 ;;
    --parser_pkg)    PARSER_PKG="$2"; shift 2 ;;
    --goexperiment)  GOEXPERIMENT_ARG="$2"; shift 2 ;;
    --goarm64)       GOARM64_ARG="$2"; shift 2 ;;
    --gcflags)       GCFLAGS_ARGS+=("$2"); shift 2 ;;
    --ldflags)       LDFLAGS_ARGS+=("$2"); shift 2 ;;
    --result)        RESULT_JSON="$2"; shift 2 ;;
    *) echo "[sonic] 未知参数: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$RESULT_JSON" ]] || { echo "[sonic] 缺少 --result <json>" >&2; exit 1; }

# ---- 路径与工具链 ----
BIN_DIR="${BIN_DIR:-${OBJECTS:-$HOME/tmp/objects}/go/bin}"
TOOLCHAIN="$BIN_DIR/$TOOLCHAIN_TARGET"
GO_BIN="$TOOLCHAIN/bin/go"
[[ -x "$GO_BIN" ]] || { echo "[sonic] no go binary at ${GO_BIN}（先跑 stage3-build）" >&2; exit 1; }
SONIC_DIR="${SONIC_DIR:-${OBJECTS:-$HOME/tmp/objects}/go/src/sonic}"
[[ -d "$SONIC_DIR" ]] || { echo "[sonic] sonic 源码目录不存在: ${SONIC_DIR}（先经 stage2 就位）" >&2; exit 1; }
# 每工具链独立 GOCACHE：避免不同工具链之间构建缓存互相污染
setup_gocache "$TOOLCHAIN_TARGET"
for _pkg in "$ENCODER_PKG" "$DECODER_PKG" "$PARSER_PKG"; do
  [[ -d "$SONIC_DIR/$_pkg" || -f "$SONIC_DIR/$_pkg" ]] || {
    echo "[sonic] bench 包不存在: ${SONIC_DIR}/${_pkg}（用 --encoder_pkg/--decoder_pkg/--parser_pkg 指定实际位置）" >&2; exit 1; }
done
unset _pkg

META="$TOOLCHAIN/toolchain_meta.json"
TOOLCHAIN_ID="$([ -f "$META" ] && sed -n 's/.*"toolchain_id": "\([^"]*\)".*/\1/p' "$META" || basename "$TOOLCHAIN")"
TOOLCHAIN_VER="$("$GO_BIN" version 2>/dev/null || echo unknown)"
DATE="$(date +%Y-%m-%d 2>/dev/null || echo unknown)"

# ---- 构建期开关描述（goexperiment/goarm64 走环境变量，gcflags/ldflags 走命令行）----
SWITCH_DESC=""
[[ -n "$GOEXPERIMENT_ARG" ]] && SWITCH_DESC+="GOEXPERIMENT=$GOEXPERIMENT_ARG "
[[ -n "$GOARM64_ARG" ]]      && SWITCH_DESC+="GOARM64=$GOARM64_ARG "
for _g in "${GCFLAGS_ARGS[@]}"; do SWITCH_DESC+="-gcflags='${_g}' "; done
for _l in "${LDFLAGS_ARGS[@]}"; do SWITCH_DESC+="-ldflags='${_l}' "; done

RESULTS="${RESULTS:-${WORKDIR:-$HOME/tmp}/results}"
mkdir -p "$RESULTS/logs"
# 本用例的 raw log 子目录（由 --result 文件名派生，如 result-sonic-x.json → sonic-x）：
# 同一 run 目录多个 sonic 用例先后跑时互不覆写
RESULT_TAG="$(basename "$RESULT_JSON" .json)"; RESULT_TAG="${RESULT_TAG#result-}"
mkdir -p "$RESULTS/logs/$RESULT_TAG"
# 中间产物：runs 元信息与 bench 行（TSV，最后由 python3 汇成 JSON）
RUNS_TSV="$(mktemp)"; ROWS_TSV="$(mktemp)"
trap 'rm -f "$RUNS_TSV" "$ROWS_TSV"' EXIT
: > "$RUNS_TSV"; : > "$ROWS_TSV"

# ---- 单模式执行：$1=subject $2=mode $3=WRAPGOC $4=LINKNAME $5=USE_VM
#      $6=bench 正则（为空则 -bench=.）$7=包路径 ----
run_one() {
  local subject="$1" mode="$2" wg="$3" ln="$4" vm="$5" bench_re="$6" pkg="$7"
  local raw_log="$RESULTS/logs/$RESULT_TAG/sonic-bench-${subject}-${mode}.raw.log"
  echo "[sonic] ${subject} [${mode}]: WRAPGOC=${wg} LINKNAME=${ln} USE_VM=${vm} GOEXP=${GOEXPERIMENT_ARG:-<烘焙默认>} GOARM64=${GOARM64_ARG:-<烘焙默认>} pkg=${pkg}" >&2
  # 用户约定：不同测试之间清测试缓存
  "$GO_BIN" clean -testcache
  local t0 t1 rc
  t0="$(date +%s)"
  set +e
  (
    cd "$SONIC_DIR"
    # go test 惯用法：构建期开关直接作命令行 flag 追加。-gcflags/-ldflags 的值
    # （可含空格，如 all=-N -l）作为一个 argv 元素传递，不经 GOFLAGS 环境变量
    local -a goargs=(test -run='^$' -benchmem -benchtime="$BENCHTIME")
    if [[ -n "$bench_re" ]]; then goargs+=(-bench="$bench_re"); else goargs+=(-bench=.); fi
    for _g in "${GCFLAGS_ARGS[@]}"; do goargs+=("-gcflags=${_g}"); done
    for _l in "${LDFLAGS_ARGS[@]}"; do goargs+=("-ldflags=${_l}"); done
    goargs+=("$pkg")
    # 环境变量一律经 env 命令前缀注入，作用域仅这条命令（不经 export）：
    #   GOEXPERIMENT/GOARM64 未传时显式置空——屏蔽全局环境残留；置空等价于
    #     未设置，go 回落到工具链烘焙默认（zbootstrap.go）
    #   GOFLAGS 不在此列，继承全局环境（如需全局 flag 由调用方设置）
    #   GOTOOLCHAIN=local 禁止 go.mod 的 go/toolchain 版本触发自动下载官方工具链
    #   SONIC_NO_ASYNC_GC=1 固定关闭测试包 TestMain 的后台 GC 循环（降噪）
    #   SONIC_USE_* 为 sonic 模式开关（运行时分派，见文件头注释）
    run_pinned env \
      GOEXPERIMENT="$GOEXPERIMENT_ARG" GOARM64="$GOARM64_ARG"  \
      GOTOOLCHAIN=local SONIC_NO_ASYNC_GC=1 \
      SONIC_USE_SVE_WRAPGOC="$wg" SONIC_USE_SVE_LINKNAME="$ln" SONIC_ENCODER_USE_VM="$vm" \
      "$GO_BIN" "${goargs[@]}"
  ) > "$raw_log" 2>&1
  rc=$?
  set -e
  t1="$(date +%s)"
  # 解析 bench 行：Benchmark<Name>-<GOMAXPROCS>  iters  N ns/op  [B B/op  A allocs/op]
  local count
  count="$(awk -v s="$subject" -v m="$mode" '
    /^Benchmark/ && /ns\/op/ {
      name=$1; sub(/-[0-9]+$/, "", name)
      b=""; a=""
      for (i=4; i<NF; i++) {
        if ($(i+1)=="B/op") b=$(i)
        if ($(i+1)=="allocs/op") a=$(i)
      }
      printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", s, m, name, $2, $3, b, a
    }' "$raw_log" | tee -a "$ROWS_TSV" | wc -l)"
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$subject" "$mode" "$rc" "$count" "$((t1-t0))" "$raw_log" >> "$RUNS_TSV"
  echo "[sonic] ${subject} [${mode}]: exit=${rc} benchmarks=${count} 耗时$((t1-t0))s（详见 ${raw_log}）" >&2
}

START="$(date +%s)"

# ---- encoder / decoder：6 种模式组合（环境变量表见文件头注释）----
for subject in encoder decoder; do
  CAP="$(printf '%s' "${subject:0:1}" | tr 'a-z' 'A-Z')${subject:1}"
  BENCH_RE="^(Benchmark${CAP}_.*)\$"
  pkg="$ENCODER_PKG"
  if [[ "$subject" == "decoder" ]]; then pkg="$DECODER_PKG"; fi
  for m in "DYN+JIT:1:0:" "SVE+JIT:0:1:" "NEON+JIT:0:0:" \
           "DYN+VM:1:0:1"  "SVE+VM:0:1:1"  "NEON+VM:0:0:1"; do
    IFS=: read -r name wg ln vm <<<"$m"
    run_one "$subject" "$name" "$wg" "$ln" "$vm" "$BENCH_RE" "$pkg"
  done
done

# ---- parser：3 种模式（NEON=全 0，语义与 encoder 表的显式关闭一致）----
for m in "DYN:1:0:" "SVE:0:1:" "NEON:0:0:"; do
  IFS=: read -r name wg ln vm <<<"$m"
  run_one "parser" "$name" "$wg" "$ln" "$vm" "" "$PARSER_PKG"
done

END="$(date +%s)"

# ---- 汇总 JSON：先写骨架（heredoc），再由 python3 合并 runs/results ----
json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
GCFLAGS_STR=""
for _g in "${GCFLAGS_ARGS[@]}"; do GCFLAGS_STR="${GCFLAGS_STR}${GCFLAGS_STR:+ }${_g}"; done
LDFLAGS_STR=""
for _l in "${LDFLAGS_ARGS[@]}"; do LDFLAGS_STR="${LDFLAGS_STR}${LDFLAGS_STR:+ }${_l}"; done
cat > "$RESULT_JSON.partial" <<EOF
{
  "cell_id": "sonic-bench-$TOOLCHAIN_ID",
  "date": "$DATE",
  "type": "bent",
  "toolchain_id": "$TOOLCHAIN_ID",
  "toolchain_target": "$TOOLCHAIN_TARGET",
  "toolchain_version": "$(json_escape "$TOOLCHAIN_VER")",
  "runner": "go test -bench (sonic parser/encoder/decoder)",
  "test_cmd": "cd $SONIC_DIR && $(json_escape "$SWITCH_DESC")go test -run=^$ -benchmem -benchtime=$BENCHTIME （encoder × 6 模式 @ ${ENCODER_PKG} + decoder × 6 模式 @ ${DECODER_PKG} + parser × 3 模式 @ ${PARSER_PKG}；模式经 SONIC_USE_SVE_WRAPGOC/LINKNAME、SONIC_ENCODER_USE_VM 控制，SONIC_NO_ASYNC_GC=1 固定关闭后台 GC 循环）",
  "benchtime": "$BENCHTIME",
  "duration_sec": $((END - START)),
  "env": {"host": "$(hostname 2>/dev/null || echo unknown)", "cpu_bind": "$(cpu_bind_desc)",
    "goexperiment": "$(json_escape "$GOEXPERIMENT_ARG")",
    "goarm64": "$(json_escape "$GOARM64_ARG")",
    "gcflags": "$(json_escape "$GCFLAGS_STR")",
    "ldflags": "$(json_escape "$LDFLAGS_STR")",
    "sonic_no_async_gc": "1",
    "gocache": "$(json_escape "$(gocache_desc)")",
    "sonic_dir": "$SONIC_DIR", "encoder_pkg": "$ENCODER_PKG",
    "decoder_pkg": "$DECODER_PKG", "parser_pkg": "$PARSER_PKG"}
}
EOF

python3 - "$RESULT_JSON" "$RUNS_TSV" "$ROWS_TSV" <<'PYEOF'
import csv, json, os, sys

result_json, runs_tsv, rows_tsv = sys.argv[1:4]

with open(runs_tsv) as f:
    runs = [dict(zip(("subject", "mode", "exit_code", "bench_count",
                      "duration_sec", "raw_log"), r))
            for r in csv.reader(f, delimiter="\t") if r]
with open(rows_tsv) as f:
    rows = [dict(zip(("subject", "mode", "benchmark", "iterations", "ns_per_op",
                      "bytes_per_op", "allocs_per_op"), r))
            for r in csv.reader(f, delimiter="\t") if r]

for r in runs:
    for k in ("exit_code", "bench_count", "duration_sec"):
        r[k] = int(r[k])
for r in rows:
    r["iterations"] = int(r["iterations"])
    r["ns_per_op"] = float(r["ns_per_op"])
    for k in ("bytes_per_op", "allocs_per_op"):
        if r[k].isdigit():
            r[k] = int(r[k])

doc = json.load(open(result_json + ".partial"))
doc["runs"] = runs
doc["results"] = rows
doc["exit_code"] = max([r["exit_code"] for r in runs] or [0])
json.dump(doc, open(result_json, "w"), indent=2, ensure_ascii=False)
os.remove(result_json + ".partial")
PYEOF

echo "[sonic] 完成：runs=$(wc -l < "$RUNS_TSV") bench_rows=$(wc -l < "$ROWS_TSV") -> $RESULT_JSON" >&2
exit 0
