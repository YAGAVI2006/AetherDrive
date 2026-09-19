cmake_minimum_required(VERSION 3.20)
project(AetherDriveHMI LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Network
)

set(HMI_SOURCES
    src/main.cpp
    src/VehicleTelemetryModel.cpp
    src/MqttClient.cpp
    src/ThemeController.cpp
    src/OtaManager.cpp
)

set(HMI_HEADERS
    src/VehicleTelemetryModel.h
    src/MqttClient.h
    src/ThemeController.h
    src/OtaManager.h
    ../common/VehicleTelemetry.h
    ../common/MqttTopics.h
)

set(HMI_QML_FILES
    qml/Main.qml
    qml/cluster/ClusterView.qml
    qml/cluster/GaugeSpeedometer.qml
    qml/cluster/GaugeTachometer.qml
    qml/cluster/BatteryRangeWidget.qml
    qml/cluster/GearIndicator.qml
    qml/cluster/WarningBar.qml
    qml/cluster/DayNightToggle.qml
    qml/infotainment/InfotainmentView.qml
    qml/infotainment/HomeScreen.qml
    qml/infotainment/NavigationScreen.qml
    qml/infotainment/MediaScreen.qml
    qml/infotainment/ClimateScreen.qml
    qml/infotainment/OtaScreen.qml
    qml/controls/AetherCard.qml
    qml/controls/AetherButton.qml
    qml/controls/AetherSlider.qml
    qml/controls/AetherIcon.qml
)

qt_add_executable(aether_hmi
    ${HMI_SOURCES}
    ${HMI_HEADERS}
)

target_include_directories(aether_hmi PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/../common
)

target_link_libraries(aether_hmi PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
)

# Qt 6 QML module setup
qt_add_qml_module(aether_hmi
    URI AetherCockpit
    VERSION 1.0
    QML_FILES ${HMI_QML_FILES}
)
