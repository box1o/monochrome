import QtQuick
import QtQuick.Controls
import "../icons"

AbstractButton {
    id: button

    required property QtObject tokens
    required property string iconName
    required property string description
    property color color: tokens.muted
    property bool spinning: false

    implicitWidth: tokens.buttonSize
    implicitHeight: tokens.buttonSize
    padding: 7
    hoverEnabled: true
    Accessible.name: description

    ButtonTooltip {
        parent: button
        tokens: button.tokens
        text: button.description
        visible: button.hovered && button.visible && button.enabled && !button.down && text.length > 0
    }

    background: Rectangle {
        radius: width / 2
        color: button.tokens.alpha(button.color, button.down ? 0.18 : button.hovered ? 0.1 : 0)
        border.width: button.visualFocus ? 1 : 0
        border.color: button.tokens.focusColor

        Behavior on color {
            ColorAnimation {
                duration: button.tokens.motionEnabled ? button.tokens.fastDuration : 0
            }
        }
    }

    contentItem: AssetIcon {
        name: button.iconName
        color: button.enabled ? button.color : button.tokens.alpha(button.color, 0.45)

        RotationAnimator on rotation {
            running: button.spinning && button.tokens.motionEnabled
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
        }
    }
}
