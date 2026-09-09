import QtQuick
import QtQuick.Layouts
import "../../components"

Rectangle {
    id: pomodoroCardRoot
    property var view

    implicitWidth: 190
    implicitHeight: 76
    radius: 14
    color: pomodoroCardRoot.view.sys.pomodoroRunning
           ? Qt.rgba(pomodoroCardRoot.view.sys.colOn.r,
                     pomodoroCardRoot.view.sys.colOn.g,
                     pomodoroCardRoot.view.sys.colOn.b, 0.16)
           : Qt.rgba(1, 1, 1, 0.05)
    border.color: pomodoroCardRoot.view.sys.pomodoroRunning
                  ? Qt.rgba(pomodoroCardRoot.view.sys.colOn.r,
                            pomodoroCardRoot.view.sys.colOn.g,
                            pomodoroCardRoot.view.sys.colOn.b, 0.4)
                  : pomodoroCardRoot.view.sys.colLine
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 3

        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            Glyph {
                glyph: String.fromCodePoint(0xF051B)
                color: pomodoroCardRoot.view.sys.pomodoroRunning
                       ? pomodoroCardRoot.view.sys.colOn : pomodoroCardRoot.view.sys.colMuted
                fontFam: pomodoroCardRoot.view.sys.fontFam
                size: pomodoroCardRoot.view.sys.iconSize - 2
            }

            Text {
                text: pomodoroCardRoot.view.sys.pomodoroPhase
                color: pomodoroCardRoot.view.sys.colFg
                font { family: pomodoroCardRoot.view.sys.fontFam; pixelSize: 11; bold: true }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: pomodoroCardRoot.view.sys.pomodoroRunning ? pomodoroCardRoot.view.sys.tr("Stop") : pomodoroCardRoot.view.sys.tr("Start")
                color: pomodoroCardRoot.view.sys.pomodoroRunning
                       ? pomodoroCardRoot.view.sys.colOn : pomodoroCardRoot.view.sys.colMuted
                font { family: pomodoroCardRoot.view.sys.fontFam; pixelSize: 10; bold: true }
            }

            Rectangle {
                z: 2
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 7
                color: resetMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.07)

                Text {
                    anchors.centerIn: parent
                    text: "↺"
                    color: pomodoroCardRoot.view.sys.colMuted
                    font { family: pomodoroCardRoot.view.sys.fontFam; pixelSize: 15; bold: true }
                }

                MouseArea {
                    id: resetMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pomodoroCardRoot.view.sys.resetPomodoro()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: pomodoroCardRoot.view.sys.pomodoroTime
                color: pomodoroCardRoot.view.sys.colFg
                font { family: pomodoroCardRoot.view.sys.fontFam; pixelSize: 20; bold: true }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.14)

                Rectangle {
                    width: parent.width * pomodoroCardRoot.view.sys.pomodoroProgress
                    height: parent.height
                    radius: 2
                    color: pomodoroCardRoot.view.sys.pomodoroRunning
                           ? pomodoroCardRoot.view.sys.colOn : pomodoroCardRoot.view.sys.colMuted
                    Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                }
            }
        }
    }

    MouseArea {
        z: -1
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: pomodoroCardRoot.view.sys.togglePomodoro()
    }

    Behavior on color { ColorAnimation { duration: 160 } }
    Behavior on border.color { ColorAnimation { duration: 160 } }
}
