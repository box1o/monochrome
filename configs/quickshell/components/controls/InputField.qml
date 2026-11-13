import QtQuick
import QtQuick.Controls

TextField {
    id: field

    required property QtObject tokens

    implicitHeight: tokens.fieldHeight
    selectByMouse: true
    color: tokens.foreground
    placeholderTextColor: tokens.muted
    selectionColor: tokens.accent
    selectedTextColor: tokens.on_accent
    font.family: tokens.fontFamily
    font.pixelSize: tokens.bodySize
    leftPadding: tokens.px(14)
    rightPadding: tokens.px(14)
    Accessible.name: placeholderText

    background: Rectangle {
        radius: height / 2
        color: field.tokens.controlBackground
        border.width: 1
        border.color: field.activeFocus ? field.tokens.alpha(field.tokens.focusColor, 0.55) : field.tokens.cardBorder

        Behavior on border.color {
            ColorAnimation {
                duration: field.tokens.motionEnabled ? field.tokens.fastDuration : 0
            }
        }
    }
}
