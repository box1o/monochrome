import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/controls"
import "../../components/icons"

OverviewCard {
    id: tile

    required property QtObject source
    signal openRequested

    RowLayout {
        anchors.fill: parent
        anchors.margins: tile.tokens.cardInset
        spacing: tile.tokens.spacing

        IconButton {
            tokens: tile.tokens
            iconName: tile.source.primary?.icon || "shield"
            description: tile.source.primary?.connected ? "Disconnect VPN" : "Connect VPN"
            color: tile.source.primary?.connected ? tile.tokens.blue : tile.tokens.muted
            enabled: !!tile.source.primary && !tile.source.busy
            onClicked: tile.source.toggle(tile.source.primary.id)
        }

        AbstractButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Accessible.name: "VPN connections"
            onClicked: tile.openRequested()
            background: Item {}
            contentItem: ColumnLayout {
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: tile.source.primary?.name || "VPN"
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: tile.tokens.foreground
                    font.family: tile.tokens.fontFamily
                    font.pixelSize: tile.tokens.labelSize
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: tile.source.busy ? "Updating…" : tile.source.primary?.connected ? "Connected" : "Disconnected"

                    color: tile.tokens.muted
                    font.family: tile.tokens.fontFamily
                    font.pixelSize: tile.tokens.captionSize
                }
            }
        }
    }
}
