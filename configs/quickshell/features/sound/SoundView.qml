import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"
import "components"

MenuPage {
    id: page

    required property QtObject model
    readonly property QtObject source: model.source
    readonly property QtObject profiles: model.profiles

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
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            text: page.model.section === "Codec" ? (page.profiles.busy ? "Switching codec…" : page.profiles.error) : ""
            error: page.profiles.error.length > 0 && !page.profiles.busy
        }

        AudioDevices {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: page.source
            tokens: page.tokens
            visible: page.model.section === "Output" || page.model.section === "Input"
            input: page.model.section === "Input"
        }

        ApplicationVolumes {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: page.source
            tokens: page.tokens
            visible: page.model.section === "Applications"
        }

        BluetoothProfiles {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: page.profiles
            tokens: page.tokens
            visible: page.model.section === "Codec"
        }
    }
}
