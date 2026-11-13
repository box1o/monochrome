#pragma once

#include <ps/protocol.hpp>
#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QElapsedTimer>
#include <functional>

namespace ps {
class Transport final : public QObject {
    Q_OBJECT
public:
    using Completion = std::function<void(Result<std::vector<std::uint8_t>>)>;
    explicit Transport(QObject* parent = nullptr);
    Result<void> open(const QString& path);
    void close();
    void request(Frame frame, int replySize, Completion completion, std::function<bool()> cancelled = {});
    bool isOpen() const;

signals:
    void received(const ps::Frame& frame);
    void failed(const QString& message);

private:
    QSerialPort port_;
    Decoder decoder_;
    QTimer timeout_;
    QTimer delay_;
    QElapsedTimer lastWrite_;
    QElapsedTimer opened_;
    Frame pending_{};
    int replySize_ = -1;
    Completion completion_;
    std::function<bool()> cancelled_;
    void send();
    void finish(Result<std::vector<std::uint8_t>> result);
};
} // namespace ps
