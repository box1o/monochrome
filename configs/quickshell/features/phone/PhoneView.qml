import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: page

    required property QtObject source

    signal backRequested()

    contentItem: content

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: page.tokens.spacing

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

        MenuList {
            motionEnabled: page.tokens.motionEnabled
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: tokens.px(4)
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
