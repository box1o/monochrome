import QtQuick

Canvas {
    required property QtObject tokens
    property real progress: 0
    property color color: "white"

    implicitWidth: tokens.px(44)
    implicitHeight: tokens.px(18)
    onProgressChanged: requestPaint()
    onColorChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d");
        const r = (height - 1) / 2;
        ctx.reset();
        ctx.beginPath();
        ctx.moveTo(r, 0.5);
        ctx.arcTo(width - 0.5, 0.5, width - 0.5, height - 0.5, r);
        ctx.arcTo(width - 0.5, height - 0.5, 0.5, height - 0.5, r);
        ctx.arcTo(0.5, height - 0.5, 0.5, 0.5, r);
        ctx.arcTo(0.5, 0.5, width - 0.5, 0.5, r);
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.1);
        ctx.fill();
        ctx.save();
        ctx.clip();
        ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.25);
        ctx.fillRect(0, 0, width * Math.max(0, Math.min(1, progress)), height);
        ctx.restore();
        ctx.lineWidth = 1;
        ctx.strokeStyle = color;
        ctx.stroke();
    }
}
