import QtQuick
import "../controls"

Item {
    id: root

    property real speed: 0.0          // Current speed in km/h
    property real maxSpeed: 240.0
    property real speedLimit: 100.0   // Road speed limit in km/h
    property bool isNightMode: true
    property color accentColor: "#00B4D8"
    property color warningColor: "#FFB703"
    property color dangerColor: "#EF233C"

    // Internal animated speed for silky 60fps gauge movement
    property real animatedSpeed: speed
    Behavior on animatedSpeed {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    implicitWidth: 280
    implicitHeight: 280
    width: Math.min(parent ? parent.width : 280, parent ? parent.height : 280, 280)
    height: width

    readonly property real startAngleDeg: 140
    readonly property real totalAngleDeg: 260
    readonly property real currentAngleDeg: startAngleDeg + (Math.min(animatedSpeed, maxSpeed) / maxSpeed) * totalAngleDeg

    Canvas {
        id: dialCanvas
        anchors.fill: parent
        antialiasing: true
        smooth: true
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            var cx = width / 2;
            var cy = height / 2;
            var radius = Math.min(width, height) * 0.42;

            var deg2rad = Math.PI / 180;
            var startRad = root.startAngleDeg * deg2rad;
            var endRad = (root.startAngleDeg + root.totalAngleDeg) * deg2rad;
            var curRad = root.currentAngleDeg * deg2rad;

            // 1. Background Track Arc
            ctx.beginPath();
            ctx.arc(cx, cy, radius, startRad, endRad, false);
            ctx.strokeStyle = root.isNightMode ? "#181E26" : "#E2E8F0";
            ctx.lineWidth = 14;
            ctx.lineCap = "round";
            ctx.stroke();

            // 2. Active Speed Glow & Arc
            if (root.animatedSpeed > 0.5) {
                // Determine active color: warning if overspeed limit
                var isOverspeed = (root.animatedSpeed > root.speedLimit + 5);
                var activeColor = isOverspeed ? root.warningColor : root.accentColor;

                // Subtle outer glow
                ctx.beginPath();
                ctx.arc(cx, cy, radius, startRad, curRad, false);
                ctx.strokeStyle = activeColor;
                ctx.lineWidth = 18;
                ctx.globalAlpha = 0.25;
                ctx.stroke();
                ctx.globalAlpha = 1.0;

                // Core gradient arc
                var grad = ctx.createLinearGradient(0, cy + radius, width, cy - radius);
                if (isOverspeed) {
                    grad.addColorStop(0.0, "#FB8500");
                    grad.addColorStop(1.0, root.warningColor);
                } else {
                    grad.addColorStop(0.0, "#0077B6");
                    grad.addColorStop(0.7, root.accentColor);
                    grad.addColorStop(1.0, "#90E0EF");
                }

                ctx.beginPath();
                ctx.arc(cx, cy, radius, startRad, curRad, false);
                ctx.strokeStyle = grad;
                ctx.lineWidth = 12;
                ctx.lineCap = "round";
                ctx.stroke();
            }

            // 3. Ticks and Labels
            ctx.font = "600 11px Segoe UI, Inter, Roboto, sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";

            for (var val = 0; val <= root.maxSpeed; val += 10) {
                var angle = (root.startAngleDeg + (val / root.maxSpeed) * root.totalAngleDeg) * deg2rad;
                var cosA = Math.cos(angle);
                var sinA = Math.sin(angle);

                var isMajor = (val % 20 === 0);
                var tickLen = isMajor ? 14 : 7;
                var innerR = radius - 18;
                var outerR = innerR - tickLen;

                ctx.beginPath();
                ctx.moveTo(cx + cosA * innerR, cy + sinA * innerR);
                ctx.lineTo(cx + cosA * outerR, cy + sinA * outerR);
                ctx.strokeStyle = val <= root.animatedSpeed ? 
                                 (root.animatedSpeed > root.speedLimit + 5 ? root.warningColor : root.accentColor) :
                                 (root.isNightMode ? "#333D4B" : "#CBD5E1");
                ctx.lineWidth = isMajor ? 2.5 : 1.2;
                ctx.lineCap = "round";
                ctx.stroke();

                if (isMajor) {
                    var labelR = radius - 44;
                    var lx = cx + cosA * labelR;
                    var ly = cy + sinA * labelR;
                    ctx.fillStyle = (val <= root.animatedSpeed) ? 
                                    (root.isNightMode ? "#FFFFFF" : "#0F172A") : 
                                    (root.isNightMode ? "#64748B" : "#94A3B8");
                    ctx.fillText(val.toString(), lx, ly);
                }
            }

            // 4. Sleek Needle Indicator
            var needleLen = radius - 12;
            var nCos = Math.cos(curRad);
            var nSin = Math.sin(curRad);

            ctx.beginPath();
            ctx.moveTo(cx + nCos * (radius - 28), cy + nSin * (radius - 28));
            ctx.lineTo(cx + nCos * needleLen, cy + nSin * needleLen);
            ctx.strokeStyle = "#FFFFFF";
            ctx.lineWidth = 3.5;
            ctx.lineCap = "round";
            ctx.stroke();
        }
    }

    onAnimatedSpeedChanged: dialCanvas.requestPaint()
    onIsNightModeChanged: dialCanvas.requestPaint()
    onWidthChanged: dialCanvas.requestPaint()
    onHeightChanged: dialCanvas.requestPaint()

    // Center Digital Readout & Status
    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.animatedSpeed).toString()
            font.pixelSize: 64
            font.weight: Font.Bold
            font.family: "Segoe UI, Inter, Roboto, sans-serif"
            color: root.animatedSpeed > root.speedLimit + 5 ? root.warningColor : (root.isNightMode ? "#FFFFFF" : "#0F172A")
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "KM / H"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            font.letterSpacing: 2
            font.family: "Segoe UI, Inter, Roboto, sans-serif"
            color: root.isNightMode ? "#94A3B8" : "#64748B"
        }

        // Speed Limit Sign Widget
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 38
            height: 38
            radius: 19
            color: "#FFFFFF"
            border.color: "#E63946"
            border.width: 3.5
            y: 8

            Text {
                anchors.centerIn: parent
                text: Math.round(root.speedLimit).toString()
                font.pixelSize: 15
                font.weight: Font.Bold
                font.family: "Segoe UI, Inter, sans-serif"
                color: "#111111"
            }
        }
    }
}
