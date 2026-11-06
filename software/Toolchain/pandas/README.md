# pandas performance case

This case measures the **upstream pandas asv benchmark suite** of the pinned
release on the BoostKit Runner. The workload, the dependency versions and the
Python interpreter are fixed, the measurement itself is offline, and every raw
sample is kept next to the published metrics.

## 1. Pinned inputs

| Input | Pinned value | Verification |
| --- | --- | --- |
| pandas | `3.1.0` | `actual-version.txt` must equal the requested version |
| pandas sdist | `pandas-3.1.0.tar.gz` (provenance only) | `sha256 ecb9b2d8a817b1e1ba1fdb90c0abe9eab31b4fdf2562b7a56b86ac66ace17e49`, 5,933,421 bytes |
| Runtime wheels | `requirements.lock` (`numpy 2.0.2`, `python-dateutil 2.9.0.post0`, `six 1.17.0`, `pandas 3.1.0`) | installed with `pip --require-hashes`; the lock carries the Linux `x86_64` and `aarch64` wheel hashes |
| CPython | `3.12.16`, built from the official source archive | `sha256 710c3e75dac8b2f258d9cd0f76e5c4c2e9175fac9e249c98901552f7cf33b7dd`, 27,310,261 bytes |
| asv benchmark snapshot | pandas `v3.1.0`, commit `c6f46769b808eb60218189d089dd67841b44f1b9` | `asv_bench/` is vendored byte-identically; `sha256sum -c asv_bench/manifest.sha256` runs before the build and again before the measurement |
| Parameter combinations | one fixed class/params/method per scenario | enforced by `fixtures/scenarios.json` and re-checked by `scripts/results/parse_benchmark.py` |
| Samples | 1 warm-up + `PERF_REPS` samples (default 5) | one isolated process per sample |
| Threads | single threaded (`OMP/OPENBLAS/MKL/NUMEXPR/VECLIB/BLIS_NUM_THREADS=1`, `OMP_DYNAMIC=false`) | exported by the test stage and echoed by the sample evidence |
| Random seed | `1234` (`numpy.random.seed`) | sample evidence and `parameters.measurement.seed` |
| Network during measurement | offline (proxies point at `127.0.0.1:9`, all data is generated locally) | exported by the test stage and recorded in the result metadata |

pandas 3.1.0 requires Python >= 3.11 and numpy >= 2.0.2, so the runtime pins
CPython 3.12.16 plus numpy 2.0.2, matching the ABI of the published wheels.

## 2. Offline layout

The Runner gets this directory pre-populated; the build stage prefers it and
only falls back to the mirrors when an artifact is missing:

```
/home/runner/software/pandas/
├── Python-3.12.16.tgz             # sha256 710c3e75…f33b7dd
├── pandas-3.1.0.tar.gz            # sha256 ecb9b2d8…c17e49 (provenance)
└── wheels/
    ├── numpy-2.0.2-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
    ├── numpy-2.0.2-cp312-cp312-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
    ├── pandas-3.1.0-cp312-cp312-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl
    ├── pandas-3.1.0-cp312-cp312-manylinux_2_24_aarch64.manylinux_2_28_aarch64.whl
    ├── python_dateutil-2.9.0.post0-py2.py3-none-any.whl
    └── six-1.17.0-py2.py3-none-any.whl
```

`PERF_PANDAS_OFFLINE_DIR` overrides the directory. When it is incomplete the
build stage downloads the pinned wheels through TUNA, Huawei Cloud, Aliyun and
finally the public PyPI index, and the CPython source through the Huawei Cloud,
Aliyun, Nanjing University and python.org mirrors. Every source must deliver the
same SHA-256; if all of them fail the build stage returns 30 and prints every
URL it tried.

## 3. Scenarios

`fixtures/scenarios.json` selects nine cases from the upstream
`asv_bench/benchmarks` package. Each scenario reuses the upstream
class/params/method and only replaces the asv auto-scaled repeat with a pinned
iteration count (one sample = 10% warm-up iterations + `iterations` timed calls,
published wall = batch seconds / iterations) and a fixed random seed. The
excluded cases and the reasons are listed under `selection` in that file.

| Scenario | Module.class.method | Params | Iterations/sample | Subsystem | Correctness gate |
| --- | --- | --- | --- | --- | --- |
| `groupby_sort_high_cardinality` | `groupby.SortHighCardinality.time_sum` | `sort=True` | 10 | groupby | grouped sum total == frame total |
| `groupby_int64_overflow` | `groupby.Int64.time_overflow` | – | 8 | groupby | max of grouped maxima == ungrouped maxima |
| `join_single_key` | `join_merge.Join.time_join_dataframe_index_single_key_bigger` | `sort=True` | 130 | join | row count == left frame rows, columns complete |
| `merge_asof_int` | `join_merge.MergeAsof.time_on_int` | `direction="backward"`, `tolerance=None` | 240 | join | row count == left frame rows, time key stays sorted |
| `stat_ops_frame_skew` | `stat_ops.FrameOps.time_op` | `op="skew"`, `dtype="float"`, `axis=0` | 1800 | statistics | four finite per-column values |
| `rolling_mean_window` | `rolling.Methods.time_method` | `DataFrame`, `rolling(window=1000)`, `float`, `mean` | 1100 | rolling | last value matches the numpy window mean |
| `drop_duplicates_int` | `reindex.DropDuplicates.time_frame_drop_dups_int` | `inplace=False` | 220 | deduplication | row count == number of distinct keys |
| `reshape_unstack` | `reshape.SimpleReshape.time_unstack` | – | 1100 | reshape | 100×400 shape, no missing cells, sampled cells match the source |
| `strings_upper` | `strings.Methods.time_upper` | `dtype="str"` | 800 | strings | result equals the Python `upper()` reference |

## 4. Stages and exit codes

The Framework drives the six stages (`python3 framework/run_case.py ... --stage ...`):

| Stage | Function | Failure exit code | Purpose |
| --- | --- | --- | --- |
| prepare | Framework built-in | – | records the system and pre-run runtime information |
| build | `build_pandas` | 30 | builds CPython, creates the private venv, installs the hash-locked runtime, verifies the benchmark snapshot and prefetches every scenario |
| start | `start_pandas_runtime` | 40 | verifies the runtime versions, the snapshot manifest and the scenario count |
| test | `run_pandas_benchmarks` | 50 | runs warm-up + `PERF_REPS` samples per scenario and parses them strictly |
| stop | `stop_pandas_runtime` | 50 | terminates leftover processes of this case |
| finalize | Framework built-in | 60 | normalizes the metrics and writes `report.md` / `status.json` |

The `optimized` variant is reserved: with `PERF_VARIANT=optimized` the build
stage returns 30 immediately and writes no `build_variant.json`, so a reserved
variant can never look like a successful build.

## 5. Artifacts and validation

Every run writes to `.perf-output/Toolchain/pandas/<version>/<arch>/<run_id>/`:

- `build_variant.json`: Python/venv/runtime wheel hashes/sdist/asv snapshot/measurement protocol
  (the Framework writes `build_info.json` itself).
- `results.json`: 18 metrics (9 scenarios × wall time and peak RSS) plus the full
  sample statistics (median/mean/min/max/stdev).
- `runs/<scenario>/{warmup.log,warmup.json,rep<i>.log,rep<i>.json}`: raw logs and
  the timing JSON of every sample.

`scripts/results/parse_benchmark.py` is the only component that can declare the
measurement successful. It rejects:

- missing or extra scenario directories/sample files, a sample count different
  from `PERF_REPS`;
- timed-out samples, non-zero exits, or a timeout budget that differs from the
  agreed one;
- runtime version drift (Python/pandas/numpy/python-dateutil versus the build
  record);
- a modified vendored benchmark file or a missing referenced module;
- class/params/method/iterations/threads different from the pinned values;
- a missing evidence line, an inconsistent batch-versus-per-call duration, or a
  batch duration outside the sanity window;
- a failed correctness gate, or data shapes that differ between samples.

On failure the test stage returns 50 and prints the last 40 lines of
`measurement.log` to stdout.

## 6. Metric semantics

- `<scenario>.wall_seconds`: duration of one `time_*` call
  (`batch_seconds / iterations`), the median over the `PERF_REPS` isolated
  process samples. The internal timer is `time.perf_counter()`; dataset
  construction (`setup`/`setup_cache`) and the correctness verification stay
  outside the timed window.
- `<scenario>.peak_rss_mib`: peak RSS of the sample process (`getrusage`),
  again the median over the samples.

Both metrics are `lower_is_better`. The semantics of the upstream `time_*`
methods (which calls they include) are unchanged; the case only pins the
iteration count and the generated data so every run and both architectures
execute exactly the same work.

## 7. Determinism and cross-architecture comparability

- Every sample process calls `numpy.random.seed(1234)` right after importing the
  benchmark module, so the `setup` datasets are element-wise identical across
  runs and architectures; the legacy numpy `RandomState` stream does not depend
  on the architecture.
- Runtime wheels, the CPython source archive and the asv snapshot are all pinned
  by SHA-256, and `parameters` in `results.json` contains only
  architecture-neutral values (versions, repository, commit, iterations,
  threads, seed) — no host name, path or timestamp.
- A pinned iteration count keeps the batch duration in the same one-second range
  on both architectures, so result comparison is not distorted by asv's
  auto-scaling.

## 8. Local validation

```bash
SOFTWARE_VERSION=3.1.0 PERF_REPS=1 PERF_BUILD_JOBS=4 \
  python3 framework/run_case.py --case software/Toolchain/pandas/case.yaml \
  --version 3.1.0 --architecture x86_64 --run-id local-pandas --stage prepare
# then build / start / test / stop / finalize

# Standalone entry point (equivalent to the six stages):
SOFTWARE_VERSION=3.1.0 PERF_REPS=1 PERF_BUILD_JOBS=4 \
  bash software/Toolchain/pandas/pandas_test.sh --results-dir /tmp/pandas-run
```

Negative check for the reserved variant:

```bash
PERF_VARIANT=optimized python3 framework/run_case.py \
  --case software/Toolchain/pandas/case.yaml --version 3.1.0 \
  --architecture x86_64 --run-id local-pandas-neg --stage build
# expects exit code 30 and no build_variant.json in the output directory
```

## 9. Containerised execution

The case runs every stage inside a private openEuler 24.03 LTS SP4 container
(`scripts/common.sh`, region `container-runtime`); the host only keeps Docker,
the download/verification tooling, the Framework and the strict result parser.

| Item | Value |
| --- | --- |
| Image | `openEuler-docker.x86_64.tar.xz` from the local archive directory `/home/runner/software/openEuler-24.03-LTS-SP4` (downloaded from `repo.openeuler.org` only when the archive is absent, then verified against its `.sha256sum`), loaded and checked for the expected architecture and `/etc/os-release` |
| Container name | `boostkit-pandas-<arch>-<run-id>` |
| Labels | `boostkit.pandas.run-id=<run-id>` — a container with a different label is never removed |
| Mounts | `${PERF_WORK_DIR}` (build tree, virtual environment, fixtures, wheelhouse), `${RESULTS_DIR}` (timings and logs), the case directory (read-only unless the standalone entry point keeps results inside it), `/etc/passwd` and `/etc/group` (read-only) |
| Network | host network; package installation uses dnf with the Huawei openEuler mirror switch, the measurement itself runs offline |
| Host responsibilities | image archive download + SHA-256 verification, source/wheel download and verification, result parsing, Framework integration |
| Container responsibilities | dnf package installation (`gcc`, `make`, `zlib-devel`, `libffi-devel`, `openssl-devel`, `bzip2-devel`, `xz-devel`, ...), CPython build, private venv + pip install (with `HOME=${PERF_WORK_DIR}/home`), asv benchmark staging, the measured process tree |
| Cleanup | `stop_pandas_runtime` removes the container first, then scans for host-side leftovers; both operations are idempotent |

Every in-container dnf install uses `--setopt=install_weak_deps=False`: the container mounts `/etc/passwd` and `/etc/group` read-only, so a weak dependency whose rpm scriptlet calls `groupadd`/`useradd` would fail and make dnf exit non-zero.

The measured command is executed with `pandas_container_exec_at`, so
`docker exec` never sits inside the timing window; the BLAS/OpenMP thread pools,
locale, timezone and offline proxies listed in `PANDAS_MEASUREMENT_ENV` are
passed explicitly to the in-container process.  The container image and the
run-id label are recorded in the run context, not in the cross-architecture
`parameters` set.  The standalone entry point (`pandas_test.sh`) needs an
accessible Docker daemon as well; without one the build stage exits 30.

## 10. Known limitations

- The upstream pandas asv suite contains many cases that need extra
  dependencies (pyarrow, numba, numexpr, openpyxl, SQLAlchemy, ...) or spend tens
  of seconds loading data. This case keeps nine stable scenarios that only need
  pandas and numpy and generate their data locally; the exclusions are listed per
  case in `fixtures/scenarios.json`.
- Some scenarios execute a sub-millisecond call, so the iteration count is large
  (up to 1800) and one batch lasts about a second; this keeps process start-up
  and scheduler noise out of the per-call value.
- On a shared Runner other build jobs can inflate timings by 1.3–2×; a dedicated
  CI Runner should be more stable.
