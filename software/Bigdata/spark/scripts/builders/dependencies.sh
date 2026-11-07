#!/usr/bin/env bash
# Only this disposable package downloader may use host networking; it starts no services.
install_spark_dependencies() (
    local image="$1" fetch="$SPARK_CONTAINER-rpm-fetch"
    trap 'rc=$?; remove_spark_fetch_container || rc=70; exit "$rc"' EXIT
    trap 'exit 130' INT TERM
    if docker exec -e "RESULTS_DIR=$RESULTS_DIR" -e "EXPECTED_ARCH=$EXPECTED_ARCH" "$SPARK_CONTAINER" \
        python3 "$SCRIPT_DIR/scripts/configure_repositories.py"; then
        docker exec "$SPARK_CONTAINER" python3 "$SCRIPT_DIR/scripts/system_dependencies.py" online
        return $?
    fi
    echo '[dependencies] Private bridge cannot reach repositories; fetching signed RPMs in a disposable download-only container'
    docker container inspect "$fetch" >/dev/null 2>&1 && { echo 'Refusing existing downloader'; return 30; }
    local -a command=(docker run --rm --name "$fetch" --network host
        --label "boostkit.spark.run-id=$PERF_RUN_ID"
        --mount "type=bind,source=$PERF_WORK_DIR,target=$PERF_WORK_DIR"
        --mount "type=bind,source=$RESULTS_DIR,target=$RESULTS_DIR"
        --mount "type=bind,source=$(dirname "$SCRIPT_DIR"),target=$(dirname "$SCRIPT_DIR"),readonly"
        -e "PERF_WORK_DIR=$PERF_WORK_DIR" -e "RESULTS_DIR=$RESULTS_DIR" -e "EXPECTED_ARCH=$EXPECTED_ARCH")
    if [[ -n "${PERF_PROXY:-}" ]]; then
        command+=(-e "http_proxy=$PERF_PROXY" -e "https_proxy=$PERF_PROXY"
            --mount type=bind,source=/home/runner/software/anchors,target=/etc/pki/ca-trust/source/anchors,readonly)
    fi
    command+=("$image" bash -c
        'if [[ -n "${https_proxy:-}" ]]; then update-ca-trust extract || exit; fi; exec python3 "$1" fetch'
        -- "$SCRIPT_DIR/scripts/system_dependencies.py")
    timeout --signal=TERM --kill-after=30 1800 "${command[@]}" || return 30
    docker exec -e "PERF_WORK_DIR=$PERF_WORK_DIR" -e "RESULTS_DIR=$RESULTS_DIR" -e "EXPECTED_ARCH=$EXPECTED_ARCH" \
        "$SPARK_CONTAINER" python3 "$SCRIPT_DIR/scripts/system_dependencies.py" offline || return 30
)
