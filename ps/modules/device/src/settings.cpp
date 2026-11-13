#include <ps/device.hpp>
#include "validation.hpp"
#include <map>
#include <cmath>

namespace ps {
Result<std::vector<Device::Step>> Device::settingsSteps(const QJsonObject& params) {
    std::vector<Step> steps;

    static const std::map<QString, std::pair<int, int>> fields{{"brightness", {0xd6, 14}},
        {"volume", {0xd7, 14}},
        {"metering", {0xd8, 1}}};

    for (auto it = params.begin(); it != params.end(); ++it) {
        if (!fields.contains(it.key())) {
            return std::unexpected(invalid("Unknown device setting: " + it.key()));
        }
        const auto [address, maximum] = fields.at(it.key());
        if (auto valid = range(params, it.key(), address == 0xd6 ? 1 : 0, maximum); !valid) {
            return std::unexpected(valid.error());
        }
        if (std::floor(it.value().toDouble()) != it.value().toDouble()) {
            return std::unexpected(invalid("Device settings must be whole numbers"));
        }
        const auto value = std::uint8_t(it.value().toInt());
        addByteWrite(steps, std::uint8_t(address), value);
    }
    return steps;
}

} // namespace ps
