import QtQuick
import QtQuick.Layouts
import "components"
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: launcher

    required property QtObject model

    onActiveChanged: {
        if (active) {
            Qt.callLater(() => {
                if (launcher.active)
                    search.forceActiveFocus();
            });
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        SearchField {
            id: search

            Layout.fillWidth: true
            tokens: launcher.tokens
            placeholderText: "Search applications"
            text: launcher.model.query
            onTextEdited: launcher.model.query = text
            Keys.onUpPressed: launcher.model.moveSelection(-1)
            Keys.onDownPressed: launcher.model.moveSelection(1)
            onAccepted: launcher.model.launch()
        }

        ListView {
            id: results

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            model: launcher.model.results
            currentIndex: launcher.model.selectedIndex
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
            boundsBehavior: Flickable.StopAtBounds

            Text {
                anchors.centerIn: parent
                visible: results.count === 0
                text: launcher.model.query.trim() ? "No applications found" : "No applications available"
                color: launcher.tokens.muted
                font.family: launcher.tokens.fontFamily
                font.pixelSize: launcher.tokens.fontSize - 2
            }

            delegate: ApplicationRow {
                required property var modelData
                required property int index

                width: results.width
                application: modelData
                tokens: launcher.tokens
                selected: index === results.currentIndex
                onClicked: launcher.model.launch(index)
            }
        }
    }
}
