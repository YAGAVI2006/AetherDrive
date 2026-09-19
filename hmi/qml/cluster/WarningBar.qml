import QtQuick
import QtQuick.Layouts
import "../controls"

Item {
    id: root

    property bool lowBattery: false
    property bool overspeed: false
    property bool laneDeparture: false
    property bool doorLocked: true
    property bool headlights: true
    property string alertMessage: ""
    property bool isNightMode: true

    property color warningAmber: "#FFB703"
    property color dangerRed: "#EF233C"
    property color safeCyan: "#00B4D8"
    property color inactiveGray: isNightMode ? "#333D4B" : "#CBD5E1"

    implicitWidth: 280
    implicitHeight: 44

    // Telltale Icon Row
    RowLayout {
        anchors.centerIn: parent
        spacing: 24

        // 1. Headlights
        AetherIcon {
            iconName: "headlights"
            iconSize: 22
            iconColor: root.headlights ? "#00F5D4" : root.inactiveGray
            opacity: root.headlights ? 1.0 : 0.4
        }

        // 2. Central Door Lock
        AetherIcon {
            iconName: root.doorLocked ? "lock" : "unlock"
            iconSize: 22
            iconColor: root.doorLocked ? root.safeCyan : root.warningAmber
            opacity: 1.0
        }

        // 3. Lane Departure Warning (Blinking when active)
        Item {
            width: 26
            height: 26

            AetherIcon {
                id: laneIcon
                anchors.centerIn: parent
                iconName: "lane_departure"
                iconSize: 24
                iconColor: root.laneDeparture ? root.warningAmber : root.inactiveGray
                opacity: root.laneDeparture ? 1.0 : 0.35

                SequentialAnimation on opacity {
                    running: root.laneDeparture
                    loops: Animation.Infinite
                    PropertyAnimation { to: 0.2; duration: 250 }
                    PropertyAnimation { to: 1.0; duration: 250 }
                }
            }
        }

        // 4. Overspeed Warning
        AetherIcon {
            iconName: "speedometer"
            iconSize: 22
            iconColor: root.overspeed ? root.warningAmber : root.inactiveGray
            opacity: root.overspeed ? 1.0 : 0.35

            SequentialAnimation on opacity {
                running: root.overspeed
                loops: Animation.Infinite
                PropertyAnimation { to: 0.25; duration: 300 }
                PropertyAnimation { to: 1.0; duration: 300 }
            }
        }

        // 5. Low Battery Alert
        AetherIcon {
            iconName: "battery"
            iconSize: 22
            iconColor: root.lowBattery ? root.dangerRed : root.inactiveGray
            opacity: root.lowBattery ? 1.0 : 0.35

            SequentialAnimation on opacity {
                running: root.lowBattery
                loops: Animation.Infinite
                PropertyAnimation { to: 0.2; duration: 300 }
                PropertyAnimation { to: 1.0; duration: 300 }
            }
        }
    }

    // Active Banner Alert Pop-up (overlaid smoothly below icons if message present)
    Rectangle {
        id: alertBanner
        anchors.top: parent.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        height: 28
        width: Math.min(root.width * 0.9, alertText.implicitWidth + 36)
        radius: 14
        color: root.laneDeparture ? "#381A00" : "#2E080D"
        border.color: root.laneDeparture ? root.warningAmber : root.dangerRed
        border.width: 1
        visible: opacity > 0.01
        opacity: root.alertMessage !== "" ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            AetherIcon {
                iconName: "warning"
                iconSize: 15
                iconColor: root.laneDeparture ? root.warningAmber : root.dangerRed
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: alertText
                anchors.verticalCenter: parent.verticalCenter
                text: root.alertMessage
                font.pixelSize: 12
                font.weight: Font.Bold
                font.family: "Segoe UI, Inter, Roboto, sans-serif"
                color: root.laneDeparture ? root.warningAmber : root.dangerRed
            }
        }
    }
}
