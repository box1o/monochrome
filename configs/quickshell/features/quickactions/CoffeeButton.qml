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
    padding: tokens.px(10)
    onClicked: source.toggle()

    background: Rectangle {
        radius: button.tokens.radius_small + tokens.px(6)
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
        spacing: tokens.px(9)

        AssetIcon {
            Layout.preferredWidth: tokens.px(16)
            Layout.preferredHeight: tokens.px(16)
            name: "coffee"
            color: button.color
        }

        Text {
            Layout.fillWidth: true
            text: "Coffee mode"
            color: button.color
            font.family: button.tokens.monoFamily
            font.pixelSize: button.tokens.labelSize
        }

        Rectangle {
            id: track

            readonly property real inset: button.tokens.px(2)

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: tokens.px(30)
            Layout.preferredHeight: tokens.px(16)
            radius: height / 2
            color: button.source.enabled ? button.tokens.foreground : button.tokens.alpha(button.tokens.foreground, 0.14)

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: button.source.enabled ? track.width - width - track.inset : track.inset
                width: track.height - 2 * track.inset
                height: width
                radius: width / 2
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
