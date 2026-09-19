import QtQuick
import "../controls"

Item {
    id: root

    property bool isNightMode: true
    signal toggled(bool nightMode)

    implicitWidth: 84
    implicitHeight: 36

    Rectangle {
        id: pillBg
        anchors.fill: parent
        radius: 18
        color: root.isNightMode ? "#16191E" : "#E2E8F0"
        border.color: root.isNightMode ? "#2C333E" : "#CBD5E1"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 200 } }

        // Sliding thumb
        Rectangle {
            id: thumb
            x: root.isNightMode ? parent.width - width - 3 : 3
            y: 3
            width: 30
            height: 30
            radius: 15
            color: root.isNightMode ? "#00B4D8" : "#F59E0B"

            Behavior on x {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }
            Behavior on color { ColorAnimation { duration: 200 } }

            AetherIcon {
                anchors.centerIn: parent
                iconName: root.isNightMode ? "moon" : "sun"
                iconSize: 16
                iconColor: "#0A0A0A"
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.isNightMode = !root.isNightMode
                root.toggled(root.isNightMode)
            }
        }
    }
}
