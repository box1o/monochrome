import QtQuick
import "../../../components/layout"
import QtQuick.Layouts
import "../../../components/controls"

Flickable {
    id: settings

    required property QtObject source
    required property QtObject tokens
    readonly property var preferences: source.tailscale.preferences

    implicitHeight: Math.max(36, contentHeight)
    contentHeight: content.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ScrollMotion {
        motionEnabled: settings.tokens.motionEnabled
    }

    ColumnLayout {
        id: content

        width: parent.width
        spacing: 9

        Repeater {
            model: [{
                "title": "Use Tailscale DNS",
                "key": "accept-dns",
                "field": "dns"
            }, {
                "title": "Accept subnet routes",
                "key": "accept-routes",
                "field": "routes"
            }, {
                "title": "Block incoming connections",
                "key": "shields-up",
                "field": "shields"
            }]

            RowLayout {
                required property var modelData

                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: modelData.title
                    color: settings.tokens.foreground
                    font.family: settings.tokens.fontFamily
                    font.pixelSize: settings.tokens.labelSize
                }

                ToggleIconButton {
                    controlScale: 1.5
                    tokens: settings.tokens
                    description: modelData.title
                    active: settings.preferences[modelData.field] === true
                    enabled: !settings.source.busy && typeof settings.preferences[modelData.field] === "boolean"
                    onClicked: settings.source.setPreference(modelData.key, !active)
                }
            }
        }

        Text {
            Layout.topMargin: 8
            text: "Exit node"
            color: settings.tokens.muted
            font.family: settings.tokens.fontFamily
            font.pixelSize: settings.tokens.labelSize
        }

        TextButton {
            tokens: settings.tokens
            text: "None · direct internet"
            visible: settings.source.exitNodes.length > 0 || settings.preferences.hasExit === true
            textColor: settings.preferences.hasExit ? settings.tokens.muted : settings.tokens.foreground
            enabled: !settings.source.busy && settings.source.tailscale.connected
            onClicked: settings.source.setPreference("exit-node", "")
        }

        Repeater {
            model: settings.source.exitNodes

            TextButton {
                required property var modelData

                tokens: settings.tokens
                text: modelData.name + (modelData.online ? "" : " · Offline")
                textColor: modelData.exitNode ? settings.tokens.blue : settings.tokens.muted
                enabled: modelData.online && !settings.source.busy
                onClicked: settings.source.setPreference("exit-node", modelData.address)
            }
        }

        Text {
            visible: settings.source.exitNodes.length === 0
            text: "No exit nodes available"
            color: settings.tokens.muted
            font.family: settings.tokens.fontFamily
            font.pixelSize: settings.tokens.captionSize
        }
    }
}
