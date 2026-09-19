#pragma once

#include <string_view>

namespace AetherDrive {
namespace Topics {

// Vehicle Telemetry Data stream (speed, rpm, battery, range, etc.)
constexpr std::string_view VehicleData = "aetherdrive/vehicle/data";

// Vehicle Alerts (lane departure, collision warning, low battery, overspeed)
constexpr std::string_view VehicleAlert = "aetherdrive/vehicle/alert";

// Vehicle Control / Commands (door locks, lights, drive mode)
constexpr std::string_view VehicleControl = "aetherdrive/vehicle/control";

// Over-the-Air (OTA) update status and triggers
constexpr std::string_view SystemOta = "aetherdrive/system/ota";

// Default public MQTT Broker
constexpr std::string_view DefaultBrokerHost = "broker.emqx.io";
constexpr int DefaultBrokerPort = 1883;

} // namespace Topics
} // namespace AetherDrive
