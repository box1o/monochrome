import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Rectangle {
    id: volCardRoot
    property var view

        implicitWidth: 190
        implicitHeight: 56
        radius: 14
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: volCardRoot.view.sys.colLine
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 11
            anchors.rightMargin: 11
            anchors.topMargin: 7
            anchors.bottomMargin: 11
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: volCardRoot.view.sys.tr("Sound")
                    color: volCardRoot.view.sys.colFg

                    font {
                        family: volCardRoot.view.sys.fontFam
                        pixelSize: 12
                        bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: volCardRoot.view.sys.togglePage("audio")
                    }

                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    text: volCardRoot.view.sys.sinkName.length ? volCardRoot.view.sys.sinkName : volCardRoot.view.sys.tr("No devices")
                    color: volCardRoot.view.sys.colMuted
                    elide: Text.ElideRight

                    font {
                        family: volCardRoot.view.sys.fontFam
                        pixelSize: 10
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: volCardRoot.view.sys.togglePage("audio")
                    }

                }

            }

            Track {
                id: vol
                view: volCardRoot.view

                readonly property var a: volCardRoot.view.sys.sinkAudio

                Layout.fillWidth: true
                Layout.preferredHeight: 22
                pos: vol.a ? vol.a.volume : 0
                dim: vol.a ? vol.a.muted : true
                icon: !vol.a ? String.fromCodePoint(984927) : vol.a.muted ? String.fromCodePoint(984927) : vol.a.volume < 0.34 ? String.fromCodePoint(984447) : vol.a.volume < 0.67 ? String.fromCodePoint(984448) : String.fromCodePoint(984446)
                valueText: !vol.a ? "—" : vol.a.muted ? volCardRoot.view.sys.tr("Muted") : Math.round(vol.shown * 100) + "%"
                onSetFrac: (f) => {
                    if (vol.a)
                        vol.a.volume = Math.round(f * 20) / 20;

                }
                onIconClicked: {
                    if (vol.a)
                        vol.a.muted = !vol.a.muted;

                }
            }

        }

    }
