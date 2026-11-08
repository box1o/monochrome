import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: page

    required property QtObject source

    signal backRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

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

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOff }
            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }
            spacing: 9
            model: page.source.entries

            Text {
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                visible: page.source.count === 0
                text: "Nothing yet"
                color: page.tokens.muted
                font.family: page.tokens.fontFamily
                font.pixelSize: page.tokens.fontSize - 2
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
