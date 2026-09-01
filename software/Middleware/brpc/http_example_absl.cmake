# The BRPC 1.17 standalone http_c++ example predates the Abseil dependency
# introduced by recent Protobuf releases.  Keep this list aligned with the
# Protobuf dependency targets in BRPC's top-level CMakeLists.txt.
if(Protobuf_VERSION GREATER 4.21)
    find_package(absl REQUIRED CONFIG)
    set(BRPC_HTTP_EXAMPLE_ABSL_TARGETS
        absl::absl_check
        absl::absl_log
        absl::algorithm
        absl::base
        absl::bind_front
        absl::bits
        absl::btree
        absl::cleanup
        absl::cord
        absl::core_headers
        absl::debugging
        absl::die_if_null
        absl::dynamic_annotations
        absl::flags
        absl::flat_hash_map
        absl::flat_hash_set
        absl::function_ref
        absl::hash
        absl::layout
        absl::log_initialize
        absl::log_severity
        absl::memory
        absl::node_hash_map
        absl::node_hash_set
        absl::optional
        absl::span
        absl::status
        absl::statusor
        absl::strings
        absl::synchronization
        absl::time
        absl::type_traits
        absl::utility
        absl::variant
    )
endif()
