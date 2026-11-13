import QtQuick

IconButton {
    id: button

    property bool active: false
    property color accentColor: tokens.blue

    implicitWidth: tokens.px(38)
    implicitHeight: tokens.px(38)
    padding: tokens.px(10)
    color: active ? accentColor : tokens.foreground

    background: Rectangle {
        radius: width / 2
        color: button.tokens.alpha(button.active ? button.accentColor : button.tokens.foreground, button.down ? 0.2 : button.hovered ? 0.14 : 0.08)
        border.width: button.visualFocus ? 1 : 0
        border.color: button.accentColor

        Behavior on color {
            ColorAnimation {
                duration: button.tokens.motionEnabled ? button.tokens.fastDuration : 0
            }

        }

    }

}
