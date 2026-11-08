import QtQuick

Text {
    required property string glyph
    required property string fontFamily
    property real pixelSize: 16

    text: glyph
    textFormat: Text.PlainText
    font.family: fontFamily
    font.pixelSize: pixelSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    Accessible.ignored: true
}
