import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../controls"

Item {
    id: root

    property bool isNightMode: true
    property color accentColor: "#00B4D8"
    signal navigateTo(string screenName)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Welcome Header
        RowLayout {
            Layout.fillWidth: true

            Column {
                spacing: 2
                Text {
                    text: "Welcome back, Alex"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                }
                Text {
                    text: "AetherDrive SDV Platform • All vehicle systems nominal"
                    font.pixelSize: 13
                    font.family: "Segoe UI, Inter, sans-serif"
                    color: root.isNightMode ? "#94A3B8" : "#64748B"
                }
            }

            Item { Layout.fillWidth: true }

            AetherCard {
                implicitWidth: 160
                implicitHeight: 40
                isNightMode: root.isNightMode
                radius: 10

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: "#10B981"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "5G LTE CONNECTED"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#E2E8F0" : "#1E293B"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // 2x2 Interactive Quick Cards Grid
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rowSpacing: 16
            columnSpacing: 16

            // CARD 1: Navigation Quick Card
            AetherCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                isNightMode: root.isNightMode

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        AetherIcon {
                            iconName: "navigation"
                            iconSize: 20
                            iconColor: root.accentColor
                        }
                        Text {
                            text: "NAVIGATION"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1
                            font.family: "Segoe UI, Inter, sans-serif"
                            color: root.isNightMode ? "#94A3B8" : "#64748B"
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "18 MIN REMAINING"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.family: "Segoe UI, Inter, sans-serif"
                            color: root.accentColor
                        }
                    }

                    Text {
                        text: "Tech Innovation Hub"
                        font.pixelSize: 19
                        font.weight: Font.Bold
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                    }

                    Text {
                        text: "In 400m turn right onto Quantum Boulevard"
                        font.pixelSize: 13
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#94A3B8" : "#64748B"
                    }

                    Item { Layout.fillHeight: true }

                    AetherButton {
                        Layout.fillWidth: true
                        text: "Open Live Map"
                        iconName: "navigation"
                        isNightMode: root.isNightMode
                        onClicked: root.navigateTo("Navigation")
                    }
                }
            }

            // CARD 2: Media Quick Card
            AetherCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                isNightMode: root.isNightMode

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        AetherIcon {
                            iconName: "media"
                            iconSize: 20
                            iconColor: root.accentColor
                        }
                        Text {
                            text: "NOW PLAYING"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1
                            font.family: "Segoe UI, Inter, sans-serif"
                            color: root.isNightMode ? "#94A3B8" : "#64748B"
                        }
                    }

                    RowLayout {
                        spacing: 12

                        // Mini album art
                        Rectangle {
                            width: 52
                            height: 52
                            radius: 10
                            color: "#1E293B"
                            border.color: root.accentColor
                            border.width: 1

                            AetherIcon {
                                anchors.centerIn: parent
                                iconName: "media"
                                iconSize: 24
                                iconColor: root.accentColor
                            }
                        }

                        Column {
                            spacing: 2
                            Text {
                                text: "Starlight Velocity"
                                font.pixelSize: 17
                                font.weight: Font.Bold
                                font.family: "Segoe UI, Inter, sans-serif"
                                color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                            }
                            Text {
                                text: "CyberSynth Orchestra • Hi-Res Audio"
                                font.pixelSize: 12
                                font.family: "Segoe UI, Inter, sans-serif"
                                color: root.isNightMode ? "#94A3B8" : "#64748B"
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    AetherButton {
                        Layout.fillWidth: true
                        text: "Media Center"
                        iconName: "media"
                        isNightMode: root.isNightMode
                        onClicked: root.navigateTo("Media")
                    }
                }
            }

            // CARD 3: Climate Quick Card
            AetherCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                isNightMode: root.isNightMode

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        AetherIcon {
                            iconName: "climate"
                            iconSize: 20
                            iconColor: root.accentColor
                        }
                        Text {
                            text: "CLIMATE DUAL ZONE"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1
                            font.family: "Segoe UI, Inter, sans-serif"
                            color: root.isNightMode ? "#94A3B8" : "#64748B"
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "AUTO AC ON"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.family: "Segoe UI, Inter, sans-serif"
                            color: "#10B981"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 24

                        Column {
                            Text {
                                text: "DRIVER"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: root.isNightMode ? "#64748B" : "#94A3B8"
                            }
                            Text {
                                text: "21.5°C"
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                            }
                        }

                        Rectangle {
                            width: 1
                            height: 32
                            color: root.isNightMode ? "#2C333E" : "#E2E8F0"
                        }

                        Column {
                            Text {
                                text: "PASSENGER"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: root.isNightMode ? "#64748B" : "#94A3B8"
                            }
                            Text {
                                text: "22.0°C"
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    AetherButton {
                        Layout.fillWidth: true
                        text: "Adjust HVAC"
                        iconName: "climate"
                        isNightMode: root.isNightMode
                        onClicked: root.navigateTo("Climate")
                    }
                }
            }

            // CARD 4: SDV OTA & System Status Card
            AetherCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                isNightMode: root.isNightMode

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        AetherIcon {
                            iconName: "ota"
                            iconSize: 20
                            iconColor: "#10B981"
                        }
                        Text {
                            text: "SOFTWARE DEFINED VEHICLE"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1
                            font.family: "Segoe UI, Inter, sans-serif"
                            color: root.isNightMode ? "#94A3B8" : "#64748B"
                        }
                    }

                    Text {
                        text: "Firmware v2.4.0 Ready"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#FFFFFF" : "#0F172A"
                    }

                    Text {
                        text: "Enhanced autonomous lane assist & cockpit visualizer"
                        font.pixelSize: 12
                        font.family: "Segoe UI, Inter, sans-serif"
                        color: root.isNightMode ? "#94A3B8" : "#64748B"
                    }

                    Item { Layout.fillHeight: true }

                    AetherButton {
                        Layout.fillWidth: true
                        text: "System OTA Updates"
                        iconName: "ota"
                        isPrimary: true
                        isNightMode: root.isNightMode
                        onClicked: root.navigateTo("OTA")
                    }
                }
            }
        }
    }
}
