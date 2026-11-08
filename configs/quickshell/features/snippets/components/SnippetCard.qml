import QtQuick
import QtQuick.Layouts
import "../../../components/controls"
import "../../../components/content"

Rectangle {
    id: card

    required property QtObject tokens
    required property var entry
    property bool selected: false
    property bool busy: false

    signal editRequested()
    signal deleteRequested()
    signal copyRequested()

    objectName: "snippetCard"
    Accessible.name: entry.title
    Accessible.role: Accessible.Button
    radius: tokens.cardRadius
    color: hover.hovered ? tokens.hoverBackground : tokens.cardBackground
    border.width: 1
    border.color: selected ? tokens.alpha(tokens.focusColor, 0.55) : tokens.cardBorder

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent
        enabled: !card.busy
        onClicked: card.copyRequested()
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        enabled: !card.busy
        onTapped: card.editRequested()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 5

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: card.entry.title
                textFormat: Text.PlainText
                color: card.tokens.foreground
                font.family: card.tokens.fontFamily
                font.pixelSize: card.tokens.labelSize
                elide: Text.ElideRight
            }

            IconButton {
                tokens: card.tokens
                objectName: "editSnippet"
                iconName: "pencil"
                description: "Edit snippet"
                implicitWidth: 24
                implicitHeight: 24
                padding: 5
                opacity: hover.hovered || visualFocus ? 1 : 0
                enabled: opacity > 0 && !card.busy
                onClicked: card.editRequested()

                Behavior on opacity {
                    NumberAnimation {
                        duration: card.tokens.motionEnabled ? card.tokens.fastDuration : 0
                    }
                }
            }

            IconButton {
                tokens: card.tokens
                objectName: "deleteSnippet"
                iconName: "trash"
                description: "Delete snippet"
                implicitWidth: 24
                implicitHeight: 24
                padding: 5
                opacity: hover.hovered || visualFocus ? 1 : 0
                enabled: opacity > 0 && !card.busy
                onClicked: card.deleteRequested()

                Behavior on opacity {
                    NumberAnimation {
                        duration: card.tokens.motionEnabled ? card.tokens.fastDuration : 0
                    }
                }
            }
        }

        CodePreview {
            id: code

            Layout.fillWidth: true
            Layout.fillHeight: true
            tokens: card.tokens
            text: card.entry.body
            languageHint: card.entry.language || "auto"
            onClicked: {
                if (!card.busy) {
                    card.copyRequested();
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: code.language
            textFormat: Text.PlainText
            color: card.tokens.muted
            font.family: card.tokens.fontFamily
            font.pixelSize: card.tokens.captionSize
            elide: Text.ElideRight
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: card.tokens.motionEnabled ? card.tokens.fastDuration : 0
        }
    }
}
