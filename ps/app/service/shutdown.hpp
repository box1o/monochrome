#pragma once

#include <ps/result.hpp>
#include <QObject>
#include <QSocketNotifier>
#include <csignal>
#include <memory>

namespace ps {
class Device;
}

namespace mps {
class Shutdown final : public QObject {
public:
    ~Shutdown() override;
    ps::Result<void> start(ps::Device& device);

private:
    int descriptor_ = -1;
    bool blocked_ = false;
    sigset_t previousMask_{};
    std::unique_ptr<QSocketNotifier> notifier_;
};
} // namespace mps
