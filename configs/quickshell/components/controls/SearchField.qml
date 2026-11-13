import QtQuick
import "../icons"

InputField {
    id: field

    leftPadding: tokens.px(36)

    AssetIcon {
        anchors.left: parent.left
        anchors.leftMargin: tokens.px(12)
        anchors.verticalCenter: parent.verticalCenter
        name: "search"
        color: field.tokens.muted
    }
}
