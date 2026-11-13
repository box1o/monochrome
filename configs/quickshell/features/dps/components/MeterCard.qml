import "../../../components/controls"
import QtQuick
import QtQuick.Layouts

Item {
    id: card

    required property QtObject tokens
    property color accentColor: tokens.blue
    required property string title
    required property string unit
    property real measurement: NaN
    property real value: 0
    property real maximum: 30
    property int decimals: 2
    property real step: 0.1
    property bool editable: true

    signal adjusted(real next)

    implicitHeight: tokens.px(158)

    GridLayout {
        anchors.fill: parent
        anchors.margins: card.tokens.sectionSpacing
        columns: 3
        columnSpacing: tokens.px(16)
        rowSpacing: tokens.px(2)

        Text {
            Layout.row: 0
            Layout.column: 0
            text: card.title
            color: card.accentColor
            font.family: card.tokens.fontFamily
            font.pixelSize: card.tokens.labelSize
        }

        Text {
            Layout.row: 0
            Layout.column: 1
            text: (card.unit === "V" ? "Set" : "Limit") + " · " + card.unit
            color: card.tokens.muted
            font.family: card.tokens.fontFamily
            font.pixelSize: card.tokens.detailSize
        }

        Text {
            Layout.row: 1
            Layout.column: 0
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.alignment: Qt.AlignVCenter
            text: Number.isFinite(card.measurement) ? card.measurement.toFixed(card.decimals) + " " + card.unit : "— " + card.unit
            color: card.accentColor
            font.family: card.tokens.monoFamily
            font.pixelSize: tokens.textSize(52)
            font.weight: Font.Medium
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: tokens.textSize(28)
        }

        NumberField {
            Layout.row: 1
            Layout.column: 1
            Layout.preferredWidth: tokens.px(104)
            Layout.alignment: Qt.AlignVCenter
            tokens: card.tokens
            value: card.value
            maximum: card.maximum
            decimals: card.decimals
            unit: card.unit
            tint: card.accentColor
            enabled: card.editable
            onEdited: (next) => {
                return card.adjusted(next);
            }
        }

        RotaryControl {
            Layout.row: 1
            Layout.column: 2
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            tokens: card.tokens
            description: card.title
            accentColor: card.accentColor
            from: 0
            to: card.maximum
            value: card.value
            stepSize: card.step
            enabled: card.editable && card.maximum > 0
            onAdjusted: (next) => {
                return card.adjusted(next);
            }
        }

        RowLayout {
            Layout.row: 2
            Layout.column: 2
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            TextButton {
                tokens: card.tokens
                text: "−"
                description: "Decrease " + card.title.toLowerCase()
                enabled: card.editable && card.value > 0
                autoRepeat: true
                onClicked: card.adjusted(Math.max(0, card.value - card.step))
            }

            TextButton {
                tokens: card.tokens
                text: "+"
                description: "Increase " + card.title.toLowerCase()
                enabled: card.editable && card.value < card.maximum
                autoRepeat: true
                onClicked: card.adjusted(Math.min(card.maximum, card.value + card.step))
            }

        }

    }

}
