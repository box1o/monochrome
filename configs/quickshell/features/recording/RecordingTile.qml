import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/controls"

AbstractButton {
    id: tile

    required property QtObject source
    required property QtObject tokens

    padding: tokens.px(8)
    enabled: !source.busy
    hoverEnabled: true
    Accessible.name: source.active ? "Stop screen recording" : "Start screen recording"
    onClicked: source.toggle()

    ButtonTooltip {
        parent: tile
        tokens: tile.tokens
        text: tile.source.error || tile.Accessible.name
        visible: tile.hovered && tile.visible && !tile.down
    }

    background: OverviewCard {
        tokens: tile.tokens
        border.color: tile.visualFocus ? tile.tokens.muted : tile.tokens.alpha(tile.tokens.foreground, 0.07)
    }

    contentItem: RowLayout {
        spacing: tile.tokens.spacing

        Rectangle {
            width: tokens.px(16)
            height: tokens.px(16)
            radius: tokens.px(8)
            color: "transparent"
            border.width: 1
            border.color: tile.source.active ? tile.tokens.red : tile.tokens.muted

            Rectangle {
                anchors.centerIn: parent
                width: tokens.px(7)
                height: tokens.px(7)
                radius: tile.source.active ? tokens.px(2) : tokens.px(5)
                color: tile.source.active ? tile.tokens.red : tile.tokens.foreground
            }
        }

        Text {
            Layout.fillWidth: true
            text: tile.source.active ? "Stop recording" : "Screen recording"
            color: tile.source.active ? tile.tokens.red : tile.tokens.muted
            font.family: tile.tokens.fontFamily
            font.pixelSize: tile.tokens.detailSize
        }
    }
}
