import QtQuick
import QtQuick.Layouts
import "components"
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: launcher

    required property QtObject model

    initialFocusItem: search
    contentItem: content

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: launcher.tokens.spacing

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

        MenuList {
            id: results

            motionEnabled: launcher.tokens.motionEnabled
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: tokens.px(2)
            model: launcher.model.results
            currentIndex: launcher.model.selectedIndex
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

            Text {
                anchors.centerIn: parent
                visible: results.count === 0
                text: launcher.model.query.trim() ? "No applications found" : "No applications available"
                color: launcher.tokens.muted
                font.family: launcher.tokens.fontFamily
                font.pixelSize: launcher.tokens.bodySize
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
