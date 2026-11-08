import QtQuick
import QtQuick.Layouts
import "../../components/controls"

OverviewCard {
    id: tile

    required property QtObject source

    signal openRequested()

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: {
            const position = brightness.mapFromItem(tile, point.position.x, point.position.y);
            if (position.x < 0 || position.x > brightness.width || position.y < 0 || position.y > brightness.height)
                tile.openRequested();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: tile.tokens.cardInset
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Brightness"
                color: tile.tokens.foreground
                font.family: tile.tokens.fontFamily
                font.pixelSize: tile.tokens.labelSize
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: tile.source.error || tile.source.label
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: tile.source.error ? tile.tokens.red : tile.tokens.muted
                font.family: tile.tokens.fontFamily
                font.pixelSize: tile.tokens.captionSize
            }
        }

        BrightnessSlider {
            id: brightness

            Layout.fillWidth: true
            source: tile.source
            tokens: tile.tokens
        }
    }
}
