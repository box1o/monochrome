import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"
import "components"

MenuPage {
    id: page

    required property QtObject model

    signal backRequested()

    contentItem: content

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: page.tokens.spacing

        ConnectionHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            title: "Bluetooth"
            radioIcon: "bluetooth"
            radioEnabled: page.model.source.enabled
            available: page.model.source.available && !page.model.source.blocked
            busy: page.model.source.busy
            scanVisible: true
            scanning: page.model.source.scanning
            scanStoppable: page.model.source.ownsScan
            onScanRequested: page.model.source.ownsScan ? page.model.source.stopScan() : page.model.source.scan()
            onBackRequested: page.backRequested()
            onToggleRequested: page.model.source.toggle()
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            text: page.model.source.error
            error: true
        }

        MenuList {
            id: devices

            motionEnabled: page.tokens.motionEnabled
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: tokens.px(2)
            model: page.model.source.enabled ? page.model.source.devices : []
            focus: page.active
            onCurrentIndexChanged: {
                if (activeFocus && currentIndex >= 0 && currentIndex < count)
                    page.model.select(model[currentIndex]);
            }
            Keys.onReturnPressed: {
                if (currentIndex >= 0 && currentIndex < count)
                    page.model.open(model[currentIndex]);
            }

            StatusLabel {
                anchors.centerIn: parent
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                tokens: page.tokens
                visible: devices.count === 0
                text: !page.model.source.available ? "No Bluetooth adapter" : page.model.source.blocked ? "Bluetooth is blocked by hardware" : !page.model.source.enabled ? "Bluetooth is off" : "No devices found. Start a scan."
            }

            delegate: SelectableMenuItem {
                required property var modelData
                required property int index

                width: devices.width
                tokens: page.tokens
                title: modelData.name || modelData.address
                subtitle: page.model.describe(modelData)
                iconName: page.model.iconFor(modelData)
                iconColor: modelData.connected ? page.tokens.green : modelData.blocked ? page.tokens.red : page.tokens.muted
                selected: page.model.selected === modelData || (devices.activeFocus && devices.currentIndex === index)
                enabled: !page.model.source.busy
                onClicked: {
                    devices.currentIndex = index;
                    page.model.open(modelData);
                }
            }
        }

        PairingPrompt {
            Layout.fillWidth: true
            source: page.model.source
            tokens: page.tokens
        }

        DeviceDetails {
            Layout.fillWidth: true
            model: page.model
            tokens: page.tokens
        }

        TextButton {
            tokens: page.tokens
            text: "Cancel"
            visible: ["pair", "connect"].includes(page.model.source.action) && !(page.model.source.prompt.kind || "").length
            onClicked: page.model.source.cancel()
        }
    }
}
