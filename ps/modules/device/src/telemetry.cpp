#include <ps/device.hpp>
#include <map>

namespace ps {
namespace {
const std::map<std::uint8_t, QString> names{{0xc0, "inputVoltage"},
    {0xc1, "setVoltage"},
    {0xc2, "setCurrent"},
    {0xc4, "temperature"},
    {0xd1, "ovp"},
    {0xd2, "ocp"},
    {0xd3, "opp"},
    {0xd4, "otp"},
    {0xd5, "uvp"},
    {0xd6, "brightness"},
    {0xd7, "volume"},
    {0xd8, "metering"},
    {0xd9, "capacity"},
    {0xda, "energy"},
    {0xdb, "outputEnabled"},
    {0xdc, "protection"},
    {0xdd, "mode"},
    {0xe1, "address"},
    {0xe2, "maxVoltage"},
    {0xe3, "maxCurrent"},
    {0xe4, "maxOvp"},
    {0xe5, "maxOcp"},
    {0xe6, "maxOpp"},
    {0xe7, "maxOtp"},
    {0xe8, "maxUvp"}};
}

void Device::ingest(const Frame& frame) {
    if (frame.command != 0xa1) {
        return;
    }
    if (frame.address == 0xc3 && frame.data.size() == 12) {
        const auto voltage = decodeFloat(std::span(frame.data).subspan(0, 4), order_);
        const auto current = decodeFloat(std::span(frame.data).subspan(4, 4), order_);
        const auto power = decodeFloat(std::span(frame.data).subspan(8, 4), order_);
        if (voltage && current && power) {
            values_["voltage"] = *voltage;
            values_["current"] = *current;
            values_["power"] = *power;
            measurementAge_.start();
            emit changed();
        }
        return;
    }
    const auto entry = names.find(frame.address);
    if (entry != names.end()) {
        if (frame.data.size() == 4) {
            if (const auto value = decodeFloat(frame.data, order_)) {
                values_[entry->second] = *value;
            }
        } else if (frame.data.size() == 1) {
            values_[entry->second] = int(frame.data[0]);
        }
    } else if (frame.address >= 0xc5 && frame.address <= 0xd0 && frame.data.size() == 4) {
        if (const auto value = decodeFloat(frame.data, order_)) {
            values_[QString("preset%1%2")
                    .arg((frame.address - 0xc5) / 2 + 1)
                    .arg((frame.address - 0xc5) % 2 ? "Current" : "Voltage")] = *value;
        }
    }
    emit changed();
}

} // namespace ps
