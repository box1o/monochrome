import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: page

    required property QtObject model

    signal backRequested

    Keys.onLeftPressed: model.moveSelection(-1)
    Keys.onRightPressed: model.moveSelection(1)
    Keys.onReturnPressed: model.activateCurrent()
    Keys.onEnterPressed: model.activateCurrent()
    contentItem: content

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: 12

        MenuHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            title: page.model.pending ? "Press again to confirm" : "Power"
            onBackRequested: page.backRequested()
        }

        Row {
            id: actions

            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: page.model.actions

                SessionActionButton {
                    required property var modelData
                    required property int index

                    width: (actions.width - actions.spacing * (page.model.actions.length - 1)) / page.model.actions.length
                    height: width
                    tokens: page.tokens
                    title: modelData.title
                    iconName: modelData.icon
                    active: page.model.pending === modelData.id
                    current: page.model.current === index
                    enabled: !page.model.busy
                    onClicked: page.model.request(modelData.id)
                }
            }
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            text: page.model.error
            error: true
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
