#pragma once

#include <QObject>
#include <QString>
#include <QTimer>
#include <memory>
#include "MqttTopics.h"

namespace AetherDrive {

/**
 * @brief MQTT Client abstraction for automotive communication with auto-reconnection.
 */
class MqttClient : public QObject {
    Q_OBJECT

public:
    explicit MqttClient(const QString& host = QString::fromUtf8(Topics::DefaultBrokerHost.data()),
                        int port = Topics::DefaultBrokerPort,
                        QObject* parent = nullptr);
    ~MqttClient() override;

    void connectToBroker();
    void disconnectFromBroker();
    bool isConnected() const;

    void publishMessage(const QString& topic, const QString& payload, int qos = 0);

signals:
    void connected();
    void disconnected();
    void telemetryReceived(const QString& jsonString);
    void alertReceived(const QString& alertMessage);
    void otaCommandReceived(const QString& command);

private slots:
    void handleReconnectAttempt();

private:
    QString m_host;
    int m_port;
    bool m_connected{false};
    std::unique_ptr<QTimer> m_reconnectTimer;
    int m_reconnectBackoffSec{2};
};

} // namespace AetherDrive
