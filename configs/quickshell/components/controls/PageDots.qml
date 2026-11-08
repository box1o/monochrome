import QtQuick
import QtQuick.Controls

Row {
    id: dots

    required property QtObject tokens
    required property var labels
    required property int currentIndex
    property bool toggleOnClick: false
    property color color: tokens.foreground

    signal selected(int index)

    Repeater {
        model: dots.labels

        AbstractButton {
            id: button

            required property int index
            required property string modelData

            width: 14
            height: 16
            hoverEnabled: true
            Accessible.name: dots.toggleOnClick ? "Show " + dots.labels[1 - dots.currentIndex] : modelData
            Accessible.role: dots.toggleOnClick ? Accessible.Button : Accessible.PageTab
            Accessible.selected: dots.currentIndex === index
            onClicked: dots.selected(dots.toggleOnClick ? 1 - dots.currentIndex : index)

            ButtonTooltip {
                parent: button
                tokens: dots.tokens
                text: button.Accessible.name
                visible: button.hovered && button.visible && !button.down
            }

            background: Item {}

            contentItem: Item {
                Rectangle {
                    anchors.centerIn: parent
                    width: 5
                    height: 5
                    radius: 2.5
                    color: dots.currentIndex === button.index ? dots.color : dots.tokens.alpha(dots.color, button.hovered ? 0.5 : 0.22)
                    border.width: button.visualFocus ? 1 : 0
                    border.color: dots.color

                    Behavior on color {
                        ColorAnimation {
                            duration: dots.tokens.motionEnabled ? dots.tokens.fastDuration : 0
                        }
                    }
                }
            }
        }
    }
}
