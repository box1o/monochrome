import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Rectangle {
    id: mediaBtnRoot
    property var view

        property string icon: ""
        property bool primary: false
        property bool enabledAction: true

        signal act()

        implicitWidth: primary ? 42 : 34
        implicitHeight: primary ? 42 : 34
        radius: width / 2
        color: primary ? mediaBtnRoot.view.sys.colFg : (mbMa.containsMouse ? mediaBtnRoot.view.sys.colHover : Qt.rgba(1, 1, 1, 0.08))
        opacity: enabledAction ? 1 : 0.35
        scale: mbMa.pressed ? 0.9 : (mbMa.containsMouse ? 1.08 : 1)

        Text {
            anchors.centerIn: parent
            text: parent.icon
            color: parent.primary ? mediaBtnRoot.view.sys.colBg : mediaBtnRoot.view.sys.colFg

            font {
                family: mediaBtnRoot.view.sys.fontFam
                pixelSize: parent.primary ? 17 : 14
            }

        }

        MouseArea {
            id: mbMa

            anchors.fill: parent
            hoverEnabled: true
            enabled: parent.enabledAction
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.act()
        }

        Behavior on color {
            ColorAnimation {
                duration: 140
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 130
                easing.type: Easing.OutBack
            }

        }

    }
