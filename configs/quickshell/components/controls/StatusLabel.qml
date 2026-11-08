import QtQuick

Text {
    required property QtObject tokens
    property bool error: false

    textFormat: Text.PlainText
    visible: text.length > 0
    color: error ? tokens.red : tokens.muted
    font.family: tokens.fontFamily
    font.pixelSize: tokens.labelSize
    wrapMode: Text.Wrap
}
