#include <ps/device.hpp>
#include "validation.hpp"

namespace ps {
Result<std::vector<Device::Step>> Device::outputSteps(const QJsonObject& params) {
    std::vector<Step> steps;

    if (!params.value("enabled").isBool()) {
        return std::unexpected(invalid("enabled must be boolean"));
    }
    const auto enabled = params.value("enabled").toBool();
    if (enabled) {
        for (auto address : {0xdc, 0xc1, 0xc2, 0xe2, 0xe3}) {
            steps.push_back(read(address));
        }
    }
    auto canEnable = [this, enabled]() -> Result<void> {
        if (enabled && values_.value("protection").toInt(-1) != 0) {
            return std::unexpected(
                Error{"protection_active", "Output cannot be enabled while protection is active or unknown"}
            );
        }
        if (enabled) {
            const auto voltage = values_.value("setVoltage").toDouble(-1);
            const auto current = values_.value("setCurrent").toDouble(-1);
            const auto maxVoltage = std::min(30., values_.value("maxVoltage").toDouble(-1));
            const auto maxCurrent = std::min(5., values_.value("maxCurrent").toDouble(-1));
            if (voltage < 0 || current < 0 || voltage > maxVoltage || current > maxCurrent) {
                return std::unexpected(Error{"device_limit", "Setpoints are outside the current device ceilings"});
            }
        }
        return {};
    };
    addByteWrite(steps, 0xdb, std::uint8_t(enabled), std::move(canEnable));
    return steps;
}

} // namespace ps
