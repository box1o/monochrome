#include "transport.hpp"

namespace ps {
Transport::Transport(QObject* parent)
    : QObject(parent) {
    timeout_.setSingleShot(true);
    delay_.setSingleShot(true);
    connect(&delay_, &QTimer::timeout, this, &Transport::send);
    connect(&timeout_, &QTimer::timeout, this, [this] {
        finish(std::unexpected(Error{"timeout", "Device response timed out"}));
    });
    connect(&port_, &QSerialPort::bytesWritten, this, [this](qint64) {
        if (completion_ && replySize_ < 0 && port_.bytesToWrite() == 0) {
            finish(std::vector<std::uint8_t>{});
        }
    });
    connect(&port_, &QSerialPort::readyRead, this, [this] {
        const auto bytes = port_.readAll();
        const auto frames = decoder_.feed(
            {reinterpret_cast<const std::uint8_t*>(bytes.constData()), std::size_t(bytes.size())}
        );
        for (const auto& frame : frames) {
            emit received(frame);
            if (completion_ && timeout_.isActive() && frame.command == 0xa1 && frame.address == pending_.address
                && int(frame.data.size()) == replySize_) {
                finish(frame.data);
            }
        }
    });
    connect(&port_, &QSerialPort::errorOccurred, this, [this](QSerialPort::SerialPortError error) {
        if (error == QSerialPort::NoError || error == QSerialPort::NotOpenError) {
            return;
        }
        const auto message = port_.errorString();
        finish(std::unexpected(Error{"serial_error", message.toStdString()}));
        emit failed(message);
    });
}

Result<void> Transport::open(const QString& path) {
    close();
    port_.setPortName(path);
    port_.setBaudRate(115200);
    port_.setDataBits(QSerialPort::Data8);
    port_.setParity(QSerialPort::NoParity);
    port_.setStopBits(QSerialPort::OneStop);
    port_.setFlowControl(QSerialPort::NoFlowControl);
    if (!port_.open(QIODevice::ReadWrite)) {
        return std::unexpected(Error{"open_failed", port_.errorString().toStdString()});
    }
    decoder_.reset();
    lastWrite_.start();
    opened_.start();
    return {};
}

void Transport::close() {
    delay_.stop();
    timeout_.stop();
    if (port_.isOpen()) {
        port_.close();
    }
    decoder_.reset();
    finish(std::unexpected(Error{"disconnected", "Serial connection closed"}));
}

bool Transport::isOpen() const {
    return port_.isOpen();
}

void Transport::request(Frame frame, int replySize, Completion completion, std::function<bool()> cancelled) {
    if (completion_) {
        completion(std::unexpected(Error{"busy", "Serial transaction already active"}));
        return;
    }
    pending_ = std::move(frame);
    replySize_ = replySize;
    completion_ = std::move(completion);
    cancelled_ = std::move(cancelled);
    const auto gap = lastWrite_.isValid() ? std::max<qint64>(0, 55 - lastWrite_.elapsed()) : 0;
    const auto settle = opened_.isValid() ? std::max<qint64>(0, 500 - opened_.elapsed()) : 0;
    delay_.start(int(std::max(gap, settle)));
}

void Transport::send() {
    if (cancelled_ && cancelled_()) {
        finish(std::unexpected(Error{"cancelled", "Write cancelled before transmission"}));
        return;
    }
    const auto bytes = encode(pending_);
    if (!bytes) {
        finish(std::unexpected(bytes.error()));
        return;
    }
    const auto written = port_.write(reinterpret_cast<const char*>(bytes->data()), qint64(bytes->size()));
    if (written != qint64(bytes->size())) {
        finish(std::unexpected(Error{"write_failed", "Could not queue complete serial packet"}));
        return;
    }
    lastWrite_.restart();
    // No-echo writes finish only after Qt drains its output buffer. Closing
    // immediately after write() would otherwise discard a session disconnect.
    timeout_.start(1500);
    if (replySize_ < 0 && port_.bytesToWrite() == 0) {
        finish(std::vector<std::uint8_t>{});
    }
}

void Transport::finish(Result<std::vector<std::uint8_t>> result) {
    timeout_.stop();
    delay_.stop();
    cancelled_ = {};
    if (completion_) {
        auto callback = std::move(completion_);
        completion_ = {};
        QTimer::singleShot(0, this, [callback = std::move(callback), result = std::move(result)]() mutable {
            callback(std::move(result));
        });
    }
}
} // namespace ps
