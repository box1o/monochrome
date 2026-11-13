import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../../components/controls"
import "../../components/icons"

AbstractButton {
    id: card

    required property QtObject notification
    required property QtObject tokens
    property string imageSource: ""
    readonly property bool urgent: notification.urgency === NotificationUrgency.Critical

    signal activated()

    implicitHeight: content.implicitHeight + 2 * tokens.sectionSpacing
    padding: 0
    hoverEnabled: true
    Accessible.name: notification.appName + ": " + notification.summary
    onClicked: activated()

    background: Rectangle {
        radius: card.tokens.radius
        color: card.hovered ? card.tokens.hoverBackground : card.tokens.cardBackground
        border.width: 1
        border.color: card.visualFocus ? card.tokens.focusColor : card.urgent ? card.tokens.alpha(card.tokens.red, 0.35) : card.tokens.cardBorder
    }

    contentItem: RowLayout {
        id: content

        anchors.fill: parent
        anchors.margins: card.tokens.sectionSpacing
        spacing: tokens.px(10)

        Item {
            Layout.preferredWidth: tokens.px(20)
            Layout.preferredHeight: tokens.px(20)
            Layout.alignment: Qt.AlignTop

            Image {
                id: icon

                anchors.fill: parent
                source: card.imageSource
                sourceSize.width: 40
                sourceSize.height: 40
                fillMode: Image.PreserveAspectFit
            }

            AssetIcon {
                anchors.fill: parent
                name: "bell"
                visible: icon.status !== Image.Ready
                color: card.urgent ? card.tokens.red : card.tokens.muted
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: tokens.px(3)

            Text {
                Layout.fillWidth: true
                text: card.notification.summary
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: card.tokens.foreground
                font.family: card.tokens.fontFamily
                font.pixelSize: card.tokens.bodySize
                font.weight: Font.Medium
            }

            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: card.notification.body
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: card.tokens.muted
                font.family: card.tokens.fontFamily
                font.pixelSize: card.tokens.detailSize
            }

            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: card.notification.appName
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: card.tokens.muted
                font.family: card.tokens.fontFamily
                font.pixelSize: card.tokens.captionSize
            }
        }

        IconButton {
            id: dismiss

            Layout.alignment: Qt.AlignTop
            tokens: card.tokens
            implicitWidth: tokens.px(24)
            implicitHeight: tokens.px(24)
            padding: 0
            iconName: ""
            description: "Dismiss notification"
            onClicked: card.notification.dismiss()

            background: Item {
            }

            contentItem: Text {
                text: "×"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: dismiss.hovered || dismiss.visualFocus ? card.tokens.foreground : card.tokens.muted
                font.family: card.tokens.fontFamily
                font.pixelSize: card.tokens.fontSize
            }
        }
    }
}
