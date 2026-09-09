import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Rectangle {
    id: brightCardRoot
    property var view


        property string bid: ""
        property int bpct: 0
        property string bname: ""

        implicitWidth: 190
        implicitHeight: 56
        radius: 14
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: brightCardRoot.view.sys.colLine
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 11
            anchors.rightMargin: 11
            anchors.topMargin: 7
            anchors.bottomMargin: 8
            spacing: 5

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: brightCardRoot.view.sys.tr("Brightness")
                    color: brightCardRoot.view.sys.colFg

                    font {
                        family: brightCardRoot.view.sys.fontFam
                        pixelSize: 12
                        bold: true
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    Layout.maximumWidth: 130
                    visible: brightCardRoot.bname.length > 0
                    text: brightCardRoot.bname
                    color: brightCardRoot.view.sys.colMuted
                    elide: Text.ElideRight

                    font {
                        family: brightCardRoot.view.sys.fontFam
                        pixelSize: 10
                    }

                }

            }

            Track {
                id: brTrk
                view: brightCardRoot.view

                Layout.fillWidth: true
                Layout.preferredHeight: 22
                pos: Math.max(0, Math.min(1, brightCardRoot.bpct / 100))
                icon: String.fromCodePoint(983261)
                valueText: Math.round(brTrk.shown * 100) + "%"
                onSetFrac: (f) => {
                    return brightCardRoot.view.sys.brightSet(brightCardRoot.bid, Math.round(f * 20) * 5);
                }
            }

        }

    }
