#pragma once

#include "VehicleTelemetry.h"
#include <functional>
#include <atomic>
#include <thread>
#include <chrono>

namespace AetherDrive {

class VehicleSimulator {
public:
    using TelemetryCallback = std::function<void(const VehicleTelemetry&)>;

    VehicleSimulator();
    ~VehicleSimulator();

    void setCallback(TelemetryCallback cb);
    void start();
    void stop();
    bool isRunning() const;

    // Simulation controls
    void setTargetSpeed(double targetSpeedKmH);
    void setGear(const std::string& gear);
    void triggerLaneDeparture(bool active);

private:
    void runLoop();
    void updatePhysics(double deltaTimeSec);

    std::atomic<bool> m_running{false};
    std::thread m_workerThread;
    TelemetryCallback m_callback;

    VehicleTelemetry m_telemetry;
    double m_targetSpeed{72.0};
    double m_accelerationRate{3.8}; // m/s^2
    double m_batteryFloat{85.0};
    double m_timeElapsed{0.0};
    bool m_laneAlertActive{false};
};

} // namespace AetherDrive
