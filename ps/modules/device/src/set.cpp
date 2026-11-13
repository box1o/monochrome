#include <ps/device.hpp>
#include "validation.hpp"
#include <cmath>

namespace ps {
Result<std::vector<Device::Step>> Device::setpointSteps(const QJsonObject& params) {
    std::vector<Step> steps;

    if (!params.contains("voltage") && !params.contains("current")) {
        return std::unexpected(invalid("Specify voltage and/or current"));
    }
    for (const auto& name : {QString("voltage"), QString("current")}) {
        if (params.contains(name)) {
            if (auto valid = range(params, name, 0, name == "voltage" ? 30 : 5); !valid) {
                return std::unexpected(valid.error());
            }
        }
    }
    steps = {read(0xe2), read(0xe3)};
    if (params.contains("voltage")) {
        addWrite(steps, 0xc1, params.value("voltage").toDouble(), 0xe2);
    }
    if (params.contains("current")) {
        addWrite(steps, 0xc2, params.value("current").toDouble(), 0xe3);
    }
    return steps;
}

} // namespace ps
