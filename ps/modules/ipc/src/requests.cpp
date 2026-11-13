#include <ps/server.hpp>
#include <ps/message.hpp>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QPointer>

namespace ps {
void Server::receive(QLocalSocket* socket) {
    if (!clients_.contains(socket)) {
        return;
    }
    auto& client = clients_[socket];
    client.buffer += socket->readAll();
    if (client.buffer.size() > 65536) {
        socket->abort();
        return;
    }
    while (clients_.contains(socket)) {
        auto& buffer = clients_[socket].buffer;
        const auto end = buffer.indexOf('\n');
        if (end < 0) {
            break;
        }
        const auto line = buffer.left(end);
        buffer.remove(0, end + 1);
        QJsonParseError error;
        const auto document = QJsonDocument::fromJson(line, &error);
        if (error.error != QJsonParseError::NoError || !document.isObject()) {
            send(socket, errorMessage({"invalid_json", "Expected one JSON object per line"}));
        } else {
            dispatch(socket, document.object());
        }
    }
}

void Server::dispatch(QLocalSocket* socket, const QJsonObject& request) {
    const auto id = request.value("id");
    const QPointer<QLocalSocket> peer(socket);
    const auto reply = [this, peer, id](Result<QJsonObject> result) {
        if (!peer || !clients_.contains(peer)) {
            return;
        }
        --clients_[peer].pending;
        send(peer, replyMessage(id, result));
    };
    ++clients_[socket].pending;
    if ((!id.isString() && !id.isDouble()) || request.value("version").toInt() != 1
        || !request.value("method").isString() || (request.contains("params") && !request.value("params").isObject())) {
        reply(std::unexpected(Error{"invalid_request", "Expected version 1, id, method and optional params object"}));
        return;
    }
    if (clients_[socket].pending > 8) {
        reply(std::unexpected(Error{"busy", "Too many outstanding requests"}));
        return;
    }
    const auto method = request.value("method").toString();
    if (method == "status" || method == "watch") {
        if (method == "watch") {
            clients_[socket].subscribed = true;
        }
        reply(device_.snapshot());
    } else if (method == "devices") {
        reply(QJsonObject{{"devices", Device::ports()}});
    } else {
        device_.execute(method, request.value("params").toObject(), reply, [peer] {
            return !peer || peer->state() != QLocalSocket::ConnectedState;
        });
    }
}

} // namespace ps
