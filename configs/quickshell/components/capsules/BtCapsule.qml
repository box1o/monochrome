import QtQuick
import QtQuick.Layouts

RowLayout {
    property var rootState

        id: btCapsule
        z: 110
        anchors.centerIn: parent
        spacing: 11
        visible: rootState.btToastActive
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: rootState.animFast } }

        Item {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 6

            Text {
                anchors.centerIn: parent
                text: rootState.btToastDisconnected ? String.fromCodePoint(0xF00B2)
                    : rootState.btToastType === "earbuds" ? String.fromCodePoint(0xF15C6)
                    : rootState.btToastType === "mouse" ? String.fromCodePoint(0xF098B)
                    : rootState.btToastType === "keyboard" ? String.fromCodePoint(0xF030C)
                    : rootState.btToastType === "gamepad" ? String.fromCodePoint(0xF02B4)
                    : rootState.btToastType === "phone" ? String.fromCodePoint(0xF011E)
                    : rootState.btToastType === "speaker" ? String.fromCodePoint(0xF04C3)
                    : String.fromCodePoint(0xF00AF)
                color: rootState.btToastDisconnected ? rootState.colCrit : rootState.colFg
                font { family: rootState.fontFam; pixelSize: 20 }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 0
            transform: Translate { y: -2 }

            Text {
                text: rootState.btToastDisconnected ? rootState.tr("Disconnected") : rootState.tr("Connected")
                color: rootState.btToastDisconnected ? rootState.colCrit : rootState.colMuted
                transform: Translate { y: 2 }
                font { family: rootState.fontFam; pixelSize: rootState.fontSize - 4 }
            }
            Text {
                Layout.maximumWidth: 220
                text: rootState.btToastName
                color: rootState.colFg
                elide: Text.ElideRight
                font { family: rootState.fontFam; pixelSize: rootState.fontSize + 1; bold: true }
            }
        }

        Item {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 48

            Canvas {
                id: btRing
                anchors.fill: parent
                visible: !rootState.btToastDisconnected && rootState.btConnectedBattery >= 0

                readonly property real level:
                    rootState.btConnectedBattery >= 0 ? rootState.btConnectedBattery / 100 : 0
                property real fill: 0
                readonly property real lineW: 3.5

                onFillChanged: requestPaint()
                onLevelChanged: {
                    if (!rootState.btToastActive) return;
                    btRingAnim.stop();
                    btRingAnim.from = btRing.fill;
                    btRingAnim.to = btRing.level;
                    btRingAnim.start();
                }

                NumberAnimation {
                    id: btRingAnim
                    target: btRing; property: "fill"
                    duration: 900; easing.type: Easing.OutCubic
                }
                function play() {
                    btRingAnim.stop();
                    btRing.fill = 0;
                    btRingAnim.from = 0;
                    btRingAnim.to = btRing.level;
                    btRingAnim.start();
                }
                Connections {
                    target: rootState
                    function onBtToastActiveChanged() {
                        if (rootState.btToastActive) btRing.play();
                    }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    if (width <= 0 || height <= 0) return;
                    var c = rootState.colFg;
                    if (rootState.btConnectedBattery >= 0 && rootState.btConnectedBattery <= 20) {
                        c = rootState.colCrit;
                    } else if (rootState.themeNothing) {
                        c = rootState.colOn;
                    } else if (rootState.btConnectedBattery > 20) {
                        c = "#34d399";
                    }
                    var r = (Math.min(width, height) - lineW) / 2;
                    var cx = width / 2, cy = height / 2;

                    ctx.lineWidth = lineW;
                    ctx.lineCap = "round";

                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                    ctx.strokeStyle = Qt.rgba(c.r, c.g, c.b, 0.22);
                    ctx.stroke();

                    if (fill > 0) {
                        var start = -Math.PI / 2;
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, start, start + 2 * Math.PI * fill);
                        ctx.strokeStyle = c;
                        ctx.stroke();
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: String(rootState.btConnectedBattery)
                    color: rootState.btConnectedBattery <= 20 ? rootState.colCrit : rootState.colFg
                    font { family: rootState.fontFam; pixelSize: rootState.fontSize - 6; bold: true }
                }
            }

            Rectangle {
                anchors.fill: parent
                visible: !rootState.btToastDisconnected && rootState.btConnectedBattery < 0
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.10)
                Text {
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xF00AF)
                    color: rootState.colFg
                    font { family: rootState.fontFam; pixelSize: 14 }
                }
            }

            Rectangle {
                anchors.fill: parent
                visible: rootState.btToastDisconnected
                radius: 14
                color: Qt.rgba(1, 0, 0, 0.12)
                Text {
                    anchors.centerIn: parent
                    text: String.fromCodePoint(0xF00B2)
                    color: rootState.colCrit
                    font { family: rootState.fontFam; pixelSize: 14 }
                }
            }
        }
    }
