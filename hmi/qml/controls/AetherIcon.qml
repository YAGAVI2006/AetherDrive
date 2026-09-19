import QtQuick

Item {
    id: root

    property string iconName: "warning"
    property color iconColor: "#00B4D8"
    property real iconSize: 24

    implicitWidth: iconSize
    implicitHeight: iconSize

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = root.iconColor;
            ctx.fillStyle = root.iconColor;
            ctx.lineWidth = Math.max(1.5, width * 0.08);
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            var w = width;
            var h = height;

            if (root.iconName === "battery") {
                // Battery body
                ctx.strokeRect(w * 0.1, h * 0.25, w * 0.72, h * 0.5);
                // Battery terminal nub
                ctx.fillRect(w * 0.84, h * 0.38, w * 0.08, h * 0.24);
                // Inner charge bar
                ctx.fillRect(w * 0.18, h * 0.33, w * 0.38, h * 0.34);
            }
            else if (root.iconName === "speedometer" || root.iconName === "tachometer") {
                // Outer dial arc
                ctx.beginPath();
                ctx.arc(w * 0.5, h * 0.58, w * 0.38, Math.PI * 0.8, Math.PI * 2.2);
                ctx.stroke();
                // Needle
                ctx.beginPath();
                ctx.moveTo(w * 0.5, h * 0.58);
                ctx.lineTo(w * 0.72, h * 0.38);
                ctx.stroke();
                // Center hub
                ctx.beginPath();
                ctx.arc(w * 0.5, h * 0.58, w * 0.09, 0, Math.PI * 2);
                ctx.fill();
            }
            else if (root.iconName === "warning") {
                // Triangle
                ctx.beginPath();
                ctx.moveTo(w * 0.5, h * 0.12);
                ctx.lineTo(w * 0.88, h * 0.85);
                ctx.lineTo(w * 0.12, h * 0.85);
                ctx.closePath();
                ctx.stroke();
                // Exclamation stem
                ctx.beginPath();
                ctx.moveTo(w * 0.5, h * 0.38);
                ctx.lineTo(w * 0.5, h * 0.60);
                ctx.stroke();
                // Dot
                ctx.beginPath();
                ctx.arc(w * 0.5, h * 0.74, w * 0.05, 0, Math.PI * 2);
                ctx.fill();
            }
            else if (root.iconName === "lane_departure") {
                // Dashed road lanes and car drifting
                // Left lane (dashed)
                ctx.beginPath();
                ctx.moveTo(w * 0.2, h * 0.9);
                ctx.lineTo(w * 0.35, h * 0.15);
                ctx.stroke();
                // Right lane (dashed)
                ctx.beginPath();
                ctx.moveTo(w * 0.8, h * 0.9);
                ctx.lineTo(w * 0.65, h * 0.15);
                ctx.stroke();
                // Car symbol angled
                ctx.beginPath();
                ctx.strokeRect(w * 0.42, h * 0.42, w * 0.26, w * 0.36);
            }
            else if (root.iconName === "lock") {
                // Shackle
                ctx.beginPath();
                ctx.arc(w * 0.5, h * 0.4, w * 0.22, Math.PI, 0);
                ctx.stroke();
                // Body
                ctx.strokeRect(w * 0.22, h * 0.42, w * 0.56, h * 0.46);
                ctx.beginPath();
                ctx.arc(w * 0.5, h * 0.62, w * 0.06, 0, Math.PI * 2);
                ctx.fill();
            }
            else if (root.iconName === "unlock") {
                // Open shackle
                ctx.beginPath();
                ctx.arc(w * 0.6, h * 0.35, w * 0.22, Math.PI, 0);
                ctx.stroke();
                // Body
                ctx.strokeRect(w * 0.22, h * 0.42, w * 0.56, h * 0.46);
                ctx.beginPath();
                ctx.arc(w * 0.5, h * 0.62, w * 0.06, 0, Math.PI * 2);
                ctx.fill();
            }
            else if (root.iconName === "headlights") {
                // Bulb dome
                ctx.beginPath();
                ctx.arc(w * 0.35, h * 0.5, w * 0.25, Math.PI * 0.5, Math.PI * 1.5, false);
                ctx.lineTo(w * 0.35, h * 0.75);
                ctx.stroke();
                // Rays
                for (var i = 0; i < 4; i++) {
                    var ry = h * (0.28 + i * 0.15);
                    ctx.beginPath();
                    ctx.moveTo(w * 0.5, ry);
                    ctx.lineTo(w * 0.85, ry);
                    ctx.stroke();
                }
            }
            else if (root.iconName === "home") {
                ctx.beginPath();
                ctx.moveTo(w * 0.15, h * 0.5);
                ctx.lineTo(w * 0.5, h * 0.18);
                ctx.lineTo(w * 0.85, h * 0.5);
                ctx.stroke();
                ctx.beginPath();
                ctx.strokeRect(w * 0.26, h * 0.48, w * 0.48, h * 0.42);
            }
            else if (root.iconName === "navigation") {
                // Nav compass arrow
                ctx.beginPath();
                ctx.moveTo(w * 0.5, h * 0.12);
                ctx.lineTo(w * 0.82, h * 0.84);
                ctx.lineTo(w * 0.5, h * 0.65);
                ctx.lineTo(w * 0.18, h * 0.84);
                ctx.closePath();
                ctx.stroke();
            }
            else if (root.iconName === "media") {
                // Musical note
                ctx.beginPath();
                ctx.arc(w * 0.35, h * 0.7, w * 0.16, 0, Math.PI * 2);
                ctx.fill();
                ctx.beginPath();
                ctx.moveTo(w * 0.48, h * 0.7);
                ctx.lineTo(w * 0.48, h * 0.22);
                ctx.lineTo(w * 0.8, h * 0.15);
                ctx.lineTo(w * 0.8, h * 0.58);
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(w * 0.68, h * 0.6, w * 0.14, 0, Math.PI * 2);
                ctx.fill();
            }
            else if (root.iconName === "climate") {
                // Fan blade representation
                ctx.beginPath();
                ctx.arc(w * 0.5, h * 0.5, w * 0.12, 0, Math.PI * 2);
                ctx.fill();
                for (var a = 0; a < 3; a++) {
                    ctx.save();
                    ctx.translate(w * 0.5, h * 0.5);
                    ctx.rotate((a * 120) * Math.PI / 180);
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.quadraticCurveTo(w * 0.28, -h * 0.15, 0, -h * 0.38);
                    ctx.stroke();
                    ctx.restore();
                }
            }
            else if (root.iconName === "ota") {
                // Cloud / Download arrow
                ctx.beginPath();
                ctx.moveTo(w * 0.5, h * 0.2);
                ctx.lineTo(w * 0.5, h * 0.65);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(w * 0.32, h * 0.48);
                ctx.lineTo(w * 0.5, h * 0.66);
                ctx.lineTo(w * 0.68, h * 0.48);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(w * 0.2, h * 0.8);
                ctx.lineTo(w * 0.8, h * 0.8);
                ctx.stroke();
            }
            else if (root.iconName === "sun") {
                ctx.beginPath();
                ctx.arc(w * 0.5, h * 0.5, w * 0.22, 0, Math.PI * 2);
                ctx.fill();
                for (var i = 0; i < 8; i++) {
                    var ang = (i * 45) * Math.PI / 180;
                    ctx.beginPath();
                    ctx.moveTo(w * 0.5 + Math.cos(ang) * w * 0.32, h * 0.5 + Math.sin(ang) * h * 0.32);
                    ctx.lineTo(w * 0.5 + Math.cos(ang) * w * 0.44, h * 0.5 + Math.sin(ang) * h * 0.44);
                    ctx.stroke();
                }
            }
            else if (root.iconName === "moon") {
                ctx.beginPath();
                ctx.arc(w * 0.5, h * 0.5, w * 0.34, Math.PI * 0.3, Math.PI * 1.7, false);
                ctx.quadraticCurveTo(w * 0.5, h * 0.5, w * 0.5 + Math.cos(Math.PI * 0.3) * w * 0.34, h * 0.5 + Math.sin(Math.PI * 0.3) * w * 0.34);
                ctx.fill();
            }
            else if (root.iconName === "play") {
                ctx.beginPath();
                ctx.moveTo(w * 0.35, h * 0.25);
                ctx.lineTo(w * 0.75, h * 0.5);
                ctx.lineTo(w * 0.35, h * 0.75);
                ctx.closePath();
                ctx.fill();
            }
            else if (root.iconName === "pause") {
                ctx.fillRect(w * 0.3, h * 0.25, w * 0.14, h * 0.5);
                ctx.fillRect(w * 0.56, h * 0.25, w * 0.14, h * 0.5);
            }
            else if (root.iconName === "prev") {
                ctx.beginPath();
                ctx.moveTo(w * 0.8, h * 0.25);
                ctx.lineTo(w * 0.45, h * 0.5);
                ctx.lineTo(w * 0.8, h * 0.75);
                ctx.closePath();
                ctx.fill();
                ctx.fillRect(w * 0.25, h * 0.25, w * 0.1, h * 0.5);
            }
            else if (root.iconName === "next") {
                ctx.beginPath();
                ctx.moveTo(w * 0.2, h * 0.25);
                ctx.lineTo(w * 0.55, h * 0.5);
                ctx.lineTo(w * 0.2, h * 0.75);
                ctx.closePath();
                ctx.fill();
                ctx.fillRect(w * 0.65, h * 0.25, w * 0.1, h * 0.5);
            }
            else if (root.iconName === "volume_low" || root.iconName === "volume_high") {
                ctx.beginPath();
                ctx.moveTo(w * 0.2, h * 0.38);
                ctx.lineTo(w * 0.4, h * 0.38);
                ctx.lineTo(w * 0.6, h * 0.2);
                ctx.lineTo(w * 0.6, h * 0.8);
                ctx.lineTo(w * 0.4, h * 0.62);
                ctx.lineTo(w * 0.2, h * 0.62);
                ctx.closePath();
                ctx.fill();
                if (root.iconName === "volume_high") {
                    ctx.beginPath();
                    ctx.arc(w * 0.55, h * 0.5, w * 0.28, -Math.PI * 0.25, Math.PI * 0.25);
                    ctx.stroke();
                }
            }
            else if (root.iconName === "car") {
                // Sleek top-down vehicle silhouette
                ctx.beginPath();
                ctx.moveTo(w * 0.35, h * 0.15);
                ctx.quadraticCurveTo(w * 0.5, h * 0.1, w * 0.65, h * 0.15);
                ctx.lineTo(w * 0.72, h * 0.35);
                ctx.lineTo(w * 0.75, h * 0.75);
                ctx.quadraticCurveTo(w * 0.5, h * 0.88, w * 0.25, h * 0.75);
                ctx.lineTo(w * 0.28, h * 0.35);
                ctx.closePath();
                ctx.stroke();
                // Windshield
                ctx.beginPath();
                ctx.moveTo(w * 0.34, h * 0.32);
                ctx.quadraticCurveTo(w * 0.5, h * 0.28, w * 0.66, h * 0.32);
                ctx.stroke();
            }
        }
    }

    onIconNameChanged: canvas.requestPaint()
    onIconColorChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
}
