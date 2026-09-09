import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Canvas {
    id: chargeWaveRoot
    property var view

        property color tint: chargeWaveRoot.view.sys.colOk
        property real level: 0.5
        property real radius: 14
        property bool running: false
        property real phase: 0

        opacity: running ? 1 : 0
        onPhaseChanged: requestPaint()
        onLevelChanged: requestPaint()
        onTintChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            if (width <= 0 || height <= 0)
                return ;

            var r = Math.min(radius, Math.min(width, height) / 2);
            ctx.beginPath();
            ctx.moveTo(r, 0);
            ctx.arcTo(width, 0, width, height, r);
            ctx.arcTo(width, height, 0, height, r);
            ctx.arcTo(0, height, 0, 0, r);
            ctx.arcTo(0, 0, width, 0, r);
            ctx.closePath();
            ctx.clip();
            var base = height * (1 - Math.max(0.12, Math.min(0.92, level)));
            var amp = 3.2;
            for (var w = 0; w < 2; w++) {
                var off = w === 0 ? 0 : Math.PI * 0.7;
                var k = w === 0 ? 0.055 : 0.041;
                ctx.beginPath();
                ctx.moveTo(0, height);
                for (var x = 0; x <= width; x += 3) {
                    var y = base + amp * Math.sin(k * x + phase + off) + amp * 0.5 * Math.sin(k * 1.9 * x - phase * 0.7);
                    if (x === 0)
                        ctx.lineTo(0, y);
                    else
                        ctx.lineTo(x, y);
                }
                ctx.lineTo(width, height);
                ctx.closePath();
                ctx.fillStyle = Qt.rgba(tint.r, tint.g, tint.b, w === 0 ? 0.16 : 0.11);
                ctx.fill();
            }
        }

        Timer {
            interval: 45
            running: parent.running && parent.visible
            repeat: true
            onTriggered: parent.phase += 0.16
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }

        }

    }
