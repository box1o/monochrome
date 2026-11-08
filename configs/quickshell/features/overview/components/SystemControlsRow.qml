import QtQuick
import QtQuick.Layouts
import "../../brightness"
import "../../vpn"

RowLayout {
    id: row

    required property QtObject brightness
    required property QtObject vpn
    required property QtObject tokens
    required property real cardHeight

    signal brightnessRequested()
    signal vpnRequested()

    implicitHeight: cardHeight
    spacing: row.tokens.spacing

    BrightnessTile {
        Layout.preferredWidth: (row.width - row.spacing) * 1.8 / 3
        Layout.minimumHeight: row.cardHeight
        Layout.preferredHeight: row.cardHeight
        Layout.maximumHeight: row.cardHeight
        tokens: row.tokens
        source: row.brightness
        onOpenRequested: row.brightnessRequested()
    }

    VpnTile {
        Layout.fillWidth: true
        Layout.minimumHeight: row.cardHeight
        Layout.preferredHeight: row.cardHeight
        Layout.maximumHeight: row.cardHeight
        tokens: row.tokens
        source: row.vpn
        onOpenRequested: row.vpnRequested()
    }
}
