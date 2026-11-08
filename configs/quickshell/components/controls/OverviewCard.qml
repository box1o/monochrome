import QtQuick

Rectangle {
    required property QtObject tokens

    implicitHeight: tokens.cardHeight
    radius: tokens.cardRadius
    color: tokens.cardBackground
    border.width: 1
    border.color: tokens.cardBorder
}
