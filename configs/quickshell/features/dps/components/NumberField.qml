import "../../../components/controls"
import QtQuick

InputField {
    id: field

    property color tint: tokens.blue
    property real value: 0
    property real maximum: 30
    property int decimals: 2
    property string unit: "V"

    signal edited(real next)

    implicitWidth: tokens.px(110)
    implicitHeight: tokens.px(32)
    color: enabled ? tint : tokens.muted
    font.family: tokens.monoFamily
    font.pixelSize: tokens.bodySize
    horizontalAlignment: Text.AlignRight
    text: value.toFixed(decimals)
    placeholderText: unit
    Accessible.name: unit === "V" ? "Voltage" : "Current limit"
    onEditingFinished: {
        if (acceptableInput)
            edited(Number(text));

        text = value.toFixed(decimals);
    }
    onValueChanged: {
        if (!activeFocus)
            text = value.toFixed(decimals);

    }

    background: Rectangle {
        radius: height / 2
        color: field.tokens.alpha(field.tint, field.activeFocus ? 0.12 : 0.06)
        border.width: 1
        border.color: field.activeFocus ? field.tokens.alpha(field.tint, 0.5) : field.tokens.cardBorder
    }

    validator: DoubleValidator {
        bottom: 0
        top: field.maximum
        decimals: field.decimals
        notation: DoubleValidator.StandardNotation
        locale: "C"
    }

}
