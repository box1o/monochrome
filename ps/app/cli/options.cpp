#include "options.hpp"
#include <ps/server.hpp>

namespace mps {
ps::Result<Options> parseOptions(const QStringList& arguments) {
    QCommandLineParser parser;
    parser.setApplicationDescription(
        "mps supply service and CLI.\n"
        "Commands: serve, devices, status, watch, connect, disconnect, refresh, set,\n"
        "          output on|off, preset N, settings, protection, lock, unlock.\n"
        "The service starts idle with controls enabled. Connect explicitly.\n"
        "Closing a client does not turn output off. Use lock for read-only mode."
    );
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument("command", "Command and optional positional arguments", "command [arguments]");
    parser.addOptions(
        {{{"j", "json"}, "Compact, machine-readable JSON output"},
            {"socket", "Local socket path", "path", ps::socketPath()},
            {"timeout", "CLI request deadline in milliseconds", "ms", "15000"},
            {"port", "Explicit serial device for connect", "path"},
            {"allow-writes", "Enable device controls in serve (default)"},
            {"read-only", "Start serve with device controls locked"},
            {"byte-order", "Device float byte order for serve: little or big", "order", "little"}}
    );
    for (const auto& name : numericOptions()) {
        parser.addOption({name, QString("Value for %1").arg(name), "value"});
    }
    if (!parser.parse(arguments)) {
        return std::unexpected(ps::Error{"usage", parser.errorText().toStdString()});
    }
    if (parser.isSet("help") || parser.isSet("help-all")) {
        parser.showHelp();
    }
    if (parser.isSet("version")) {
        parser.showVersion();
    }

    auto command = parseCommand(parser);
    if (!command) {
        return std::unexpected(command.error());
    }

    Options options;
    options.command = std::move(*command);
    options.socket = parser.value("socket");
    options.json = parser.isSet("json");
    if (parser.isSet("allow-writes") && parser.isSet("read-only")) {
        return std::unexpected(ps::Error{"usage", "Choose --read-only or --allow-writes"});
    }
    options.allowWrites = !parser.isSet("read-only");

    if (options.command.method != "serve" && options.command.method != "devices") {
        bool valid = false;
        options.timeout = parser.value("timeout").toInt(&valid);
        if (!valid || options.timeout < 100 || options.timeout > 300000) {
            return std::unexpected(ps::Error{"usage", "--timeout must be between 100 and 300000 ms"});
        }
    }
    if (options.command.method == "serve") {
        const auto order = parser.value("byte-order");
        if (order != "little" && order != "big") {
            return std::unexpected(ps::Error{"usage", "--byte-order must be little or big"});
        }
        options.byteOrder = order == "little" ? ps::ByteOrder::Little : ps::ByteOrder::Big;
    }
    return options;
}
} // namespace mps
