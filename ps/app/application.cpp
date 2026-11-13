#include "application.hpp"
#include "cli/options.hpp"
#include "service/service.hpp"
#include <ps/client.hpp>
#include <ps/device.hpp>
#include <ps/message.hpp>

namespace mps {
Application::Application(int& argc, char** argv)
    : application_(argc, argv) {
    application_.setApplicationName("mps");
    application_.setApplicationVersion("0.1.0");
}

int Application::run() {
    const auto arguments = application_.arguments();
    const auto options = parseOptions(arguments);
    if (!options) {
        ps::printJson(ps::errorMessage(options.error()), arguments.contains("--json") || arguments.contains("-j"));
        return 2;
    }

    const auto& command = options->command;
    if (command.method == "serve") {
        return runService(*options);
    }
    if (command.method == "devices") {
        ps::printJson({{"devices", ps::Device::ports()}}, options->json);
        return 0;
    }
    return ps::runClient(options->socket, command.method, command.params, options->json, options->timeout);
}
} // namespace mps
