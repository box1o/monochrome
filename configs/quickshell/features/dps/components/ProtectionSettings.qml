import "../../../components/controls"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: panel

    required property QtObject tokens
    required property QtObject model
    readonly property QtObject source: model.source

    spacing: tokens.px(8)

    Repeater {
        model: panel.model.fields

        RowLayout {
            id: row

            required property var modelData
            readonly property bool dirty: panel.model.dirty(modelData.key)

            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: row.modelData.title
                color: panel.tokens.muted
                font.family: panel.tokens.fontFamily
                font.pixelSize: panel.tokens.labelSize
            }

            NumberField {
                id: editor

                tokens: panel.tokens
                value: panel.model.value(row.modelData.key)
                maximum: Number(panel.source.values[row.modelData.limit]) || 10000
                unit: row.modelData.unit
                enabled: panel.source.writable && !panel.source.busy && maximum > 0
                onEdited: (next) => {
                    return panel.model.stage(row.modelData.key, next);
                }
            }

            Text {
                Layout.preferredWidth: tokens.px(22)
                text: row.modelData.unit
                color: panel.tokens.muted
                font.family: panel.tokens.monoFamily
                font.pixelSize: panel.tokens.detailSize
            }

            TextButton {
                tokens: panel.tokens
                text: "Apply"
                textColor: panel.tokens.blue
                enabled: row.dirty && panel.source.writable && !panel.source.busy
                onClicked: panel.model.apply(row.modelData.key)
            }

        }

    }

}
