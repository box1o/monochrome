import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Rectangle {
    id: battStatRoot
    property var view

        property string label: ""
        property string value: ""

        implicitWidth: 90
        implicitHeight: 44
        Layout.fillWidth: true
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: battStatRoot.view.sys.colLine
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: parent.parent.label
                color: battStatRoot.view.sys.colMuted

                font {
                    family: battStatRoot.view.sys.fontFam
                    pixelSize: 10
                }

            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: parent.parent.value
                color: battStatRoot.view.sys.colFg

                font {
                    family: battStatRoot.view.sys.fontFam
                    pixelSize: 12
                    bold: true
                }

            }

        }

    }
