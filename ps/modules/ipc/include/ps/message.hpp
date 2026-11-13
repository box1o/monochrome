#pragma once

#include <ps/result.hpp>
#include <QJsonObject>

namespace ps {
QJsonObject errorMessage(const Error& error);
QJsonObject replyMessage(const QJsonValue& id, const Result<QJsonObject>& result);
} // namespace ps
