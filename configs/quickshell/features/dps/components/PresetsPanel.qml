import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: panel

    required property QtObject tokens
    required property QtObject model

    spacing: tokens.sectionSpacing

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: tokens.px(4)
        columnSpacing: panel.tokens.spacing

        Repeater {
            model: 6

            PresetTile {
                required property int index

                Layout.fillWidth: true
                tokens: panel.tokens
                number: index + 1
                preset: panel.model.preset(number)
                selected: panel.model.selectedPreset === number
                editing: panel.model.editingPreset === number
                enabled: preset.loaded && panel.model.source.writable && !panel.model.source.busy
                editable: enabled
                onClicked: panel.model.loadPreset(number)
                onEditRequested: panel.model.editPreset(number)
            }

        }

    }

    PresetEditor {
        Layout.fillWidth: true
        visible: panel.model.editingPreset > 0
        tokens: panel.tokens
        model: panel.model
    }

}
