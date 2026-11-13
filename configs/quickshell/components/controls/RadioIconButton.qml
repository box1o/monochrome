import QtQuick
import "../icons"

IconButton {
    id: button

    required property bool active
    required property string radioIcon

    iconName: radioIcon
    padding: tokens.px(7)
    color: active ? tokens.green : tokens.alpha(tokens.red, 0.75)

    Behavior on color {
        ColorAnimation {
            duration: button.tokens.motionEnabled ? button.tokens.normalDuration : 0
            easing.type: Easing.OutCubic
        }
    }

    background: Rectangle {
        radius: width / 2
        color: button.tokens.alpha(button.color, button.active ? (button.hovered ? 0.2 : 0.13) : (button.hovered ? 0.1 : 0.04))
        border.width: button.visualFocus ? 1 : 0
        border.color: button.tokens.border

        Behavior on color {
            ColorAnimation {
                duration: button.tokens.motionEnabled ? button.tokens.normalDuration : 0
            }
        }
    }

    contentItem: Item {
        AssetIcon {
            anchors.fill: parent
            name: button.radioIcon
            color: button.color
            opacity: button.active ? 1 : 0
            scale: button.active ? 1 : 0.85

            Behavior on opacity {
                NumberAnimation {
                    duration: button.tokens.motionEnabled ? button.tokens.fastDuration : 0
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: button.tokens.motionEnabled ? button.tokens.normalDuration : 0
                    easing.type: Easing.OutCubic
                }
            }
        }

        AssetIcon {
            anchors.fill: parent
            name: button.radioIcon + "-off"
            color: button.color
            opacity: button.active ? 0 : 1
            scale: button.active ? 0.85 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: button.tokens.motionEnabled ? button.tokens.fastDuration : 0
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: button.tokens.motionEnabled ? button.tokens.normalDuration : 0
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
