import QtQuick
import QtQuick.Controls
import "../../../components/controls"
import "../../../components/icons"

AbstractButton {
    id: tile

    required property QtObject source
    required property QtObject tokens

    signal openRequested()

    implicitWidth: tokens.px(78)
    implicitHeight: tokens.px(86)
    padding: tokens.px(10)
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
        radius: tile.tokens.cardRadius
        color: tile.down ? Qt.darker(tile.tokens.foreground, 1.06) : tile.tokens.foreground
        border.width: tile.visualFocus ? 1 : 0
        border.color: tile.tokens.focusColor
    }

    contentItem: Item {
        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: tokens.px(3)
            spacing: tokens.px(6)

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: tokens.px(30)
                height: width
                radius: width / 2
                color: tile.tokens.onFill

                GlyphIcon {
                    anchors.fill: parent
                    glyph: String.fromCodePoint(tile.source.connected ? 983617 : 983161)
                    fontFamily: tile.tokens.monoFamily
                    pixelSize: tokens.textSize(18)
                    color: tile.tokens.foreground
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: tile.source.ready ? tile.source.percentage + "%" : "--"
                textFormat: Text.PlainText
                color: tile.tokens.onFill
                font.family: tile.tokens.monoFamily
                font.pixelSize: tile.tokens.bodySize
                font.bold: true
            }
        }
    }
}
