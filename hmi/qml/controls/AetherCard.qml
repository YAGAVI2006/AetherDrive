import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property bool isNightMode: true
    property color cardColor: isNightMode ? "#16191E" : "#FFFFFF"
    property color borderColor: isNightMode ? "#252B35" : "#E2E8F0"
    property color glowColor: "#00B4D8"
    property bool hasGlow: false
    property real glowOpacity: 0.15

    color: cardColor
    radius: 16
    border.color: borderColor
    border.width: 1

    // Subtle automotive backdrop gradient
    gradient: Gradient {
        GradientStop { 
            position: 0.0
            color: root.isNightMode ? Qt.lighter(root.cardColor, 1.08) : root.cardColor 
        }
        GradientStop { 
            position: 1.0
            color: root.cardColor 
        }
    }

    // Top border specular highlight for premium glass/metal look
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: 1
        radius: root.radius
        color: root.isNightMode ? "#333C4A" : "#F8FAFC"
        opacity: 0.6
    }
}
