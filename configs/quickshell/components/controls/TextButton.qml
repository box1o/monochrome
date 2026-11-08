import QtQuick
import QtQuick.Controls

Button {
    id: button

    required property QtObject tokens
    property string description: text
    property color textColor: tokens.foreground

    implicitWidth: Math.max(32, label.implicitWidth + 20)
    implicitHeight: 26
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
        color: button.down ? Qt.rgba(1, 1, 1, 0.16) : button.hovered ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        border.width: button.visualFocus ? 1 : 0
        border.color: button.textColor
    }

    contentItem: Text {
        id: label

        text: button.text
        textFormat: Text.PlainText
        color: button.textColor
        font.family: button.tokens.fontFamily
        font.pixelSize: button.tokens.fontSize - 3
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
