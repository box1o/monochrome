import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: page

    required property QtObject source

    signal backRequested()

    contentItem: content

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: page.tokens.spacing

        MenuHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            title: "Notifications"
            onBackRequested: page.backRequested()

            action: TextButton {
                tokens: page.tokens
                text: "Clear"
                visible: page.source.count > 0
                textColor: page.tokens.muted
                onClicked: page.source.clear()
            }
        }

        MenuList {
            motionEnabled: page.tokens.motionEnabled
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: tokens.px(9)
            model: page.source.entries

            Text {
                anchors.top: parent.top
                anchors.topMargin: tokens.px(10)
                anchors.horizontalCenter: parent.horizontalCenter
                visible: page.source.count === 0
                text: "Nothing yet"
                color: page.tokens.muted
                font.family: page.tokens.fontFamily
                font.pixelSize: page.tokens.bodySize
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOff
            }

            ScrollBar.horizontal: ScrollBar {
                policy: ScrollBar.AlwaysOff
            }

            delegate: NotificationCard {
                required property var modelData

                width: ListView.view.width
                notification: modelData
                tokens: page.tokens
                imageSource: page.source.iconFor(modelData)
                onActivated: {
                    if (page.source.activate(modelData))
                        page.closeRequested();
                }
            }
        }
    }
}
