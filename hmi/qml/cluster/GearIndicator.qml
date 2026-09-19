import QtQuick
import "../controls"

AetherCard {
    id: root

    property string currentGear: "P"   // P, R, N, D
    property color accentColor: "#00B4D8"

    readonly property var gears: ["P", "R", "N", "D"]

    implicitWidth: 240
    implicitHeight: 56

    Row {
        anchors.centerIn: parent
        spacing: 12

        Repeater {
            model: root.gears

            Rectangle {
                id: gearBtn
                width: 38
                height: 38
                radius: 10
                color: (modelData === root.currentGear) ? root.accentColor : "transparent"
                border.color: (modelData === root.currentGear) ? 
                              Qt.lighter(root.accentColor, 1.2) : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 180 } }

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 17
                    font.weight: (modelData === root.currentGear) ? Font.Bold : Font.DemiBold
                    font.family: "Segoe UI, Inter, Roboto, sans-serif"
                    color: {
                        if (modelData === root.currentGear) {
                            return "#0A0A0A"
                        } else {
                            return root.isNightMode ? "#64748B" : "#94A3B8"
                        }
                    }
                }

                // Subtle glow on active gear
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.color: root.accentColor
                    border.width: 2
                    opacity: (modelData === root.currentGear) ? 0.4 : 0.0
                    scale: 1.15
                }
            }
        }
    }
}
