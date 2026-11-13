#include <ps/device.hpp>
#include "transport.hpp"

namespace ps {
void Device::enqueue(std::vector<Step> steps, Completion completion, std::function<bool()> cancelled) {
    if (queue_.size() >= 32) {
        completion(std::unexpected(Error{"busy", "Device queue is full"}));
        return;
    }
    queue_.push_back(
        std::make_unique<Operation>(Operation{std::move(steps), 0, std::move(completion), std::move(cancelled)})
    );
    if (!active_) {
        advance();
    }
}

void Device::advance() {
    if (!active_) {
        if (queue_.empty()) {
            return;
        }
        active_ = std::move(queue_.front());
        queue_.pop_front();
    }
    if (active_->index == active_->steps.size()) {
        finish(snapshot());
        return;
    }
    const auto& step = active_->steps[active_->index];
    const bool outputOff = step.frame.command == 0xb1 && step.frame.address == 0xdb
                           && step.frame.data == std::vector<std::uint8_t>{0};
    if (step.frame.command == 0xb1 && !allowWrites_ && !outputOff) {
        finish(std::unexpected(Error{"read_only", "Device controls were locked before transmission"}));
        return;
    }
    if (step.frame.command == 0xb1 && active_->cancelled && active_->cancelled()) {
        finish(std::unexpected(Error{"cancelled", "Client disconnected before the next write"}));
        return;
    }
    if (step.before) {
        if (auto valid = step.before(); !valid) {
            finish(std::unexpected(valid.error()));
            return;
        }
    }
    const auto generation = generation_;
    transport_->request(
        step.frame,
        step.replySize,
        [this, generation](auto result) {
            if (generation != generation_ || !active_) {
                return;
            }
            if (!result) {
                if (result.error().code == "cancelled") {
                    finish(std::unexpected(result.error()));
                    return;
                }
                const auto message = QString::fromStdString(result.error().message);
                finish(std::unexpected(result.error()));
                disconnectDevice();
                phase_ = "error";
                error_ = message;
                emit changed();
                return;
            }
            auto& step = active_->steps[active_->index];
            if (step.verify) {
                if (auto verified = step.verify(*result); !verified) {
                    finish(std::unexpected(verified.error()));
                    return;
                }
            }
            ++active_->index;
            advance();
        },
        step.frame.command == 0xb1 ? std::function<bool()>([this, outputOff, cancelled = active_->cancelled] {
            return (!allowWrites_ && !outputOff) || (cancelled && cancelled());
        })
                                   : std::function<bool()>{}
    );
}

void Device::finish(Result<QJsonObject> result) {
    auto operation = std::move(active_);
    if (operation) {
        operation->completion(std::move(result));
    }
    emit changed();
    QTimer::singleShot(0, this, &Device::advance);
}

} // namespace ps
