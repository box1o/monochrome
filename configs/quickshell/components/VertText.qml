import QtQuick

Column {
    id: vt

    property string value: ""
    property color textColor: "white"
    property string fontFam: "monospace"
    property real size: 15
    property bool bold: false
    property int maxChars: 16

    spacing: -2

    Repeater {
        model: String(vt.value).slice(0, vt.maxChars).split("")

        Text {
            required property string modelData
            anchors.horizontalCenter: parent.horizontalCenter
            text: modelData === " " ? "·" : modelData
            color: vt.textColor
            font {
                family: vt.fontFam
                pixelSize: vt.size
                bold: vt.bold
            }
        }
    }
}
