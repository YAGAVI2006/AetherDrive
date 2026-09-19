import QtQuick
import QtQuick.Controls

Button {
    id: control

    property bool isNightMode: true
    property bool isPrimary: false
    property string iconName: ""
    property color accentColor: "#00B4D8"

    implicitWidth: Math.max(120, contentRow.implicitWidth + 32)
    implicitHeight: 44

    background: Rectangle {
        id: bgRect
        radius: 12
        color: {
            if (control.isPrimary) {
                return control.down ? Qt.darker(control.accentColor, 1.2) : 
                       (control.hovered ? Qt.lighter(control.accentColor, 1.1) : control.accentColor)
            } else {
                if (control.isNightMode) {
                    return control.down ? "#222730" : (control.hovered ? "#1E232B" : "#14171D")
                } else {
                    return control.down ? "#CBD5E1" : (control.hovered ? "#E2E8F0" : "#F1F5F9")
                }
            }
        }
        border.color: control.isPrimary ? Qt.lighter(control.accentColor, 1.2) : 
                      (control.hovered ? control.accentColor : (control.isNightMode ? "#2C333E" : "#D1D5DB"))
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        // Glow when hovered
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: control.accentColor
            border.width: 2
            opacity: control.hovered && !control.isPrimary ? 0.35 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    contentItem: Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        AetherIcon {
            id: btnIcon
            visible: control.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter
            iconName: control.iconName
            iconSize: 18
            iconColor: control.isPrimary ? "#0A0A0A" : (control.isNightMode ? "#E0E0E0" : "#1E293B")
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: control.text
            font.pixelSize: 14
            font.weight: Font.DemiBold
            font.family: "Segoe UI, Inter, Roboto, sans-serif"
            color: control.isPrimary ? "#0A0A0A" : (control.isNightMode ? "#F1F5F9" : "#0F172A")
        }
    }
}
