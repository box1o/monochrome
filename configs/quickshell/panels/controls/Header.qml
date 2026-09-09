import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

RowLayout {
    id: headerRoot
    property var view

        property string title: ""
        property bool busy: false

        signal back()
        signal refresh()

        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: 14
            color: backMa.containsMouse ? headerRoot.view.sys.colHover : "transparent"

            Text {
                anchors.centerIn: parent
                text: ""
                color: headerRoot.view.sys.colFg

                font {
                    family: headerRoot.view.sys.fontFam
                    pixelSize: 13
                }

            }

            MouseArea {
                id: backMa

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: parent.parent.back()
            }

            Behavior on color {
                ColorAnimation {
                    duration: 130
                }

            }

        }

        Text {
            Layout.fillWidth: true
            text: parent.title
            color: headerRoot.view.sys.colFg

            font {
                family: headerRoot.view.sys.fontFam
                pixelSize: 13
                bold: true
            }

        }

        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: 14
            color: refMa.containsMouse ? headerRoot.view.sys.colHover : "transparent"

            Text {
                id: refIcon

                anchors.centerIn: parent
                text: "󰑐"
                color: headerRoot.view.sys.colFg

                font {
                    family: headerRoot.view.sys.fontFam
                    pixelSize: 13
                }

                RotationAnimator on rotation {
                    running: refIcon.parent.parent.busy
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 900
                }

            }

            MouseArea {
                id: refMa

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: parent.parent.refresh()
            }

            Behavior on color {
                ColorAnimation {
                    duration: 130
                }

            }

        }

    }
