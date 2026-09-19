import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../controls"

Item {
    id: root

    property bool isNightMode: true
    property color accentColor: "#00B4D8"
    property bool isPlaying: true
    property real trackProgress: 0.42
    property real volumeLevel: 70.0

    // Equalizer visualizer animation phase
    property real eqPhase: 0.0
    NumberAnimation on eqPhase {
        from: 0.0
        to: Math.PI * 2
        duration: 2000
        loops: Animation.Infinite
        running: root.isPlaying
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        // LEFT: Media Player Main Stage
        AetherCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            isNightMode: root.isNightMode

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                // Center Album Art + Equalizer
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180

                    // Glowing backdrop aura
                    Rectangle {
                        anchors.centerIn: parent
                        width: 170
                        height: 170
                        radius: 85
                        color: root.accentColor
                        opacity: root.isPlaying ? 0.25 : 0.08

                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }

                    // Album Art Square
                    Rectangle {
                        id: albumArt
                        anchors.centerIn: parent
                        width: 140
                        height: 140
                        radius: 18
                        color: "#1E2633"
                        border.color: root.accentColor
                        border.width: 1.5

                        AetherIcon {
                            anchors.centerIn: parent
                            iconName: "media"
                            iconSize: 56
                            iconColor: root.accentColor
                        }
                    }

                    // Equalizer Visualizer Bars below album art
                    Canvas {
                        id: eqCanvas
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 32
                        renderTarget: Canvas.FramebufferObject

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.clearRect(0, 0, width, height);

                            var numBars = 24;
                            var barWidth = 4;
                            var gap = (width - (numBars * barWidth)) / (numBars - 1);

                            ctx.fillStyle = root.accentColor;

                            for (var i = 0; i < numBars; i++) {
                                var barHeight = 6;
                                if (root.isPlaying) {
                                    var sineVal = Math.sin(root.eqPhase + (i * 0.45));
                                    var cosVal = Math.cos(root.eqPhase * 1.5 + (i * 0.3));
                                    var norm = (sineVal + cosVal + 2) / 4;
                                    barHeight = 6 + norm * (height - 8);
                                }

                                var bx = i * (barWidth + gap);
                                var by = height - barHeight;
                                ctx.beginPath();
                                ctx.roundRect(bx, by, barWidth, barHeight, 2);
                                ctx.fill();
                            }
                        }
                    }

                    Connections {
                        target: root
                        function onEqPhaseChanged() { eqCanvas.requestPaint() }
                        function onIsPlayingChanged() { eqCanvas.requestPaint() }
                    }
                }

                // Track Metadata
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Starlight Velocity"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "CyberSynth Orchestra • AetherDrive Hi-Fi Master"
                        font.pixelSize: 13
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#94A3B8" : "#64748B"
                    }
                }

                // Scrubber Slider
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    AetherSlider {
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: root.trackProgress * 100
                        isNightMode: root.isNightMode
                        accentColor: root.accentColor
                        onMoved: root.trackProgress = value / 100.0
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "01:34"
                            font.pixelSize: 11
                            font.family: "Segoe UI, Inter, sans-serif"
                            color: root.isNightMode ? "#64748B" : "#94A3B8"
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "03:45"
                            font.pixelSize: 11
                            font.family: "Segoe UI, Inter, sans-serif"
                            color: root.isNightMode ? "#64748B" : "#94A3B8"
                        }
                    }
                }

                // Playback Control Buttons Row
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 28

                    // Previous Track Button
                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        color: root.isNightMode ? "#1A222C" : "#E2E8F0"
                        anchors.verticalCenter: parent.verticalCenter

                        AetherIcon {
                            anchors.centerIn: parent
                            iconName: "prev"
                            iconSize: 18
                            iconColor: root.isNightMode ? "#E2E8F0" : "#1E293B"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.trackProgress = 0.0
                        }
                    }

                    // Play / Pause Master Button
                    Rectangle {
                        width: 58
                        height: 58
                        radius: 29
                        color: root.accentColor
                        anchors.verticalCenter: parent.verticalCenter

                        AetherIcon {
                            anchors.centerIn: parent
                            iconName: root.isPlaying ? "pause" : "play"
                            iconSize: 22
                            iconColor: "#0A0A0A"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.isPlaying = !root.isPlaying
                        }
                    }

                    // Next Track Button
                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        color: root.isNightMode ? "#1A222C" : "#E2E8F0"
                        anchors.verticalCenter: parent.verticalCenter

                        AetherIcon {
                            anchors.centerIn: parent
                            iconName: "next"
                            iconSize: 18
                            iconColor: root.isNightMode ? "#E2E8F0" : "#1E293B"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.trackProgress = 0.0
                        }
                    }
                }

                // Volume Bar
                RowLayout {
                    Layout.preferredWidth: 260
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    AetherIcon {
                        iconName: "volume_low"
                        iconSize: 16
                        iconColor: root.isNightMode ? "#94A3B8" : "#64748B"
                    }

                    AetherSlider {
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: root.volumeLevel
                        isNightMode: root.isNightMode
                        accentColor: root.accentColor
                        onMoved: root.volumeLevel = value
                    }

                    AetherIcon {
                        iconName: "volume_high"
                        iconSize: 16
                        iconColor: root.isNightMode ? "#94A3B8" : "#64748B"
                    }
                }
            }
        }

        // RIGHT: Playlist Queue (Responsive: shown on wider viewports)
        AetherCard {
            visible: root.width >= 560
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            isNightMode: root.isNightMode

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                Text {
                    text: "UP NEXT"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 1.2
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#94A3B8" : "#64748B"
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 10

                    model: [
                        { title: "Neon Skyline", artist: "HyperPulse", duration: "04:12" },
                        { title: "Quantum Horizon", artist: "CyberEcho", duration: "03:28" },
                        { title: "Midnight Autobahn", artist: "SynthWave Riders", duration: "05:04" },
                        { title: "Silicon Dreams", artist: "AetherDrive Lab", duration: "03:52" }
                    ]

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 52
                        radius: 10
                        color: root.isNightMode ? "#161D26" : "#F1F5F9"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Column {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: modelData.title
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: root.isNightMode ? "#F1F5F9" : "#0F172A"
                                }
                                Text {
                                    text: modelData.artist
                                    font.pixelSize: 11
                                    color: root.isNightMode ? "#64748B" : "#94A3B8"
                                }
                            }

                            Text {
                                text: modelData.duration
                                font.pixelSize: 11
                                color: root.accentColor
                            }
                        }
                    }
                }
            }
        }
    }
}
