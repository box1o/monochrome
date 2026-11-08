import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: page

    required property QtObject model
    signal backRequested

    onActiveChanged: {
        if (!active)
            password.clear();
    }

    Connections {
        target: page.model
        function onSelectedChanged() {
            password.clear();
        }
    }

    contentItem: content

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: 8

        ConnectionHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            title: "Wi-Fi"
            radioIcon: "wifi"
            radioEnabled: page.model.source.enabled
            available: page.model.source.available && page.model.source.hardwareEnabled
            busy: page.model.source.busy
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
            id: networks
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2
            model: page.model.source.enabled ? page.model.source.networks : []
            delegate: SelectableMenuItem {
                required property var modelData
                width: networks.width
                tokens: page.tokens
                title: modelData.name
                subtitle: page.model.describe(modelData)
                iconName: "wifi"
                selected: page.model.selected === modelData || modelData.connected
                enabled: !page.model.source.busy
                onClicked: page.model.select(modelData)
            }

            StatusLabel {
                anchors.centerIn: parent
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                tokens: page.tokens
                visible: networks.count === 0
                text: !page.model.source.available ? "No Wi-Fi adapter" : !page.model.source.hardwareEnabled ? "Wi-Fi is blocked by hardware" : !page.model.source.enabled ? "Wi-Fi is off" : "Looking for nearby networks…"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: page.model.selected !== null
            spacing: 6

            InputField {
                id: password
                Layout.fillWidth: true
                visible: page.model.passwordNeeded
                tokens: page.tokens
                placeholderText: "Wi-Fi password"
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                onAccepted: {
                    if (text.length > 0) {
                        page.model.connect(text);
                        clear();
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                TextButton {
                    tokens: page.tokens
                    text: page.model.selected?.connected ? "Disconnect" : "Connect"
                    visible: !page.model.source.needsSetup(page.model.selected)
                    enabled: !page.model.source.busy && (!page.model.passwordNeeded || password.text.length > 0)
                    onClicked: {
                        if (page.model.selected.connected)
                            page.model.source.disconnect(page.model.selected);
                        else
                            page.model.connect(password.text);
                        password.clear();
                    }
                }

                TextButton {
                    tokens: page.tokens
                    text: "Network Settings"
                    visible: page.model.source.needsSetup(page.model.selected)
                    onClicked: {
                        page.closeRequested();
                        page.model.source.openSettings();
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                TextButton {
                    tokens: page.tokens
                    text: page.model.confirmForget ? "Confirm forget" : "Forget"
                    visible: page.model.selected !== null && page.model.selected.known && !page.model.selected.connected
                    enabled: !page.model.source.busy
                    onClicked: page.model.forget()
                }
            }
        }
    }
}
