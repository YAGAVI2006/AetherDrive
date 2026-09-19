#pragma once

#include <string>
#include <sstream>
#include <iomanip>
#include <chrono>

namespace AetherDrive {

/**
 * @brief Represents the real-time telemetry frame of the vehicle.
 */
struct VehicleTelemetry {
    double speed{0.0};             // Current vehicle speed (km/h)
    int rpm{0};                    // Engine/Motor RPM (0 - 8000)
    int battery{100};              // State of Charge SoC (0 - 100%)
    int range{380};                // Estimated driving range (km)
    std::string gear{"P"};         // P, R, N, D
    bool doorLocked{true};         // Central door lock state
    std::string timestamp;         // ISO 8601 UTC timestamp
    
    // Additional automotive indicators
    double speedLimit{100.0};      // Speed limit on current road (km/h)
    std::string driveMode{"NORMAL"};// ECO, NORMAL, SPORT
    int turnSignal{0};             // 0: Off, 1: Left, 2: Right, 3: Hazard
    bool laneDepartureWarning{false};
    std::string alertMessage{""};

    /**
     * @brief Generates current ISO8601 timestamp string.
     */
    static std::string currentIsoTimestamp() {
        auto now = std::chrono::system_clock::now();
        std::time_t tt = std::chrono::system_clock::to_time_t(now);
        std::tm tm{};
#if defined(_WIN32) || defined(_WIN64)
        gmtime_s(&tm, &tt);
#else
        gmtime_r(&tt, &tm);
#endif
        std::ostringstream ss;
        ss << std::put_time(&tm, "%Y-%m-%dT%H:%M:%SZ");
        return ss.str();
    }

    /**
     * @brief Serializes the telemetry data to a clean JSON string.
     */
    std::string toJson() const {
        std::ostringstream ss;
        ss << "{\n"
           << "  \"speed\": " << static_cast<int>(speed + 0.5) << ",\n"
           << "  \"rpm\": " << rpm << ",\n"
           << "  \"battery\": " << battery << ",\n"
           << "  \"range\": " << range << ",\n"
           << "  \"gear\": \"" << gear << "\",\n"
           << "  \"door_locked\": " << (doorLocked ? "true" : "false") << ",\n"
           << "  \"speed_limit\": " << static_cast<int>(speedLimit) << ",\n"
           << "  \"drive_mode\": \"" << driveMode << "\",\n"
           << "  \"turn_signal\": " << turnSignal << ",\n"
           << "  \"lane_departure\": " << (laneDepartureWarning ? "true" : "false") << ",\n"
           << "  \"alert\": \"" << alertMessage << "\",\n"
           << "  \"timestamp\": \"" << (timestamp.empty() ? currentIsoTimestamp() : timestamp) << "\"\n"
           << "}";
        return ss.str();
    }
};

} // namespace AetherDrive
