#include "VehicleSimulator.h"
#include "MqttTopics.h"
#include <iostream>
#include <csignal>
#include <atomic>

namespace {
std::atomic<bool> g_stopRequested{false};
void signalHandler(int) {
    g_stopRequested = true;
}
}

int main(int argc, char* argv[]) {
    std::signal(SIGINT, signalHandler);
    std::signal(SIGTERM, signalHandler);

    std::cout << "=========================================================\n";
    std::cout << " AetherDrive - SDV Vehicle Telemetry Simulator (C++20)\n";
    std::cout << " Topic: " << AetherDrive::Topics::VehicleData << "\n";
    std::cout << " Broker: " << AetherDrive::Topics::DefaultBrokerHost << ":" << AetherDrive::Topics::DefaultBrokerPort << "\n";
    std::cout << " Press Ctrl+C to stop.\n";
    std::cout << "=========================================================\n\n";

    AetherDrive::VehicleSimulator simulator;
    simulator.setCallback([](const AetherDrive::VehicleTelemetry& data) {
        std::cout << "[SIMULATOR] Publishing telemetry: "
                  << "Speed=" << static_cast<int>(data.speed) << " km/h, "
                  << "RPM=" << data.rpm << ", "
                  << "Battery=" << data.battery << "%, "
                  << "Range=" << data.range << " km, "
                  << "Gear=" << data.gear
                  << (data.laneDepartureWarning ? " [LANE DEPARTURE]" : "")
                  << "\n";
    });

    simulator.start();

    while (!g_stopRequested.load()) {
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }

    std::cout << "\nStopping simulator...\n";
    simulator.stop();
    std::cout << "Simulator terminated cleanly.\n";
    return 0;
}
