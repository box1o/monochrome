import QtQuick
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
            title: "Power profiles"
            onBackRequested: page.backRequested()
        }

        Repeater {
            model: page.source.profiles
            SelectableMenuItem {
                required property var modelData
                Layout.fillWidth: true
                tokens: page.tokens
                title: modelData.title
                subtitle: modelData.detail
                iconName: modelData.icon
                selected: page.source.profile === modelData.value
                enabled: !page.source.busy
                onClicked: page.source.selectProfile(modelData.value)
            }
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            text: page.source.error || page.source.limitation
            error: page.source.error.length > 0
        }

        Item { Layout.fillHeight: true }
    }
}
