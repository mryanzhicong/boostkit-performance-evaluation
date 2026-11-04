# scikit-learn performance case

This case measures the **upstream scikit-learn asv benchmark suite** of the
pinned release on the BoostKit Runner. The workload, the dependency versions and
the Python interpreter are fixed, the measurement itself is offline, and every
raw sample is kept so the numbers can be re-verified.

The manual (`手册/全量/19-scikit-learn.md`) requires the public suite of
scikit-learn (`asv`, upstream `asv_benchmarks`).  The repository case therefore
runs nine selected upstream benchmark scenarios instead of the short
`make_classification` smoke load that the manual uses only as an illustration.

## Pinned inputs

| Input | Value | Verification |
| --- | --- | --- |
| scikit-learn | `1.9.1` | `actual-version.txt` must equal the requested version |
| CPython | `3.12.16`, built from the official source archive | `sha256 710c3e75dac8b2f258d9cd0f76e5c4c2e9175fac9e249c98901552f7cf33b7dd`, 27,310,261 bytes |
| scikit-learn sdist | `scikit_learn-1.9.1.tar.gz` (provenance) | `sha256 629cada3e33e2b9bf376cdc7614a47a4140b8aedc1d836579e359736fbd82977`, 7,786,908 bytes |
| Runtime wheels | `requirements.lock` (`numpy 2.0.0`, `scipy 1.14.0`, `scikit-learn 1.9.1`, `joblib 1.4.0`, `narwhals 2.0.1`, `threadpoolctl 3.5.0`) | installed with `pip --require-hashes`; the lock lists the Linux `x86_64` and `aarch64` wheel hashes |
| asv benchmark snapshot | scikit-learn `1.9.1`, commit `866c0f51e7560ef0303cbcc5f159df5382ea9e3f` | vendored byte-identical copy of `asv_benchmarks/`, verified against `asv_benchmarks/manifest.sha256` before the build and again before the measurement |

The wheel versions are exactly the `matrix` pins of the upstream
`asv_benchmarks/asv.conf.json`, so the measured code matches the upstream
benchmark configuration.

## Offline pre-placement

The Runner may have no stable access to `pypi.org` or `python.org`, and the
measurement itself must not touch the network at all.  Pre-place the following
tree on the Runner (content-addressed, all files verified by SHA-256):

```
/home/runner/software/scikit-learn/
├── Python-3.12.16.tgz          # sha256 710c3e75…b7dd
├── scikit_learn-1.9.1.tar.gz   # sha256 629cada3…2977 (provenance only)
└── wheels/
    ├── numpy-2.0.0-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
    ├── numpy-2.0.0-cp312-cp312-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
    ├── scipy-1.14.0-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
    ├── scipy-1.14.0-cp312-cp312-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
    ├── scikit_learn-1.9.1-cp312-cp312-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl
    ├── scikit_learn-1.9.1-cp312-cp312-manylinux_2_27_aarch64.manylinux_2_28_aarch64.whl
    ├── joblib-1.4.0-py3-none-any.whl
    ├── narwhals-2.0.1-py3-none-any.whl
    └── threadpoolctl-3.5.0-py3-none-any.whl
```

The directory can be overridden with `PERF_SCIKIT_LEARN_OFFLINE_DIR`.  When an
artifact is missing the build stage falls back to the mirrors and verifies the
same SHA-256 afterwards:

1. CPython source: Huawei Cloud, Aliyun (two independent downloads produced the
   same archive; NJU is the third mirror), then the official `python.org`.
2. Pinned wheels: `pip download` from the Tsinghua TUNA index, Huawei Cloud,
   Aliyun and finally `pypi.org`; the hash check is enforced by
   `pip install --require-hashes` against `requirements.lock`.
3. scikit-learn sdist: TUNA package URL, then `pip download --no-binary :all:`.

If every source fails the build stage returns `30` and prints every attempted
URL.  The measurement stage never downloads anything: it installs only from the
local wheelhouse and sets dead HTTP proxies (`http://127.0.0.1:9`) so an
accidental network call fails immediately instead of silently changing timing.

## Stages

| Stage | Behaviour | Exit code |
| --- | --- | --- |
| build | installs `gcc`/`make`/`-devel` headers with `dnf` **inside the private openEuler container**, builds the pinned CPython there, creates a private venv, installs the hash-locked runtime, stages the vendored asv suite, prefetches all scenarios once (cold-cache correctness gate) and writes `build_variant.json` | `30` on failure |
| start | verifies (inside the container) the private runtime, the pinned versions and the asv snapshot manifest | `40` on failure |
| test | runs `1` warmup + `N` samples per scenario (`PERF_REPS`, default `5`) with one process per sample inside the container, then strictly parses the raw samples into `results.json` on the host | `50` on failure |
| stop | removes this task's private container first, then terminates any leftover measurement process that belongs to this run's work directory | `50` if a process survives |

`raw-output.log` is produced by the Framework; `runs/<scenario>/warmup.log`,
`runs/<scenario>/rep<i>.log` and `runs/<scenario>/rep<i>.json` are produced here
and are part of the declared output `run_samples`.

## Scenarios

All data sets are generated locally by the upstream `datasets.py` (no download),
the profile is `regular` and `n_jobs` is fixed to `1`.

| Scenario | Upstream definition | Parameter | Typical duration |
| --- | --- | --- | --- |
| `svc_fit_linear` | `benchmarks.svm.SVCBenchmark.time_fit` | `linear` | ~1 s |
| `svc_fit_rbf` | `benchmarks.svm.SVCBenchmark.time_fit` | `rbf` | ~1 s |
| `svc_predict_rbf` | `benchmarks.svm.SVCBenchmark.time_predict` | `rbf` | ~1 s |
| `hist_gbdt_fit` | `benchmarks.ensemble.HistGradientBoostingClassifierBenchmark.time_fit` | – | ~2.5 s |
| `kmeans_fit_blobs_dense` | `benchmarks.cluster.KMeansBenchmark.time_fit` | `dense, lloyd, k-means++` | ~1.5 s |
| `minibatch_kmeans_fit_blobs_dense` | `benchmarks.cluster.MiniBatchKMeansBenchmark.time_fit` | `dense, k-means++` | ~5 s |
| `sgd_regressor_fit_synth` | `benchmarks.linear_model.SGDRegressorBenchmark.time_fit` | `dense` | ~3.5 s |
| `ridge_fit_synth_auto` | `benchmarks.linear_model.RidgeBenchmark.time_fit` | `dense, auto` | ~0.5 s |
| `crossval_rf_50k` | `benchmarks.model_selection.CrossValidationBenchmark.time_crossval` | `n_jobs=1` | ~35 s |

Every sample is validated before a metric is published:

* the runtime banner must report the pinned CPython and the six pinned packages;
* the evidence line must name the same benchmark class, parameters and method as
  `fixtures/scenarios.json`;
* the train-split data shape must be the documented one
  (`900 x 10000`, `9000 x 100`, `450000 x 3`, `90000 x 200`, `450000 x 100`,
  `45000 x 100`);
* the correctness score must be finite and above the scenario threshold
  (balanced accuracy >= 0.5 for SVC, >= 0.9 for HistGradientBoosting,
  R2 >= 0.5 for SGD, R2 >= 0.8 for Ridge, negatives inertia <= 0 for the two
  KMeans scenarios, cross-validation accuracy >= 0.8);
* the in-process measured window must be shorter than the process wall clock.

The SVC scenarios intentionally keep the upstream `max_iter=100`, which emits
`sklearn.exceptions.ConvergenceWarning`; the benchmark definitions decide the
workload, so the warning is recorded as evidence instead of being treated as a
failure.

## Excluded upstream benchmarks

The upstream suite also contains benchmarks that cannot run inside this
contract; they are excluded explicitly rather than silently skipped:

| Benchmark | Reason |
| --- | --- |
| `DictionaryLearningBenchmark` | downloads the Olivetti faces data set |
| `PCABenchmark` | downloads the MNIST data set (`fetch_openml`) |
| `RandomForestBenchmark` | downloads the 20 newsgroups data set |
| `KNeighborsClassifierBenchmark` | downloads the 20 newsgroups data set |
| `GridSearchBenchmark` | one repetition takes ~145 s, far outside the sampling budget |
| `PairwiseDistancesBenchmark` | peak RSS above 1 GiB on the shared Runner |

## Metrics and sampling

Each scenario contributes two metrics, both `lower_is_better` and grouped by the
scenario name:

* `<scenario>.wall_seconds`: the timed call of the upstream `time_*` method,
  measured with `time.perf_counter` inside the benchmark process (the dataset
  load, the untimed `fit` that the upstream `setup` performs and the joblib
  dataset cache are outside this window, exactly like asv);
* `<scenario>.peak_rss_mib`: peak RSS of the whole benchmark process, taken from
  `getrusage(RUSAGE_CHILDREN)` by `scripts/run_timed.py`.

The published value is the **median** of the `PERF_REPS` samples; the full
sample list, mean, min, max and standard deviation are kept in
`results.json`.  `PERF_REPS=1` is supported for quick local validation, a
delivery run uses the default `5`.

## Determinism and cross-architecture comparability

The measurement environment fixes `OMP_NUM_THREADS=1`,
`OPENBLAS_NUM_THREADS=1`, `MKL_NUM_THREADS=1`, `NUMEXPR_NUM_THREADS=1`,
`PYTHONHASHSEED=0`, `LC_ALL=C` and `TZ=UTC`; `SKLBENCH_PROFILE=regular` and
`SKLBENCH_NJOBS=[1]` reproduce the upstream asv profile.  The same interpreter
patch release and the same wheel versions are used on both architectures.

`results.json.parameters` only contains values that are identical on
`x86_64` and `aarch64` (versions, hashes of the shared sources, scenario
definitions, sampling protocol, thread settings), so
`normalize_results.parameter_signature` matches across architectures.  Machine
specific evidence (architecture, absolute paths, wheel hashes of the installed
platform, timings) stays outside `parameters`.

## Container execution (openEuler 24.03 LTS SP4)

The build/start/test/stop stages of this case run inside a per-run
openEuler 24.03 LTS SP4 container; the host keeps only Docker, the
download/SHA-256 verification tooling, the Framework and the strict parser.

| Item | Value |
| --- | --- |
| Image | `openEuler-docker.<arch>.tar.xz` from `repo.openeuler.org`; the archive and its `.sha256sum` are verified, then the loaded image is pinned by reference, architecture and the `24.03` string in `/etc/os-release` |
| Image archive directory | `SCIKIT_LEARN_IMAGE_ARCHIVE_DIR`, default `/home/runner/software/openEuler-24.03-LTS-SP4` (the local archive is preferred, downloads happen only when it is missing) |
| Container name | `boostkit-scikit_learn-<arch>-<run-id>` |
| Label | `boostkit.scikit_learn.run-id=<run-id>`; `stop` refuses to delete a container without this task's label and returns `60` |
| Mounts | `PERF_WORK_DIR` and `RESULTS_DIR` read-write, the case directory read-only, `/etc/passwd`, `/etc/group`; `--network=host`, no extra privileges |
| In-container packages | `dnf install gcc gcc-c++ make tar gzip xz curl coreutils findutils diffutils pkgconf-pkg-config time python3 zlib-devel libffi-devel openssl-devel bzip2-devel xz-devel sqlite-devel ncurses-devel readline-devel`, always with `--setopt=install_weak_deps=False` so weak-dependency rpm scriptlets cannot fail on the read-only `/etc/passwd` mount |
| Host duties | source/wheel download or offline copy plus SHA-256 checks, Docker image preparation, Framework stages, `parse_benchmark.py` |
| Container duties | dependency installation, CPython extraction/configure/make/install, venv creation, `pip download`/`pip install`, asv snapshot staging, prefetch, every measured Python process and the timing wrapper |

The pinned measurement environment (`OMP_NUM_THREADS=1`,
`OPENBLAS_NUM_THREADS=1`, `MKL_NUM_THREADS=1`, `NUMEXPR_NUM_THREADS=1`,
`PYTHONHASHSEED=0`, `LC_ALL=C`, `TZ=UTC`, `SKLBENCH_PROFILE=regular`,
`SKLBENCH_NJOBS=[1]`, `HOME=${PERF_WORK_DIR}/home`, the dead HTTP proxies and
`TMPDIR=${PERF_WORK_DIR}/tmp`) is applied **inside** the container through
`sklearn_container_exec_measured()`: `docker exec` does not forward the caller
environment, so every pinned variable is re-applied explicitly.  The measured
window is still taken by `run_timed.py` around a single child process, so the
`docker exec` management overhead never lands inside a sample.

Cleanup: `stop` calls `remove_scikit_learn_container` first (idempotent, an
absent container returns `0`), then keeps the original leftover-process scan.
Stale containers left by cancelled CI runs are removed by
`sweep_scikit_learn_stale_containers`, which only matches the
`boostkit-scikit_learn-` prefix and a different run-id.

## Local validation

```bash
# the local entry point also needs a reachable Docker daemon and the
# openEuler 24.03 LTS SP4 image (or its archive under the pinned directory)
# quick validation: one sample per scenario
SOFTWARE_VERSION=1.9.1 PERF_REPS=1 PERF_BUILD_JOBS=4 \
  bash software/Toolchain/scikit-learn/scikit-learn_test.sh --keep-workdir

# delivery sampling: default five samples
SOFTWARE_VERSION=1.9.1 PERF_BUILD_JOBS=4 \
  bash software/Toolchain/scikit-learn/scikit-learn_test.sh --results-dir /tmp/sklearn-run

# six Framework stages (what CI executes)
python3 framework/run_case.py --case software/Toolchain/scikit-learn/case.yaml \
  --version 1.9.1 --architecture x86_64 --run-id local-sklearn --stage prepare
# … then build, start, test, stop, finalize
```
