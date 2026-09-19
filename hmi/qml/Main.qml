import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "cluster"
import "infotainment"
import "controls"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1600
    height: 860
    minimumWidth: 1080
    minimumHeight: 640
    title: "AetherDrive – SDV Digital Cockpit & Connected Vehicle Platform"

    // Global state
    property bool isNightMode: (typeof themeController !== "undefined") ? themeController.isNightMode : true
    property int cockpitViewMode: 0 // 0: Dual Panoramic (Cluster + Infotainment), 1: Cluster Only, 2: Infotainment Only

    // Internal simulation fallback if no external MQTT source is active
    property bool standaloneSim: false
    property real simSpeed: 68.0
    property int simRpm: 2300
    property int simBattery: 78
    property int simRange: 320
    property string simGear: "D"
    property bool simDoorLocked: true
    property bool simLaneAlert: false
    property string simAlertMsg: ""

    // Live telemetry properties: read from C++ or PySide6 telemetryModel if available, else standaloneSim
    readonly property real liveSpeed: (typeof telemetryModel !== "undefined" && telemetryModel.isConnected) ? 
                                       telemetryModel.speed : (standaloneSim ? simSpeed : 
                                       (typeof telemetryModel !== "undefined" ? telemetryModel.speed : 68.0))
    readonly property int liveRpm: (typeof telemetryModel !== "undefined" && telemetryModel.isConnected) ? 
                                    telemetryModel.rpm : (standaloneSim ? simRpm : 
                                    (typeof telemetryModel !== "undefined" ? telemetryModel.rpm : 2300))
    readonly property int liveBattery: (typeof telemetryModel !== "undefined" && telemetryModel.isConnected) ? 
                                        telemetryModel.battery : (standaloneSim ? simBattery : 
                                        (typeof telemetryModel !== "undefined" ? telemetryModel.battery : 78))
    readonly property int liveRange: (typeof telemetryModel !== "undefined" && telemetryModel.isConnected) ? 
                                      telemetryModel.range : (standaloneSim ? simRange : 
                                      (typeof telemetryModel !== "undefined" ? telemetryModel.range : 320))
    readonly property string liveGear: (typeof telemetryModel !== "undefined" && telemetryModel.isConnected) ? 
                                        telemetryModel.gear : (standaloneSim ? simGear : 
                                        (typeof telemetryModel !== "undefined" ? telemetryModel.gear : "D"))
    readonly property bool liveDoorLocked: (typeof telemetryModel !== "undefined" && telemetryModel.isConnected) ? 
                                            telemetryModel.doorLocked : (standaloneSim ? simDoorLocked : true)
    readonly property bool liveLaneAlert: (typeof telemetryModel !== "undefined" && telemetryModel.isConnected) ? 
                                           telemetryModel.laneDeparture : (standaloneSim ? simLaneAlert : false)
    readonly property string liveAlertMsg: (typeof telemetryModel !== "undefined" && telemetryModel.isConnected) ? 
                                            telemetryModel.alertMessage : (standaloneSim ? simAlertMsg : "")

    // Background color
    color: isNightMode ? "#080B0F" : "#EDF2F7"

    // Standalone dynamic test loop
    Timer {
        id: localSimTimer
        interval: 100
        repeat: true
        running: mainWindow.standaloneSim
        property real t: 0.0
        onTriggered: {
            t += 0.1
            var wave = Math.sin(t * 0.15) * 20.0 + Math.cos(t * 0.35) * 8.0
            mainWindow.simSpeed = Math.max(0, 68.0 + wave)
            mainWindow.simRpm = Math.round(950 + (mainWindow.simSpeed * 38.0))
            mainWindow.simBattery = Math.max(5, 78 - Math.round(t * 0.02))
            mainWindow.simRange = Math.round(mainWindow.simBattery * 4.1)
            mainWindow.simLaneAlert = (Math.floor(t) % 35 >= 31)
            mainWindow.simAlertMsg = mainWindow.simLaneAlert ? "LANE DEPARTURE: Keep vehicle centered" : ""
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ================= TOP COCKPIT CONTROL BAR =================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            color: mainWindow.isNightMode ? "#0C0F15" : "#E2E8F0"
            border.color: mainWindow.isNightMode ? "#1E2632" : "#CBD5E1"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                // Brand
                Row {
                    spacing: 8
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: "#00B4D8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "AETHERDRIVE COCKPIT"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 1.5
                        color: mainWindow.isNightMode ? "#FFFFFF" : "#0F172A"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item { Layout.fillWidth: true }

                // View Mode Switcher
                Row {
                    spacing: 4
                    Layout.alignment: Qt.AlignVCenter

                    Repeater {
                        model: ["Panoramic Cockpit", "Cluster Only", "Infotainment Only"]
                        Rectangle {
                            width: 130
                            height: 28
                            radius: 6
                            color: (mainWindow.cockpitViewMode === index) ? "#00B4D8" : "transparent"
                            border.color: (mainWindow.cockpitViewMode === index) ? "#00B4D8" : (mainWindow.isNightMode ? "#2A3442" : "#CBD5E1")
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 11
                                font.weight: (mainWindow.cockpitViewMode === index) ? Font.Bold : Font.Normal
                                color: (mainWindow.cockpitViewMode === index) ? "#0A0A0A" : (mainWindow.isNightMode ? "#94A3B8" : "#64748B")
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mainWindow.cockpitViewMode = index
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // MQTT / Demo Status
                Row {
                    spacing: 12
                    Layout.alignment: Qt.AlignVCenter

                    // Live demo trigger
                    Rectangle {
                        width: 108
                        height: 26
                        radius: 6
                        color: mainWindow.standaloneSim ? "#1E3A8A" : (mainWindow.isNightMode ? "#161D26" : "#E2E8F0")
                        border.color: mainWindow.standaloneSim ? "#3B82F6" : (mainWindow.isNightMode ? "#2C3440" : "#CBD5E1")
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: mainWindow.standaloneSim ? "Sim: Active" : "Sim: Off"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: mainWindow.standaloneSim ? "#93C5FD" : (mainWindow.isNightMode ? "#94A3B8" : "#64748B")
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mainWindow.standaloneSim = !mainWindow.standaloneSim
                        }
                    }

                    // MQTT Indicator
                    Row {
                        spacing: 6
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: (typeof telemetryModel !== "undefined" && telemetryModel.isConnected) ? "#10B981" : "#F59E0B"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: (typeof telemetryModel !== "undefined" && telemetryModel.isConnected) ? 
                                  "MQTT: broker.emqx.io" : "MQTT: Standby"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: mainWindow.isNightMode ? "#94A3B8" : "#64748B"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }

        // ================= PANORAMIC / MULTI-SCREEN VIEWPORT =================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 0: Panoramic Split Screen (Cluster on Left 58%, Infotainment on Right 42%)
            Item {
                anchors.fill: parent
                visible: mainWindow.cockpitViewMode === 0

                // Vertical Divider Line at 58% of panoramic width
                Rectangle {
                    id: splitDivider
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(mainWindow.width * 0.58)
                    width: 2
                    color: mainWindow.isNightMode ? "#1E2632" : "#CBD5E1"
                }

                // Left: Instrument Cluster
                ClusterView {
                    id: splitCluster
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: splitDivider.left

                    speed: mainWindow.liveSpeed
                    rpm: mainWindow.liveRpm
                    battery: mainWindow.liveBattery
                    range: mainWindow.liveRange
                    gear: mainWindow.liveGear
                    doorLocked: mainWindow.liveDoorLocked
                    laneDeparture: mainWindow.liveLaneAlert
                    alertMessage: mainWindow.liveAlertMsg
                    isNightMode: mainWindow.isNightMode
                }

                // Right: Infotainment System
                InfotainmentView {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: splitDivider.right
                    anchors.right: parent.right
                    isNightMode: mainWindow.isNightMode
                }
            }

            // 1: Fullscreen Instrument Cluster
            ClusterView {
                anchors.fill: parent
                visible: mainWindow.cockpitViewMode === 1
                speed: mainWindow.liveSpeed
                rpm: mainWindow.liveRpm
                battery: mainWindow.liveBattery
                range: mainWindow.liveRange
                gear: mainWindow.liveGear
                doorLocked: mainWindow.liveDoorLocked
                laneDeparture: mainWindow.liveLaneAlert
                alertMessage: mainWindow.liveAlertMsg
                isNightMode: mainWindow.isNightMode
            }

            // 2: Fullscreen Infotainment
            InfotainmentView {
                anchors.fill: parent
                visible: mainWindow.cockpitViewMode === 2
                isNightMode: mainWindow.isNightMode
            }
        }
    }
}
