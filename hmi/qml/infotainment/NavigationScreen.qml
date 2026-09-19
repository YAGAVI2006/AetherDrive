import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../controls"

Item {
    id: root

    property bool isNightMode: true
    property color accentColor: "#00B4D8"

    // Dynamic map animation
    property real carProgress: 0.35
    NumberAnimation on carProgress {
        from: 0.1
        to: 0.9
        duration: 25000
        loops: Animation.Infinite
    }

    // Map Canvas
    Canvas {
        id: mapCanvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            var w = width;
            var h = height;

            // Background terrain
            ctx.fillStyle = root.isNightMode ? "#0D1117" : "#E2E8F0";
            ctx.fillRect(0, 0, w, h);

            // Street Grid / Blocks
            ctx.strokeStyle = root.isNightMode ? "#161E28" : "#CBD5E1";
            ctx.lineWidth = 1.0;
            var gridSize = 60;
            for (var x = 0; x < w; x += gridSize) {
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x, h);
                ctx.stroke();
            }
            for (var y = 0; y < h; y += gridSize) {
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(w, y);
                ctx.stroke();
            }

            // Secondary Roads
            ctx.strokeStyle = root.isNightMode ? "#202A36" : "#F1F5F9";
            ctx.lineWidth = 10;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            ctx.beginPath();
            ctx.moveTo(w * 0.1, h * 0.2);
            ctx.lineTo(w * 0.85, h * 0.25);
            ctx.stroke();

            ctx.beginPath();
            ctx.moveTo(w * 0.3, h * 0.1);
            ctx.lineTo(w * 0.35, h * 0.9);
            ctx.stroke();

            // Main Active Route Line
            // Route Glow
            ctx.strokeStyle = root.accentColor;
            ctx.globalAlpha = 0.3;
            ctx.lineWidth = 16;
            ctx.beginPath();
            ctx.moveTo(w * 0.2, h * 0.8);
            ctx.bezierCurveTo(w * 0.4, h * 0.75, w * 0.45, h * 0.4, w * 0.75, h * 0.3);
            ctx.stroke();
            ctx.globalAlpha = 1.0;

            // Route Core
            ctx.strokeStyle = root.accentColor;
            ctx.lineWidth = 7;
            ctx.beginPath();
            ctx.moveTo(w * 0.2, h * 0.8);
            ctx.bezierCurveTo(w * 0.4, h * 0.75, w * 0.45, h * 0.4, w * 0.75, h * 0.3);
            ctx.stroke();

            // Destination Pin
            var destX = w * 0.75;
            var destY = h * 0.3;
            ctx.fillStyle = "#EF233C";
            ctx.beginPath();
            ctx.arc(destX, destY, 9, 0, Math.PI * 2);
            ctx.fill();
            ctx.strokeStyle = "#FFFFFF";
            ctx.lineWidth = 2.5;
            ctx.stroke();

            // Vehicle GPS Marker position along bezier
            var t = root.carProgress;
            var p0 = { x: w * 0.2, y: h * 0.8 };
            var p1 = { x: w * 0.4, y: h * 0.75 };
            var p2 = { x: w * 0.45, y: h * 0.4 };
            var p3 = { x: w * 0.75, y: h * 0.3 };

            // Cubic bezier formula
            var cx = Math.pow(1 - t, 3) * p0.x + 3 * Math.pow(1 - t, 2) * t * p1.x + 3 * (1 - t) * Math.pow(t, 2) * p2.x + Math.pow(t, 3) * p3.x;
            var cy = Math.pow(1 - t, 3) * p0.y + 3 * Math.pow(1 - t, 2) * t * p1.y + 3 * (1 - t) * Math.pow(t, 2) * p2.y + Math.pow(t, 3) * p3.y;

            // Vehicle marker pulse circle
            ctx.fillStyle = root.accentColor;
            ctx.globalAlpha = 0.25;
            ctx.beginPath();
            ctx.arc(cx, cy, 22, 0, Math.PI * 2);
            ctx.fill();
            ctx.globalAlpha = 1.0;

            // Vehicle marker dot
            ctx.fillStyle = "#FFFFFF";
            ctx.beginPath();
            ctx.arc(cx, cy, 7, 0, Math.PI * 2);
            ctx.fill();
            ctx.strokeStyle = root.accentColor;
            ctx.lineWidth = 3;
            ctx.stroke();
        }
    }

    onCarProgressChanged: mapCanvas.requestPaint()
    onIsNightModeChanged: mapCanvas.requestPaint()

    // Turn-by-Turn Guidance Banner Overlay (Top)
    AetherCard {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 18
        height: 76
        isNightMode: root.isNightMode

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            // Turn arrow container
            Rectangle {
                width: 44
                height: 44
                radius: 12
                color: "#10B981"

                AetherIcon {
                    anchors.centerIn: parent
                    iconName: "navigation"
                    iconSize: 24
                    iconColor: "#FFFFFF"
                    rotation: 90
                }
            }

            Column {
                spacing: 2
                Text {
                    text: "In 450 m Turn Right"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                }
                Text {
                    text: "Then take Cyberway Boulevard toward Tech Hub"
                    font.pixelSize: 12
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#94A3B8" : "#64748B"
                }
            }

            Item { Layout.fillWidth: true }

            Column {
                Layout.alignment: Qt.AlignRight
                spacing: 2

                Text {
                    text: "18 MIN • 14.2 KM"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.accentColor
                }
                Text {
                    text: "ETA 14:48 • On Time"
                    font.pixelSize: 12
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: "#10B981"
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    // Floating Map Controls (Right edge)
    Column {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        spacing: 12

        AetherCard {
            width: 44
            height: 44
            radius: 22
            isNightMode: root.isNightMode

            Text {
                anchors.centerIn: parent
                text: "+"
                font.pixelSize: 22
                font.weight: Font.Bold
                color: root.isNightMode ? "#FFFFFF" : "#0F172A"
            }
        }

        AetherCard {
            width: 44
            height: 44
            radius: 22
            isNightMode: root.isNightMode

            Text {
                anchors.centerIn: parent
                text: "−"
                font.pixelSize: 22
                font.weight: Font.Bold
                color: root.isNightMode ? "#FFFFFF" : "#0F172A"
            }
        }

        AetherCard {
            width: 44
            height: 44
            radius: 22
            isNightMode: root.isNightMode

            AetherIcon {
                anchors.centerIn: parent
                iconName: "navigation"
                iconSize: 20
                iconColor: root.accentColor
            }
        }
    }
}
