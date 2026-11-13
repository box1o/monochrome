#include <ps/server.hpp>
#include <QDir>
#include <QFileInfo>
#include <QJsonDocument>
#include <QStandardPaths>

namespace ps {
QString socketPath() {
    const auto runtime = QStandardPaths::writableLocation(QStandardPaths::RuntimeLocation);
    return runtime.isEmpty() ? QString{} : runtime + "/mps/control.sock";
}

Server::Server(Device& device, QObject* parent)
    : QObject(parent),
      device_(device) {
    server_.setSocketOptions(QLocalServer::UserAccessOption);
    server_.setMaxPendingConnections(16);
    publish_.setSingleShot(true);
    publish_.setInterval(50);
    connect(&device_, &Device::changed, this, [this] {
        if (!publish_.isActive()) {
            publish_.start();
        }
    });
    connect(&publish_, &QTimer::timeout, this, [this] {
        const QJsonObject message{{"version", 1},
            {"event", "state"},
            {"revision", QString::number(++revision_)},
            {"data", device_.snapshot()}};
        const auto sockets = clients_.keys();
        for (auto* socket : sockets) {
            if (clients_.value(socket).subscribed) {
                send(socket, message);
            }
        }
    });
    connect(&server_, &QLocalServer::newConnection, this, [this] {
        while (auto* socket = server_.nextPendingConnection()) {
            if (clients_.size() >= 16) {
                socket->abort();
                socket->deleteLater();
                continue;
            }
            socket->setReadBufferSize(65537);
            clients_.insert(socket, {});
            connect(socket, &QLocalSocket::readyRead, this, [this, socket] { receive(socket); });
            connect(socket, &QLocalSocket::disconnected, this, [this, socket] {
                clients_.remove(socket);
                socket->deleteLater();
            });
        }
    });
}

Result<void> Server::listen(const QString& path) {
    if (path.isEmpty() || !QDir::isAbsolutePath(path)) {
        return std::unexpected(Error{"socket_path", "An absolute socket path is required"});
    }
    const auto directory = QFileInfo(path).absolutePath();
    if (!QDir().mkpath(directory)) {
        return std::unexpected(Error{"socket_path", "Cannot create socket directory"});
    }
    lock_ = std::make_unique<QLockFile>(path + ".lock");
    if (!lock_->tryLock(0)) {
        return std::unexpected(Error{"already_running", "A backend already owns this socket"});
    }
    // Only remove a stale socket after acquiring its process lock.
    QLocalServer::removeServer(path);
    if (!server_.listen(path)) {
        return std::unexpected(Error{"listen_failed", server_.errorString().toStdString()});
    }
    return {};
}

void Server::send(QLocalSocket* socket, const QJsonObject& message) {
    if (socket->bytesToWrite() > 262144) {
        socket->abort();
        return;
    }
    socket->write(QJsonDocument(message).toJson(QJsonDocument::Compact) + '\n');
    socket->flush();
}
} // namespace ps
