#include <ps/device.hpp>
#include "validation.hpp"
#include <cmath>

namespace ps {
Result<std::vector<Device::Step>> Device::presetSteps(const QJsonObject& params) {
    std::vector<Step> steps;

    if (auto valid = range(params, "number", 1, 6); !valid) {
        return std::unexpected(valid.error());
    }
    const auto number = params.value("number").toDouble();
    if (std::floor(number) != number) {
        return std::unexpected(invalid("Preset number must be a whole number"));
    }
    const auto address = std::uint8_t(0xc5 + 2 * (int(number) - 1));
    if (!params.contains("voltage") && !params.contains("current")) {
        return std::vector<Step>{read(address), read(address + 1)};
    }
    if (auto valid = range(params, "voltage", 0, 30); !valid) {
        return std::unexpected(valid.error());
    }
    if (auto valid = range(params, "current", 0, 5); !valid) {
        return std::unexpected(valid.error());
    }
    steps = {read(0xe2), read(0xe3)};
    addWrite(steps, address, params.value("voltage").toDouble(), 0xe2);
    addWrite(steps, address + 1, params.value("current").toDouble(), 0xe3);
    return steps;
}

} // namespace ps
