#include <ps/device.hpp>
#include <cmath>
#include <map>
#include <limits>

namespace ps {
namespace {
const std::map<std::uint8_t, QString> ceilings{{0xe2, "maxVoltage"},
    {0xe3, "maxCurrent"},
    {0xe4, "maxOvp"},
    {0xe5, "maxOcp"},
    {0xe6, "maxOpp"},
    {0xe7, "maxOtp"},
    {0xe8, "maxUvp"}};

}

void Device::addWrite(std::vector<Step>& steps, std::uint8_t address, double value, std::uint8_t ceiling) {
    const auto bytes = encodeFloat(float(value), order_);
    Step write{{0xb1, address, bytes}, -1, {}, {}};
    write.before = [this, value, ceiling, address]() -> Result<void> {
        const auto limit = values_.value(ceilings.at(ceiling));
        const auto maximum = address == 0xc1 ? 30.0 : address == 0xc2 ? 5.0 : std::numeric_limits<double>::max();
        if (!limit.isDouble() || limit.toDouble() <= 0 || value > std::min(limit.toDouble(), maximum)) {
            return std::unexpected(Error{"device_limit", "Requested value exceeds the freshly read device ceiling"});
        }
        return {};
    };
    steps.push_back(std::move(write));
    auto verify = read(address);
    verify.verify = [this, value](std::span<const std::uint8_t> bytes) -> Result<void> {
        const auto actual = decodeFloat(bytes, order_);
        if (!actual || std::abs(double(*actual) - value) > 0.011) {
            return std::unexpected(
                Error{"verification_failed", "Setpoint readback did not match; device may have changed partially"}
            );
        }
        return {};
    };
    steps.push_back(std::move(verify));
}

Device::Step Device::read(std::uint8_t address) {
    const bool byte = (address >= 0xd6 && address <= 0xd8) || (address >= 0xdb && address <= 0xdd) || address == 0xe1;
    Step step{{0xa1, address, {0}}, address == 0xc3 ? 12 : byte ? 1 : 4, {}, {}};
    if (!byte && address != 0xc3) {
        step.verify = [this](std::span<const std::uint8_t> data) -> Result<void> {
            const auto value = decodeFloat(data, order_);
            if (!value) {
                return std::unexpected(value.error());
            }
            return {};
        };
    }
    return step;
}

std::vector<Device::Step> Device::refreshSteps() {
    std::vector<Step> steps;
    for (auto address : {0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xdb, 0xdc, 0xdd, 0xe2, 0xe3}) {
        steps.push_back(read(address));
    }
    return steps;
}

void Device::addByteWrite(std::vector<Step>& steps, std::uint8_t address, std::uint8_t value, Check before) {
    steps.push_back({{0xb1, address, {value}}, -1, std::move(before), {}});
    auto verify = read(address);
    verify.verify = [value](std::span<const std::uint8_t> data) -> Result<void> {
        if (data.size() != 1 || data[0] != value) {
            return std::unexpected(Error{"verification_failed", "Device setting readback did not match"});
        }
        return {};
    };
    steps.push_back(std::move(verify));
}

} // namespace ps
