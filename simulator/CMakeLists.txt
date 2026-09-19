cmake_minimum_required(VERSION 3.20)
project(AetherDriveSimulator LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(SIMULATOR_SOURCES
    src/main.cpp
    src/VehicleSimulator.cpp
)

set(SIMULATOR_HEADERS
    src/VehicleSimulator.h
    ../common/VehicleTelemetry.h
    ../common/MqttTopics.h
)

add_executable(aether_simulator ${SIMULATOR_SOURCES} ${SIMULATOR_HEADERS})

target_include_directories(aether_simulator PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
)

# Optional MQTT library linking (if Eclipse Paho is available on the system)
find_package(PahoMqttCpp QUIET)
if(PahoMqttCpp_FOUND)
    target_link_libraries(aether_simulator PRIVATE PahoMqttCpp::paho-mqttpp3)
    target_compile_definitions(aether_simulator PRIVATE HAVE_PAHO_MQTT=1)
    message(STATUS "Paho MQTT C++ found for simulator")
else()
    message(STATUS "Paho MQTT C++ not found. Simulator will compile with standalone TCP/Console telemetry generator mode.")
endif()
