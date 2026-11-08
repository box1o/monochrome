import QtQuick

Rectangle {
    required property QtObject tokens

    implicitHeight: 54
    radius: tokens.radius + 5
    color: tokens.alpha(tokens.foreground, 0.025)
    border.width: 1
    border.color: tokens.alpha(tokens.foreground, 0.07)
}
