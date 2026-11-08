import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: page

    required property QtObject model

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        MenuHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            title: page.model.title
            onBackRequested: page.model.back()
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: page.model.entries
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOff }
            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }

            delegate: TrayMenuEntry {
                required property var modelData

                width: ListView.view.width
                entry: modelData
                tokens: page.tokens
                onClicked: page.model.activate(modelData)
            }
        }
    }
}
