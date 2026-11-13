#include <ps/client.hpp>
#include <ps/message.hpp>
#include <QLocalSocket>
#include <QCoreApplication>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QTimer>
#include <QUuid>
#include <cstdio>

namespace ps {
void printJson(const QJsonObject& value, bool compact) {
    auto bytes = QJsonDocument(value).toJson(compact ? QJsonDocument::Compact : QJsonDocument::Indented);
    if (!bytes.endsWith('\n')) {
        bytes += '\n';
    }
    std::fwrite(bytes.constData(), 1, std::size_t(bytes.size()), stdout);
    std::fflush(stdout);
}

int runClient(const QString& path, const QString& method, const QJsonObject& params, bool json, int timeout) {
    QLocalSocket socket;
    QTimer deadline;
    deadline.setSingleShot(true);
    QByteArray buffer;
    const auto id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    bool finished = false;
    const auto fail = [&](const QString& code, const QString& message, int exitCode) {
        if (finished) {
            return;
        }
        finished = true;
        printJson(errorMessage({code.toStdString(), message.toStdString()}), json);
        QCoreApplication::exit(exitCode);
    };
    QObject::connect(&socket, &QLocalSocket::connected, &socket, [&] {
        socket.write(
            QJsonDocument(QJsonObject{{"version", 1}, {"id", id}, {"method", method}, {"params", params}})
                .toJson(QJsonDocument::Compact)
            + '\n'
        );
        socket.flush();
    });
    QObject::connect(&socket, &QLocalSocket::readyRead, &socket, [&] {
        buffer += socket.readAll();
        if (buffer.size() > 65536) {
            fail("invalid_response", "Backend response exceeds size limit", 3);
            return;
        }
        while (buffer.contains('\n')) {
            const auto end = buffer.indexOf('\n');
            QJsonParseError parse;
            const auto document = QJsonDocument::fromJson(buffer.left(end), &parse);
            buffer.remove(0, end + 1);
            if (parse.error != QJsonParseError::NoError || !document.isObject()) {
                fail("invalid_response", "Backend returned malformed JSON", 3);
                return;
            }
            const auto value = document.object();
            if (value.value("id").toString() != id) {
                if (method == "watch" && value.value("event") == "state") {
                    printJson(value, json);
                }
                continue;
            }
            deadline.stop();
            printJson(value, json);
            if (!value.value("ok").toBool() || method != "watch") {
                finished = true;
                QCoreApplication::exit(value.value("ok").toBool() ? 0 : 4);
                return;
            }
        }
    });
    QObject::connect(&socket, &QLocalSocket::errorOccurred, &socket, [&](auto) {
        fail("backend_unavailable", socket.errorString() + "; start mps serve or the mps user service", 3);
    });
    QObject::connect(&socket, &QLocalSocket::disconnected, &socket, [&] {
        fail("backend_disconnected", "Backend disconnected", 3);
    });
    QObject::connect(&deadline, &QTimer::timeout, &socket, [&] {
        fail("timeout", "Request timed out; an already transmitted write cannot be undone", 5);
    });
    // Start asynchronously so even immediate connection failures exit the running event loop.
    QTimer::singleShot(0, &socket, [&] {
        deadline.start(timeout);
        socket.connectToServer(path);
    });
    return QCoreApplication::exec();
}
} // namespace ps
