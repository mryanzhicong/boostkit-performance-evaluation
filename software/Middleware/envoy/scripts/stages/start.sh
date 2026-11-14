#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

write_runtime_configurations() {
    mkdir -p "${RUNTIME_DIR}" || return 40
    openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
        -keyout "${RUNTIME_DIR}/tls.key" -out "${RUNTIME_DIR}/tls.crt" \
        -subj '/CN=localhost' >/dev/null 2>&1 || return 40

    cat > "${RUNTIME_DIR}/backend.yaml" <<EOF
static_resources:
  listeners:
  - name: backend
    address:
      socket_address: { address: 127.0.0.1, port_value: 18080 }
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: backend
          route_config:
            name: backend_route
            virtual_hosts:
            - name: backend
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                direct_response: { status: 200, body: { inline_string: "ok" } }
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
admin:
  access_log_path: /dev/null
  address:
    socket_address: { address: 127.0.0.1, port_value: 18081 }
EOF
    cat > "${RUNTIME_DIR}/direct.yaml" <<EOF
static_resources:
  listeners:
  - name: direct_tls
    address:
      socket_address: { address: 127.0.0.1, port_value: 19000 }
    filter_chains:
    - transport_socket:
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificates:
            - certificate_chain: { filename: "${RUNTIME_DIR}/tls.crt" }
              private_key: { filename: "${RUNTIME_DIR}/tls.key" }
      filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: direct
          route_config:
            name: direct_route
            virtual_hosts:
            - name: direct
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                direct_response: { status: 200, body: { inline_string: "ok" } }
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
admin:
  access_log_path: /dev/null
  address:
    socket_address: { address: 127.0.0.1, port_value: 19002 }
EOF
    cat > "${RUNTIME_DIR}/proxy.yaml" <<EOF
static_resources:
  listeners:
  - name: proxy_tls
    address:
      socket_address: { address: 127.0.0.1, port_value: 19001 }
    filter_chains:
    - transport_socket:
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificates:
            - certificate_chain: { filename: "${RUNTIME_DIR}/tls.crt" }
              private_key: { filename: "${RUNTIME_DIR}/tls.key" }
      filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: proxy
          route_config:
            name: proxy_route
            virtual_hosts:
            - name: proxy
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                route: { cluster: local_backend }
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
  clusters:
  - name: local_backend
    type: STATIC
    connect_timeout: 1s
    load_assignment:
      cluster_name: local_backend
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address: { address: 127.0.0.1, port_value: 18080 }
admin:
  access_log_path: /dev/null
  address:
    socket_address: { address: 127.0.0.1, port_value: 19003 }
EOF
}

start_envoy_container() {
    local dnf_options=()
    local -a mounts=(--mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}")
    if [[ "${RESULTS_DIR}" != "${PERF_WORK_DIR}" && "${RESULTS_DIR}" != "${PERF_WORK_DIR}/"* ]]; then
        mounts+=(--mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}")
    fi
    mounts+=(--mount "type=bind,source=/etc/passwd,target=/etc/passwd,readonly")
    mounts+=(--mount "type=bind,source=/etc/group,target=/etc/group,readonly")
    if [[ -n "${PERF_PROXY:-}" ]]; then
        if [[ ! -d "${ENVOY_CA_ANCHORS_DIR}" ]]; then
            log_message "ERROR: proxy CA certificate directory is missing: ${ENVOY_CA_ANCHORS_DIR}"
            return 30
        fi
        mounts+=(--mount "type=bind,source=${ENVOY_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly")
    fi
    if docker container inspect "${ENVOY_CONTAINER_NAME}" >/dev/null 2>&1; then
        log_message "ERROR: refusing to reuse an existing Envoy container: ${ENVOY_CONTAINER_NAME}"
        return 40
    fi
    log_message "starting task-private Envoy container ${ENVOY_CONTAINER_NAME} from ${ENVOY_CONTAINER_IMAGE}"
    docker run --detach --name "${ENVOY_CONTAINER_NAME}" \
        --label "boostkit.envoy.run-id=${PERF_RUN_ID}" \
        --network=host --user "$(id -u):$(id -g)" \
        --ulimit "nofile=1048576:1048576" \
        "${mounts[@]}" "${ENVOY_CONTAINER_IMAGE}" sleep infinity >/dev/null || return 40

    if [[ -n "${PERF_PROXY:-}" ]]; then
        log_message "updating CA trust in the private Envoy container"
        docker exec --user 0 "${ENVOY_CONTAINER_NAME}" update-ca-trust extract || {
            log_message "ERROR: failed to update CA trust in the Envoy container"
            return 30
        }
    fi
    log_message "switching private Envoy container repositories to the Huawei openEuler mirror"
    docker exec --user 0 "${ENVOY_CONTAINER_NAME}" sed -i \
        -e '/^meta/ s/^\(.*\)$/#\1/g' \
        -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
        /etc/yum.repos.d/openEuler.repo || {
        log_message "ERROR: failed to update openEuler repositories in the Envoy container"
        return 30
    }
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing Envoy/k6 runtime dependencies inside the private container"
    docker exec --user 0 "${ENVOY_CONTAINER_NAME}" \
        dnf "${dnf_options[@]}" install -y python3 bash libstdc++ || return 30
}

start_envoy_process() {
    local name="$1" configuration="$2"
    docker exec -d --user "$(id -u):$(id -g)" \
        --env "TMPDIR=${TMPDIR}" "${ENVOY_CONTAINER_NAME}" \
        bash -c "exec '${ENVOY_BIN}' --config-path '${configuration}' --disable-hot-restart > '${RUNTIME_DIR}/${name}.log' 2>&1" || {
        log_message "ERROR: failed to start the ${name} Envoy process inside the container"
        return 40
    }
}

wait_for_https_service() {
    local url="$1" attempts=30
    while (( attempts > 0 )); do
        if curl --silent --show-error --fail --insecure "${url}" >/dev/null; then
            return 0
        fi
        sleep 1
        ((attempts--))
    done
    log_message "ERROR: Envoy service did not become ready: ${url}"
    return 40
}

start_envoy_runtime() {
    initialize_runtime || return $?
    [[ -x "${ENVOY_BIN}" && -x "${K6_BIN}" ]] || {
        log_message "ERROR: Envoy build artifacts are unavailable"
        return 40
    }
    [[ ! -e "${RUNTIME_DIR}" ]] || {
        log_message "ERROR: Envoy runtime directory is not clean: ${RUNTIME_DIR}"
        return 20
    }
    prepare_envoy_container_image || return $?
    write_runtime_configurations || {
        log_message "ERROR: failed to generate isolated Envoy runtime configurations"
        return 40
    }
    start_envoy_container || return $?
    start_envoy_process backend "${RUNTIME_DIR}/backend.yaml" || return $?
    start_envoy_process direct "${RUNTIME_DIR}/direct.yaml" || return $?
    start_envoy_process proxy "${RUNTIME_DIR}/proxy.yaml" || return $?
    wait_for_https_service 'https://127.0.0.1:19000/' || return $?
    wait_for_https_service 'https://127.0.0.1:19001/' || return $?
    log_message "Envoy direct-response and reverse-proxy scenarios are ready inside ${ENVOY_CONTAINER_NAME}"
}
