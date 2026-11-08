import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"
import "components"

MenuPage {
    id: page

    required property QtObject model
    readonly property QtObject source: model.source

    signal backRequested

    contentItem: content

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            IconButton {
                tokens: page.tokens
                iconName: "chevron-left"
                description: "Back"
                onClicked: page.backRequested()
            }

            Repeater {
                model: page.model.sections

                TextButton {
                    required property string modelData

                    tokens: page.tokens
                    text: modelData
                    textColor: page.model.section === modelData ? page.tokens.foreground : page.tokens.muted
                    onClicked: page.model.selectSection(modelData)
                }
            }

            Item {
                Layout.fillWidth: true
            }

            TextButton {
                tokens: page.tokens
                text: "Sign in"
                visible: page.source.loginUrl.length > 0 && !page.source.tailscale.connected
                onClicked: page.source.signIn()
            }
        }

        VpnConnections {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: page.source
            tokens: page.tokens
            visible: page.model.section === "Connections"
        }

        VpnDevices {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: page.source
            tokens: page.tokens
            visible: page.model.section === "Devices"
        }

        VpnSettings {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: page.source
            tokens: page.tokens
            visible: page.model.section === "Settings"
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            text: page.source.error || (page.source.busy ? "Applying changes…" : page.source.notice)
            error: page.source.error.length > 0
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }
}
