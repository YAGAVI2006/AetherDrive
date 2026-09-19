import QtQuick
import "../controls"

Item {
    id: root

    property int rpm: 0               // Engine/Motor RPM
    property int maxRpm: 8000
    property int redlineRpm: 6500
    property bool isNightMode: true
    property color accentColor: "#00B4D8"
    property color redlineColor: "#EF233C"

    // Smooth animation
    property real animatedRpm: rpm
    Behavior on animatedRpm {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    implicitWidth: 260
    implicitHeight: 260
    width: Math.min(parent ? parent.width : 260, parent ? parent.height : 260, 260)
    height: width

    readonly property real startAngleDeg: 140
    readonly property real totalAngleDeg: 260
    readonly property real currentAngleDeg: startAngleDeg + (Math.min(animatedRpm, maxRpm) / maxRpm) * totalAngleDeg

    Canvas {
        id: dialCanvas
        anchors.fill: parent
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
            var redlineRad = (root.startAngleDeg + (root.redlineRpm / root.maxRpm) * root.totalAngleDeg) * deg2rad;

            // 1. Background Track Arc
            ctx.beginPath();
            ctx.arc(cx, cy, radius, startRad, endRad, false);
            ctx.strokeStyle = root.isNightMode ? "#181E26" : "#E2E8F0";
            ctx.lineWidth = 14;
            ctx.lineCap = "round";
            ctx.stroke();

            // 2. Redline Zone Arc on background
            ctx.beginPath();
            ctx.arc(cx, cy, radius, redlineRad, endRad, false);
            ctx.strokeStyle = root.redlineColor;
            ctx.globalAlpha = 0.35;
            ctx.lineWidth = 14;
            ctx.lineCap = "round";
            ctx.stroke();
            ctx.globalAlpha = 1.0;

            // 3. Active RPM Arc
            if (root.animatedRpm > 50) {
                var isRedline = (root.animatedRpm >= root.redlineRpm);
                var activeColor = isRedline ? root.redlineColor : root.accentColor;

                // Outer subtle glow
                ctx.beginPath();
                ctx.arc(cx, cy, radius, startRad, curRad, false);
                ctx.strokeStyle = activeColor;
                ctx.lineWidth = 18;
                ctx.globalAlpha = 0.22;
                ctx.stroke();
                ctx.globalAlpha = 1.0;

                // Core arc
                var grad = ctx.createLinearGradient(0, cy + radius, width, cy - radius);
                if (isRedline) {
                    grad.addColorStop(0.0, "#0077B6");
                    grad.addColorStop(0.7, root.accentColor);
                    grad.addColorStop(1.0, root.redlineColor);
                } else {
                    grad.addColorStop(0.0, "#0077B6");
                    grad.addColorStop(1.0, root.accentColor);
                }

                ctx.beginPath();
                ctx.arc(cx, cy, radius, startRad, curRad, false);
                ctx.strokeStyle = grad;
                ctx.lineWidth = 12;
                ctx.lineCap = "round";
                ctx.stroke();
            }

            // 4. Ticks and Labels (0 to 8)
            ctx.font = "600 12px Segoe UI, Inter, Roboto, sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";

            for (var val = 0; val <= root.maxRpm; val += 500) {
                var angle = (root.startAngleDeg + (val / root.maxRpm) * root.totalAngleDeg) * deg2rad;
                var cosA = Math.cos(angle);
                var sinA = Math.sin(angle);

                var isMajor = (val % 1000 === 0);
                var isRed = (val >= root.redlineRpm);
                var tickLen = isMajor ? 14 : 7;
                var innerR = radius - 18;
                var outerR = innerR - tickLen;

                ctx.beginPath();
                ctx.moveTo(cx + cosA * innerR, cy + sinA * innerR);
                ctx.lineTo(cx + cosA * outerR, cy + sinA * outerR);
                ctx.strokeStyle = isRed ? root.redlineColor : 
                                 (val <= root.animatedRpm ? root.accentColor : 
                                 (root.isNightMode ? "#333D4B" : "#CBD5E1"));
                ctx.lineWidth = isMajor ? 2.5 : 1.2;
                ctx.lineCap = "round";
                ctx.stroke();

                if (isMajor) {
                    var labelR = radius - 42;
                    var lx = cx + cosA * labelR;
                    var ly = cy + sinA * labelR;
                    var digit = val / 1000;
                    ctx.fillStyle = isRed ? root.redlineColor : 
                                    ((val <= root.animatedRpm) ? 
                                    (root.isNightMode ? "#FFFFFF" : "#0F172A") : 
                                    (root.isNightMode ? "#64748B" : "#94A3B8"));
                    ctx.fillText(digit.toString(), lx, ly);
                }
            }

            // 5. Sleek Needle
            var needleLen = radius - 12;
            var nCos = Math.cos(curRad);
            var nSin = Math.sin(curRad);

            ctx.beginPath();
            ctx.moveTo(cx + nCos * (radius - 28), cy + nSin * (radius - 28));
            ctx.lineTo(cx + nCos * needleLen, cy + nSin * needleLen);
            ctx.strokeStyle = root.animatedRpm >= root.redlineRpm ? root.redlineColor : "#FFFFFF";
            ctx.lineWidth = 3.5;
            ctx.lineCap = "round";
            ctx.stroke();
        }
    }

    onAnimatedRpmChanged: dialCanvas.requestPaint()
    onIsNightModeChanged: dialCanvas.requestPaint()
    onWidthChanged: dialCanvas.requestPaint()
    onHeightChanged: dialCanvas.requestPaint()

    // Center Digital Readout
    Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.animatedRpm).toString()
            font.pixelSize: 52
            font.weight: Font.Bold
            font.family: "Segoe UI, Inter, Roboto, sans-serif"
            color: root.animatedRpm >= root.redlineRpm ? root.redlineColor : (root.isNightMode ? "#FFFFFF" : "#0F172A")
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "RPM"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            font.letterSpacing: 2
            font.family: "Segoe UI, Inter, Roboto, sans-serif"
            color: root.isNightMode ? "#94A3B8" : "#64748B"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "x1000 r/min"
            font.pixelSize: 11
            font.family: "Segoe UI, Inter, sans-serif"
            color: root.isNightMode ? "#475569" : "#94A3B8"
            y: 4
        }
    }
}
