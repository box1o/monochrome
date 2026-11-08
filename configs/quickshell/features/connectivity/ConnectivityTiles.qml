import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../sound"

RowLayout {
    id: tiles

    required property QtObject audio
    required property QtObject wifi
    required property QtObject bluetooth
    required property QtObject tokens
    signal soundRequested
    signal wifiRequested
    signal bluetoothRequested

    spacing: 8
    ConnectionTile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        tokens: tiles.tokens
        title: tiles.wifi.connectedNetwork?.name || "Wi-Fi"
        description: "Wi-Fi"
        subtitle: tiles.wifi.connectedNetwork ? Math.round(tiles.wifi.connectedNetwork.signalStrength * 100) + "%" : tiles.wifi.summary
        icon: "wifi"
        radioEnabled: tiles.wifi.enabled
        available: tiles.wifi.available && tiles.wifi.hardwareEnabled && !tiles.wifi.busy
        onToggleRequested: tiles.wifi.toggle()
        onOpenRequested: tiles.wifiRequested()
    }

    ConnectionTile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        tokens: tiles.tokens
        title: tiles.bluetooth.connectedDevice?.name || "Bluetooth"
        description: "Bluetooth"
        subtitle: tiles.bluetooth.connectedDevice ? (tiles.bluetooth.connectedDevice.batteryAvailable ? Math.round(tiles.bluetooth.connectedDevice.battery * 100) + "%" : "Connected") : tiles.bluetooth.summary
        icon: "bluetooth"
        radioEnabled: tiles.bluetooth.enabled
        available: tiles.bluetooth.available && !tiles.bluetooth.blocked && !tiles.bluetooth.busy
        onToggleRequested: tiles.bluetooth.toggle()
        onOpenRequested: tiles.bluetoothRequested()
    }

    SoundTile {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        onOpenRequested: tiles.soundRequested()
        source: tiles.audio
        tokens: tiles.tokens
    }
}
