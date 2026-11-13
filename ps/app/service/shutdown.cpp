#include "shutdown.hpp"
#include <ps/device.hpp>
#include <QCoreApplication>
#include <cerrno>
#include <cstring>
#include <sys/signalfd.h>
#include <unistd.h>

namespace mps {
Shutdown::~Shutdown() {
    notifier_.reset();
    if (descriptor_ >= 0) {
        close(descriptor_);
    }
    if (blocked_) {
        sigprocmask(SIG_SETMASK, &previousMask_, nullptr);
    }
}

ps::Result<void> Shutdown::start(ps::Device& device) {
    sigset_t terminationSignals;
    sigemptyset(&terminationSignals);
    sigaddset(&terminationSignals, SIGINT);
    sigaddset(&terminationSignals, SIGTERM);
    if (sigprocmask(SIG_BLOCK, &terminationSignals, &previousMask_) != 0) {
        return std::unexpected(ps::Error{"signal_setup", std::strerror(errno)});
    }
    blocked_ = true;
    descriptor_ = signalfd(-1, &terminationSignals, SFD_NONBLOCK | SFD_CLOEXEC);
    if (descriptor_ < 0) {
        return std::unexpected(ps::Error{"signal_setup", std::strerror(errno)});
    }

    notifier_ = std::make_unique<QSocketNotifier>(descriptor_, QSocketNotifier::Read);
    connect(notifier_.get(), &QSocketNotifier::activated, this, [this, &device] {
        signalfd_siginfo signal{};
        if (read(descriptor_, &signal, sizeof(signal)) != sizeof(signal)) {
            return;
        }
        notifier_->setEnabled(false);
        device.execute("disconnect", {}, [](auto) { QCoreApplication::quit(); });
        QTimer::singleShot(2000, this, &QCoreApplication::quit);
    });
    return {};
}
} // namespace mps
