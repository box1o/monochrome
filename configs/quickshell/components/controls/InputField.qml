import QtQuick
import QtQuick.Controls

TextField {
    id: field

    required property QtObject tokens

    implicitHeight: 36
    selectByMouse: true
    color: tokens.foreground
    placeholderTextColor: tokens.muted
    selectionColor: tokens.accent
    selectedTextColor: tokens.on_accent
    font.family: tokens.fontFamily
    font.pixelSize: tokens.fontSize - 2
    leftPadding: 14
    rightPadding: 14
    Accessible.name: placeholderText

    background: Rectangle {
        radius: height / 2
        color: field.tokens.alpha(field.tokens.foreground, 0.025)
        border.width: 1
        border.color: field.tokens.alpha(field.tokens.foreground, field.activeFocus ? 0.18 : 0.08)

        Behavior on border.color {
            ColorAnimation {
                duration: field.tokens.motionEnabled ? field.tokens.fastDuration : 0
            }
        }
    }
}
