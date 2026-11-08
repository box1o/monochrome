import QtQuick
import "../../../components/layout"
import QtQuick.Layouts
import "../../../components/controls"

Item {
    id: list

    required property QtObject source
    required property QtObject tokens

    implicitHeight: source.tailscale.connected ? devices.implicitHeight : 36

    Text {
        anchors.centerIn: parent
        visible: !list.source.tailscale.connected
        text: "Connect Tailscale to see your devices"
        color: list.tokens.muted
        font.family: list.tokens.fontFamily
        font.pixelSize: list.tokens.labelSize
    }

    Flickable {
        anchors.fill: parent
        visible: list.source.tailscale.connected
        contentHeight: devices.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollMotion {
            motionEnabled: list.tokens.motionEnabled
        }

        ColumnLayout {
            id: devices

            width: parent.width
            spacing: 6

            Repeater {
                model: list.source.tailscale.devices

                VpnDeviceRow {
                    required property var modelData

                    Layout.fillWidth: true
                    device: modelData
                    tokens: list.tokens
                    busy: list.source.busy
                    onCopyRequested: list.source.copyAddress(device.address)
                    onPingRequested: list.source.ping(device.address)
                }
            }
        }
    }
}
