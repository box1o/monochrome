import QtQuick
import "WavePaint.js" as Wave

Canvas {
    id: wave

    property real level: 0
    property real phase: 0
    property real lowerRadius: 13
    property color tint: "white"
    property bool animated: true

    onLevelChanged: requestPaint()
    onPhaseChanged: requestPaint()
    onLowerRadiusChanged: requestPaint()
    onTintChanged: requestPaint()
    onVisibleChanged: {
        phase = 0;
        requestPaint();
    }
    onPaint: Wave.paint(getContext("2d"), width, height, lowerRadius, tint, level, phase)

    Timer {
        interval: 45
        running: wave.visible && wave.animated
        repeat: true
        onTriggered: wave.phase += 0.16
    }
}
