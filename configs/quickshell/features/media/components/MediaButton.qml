import QtQuick
import "../../../components/controls"

IconButton {
    id: button

    property bool primary: false

    implicitWidth: primary ? 32 : 26
    implicitHeight: implicitWidth
    padding: primary ? 9 : 6
    color: primary ? tokens.background : tokens.foreground
    scale: down ? 0.94 : hovered ? 1.04 : 1

    background: Rectangle {
        radius: width / 2
        color: button.primary ? button.tokens.foreground : button.tokens.alpha(button.tokens.foreground, button.hovered ? 0.14 : 0.07)
        opacity: button.enabled ? 1 : 0.35
        border.width: button.visualFocus ? 1 : 0
        border.color: button.tokens.muted
    }

    Behavior on scale {
        NumberAnimation {
            duration: button.tokens.motionEnabled ? button.tokens.fastDuration : 0
            easing.type: Easing.OutCubic
        }
    }
}
