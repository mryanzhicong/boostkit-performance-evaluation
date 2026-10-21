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

start_envoy_process() {
    local name="$1" configuration="$2" pid_file="$3"
    "${ENVOY_BIN}" --config-path "${configuration}" --disable-hot-restart \
        > "${RUNTIME_DIR}/${name}.log" 2>&1 &
    printf '%s\n' "$!" > "${pid_file}"
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
    write_runtime_configurations || {
        log_message "ERROR: failed to generate isolated Envoy runtime configurations"
        return 40
    }
    start_envoy_process backend "${RUNTIME_DIR}/backend.yaml" "${BACKEND_PID_FILE}"
    start_envoy_process direct "${RUNTIME_DIR}/direct.yaml" "${DIRECT_PID_FILE}"
    start_envoy_process proxy "${RUNTIME_DIR}/proxy.yaml" "${PROXY_PID_FILE}"
    wait_for_https_service 'https://127.0.0.1:19000/' || return $?
    wait_for_https_service 'https://127.0.0.1:19001/' || return $?
    log_message "Envoy direct-response and reverse-proxy scenarios are ready"
}
