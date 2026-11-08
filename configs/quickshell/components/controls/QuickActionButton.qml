import QtQuick

IconButton {
    id: button

    property bool active: false
    property real cornerRadius: tokens.radius_small + 3

    implicitWidth: 40
    implicitHeight: implicitWidth
    padding: 11
    color: active ? tokens.foreground : tokens.muted

    background: Rectangle {
        radius: button.cornerRadius
        color: button.tokens.alpha(button.tokens.foreground, button.down ? 0.12 : button.active ? 0.09 : button.hovered ? 0.06 : 0.025)
        border.width: 1
        border.color: button.visualFocus ? button.tokens.muted : button.tokens.alpha(button.tokens.foreground, 0.12)

        Behavior on color {
            ColorAnimation {
                duration: button.tokens.motionEnabled ? button.tokens.fastDuration : 0
            }
        }
    }
}
