#include <ps/device.hpp>
#include "validation.hpp"
#include <QSet>
#include <map>
#include <optional>

namespace ps {
void Device::execute(
    const QString& method,
    const QJsonObject& params,
    Completion completion,
    std::function<bool()> cancelled
) {
    static const std::map<QString, QSet<QString>> allowed{{"connect", {"port"}},
        {"disconnect", {}},
        {"access", {"readOnly"}},
        {"refresh", {}},
        {"set", {"voltage", "current"}},
        {"output", {"enabled"}},
        {"settings", {"brightness", "volume", "metering"}},
        {"protection", {"ovp", "ocp", "opp", "otp", "uvp"}},
        {"preset", {"number", "voltage", "current"}}};
    if (!allowed.contains(method)) {
        completion(std::unexpected(Error{"unknown_method", "Unknown device operation"}));
        return;
    }
    for (auto it = params.begin(); it != params.end(); ++it) {
        if (!allowed.at(method).contains(it.key())) {
            completion(std::unexpected(invalid("Unexpected parameter: " + it.key())));
            return;
        }
    }
    if (params.contains("port") && (!params.value("port").isString() || params.value("port").toString().isEmpty())) {
        completion(std::unexpected(invalid("port must be a non-empty string")));
        return;
    }
    if (method == "access") {
        if (!params.value("readOnly").isBool()) {
            completion(std::unexpected(invalid("readOnly must be boolean")));
            return;
        }
        allowWrites_ = !params.value("readOnly").toBool();
        emit changed();
        completion(snapshot());
        return;
    }
    if (method == "connect") {
        openSession(params.value("port").toString(), std::move(completion));
        return;
    }
    if (method == "disconnect") {
        closeSession(std::move(completion));
        return;
    }

    if (phase_ != "ready") {
        completion(std::unexpected(Error{"not_ready", "Connect to a compatible supply first"}));
        return;
    }
    auto steps = operation(method, params);
    if (!steps) {
        completion(std::unexpected(steps.error()));
        return;
    }
    validateBatch(*steps);
    enqueue(std::move(*steps), std::move(completion), std::move(cancelled));
}

void Device::validateBatch(std::vector<Step>& steps) {
    // Run every dynamic limit check before the first write. A later invalid
    // field must not leave an earlier field changed by a partially validated batch.
    std::vector<Check> checks;
    std::optional<std::size_t> firstWrite;
    for (std::size_t i = 0; i < steps.size(); ++i) {
        if (steps[i].frame.command == 0xb1) {
            if (!firstWrite) {
                firstWrite = i;
            }
            if (steps[i].before) {
                checks.push_back(steps[i].before);
            }
        }
    }
    if (firstWrite) {
        steps[*firstWrite].before = [checks = std::move(checks)]() -> Result<void> {
            for (const auto& check : checks) {
                if (auto valid = check(); !valid) {
                    return valid;
                }
            }
            return {};
        };
    }
}

} // namespace ps
