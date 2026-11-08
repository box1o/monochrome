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
        color: button.down ? button.tokens.pressedBackground : button.active ? button.tokens.selectionBackground : button.hovered ? button.tokens.hoverBackground : button.tokens.cardBackground
        border.width: 1
        border.color: button.visualFocus ? button.tokens.focusColor : button.tokens.cardBorder

        Behavior on color {
            ColorAnimation {
                duration: button.tokens.motionEnabled ? button.tokens.fastDuration : 0
            }
        }
    }
}
