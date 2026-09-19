import QtQuick
import QtQuick.Layouts
import "../controls"

AetherCard {
    id: root

    property int batteryLevel: 72       // Battery SoC (0-100%)
    property int estimatedRange: 295    // km
    property real powerConsumption: 16.4 // kWh / 100 km
    property color accentColor: "#00B4D8"
    property color warningColor: "#FFB703"
    property color dangerColor: "#EF233C"

    property color activeBatteryColor: {
        if (batteryLevel <= 15) return dangerColor
        if (batteryLevel <= 25) return warningColor
        return accentColor
    }

    implicitWidth: 240
    implicitHeight: 165

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // Header: Title and Battery Icon
        RowLayout {
            Layout.fillWidth: true

            Row {
                spacing: 6
                Layout.alignment: Qt.AlignVCenter

                AetherIcon {
                    iconName: "battery"
                    iconSize: 18
                    iconColor: root.activeBatteryColor
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "HV BATTERY"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                    font.family: "Segoe UI, Inter, Roboto, sans-serif"
                    color: root.isNightMode ? "#94A3B8" : "#64748B"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: root.batteryLevel + "%"
                font.pixelSize: 20
                font.weight: Font.Bold
                font.family: "Segoe UI, Inter, Roboto, sans-serif"
                color: root.activeBatteryColor
            }
        }

        // Animated Battery Fill Bar
        Rectangle {
            Layout.fillWidth: true
            height: 14
            radius: 7
            color: root.isNightMode ? "#1E242C" : "#E2E8F0"

            Rectangle {
                id: fillBar
                height: parent.height
                width: parent.width * Math.max(0.04, Math.min(1.0, root.batteryLevel / 100.0))
                radius: 7
                color: root.activeBatteryColor

                Behavior on width {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }

                // Inner glow highlight
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 3
                    radius: 7
                    color: "#FFFFFF"
                    opacity: 0.35
                }
            }
        }

        // Range and Consumption details
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4

            // Estimated Range
            Column {
                Layout.alignment: Qt.AlignLeft
                spacing: 2

                Text {
                    text: "EST. RANGE"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#64748B" : "#94A3B8"
                }

                Row {
                    spacing: 4
                    Text {
                        text: root.estimatedRange.toString()
                        font.pixelSize: 26
                        font.weight: Font.Bold
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                    }
                    Text {
                        text: "KM"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.accentColor
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 4
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Average Consumption
            Column {
                Layout.alignment: Qt.AlignRight
                spacing: 2

                Text {
                    text: "AVG USAGE"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#64748B" : "#94A3B8"
                    horizontalAlignment: Text.AlignRight
                }

                Row {
                    spacing: 4
                    anchors.right: parent.right
                    Text {
                        text: root.powerConsumption.toFixed(1)
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                    }
                    Text {
                        text: "kWh"
                        font.pixelSize: 11
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#94A3B8" : "#64748B"
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3
                    }
                }
            }
        }
    }
}
