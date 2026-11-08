import QtQuick
import "../../../components/layout"
import QtQuick.Layouts
import "../../../components/controls"
import "../../../components/icons"

Flickable {
    id: list

    required property QtObject source
    required property QtObject tokens

    implicitHeight: Math.max(36, contentHeight)
    contentHeight: connections.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ScrollMotion {
        motionEnabled: list.tokens.motionEnabled
    }

    Text {
        anchors.centerIn: parent
        visible: list.source.connections.length === 0
        text: "No VPN connections found"
        color: list.tokens.muted
        font.family: list.tokens.fontFamily
        font.pixelSize: list.tokens.labelSize
    }

    ColumnLayout {
        id: connections

        width: parent.width
        spacing: list.tokens.spacing

        Repeater {
            model: list.source.connections

            OverviewCard {
                required property var modelData

                Layout.fillWidth: true
                tokens: list.tokens

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: list.tokens.spacing

                    AssetIcon {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        name: modelData.icon
                        color: modelData.connected ? list.tokens.blue : list.tokens.muted
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: list.tokens.foreground
                            font.family: list.tokens.fontFamily
                            font.pixelSize: list.tokens.labelSize
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.connected ? "Connected" : "Disconnected"
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: list.tokens.muted
                            font.family: list.tokens.fontFamily
                            font.pixelSize: list.tokens.captionSize
                        }
                    }

                    TextButton {
                        tokens: list.tokens
                        text: modelData.connected ? "Disconnect" : "Connect"
                        enabled: !list.source.busy
                        onClicked: list.source.toggle(modelData.id)
                    }
                }
            }
        }
    }
}
