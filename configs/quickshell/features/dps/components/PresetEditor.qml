import "../../../components/controls"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: editor

    required property QtObject tokens
    required property QtObject model

    spacing: tokens.px(8)

    RowLayout {
        Layout.fillWidth: true

        Text {
            Layout.fillWidth: true
            text: "Edit preset " + editor.model.editingPreset
            color: editor.tokens.foreground
            font.family: editor.tokens.fontFamily
            font.pixelSize: editor.tokens.labelSize
        }

        TextButton {
            tokens: editor.tokens
            text: "Cancel"
            enabled: !editor.model.source.busy
            onClicked: editor.model.editingPreset = 0
        }

        StateButton {
            tokens: editor.tokens
            text: "Save"
            active: true
            enabled: editor.model.source.writable && !editor.model.source.busy && editor.model.presetVoltage <= editor.model.control.maxVoltage && editor.model.presetCurrent <= editor.model.control.maxCurrent
            onClicked: editor.model.savePreset()
        }

    }

    RowLayout {
        Layout.fillWidth: true
        spacing: tokens.px(12)

        NumberField {
            Layout.fillWidth: true
            tokens: editor.tokens
            value: editor.model.presetVoltage
            maximum: editor.model.control.maxVoltage
            enabled: !editor.model.source.busy
            onEdited: (next) => {
                return editor.model.presetVoltage = next;
            }
        }

        Text {
            text: "V"
            color: editor.tokens.blue
            font.family: editor.tokens.monoFamily
            font.pixelSize: editor.tokens.labelSize
        }

        NumberField {
            Layout.fillWidth: true
            tokens: editor.tokens
            unit: "A"
            decimals: 3
            tint: editor.tokens.magenta
            value: editor.model.presetCurrent
            maximum: editor.model.control.maxCurrent
            enabled: !editor.model.source.busy
            onEdited: (next) => {
                return editor.model.presetCurrent = next;
            }
        }

        Text {
            text: "A"
            color: editor.tokens.magenta
            font.family: editor.tokens.monoFamily
            font.pixelSize: editor.tokens.labelSize
        }

    }

}
