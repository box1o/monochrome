#include <ps/protocol.hpp>
#include <bit>
#include <cmath>
#include <limits>

namespace ps {
Result<std::vector<std::uint8_t>> encode(const Frame& frame) {
    if (frame.data.size() > 255) {
        return std::unexpected(Error{"packet_size", "Payload exceeds 255 bytes"});
    }
    const auto size = static_cast<std::uint8_t>(frame.data.size());
    std::vector<std::uint8_t> bytes{0xf1, frame.command, frame.address, size};
    bytes.insert(bytes.end(), frame.data.begin(), frame.data.end());
    std::uint8_t checksum = frame.address + size;
    for (auto byte : frame.data) {
        checksum += byte;
    }
    bytes.push_back(checksum);
    return bytes;
}

std::vector<std::uint8_t> encodeFloat(float value, ByteOrder order) {
    static_assert(sizeof(float) == 4 && std::numeric_limits<float>::is_iec559);
    const auto bits = std::bit_cast<std::uint32_t>(value);
    std::vector<std::uint8_t> bytes(4);
    for (unsigned i = 0; i < 4; ++i) {
        const auto shift = order == ByteOrder::Little ? i : 3 - i;
        bytes[i] = static_cast<std::uint8_t>(bits >> (8 * shift));
    }
    return bytes;
}

Result<float> decodeFloat(std::span<const std::uint8_t> data, ByteOrder order) {
    if (data.size() != 4) {
        return std::unexpected(Error{"payload_size", "Expected a four-byte float"});
    }
    std::uint32_t bits = 0;
    for (unsigned i = 0; i < 4; ++i) {
        const auto shift = order == ByteOrder::Little ? i : 3 - i;
        bits |= std::uint32_t(data[i]) << (8 * shift);
    }
    const auto value = std::bit_cast<float>(bits);
    if (!std::isfinite(value)) {
        return std::unexpected(Error{"invalid_value", "Device returned a non-finite float"});
    }
    return value;
}
} // namespace ps
