#pragma once

#include <expected>
#include <string>

namespace ps {
struct Error {
    std::string code;
    std::string message;
};

template <typename T>
using Result = std::expected<T, Error>;
} // namespace ps
