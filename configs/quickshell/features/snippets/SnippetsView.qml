import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"
import "components"

MenuPage {
    id: page

    required property QtObject model
    readonly property int columns: width >= 600 ? 3 : 2

    signal backRequested()

    initialFocusItem: model.editing ? editor.initialFocusItem : search
    contentItem: model.editing ? editor : content

    Shortcut {
        sequence: "Ctrl+V"
        enabled: page.active && !page.model.editing && !page.model.source.busy
        onActivated: page.model.source.add()
    }

    SnippetEditor {
        id: editor

        anchors.fill: parent
        visible: page.model.editing
        tokens: page.tokens
        model: page.model
    }

    ColumnLayout {
        id: content

        visible: !page.model.editing
        anchors.fill: parent
        spacing: page.tokens.spacing

        MenuHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            title: "Snippets"
            onBackRequested: page.backRequested()

            action: IconButton {
                tokens: page.tokens
                iconName: "pencil"
                description: "Edit snippets in Neovim"
                enabled: !page.model.source.busy
                onClicked: page.model.source.edit()
            }
        }

        SearchField {
            id: search

            Layout.fillWidth: true
            tokens: page.tokens
            placeholderText: "Search snippets"
            text: page.model.query
            onTextEdited: page.model.query = text
            onAccepted: page.model.copy()
            Keys.priority: Keys.BeforeItem
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_V && (event.modifiers & Qt.ControlModifier)) {
                    event.accepted = true;
                    page.model.source.add();
                }
            }
            Keys.onDownPressed: page.model.moveSelection(page.columns)
            Keys.onUpPressed: page.model.moveSelection(-page.columns)
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            text: page.model.source.error
            error: true
        }

        GridView {
            id: cards

            objectName: "snippetGrid"
            Layout.fillWidth: true
            Layout.preferredHeight: page.model.source.loaded ? Math.min(3 * cellHeight, Math.max(48, Math.ceil(count / page.columns) * cellHeight)) : 3 * cellHeight
            implicitHeight: Layout.preferredHeight
            clip: true
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            cellWidth: width / page.columns
            cellHeight: (cellWidth - 8) / 1.8 + 8
            model: page.model.results
            currentIndex: page.model.selectedIndex
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)

            ScrollMotion {
                motionEnabled: page.tokens.motionEnabled
            }

            StatusLabel {
                anchors.centerIn: parent
                tokens: page.tokens
                text: page.model.source.busy ? "Loading snippets…" : "No matching snippets"
                visible: cards.count === 0
            }

            delegate: Item {
                required property var modelData
                required property int index

                width: cards.cellWidth
                height: cards.cellHeight

                SnippetCard {
                    anchors.fill: parent
                    anchors.rightMargin: index % page.columns < page.columns - 1 ? 4 : 0
                    anchors.leftMargin: index % page.columns > 0 ? 4 : 0
                    anchors.bottomMargin: 8
                    tokens: page.tokens
                    entry: modelData
                    selected: index === page.model.selectedIndex
                    busy: page.model.source.busy || !page.model.source.available
                    onEditRequested: page.model.openEditor(modelData)
                    onDeleteRequested: page.model.source.remove(modelData.id)
                    onCopyRequested: {
                        page.model.selectedIndex = index;
                        page.model.copy();
                    }
                }
            }
        }
    }
}
