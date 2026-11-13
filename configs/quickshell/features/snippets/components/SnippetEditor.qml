import QtQuick
import "../../../components/layout"
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/controls"

ColumnLayout {
    id: editor

    required property QtObject tokens
    required property QtObject model
    readonly property alias initialFocusItem: code

    spacing: editor.tokens.spacing
    onVisibleChanged: {
        if (visible)
            Qt.callLater(() => {
            return code.forceActiveFocus();
        });
    }

    Shortcut {
        sequence: "Ctrl+S"
        enabled: editor.visible && editor.model.canSave
        onActivated: editor.model.save()
    }

    MenuHeader {
        Layout.fillWidth: true
        tokens: editor.tokens
        title: "Edit snippet"
        onBackRequested: editor.model.closeEditor()

        action: TextButton {
            tokens: editor.tokens
            text: "Save"
            enabled: editor.model.canSave
            onClicked: editor.model.save()
        }
    }

    InputField {
        Layout.fillWidth: true
        tokens: editor.tokens
        placeholderText: "Snippet title"
        text: editor.model.draftTitle
        enabled: !editor.model.source.busy
        onTextEdited: editor.model.draftTitle = text
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: tokens.px(360)
        color: editor.tokens.cardBackground
        border.width: 1
        border.color: editor.tokens.cardBorder
        radius: editor.tokens.cardRadius
        clip: true

        Flickable {
            id: scroll

            anchors.fill: parent
            anchors.margins: tokens.px(12)
            contentWidth: width
            contentHeight: code.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ScrollMotion {
                motionEnabled: editor.tokens.motionEnabled
            }

            TextArea.flickable: TextArea {
                id: code

                objectName: "snippetEditorText"
                text: editor.model.draftBody
                textFormat: TextEdit.PlainText
                wrapMode: TextEdit.WrapAnywhere
                selectByMouse: true
                persistentSelection: true
                enabled: !editor.model.source.busy
                color: editor.tokens.foreground
                selectionColor: editor.tokens.accent
                selectedTextColor: editor.tokens.on_accent
                font.family: editor.tokens.monoFamily
                font.pixelSize: editor.tokens.labelSize
                padding: 0
                background: null
                onTextChanged: editor.model.draftBody = text
            }
        }
    }

    StatusLabel {
        Layout.fillWidth: true
        tokens: editor.tokens
        text: editor.model.source.error
        error: true
    }

    RowLayout {
        Layout.fillWidth: true

        StatusLabel {
            Layout.fillWidth: true
            tokens: editor.tokens
            text: "Ctrl+S save · Ctrl+C copy selection"
        }

        TextButton {
            tokens: editor.tokens
            text: "Copy all"
            enabled: editor.model.draftBody.length > 0 && !editor.model.source.busy
            onClicked: editor.model.source.copy(editor.model.draftBody)
        }
    }
}
