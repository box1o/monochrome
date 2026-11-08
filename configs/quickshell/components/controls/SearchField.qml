import QtQuick
import "../icons"

InputField {
    id: field

    leftPadding: 36

    AssetIcon {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        name: "search"
        color: field.tokens.muted
    }
}
