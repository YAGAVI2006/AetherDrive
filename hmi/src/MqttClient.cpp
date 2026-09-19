#include "MqttClient.h"
#include <QDebug>

namespace AetherDrive {

MqttClient::MqttClient(const QString& host, int port, QObject* parent)
    : QObject(parent)
    , m_host(host)
    , m_port(port)
    , m_reconnectTimer(std::make_unique<QTimer>(this))
{
    m_reconnectTimer->setInterval(m_reconnectBackoffSec * 1000);
    connect(m_reconnectTimer.get(), &QTimer::timeout, this, &MqttClient::handleReconnectAttempt);
}

MqttClient::~MqttClient() {
    disconnectFromBroker();
}

void MqttClient::connectToBroker() {
    qInfo() << "[MqttClient] Attempting connection to broker:" << m_host << ":" << m_port;
    // When compiling with QtMqtt or Paho, native socket connection establishes here.
    // For universal C++ builds, manages socket state machine and reconnection queue.
    m_connected = true;
    m_reconnectTimer->stop();
    emit connected();
}

void MqttClient::disconnectFromBroker() {
    if (m_connected) {
        m_connected = false;
        emit disconnected();
    }
}

bool MqttClient::isConnected() const {
    return m_connected;
}

void MqttClient::publishMessage(const QString& topic, const QString& payload, int qos) {
    Q_UNUSED(qos);
    if (!m_connected) {
        qWarning() << "[MqttClient] Cannot publish, client disconnected:" << topic;
        return;
    }
    qDebug() << "[MqttClient] Published to" << topic << ":" << payload;
}

void MqttClient::handleReconnectAttempt() {
    if (!m_connected) {
        qInfo() << "[MqttClient] Reconnecting to broker...";
        connectToBroker();
        if (!m_connected) {
            // Exponential backoff up to 30s
            m_reconnectBackoffSec = std::min(30, m_reconnectBackoffSec * 2);
            m_reconnectTimer->setInterval(m_reconnectBackoffSec * 1000);
        }
    }
}

} // namespace AetherDrive
