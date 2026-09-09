import QtQuick
import QtQuick.Layouts

RowLayout {
    property var rootState

        id: toastCapsule
        z: 110
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 16
        anchors.rightMargin: 14
        anchors.topMargin: 12
        spacing: 12
        visible: rootState.toastActive && !rootState.btToastActive && !rootState.acToastActive
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: rootState.animFast } }

        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            Layout.alignment: Qt.AlignTop
            radius: 10
            color: rootState.notifUrgent ? Qt.rgba(1, 0.27, 0.27, 0.18)
                                    : Qt.rgba(1, 1, 1, 0.08)

            Image {
                id: toastIcon
                anchors.fill: parent
                anchors.margins: 5
                source: rootState.notifImage
                visible: source != "" && status === Image.Ready
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
            Text {
                anchors.centerIn: parent
                visible: !toastIcon.visible
                text: String.fromCodePoint(rootState.notifUrgent ? 0xF0026 : 0xF009A)
                color: rootState.notifUrgent ? rootState.colCrit : rootState.colFg
                font { family: rootState.fontFam; pixelSize: rootState.iconSize - 1 }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    Layout.fillWidth: true
                    text: rootState.notifSummary
                    color: rootState.colFg
                    elide: Text.ElideRight
                    font { family: rootState.fontFam; pixelSize: rootState.fontSize - 1; bold: true }
                }
                Text {
                    text: rootState.notifApp
                    color: rootState.colMuted
                    font { family: rootState.fontFam; pixelSize: rootState.fontSize - 5 }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: rootState.notifBody.length > 0 && rootState.cfg.notifPreview
                text: rootState.notifBody
                color: rootState.colMuted
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                textFormat: Text.StyledText
                font { family: rootState.fontFam; pixelSize: rootState.fontSize - 3 }
            }
        }

        Text {
            Layout.alignment: Qt.AlignTop
            text: "×"
            color: closeMa.containsMouse ? rootState.colFg : rootState.colMuted
            font { family: rootState.fontFam; pixelSize: rootState.fontSize + 2 }
            Behavior on color { ColorAnimation { duration: 150 } }
            MouseArea {
                id: closeMa
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: rootState.dismissToast()
            }
        }
    }
