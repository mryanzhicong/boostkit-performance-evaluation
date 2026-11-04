# Vendored upstream asv benchmark suite

`asv_benchmarks/` is a byte-identical copy of the upstream scikit-learn
benchmark suite for the pinned release.  It is vendored because the published
source distribution does **not** contain `asv_benchmarks/` (the directory is
`export-ignore` in the project's `.gitattributes`) and because the measurement
must not clone or download anything at run time.

## Provenance

| Field | Value |
| --- | --- |
| Project | scikit-learn |
| Repository | <https://github.com/scikit-learn/scikit-learn> |
| Tag | `1.9.1` (annotated tag object `f0668270731746c1b4517f0e9e2cd5b8c2ba3784`) |
| Commit | `866c0f51e7560ef0303cbcc5f159df5382ea9e3f` |
| Upstream suite | `asv_benchmarks/` (`asv.conf.json`, `benchmarks/`, `COPYING`) |
| Obtained from | `https://gitee.com/mirrors/scikit-learn` at tag `1.9.1` (clone HEAD reported `866c0f51e7560ef0303cbcc5f159df5382ea9e3f`; the tag commit was cross-checked with the GitHub API) |
| License | BSD-3-Clause, see `COPYING` |

The files were copied without edits.  `manifest.sha256` records the SHA-256 of
every vendored file; the build stage verifies it before staging the suite and
the test stage verifies it again before measuring, so a modified or partially
copied snapshot can never produce benchmark numbers.

The copy and the manifest were generated from the tag checkout with:

```bash
git clone --branch 1.9.1 --depth 1 https://gitee.com/mirrors/scikit-learn
cp asv_benchmarks/{asv.conf.json,COPYING} <case>/asv_benchmarks/
cp asv_benchmarks/benchmarks/* <case>/asv_benchmarks/benchmarks/
(cd <case>/asv_benchmarks && find benchmarks asv.conf.json COPYING -type f | sort | xargs sha256sum > manifest.sha256)
```

## How the snapshot is used

The case does not use the `asv` command line (it would create its own conda
environment, which is not available on the Runner).  Instead
`scripts/fixtures/asv_runner.py` imports the unmodified upstream benchmark
classes from the staged copy, performs the same untimed `setup`/`make_data` +
`fit` steps that asv performs, and times exactly one call of the selected
`time_*` method.  The selected scenarios and their parameters are listed in
`fixtures/scenarios.json`; `asv.conf.json` is kept so the pinned dependency
matrix and the benchmark profile can be audited.

## Updating

When the case version changes, replace the whole tree from the new tag, update
`manifest.sha256` with the command above, update the commit hash in
`fixtures/scenarios.json`, `case.yaml` (`test_tools.asv_benchmarks.revision`),
`scripts/common.sh` (`ASV_TAG_COMMIT`) and this file, then re-run the
`PERF_REPS=1` validation before the delivery run.
