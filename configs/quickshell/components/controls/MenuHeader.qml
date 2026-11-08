import QtQuick
import QtQuick.Layouts

RowLayout {
    id: header

    required property QtObject tokens
    required property string title
    property Component action: null

    signal backRequested()

    spacing: header.tokens.spacing

    IconButton {
        tokens: header.tokens
        iconName: "chevron-left"
        description: "Back"
        onClicked: header.backRequested()
    }

    Text {
        Layout.fillWidth: true
        text: header.title
        textFormat: Text.PlainText
        elide: Text.ElideRight
        color: header.tokens.foreground
        font.family: header.tokens.fontFamily
        font.pixelSize: header.tokens.bodySize
    }

    Loader {
        sourceComponent: header.action
        visible: item !== null
    }
}
