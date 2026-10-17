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

#include <folly/SocketAddress.h>
#include <folly/io/async/AsyncSSLSocket.h>
#include <folly/io/async/AsyncSocket.h>
#include <folly/io/async/EventBase.h>
#include <folly/io/async/ScopedEventBaseThread.h>
#include <thrift/lib/cpp2/async/HeaderClientChannel.h>
#include <thrift/lib/cpp2/async/RocketClientChannel.h>
#include <thrift/lib/cpp2/server/ThriftServer.h>

// The upstream Util.h additionally supports the http2 transport via
// thrift/lib/cpp2/transport/http2 (H2ClientConnection), which is only
// built when proxygen is available. The standalone fbthrift CMake
// build ships header + rocket, so the http2 branch is dropped here
// (along with the test-only ServerConfigsMock include, whose headers
// are not part of the installed package).

using apache::thrift::HeaderClientChannel;
using apache::thrift::RocketClientChannel;
using apache::thrift::ThriftServerAsyncProcessorFactory;

namespace apache::thrift::perf {
folly::AsyncSocket::UniquePtr getSocket(
    folly::EventBase* evb,
    const folly::SocketAddress& addr,
    bool encrypted,
    std::list<std::string> advertizedProtocols = {});

} // namespace apache::thrift::perf

template <typename AsyncClient>
static std::unique_ptr<AsyncClient> newHeaderClient(
    folly::EventBase* evb, const folly::SocketAddress& addr) {
  auto sock = apache::thrift::perf::getSocket(evb, addr, false);
  auto chan = HeaderClientChannel::newChannel(std::move(sock));
  return std::make_unique<AsyncClient>(std::move(chan));
}

template <typename AsyncClient>
static std::unique_ptr<AsyncClient> newRocketClient(
    folly::EventBase* evb, const folly::SocketAddress& addr, bool encrypted) {
  auto sock = apache::thrift::perf::getSocket(evb, addr, encrypted, {"rs2"});
  RocketClientChannel::Ptr channel =
      RocketClientChannel::newChannel(std::move(sock));
  return std::make_unique<AsyncClient>(std::move(channel));
}

template <typename AsyncClient>
static std::unique_ptr<AsyncClient> newClient(
    folly::EventBase* evb,
    const folly::SocketAddress& addr,
    folly::StringPiece transport,
    bool encrypted = false) {
  if (transport == "header") {
    return newHeaderClient<AsyncClient>(evb, addr);
  }
  if (transport == "rocket") {
    return newRocketClient<AsyncClient>(evb, addr, encrypted);
  }
  return nullptr;
}

template <typename AsyncClient>
class ConnectionThread : public folly::ScopedEventBaseThread {
 public:
  ~ConnectionThread() override {
    getEventBase()->runInEventBaseThreadAndWait([&] { connection_.reset(); });
  }

  ConnectionThread() = default;

  ConnectionThread(const ConnectionThread&) = delete;
  ConnectionThread& operator=(const ConnectionThread&) = delete;
  ConnectionThread(ConnectionThread&&) = delete;
  ConnectionThread& operator=(ConnectionThread&&) = delete;

  std::shared_ptr<AsyncClient> newSyncClient(
      const folly::SocketAddress& addr,
      folly::StringPiece transport,
      bool encrypted = false) {
    DCHECK(connection_ == nullptr);
    getEventBase()->runInEventBaseThreadAndWait([&]() {
      connection_ =
          newClient<AsyncClient>(getEventBase(), addr, transport, encrypted);
    });
    return connection_;
  }

 private:
  std::shared_ptr<AsyncClient> connection_;
};
