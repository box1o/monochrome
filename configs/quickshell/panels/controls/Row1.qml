import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Rectangle {
    id: row1
    property var view

        property string icon: ""
        property string title: ""
        property string sub: ""
        property bool highlight: false

        signal activated()
        signal menuRequested(real mx, real my)

        Layout.fillWidth: true
        Layout.preferredHeight: 42
        radius: 12
        color: rowMa.containsMouse ? row1.view.sys.colHover : (highlight ? Qt.rgba(1, 1, 1, 0.06) : "transparent")

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 11
            anchors.rightMargin: 11
            spacing: 10

            Text {
                text: rowMa.parent.icon
                color: rowMa.parent.highlight ? row1.view.sys.colOn : row1.view.sys.colFg

                font {
                    family: row1.view.sys.fontFam
                    pixelSize: 15
                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: rowMa.parent.title
                    color: row1.view.sys.colFg
                    elide: Text.ElideRight

                    font {
                        family: row1.view.sys.fontFam
                        pixelSize: 12
                        bold: rowMa.parent.highlight
                    }

                }

                Text {
                    text: rowMa.parent.sub
                    visible: text.length > 0
                    color: row1.view.sys.colMuted

                    font {
                        family: row1.view.sys.fontFam
                        pixelSize: 10
                    }

                }

            }

            Text {
                visible: rowMa.parent.highlight
                text: "󰄬"
                color: row1.view.sys.colOn

                font {
                    family: row1.view.sys.fontFam
                    pixelSize: 13
                }

            }

        }

        MouseArea {
            id: rowMa

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    var p = mapToItem(wifiPage, mouse.x, mouse.y);
                    parent.menuRequested(p.x, p.y);
                } else {
                    parent.activated();
                }
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 130
            }

        }

    }
