import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/icons"

QuickActionButton {
    id: button

    required property QtObject source

    active: source.enabled
    iconName: "coffee"
    description: source.enabled ? "Allow display sleep" : "Keep display awake"
    padding: 10
    onClicked: source.toggle()

    background: Rectangle {
        radius: button.tokens.radius_small + 6
        color: button.tokens.alpha(button.tokens.foreground, button.active ? 0.16 : button.hovered ? 0.1 : 0.05)
        border.width: 1
        border.color: button.visualFocus ? button.tokens.muted : button.active ? button.tokens.alpha(button.tokens.foreground, 0.4) : button.tokens.border

        Behavior on color {
            ColorAnimation {
                duration: button.tokens.motionEnabled ? button.tokens.fastDuration : 0
            }
        }
    }

    contentItem: RowLayout {
        spacing: 9

        AssetIcon {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            name: "coffee"
            color: button.color
        }

        Text {
            Layout.fillWidth: true
            text: "Coffee mode"
            color: button.color
            font.family: button.tokens.monoFamily
            font.pixelSize: button.tokens.fontSize - 3
        }

        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 16
            radius: 8
            color: button.source.enabled ? button.tokens.foreground : button.tokens.alpha(button.tokens.foreground, 0.14)

            Rectangle {
                x: button.source.enabled ? parent.width - width - 2 : 2
                y: 2
                width: 12
                height: 12
                radius: 6
                color: button.source.enabled ? button.tokens.background : button.tokens.foreground

                Behavior on x {
                    NumberAnimation {
                        duration: button.tokens.motionEnabled ? button.tokens.fastDuration : 0
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
