#pragma once

#include <ps/result.hpp>
#include <QString>
#include <QJsonObject>
#include <cmath>

namespace ps {
inline Error invalid(const QString& message) {
    return {"invalid_argument", message.toStdString()};
}

inline Result<void> range(const QJsonObject& params, const QString& name, double minimum, double maximum) {
    const auto value = params.value(name);
    if (!value.isDouble() || !std::isfinite(value.toDouble()) || value.toDouble() < minimum
        || value.toDouble() > maximum) {
        return std::unexpected(
            Error{"invalid_argument",
                QString("%1 must be between %2 and %3").arg(name).arg(minimum).arg(maximum).toStdString()}
        );
    }
    return {};
}

} // namespace ps
