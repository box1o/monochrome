import "../../../components/controls"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: toolbar

    required property QtObject tokens
    required property QtObject model
    property bool showOutput: true
    readonly property QtObject source: model.source

    spacing: tokens.px(8)

    Text {
        visible: toolbar.showOutput
        text: !toolbar.source.stale && Number.isFinite(toolbar.source.values.power) ? toolbar.source.values.power.toFixed(2) + " W" : "— W"
        color: toolbar.tokens.foreground
        font.family: toolbar.tokens.monoFamily
        font.pixelSize: toolbar.tokens.labelSize
    }

    IconButton {
        tokens: toolbar.tokens
        iconName: toolbar.source.state.readOnly ? "lock-keyhole" : "lock-keyhole-open"
        description: toolbar.source.state.readOnly ? "Unlock controls" : "Lock controls"
        color: toolbar.source.state.readOnly ? toolbar.tokens.yellow : toolbar.tokens.muted
        enabled: toolbar.source.connected && !toolbar.source.busy
        onClicked: toolbar.source.request("access", {
            "readOnly": !toolbar.source.state.readOnly
        }, "access")
    }

    StateIconButton {
        tokens: toolbar.tokens
        iconName: toolbar.source.ready ? "unplug" : "plug"
        spinning: toolbar.source.state.phase === "connecting"
        description: toolbar.source.ready ? "Disconnect device" : "Connect device"
        active: toolbar.source.ready
        enabled: toolbar.source.connected && !toolbar.source.busy && toolbar.source.state.phase !== "connecting"
        onClicked: toolbar.source.request(toolbar.source.ready ? "disconnect" : "connect", {
        }, "connection")
    }

    StateIconButton {
        Layout.rightMargin: toolbar.tokens.sectionSpacing
        tokens: toolbar.tokens
        visible: toolbar.showOutput
        iconName: "power"
        description: toolbar.model.outputOn ? "Turn output off" : "Turn output on"
        active: toolbar.model.outputOn
        accentColor: toolbar.tokens.green
        enabled: toolbar.source.ready && !toolbar.source.busy && (toolbar.model.outputOn || toolbar.source.writable && !toolbar.model.control.dirty && !toolbar.source.values.protection)
        onClicked: toolbar.model.toggleOutput()
    }

}
