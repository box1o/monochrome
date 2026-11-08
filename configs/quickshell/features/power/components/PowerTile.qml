import QtQuick
import QtQuick.Controls
import "../../../components/controls"
import "../../../components/icons"

AbstractButton {
    id: tile

    required property QtObject source
    required property QtObject tokens

    signal openRequested

    implicitWidth: 78
    implicitHeight: 86
    padding: 10
    hoverEnabled: true
    Accessible.name: (source.ready ? source.percentage + "% · " : "") + (source.connected ? "On AC" : "On battery") + " · " + source.profileName
    onClicked: openRequested()

    ButtonTooltip {
        parent: tile
        tokens: tile.tokens
        text: tile.Accessible.name
        visible: tile.hovered && tile.visible && !tile.down
    }

    background: Rectangle {
        radius: tile.tokens.radius + 5
        color: tile.down ? Qt.darker(tile.tokens.foreground, 1.06) : tile.tokens.foreground
        border.width: tile.visualFocus ? 1 : 0
        border.color: tile.tokens.muted
    }

    contentItem: Item {
        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 3
            spacing: 6

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 30
                height: width
                radius: width / 2
                color: tile.tokens.background

                GlyphIcon {
                    anchors.fill: parent
                    glyph: String.fromCodePoint(tile.source.connected ? 0xF0241 : 0xF0079)
                    fontFamily: tile.tokens.monoFamily
                    pixelSize: 18
                    color: tile.tokens.foreground
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: tile.source.ready ? tile.source.percentage + "%" : "--"
                textFormat: Text.PlainText
                color: tile.tokens.background
                font.family: tile.tokens.monoFamily
                font.pixelSize: tile.tokens.fontSize - 2
                font.bold: true
            }
        }
    }
}
