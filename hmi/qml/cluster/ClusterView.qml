import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../controls"

Rectangle {
    id: root

    // Telemetry properties bound to model
    property real speed: 0.0
    property int rpm: 800
    property int battery: 85
    property int range: 350
    property string gear: "P"
    property bool doorLocked: true
    property real speedLimit: 100.0
    property string driveMode: "NORMAL"
    property bool laneDeparture: false
    property string alertMessage: ""
    property string currentTime: "14:30"
    property bool isNightMode: true

    // Theme color palette
    property color bgDark: "#0A0D12"
    property color bgLight: "#F1F5F9"
    property color accentColor: "#00B4D8"
    property color warningColor: "#FFB703"

    color: isNightMode ? bgDark : bgLight
    Behavior on color { ColorAnimation { duration: 250 } }

    // Subtle background radial glow behind center speedometer
    Rectangle {
        anchors.centerIn: parent
        width: 600
        height: 400
        radius: 300
        color: root.accentColor
        opacity: root.isNightMode ? 0.04 : 0.02
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.width < 750 ? 12 : 20
        spacing: root.width < 750 ? 8 : 12

        // ================= TOP BAR =================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            // Time & Ambient Temperature
            Row {
                spacing: 8
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                Text {
                    text: root.currentTime
                    font.pixelSize: 17
                    font.weight: Font.Bold
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                }

                Rectangle {
                    width: 1
                    height: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.isNightMode ? "#2C333E" : "#CBD5E1"
                }

                Text {
                    text: "21°C"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#94A3B8" : "#64748B"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item { Layout.fillWidth: true }

            // Warning and Status Telltales
            WarningBar {
                id: warningBar
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                lowBattery: root.battery < 20
                overspeed: root.speed > root.speedLimit + 5
                laneDeparture: root.laneDeparture
                doorLocked: root.doorLocked
                alertMessage: root.alertMessage
                isNightMode: root.isNightMode
            }

            Item { Layout.fillWidth: true }

            // Day / Night Toggle & System Status
            Row {
                spacing: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                Rectangle {
                    width: 58
                    height: 26
                    radius: 6
                    color: root.isNightMode ? "#102A24" : "#DCFCE7"
                    border.color: "#10B981"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "READY"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: "#10B981"
                    }
                }

                DayNightToggle {
                    isNightMode: root.isNightMode
                    onToggled: function(night) {
                        root.isNightMode = night
                    }
                }
            }
        }

        // ================= MAIN CLUSTER GAUGES =================
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: root.width < 750 ? 6 : 12

            // LEFT: Tachometer
            Item {
                Layout.preferredWidth: root.width < 750 ? 180 : 230
                Layout.minimumWidth: 140
                Layout.maximumWidth: 260
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter

                GaugeTachometer {
                    anchors.centerIn: parent
                    rpm: root.rpm
                    isNightMode: root.isNightMode
                    accentColor: root.accentColor
                }
            }

            // CENTER: ADAS Visualizer & Speedometer
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 170
                Layout.alignment: Qt.AlignVCenter

                // ADAS Road Perspective Lane Canvas
                Canvas {
                    id: adasCanvas
                    anchors.fill: parent
                    renderTarget: Canvas.FramebufferObject

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.clearRect(0, 0, width, height);

                        var cx = width / 2;
                        var topY = height * 0.12;
                        var botY = height * 0.94;

                        // Left Road Boundary
                        ctx.beginPath();
                        ctx.moveTo(cx - 30, topY);
                        ctx.lineTo(cx - 140, botY);
                        ctx.strokeStyle = root.laneDeparture ? root.warningColor : (root.isNightMode ? "#2A3442" : "#CBD5E1");
                        ctx.lineWidth = root.laneDeparture ? 3.5 : 2.0;
                        ctx.stroke();

                        // Right Road Boundary
                        ctx.beginPath();
                        ctx.moveTo(cx + 30, topY);
                        ctx.lineTo(cx + 140, botY);
                        ctx.strokeStyle = root.laneDeparture ? root.warningColor : (root.isNightMode ? "#2A3442" : "#CBD5E1");
                        ctx.lineWidth = root.laneDeparture ? 3.5 : 2.0;
                        ctx.stroke();

                        // Dashed Center Lanes
                        ctx.beginPath();
                        ctx.setLineDash([12, 10]);
                        ctx.moveTo(cx, topY + 20);
                        ctx.lineTo(cx, botY - 30);
                        ctx.strokeStyle = root.isNightMode ? "#1E2733" : "#E2E8F0";
                        ctx.lineWidth = 1.5;
                        ctx.stroke();
                        ctx.setLineDash([]);
                    }
                }

                Connections {
                    target: root
                    function onLaneDepartureChanged() { adasCanvas.requestPaint() }
                    function onIsNightModeChanged() { adasCanvas.requestPaint() }
                }

                // Speedometer Gauge in Center
                GaugeSpeedometer {
                    anchors.centerIn: parent
                    speed: root.speed
                    speedLimit: root.speedLimit
                    isNightMode: root.isNightMode
                    accentColor: root.accentColor
                    warningColor: root.warningColor
                }

                // Vehicle Top-down Silhouette on road
                AetherIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 18
                    iconName: "car"
                    iconSize: 34
                    iconColor: root.accentColor
                }
            }

            // RIGHT: Battery/Range Widget & Gear Indicator
            ColumnLayout {
                Layout.preferredWidth: root.width < 750 ? 180 : 240
                Layout.minimumWidth: 140
                Layout.maximumWidth: 260
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 10

                BatteryRangeWidget {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 165
                    batteryLevel: root.battery
                    estimatedRange: root.range
                    isNightMode: root.isNightMode
                    accentColor: root.accentColor
                }

                GearIndicator {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    currentGear: root.gear
                    isNightMode: root.isNightMode
                    accentColor: root.accentColor
                }
            }
        }

        // ================= BOTTOM BAR =================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            // Drive Mode Pill
            Row {
                spacing: 6
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                Rectangle {
                    width: 68
                    height: 24
                    radius: 12
                    color: root.isNightMode ? "#161D26" : "#E2E8F0"
                    border.color: root.accentColor
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: root.driveMode
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.accentColor
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Odometer & Trip
            Row {
                spacing: 12
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Text {
                    text: "ODO 14,820 KM"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.0
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#94A3B8" : "#64748B"
                }

                Text {
                    text: "•"
                    font.pixelSize: 11
                    color: root.isNightMode ? "#333D4B" : "#CBD5E1"
                }

                Text {
                    text: "TRIP 142.5 KM"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.0
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#94A3B8" : "#64748B"
                }
            }

            Item { Layout.fillWidth: true }

            // Platform tag
            Row {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                Text {
                    text: "SDV PLATFORM"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#475569" : "#94A3B8"
                }
            }
        }
    }
}
