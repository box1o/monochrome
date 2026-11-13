import QtQuick

TextButton {
    id: button

    property bool active: false
    property color accentColor: tokens.blue

    implicitHeight: tokens.buttonSize + tokens.px(4)
    selected: active
    textColor: enabled ? (active ? accentColor : tokens.foreground) : tokens.muted

    background: Rectangle {
        radius: height / 2
        color: button.tokens.alpha(button.active ? button.accentColor : button.tokens.foreground, button.down ? 0.2 : button.hovered ? 0.14 : 0.08)
        border.width: 1
        border.color: button.visualFocus ? button.accentColor : button.active ? button.tokens.alpha(button.accentColor, 0.3) : button.tokens.cardBorder

        Behavior on color {
            ColorAnimation {
                duration: button.tokens.motionEnabled ? button.tokens.fastDuration : 0
            }

        }

    }

}
