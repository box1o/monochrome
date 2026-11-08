import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/controls"
import "../../../components/icons"

AbstractButton {
    id: tile

    required property QtObject source
    required property QtObject tokens
    property bool compact: false
    readonly property var levelGlyphs: [0xF008E, 0xF007A, 0xF007B, 0xF007C, 0xF007D, 0xF007E, 0xF007F, 0xF0080, 0xF0081, 0xF0082, 0xF0079]
    readonly property string batteryGlyph: String.fromCodePoint(source.charging ? 0xF0241
        : levelGlyphs[Math.max(0, Math.min(10, Math.round(source.percentage / 10)))])

    signal openRequested()

    implicitHeight: 64
    padding: 0
    hoverEnabled: true
    Accessible.name: "Power profiles · " + source.profileName
    onClicked: openRequested()

    ButtonTooltip {
        parent: tile
        tokens: tile.tokens
        text: tile.Accessible.name
        visible: tile.hovered && tile.visible && !tile.down
    }

    background: Rectangle {
        radius: tile.tokens.radius + 5
        color: tile.tokens.foreground
        border.width: tile.visualFocus ? 1 : 0
        border.color: tile.tokens.muted
    }

    contentItem: RowLayout {
        spacing: tile.compact ? 4 : 9

        Rectangle {
            Layout.preferredWidth: tile.compact ? 22 : 38
            Layout.preferredHeight: tile.compact ? 22 : 38
            Layout.leftMargin: tile.compact ? 6 : 9
            radius: width / 2
            color: tile.tokens.background

            GlyphIcon {
                anchors.centerIn: parent
                width: 18
                height: 18
                glyph: tile.batteryGlyph
                fontFamily: tile.tokens.monoFamily
                pixelSize: tile.compact ? 14 : 17
                color: tile.tokens.foreground
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.rightMargin: 9
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: tile.source.ready ? tile.source.percentage + "%" + (tile.compact ? (tile.source.connected ? " · On AC" : " · Battery") : "") : "Power"
                color: tile.tokens.background
                font.family: tile.tokens.monoFamily
                font.pixelSize: tile.tokens.fontSize - (tile.compact ? 4 : 2)
                font.bold: true
            }

            Text {
                visible: !tile.compact
                Layout.fillWidth: true
                text: tile.source.connected ? "AC" : tile.compact ? "Battery" : "On battery"
                color: tile.tokens.alpha(tile.tokens.background, 0.6)
                font.family: tile.tokens.monoFamily
                font.pixelSize: tile.tokens.fontSize - 4
            }
        }
    }
}
