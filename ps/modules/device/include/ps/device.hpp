#pragma once

#include <ps/protocol.hpp>
#include <QObject>
#include <QElapsedTimer>
#include <QTimer>
#include <functional>
#include <QJsonArray>
#include <QJsonObject>
#include <deque>
#include <memory>

namespace ps {
class Transport;

class Device final : public QObject {
    Q_OBJECT
public:
    using Completion = std::function<void(Result<QJsonObject>)>;
    Device(bool allowWrites, ByteOrder order, QObject* parent = nullptr);
    ~Device() override;
    static QJsonArray ports();
    QJsonObject snapshot() const;
    void execute(
        const QString& method,
        const QJsonObject& params,
        Completion completion,
        std::function<bool()> cancelled = {}
    );
    void disconnectDevice();

signals:
    void changed();

private:
    using Check = std::function<Result<void>()>;

    struct Step {
        Frame frame;
        int replySize = -1;
        Check before;
        std::function<Result<void>(std::span<const std::uint8_t>)> verify;
    };

    struct Operation {
        std::vector<Step> steps;
        std::size_t index = 0;
        Completion completion;
        std::function<bool()> cancelled;
    };

    std::unique_ptr<Transport> transport_;
    bool allowWrites_;
    ByteOrder order_;
    QString phase_ = "disconnected";
    QString port_;
    QString error_;
    QJsonObject values_;
    QElapsedTimer measurementAge_;
    QTimer poll_;
    std::deque<std::unique_ptr<Operation>> queue_;
    std::unique_ptr<Operation> active_;
    quint64 generation_ = 0;

    void ingest(const Frame& frame);
    void enqueue(std::vector<Step> steps, Completion completion, std::function<bool()> cancelled = {});
    void advance();
    void finish(Result<QJsonObject> result);
    Step read(std::uint8_t address);
    std::vector<Step> refreshSteps();
    Result<std::vector<Step>> operation(const QString& method, const QJsonObject& params);
    Result<std::vector<Step>> setpointSteps(const QJsonObject& params);
    Result<std::vector<Step>> outputSteps(const QJsonObject& params);
    Result<std::vector<Step>> settingsSteps(const QJsonObject& params);
    Result<std::vector<Step>> protectionSteps(const QJsonObject& params);
    Result<std::vector<Step>> presetSteps(const QJsonObject& params);
    void openSession(QString path, Completion completion);
    void closeSession(Completion completion);
    static void validateBatch(std::vector<Step>& steps);
    void addByteWrite(std::vector<Step>& steps, std::uint8_t address, std::uint8_t value, Check before = {});
    void addWrite(std::vector<Step>& steps, std::uint8_t address, double value, std::uint8_t ceiling);
};
} // namespace ps
