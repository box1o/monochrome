import QtQuick
import QtQuick.Layouts
import "../../../components/controls"
import "../../media"
import "../../power/components"
import "../../pomodoro"

Item {
    id: deck

    required property QtObject model
    readonly property QtObject media: model.media
    required property QtObject power
    required property QtObject pomodoro
    required property QtObject tokens

    signal powerRequested()

    implicitHeight: 86

    PageDots {
        id: selector

        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.right: parent.right
        anchors.rightMargin: 7
        z: 2
        tokens: deck.tokens
        labels: ["Media", "Power and Pomodoro"]
        toggleOnClick: true
        currentIndex: deck.model.currentIndex
        color: currentIndex === 1 ? deck.tokens.onFill : deck.tokens.foreground
        onSelected: index => deck.model.select(index)
    }

    Item {
        anchors.fill: parent
        clip: true

        ActivityPage {
            anchors.fill: parent
            tokens: deck.tokens
            active: deck.model.currentIndex === 0
            direction: -1

            MediaCard {
                anchors.fill: parent
                contentTopPadding: 14
                source: deck.media
                tokens: deck.tokens
                visible: deck.media.available
                active: deck.model.currentIndex === 0 && deck.media.monitoring
            }

            OverviewCard {
                anchors.fill: parent
                tokens: deck.tokens
                visible: !deck.media.available

                Text {
                    anchors.centerIn: parent
                    text: "No media playing"
                    color: deck.tokens.muted
                    font.family: deck.tokens.fontFamily
                    font.pixelSize: deck.tokens.bodySize
                }
            }
        }

        ActivityPage {
            anchors.fill: parent
            tokens: deck.tokens
            active: deck.model.currentIndex === 1
            direction: 1

            RowLayout {
                id: powerRow

                anchors.fill: parent
                spacing: deck.tokens.spacing

                PomodoroTile {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    contentTopPadding: 14
                    source: deck.pomodoro
                    tokens: deck.tokens
                }

                PowerTile {
                    Layout.fillHeight: true
                    Layout.minimumWidth: (powerRow.width - powerRow.spacing) / 6
                    Layout.preferredWidth: Layout.minimumWidth
                    Layout.maximumWidth: Layout.minimumWidth
                    source: deck.power
                    tokens: deck.tokens
                    onOpenRequested: deck.powerRequested()
                }
            }
        }
    }
}
