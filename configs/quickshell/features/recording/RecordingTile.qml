import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/controls"

AbstractButton {
    id: tile

    required property QtObject source
    required property QtObject tokens

    padding: 8
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
        spacing: 8

        Rectangle {
            width: 16
            height: 16
            radius: 8
            color: "transparent"
            border.width: 1
            border.color: tile.source.active ? "#ef6b73" : tile.tokens.muted

            Rectangle {
                anchors.centerIn: parent
                width: 7
                height: 7
                radius: tile.source.active ? 2 : 5
                color: tile.source.active ? "#ef6b73" : tile.tokens.foreground
            }
        }

        Text {
            Layout.fillWidth: true
            text: tile.source.active ? "Stop recording" : "Screen recording"
            color: tile.source.active ? "#ef6b73" : tile.tokens.muted
            font.family: tile.tokens.fontFamily
            font.pixelSize: tile.tokens.fontSize - 4
        }
    }
}
