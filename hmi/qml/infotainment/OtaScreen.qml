import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../controls"

Item {
    id: root

    property bool isNightMode: true
    property color accentColor: "#00B4D8"
    property string currentVersion: "v2.3.4"
    property string targetVersion: "v2.4.0"
    property int otaProgress: 0
    property bool isUpdating: false
    property string statusText: "Software update ready for installation."

    // Timer simulating the download and flash steps when triggered
    Timer {
        id: otaTimer
        interval: 100
        repeat: true
        running: root.isUpdating
        onTriggered: {
            root.otaProgress += 2
            if (root.otaProgress < 50) {
                root.statusText = "Downloading OTA Package (248 MB)... " + root.otaProgress + "%"
            } else if (root.otaProgress < 85) {
                root.statusText = "Verifying cryptographic signatures & SHA-256 integrity... " + root.otaProgress + "%"
            } else if (root.otaProgress < 100) {
                root.statusText = "Flashing SDV ECUs and configuring cluster modules... " + root.otaProgress + "%"
            } else {
                root.otaProgress = 100
                root.isUpdating = false
                root.currentVersion = root.targetVersion
                root.statusText = "System successfully updated to " + root.targetVersion + "!"
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true
            AetherIcon {
                iconName: "ota"
                iconSize: 24
                iconColor: "#10B981"
            }
            Text {
                text: "SOFTWARE DEFINED VEHICLE • OTA MANAGER"
                font.pixelSize: 13
                font.weight: Font.Bold
                font.letterSpacing: 1.5
                color: root.isNightMode ? "#94A3B8" : "#64748B"
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "ACTIVE: " + root.currentVersion
                font.pixelSize: 13
                font.weight: Font.Bold
                color: root.accentColor
            }
        }

        // Main OTA Card
        AetherCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            isNightMode: root.isNightMode

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    Column {
                        spacing: 4
                        Text {
                            text: "AetherOS " + root.targetVersion + " Feature Update"
                            font.pixelSize: 22
                            font.weight: Font.Bold
                            color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                        }
                        Text {
                            text: "Release 2026.09 • 248 MB • High Priority Security & ADAS Release"
                            font.pixelSize: 12
                            color: root.isNightMode ? "#94A3B8" : "#64748B"
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 90
                        height: 30
                        radius: 8
                        color: "#102A24"
                        border.color: "#10B981"
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "OFFICIAL"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                            color: "#10B981"
                        }
                    }
                }

                // Release Notes
                AetherCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    isNightMode: root.isNightMode

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        Text {
                            text: "WHAT'S NEW IN THIS RELEASE:"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                            color: root.isNightMode ? "#64748B" : "#94A3B8"
                        }

                        Text {
                            text: "• Vision-based Lane Departure Warning integration using OpenCV edge AI"
                            font.pixelSize: 13
                            color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                        }
                        Text {
                            text: "• Fluid 60 FPS Canvas rendering optimizations for Speedometer & Tachometer"
                            font.pixelSize: 13
                            color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                        }
                        Text {
                            text: "• MQTT telemetry latency reduction and automatic failover reconnection logic"
                            font.pixelSize: 13
                            color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                        }
                        Text {
                            text: "• Regenerative braking energy recuperation curve improvements (+4.5% efficiency)"
                            font.pixelSize: 13
                            color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                        }
                    }
                }

                // Progress Bar Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.statusText
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.otaProgress + "%"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                            color: root.accentColor
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 10
                        radius: 5
                        color: root.isNightMode ? "#1E2632" : "#E2E8F0"

                        Rectangle {
                            height: parent.height
                            width: parent.width * (root.otaProgress / 100.0)
                            radius: 5
                            color: root.accentColor
                            Behavior on width { NumberAnimation { duration: 100 } }
                        }
                    }
                }

                // Action Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    AetherButton {
                        Layout.preferredWidth: 200
                        text: root.isUpdating ? "Updating System..." : (root.currentVersion === root.targetVersion ? "System Up to Date" : "Install Update Now")
                        isPrimary: true
                        enabled: !root.isUpdating && root.currentVersion !== root.targetVersion
                        isNightMode: root.isNightMode
                        onClicked: {
                            root.isUpdating = true
                            root.otaProgress = 0
                        }
                    }

                    AetherButton {
                        Layout.preferredWidth: 160
                        text: "Check for Updates"
                        enabled: !root.isUpdating
                        isNightMode: root.isNightMode
                        onClicked: {
                            root.statusText = "Checking AetherCloud update servers... System verified."
                        }
                    }
                }
            }
        }
    }
}
