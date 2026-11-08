import QtQuick
import QtQuick.Layouts
import "../../../components/controls"
import "../../../components/icons"

Flickable {
    id: list

    required property QtObject source
    required property QtObject tokens

    contentHeight: connections.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Text {
        anchors.centerIn: parent
        visible: list.source.connections.length === 0
        text: "No VPN connections found"
        color: list.tokens.muted
        font.family: list.tokens.fontFamily
        font.pixelSize: list.tokens.fontSize - 3
    }

    ColumnLayout {
        id: connections

        width: parent.width
        spacing: 8

        Repeater {
            model: list.source.connections

            OverviewCard {
                required property var modelData

                Layout.fillWidth: true
                tokens: list.tokens

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

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
                            font.pixelSize: list.tokens.fontSize - 3
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.connected ? "Connected" : "Disconnected"
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: list.tokens.muted
                            font.family: list.tokens.fontFamily
                            font.pixelSize: list.tokens.fontSize - 5
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
