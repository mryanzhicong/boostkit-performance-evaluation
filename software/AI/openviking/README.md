# OpenViking 0.5.0 performance evaluation (benchmark kit)

This case evaluates the write / search / QA pipeline of
[OpenViking](https://gitcode.com/JankinLee/OpenViking) v0.5.0 with the
**benchmark kit that the v0.5.0 release ships**, executed entirely inside one
private openEuler 24.03 LTS SP4 container. It measures the out-of-the-box
configuration: the kit is run exactly as shipped, with **no NUMA node binding, no
cpuset pinning, no CPU-frequency or memory-spec tuning**, and no rebuild of the
project.

## Upstream sources

| Asset | Location |
| --- | --- |
| Source tree | `https://gitcode.com/JankinLee/OpenViking.git` tag `V0.5.0` |
| Tag commit | `309645cafee3897459fcd819d26e60fad89e9c81` |
| Benchmark kit (aarch64) | `benchmark-kit/openviking-0.5.0-48T96G-aarch64-container-benchmark-kit.tar` |
| Benchmark kit (x86_64) | `benchmark-kit/openviking-0.5.0-48T96G-x86_64-container-benchmark-kit.tar` |
| SHA-256 (aarch64 kit) | `47adef0759dcc28f9edb01b4a07f89924688a240352bf149a6e65fc60ffcd04d` |
| SHA-256 (x86_64 kit) | `ff8499c84b71d5a49ae2bf18f4b319cc3ad18980b600807a9da4f2d7b89be703` |

The build stage clones the tag on the host, verifies the commit, copies the
architecture-matching kit archive out of the clone and verifies its SHA-256
before the container ever sees it. A pre-placed archive in
`${OPENVIKING_OFFLINE_DIR:-/home/runner/software/openviking}` is accepted when it
matches the same digest.

## What the kit protocol measures

The kit's seven-step protocol is executed out of the box:

1. generate `ov.conf` with the kit's `harness/prepare_run.py`;
2. start the service through the kit's `harness/agfs_timing.py` (AGFS spans on);
3. write LoCoMo sample 0: 19 sessions → 61 commits with per-stage telemetry;
4. replay the 152 LoCoMo search questions (`capture_search_telemetry.py`);
5. answer the 152 LoCoMo questions (`benchmark/locomo/openviking/run_eval.py`,
   `complete_missing_qa.py`, `token_savings.py`);
6. record instrumentation coverage;
7. generate the report suite (`agfs_report.py`, `build_reports.py`).

The measured pass runs on a fresh workspace after a discarded warm-up pass
(first session write + search replay), so first-touch effects never enter the
evidence. No `numactl`, `--cpunodebind`, `--cpuset-cpus` or `--memory` option is
used; the kit's own pinning re-exec is skipped by design.

## Provider mock (why the numbers are reproducible)

The kit expects a real LLM and a real embedding service. The performance runners
have no external model credentials and an external service would make the numbers
vary per run, so the case starts a deterministic, dependency-free
OpenAI-compatible mock (`benchmark/mock_openai.py`) inside the same container:

* `/v1/embeddings` returns text-deterministic unit vectors of the configured
  dimension (identical on every run and every architecture);
* `/v1/chat/completions` returns a deterministic operations document that obeys
  the JSON Schema the extraction prompt itself embeds, with one synthetic event
  operation, so the resolve / patch / persist / vector-upsert path of the write
  pipeline really executes; every other prompt (LoCoMo QA) gets a deterministic
  canned answer.

Consequences that are recorded in the result payload and must be respected when
reading the numbers:

* the timings of the local write and search pipeline are meaningful and
  comparable across architectures and runs;
* answer quality, judge accuracy and token-savings figures are **not** meaningful
  with a mock and are therefore not published as metrics;
* working memory stays at the v0.5.0 default (`enable_working_memory=false`), so
  `branch.archive_summary` / `archive_summary.*` stages are absent — exactly as
  in an upstream kit run with the same defaults;
* the kit importer commits sequentially, so concurrent streaming-merge stages
  (`long_term.streaming.patch_merge`, `merge_wait_apply`) are not exercised and
  are not published.

## Metrics

`scripts/results/parse_benchmark.py` converts the kit's raw telemetry into the
repository metric contract. Every metric is the **median over the per-item samples
of the measured pass** (61 write commits, 152 search questions) and every sample
is retained in the result payload (`samples`, `sample_values`, `aggregate`).
Grouping and local-time formulas follow the kit's own `analyze.py` (v0.5.0).

| Metric | Unit | Group |
| --- | --- | --- |
| `write_commit_prepare` | ms/commit | write |
| `write_long_term_prepare` | ms/commit | write |
| `write_extraction_local` | ms/commit | write |
| `write_streaming_merge_local` | ms/commit | write |
| `write_persist_and_vector_upsert` | ms/commit | write |
| `write_long_term_finalize` | ms/commit | write |
| `write_parallel_tail` | ms/commit | write |
| `write_relation_and_commit` | ms/commit | write |
| `write_local_net` | ms/commit | write |
| `write_local_sum` | ms/commit | write |
| `search_query_prepare` | ms/query | search |
| `search_vector_recall` | ms/query | search |
| `search_result_processing` | ms/query | search |
| `search_response_handling` | ms/query | search |
| `search_local_sum` | ms/query | search |

All metrics are `lower_is_better`. When the kit does not instrument a stage
group at all -- for example the archive-summary branch, which stays disabled
because OpenViking 0.5.0 defaults working memory off -- the parser omits that
metric and records the reason under `protocol.omitted_metrics` instead of
publishing a misleading `0 ms` value. The parser fails closed: it aborts when the
kit telemetry is missing, when fewer than 50 write commits or 120 search rows
were recorded, when essential instrumentation stages are absent
(`context_prepare`, `parallel_extraction`, `queue_drain`,
`extract.long_term.json_parse`, `long_term.apply_detail.persist`,
`index.vector_upsert`, `request_prepare`, `vector_retrieval`), or when more than
5 % of the write samples report a negative local time.

## Container execution

Every stage runs in one private openEuler 24.03 LTS SP4 container:

| Stage | What happens inside the container |
| --- | --- |
| `build` | install `python3`/`pip`/`gcc` from the openEuler repository, extract the kit, install the kit's pinned dependency set, the v0.5.0 wheel and the instrumented overlay, verify the import contract, publish `build_variant.json` |
| `start` | prepare the run tree, start the provider mock, generate `ov.conf` with the kit's `prepare_run.py`, start the service through `harness/agfs_timing.py`, wait for `/health`, run the kit's provider smoke test |
| `test` | warm-up pass, measured seven-step protocol, coverage/report generation, host-side strict parsing (`benchmark_openviking.json`, `runs/`, `reports/`) |
| `stop` | stop the service and the mock, remove the container |

The container base image ships Python 3.11.6. The kit image uses CPython 3.13,
but the OpenViking wheel is `cp310-abi3` and all 171 pinned dependencies resolve
to `cp311`/`abi3`/`py3-none` wheels, so the identical pinned set is used on both
architectures; the interpreter version is recorded in every result payload.

## Local reproduction (x86_64 / aarch64 host with Docker)

```bash
bash software/AI/openviking/openviking_test.sh --version 0.5.0 \
    --results-dir /home/runner/boostkit-perf/openviking-results

# Framework equivalent (six stages):
PERF_REPS=1 bash adaptation/scripts/local-run-case.sh \
    <repo> software/AI/openviking/case.yaml 0.5.0 local-openviking
```

The run needs network access to the Huawei PyPI/openEuler mirrors during the
build stage (the pinned dependency set is installed fresh per run) and none
afterwards: the measured protocol only talks to the in-container mock.

## Limitations

* The mock replaces the model and embedding service by design; see above for the
  metrics that are and are not meaningful.
* The kit's strict x86 `run_full.sh` stage gate (27 write stages) cannot be
  satisfied offline without working memory and concurrent merges; this case uses
  the kit's `container_run.sh` step sequence (steps 3–7) as the protocol and
  publishes the strict, stage-validated metric subset described above.
* `grader`/`judge` accuracy and token-savings analysis run for protocol
  completeness only; they are excluded from the published metrics.
