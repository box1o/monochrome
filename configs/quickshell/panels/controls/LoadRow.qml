import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

RowLayout {
    id: lrow
    property var view


        property string glyph: ""
        property string name: ""
        property int pct: -1
        property int temp: -1

        visible: lrow.pct >= 0
        spacing: 8

        Glyph {
            Layout.preferredWidth: 15
            Layout.preferredHeight: 15
            glyph: lrow.glyph
            color: lrow.view.sys.colMuted
            fontFam: lrow.view.sys.fontFam
            size: 12
        }

        Text {
            Layout.preferredWidth: 30
            text: lrow.name
            color: lrow.view.sys.colMuted

            font {
                family: lrow.view.sys.fontFam
                pixelSize: 9
                letterSpacing: 0.6
            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 3
            Layout.alignment: Qt.AlignVCenter
            radius: 1.5
            color: Qt.rgba(1, 1, 1, 0.12)

            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, lrow.pct)) / 100
                height: parent.height
                radius: parent.radius
                color: lrow.view.sys.colFg

                Behavior on width {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

        Item {
            Layout.preferredWidth: pctRuler.implicitWidth
            Layout.preferredHeight: pctRuler.implicitHeight

            Num {
                view: lrow.view
                id: pctRuler

                visible: false
                value: "100%"
                size: lrow.view.sys.dotHTiny
            }

            Num {
                view: lrow.view
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                value: lrow.pct + "%"
                size: lrow.view.sys.dotHTiny
                color: lrow.view.sys.colFg
            }

        }

        RowLayout {
            spacing: 3
            visible: lrow.temp >= 0

            Glyph {
                Layout.preferredWidth: 11
                Layout.preferredHeight: 11
                glyph: String.fromCodePoint(986625)
                color: lrow.temp >= 80 ? lrow.view.sys.colCrit : lrow.view.sys.colMuted
                fontFam: lrow.view.sys.fontFam
                size: 10
            }

            Num {
                view: lrow.view
                Layout.alignment: Qt.AlignVCenter
                value: lrow.temp + "°"
                size: lrow.view.sys.dotHTiny
                color: lrow.temp >= 80 ? lrow.view.sys.colCrit : lrow.view.sys.colMuted
            }

        }

    }
