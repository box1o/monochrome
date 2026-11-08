import QtQuick
import QtQuick.Layouts
import "../../../components/controls"

Flickable {
    id: profiles
    implicitHeight: Math.max(36, contentHeight)

    required property QtObject source
    required property QtObject tokens
    contentHeight: content.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: content
        width: profiles.width
        spacing: 6
        Repeater {
            model: profiles.source.cards
            ColumnLayout {
                id: card
                required property var modelData
                Layout.fillWidth: true
                spacing: 2
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 4
                    spacing: 10
                    Text {
                        text: "Sound codec"
                        color: profiles.tokens.foreground
                        font.family: profiles.tokens.fontFamily
                        font.pixelSize: profiles.tokens.fontSize - 3
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                        text: card.modelData.title
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: profiles.tokens.muted
                        font.family: profiles.tokens.fontFamily
                        font.pixelSize: profiles.tokens.fontSize - 4
                    }
                }

                Repeater {
                    model: card.modelData.profiles
                    SelectableMenuItem {
                        required property var modelData
                        Layout.fillWidth: true
                        tokens: profiles.tokens
                        title: modelData.title
                        subtitle: modelData.description
                        iconName: "headphones"
                        selected: card.modelData.current === modelData.name
                        enabled: !profiles.source.busy
                        onClicked: profiles.source.select(card.modelData.name, modelData.name)
                    }
                }
            }
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: profiles.tokens
            text: "Connect Bluetooth headphones to choose a codec."
            visible: profiles.source.cards.length === 0
        }
    }
}
