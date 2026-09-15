/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#pragma once

#include <algorithm>
#include <atomic>
#include <chrono>
#include <map>
#include <string>
#include <utility>
#include <vector>
#include <glog/logging.h>
#include <folly/ThreadCachedInt.h>
#include <thrift/perf/cpp2/util/Counter.h>

namespace facebook::thrift::benchmarks {

// Harness addition on top of the upstream QPSStats: a sampled
// per-operation round-trip latency recorder.  Every completed
// request/response call offers a nanosecond send->reply delta; a
// fixed window of samples (one every kSamplingStride completions,
// lock-free) is kept and summarized as avg/p50/p99/max once the run
// ends.  The upstream harness only reports operations per second.
class LatencyStats {
 public:
  static constexpr size_t kMaxSamples = 8192;
  static constexpr uint64_t kSamplingStride = 16;

  void setMeasuring(bool measuring) { measuring_.store(measuring); }

  void offer(uint64_t latencyNs) {
    if (!measuring_.load(std::memory_order_relaxed)) {
      return;
    }
    uint64_t slot = completions_.fetch_add(1, std::memory_order_relaxed);
    if ((slot % kSamplingStride) != 0) {
      return;
    }
    size_t index = filled_.fetch_add(1, std::memory_order_relaxed);
    if (index >= kMaxSamples) {
      return;
    }
    samples_[index].store(latencyNs, std::memory_order_relaxed);
  }

  // Printed once by the client main after all worker threads joined,
  // in a format the benchmark collector parses ("LATENCY ns").
  void summarize() const {
    size_t filled = std::min(filled_.load(), kMaxSamples);
    if (filled == 0) {
      LOG(INFO) << " | LATENCY ns | samples: 0";
      return;
    }
    std::vector<uint64_t> sorted;
    sorted.reserve(filled);
    for (size_t i = 0; i < filled; ++i) {
      sorted.push_back(samples_[i].load(std::memory_order_relaxed));
    }
    std::sort(sorted.begin(), sorted.end());
    double total = 0;
    for (uint64_t value : sorted) {
      total += static_cast<double>(value);
    }
    auto percentile = [&](double p) -> uint64_t {
      size_t index = static_cast<size_t>(p * static_cast<double>(filled - 1));
      return sorted[index];
    };
    LOG(INFO) << std::fixed << " | LATENCY ns | avg: "
              << (total / static_cast<double>(filled))
              << " | p50: " << percentile(0.50)
              << " | p99: " << percentile(0.99)
              << " | max: " << sorted[filled - 1]
              << " | samples: " << filled;
  }

 private:
  std::atomic<bool> measuring_{false};
  std::atomic<uint64_t> completions_{0};
  std::atomic<size_t> filled_{0};
  std::atomic<uint64_t> samples_[kMaxSamples]{};
};

class QPSStats {
 public:
  void printStats(double secsSinceLastPrint) {
    double totalQPS = 0;
    for (auto& pair : counters_) {
      totalQPS += pair.second->print(secsSinceLastPrint);
    }
    LOG(INFO) << std::scientific << " | TOTAL QPS: " << totalQPS;
  }

  LatencyStats& latency() { return latency_; }

  void registerCounter(std::string name) {
    // TODO: Each thread in the Runner creates an instance of an Operation.
    // Each instance of the operation calls registerCounter with given name.
    // So this function is being called as the number of threads.
    // We should make this function to be called per type of the Operation, not
    // per instance.
    std::lock_guard<std::mutex> guard(mutex_);
    counters_.emplace(name, std::make_unique<Counter>(name));
  }

  void add(std::string& name) { ++(*counters_[name]); }

  void add(std::string& name, uint32_t sz) { (*counters_[name]) += sz; }

 private:
  std::map<std::string, std::unique_ptr<Counter>> counters_;
  std::mutex mutex_;
  LatencyStats latency_;
};

} // namespace facebook::thrift::benchmarks
