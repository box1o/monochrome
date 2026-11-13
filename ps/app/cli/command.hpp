#pragma once

#include <ps/result.hpp>
#include <QCommandLineParser>
#include <QJsonObject>

namespace mps {
struct Command {
    QString method;
    QJsonObject params;
};

const QStringList& numericOptions();
ps::Result<Command> parseCommand(const QCommandLineParser& parser);

} // namespace mps
