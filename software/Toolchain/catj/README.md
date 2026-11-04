# catj 1.0.4 performance case

This case measures the **upstream catj 1.0.4 CLI** flattening fixed JSON inputs.
The load is the representational load of the catj release manual (a JSON array of
objects flattened to `.<index>.<path> = value` lines), extended to three input
scales and both input modes (`file` argument and `stdin`).  Node.js start-up and
the complete stdout capture are part of the wall time.

## Containerized execution

The build, start, test and stop stages of this case all run in a per-run
openEuler 24.03 LTS SP4 container, using the same container contract as
`software/Database/mysql`, `software/Bigdata/ray` and
`software/Others/unixbench`.  The host only needs Docker, the
download/verification tools and the Framework; no Node.js toolchain is
installed on the host.

- Image: the official openEuler 24.03 LTS SP4 Docker archive, read from
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`
  with its `.sha256sum` when present and downloaded from
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/`
  otherwise; archive SHA-256, image architecture and the image's
  `/etc/os-release` are verified after loading.
- Container: named `boostkit-catj-<arch>-<run id>` and labelled
  `boostkit.catj.run-id=<run id>`, host network, runs as the Runner user, mounts
  the case directory read-only and `${PERF_WORK_DIR}` / `${RESULTS_DIR}`
  read-write; no `--privileged`.
- Node.js: the official `node-v22.23.4-linux-<arch>.tar.xz` archive is still
  downloaded and SHA-256 verified on the host (pre-placed offline copy first),
  extracted into `${PERF_WORK_DIR}` and **executed inside the container**.  The
  openEuler 24.03 LTS SP4 userland (glibc 2.38) satisfies the archive's glibc
  requirement, so no distribution Node.js package is installed; the runtime is
  pinned and identical on both architectures.  `tar`, `xz`, `libstdc++` and
  `python3` come from the container's `dnf` (with
  `--setopt=install_weak_deps=False`, because the read-only `/etc/passwd` and
  `/etc/group` mounts break `useradd`/`groupadd` scriptlets).
- Container-side work: Node.js extraction, the dependency/version probes,
  fixed-input generation, the runtime record, the cold-cache prefetch of every
  scenario, and each timed sample through
  `scripts/results/run_measure.py`.
- Host-side work: downloading and verifying the pinned archives, the strict
  parser (`results.json`), `scripts/results/verify_output.py` and removing this
  task's container.
- Measurement: each sample is a container-native child of `run_measure.py`, so
  `docker exec` overhead never enters a measurement window; sample counts,
  warm-ups, the `FORCE_COLOR=0`/locale/thread-pool environment and the parser
  strictness are unchanged.
- Cleanup: `stop` removes the container first and then proves no measured
  process of this run survives; it is idempotent and safe to call on failure.

Running the case standalone also requires Docker and an accessible Docker
daemon; otherwise the build stage returns 30 with a clear message.

## 1. Pinned inputs

| Input | Pinned value | Verification |
| --- | --- | --- |
| catj | `1.0.4` | staged from the pinned npm tarball and re-read from `package.json` |
| Node.js | `v22.23.4` (official archive) | per-architecture SHA-256 (x86_64 `1805bcd3…37e9ce`, aarch64 `6287aa46…d2f4b`) |
| catj tarball | `catj-1.0.4.tgz` | `sha256 bc3c7c18…518f3e6c` |
| Dependency tree | `catj-node_modules-1.0.4.tar.gz` (`catj 1.0.4`, `optimist 0.6.1`, `colors 1.4.0`, `minimist 0.0.10`, `wordwrap 0.0.3`) | `sha256 c9a154e3…3e12fce`; every package version and `package.json` hash re-checked before the measurement |
| JSON inputs | three deterministic files generated from `fixtures/generate_inputs.js` | SHA-256 and byte size pinned in `fixtures/scenarios.json`: `objects-5000.json` (621,271 B, `e34897a7…defa3`), `objects-25000.json` (3,166,334 B, `01a77b0b…b4576`), `objects-100000.json` (12,785,306 B, `c67dfc01…bcc13`) |
| stdout | byte-identical flattening output | per-input SHA-256 pinned; `FORCE_COLOR=0` removes terminal escapes, so both architectures produce the same bytes |
| Samples | 1 warm-up + `PERF_REPS` samples (default 5) | one isolated process per sample |
| Network during measurement | offline (proxies point at `127.0.0.1:9`) | exported by the test stage |

## 2. Offline layout

```
/home/runner/software/catj/
├── node-v22.23.4-linux-x64.tar.xz     # sha256 1805bcd3…37e9ce
└── node-v22.23.4-linux-arm64.tar.xz   # sha256 6287aa46…d2f4b
```

`PERF_CATJ_OFFLINE_DIR` overrides the directory.  The catj tarball and the
flattened `node_modules` tree are shipped inside the case (`fixtures/`), so the
build stage never needs a registry; only a missing Node.js archive falls back to
the Huawei Cloud and npmmirror node distributions (each must match the pinned
SHA-256, otherwise the next mirror is tried and a build returns 30 when every
URL failed).

## 3. Scenarios

| Scenario | Input | Mode | Calls per sample | Expected stdout |
| --- | --- | --- | --- | --- |
| `flatten_file_5000` | `objects-5000.json` | file argument | 1 | 45,000 lines |
| `flatten_stdin_5000` | `objects-5000.json` | stdin | 1 | 45,000 lines |
| `flatten_file_25000` | `objects-25000.json` | file argument | 1 | 225,000 lines |
| `flatten_stdin_25000` | `objects-25000.json` | stdin | 1 | 225,000 lines |
| `flatten_file_100000` | `objects-100000.json` | file argument | 1 | 900,000 lines |
| `flatten_stdin_100000` | `objects-100000.json` | stdin | 1 | 900,000 lines |

Each sample is one CLI invocation (`node node_modules/catj/catj.js <input>` or
`node node_modules/catj/catj.js < <input>`), so Node.js start-up dominates the
small scenario and the flattening pass dominates the large one.  The parser
requires the recorded stdout to be byte-identical to the pinned output of the
corresponding input (SHA-256, exact line count, last object id token and last
value token).

## 4. Stages and exit codes

| Stage | Function | Failure exit code | Purpose |
| --- | --- | --- | --- |
| prepare | Framework built-in | – | records the system and pre-run runtime information |
| build | `build_catj` | 30 | installs Node.js, stages catj and its dependencies, generates and verifies the JSON inputs, runs every scenario once as a cold correctness gate |
| start | `start_catj_runtime` | 40 | cross-checks the runtime record against the staged artefacts |
| test | `run_catj_benchmarks` | 50 | runs warm-up + `PERF_REPS` samples per scenario and parses them strictly |
| stop | `stop_catj_runtime` | 50 | terminates leftover processes of this case |
| finalize | Framework built-in | 60 | normalizes the metrics and writes `report.md` / `status.json` |

The `optimized` variant is reserved: with `PERF_VARIANT=optimized` the build
stage returns 30 immediately and writes no `build_variant.json`.

## 5. Artifacts and validation

Every run writes to `.perf-output/Toolchain/catj/<version>/<arch>/<run_id>/`:

- `build_variant.json`: Node.js version and archive hash, catj tarball hash,
  dependency tree hash, input hashes, measurement protocol.
- `results.json`: 18 metrics (6 scenarios × wall time, peak RSS and throughput)
  plus the full sample statistics.
- `runs/<scenario>/{warmup.json,warmup.out,warmup.err,rep<i>.json,rep<i>.out,rep<i>.err}`:
  the timing record and the complete stdout/stderr capture of every sample.

`scripts/results/parse_benchmark.py` is the only component that can declare the
measurement successful.  It rejects:

- missing or extra scenario directories/sample files, a sample count different
  from `PERF_REPS`;
- timed-out samples, non-zero exits, or a timeout budget that differs from the
  agreed one;
- Node.js/catj/dependency version drift, or a modified staged package file;
- a regenerated input whose SHA-256 or size differs from the pinned value;
- stdout that differs from the pinned flattening output (hash, line count, last
  object tokens);
- a non-positive wall time, peak RSS or throughput.

On failure the test stage returns 50 and prints the last 40 lines of
`measurement.log`.

## 6. Metric semantics

- `<scenario>.wall_seconds`: whole CLI invocation (Node.js start-up + parsing +
  flattening + writing the captured stdout), median over the samples,
  `lower_is_better`.
- `<scenario>.peak_rss_mib`: peak RSS of the CLI process, median over the samples,
  `lower_is_better`.
- `<scenario>.throughput_mib_s`: input bytes / wall time in MiB/s, median over the
  samples, `higher_is_better`.

## 7. Determinism and cross-architecture comparability

- The generator is a pure function of the object index; it contains no random
  number generator, so the three inputs are byte-identical on both
  architectures (and their SHA-256 values are pinned in `fixtures/scenarios.json`).
- `FORCE_COLOR=0` and `NO_COLOR=1` disable colour escapes, so the captured
  stdout is byte-identical; the parser pins its SHA-256 per input.
- Node.js, the catj tarball, the dependency tree and the inputs are all pinned by
  SHA-256; `parameters` in `results.json` only contains architecture-neutral
  values (versions, hashes, modes, iteration counts, environment), no host name,
  path or timestamp.

## 8. Local validation

```bash
SOFTWARE_VERSION=1.0.4 PERF_REPS=1 PERF_BUILD_JOBS=4 \
  python3 framework/run_case.py --case software/Toolchain/catj/case.yaml \
  --version 1.0.4 --architecture x86_64 --run-id local-catj --stage prepare
# then build / start / test / stop / finalize

# Standalone entry point (equivalent to the six stages):
SOFTWARE_VERSION=1.0.4 PERF_REPS=1 python3 \
  software/Toolchain/catj/catj_test.sh --results-dir /tmp/catj-run
```

Negative check for the reserved variant:

```bash
PERF_VARIANT=optimized python3 framework/run_case.py \
  --case software/Toolchain/catj/case.yaml --version 1.0.4 \
  --architecture x86_64 --run-id local-catj-neg --stage build
# expects exit code 30 and no build_variant.json in the output directory
```

## 9. Known limitations

- catj has no upstream performance suite; the release manual only defines the
  fixed 10,000-object flatten load.  This case keeps that load and extends it to
  three scales (5,000 / 25,000 / 100,000 objects) and both input modes, with the
  extended inputs generated deterministically.
- The wall time includes Node.js start-up (about 40 ms), which is significant for
  the 5,000-object scenario; this matches the manual's "CLI flatten incl. Node
  start-up and output capture" definition rather than an in-process library call.
- stdout is written to disk for every sample, so the 100,000-object scenarios
  consume roughly 36 MB per sample while the evidence is retained.
- On a shared Runner other build jobs can inflate timings; a dedicated CI Runner
  should be more stable.
