#include "command.hpp"
#include <cmath>
#include <QMap>
#include <QSet>

namespace mps {
const QStringList& numericOptions() {
    static const QStringList
        options{"voltage", "current", "brightness", "volume", "metering", "ovp", "ocp", "opp", "otp", "uvp"};
    return options;
}

ps::Result<Command> parseCommand(const QCommandLineParser& parser) {
    const auto arguments = parser.positionalArguments();
    if (arguments.isEmpty()) {
        return std::unexpected(ps::Error{"usage", "Specify a command; see mps --help"});
    }
    const auto name = arguments[0];
    const QSet<QString> known{"serve",
        "devices",
        "lock",
        "unlock",
        "status",
        "watch",
        "connect",
        "disconnect",
        "refresh",
        "set",
        "output",
        "preset",
        "settings",
        "protection"};
    if (!known.contains(name)) {
        return std::unexpected(ps::Error{"usage", "Unknown command"});
    }
    static const QMap<QString, QSet<QString>> allowed{{"set", {"voltage", "current"}},
        {"preset", {"voltage", "current"}},
        {"settings", {"brightness", "volume", "metering"}},
        {"protection", {"ovp", "ocp", "opp", "otp", "uvp"}}};
    Command command{name, {}};
    if (name == "output") {
        if (arguments.size() != 2 || (arguments[1] != "on" && arguments[1] != "off")) {
            return std::unexpected(ps::Error{"usage", "Usage: mps output on|off"});
        }
        command.params["enabled"] = arguments[1] == "on";
    } else if (name == "preset") {
        bool valid = false;
        const auto number = arguments.value(1).toInt(&valid);
        if (arguments.size() != 2 || !valid || number < 1 || number > 6) {
            return std::unexpected(ps::Error{"usage", "Usage: mps preset 1..6 [--voltage V --current A]"});
        }
        command.params["number"] = number;
    } else if (arguments.size() != 1) {
        return std::unexpected(ps::Error{"usage", "Unexpected positional arguments"});
    }
    if (name == "lock" || name == "unlock") {
        command.method = "access";
        command.params["readOnly"] = name == "lock";
    }
    if (parser.isSet("port")) {
        if (name != "connect") {
            return std::unexpected(ps::Error{"usage", "--port is only valid with connect"});
        }
        command.params["port"] = parser.value("port");
    }
    for (const auto& option : numericOptions()) {
        if (!parser.isSet(option)) {
            continue;
        }
        bool valid = false;
        const auto value = parser.value(option).toDouble(&valid);
        if (!allowed.value(name).contains(option) || !valid || !std::isfinite(value)) {
            return std::unexpected(
                ps::Error{"usage", "Unexpected option or invalid numeric value: " + option.toStdString()}
            );
        }
        command.params[option] = value;
    }
    if (name != "serve" && (parser.isSet("allow-writes") || parser.isSet("read-only") || parser.isSet("byte-order"))) {
        return std::unexpected(ps::Error{"usage", "--allow-writes, --read-only and --byte-order configure serve only"});
    }
    return command;
}

} // namespace mps
