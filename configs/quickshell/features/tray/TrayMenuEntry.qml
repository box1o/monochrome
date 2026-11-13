import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

AbstractButton {
    id: row

    required property QtObject entry
    required property QtObject tokens

    implicitHeight: entry.isSeparator ? 0 : tokens.px(36)
    visible: !entry.isSeparator
    enabled: entry.enabled && !entry.isSeparator
    hoverEnabled: true
    padding: tokens.px(8)
    Accessible.ignored: entry.isSeparator
    Accessible.name: entry.text.replace(/&&|&/g, marker => marker === "&&" ? "&" : "")

    background: Rectangle {
        radius: row.tokens.radius_small + tokens.px(3)
        color: row.down ? row.tokens.pressedBackground : row.hovered ? row.tokens.hoverBackground : "transparent"
        border.width: row.visualFocus ? 1 : 0
        border.color: row.tokens.focusColor
    }

    contentItem: RowLayout {
        visible: !row.entry.isSeparator
        spacing: tokens.px(9)

        Text {
            visible: row.entry.buttonType !== QsMenuButtonType.None
            text: row.entry.checkState === Qt.Checked ? "✓" : "○"
            color: row.tokens.foreground
            font.pixelSize: tokens.textSize(12)
        }

        Image {
            visible: source.toString().length > 0
            Layout.preferredWidth: tokens.px(16)
            Layout.preferredHeight: tokens.px(16)
            source: row.entry.icon
            fillMode: Image.PreserveAspectFit
        }

        Text {
            Layout.fillWidth: true
            text: row.Accessible.name
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: row.enabled ? row.tokens.foreground : row.tokens.muted
            font.family: row.tokens.fontFamily
            font.pixelSize: row.tokens.labelSize
        }

        Text {
            visible: row.entry.hasChildren
            text: "›"
            color: row.tokens.muted
            font.pixelSize: tokens.textSize(18)
        }
    }
}
