#include "service.hpp"
#include "shutdown.hpp"
#include "../cli/options.hpp"
#include <ps/server.hpp>
#include <QCoreApplication>

namespace mps {
int runService(const Options& options) {
    ps::Device device(options.allowWrites, options.byteOrder);
    ps::Server server(device);
    Shutdown shutdown;

    if (const auto started = shutdown.start(device); !started) {
        qCritical("%s", started.error().message.c_str());
        return 3;
    }
    if (const auto listening = server.listen(options.socket); !listening) {
        qCritical("%s", listening.error().message.c_str());
        return 3;
    }
    return QCoreApplication::exec();
}
} // namespace mps
