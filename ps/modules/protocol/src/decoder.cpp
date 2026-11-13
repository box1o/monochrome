#include <ps/protocol.hpp>
#include <algorithm>

namespace ps {
std::vector<Frame> Decoder::feed(std::span<const std::uint8_t> bytes) {
    std::vector<Frame> frames;
    for (auto byte : bytes) {
        if (buffer_.empty() && byte != 0xf0) {
            continue;
        }
        buffer_.push_back(byte);
        while (buffer_.size() >= 5) {
            const std::size_t length = buffer_[3];
            if (buffer_.size() < length + 5) {
                break;
            }
            std::uint8_t checksum = buffer_[2] + buffer_[3];
            for (std::size_t i = 0; i < length; ++i) {
                checksum += buffer_[4 + i];
            }
            if (checksum == buffer_[length + 4]) {
                frames.push_back({buffer_[1], buffer_[2], {buffer_.begin() + 4, buffer_.begin() + 4 + length}});
                buffer_.erase(buffer_.begin(), buffer_.begin() + length + 5);
            } else {
                buffer_.erase(buffer_.begin());
            }
            const auto start = std::find(buffer_.begin(), buffer_.end(), 0xf0);
            buffer_.erase(buffer_.begin(), start);
        }
    }
    return frames;
}

void Decoder::reset() {
    buffer_.clear();
}
} // namespace ps
