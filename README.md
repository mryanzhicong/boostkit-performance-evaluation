# Performance result history

This branch is maintained by the manually triggered performance workflow.

Existing results were cleared before adopting the current result layout. New result
directories use UTC+8 time and the format
`YYYY-MM-DD-HH-MM-SS_RUN_ID-ATTEMPT`.

Each architecture keeps its normalized data, report, declared JSON outputs, and
original test-stage stdout/stderr in `raw-output.log`. Other stage logs remain in
GitHub Actions artifacts.
