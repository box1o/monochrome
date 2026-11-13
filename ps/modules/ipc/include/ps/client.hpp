#pragma once

#include <ps/result.hpp>
#include <QJsonObject>
#include <QString>

namespace ps {
int runClient(const QString& socket, const QString& method, const QJsonObject& params, bool json, int timeout);
void printJson(const QJsonObject& value, bool compact);
} // namespace ps
