import QtQml
import "DotFont.js" as Font
import "DotLayout.js" as Layout

QtObject {
    property string text: ""
    property real pixelSize: 12
    property real dotSpacing: 0.1
    property real rowSpacing: dotSpacing
    property real letterSpacing: 1
    property real weight: 1
    readonly property real dotSize: pixelSize / (7 + 6 * dotSpacing)
    readonly property real pitch: dotSize * (1 + dotSpacing)
    readonly property real rowPitch: dotSize * (1 + rowSpacing)
    readonly property real inkPadding: Math.max(0, (weight - 1) * dotSize / 2)
    readonly property var characters: Font.characters(text)
    readonly property real contentWidth: Layout.width(characters, pitch, letterSpacing, dotSize, dotSpacing, inkPadding)
    readonly property real contentHeight: 6 * rowPitch + dotSize + 2 * inkPadding
}
