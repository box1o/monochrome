#include <ps/device.hpp>

namespace ps {
Result<std::vector<Device::Step>> Device::operation(const QString& method, const QJsonObject& params) {
    if (method == "refresh") {
        return refreshSteps();
    }
    if ((method == "settings" || method == "protection") && params.isEmpty()) {
        std::vector<Step> steps;
        const int first = method == "settings" ? 0xd6 : 0xd1;
        const int last = method == "settings" ? 0xd8 : 0xd5;
        for (int address = first; address <= last; ++address) {
            steps.push_back(read(address));
        }
        if (method == "protection") {
            for (int address = 0xe4; address <= 0xe8; ++address) {
                steps.push_back(read(address));
            }
        }
        return steps;
    }
    if (method == "preset" && !params.contains("voltage") && !params.contains("current")) {
        return presetSteps(params);
    }
    if (!allowWrites_ && !(method == "output" && params.value("enabled") == false)) {
        return std::unexpected(Error{"read_only", "Device controls are locked; use mps unlock to enable writes"});
    }
    if (method == "set") {
        return setpointSteps(params);
    }
    if (method == "output") {
        return outputSteps(params);
    }
    if (method == "settings") {
        return settingsSteps(params);
    }
    if (method == "protection") {
        return protectionSteps(params);
    }
    if (method == "preset") {
        return presetSteps(params);
    }
    return std::unexpected(Error{"unknown_method", "Unknown operation"});
}

} // namespace ps
