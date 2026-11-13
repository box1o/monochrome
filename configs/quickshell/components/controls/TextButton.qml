import QtQuick
import QtQuick.Controls

Button {
    id: button

    required property QtObject tokens
    property string description: text
    property color textColor: tokens.foreground
    property bool selected: false

    implicitWidth: Math.max(tokens.px(32), label.implicitWidth + tokens.px(20))
    implicitHeight: tokens.buttonSize
    hoverEnabled: true
    Accessible.name: description

    ButtonTooltip {
        parent: button
        tokens: button.tokens
        text: button.description
        visible: button.hovered && button.visible && button.enabled && !button.down && text.length > 0 && text !== button.text
    }

    background: Rectangle {
        radius: button.tokens.radius_small
        color: button.down ? button.tokens.pressedBackground : button.selected ? button.tokens.selectionBackground : button.hovered ? button.tokens.hoverBackground : "transparent"
        border.width: button.visualFocus ? 1 : 0
        border.color: button.tokens.focusColor
    }

    contentItem: Text {
        id: label

        text: button.text
        textFormat: Text.PlainText
        color: button.textColor
        font.family: button.tokens.fontFamily
        font.pixelSize: button.tokens.labelSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
