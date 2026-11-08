import QtQuick
import QtQuick.Layouts
import "../../../components/controls"

RowLayout {
    id: details

    required property QtObject model
    required property QtObject tokens
    readonly property QtObject device: model.selected
    visible: device !== null && !model.source.busy
    spacing: 8

    TextButton {
        tokens: details.tokens
        text: details.device?.connected ? "Disconnect" : details.device?.paired || details.device?.bonded ? "Connect" : "Pair"
        enabled: details.device !== null && !details.device.blocked
        onClicked: details.model.activate()
    }

    Item {
        Layout.fillWidth: true
    }

    TextButton {
        tokens: details.tokens
        text: details.model.confirmForget ? "Confirm forget" : "Forget"
        textColor: details.model.confirmForget ? details.tokens.red : details.tokens.muted
        visible: details.device !== null && !details.device.connected && (details.device.paired || details.device.bonded)
        onClicked: details.model.forget()
    }
}
