import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "components"
import "models"

OverviewCard {
    id: card

    required property QtObject source
    property bool active: false
    property real contentTopPadding: 0

    implicitHeight: tokens.px(124)

    MediaSpectrum {
        id: spectrum

        active: card.active && card.source.playing && card.tokens.motionEnabled
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: tokens.px(6)
        anchors.topMargin: card.tokens.px(6) + card.contentTopPadding
        spacing: tokens.px(2)

        RowLayout {
            Layout.fillWidth: true
            spacing: tokens.px(10)

            MediaArtwork {
                Layout.preferredWidth: tokens.px(32)
                Layout.preferredHeight: tokens.px(32)
                description: card.source.playing ? "Pause" : "Play"
                enabled: card.source.canToggle
                onClicked: card.source.toggle()
                source: card.source.artwork
                tokens: card.tokens
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: tokens.px(2)

                Text {
                    Layout.fillWidth: true
                    text: card.source.title
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: card.tokens.foreground
                    font.family: card.tokens.fontFamily
                    font.pixelSize: card.tokens.bodySize
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: card.source.artist
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: card.tokens.muted
                    font.family: card.tokens.fontFamily
                    font.pixelSize: card.tokens.detailSize
                }
            }

            MediaButton {
                tokens: card.tokens
                iconName: "skip-back"
                description: "Previous track"
                enabled: card.source.canPrevious
                onClicked: card.source.previous()
            }

            MediaButton {
                tokens: card.tokens
                primary: true
                iconName: card.source.playing ? "pause" : "play"
                description: card.source.playing ? "Pause" : "Play"
                enabled: card.source.canToggle
                onClicked: card.source.toggle()
            }

            MediaButton {
                tokens: card.tokens
                iconName: "skip-forward"
                description: "Next track"
                enabled: card.source.canNext
                onClicked: card.source.next()
            }
        }

        MediaTimeline {
            Layout.fillWidth: true
            source: card.source
            tokens: card.tokens
            levels: spectrum.levels
        }
    }
}
