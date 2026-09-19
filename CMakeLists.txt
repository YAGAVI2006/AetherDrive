cmake_minimum_required(VERSION 3.20)
project(AetherDrive VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Common include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/common)

# Optional feature flags
option(BUILD_SIMULATOR "Build C++ vehicle telemetry simulator" ON)
option(BUILD_HMI "Build Qt 6 QML Cockpit HMI" ON)

if(BUILD_SIMULATOR)
    add_subdirectory(simulator)
endif()

if(BUILD_HMI)
    add_subdirectory(hmi)
endif()
