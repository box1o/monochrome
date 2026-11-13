#include <ps/device.hpp>
#include "validation.hpp"
#include <map>
#include <cmath>

namespace ps {
Result<std::vector<Device::Step>> Device::protectionSteps(const QJsonObject& params) {
    std::vector<Step> steps;

    static const std::map<QString, int> fields{{"ovp", 0xd1},
        {"ocp", 0xd2},
        {"opp", 0xd3},
        {"otp", 0xd4},
        {"uvp", 0xd5}};

    for (auto it = params.begin(); it != params.end(); ++it) {
        if (!fields.contains(it.key())) {
            return std::unexpected(invalid("Unknown protection: " + it.key()));
        }
        if (auto valid = range(params, it.key(), 0, 10000); !valid) {
            return std::unexpected(valid.error());
        }
        steps.push_back(read(fields.at(it.key()) + 0x13));
    }
    for (auto it = params.begin(); it != params.end(); ++it) {
        addWrite(steps, fields.at(it.key()), it.value().toDouble(), fields.at(it.key()) + 0x13);
    }
    return steps;
}

} // namespace ps
