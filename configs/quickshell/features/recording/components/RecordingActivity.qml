import QtQuick
import QtQuick.Layouts

RowLayout {
    id: activity

    required property QtObject tokens
    readonly property real contentWidth: implicitWidth + 24

    spacing: 8

    Rectangle {
        Layout.preferredWidth: 7
        Layout.preferredHeight: 7
        radius: 3.5
        color: "#ef6b73"
    }

    Text {
        text: "Recording"
        color: activity.tokens.foreground
        font.family: activity.tokens.fontFamily
        font.pixelSize: activity.tokens.fontSize - 3
        font.bold: true
    }
}
