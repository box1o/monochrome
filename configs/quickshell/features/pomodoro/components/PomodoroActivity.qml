import QtQuick
import QtQuick.Layouts
import "../../../components/icons"

RowLayout {
    id: activity

    required property QtObject source
    required property QtObject tokens
    readonly property real contentWidth: implicitWidth + tokens.px(24)

    spacing: tokens.px(7)

    AssetIcon {
        Layout.preferredWidth: tokens.px(15)
        Layout.preferredHeight: tokens.px(15)
        name: activity.source.running ? "timer" : "pause"
        color: activity.tokens.magenta
    }

    Text {
        text: activity.source.title
        color: activity.tokens.muted
        font.family: activity.tokens.fontFamily
        font.pixelSize: activity.tokens.labelSize
    }

    Text {
        text: activity.source.text
        color: activity.tokens.foreground
        opacity: activity.source.running ? 1 : 0.6
        font.family: activity.tokens.monoFamily
        font.pixelSize: activity.tokens.bodySize
        font.bold: true
    }
}
