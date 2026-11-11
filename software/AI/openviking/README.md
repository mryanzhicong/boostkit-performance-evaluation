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
| Source tree | `https://gitcode.com/JankinLee/OpenViking.git` branch `V0.5.0` |
| Source commit | `b2b3df1fb5d845552a87f1efde8d5ddf5018c66b` |
| Benchmark kit (aarch64) | `benchmark-kit/openviking-0.5.0-48T96G-aarch64-container-benchmark-kit.tar` |
| Benchmark kit (x86_64) | `benchmark-kit/openviking-0.5.0-48T96G-x86_64-container-benchmark-kit.tar` |
| SHA-256 (aarch64 kit) | `45d6f22bf825c837cd46b462639a0c561960c008941407aa7ec9c470b02a8707` |
| SHA-256 (x86_64 kit) | `3e947cc9c50b50e63a1a1af48692f3c1f9c9daf0d4b0cc5ed67977ef53450dc0` |

The `V0.5.0` branch is a moving branch: the case was first adapted against
`309645c` and is now pinned to `b2b3df1` (2026-11-10), which revised the kit's
analysis/report layer to its final report contract (write local 7 groups /
server-side search 5 items, 0.4.21 baseline comparison removed). The seven-step
protocol and the raw telemetry the kit writes are unchanged between the two
revisions; the published metric definitions below are exactly that final report
contract, so the numbers can be compared with the kit's own final report. The
earlier metric set (15 metrics) is superseded by the runs linked in the PR.

The build stage clones the branch on the host, verifies the commit, copies the
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
  in an upstream kit run with the same defaults, and the kit's final report also
  publishes the archive-summary group as `0` in that case (recorded under
  `protocol.zero_by_design_metrics`);
* the kit importer commits sequentially, so concurrent streaming-merge stages
  (`long_term.streaming.patch_merge`, `merge_wait_apply`) are not exercised and
  the `write_streaming_merge_local` group only contains
  `long_term.streaming.route` (≈0.01 ms/commit), matching the kit report.

## Metrics

`scripts/results/parse_benchmark.py` converts the kit's raw telemetry into the
repository metric contract and reproduces the **final report metric set of the
v0.5.0 kit** (`analyze.py` / `report_local_stages.py`, revision `b2b3df1`):

* **write local 7 groups** -- per-commit local stage sums, one sample per write
  commit (61), published as the median;
* **search local 5 items** -- three server-side telemetry groups with one sample
  per replayed question (152, published median), plus the two content-read items
  that the kit defines as run-level aggregates over the QA `content.read`
  requests divided by the number of questions.

| Metric | Unit | Group | Formula |
| --- | --- | --- | --- |
| `write_commit_prepare` | ms/commit | write | `context_prepare` |
| `write_archive_summary_local` | ms/commit | write | `archive_summary.input_prepare + archive_summary.persist` (`0` while working memory is disabled) |
| `write_long_term_prepare` | ms/commit | write | `long_term.default_files + long_term.context_prepare` |
| `write_extraction_local` | ms/commit | write | `extract.long_term.{prompt_schema,json_parse,resolve_operations,existing_check,patch_validate,finalize}` |
| `write_streaming_merge_local` | ms/commit | write | `long_term.streaming.route + long_term.streaming.patch_merge` |
| `write_long_term_finalize` | ms/commit | write | `long_term.memory_diff + long_term.memory_diff_build` |
| `write_relation_and_commit` | ms/commit | write | `active_count_update + max(duration_ms - context_prepare - parallel_extraction - queue_drain, 0)` |
| `search_query_prepare` | ms/query | search | `request_prepare + collection_check` |
| `search_vector_recall` | ms/query | search | `vector_retrieval` |
| `search_result_processing` | ms/query | search | `result_processing` |
| `search_read_agfs` | ms/query | search | sum of the AGFS span union of every `content.read` request, divided by the number of questions |
| `search_read_service_processing` | ms/query | search | sum of `max(server wall time - AGFS span union, 0)` over every `content.read` request, divided by the number of questions |

All metrics are `lower_is_better`. The ten per-item metrics publish the
repository-standard **median** and retain every sample (`samples`,
`sample_values`, `aggregate`); for the write groups this is the same statistic as
the kit report's `p50` column, and `aggregate.avg` carries the average used in the
kit report headline. The two content-read items are run aggregates by definition:
they are published as one `ms/query` sample per run whose `aggregate` block
records `n_reads`, `n_queries` and `total_ms`, and every per-request timing is
retained in `runs/search_read_samples.jsonl`. Nothing else is published: the
persist/vector-upsert group, the parallel tail, `local_net`, the two group sums
and the HTTP response residual of the previous metric set are not part of the
kit's final report contract.

The kit instruments no archive-summary stages while working memory keeps the
v0.5.0 default (`enable_working_memory=false`); the kit's final report still lists
the group and reports it as `0`, so the parser does the same and records the
reason under `protocol.zero_by_design_metrics` instead of dropping the row.

The parser fails closed: it aborts when the kit telemetry is missing, when fewer
than 50 write commits or 120 search rows were recorded, when essential
instrumentation stages are absent (`context_prepare`, `parallel_extraction`,
`queue_drain`, `long_term.default_files`, `long_term.context_prepare`,
`long_term.streaming.route`, `long_term.memory_diff`,
`long_term.memory_diff_build`, `extract.long_term.json_parse`,
`extract.long_term.finalize`, `request_prepare`, `collection_check`,
`vector_retrieval`, `result_processing`), when the AGFS spans or their
`content.read` requests are missing (the five-item contract is not computable),
or when a stage duration is negative or non-finite.

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
  publishes the kit's final report metric set (write 7 groups / search 5 items)
  described above.
* `grader`/`judge` accuracy and token-savings analysis run for protocol
  completeness only; they are excluded from the published metrics.
