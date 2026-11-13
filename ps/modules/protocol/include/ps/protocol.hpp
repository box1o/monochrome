#pragma once

#include <ps/result.hpp>
#include <cstdint>
#include <span>
#include <vector>

namespace ps {
enum class ByteOrder { Little, Big };

struct Frame {
    std::uint8_t command;
    std::uint8_t address;
    std::vector<std::uint8_t> data;
};

Result<std::vector<std::uint8_t>> encode(const Frame& frame);
std::vector<std::uint8_t> encodeFloat(float value, ByteOrder order);
Result<float> decodeFloat(std::span<const std::uint8_t> data, ByteOrder order);

class Decoder {
public:
    std::vector<Frame> feed(std::span<const std::uint8_t> bytes);
    void reset();

private:
    std::vector<std::uint8_t> buffer_;
};
} // namespace ps
