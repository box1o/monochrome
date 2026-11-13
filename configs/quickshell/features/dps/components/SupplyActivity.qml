import "../../../components/icons"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: activity

    required property QtObject source
    required property QtObject tokens
    readonly property real contentWidth: implicitWidth + tokens.px(24)

    signal openRequested()

    spacing: tokens.px(8)

    AssetIcon {
        Layout.preferredWidth: tokens.px(14)
        Layout.preferredHeight: tokens.px(14)
        name: "power"
        color: activity.source.stale ? activity.tokens.yellow : activity.tokens.green
    }

    Text {
        text: activity.source.stale ? "Output unknown" : Number(activity.source.values.voltage).toFixed(2) + " V"
        color: activity.tokens.foreground
        font.family: activity.tokens.monoFamily
        font.pixelSize: activity.tokens.labelSize
    }

    Text {
        visible: !activity.source.stale
        text: Number(activity.source.values.current || 0).toFixed(3) + " A"
        color: activity.tokens.muted
        font.family: activity.tokens.monoFamily
        font.pixelSize: activity.tokens.labelSize
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: activity.openRequested()
    }

}
