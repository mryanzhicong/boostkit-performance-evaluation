// Multi-scale builder/accessor driver for the FlatBuffers performance case.
//
// The driver is deliberately small and deterministic: it serializes a
// `[uint32]` vector into a FlatBuffer and immediately reads it back through the
// generated accessor, either together (merged), build-only, or access-only.
// The checksum is the sum of every value read back, so a build that produced a
// wrong or truncated buffer cannot finish successfully.
//
// The matrix mirrors the representative load of the delivery manual (1000
// uint32 values, 10000 build+access iterations, checksum 4995000000) while
// shrinking or growing the payload so that several payload scales are covered
// with a comparable amount of total work.
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>

#include "driver_generated.h"
#include "flatbuffers/flatbuffers.h"

using namespace fbperf;

namespace {

// Build-only runs never read the produced buffer back, so the compiler is free
// to eliminate the whole builder work as dead stores.  Publishing the buffer
// address through a volatile sink makes the memory observable (it "escapes") and
// keeps the measurement honest, without adding any real read work.
volatile const uint8_t *g_buffer_sink = nullptr;

struct Options {
  const char *mode = "merged";
  int64_t elements = 1000;
  int64_t iterations = 10000;
};

Options parse_options(int argc, char **argv) {
  Options options;
  for (int i = 1; i < argc; ++i) {
    if (std::strcmp(argv[i], "--mode") == 0 && i + 1 < argc) {
      options.mode = argv[++i];
    } else if (std::strcmp(argv[i], "--elements") == 0 && i + 1 < argc) {
      options.elements = std::atoll(argv[++i]);
    } else if (std::strcmp(argv[i], "--iterations") == 0 && i + 1 < argc) {
      options.iterations = std::atoll(argv[++i]);
    } else if (std::strcmp(argv[i], "--help") == 0) {
      std::printf(
          "usage: %s [--mode merged|build|access] [--elements N] "
          "[--iterations M]\n",
          argv[0]);
      std::exit(0);
    } else {
      std::fprintf(stderr, "unknown argument: %s\n", argv[i]);
      std::exit(2);
    }
  }
  if (options.elements <= 0 || options.iterations <= 0) {
    std::fprintf(stderr, "elements and iterations must be positive\n");
    std::exit(2);
  }
  if (std::strcmp(options.mode, "merged") != 0 &&
      std::strcmp(options.mode, "build") != 0 &&
      std::strcmp(options.mode, "access") != 0) {
    std::fprintf(stderr, "invalid mode: %s\n", options.mode);
    std::exit(2);
  }
  return options;
}

}  // namespace

int main(int argc, char **argv) {
  const Options options = parse_options(argc, argv);
  const bool do_build = std::strcmp(options.mode, "access") != 0;
  const bool do_access = std::strcmp(options.mode, "build") != 0;

  std::vector<uint32_t> values(static_cast<size_t>(options.elements));
  for (int64_t i = 0; i < options.elements; ++i) {
    values[static_cast<size_t>(i)] = static_cast<uint32_t>(i);
  }

  flatbuffers::FlatBufferBuilder fbb(1024);
  int64_t checksum = 0;
  int64_t encoded_bytes = 0;
  int64_t encoded_size = 0;

  const auto build_once = [&]() {
    fbb.Clear();
    auto vec = fbb.CreateVector(values);
    PayloadBuilder builder(fbb);
    builder.add_values(vec);
    auto root = builder.Finish();
    fbb.Finish(root);
    encoded_size = static_cast<int64_t>(fbb.GetSize());
    g_buffer_sink = fbb.GetBufferPointer();
  };
  const auto access_once = [&]() {
    auto payload = GetPayload(fbb.GetBufferPointer());
    auto vec = payload->values();
    for (uint32_t i = 0; i < vec->size(); ++i) checksum += vec->Get(i);
  };

  if (do_build) {
    for (int64_t i = 0; i < options.iterations; ++i) {
      build_once();
      encoded_bytes += encoded_size;
      if (do_access) access_once();
    }
  } else {
    // Access-only mode builds one buffer and repeatedly traverses it, so the
    // measurement isolates the accessor path from the builder path.
    build_once();
    encoded_bytes = encoded_size * options.iterations;
    for (int64_t i = 0; i < options.iterations; ++i) access_once();
  }

  const int64_t expected =
      do_access ? (options.elements * (options.elements - 1) / 2) * options.iterations : 0;
  std::printf(
      "[fb-bench] mode=%s elements=%lld iterations=%lld encoded_bytes=%lld "
      "encoded_size=%lld checksum=%lld expected=%lld\n",
      options.mode, static_cast<long long>(options.elements),
      static_cast<long long>(options.iterations),
      static_cast<long long>(encoded_bytes), static_cast<long long>(encoded_size),
      static_cast<long long>(checksum), static_cast<long long>(expected));
  if (checksum != expected) {
    std::fprintf(stderr, "checksum mismatch: got %lld, expected %lld\n",
                 static_cast<long long>(checksum),
                 static_cast<long long>(expected));
    return 3;
  }
  return 0;
}
