import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Rectangle {
    id: powerSegRoot
    property var view

        property string icon: ""
        property string label: ""
        property string profile: ""
        property color accent: powerSegRoot.view.sys.colOn
        readonly property bool active: powerSegRoot.view.sys.powerProfile === profile

        Layout.fillWidth: true
        Layout.preferredHeight: 54
        radius: 14
        color: active ? Qt.rgba(accent.r, accent.g, accent.b, 0.18) : (segMa.containsMouse ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(1, 1, 1, 0.05))
        border.color: active ? Qt.rgba(accent.r, accent.g, accent.b, 0.4) : powerSegRoot.view.sys.colLine
        border.width: 1
        scale: segMa.pressed ? 0.95 : 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: parent.parent.icon
                color: parent.parent.active ? parent.parent.accent : "#ffffff"

                font {
                    family: powerSegRoot.view.sys.fontFam
                    pixelSize: 17
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }

                }

            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: parent.parent.label
                color: parent.parent.active ? powerSegRoot.view.sys.colFg : powerSegRoot.view.sys.colMuted

                font {
                    family: powerSegRoot.view.sys.fontFam
                    pixelSize: 11
                    bold: parent.parent.active
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }

                }

            }

        }

        MouseArea {
            id: segMa

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: powerSegRoot.view.sys.setPowerProfile(parent.profile)
        }

        Behavior on color {
            ColorAnimation {
                duration: 180
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 180
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 130
                easing.type: Easing.OutBack
            }

        }

    }
