import QtQuick
import QtQuick.Layouts
import "../../../components/controls"

Item {
    id: navigation

    required property QtObject tokens
    required property string title

    signal previousRequested()
    signal nextRequested()
    signal todayRequested()

    implicitHeight: tokens.px(26)

    TextButton {
        anchors.left: parent.left
        tokens: navigation.tokens
        text: "‹"
        description: "Previous month"
        onClicked: navigation.previousRequested()
    }

    Text {
        font.family: navigation.tokens.fontFamily
        font.bold: true
        anchors.centerIn: parent
        text: navigation.title
        color: navigation.tokens.foreground
        font.pixelSize: navigation.tokens.bodySize
    }

    RowLayout {
        anchors.right: parent.right
        spacing: tokens.px(6)

        TextButton {
            tokens: navigation.tokens
            text: "Today"
            onClicked: navigation.todayRequested()
        }

        TextButton {
            tokens: navigation.tokens
            text: "›"
            description: "Next month"
            onClicked: navigation.nextRequested()
        }
    }
}
