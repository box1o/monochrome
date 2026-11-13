#include <ps/device.hpp>
#include "transport.hpp"

namespace ps {
void Device::openSession(QString path, Completion completion) {
    if (transport_->isOpen() || active_) {
        completion(std::unexpected(Error{"already_connected", "Disconnect before selecting another supply"}));
        return;
    }
    if (path.isEmpty()) {
        const auto available = ports();
        if (available.size() != 1) {
            completion(
                std::unexpected(Error{"device_selection", "Expected one DPS-150; use devices and specify --port"})
            );
            return;
        }
        path = available[0].toObject().value("port").toString();
    }
    if (auto opened = transport_->open(path); !opened) {
        completion(std::unexpected(opened.error()));
        return;
    }
    phase_ = "connecting";
    port_ = path;
    error_.clear();
    values_ = {};
    auto steps = refreshSteps();
    steps.insert(steps.begin(), {{0xc1, 0, {1}}, -1, {}, {}});
    enqueue(std::move(steps), [this, completion = std::move(completion)](auto result) {
        phase_ = result ? "ready" : "error";
        error_ = result ? QString{} : QString::fromStdString(result.error().message);
        if (result) {
            completion(snapshot());
        } else {
            completion(std::unexpected(result.error()));
        }
        emit changed();
    });
}

void Device::closeSession(Completion completion) {
    if (!transport_->isOpen()) {
        disconnectDevice();
        completion(snapshot());
        return;
    }
    enqueue({{{0xc1, 0, {0}}, -1, {}, {}}}, [this, completion = std::move(completion)](auto result) {
        disconnectDevice();
        if (result) {
            completion(snapshot());
        } else {
            completion(std::unexpected(result.error()));
        }
    });
}

void Device::disconnectDevice() {
    ++generation_;
    phase_ = "disconnected";
    auto pending = std::move(queue_);
    queue_.clear();
    if (active_) {
        pending.push_front(std::move(active_));
    }
    transport_->close();
    for (const auto& operation : pending) {
        operation->completion(std::unexpected(Error{"disconnected", "Operation cancelled; no writes replayed"}));
    }
    values_ = {};
    measurementAge_.invalidate();
    port_.clear();
    emit changed();
}
} // namespace ps
