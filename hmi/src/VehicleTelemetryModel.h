#pragma once

#include <QObject>
#include <QString>
#include "VehicleTelemetry.h"

namespace AetherDrive {

/**
 * @brief Qt QML model exposing real-time vehicle telemetry data with property bindings.
 */
class VehicleTelemetryModel : public QObject {
    Q_OBJECT

    Q_PROPERTY(double speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(int rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(int battery READ battery NOTIFY batteryChanged)
    Q_PROPERTY(int range READ range NOTIFY rangeChanged)
    Q_PROPERTY(QString gear READ gear NOTIFY gearChanged)
    Q_PROPERTY(bool doorLocked READ doorLocked NOTIFY doorLockedChanged)
    Q_PROPERTY(double speedLimit READ speedLimit NOTIFY speedLimitChanged)
    Q_PROPERTY(QString driveMode READ driveMode NOTIFY driveModeChanged)
    Q_PROPERTY(bool laneDeparture READ laneDeparture NOTIFY laneDepartureChanged)
    Q_PROPERTY(QString alertMessage READ alertMessage NOTIFY alertMessageChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)

public:
    explicit VehicleTelemetryModel(QObject* parent = nullptr);

    // Getters
    double speed() const { return m_data.speed; }
    int rpm() const { return m_data.rpm; }
    int battery() const { return m_data.battery; }
    int range() const { return m_data.range; }
    QString gear() const { return QString::fromStdString(m_data.gear); }
    bool doorLocked() const { return m_data.doorLocked; }
    double speedLimit() const { return m_data.speedLimit; }
    QString driveMode() const { return QString::fromStdString(m_data.driveMode); }
    bool laneDeparture() const { return m_data.laneDepartureWarning; }
    QString alertMessage() const { return QString::fromStdString(m_data.alertMessage); }
    bool isConnected() const { return m_isConnected; }

public slots:
    void updateTelemetryFromJson(const QString& jsonString);
    void updateAlert(const QString& alert);
    void setConnected(bool connected);
    void setDriveMode(const QString& mode);

signals:
    void speedChanged();
    void rpmChanged();
    void batteryChanged();
    void rangeChanged();
    void gearChanged();
    void doorLockedChanged();
    void speedLimitChanged();
    void driveModeChanged();
    void laneDepartureChanged();
    void alertMessageChanged();
    void connectionChanged();

private:
    VehicleTelemetry m_data;
    bool m_isConnected{false};
};

} // namespace AetherDrive
