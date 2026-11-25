cmake_minimum_required(VERSION 3.16)
project(simdjson_benchmarks CXX)

# Offline replacement for simdjson's SIMDJSON_DEVELOPER_MODE benchmark targets.
#
# The library itself is still built by simdjson's own CMakeLists.txt (developer
# mode is OFF, so no CPM bootstrap and no network access during configure).  The
# official sources under benchmark/ are then compiled against that library with
# the same Release options the upstream developer mode uses, which keeps the
# measured binaries byte-comparable with the upstream targets without touching
# any simdjson file.

if(NOT SIMDJSON_SRC OR NOT GOOGLE_BENCHMARK_SRC OR NOT SIMDJSON_DATA_DIR)
  message(FATAL_ERROR "SIMDJSON_SRC, GOOGLE_BENCHMARK_SRC and SIMDJSON_DATA_DIR are required")
endif()

if(NOT EXISTS "${SIMDJSON_SRC}/CMakeLists.txt")
  message(FATAL_ERROR "simdjson source tree not found: ${SIMDJSON_SRC}")
endif()
if(NOT EXISTS "${GOOGLE_BENCHMARK_SRC}/CMakeLists.txt")
  message(FATAL_ERROR "Google Benchmark source tree not found: ${GOOGLE_BENCHMARK_SRC}")
endif()
if(NOT EXISTS "${SIMDJSON_DATA_DIR}/gsoc-2018.json")
  message(FATAL_ERROR "simdjson-data corpus not found: ${SIMDJSON_DATA_DIR}")
endif()

set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Library-only simdjson build: no tools, no tests, no CPM, no network.
set(SIMDJSON_DEVELOPER_MODE OFF CACHE BOOL "" FORCE)
set(SIMDJSON_INSTALL OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

# Google Benchmark without GoogleTest: the suites only need the benchmark runtime.
set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_INSTALL OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE)
set(BENCHMARK_USE_BUNDLED_GTEST OFF CACHE BOOL "" FORCE)

find_package(Threads REQUIRED)
add_subdirectory("${SIMDJSON_SRC}" "${CMAKE_BINARY_DIR}/simdjson" EXCLUDE_FROM_ALL)
add_subdirectory("${GOOGLE_BENCHMARK_SRC}" "${CMAKE_BINARY_DIR}/google-benchmark" EXCLUDE_FROM_ALL)

set(SIMDJSON_BENCHMARK_INCLUDES "${SIMDJSON_SRC}/benchmark" "${SIMDJSON_SRC}/benchmark/linux")
add_compile_definitions("SIMDJSON_BENCHMARK_DATA_DIR=\"${SIMDJSON_DATA_DIR}/\"")

# The suites verify themselves against a DOM reference by comparing an
# accumulation of ``rating * reviews`` with exact double equality.  FMA is
# baseline on aarch64, so GCC contracts that accumulation into a fused
# multiply-add and the ondemand reference can round differently from the DOM
# reference, which upstream reports as "result incorrect" (aarch64 only, the
# x86_64 baseline has no FMA).  The arithmetic is only a verification artefact:
# disabling contraction keeps both platforms bit-identical without touching the
# parsing code or the upstream -O3 settings.
add_compile_options(-ffp-contract=off)

# DOM command line tools (benchmark/dom/parse.cpp and parse_stream.cpp).
foreach(tool IN ITEMS parse parse_stream)
  add_executable("${tool}" "${SIMDJSON_SRC}/benchmark/dom/${tool}.cpp")
  target_include_directories("${tool}" PRIVATE ${SIMDJSON_BENCHMARK_INCLUDES})
  target_link_libraries("${tool}" PRIVATE simdjson Threads::Threads)
endforeach()

# Google Benchmark suites (benchmark/bench_*.cpp), exactly the upstream names.
foreach(suite IN ITEMS bench_parse_call bench_dom_api bench_ondemand)
  add_executable("${suite}" "${SIMDJSON_SRC}/benchmark/${suite}.cpp")
  target_include_directories("${suite}" PRIVATE ${SIMDJSON_BENCHMARK_INCLUDES})
  target_link_libraries("${suite}" PRIVATE simdjson benchmark::benchmark Threads::Threads)
endforeach()
