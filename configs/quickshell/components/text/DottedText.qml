import QtQuick
import "DotLayout.js" as Layout

Canvas {
    id: root

    property string text: ""
    property color color: "white"
    property real pixelSize: 12
    property real dotSpacing: 0.1
    property real rowSpacing: dotSpacing
    property real letterSpacing: 1
    property real weight: 1
    readonly property var characters: metrics.characters

    implicitWidth: metrics.contentWidth
    implicitHeight: metrics.contentHeight
    onCharactersChanged: requestPaint()
    onColorChanged: requestPaint()
    onPixelSizeChanged: requestPaint()
    onDotSpacingChanged: requestPaint()
    onRowSpacingChanged: requestPaint()
    onLetterSpacingChanged: requestPaint()
    onWeightChanged: requestPaint()
    onPaint: Layout.paint(getContext("2d"), characters, color, metrics.pitch, metrics.rowPitch, metrics.dotSize, weight, letterSpacing, metrics.inkPadding)

    DottedMetrics {
        id: metrics

        text: root.text
        pixelSize: root.pixelSize
        dotSpacing: root.dotSpacing
        rowSpacing: root.rowSpacing
        letterSpacing: root.letterSpacing
        weight: root.weight
    }
}
