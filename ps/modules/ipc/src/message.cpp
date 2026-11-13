#include <ps/message.hpp>

namespace ps {
QJsonObject errorMessage(const Error& error) {
    return {{"version", 1},
        {"ok", false},
        {"error",
            QJsonObject{{"code", QString::fromStdString(error.code)},
                {"message", QString::fromStdString(error.message)}}}};
}

QJsonObject replyMessage(const QJsonValue& id, const Result<QJsonObject>& result) {
    auto message = result ? QJsonObject{{"version", 1}, {"ok", true}, {"result", *result}}
                          : errorMessage(result.error());
    message["id"] = id;
    return message;
}
} // namespace ps
