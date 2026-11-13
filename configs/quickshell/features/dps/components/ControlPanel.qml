import "../../../components/controls"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: panel

    required property QtObject tokens
    required property QtObject model
    readonly property QtObject source: model.source

    spacing: tokens.spacing

    MeterCard {
        Layout.fillWidth: true
        tokens: panel.tokens
        title: "Voltage"
        unit: "V"
        measurement: panel.source.stale ? NaN : Number(panel.source.values.voltage)
        value: panel.model.control.voltage
        maximum: panel.model.control.maxVoltage
        editable: panel.source.writable
        onAdjusted: (next) => {
            return panel.model.control.setValues(next, panel.model.control.current);
        }
    }

    MeterCard {
        Layout.fillWidth: true
        tokens: panel.tokens
        accentColor: panel.tokens.magenta
        title: "Current"
        unit: "A"
        decimals: 3
        step: 0.01
        measurement: panel.source.stale ? NaN : Number(panel.source.values.current)
        value: panel.model.control.current
        maximum: panel.model.control.maxCurrent
        editable: panel.source.writable
        onAdjusted: (next) => {
            return panel.model.control.setValues(panel.model.control.voltage, next);
        }
    }

    RowLayout {
        visible: panel.model.control.dirty || panel.model.control.sending || panel.model.control.failed
        Layout.fillWidth: true
        spacing: tokens.px(16)

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: panel.model.control.sending || panel.model.control.dirty && !panel.model.control.failed ? "Updating…" : ""
            color: panel.tokens.blue
            font.family: panel.tokens.fontFamily
            font.pixelSize: panel.tokens.detailSize
        }

        TextButton {
            tokens: panel.tokens
            text: "Retry"
            visible: panel.model.control.failed
            enabled: panel.source.writable && !panel.source.busy
            onClicked: panel.model.control.retry()
        }

    }

    StatusLabel {
        Layout.fillWidth: true
        tokens: panel.tokens
        text: panel.model.control.dirty && !panel.model.control.valid ? "Value exceeds the available device range" : ""
        error: true
    }

}
