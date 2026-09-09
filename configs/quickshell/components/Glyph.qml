import QtQuick

Item {
    id: glyph

    property string glyph: ""
    property color color: "#ffffff"
    property string fontFam: "monospace"
    property real size: 16
    readonly property real baselineY: -tm.boundingRect.y
    readonly property real inkX: tm.tightBoundingRect.x + tm.tightBoundingRect.width / 2
    readonly property real inkY: baselineY + tm.tightBoundingRect.y + tm.tightBoundingRect.height / 2

    implicitWidth: size
    implicitHeight: size

    TextMetrics {
        id: tm

        text: glyph.glyph

        font {
            family: glyph.fontFam
            pixelSize: glyph.size
        }

    }

    Text {
        text: glyph.glyph
        color: glyph.color
        x: Math.round(glyph.width / 2 - glyph.inkX)
        y: Math.round(glyph.height / 2 - glyph.inkY)

        font {
            family: glyph.fontFam
            pixelSize: glyph.size
            hintingPreference: Font.PreferFullHinting
        }

        Behavior on color {
            ColorAnimation {
                duration: 160
            }

        }

    }

}
