import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Item {
    id: trk
    property var view


        property real pos: 0
        property string icon: ""
        property string valueText: ""
        property real wheelStep: 0.05
        property bool dim: false
        readonly property real padL: trk.icon.length ? 22 : 0
        property bool live: false
        property real wheelFrom: -1
        property real held: -1
        readonly property real shown: trk.held >= 0 ? trk.held : trk.pos

        signal setFrac(real frac)
        signal iconClicked()

        function fracAt(x) {
            return Math.max(0, Math.min(1, (x + trk.padL) / Math.max(1, trk.width)));
        }

        function put(frac) {
            trk.held = Math.max(0, Math.min(1, frac));
            heldIdle.restart();
            trk.setFrac(trk.held);
        }

        implicitHeight: 22
        Component.onCompleted: liveTimer.start()

        Timer {
            id: liveTimer

            interval: 260
            onTriggered: trk.live = true
        }

        Timer {
            id: wheelIdle

            interval: 260
            onTriggered: trk.wheelFrom = -1
        }

        Timer {
            id: heldIdle

            interval: 400
            onTriggered: trk.held = -1
        }

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Qt.rgba(1, 1, 1, 0.12)
            clip: true

            Rectangle {
                width: Math.max(parent.height, parent.width * trk.shown)
                height: parent.height
                radius: height / 2
                color: trk.view.sys.colFg
                opacity: trk.dim ? 0.45 : 1

                Behavior on width {
                    enabled: trk.live && !trkMa.pressed

                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 130
                    }

                }

            }

        }

        Text {
            x: 6
            anchors.verticalCenter: parent.verticalCenter
            visible: trk.icon.length > 0
            text: trk.icon
            color: trk.view.sys.colBg

            font {
                family: trk.view.sys.fontFam
                pixelSize: 15
            }

        }

        Text {
            id: trkVal

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            text: trk.valueText
            color: (trk.width * trk.shown) > (trk.width - trkVal.width - 12) ? trk.view.sys.colBg : trk.view.sys.colFg

            font {
                family: trk.view.sys.fontFam
                pixelSize: 11
                bold: true
            }

        }

        MouseArea {
            id: trkMa

            anchors.fill: parent
            anchors.leftMargin: trk.padL
            preventStealing: true
            cursorShape: Qt.PointingHandCursor
            onPressed: (mouse) => {
                return trk.put(trk.fracAt(mouse.x));
            }
            onPositionChanged: (mouse) => {
                if (pressed)
                    trk.put(trk.fracAt(mouse.x));

            }
            onWheel: (wheel) => {
                var d = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x;
                if (d === 0)
                    return ;

                var base = trk.wheelFrom >= 0 ? trk.wheelFrom : trk.shown;
                var steps = Math.round(base / trk.wheelStep) + (d > 0 ? 1 : -1);
                var next = Math.max(0, Math.min(1, steps * trk.wheelStep));
                trk.wheelFrom = next;
                wheelIdle.restart();
                trk.put(next);
            }
        }

        MouseArea {
            width: 22
            height: parent.height
            visible: trk.icon.length > 0
            cursorShape: Qt.PointingHandCursor
            onClicked: trk.iconClicked()
        }

    }
