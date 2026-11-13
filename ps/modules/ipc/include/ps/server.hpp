#pragma once

#include <ps/device.hpp>
#include <QLocalServer>
#include <QLocalSocket>
#include <QLockFile>
#include <QHash>
#include <memory>

namespace ps {
QString socketPath();

class Server final : public QObject {
    Q_OBJECT
public:
    explicit Server(Device& device, QObject* parent = nullptr);
    Result<void> listen(const QString& path);

private:
    struct Client {
        QByteArray buffer;
        bool subscribed = false;
        int pending = 0;
    };

    Device& device_;
    QLocalServer server_;
    std::unique_ptr<QLockFile> lock_;
    QHash<QLocalSocket*, Client> clients_;
    QTimer publish_;
    quint64 revision_ = 0;
    void receive(QLocalSocket* socket);
    void dispatch(QLocalSocket* socket, const QJsonObject& request);
    void send(QLocalSocket* socket, const QJsonObject& message);
};
} // namespace ps
