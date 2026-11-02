# bcrypt 6.0.0 performance case

This case measures the **pinned node.bcrypt.js 6.0.0** native module with the
representative load from its release manual: cost=10 hashing and comparison of a
fixed password, executed single threaded in fresh Node.js processes.  The
asynchronous API and a cost=12 hashing scenario extend the same load so the API
path and the work-factor scaling are covered.

## 1. Pinned inputs

| Item | Pinned value | Verification |
| --- | --- | --- |
| bcrypt | `6.0.0` (npm release tarball) | `tarball sha256 3b2478cd…b5ae20`; `package.json`, `bcrypt.js`, `binding.gyp` hash-pinned; version re-read before the measurement |
| Node.js | `v22.23.4` (official archive) | x86_64 `1805bcd3…37e9ce`, aarch64 `6287aa46…d2f4b`; `node --version` checked at build/start |
| Native module | prebuilt N-API binary shipped in the release | linux-x64 `prebuilds/linux-x64/bcrypt.glibc.node` `d6406498…bb5e3`, linux-arm64 `prebuilds/linux-arm64/bcrypt.glibc.node` `68f3cf61…fcc52` |
| Dependencies | `node-addon-api 8.9.2`, `node-gyp-build 4.8.4` | vendored `bcrypt-node_modules-6.0.0.tar.gz` `ac85950f…949329`, every version re-read at build/start |
| Password | fixed literal `BoostKit-bcrypt-benchmark-2026` | defined in `fixtures/scenarios.json` and copied into `parameters` |
| Salt | generated once per sample, **before** the timed window | recorded as `salt_seconds` in every sample, never inside the timing |
| Samples | 1 warm-up + `PERF_REPS` samples (default 5) | one isolated Node.js process per sample |
| Network during measurement | offline (proxies point at `127.0.0.1:9`) | exported by the test stage |

The release ships prebuilt N-API binaries for both target architectures, so no
compilation and no `node-gyp` toolchain download happens during the build.  The
build stage verifies that the binary for the target architecture loads, hashes
and compares correctly; the prebuilt-binary hash is pinned per architecture.

## 2. Offline layout

```
/home/runner/software/bcrypt/
├── node-v22.23.4-linux-x64.tar.xz     # sha256 1805bcd3…37e9ce
└── node-v22.23.4-linux-arm64.tar.xz   # sha256 6287aa46…d2f4b
```

`PERF_BCRYPT_OFFLINE_DIR` overrides the directory.  The bcrypt tarball and the
dependency tree are shipped inside the case (`fixtures/`), so the build stage
never needs the npm registry; only a missing Node.js archive falls back to the
Huawei Cloud and npmmirror node distributions (each must match the pinned
SHA-256; a build returns 30 when every URL failed).

## 3. Scenarios

| Scenario | Operation | API | Cost | Operations per sample | Timeout |
| --- | --- | --- | --- | --- | --- |
| `hash_sync_cost10` | hash | synchronous | 10 | 10 | 180 s |
| `hash_async_cost10` | hash | asynchronous (callback) | 10 | 10 | 180 s |
| `compare_sync_cost10` | compare | synchronous | 10 | 10 | 180 s |
| `compare_async_cost10` | compare | asynchronous (callback) | 10 | 10 | 180 s |
| `hash_sync_cost12` | hash | synchronous | 12 | 10 | 300 s |
| `compare_async_cost12` | compare | asynchronous (callback) | 12 | 10 | 300 s |

Each sample is one Node.js process that creates the salt (and, for the compare
scenarios, one reference hash) outside the timed window, performs one warm-up
operation, then times every operation individually with
`process.hrtime.bigint()`.  `UV_THREADPOOL_SIZE=1` keeps the asynchronous path
single threaded, so sync and async scenarios perform the same amount of C++ work.

Correctness gates (enforced by the runner and re-checked by the parser):

- every `compare` must return `true` (and the async callback must not report an
  error);
- every produced hash is verified once more with `compareSync` outside the timed
  window;
- a sample with a wrong boolean, a missing value or a non-positive duration is
  rejected.

## 4. Stages and exit codes

| Stage | Function | Failure exit code | Purpose |
| --- | --- | --- | --- |
| prepare | Framework built-in | – | records the system and pre-run runtime information |
| build | `build_bcrypt` | 30 | installs Node.js, stages bcrypt and its dependencies, verifies the prebuilt N-API binary, loads the module, prefetches every scenario |
| start | `start_bcrypt_runtime` | 40 | re-verifies the runtime, the native binary hash and a hash/compare self-check |
| test | `run_bcrypt_benchmarks` | 50 | runs warm-up + `PERF_REPS` samples per scenario and parses them strictly |
| stop | `stop_bcrypt_runtime` | 50 | terminates leftover processes of the staged app |
| finalize | Framework built-in | 60 | normalizes the metrics and writes `report.md` / `status.json` |

`PERF_VARIANT=optimized` is reserved: the build stage returns 30 immediately and
writes no `build_variant.json`.

## 5. Artifacts and validation

Every run writes to `.perf-output/Toolchain/bcrypt/<version>/<arch>/<run_id>/`:

- `build_variant.json`: Node.js version and archive hash, bcrypt tarball hash,
  dependency-tree hash, native-binary hash, measurement protocol, scenario list.
- `results.json`: 18 metrics (6 scenarios × ms/op, op/s, peak RSS) plus full
  sample statistics.
- `runs/<scenario>/{warmup.log,rep<i>.log}`: environment line, per-operation
  timings, batch/salt/warm-up durations and the correctness record.

`scripts/results/parse_benchmark.py` is the only component that can declare the
measurement successful.  It rejects missing/extra sample logs, a count different
from `PERF_REPS`, missing environment or evidence lines, a runtime or package
drift, a modified native binary or staged package file, a scenario parameter
mismatch, a timing that disagrees with the recorded per-operation durations, a
failed correctness gate, and non-positive metric values.

## 6. Metric semantics

- `<scenario>.ms_per_op`: mean cost of one hash/compare operation over the
  samples (total operation time / operations), median over the samples,
  `lower_is_better`.
- `<scenario>.ops_per_second`: operations per second (`operations / total
  operation time`), median over the samples, `higher_is_better`.
- `<scenario>.peak_rss_mib`: peak RSS of the Node.js process (`VmHWM`), median
  over the samples, `lower_is_better`.

## 7. Determinism and cross-architecture comparability

- The password and the scenario parameters are constants; the salt is random by
  design (bcrypt requires a random salt), but it is generated before the timed
  window and its generation time is recorded separately, so the measured
  operation cost is comparable.
- Node.js, the bcrypt tarball, the dependency tree and the prebuilt native
  binaries are pinned by SHA-256; `parameters` only contains architecture-neutral
  values (versions, hashes, costs, operation counts, environment), no host name,
  path or timestamp.

## 8. Local validation

```bash
SOFTWARE_VERSION=6.0.0 PERF_REPS=1 PERF_BUILD_JOBS=4 \
  python3 framework/run_case.py --case software/Toolchain/bcrypt/case.yaml \
  --version 6.0.0 --architecture x86_64 --run-id local-bcrypt --stage prepare
# then build / start / test / stop / finalize

# Standalone entry point (equivalent to the six stages):
SOFTWARE_VERSION=6.0.0 PERF_REPS=1 python3 \
  software/Toolchain/bcrypt/bcrypt_test.sh --results-dir /tmp/bcrypt-run
```

Negative check for the reserved variant:

```bash
PERF_VARIANT=optimized python3 framework/run_case.py \
  --case software/Toolchain/bcrypt/case.yaml --version 6.0.0 \
  --architecture x86_64 --run-id local-bcrypt-neg --stage build
# expects exit code 30 and no build_variant.json in the output directory
```

## 9. Known limitations

- node.bcrypt.js ships no benchmark suite, so the release manual's fixed cost=10
  hash/compare load is the reference; this case keeps that load and adds the
  asynchronous API and cost=12 hashing.
- The native module is not recompiled: bcrypt 6.0.0 ships prebuilt N-API binaries
  for linux-x64 and linux-arm64, which the case hash-pins and verifies.  If a
  future release drops them, the build must add a pinned `node-gyp` toolchain and
  Node.js headers to the offline directory.
- The salt is random by design, so the raw timings vary slightly more than a pure
  integer workload; the median over five processes is used instead of a single
  sample.
- On a shared Runner other build jobs can inflate timings; a dedicated CI Runner
  should be more stable.
