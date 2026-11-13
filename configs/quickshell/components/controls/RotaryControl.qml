import QtQuick
import QtQuick.Controls

Dial {
    id: dial

    required property QtObject tokens
    property color accentColor: tokens.blue
    property string description: "Adjust value"
    property real fineStep: stepSize / 10

    signal adjusted(real next)

    implicitWidth: tokens.dialSize
    implicitHeight: tokens.dialSize
    inputMode: Dial.Vertical
    startAngle: -135
    endAngle: 135
    wrap: false
    wheelEnabled: false
    snapMode: Dial.SnapAlways
    Accessible.name: description
    onMoved: adjusted(value)

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            if (event.phase === Qt.ScrollMomentum) {
                event.accepted = true;
                return ;
            }
            const delta = event.angleDelta.y || event.pixelDelta.y;
            if (!delta)
                return ;

            const step = event.modifiers & Qt.ShiftModifier ? dial.fineStep : dial.stepSize;
            const next = Math.max(dial.from, Math.min(dial.to, dial.value + Math.sign(delta) * step));
            dial.adjusted(Number(next.toFixed(6)));
            event.accepted = true;
        }
    }

    background: Canvas {
        id: scale

        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const cx = width / 2, cy = height / 2, r = width / 2 - dial.tokens.px(3);
            const start = 0.75 * Math.PI, span = 1.5 * Math.PI;
            ctx.lineWidth = 2;
            ctx.lineCap = "round";
            ctx.strokeStyle = dial.tokens.cardBorder;
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, start + span);
            ctx.stroke();
            ctx.strokeStyle = dial.enabled ? dial.accentColor : dial.tokens.muted;
            ctx.beginPath();
            ctx.arc(cx, cy, r, start, start + span * dial.position);
            ctx.stroke();
        }

        Connections {
            function onPositionChanged() {
                scale.requestPaint();
            }

            function onEnabledChanged() {
                scale.requestPaint();
            }

            target: dial
        }

    }

    handle: Rectangle {
        x: dial.tokens.px(10)
        y: dial.tokens.px(10)
        width: dial.width - tokens.px(20)
        height: dial.height - tokens.px(20)
        radius: width / 2
        color: dial.tokens.controlBackground
        border.width: 1
        border.color: dial.visualFocus ? dial.accentColor : dial.tokens.cardBorder
        rotation: dial.angle

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: tokens.px(6)
            width: tokens.px(3)
            height: tokens.px(10)
            radius: tokens.px(1.5)
            color: dial.enabled ? dial.tokens.foreground : dial.tokens.muted
        }

        Behavior on rotation {
            NumberAnimation {
                duration: dial.tokens.motionEnabled && !dial.pressed ? dial.tokens.fastDuration : 0
                easing.type: Easing.OutCubic
            }

        }

    }

}
