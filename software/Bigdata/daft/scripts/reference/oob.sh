#!/usr/bin/env bash
# Daft 0.7.2 TPC-H 开箱测试工具。用法: bash oob.sh <setup|gen|checksum|verify|env|run|answers|pack>
# 全部配置通过环境变量传入（见 oob.env.example），执行前须 `source oob.env`。
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OOB_HOME="${OOB_HOME:-$HOME/daft_oob}"
PYTHON="${PYTHON:-python3}"
SF="${SF:-100}"
DATA_DIR="${DATA_DIR:-$OOB_HOME/tpch-data}"
ROUNDS="${ROUNDS:-4}"
VENV="$OOB_HOME/venv"
SRC="$OOB_HOME/daft-src"
DAFT_TAG="v0.7.2"

die() { echo "[oob] ERROR: $*" >&2; exit 1; }
log() { echo "[oob] $*"; }
need_tag() { [[ -n "${MACHINE_TAG:-}" ]] || die "未设置 MACHINE_TAG（取值 kp950 或 epyc9654）"; }
vpy() { "$VENV/bin/python" "$@"; }

# TPC-H 官方脚本的数据目录布局: <DATA_DIR>/<SF 保留一位小数, 点换下划线>/<分片数>/parquet
parquet_dir() {
  local sub
  sub="$("$PYTHON" -c "import math,sys; s=float(sys.argv[1]); print(f'{s:.1f}'.replace('.','_') + '/' + str(math.ceil(s)))" "$SF")"
  echo "$DATA_DIR/$sub/parquet"
}
result_dir() { echo "$OOB_HOME/results/$MACHINE_TAG/sf$SF"; }

# 开箱 = 不带任何调优变量。把 shell 里残留的 DAFT_*/RAY_* 清掉并记下来（曾因残留变量整轮结果作废）。
clean_env() {
  local leaked=()
  while read -r v; do
    [[ -z "$v" ]] && continue
    leaked+=("$v"); unset "$v"
  done < <(compgen -e | grep -E '^(DAFT_|RAY_)' || true)
  if ((${#leaked[@]})); then log "已清除残留环境变量: ${leaked[*]}"; fi
  export DAFT_PROGRESS_BAR=0
  for v in OMP_NUM_THREADS MKL_NUM_THREADS OPENBLAS_NUM_THREADS MALLOC_CONF LD_PRELOAD; do
    [[ -n "${!v:-}" ]] && log "警告：$v=${!v} 已设置，开箱测试不应设置该变量；确认后执行 unset 再运行"
  done
  return 0
}

cmd_setup() {
  "$PYTHON" -c 'import sys; assert sys.version_info >= (3, 10), sys.version' \
    || die "需要 Python >= 3.10（daft 0.7.2 的要求），用 PYTHON=/path/to/python3.10 指定"
  mkdir -p "$OOB_HOME"
  [[ -x "$VENV/bin/python" ]] || "$PYTHON" -m venv "$VENV"
  vpy -m pip install -q ${PIP_ARGS:-} -U pip || log "pip 自升级跳过（离线安装时正常）"
  vpy -m pip install ${PIP_ARGS:-} -r "$KIT_DIR/requirements.txt"
  if [[ ! -d "$SRC/.git" ]]; then
    # 只检出 benchmarking/：仓库根下的 daft/ 源码目录会遮住已安装的 wheel，导致 import daft 失败
    git -c advice.detachedHead=false clone -q --depth 1 --branch "$DAFT_TAG" --filter=blob:none --sparse \
      "${DAFT_GIT_URL:-https://github.com/Eventual-Inc/Daft.git}" "$SRC"
    git -C "$SRC" sparse-checkout set benchmarking
  fi
  [[ "$(git -C "$SRC" tag --points-at HEAD)" == *"$DAFT_TAG"* ]] || die "$SRC 不在 $DAFT_TAG"
  [[ ! -e "$SRC/daft" ]] || die "$SRC/daft 存在，会遮住 wheel；请删掉 $SRC 重新 setup"
  # v0.7.2 tag 的 q13 调用了 0.7.2 发行版里没有的 Expression.match，同一文件 q22 用的是同义的 .regexp
  local ans="$SRC/benchmarking/tpch/answers.py"
  if grep -q 'col("O_COMMENT").match(' "$ans"; then
    sed -i 's/col("O_COMMENT").match(/col("O_COMMENT").regexp(/' "$ans"
  fi
  [[ "$(grep -c 'col("O_COMMENT").regexp(' "$ans")" == 1 ]] || die "q13 补丁未生效，检查 $ans"
  git -C "$SRC" diff --stat
  (cd "$SRC" && vpy -c "import daft, ray, benchmarking.tpch.answers as a; assert daft.__version__ == '0.7.2', daft.__version__; print('daft', daft.__version__, 'ray', ray.__version__, 'answers', a.__file__)")
  log "setup OK: venv=$VENV src=$SRC"
}

cmd_gen() {
  local pq; pq="$(parquet_dir)"
  [[ ! -d "$pq" ]] || die "$pq 已存在；数据只生成一次，另一台机器使用复制的数据"
  command -v make >/dev/null && command -v gcc >/dev/null || die "生成数据需要 gcc 和 make"
  mkdir -p "$DATA_DIR"
  clean_env
  log "生成 TPC-H SF$SF 到 $DATA_DIR（dbgen 单线程，耗时随 SF 近似线性增长，可按 SF1 的耗时估算；日志 $DATA_DIR/gen_sf$SF.log）"
  (cd "$SRC" && vpy -m benchmarking.tpch.data_generation --tpch_gen_folder "$DATA_DIR" \
      --scale_factor "$SF" --generate_parquet) > "$DATA_DIR/gen_sf$SF.log" 2>&1 \
    || die "生成失败，见 $DATA_DIR/gen_sf$SF.log"
  if [[ "${KEEP_TBL:-0}" != 1 ]]; then
    find "$(dirname "$pq")" -maxdepth 1 -name '*.tbl*' -delete   # 中间 CSV 体积约为 parquet 的 3 倍
  fi
  cmd_checksum
}

cmd_checksum() {
  local pq; pq="$(parquet_dir)"
  [[ -d "$pq" ]] || die "缺少数据目录 $pq"
  (cd "$pq" && find . -type f -name '*.parquet' -print0 | sort -z \
     | xargs -0 -n 8 -P "$(nproc)" sha256sum | sort -k2) > "$pq.sha256"
  log "已写校验清单 $pq.sha256（$(wc -l < "$pq.sha256") 个文件, $(du -sh "$pq" | cut -f1)）"
}

cmd_verify() {
  local pq; pq="$(parquet_dir)"
  [[ -f "$pq.sha256" ]] || die "缺少 $pq.sha256（须随数据一并复制）"
  local n_list n_disk
  n_list="$(wc -l < "$pq.sha256")"
  n_disk="$(find "$pq" -type f -name '*.parquet' | wc -l)"
  [[ "$n_list" == "$n_disk" ]] || die "文件数不一致：清单 $n_list，磁盘 $n_disk"
  (cd "$pq" && sha256sum --quiet -c "$pq.sha256") || die "sha256 校验失败，数据与生成机不一致"
  log "数据校验通过: $n_disk 个文件与清单一致"
}

cmd_env() {
  need_tag
  local d="$OOB_HOME/results/$MACHINE_TAG/env"; mkdir -p "$d"
  run() { local f="$1"; shift; { "$@" > "$d/$f" 2>&1; } || echo "(failed: $*)" >> "$d/$f"; }
  run uname.txt uname -a
  run os-release.txt cat /etc/os-release
  run lscpu.txt lscpu
  run nproc.txt nproc
  run numactl.txt numactl -H
  run free.txt free -g
  run meminfo.txt cat /proc/meminfo
  run cmdline.txt cat /proc/cmdline
  run glibc.txt ldd --version
  run df.txt df -h "$DATA_DIR" "$OOB_HOME"
  run lsblk.txt lsblk -o NAME,SIZE,TYPE,ROTA,MODEL,MOUNTPOINT
  run ulimit.txt bash -c 'ulimit -a'
  run pip-freeze.txt "$VENV/bin/python" -m pip freeze
  run python.txt "$VENV/bin/python" -VV
  run daft-src.txt git -C "$SRC" log -1 --format='%H %cI %D'
  run daft-src-patch.txt git -C "$SRC" diff
  {
    for f in /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver \
             /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq /sys/devices/system/cpu/smt/active \
             /sys/kernel/mm/transparent_hugepage/enabled /sys/kernel/mm/transparent_hugepage/defrag \
             /proc/sys/kernel/numa_balancing; do
      printf '%s: %s\n' "$f" "$(cat "$f" 2>/dev/null || echo n/a)"
    done
    command -v tuned-adm >/dev/null && tuned-adm active
  } > "$d/kernel-knobs.txt" 2>&1 || true
  if [[ $EUID == 0 ]] && command -v dmidecode >/dev/null; then
    run dmidecode-memory.txt dmidecode -t memory
    run dmidecode-processor.txt dmidecode -t processor
    run dmidecode-system.txt dmidecode -t system -t bios
  else
    echo "非 root 或无 dmidecode：内存条型号/频率/通道数请手工补到报告" > "$d/dmidecode-skipped.txt"
  fi
  env | grep -E '^(DAFT_|RAY_|OMP_|MKL_|OPENBLAS_|MALLOC_|LD_PRELOAD)' > "$d/perf-env-vars.txt" || true
  log "环境信息已写入 $d"
}

cmd_run() {
  need_tag
  local runner="${1:-native}"
  [[ "$runner" == native || "$runner" == ray ]] || die "runner 只能是 native 或 ray"
  local pq out; pq="$(parquet_dir)"; out="$(result_dir)/$runner"
  [[ -f "$pq.sha256" ]] || die "缺少校验清单 $pq.sha256；须先执行 gen，或复制数据后执行 verify"
  [[ ! -e "$out/timings.jsonl" || "${FORCE:-0}" == 1 ]] || die "$out 已有结果；重测前须重命名该目录，或设置 FORCE=1 覆盖"
  rm -rf "$out"; mkdir -p "$out"
  clean_env
  if [[ "$runner" == ray ]] && "$VENV/bin/ray" status >/dev/null 2>&1; then
    die "检测到正在运行的 Ray 集群（ray.init() 会接入该集群）；须先执行 $VENV/bin/ray stop --force"
  fi
  local busy; busy="$(ps -eo pcpu= | awk '{s+=$1} END {printf "%d", s}')"
  log "当前全部进程 CPU 占用合计约 ${busy}%（应接近 0；存在其他负载时须先停止）"
  log "runner=$runner SF=$SF rounds=$ROUNDS -> $out"
  local timer=()
  if [[ -x /usr/bin/time ]]; then timer=(/usr/bin/time -v -o "$out/time-v.txt"); else log "无 /usr/bin/time，峰值内存不记录"; fi
  # 整机已用内存采样（ray 的 worker 是独立进程，time -v 只看得到 driver）
  ( while :; do echo "$(date +%s) $(free -m | awk '/^Mem:/{print $3}')"; sleep 2; done ) > "$out/mem_used_mb.log" &
  local sampler=$!
  (cd "$SRC" && DAFT_RUNNER="$runner" ${timer[@]+"${timer[@]}"} "$VENV/bin/python" "$KIT_DIR/tpch_driver.py" \
      --parquet "$pq" --out "$out" --rounds "$ROUNDS") 2>&1 | tee "$out/run.log"
  local rc="${PIPESTATUS[0]}"
  kill "$sampler" 2>/dev/null || true
  [[ "$runner" == ray ]] && "$VENV/bin/ray" stop --force >/dev/null 2>&1 || true
  [[ "$rc" == 0 ]] || die "存在失败的查询（rc=$rc），详见 $out/run.log 及 timings.jsonl 的 error 字段"
  log "完成: $out/timings.jsonl"
}

cmd_answers() {
  need_tag
  local pq out; pq="$(parquet_dir)"; out="$(result_dir)"
  clean_env
  (cd "$SRC" && DAFT_RUNNER=native "$VENV/bin/python" "$KIT_DIR/tpch_driver.py" \
      --mode answers --parquet "$pq" --out "$out") 2>&1 | tee "$out/answers.log"
  [[ "${PIPESTATUS[0]}" == 0 ]] || die "存在导出失败的查询结果，详见 $out/answers.log"
}

cmd_pack() {
  need_tag
  local t="$OOB_HOME/oob_${MACHINE_TAG}_sf${SF}_$(date +%Y%m%d_%H%M).tar.gz"
  cp "$(parquet_dir).sha256" "$OOB_HOME/results/$MACHINE_TAG/" 2>/dev/null || true
  tar -C "$OOB_HOME/results" -czf "$t" "$MACHINE_TAG"
  log "结果包: $t ($(du -h "$t" | cut -f1))"
}

case "${1:-}" in
  setup) cmd_setup ;;
  gen) cmd_gen ;;
  checksum) cmd_checksum ;;
  verify) cmd_verify ;;
  env) cmd_env ;;
  run) shift; cmd_run "$@" ;;
  answers) cmd_answers ;;
  pack) cmd_pack ;;
  *) echo "用法: bash oob.sh <setup|gen|checksum|verify|env|run [native|ray]|answers|pack>"; exit 2 ;;
esac
