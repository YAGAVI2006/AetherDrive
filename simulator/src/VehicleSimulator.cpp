#include "VehicleSimulator.h"
#include <cmath>
#include <iostream>

namespace AetherDrive {

VehicleSimulator::VehicleSimulator() {
    m_telemetry.speed = 0.0;
    m_telemetry.rpm = 800;
    m_telemetry.battery = 85;
    m_telemetry.range = static_cast<int>(m_batteryFloat * 4.1);
    m_telemetry.gear = "P";
    m_telemetry.doorLocked = true;
    m_telemetry.driveMode = "NORMAL";
    m_telemetry.speedLimit = 100.0;
}

VehicleSimulator::~VehicleSimulator() {
    stop();
}

void VehicleSimulator::setCallback(TelemetryCallback cb) {
    m_callback = std::move(cb);
}

void VehicleSimulator::start() {
    if (m_running.load()) return;
    m_running.store(true);
    m_workerThread = std::thread(&VehicleSimulator::runLoop, this);
}

void VehicleSimulator::stop() {
    if (!m_running.load()) return;
    m_running.store(false);
    if (m_workerThread.joinable()) {
        m_workerThread.join();
    }
}

bool VehicleSimulator::isRunning() const {
    return m_running.load();
}

void VehicleSimulator::setTargetSpeed(double targetSpeedKmH) {
    m_targetSpeed = targetSpeedKmH;
}

void VehicleSimulator::setGear(const std::string& gear) {
    m_telemetry.gear = gear;
}

void VehicleSimulator::triggerLaneDeparture(bool active) {
    m_laneAlertActive = active;
}

void VehicleSimulator::updatePhysics(double dt) {
    m_timeElapsed += dt;

    // Natural highway driving speed profile simulation (0 -> 45 -> 75 -> 105 -> 65 -> 80)
    // Sine harmonic wave creates realistic traffic variations
    double speedOscillation = 18.0 * std::sin(m_timeElapsed * 0.15) + 8.0 * std::cos(m_timeElapsed * 0.35);
    double desiredSpeed = std::max(0.0, m_targetSpeed + speedOscillation);

    // Initial warm-up gear shifting
    if (m_timeElapsed < 2.0) {
        m_telemetry.gear = "P";
        desiredSpeed = 0.0;
    } else if (m_telemetry.gear == "P") {
        m_telemetry.gear = "D";
    }

    // Smooth speed change
    if (m_telemetry.speed < desiredSpeed) {
        m_telemetry.speed += m_accelerationRate * dt * 4.0;
        if (m_telemetry.speed > desiredSpeed) m_telemetry.speed = desiredSpeed;
    } else if (m_telemetry.speed > desiredSpeed) {
        m_telemetry.speed -= m_accelerationRate * dt * 3.0; // deceleration
        if (m_telemetry.speed < desiredSpeed) m_telemetry.speed = desiredSpeed;
    }

    // RPM calculations: base motor/engine rpm directly scaled with speed
    if (m_telemetry.speed < 1.0) {
        m_telemetry.rpm = 800; // Idle
    } else {
        // Gear ratio simulation
        double baseRpm = 1000.0 + (m_telemetry.speed * 42.0);
        // Add subtle engine flutter
        double jitter = 35.0 * std::sin(m_timeElapsed * 1.5);
        m_telemetry.rpm = static_cast<int>(baseRpm + jitter);
    }

    // Battery & Regenerative Braking
    if (m_telemetry.speed > desiredSpeed) {
        // Regenerative braking: slight recharge
        m_batteryFloat += 0.002 * dt;
    } else {
        // Power consumption based on speed squared
        double powerDrain = (0.012 + (m_telemetry.speed / 140.0) * 0.02) * dt;
        m_batteryFloat -= powerDrain;
    }
    if (m_batteryFloat < 5.0) m_batteryFloat = 98.0; // reset for continuous demo

    m_telemetry.battery = static_cast<int>(std::round(m_batteryFloat));
    m_telemetry.range = static_cast<int>(m_batteryFloat * 4.1);

    // Auto door locking above 15 km/h
    m_telemetry.doorLocked = (m_telemetry.speed > 15.0);

    // Dynamic alerts
    m_telemetry.laneDepartureWarning = m_laneAlertActive || (std::fmod(m_timeElapsed, 45.0) > 40.0);
    if (m_telemetry.speed > m_telemetry.speedLimit + 10.0) {
        m_telemetry.alertMessage = "Overspeed Warning: Exceeding Road Limit";
    } else if (m_telemetry.battery < 20) {
        m_telemetry.alertMessage = "Low Battery: Find Nearest Charger";
    } else if (m_telemetry.laneDepartureWarning) {
        m_telemetry.alertMessage = "Lane Departure: Keep Vehicle Centered";
    } else {
        m_telemetry.alertMessage = "";
    }

    m_telemetry.timestamp = VehicleTelemetry::currentIsoTimestamp();
}

void VehicleSimulator::runLoop() {
    const double dt = 0.1; // 100ms update rate = 10 Hz
    while (m_running.load()) {
        updatePhysics(dt);

        if (m_callback) {
            m_callback(m_telemetry);
        }

        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
}

} // namespace AetherDrive
