#include "VehicleTelemetryModel.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

namespace AetherDrive {

VehicleTelemetryModel::VehicleTelemetryModel(QObject* parent)
    : QObject(parent)
{
    m_data.speed = 0.0;
    m_data.rpm = 800;
    m_data.battery = 85;
    m_data.range = 350;
    m_data.gear = "P";
    m_data.doorLocked = true;
    m_data.speedLimit = 100.0;
    m_data.driveMode = "NORMAL";
    m_data.laneDepartureWarning = false;
    m_data.alertMessage = "";
}

void VehicleTelemetryModel::setConnected(bool connected) {
    if (m_isConnected != connected) {
        m_isConnected = connected;
        emit connectionChanged();
    }
}

void VehicleTelemetryModel::setDriveMode(const QString& mode) {
    std::string sMode = mode.toStdString();
    if (m_data.driveMode != sMode) {
        m_data.driveMode = sMode;
        emit driveModeChanged();
    }
}

void VehicleTelemetryModel::updateAlert(const QString& alert) {
    std::string sAlert = alert.toStdString();
    if (m_data.alertMessage != sAlert) {
        m_data.alertMessage = sAlert;
        emit alertMessageChanged();
    }
}

void VehicleTelemetryModel::updateTelemetryFromJson(const QString& jsonString) {
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(jsonString.toUtf8(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
        qWarning() << "[VehicleTelemetryModel] JSON parse error:" << parseError.errorString();
        return;
    }

    QJsonObject obj = doc.object();

    if (obj.contains("speed")) {
        double newSpeed = obj["speed"].toDouble();
        if (std::abs(m_data.speed - newSpeed) > 0.01) {
            m_data.speed = newSpeed;
            emit speedChanged();
        }
    }

    if (obj.contains("rpm")) {
        int newRpm = obj["rpm"].toInt();
        if (m_data.rpm != newRpm) {
            m_data.rpm = newRpm;
            emit rpmChanged();
        }
    }

    if (obj.contains("battery")) {
        int newBat = obj["battery"].toInt();
        if (m_data.battery != newBat) {
            m_data.battery = newBat;
            emit batteryChanged();
        }
    }

    if (obj.contains("range")) {
        int newRange = obj["range"].toInt();
        if (m_data.range != newRange) {
            m_data.range = newRange;
            emit rangeChanged();
        }
    }

    if (obj.contains("gear")) {
        std::string newGear = obj["gear"].toString().toStdString();
        if (m_data.gear != newGear) {
            m_data.gear = newGear;
            emit gearChanged();
        }
    }

    if (obj.contains("door_locked")) {
        bool locked = obj["door_locked"].toBool();
        if (m_data.doorLocked != locked) {
            m_data.doorLocked = locked;
            emit doorLockedChanged();
        }
    }

    if (obj.contains("speed_limit")) {
        double limit = obj["speed_limit"].toDouble();
        if (std::abs(m_data.speedLimit - limit) > 0.01) {
            m_data.speedLimit = limit;
            emit speedLimitChanged();
        }
    }

    if (obj.contains("drive_mode")) {
        std::string mode = obj["drive_mode"].toString().toStdString();
        if (m_data.driveMode != mode) {
            m_data.driveMode = mode;
            emit driveModeChanged();
        }
    }

    if (obj.contains("lane_departure")) {
        bool ldw = obj["lane_departure"].toBool();
        if (m_data.laneDepartureWarning != ldw) {
            m_data.laneDepartureWarning = ldw;
            emit laneDepartureChanged();
        }
    }

    if (obj.contains("alert")) {
        std::string alert = obj["alert"].toString().toStdString();
        if (m_data.alertMessage != alert) {
            m_data.alertMessage = alert;
            emit alertMessageChanged();
        }
    }
}

} // namespace AetherDrive
