import "../../../components/controls"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: row

    required property QtObject tokens
    required property string title
    property real value: 0
    property real minimum: 0
    property real maximum: 14

    signal committed(real next)

    spacing: tokens.px(16)

    Text {
        Layout.preferredWidth: tokens.px(100)
        text: row.title
        color: row.tokens.muted
        font.family: row.tokens.fontFamily
        font.pixelSize: row.tokens.labelSize
    }

    LevelSlider {
        id: slider

        Layout.fillWidth: true
        tokens: row.tokens
        description: row.title
        from: row.minimum
        to: row.maximum
        stepSize: 1
        snapMode: LevelSlider.SnapAlways
        value: row.value
        wheelEnabled: false
        onPressedChanged: {
            if (!pressed)
                row.committed(Math.round(value));

        }
        onMoved: {
            if (!pressed)
                row.committed(Math.round(value));

        }
    }

    Text {
        Layout.preferredWidth: tokens.px(28)
        horizontalAlignment: Text.AlignRight
        text: Math.round(slider.value)
        color: row.tokens.foreground
        font.family: row.tokens.monoFamily
        font.pixelSize: row.tokens.labelSize
    }

}
