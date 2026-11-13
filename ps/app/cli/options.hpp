#pragma once

#include "command.hpp"
#include <ps/protocol.hpp>

namespace mps {
struct Options {
    Command command;
    QString socket;
    int timeout = 15000;
    bool json = false;
    bool allowWrites = true;
    ps::ByteOrder byteOrder = ps::ByteOrder::Little;
};

ps::Result<Options> parseOptions(const QStringList& arguments);
} // namespace mps
