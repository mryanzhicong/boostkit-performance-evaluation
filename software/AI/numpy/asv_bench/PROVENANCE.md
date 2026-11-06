# Provenance — vendored asv benchmark suite

- **Repository URL:** https://gitcode.com/boostkit/numpy.git
- **Suite commit (full):** `95422b21eb5b43a2453e45b8531a3dd09c9b61ab`
- **Suite commit (short):** `95422b2`
- **`benchmarks` tree sha at that commit:** `b76e6b454f70b2ceb13b7cfe8a22bce57717ac3f`
  (`git rev-parse 95422b2:benchmarks`)
- **Baseline commit of the software under test:** `289c872fc2cc3a82a63a66b4c1a32e8ef6e80fb6`
  (its benchmark files are **not** used; the suite is taken from `95422b2` only)

## How this copy was produced (refresh command)

The suite directory `benchmarks/benchmarks` was exported from the `95422b2` commit and
unpacked, byte for byte, into `asv_bench/benchmarks/`:

```bash
# from a clone/worktree of https://gitcode.com/boostkit/numpy.git containing 95422b2
git -C <clone> archive 95422b2 benchmarks/benchmarks | tar -x -C <tmp>
rsync -a --exclude='__pycache__' --exclude='*.pyc' \
      <tmp>/benchmarks/benchmarks/ <case>/asv_bench/benchmarks/
```

`benchmarks/asv.conf.json` was copied from `95422b2:benchmarks/asv.conf.json`, and
`LICENSE.txt` from the repository root at the same commit.

Totals (excluding `__pycache__` / `*.pyc`):

| path | files | bytes |
|---|---:|---:|
| `benchmarks/benchmarks` source tree | 44 | 833948 |
| `asv_bench/` vendored content: `benchmarks/` + `asv.conf.json` + `LICENSE.txt` (measured before the two generated metadata files below) | 46 | 838952 |

`PROVENANCE.md` (this file) and `manifest.sha256` are generated metadata; they are not upstream
content and are excluded from the `asv_bench/` row above.

## Fidelity notes

- The benchmark suite under `asv_bench/benchmarks/` is **byte-identical** to
  `95422b2:benchmarks/benchmarks`; only `__pycache__/` and `*.pyc` are omitted.
- `asv_bench/asv.conf.json` is byte-identical to the upstream file **except** for the
  following keys, changed only so the config is relocatable inside the runner work dir:
  - `"repo"`: `".."` -> `"../src/numpy"`
  - `"benchmark_dir"`: `"benchmarks"` (unchanged)
  - `"results_dir"`: `"results"` (unchanged)
  - `"html_dir"`: `"html"` (unchanged)
  - `"env_dir"`: `"env"` (unchanged)
  - `"environment_type"`: `"virtualenv"` (unchanged)
- Additions that are not upstream: `LICENSE.txt`, `PROVENANCE.md`, `manifest.sha256`.
- `manifest.sha256` records the sha256 of every file in `asv_bench/` (except itself) and
  verifies with `cd asv_bench && sha256sum -c manifest.sha256`.
