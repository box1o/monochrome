#include <ps/device.hpp>
#include "transport.hpp"
#include <QSerialPortInfo>

namespace ps {
Device::Device(bool allowWrites, ByteOrder order, QObject* parent)
    : QObject(parent),
      transport_(std::make_unique<Transport>()),
      allowWrites_(allowWrites),
      order_(order) {
    connect(transport_.get(), &Transport::received, this, &Device::ingest);
    connect(transport_.get(), &Transport::failed, this, [this](const QString& message) {
        if (phase_ != "disconnected") {
            disconnectDevice();
            phase_ = "error";
            error_ = message;
            emit changed();
        }
    });
    poll_.setInterval(2000);
    connect(&poll_, &QTimer::timeout, this, [this] {
        if (phase_ == "ready" && !active_ && queue_.empty()) {
            enqueue(refreshSteps(), [this](Result<QJsonObject> result) {
                error_ = result ? QString{} : QString::fromStdString(result.error().message);
                emit changed();
            });
        }
        emit changed();
    });
    poll_.start();
}

Device::~Device() {
    disconnectDevice();
}

QJsonArray Device::ports() {
    QJsonArray ports;
    for (const auto& info : QSerialPortInfo::availablePorts()) {
        if (info.vendorIdentifier() == 0x2e3c && info.productIdentifier() == 0x5740) {
            ports.append(
                QJsonObject{{"port", info.systemLocation()},
                    {"description", info.description()},
                    {"serial", info.serialNumber()},
                    {"vendorId", 0x2e3c},
                    {"productId", 0x5740}}
            );
        }
    }
    return ports;
}

QJsonObject Device::snapshot() const {
    const auto age = measurementAge_.isValid() ? measurementAge_.elapsed() : -1;
    return {{"phase", phase_},
        {"port", port_},
        {"readOnly", !allowWrites_},
        {"byteOrder", order_ == ByteOrder::Little ? "little" : "big"},
        {"busy", active_ != nullptr},
        {"error", error_},
        {"measurementAgeMs", double(age)},
        {"stale", phase_ != "ready" || age < 0 || age > 3000},
        {"values", values_}};
}

} // namespace ps
