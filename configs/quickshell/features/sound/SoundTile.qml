import QtQuick
import QtQuick.Layouts
import "../../components/controls"

OverviewCard {
    id: tile

    required property QtObject source

    signal openRequested

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: {
            const position = volume.mapFromItem(tile, point.position.x, point.position.y);
            if (position.x < 0 || position.x > volume.width || position.y < 0 || position.y > volume.height)
                tile.openRequested();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 7
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: "Sound"
                color: tile.tokens.foreground
                font.family: tile.tokens.fontFamily
                font.pixelSize: tile.tokens.fontSize - 3
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: tile.source.name
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: tile.tokens.muted
                font.family: tile.tokens.fontFamily
                font.pixelSize: tile.tokens.fontSize - 5
            }
        }

        AudioSlider {
            id: volume
            Layout.fillWidth: true
            tokens: tile.tokens
            description: "Output volume"
            enabled: tile.source.available
            value: tile.source.volume
            muted: tile.source.muted
            onMoved: tile.source.setVolume(value)
            onMuteRequested: tile.source.toggleMute()
        }
    }
}
