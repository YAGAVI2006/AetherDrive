import QtQuick
import QtQuick.Controls

Slider {
    id: control

    property bool isNightMode: true
    property color accentColor: "#00B4D8"

    from: 0
    to: 100
    value: 50

    implicitWidth: 200
    implicitHeight: 32

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 6
        width: control.availableWidth
        height: implicitHeight
        radius: 3
        color: control.isNightMode ? "#1E242C" : "#E2E8F0"

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: control.accentColor
            radius: 3

            // Glow line
            Rectangle {
                anchors.fill: parent
                color: control.accentColor
                radius: 3
                opacity: 0.4
            }
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 20
        implicitHeight: 20
        radius: 10
        color: control.pressed ? Qt.lighter(control.accentColor, 1.2) : "#FFFFFF"
        border.color: control.accentColor
        border.width: 3

        Behavior on scale { NumberAnimation { duration: 100 } }
        scale: control.pressed ? 1.2 : (control.hovered ? 1.1 : 1.0)
    }
}
