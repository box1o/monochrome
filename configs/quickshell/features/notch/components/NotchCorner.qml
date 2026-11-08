import QtQuick

Canvas {
    id: corner

    property bool rightSide: false
    property color color: "#000000"
    property real radius: 12

    width: radius
    height: radius
    onRightSideChanged: requestPaint()
    onColorChanged: requestPaint()
    onRadiusChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d");
        const r = radius;
        ctx.reset();
        ctx.fillStyle = color;
        ctx.beginPath();
        if (rightSide) {
            ctx.moveTo(r, 0);
            ctx.lineTo(0, 0);
            ctx.lineTo(0, r);
            ctx.arc(r, r, r, Math.PI, -Math.PI / 2, false);
        } else {
            ctx.moveTo(0, 0);
            ctx.lineTo(r, 0);
            ctx.lineTo(r, r);
            ctx.arc(0, r, r, 0, -Math.PI / 2, true);
        }
        ctx.closePath();
        ctx.fill();
    }
}
