import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Rectangle {
    id: iconBtnRoot
    property var view

        property string glyph: ""
        property string tip: ""
        property color glyphColor: iconBtnRoot.view.sys.colMuted
        property color activeColor: iconBtnRoot.view.sys.colFg
        property bool active: false
        property int badge: 0

        signal act()

        implicitWidth: 44
        implicitHeight: 44
        radius: 13
        z: ibMa.containsMouse ? 10 : 0
        color: ibMa.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
        border.color: active ? Qt.rgba(iconBtnRoot.view.sys.colOk.r, iconBtnRoot.view.sys.colOk.g, iconBtnRoot.view.sys.colOk.b, 0.5) : iconBtnRoot.view.sys.colLine
        border.width: 1
        scale: ibMa.pressed ? 0.9 : (ibMa.containsMouse ? 1.06 : 1)

        Glyph {
            anchors.fill: parent
            glyph: parent.glyph
            color: parent.active ? parent.activeColor : ibMa.containsMouse ? iconBtnRoot.view.sys.colFg : parent.glyphColor
            fontFam: iconBtnRoot.view.sys.fontFam
            size: iconBtnRoot.view.sys.iconSize - 2
        }

        Rectangle {
            width: 15
            height: 15
            radius: 8
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 2
            visible: parent.badge > 0
            color: iconBtnRoot.view.sys.colOn

            Text {
                anchors.centerIn: parent
                text: parent.parent.badge > 9 ? "9+" : parent.parent.badge
                color: iconBtnRoot.view.sys.fgOn(iconBtnRoot.view.sys.colOn)

                font {
                    family: iconBtnRoot.view.sys.fontFam
                    pixelSize: 9
                    bold: true
                }

            }

        }

        MouseArea {
            id: ibMa

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.act()
        }

        Rectangle {
            id: ibTip

            visible: opacity > 0.01
            opacity: (ibMa.containsMouse && parent.tip.length) ? 1 : 0
            width: ibTipText.implicitWidth + 20
            height: 26
            radius: 13
            x: (parent.width - width) / 2
            y: -height - 8
            color: Qt.rgba(0.04, 0.04, 0.05, 0.96)
            border.color: iconBtnRoot.view.sys.colLine
            border.width: 1
            scale: ibMa.containsMouse ? 1 : 0.92
            transformOrigin: Item.Bottom

            Text {
                id: ibTipText

                anchors.centerIn: parent
                text: ibTip.parent.tip
                color: iconBtnRoot.view.sys.colFg

                font {
                    family: iconBtnRoot.view.sys.fontFam
                    pixelSize: 11
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutBack
                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 160
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 160
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutBack
            }

        }

    }
