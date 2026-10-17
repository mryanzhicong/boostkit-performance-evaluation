# fbthrift official perf harness (thrift/perf/cpp2): server + client.
#
# The IDL (if/), the operation/driver/util glue (util/) and the
# BenchmarkHandler are the upstream Apache-2.0 sources from the
# fbthrift repository (thrift/perf/cpp2), with the http2 transport
# branch dropped: that branch needs proxygen, which the standalone
# fbthrift CMake build does not ship (header and rocket only).
#
# The stubs are regenerated with the thrift1 compiler installed by the
# fbthrift build under FBTHRIFT_PREFIX, mirroring the official
# add_fbthrift_cpp_library() invocation (--legacy-strict, mstch_cpp2
# with include_prefix), so the generated code lives under the same
# thrift/perf/cpp2/if/gen-cpp2/ include path the upstream sources use.

cmake_minimum_required(VERSION 3.20)
project(fbthrift_perf LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT DEFINED FBTHRIFT_PREFIX)
  message(FATAL_ERROR "pass -DFBTHRIFT_PREFIX=<isolated fbthrift install prefix>")
endif()
list(PREPEND CMAKE_PREFIX_PATH "${FBTHRIFT_PREFIX}")

# FBThriftConfig.cmake documents that wangle (and its fizz/folly chain)
# must be found before FBThrift; everything resolves against the
# isolated prefix.
find_package(folly CONFIG REQUIRED)
find_package(fizz CONFIG REQUIRED)
find_package(wangle CONFIG REQUIRED)
find_package(mvfst CONFIG REQUIRED)
find_package(FBThrift CONFIG REQUIRED)

# FBThriftConfig.cmake exposes the compiler path via FBTHRIFT_COMPILER
# (the FBThrift::thrift1 target); fall back to the explicit prefix path.
if(DEFINED FBTHRIFT_COMPILER AND EXISTS "${FBTHRIFT_COMPILER}")
  set(THRIFT1 "${FBTHRIFT_COMPILER}")
else()
  set(THRIFT1 "${FBTHRIFT_PREFIX}/bin/thrift1")
endif()
if(NOT EXISTS "${THRIFT1}")
  message(FATAL_ERROR "the fbthrift compiler is missing: ${THRIFT1}")
endif()

set(PERF_IF "${CMAKE_CURRENT_SOURCE_DIR}/thrift/perf/cpp2/if")
set(GEN_OUT "${CMAKE_CURRENT_BINARY_DIR}/thrift/perf/cpp2/if")

# The output file list mirrors add_fbthrift_cpp_library() from the
# fbthrift sources (build/fbcode_builder/CMake/FBThriftCppLibrary.cmake).
function(gen_thrift_file base)
  set(_outs
    "${GEN_OUT}/gen-cpp2/${base}_constants.h"
    "${GEN_OUT}/gen-cpp2/${base}_constants.cpp"
    "${GEN_OUT}/gen-cpp2/${base}_data.h"
    "${GEN_OUT}/gen-cpp2/${base}_data.cpp"
    "${GEN_OUT}/gen-cpp2/${base}_types.h"
    "${GEN_OUT}/gen-cpp2/${base}_types.cpp"
    "${GEN_OUT}/gen-cpp2/${base}_types_binary.cpp"
    "${GEN_OUT}/gen-cpp2/${base}_types_compact.cpp"
    "${GEN_OUT}/gen-cpp2/${base}_types_serialization.cpp"
    "${GEN_OUT}/gen-cpp2/${base}_metadata.h"
    "${GEN_OUT}/gen-cpp2/${base}_metadata.cpp")
  foreach(_service IN LISTS ARGN)
    list(APPEND _outs
      "${GEN_OUT}/gen-cpp2/${_service}.h"
      "${GEN_OUT}/gen-cpp2/${_service}.cpp"
      "${GEN_OUT}/gen-cpp2/${_service}AsyncClient.h"
      "${GEN_OUT}/gen-cpp2/${_service}AsyncClient.cpp"
      "${GEN_OUT}/gen-cpp2/${_service}_processmap_binary.cpp"
      "${GEN_OUT}/gen-cpp2/${_service}_processmap_compact.cpp")
  endforeach()
  add_custom_command(
    OUTPUT ${_outs}
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${GEN_OUT}"
    COMMAND "${THRIFT1}" --legacy-strict
            --gen "mstch_cpp2:include_prefix=thrift/perf/cpp2/if"
            -I "${FBTHRIFT_PREFIX}/include"
            -I "${CMAKE_CURRENT_SOURCE_DIR}"
            -o "${GEN_OUT}"
            "${PERF_IF}/${base}.thrift"
    DEPENDS "${PERF_IF}/${base}.thrift"
    COMMENT "thrift1 ${base}.thrift"
    VERBATIM)
  set(PERF_GENERATED ${PERF_GENERATED} ${_outs} PARENT_SCOPE)
endfunction()

gen_thrift_file(ApiBase)
gen_thrift_file(Api Benchmark)
gen_thrift_file(StreamApi StreamBenchmark)

add_library(perf_generated STATIC ${PERF_GENERATED})
target_include_directories(perf_generated PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_BINARY_DIR}")
# FBThrift::thriftcpp2 carries the whole dependency closure (folly,
# fizz, wangle, mvfst, fmt, boost, glog, gflags, zstd, xxhash,
# openssl, libevent, libsodium) through its exported interface.
target_link_libraries(perf_generated PUBLIC FBThrift::thriftcpp2)

add_executable(perf_server thrift/perf/cpp2/server/Server.cpp)
target_link_libraries(perf_server PRIVATE perf_generated)
# Server.cpp/Client.cpp include the generated headers, so the codegen
# must finish before these targets start compiling (a plain link
# dependency would not order the compile step).
add_dependencies(perf_server perf_generated)

add_executable(perf_client
  thrift/perf/cpp2/client/Client.cpp
  thrift/perf/cpp2/util/Util.cpp)
# The upstream build compiles the client with STREAM_PERF_TEST so the
# download/upload/stream operations (util/StreamOps.h) are registered.
target_compile_definitions(perf_client PRIVATE STREAM_PERF_TEST=1)
target_link_libraries(perf_client PRIVATE perf_generated)
add_dependencies(perf_client perf_generated)
