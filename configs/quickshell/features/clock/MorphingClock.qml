import QtQuick
import "../../components/text"

Item {
    id: morph

    required property QtObject clock
    required property QtObject metrics
    required property QtObject tokens
    required property QtObject style
    required property real progress
    readonly property real expandedWidth: largeMetrics.contentWidth

    DottedMetrics {
        id: largeMetrics

        text: morph.clock.text
        pixelSize: morph.metrics.clockSize
        letterSpacing: morph.style.clockSpacing
        dotSpacing: 0.45
        rowSpacing: dotSpacing
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: (morph.style.compactHeight - height) / 2
        text: morph.clock.text
        textFormat: Text.PlainText
        font.family: morph.tokens.fontFamily
        font.pixelSize: morph.tokens.textSize(12)
        color: morph.style.foreground
        opacity: 1 - morph.progress
        visible: opacity > 0
    }

    DottedText {
        readonly property real compactX: (morph.width - width) / 2

        x: compactX + (morph.metrics.padding - compactX) * morph.progress
        y: (morph.style.compactHeight - height) / 2 * (1 - morph.progress) + morph.metrics.clockY * morph.progress
        text: morph.clock.text
        pixelSize: Math.max(10, morph.tokens.fontSize - morph.style.clockSizeOffset) * (1 - morph.progress) + largeMetrics.pixelSize * morph.progress
        dotSpacing: morph.style.clockDotSpacing + (largeMetrics.dotSpacing - morph.style.clockDotSpacing) * morph.progress
        rowSpacing: morph.style.clockRowSpacing + (largeMetrics.rowSpacing - morph.style.clockRowSpacing) * morph.progress
        letterSpacing: morph.style.clockSpacing
        opacity: morph.progress
        visible: opacity > 0
        weight: 1
        color: morph.style.foreground
    }
}
