import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: page

    required property QtObject source

    signal backRequested()

    Binding {
        target: page.source
        property: "browsing"
        value: page.active
        restoreMode: Binding.RestoreBindingOrValue
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        MenuHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            title: "Scrcpy devices"
            onBackRequested: page.backRequested()

            action: IconButton {
                tokens: page.tokens
                iconName: "rotate-cw"
                description: "Refresh devices"
                enabled: !page.source.busy
                onClicked: page.source.refresh()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, Math.max(0, page.height - 90))
            clip: true
            spacing: 4
            model: page.source.devices

            delegate: SelectableMenuItem {
                required property var modelData

                width: ListView.view.width
                tokens: page.tokens
                iconName: "smartphone"
                title: modelData.name
                subtitle: modelData.state === "device" ? "Open screen mirroring" : modelData.state === "unauthorized" ? "Allow USB debugging on your phone" : modelData.state
                enabled: modelData.state === "device"
                onClicked: {
                    if (page.source.mirror(modelData.serial))
                        page.backRequested();
                }
            }
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            horizontalAlignment: Text.AlignHCenter
            text: page.source.error || (page.source.devices.length === 0 ? (page.source.busy ? "Looking for devices…" : "No ADB devices found") : "")
            error: page.source.error.length > 0
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
