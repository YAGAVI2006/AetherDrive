import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../controls"

Item {
    id: root

    property bool isNightMode: true
    property color accentColor: "#00B4D8"
    property real driverTemp: 21.5
    property real passengerTemp: 22.0
    property int fanSpeed: 3
    property bool autoAc: true
    property bool acEnabled: true
    property bool recirculate: false
    property bool frontDefrost: false
    property bool rearDefrost: false
    property int driverSeatHeat: 2     // 0: off, 1: low, 2: med, 3: high
    property int passengerSeatHeat: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "CLIMATE CONTROL SYSTEM"
                font.pixelSize: 13
                font.weight: Font.Bold
                font.letterSpacing: 1.5
                color: root.isNightMode ? "#94A3B8" : "#64748B"
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "CABIN TEMP: 21.8°C"
                font.pixelSize: 13
                font.weight: Font.Bold
                color: root.accentColor
            }
        }

        // Dual Temperature Hub Cards
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            spacing: 24

            // DRIVER ZONE
            AetherCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                isNightMode: root.isNightMode

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "DRIVER ZONE"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1
                        color: root.isNightMode ? "#64748B" : "#94A3B8"
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 16

                        // Decrement Temp
                        Rectangle {
                            width: 38
                            height: 38
                            radius: 19
                            color: root.isNightMode ? "#1E2632" : "#E2E8F0"
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "−"
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.driverTemp = Math.max(16.0, root.driverTemp - 0.5)
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.driverTemp.toFixed(1) + "°C"
                            font.pixelSize: 36
                            font.weight: Font.Bold
                            font.family: "Segoe UI, Inter, sans-serif"
                            color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                        }

                        // Increment Temp
                        Rectangle {
                            width: 38
                            height: 38
                            radius: 19
                            color: root.isNightMode ? "#1E2632" : "#E2E8F0"
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.driverTemp = Math.min(29.0, root.driverTemp + 0.5)
                            }
                        }
                    }

                    // Seat Heater Indicator
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        Text {
                            text: "SEAT HEATER"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: root.isNightMode ? "#64748B" : "#94A3B8"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Row {
                            spacing: 3
                            anchors.verticalCenter: parent.verticalCenter
                            Repeater {
                                model: 3
                                Rectangle {
                                    width: 12
                                    height: 6
                                    radius: 2
                                    color: (index < root.driverSeatHeat) ? "#FB8500" : (root.isNightMode ? "#2C3440" : "#CBD5E1")
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.driverSeatHeat = (root.driverSeatHeat + 1) % 4
                        }
                    }
                }
            }

            // PASSENGER ZONE
            AetherCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                isNightMode: root.isNightMode

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "PASSENGER ZONE"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1
                        color: root.isNightMode ? "#64748B" : "#94A3B8"
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 16

                        Rectangle {
                            width: 38
                            height: 38
                            radius: 19
                            color: root.isNightMode ? "#1E2632" : "#E2E8F0"
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "−"
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.passengerTemp = Math.max(16.0, root.passengerTemp - 0.5)
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.passengerTemp.toFixed(1) + "°C"
                            font.pixelSize: 36
                            font.weight: Font.Bold
                            font.family: "Segoe UI, Inter, sans-serif"
                            color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                        }

                        Rectangle {
                            width: 38
                            height: 38
                            radius: 19
                            color: root.isNightMode ? "#1E2632" : "#E2E8F0"
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.passengerTemp = Math.min(29.0, root.passengerTemp + 0.5)
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        Text {
                            text: "SEAT HEATER"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: root.isNightMode ? "#64748B" : "#94A3B8"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Row {
                            spacing: 3
                            anchors.verticalCenter: parent.verticalCenter
                            Repeater {
                                model: 3
                                Rectangle {
                                    width: 12
                                    height: 6
                                    radius: 2
                                    color: (index < root.passengerSeatHeat) ? "#FB8500" : (root.isNightMode ? "#2C3440" : "#CBD5E1")
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.passengerSeatHeat = (root.passengerSeatHeat + 1) % 4
                        }
                    }
                }
            }
        }

        // Fan Speed Controller
        AetherCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            isNightMode: root.isNightMode

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                AetherIcon {
                    iconName: "climate"
                    iconSize: 24
                    iconColor: root.accentColor
                }

                Text {
                    text: "FAN SPEED"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                    color: root.isNightMode ? "#94A3B8" : "#64748B"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: 5
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 16
                            radius: 4
                            color: (index < root.fanSpeed) ? root.accentColor : (root.isNightMode ? "#1E2632" : "#E2E8F0")

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.fanSpeed = index + 1
                            }
                        }
                    }
                }

                Text {
                    text: "LVL " + root.fanSpeed
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: root.accentColor
                }
            }
        }

        // Mode Toggles Grid
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Repeater {
                model: [
                    { label: "AUTO AC", active: root.autoAc, key: "auto" },
                    { label: "A/C MAX", active: root.acEnabled, key: "ac" },
                    { label: "RECIRC", active: root.recirculate, key: "recirc" },
                    { label: "FRONT DEFROST", active: root.frontDefrost, key: "fdef" },
                    { label: "REAR DEFROST", active: root.rearDefrost, key: "rdef" }
                ]

                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    radius: 12
                    color: modelData.active ? root.accentColor : (root.isNightMode ? "#161D26" : "#E2E8F0")
                    border.color: modelData.active ? Qt.lighter(root.accentColor, 1.2) : (root.isNightMode ? "#2C3440" : "#CBD5E1")
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 0.8
                        color: modelData.active ? "#0A0A0A" : (root.isNightMode ? "#E2E8F0" : "#1E293B")
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.key === "auto") root.autoAc = !root.autoAc;
                            if (modelData.key === "ac") root.acEnabled = !root.acEnabled;
                            if (modelData.key === "recirc") root.recirculate = !root.recirculate;
                            if (modelData.key === "fdef") root.frontDefrost = !root.frontDefrost;
                            if (modelData.key === "rdef") root.rearDefrost = !root.rearDefrost;
                        }
                    }
                }
            }
        }
    }
}
