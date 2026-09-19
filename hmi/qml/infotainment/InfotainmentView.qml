import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../controls"

Rectangle {
    id: root
    objectName: "infotainmentView"

    property bool isNightMode: true
    property color bgDark: "#0E1116"
    property color bgLight: "#F8FAFC"
    property color accentColor: "#00B4D8"
    property int currentTabIndex: 0 // 0: Home, 1: Navigation, 2: Media, 3: Climate, 4: OTA

    color: isNightMode ? bgDark : bgLight
    Behavior on color { ColorAnimation { duration: 250 } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ================= TOP STATUS BAR =================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20

                // Left: Driver Profile & Time
                Row {
                    spacing: 12
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: root.accentColor
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: "K"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: "#0A0A0A"
                        }
                    }

                    Text {
                        text: "Karthik's AetherDrive • TN-07"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item { Layout.fillWidth: true }

                // Center Title
                Text {
                    text: {
                        switch (root.currentTabIndex) {
                            case 0: return "DASHBOARD"
                            case 1: return "GPS NAVIGATION"
                            case 2: return "MEDIA CENTER"
                            case 3: return "CLIMATE & COMFORT"
                            case 4: return "OTA SOFTWARE UPDATES"
                            default: return ""
                        }
                    }
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.accentColor
                }

                Item { Layout.fillWidth: true }

                // Right: Connectivity & Weather
                Row {
                    spacing: 16
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "32°C CHENNAI • SUNNY"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: root.isNightMode ? "#94A3B8" : "#64748B"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Jio 5G  |  Wi-Fi"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.isNightMode ? "#1E2530" : "#E2E8F0"
            }
        }

        // ================= MAIN CONTENT VIEWPORT =================
        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.currentTabIndex

            HomeScreen {
                isNightMode: root.isNightMode
                accentColor: root.accentColor
                onNavigateTo: function(screen) {
                    if (screen === "Navigation") root.currentTabIndex = 1;
                    if (screen === "Media") root.currentTabIndex = 2;
                    if (screen === "Climate") root.currentTabIndex = 3;
                    if (screen === "OTA") root.currentTabIndex = 4;
                }
            }

            NavigationScreen {
                isNightMode: root.isNightMode
                accentColor: root.accentColor
            }

            MediaScreen {
                isNightMode: root.isNightMode
                accentColor: root.accentColor
            }

            ClimateScreen {
                isNightMode: root.isNightMode
                accentColor: root.accentColor
            }

            OtaScreen {
                isNightMode: root.isNightMode
                accentColor: root.accentColor
            }
        }

        // ================= BOTTOM DOCK TOUCH BAR =================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            color: root.isNightMode ? "#12161D" : "#FFFFFF"
            border.color: root.isNightMode ? "#1E2632" : "#E2E8F0"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 40
                anchors.rightMargin: 40
                spacing: 20

                Repeater {
                    model: [
                        { name: "home", label: "Home", index: 0 },
                        { name: "navigation", label: "Nav", index: 1 },
                        { name: "media", label: "Media", index: 2 },
                        { name: "climate", label: "Climate", index: 3 },
                        { name: "ota", label: "OTA Updates", index: 4 }
                    ]

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Rectangle {
                                width: 44
                                height: 44
                                radius: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: (root.currentTabIndex === modelData.index) ? 
                                       root.accentColor : "transparent"

                                Behavior on color { ColorAnimation { duration: 150 } }

                                AetherIcon {
                                    anchors.centerIn: parent
                                    iconName: modelData.name
                                    iconSize: 22
                                    iconColor: (root.currentTabIndex === modelData.index) ? 
                                               "#0A0A0A" : (root.isNightMode ? "#94A3B8" : "#64748B")
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.label
                                font.pixelSize: 11
                                font.weight: (root.currentTabIndex === modelData.index) ? Font.Bold : Font.Normal
                                color: (root.currentTabIndex === modelData.index) ? 
                                       root.accentColor : (root.isNightMode ? "#64748B" : "#94A3B8")
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTabIndex = modelData.index
                        }
                    }
                }
            }
        }
    }
}
