import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/icons"

QuickActionButton {
    id: button

    required property string title
    property bool current: false

    padding: tokens.px(10)
    description: active ? "Confirm " + title.toLowerCase() : title
    color: active || current ? tokens.foreground : tokens.muted

    contentItem: ColumnLayout {
        spacing: button.tokens.spacing

        AssetIcon {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: tokens.px(23)
            Layout.preferredHeight: tokens.px(23)
            name: button.iconName
            color: button.color
        }

        Text {
            Layout.fillWidth: true
            text: button.title
            horizontalAlignment: Text.AlignHCenter
            color: button.color
            font.family: button.tokens.fontFamily
            font.pixelSize: button.tokens.detailSize
        }
    }
}
