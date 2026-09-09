import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Rectangle {
    id: tileRoot
    property var view

        property string icon: ""
        property string label: ""
        property string sub: ""
        property bool on: false
        property color accent: tileRoot.view.sys.colOn

        signal iconClicked()
        signal bodyClicked()

        Layout.fillWidth: true
        Layout.preferredHeight: 62
        radius: 16
        color: on ? Qt.rgba(accent.r, accent.g, accent.b, 0.16) : Qt.rgba(1, 1, 1, 0.05)
        border.color: on ? Qt.rgba(accent.r, accent.g, accent.b, 0.35) : tileRoot.view.sys.colLine
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 12
            spacing: 11

            Rectangle {
                id: iconBtn

                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 20
                color: parent.parent.on ? parent.parent.accent : Qt.rgba(1, 1, 1, 0.1)
                scale: iconMa.pressed ? 0.9 : (iconMa.containsMouse ? 1.06 : 1)

                Text {
                    anchors.centerIn: parent
                    text: iconBtn.parent.parent.icon
                    color: "#ffffff"

                    font {
                        family: tileRoot.view.sys.fontFam
                        pixelSize: 17
                    }

                }

                MouseArea {
                    id: iconMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: iconBtn.parent.parent.iconClicked()
                }

                Behavior on color {
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

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: iconBtn.parent.parent.label
                    color: tileRoot.view.sys.colFg
                    elide: Text.ElideRight

                    font {
                        family: tileRoot.view.sys.fontFam
                        pixelSize: 13
                        bold: true
                    }

                }

                Text {
                    Layout.fillWidth: true
                    text: iconBtn.parent.parent.sub
                    color: tileRoot.view.sys.colMuted
                    elide: Text.ElideRight

                    font {
                        family: tileRoot.view.sys.fontFam
                        pixelSize: 11
                    }

                }

            }

            Text {
                text: ""
                color: bodyMa.containsMouse ? tileRoot.view.sys.colFg : tileRoot.view.sys.colMuted

                font {
                    family: tileRoot.view.sys.fontFam
                    pixelSize: 13
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 130
                    }

                }

            }

        }

        MouseArea {
            id: bodyMa

            anchors.fill: parent
            anchors.leftMargin: 58
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.bodyClicked()
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

    }
