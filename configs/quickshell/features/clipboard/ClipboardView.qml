import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: page

    required property QtObject model

    signal backRequested()

    initialFocusItem: search
    contentItem: content

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: page.tokens.spacing

        MenuHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            title: "Clipboard"
            onBackRequested: page.backRequested()

            action: TextButton {
                tokens: page.tokens
                text: "Clear"
                visible: page.model.source.entries.length > 0
                enabled: !page.model.source.busy
                onClicked: page.model.source.perform("clear")
            }
        }

        SearchField {
            id: search

            Layout.fillWidth: true
            tokens: page.tokens
            placeholderText: "Search clipboard"
            text: page.model.query
            onTextEdited: page.model.query = text
            onAccepted: page.model.copy()
            Keys.onDownPressed: page.model.moveSelection(1)
            Keys.onUpPressed: page.model.moveSelection(-1)
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            text: page.model.source.error
            error: true
        }

        MenuList {
            id: history

            motionEnabled: page.tokens.motionEnabled
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: page.model.results
            currentIndex: page.model.selectedIndex
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
            spacing: 3

            StatusLabel {
                anchors.centerIn: parent
                tokens: page.tokens
                text: page.model.query ? "Nothing found" : "Clipboard is empty"
                visible: history.count === 0
            }

            delegate: RowLayout {
                required property var modelData
                required property int index

                width: history.width
                height: 40
                spacing: 2

                SelectableMenuItem {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    tokens: page.tokens
                    title: modelData.image ? "Image" : modelData.preview
                    iconName: "copy"
                    selected: index === page.model.selectedIndex
                    enabled: !page.model.source.busy
                    onClicked: page.model.copy(index)
                }

                IconButton {
                    tokens: page.tokens
                    iconName: "trash"
                    description: "Delete entry"
                    enabled: !page.model.source.busy
                    onClicked: page.model.source.perform("delete", modelData.id)
                }
            }
        }
    }
}
