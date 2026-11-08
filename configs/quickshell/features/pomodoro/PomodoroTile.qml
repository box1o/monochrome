import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/controls"
import "../../components/icons"

AbstractButton {
    id: tile

    required property QtObject source
    required property QtObject tokens
    property real contentTopPadding: 0

    implicitHeight: 64
    padding: 0
    hoverEnabled: true
    Accessible.name: (source.running ? "Pause " : "Start ") + source.title + " timer"
    onClicked: source.toggle()

    background: OverviewCard {
        tokens: tile.tokens
        color: tile.tokens.alpha(tile.source.running ? tile.tokens.magenta : tile.tokens.foreground,
            tile.source.running ? 0.08 : 0.025)
        border.color: tile.visualFocus ? tile.tokens.muted : tile.tokens.alpha(tile.tokens.foreground, 0.07)

        Behavior on color {
            ColorAnimation {
                duration: tile.tokens.motionEnabled ? tile.tokens.normalDuration : 0
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 3
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 6 + tile.contentTopPadding
        anchors.bottomMargin: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            GlyphIcon {
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
                glyph: String.fromCodePoint(0xF051B)
                fontFamily: tile.tokens.monoFamily
                pixelSize: 14
                color: tile.source.running ? tile.tokens.magenta : tile.tokens.muted
            }

            Text {
                Layout.fillWidth: true
                text: tile.source.title
                color: tile.tokens.foreground
                font.family: tile.tokens.monoFamily
                font.pixelSize: tile.tokens.fontSize - 3
                font.bold: true
            }

            Text {
                text: tile.source.running ? "Stop" : "Start"
                color: tile.source.running ? tile.tokens.magenta : tile.tokens.muted
                font.family: tile.tokens.monoFamily
                font.pixelSize: tile.tokens.fontSize - 5
                font.bold: true
            }

            IconButton {
                id: reset

                tokens: tile.tokens
                implicitWidth: 22
                implicitHeight: 22
                padding: 0
                iconName: ""
                description: "Reset Pomodoro"
                onClicked: tile.source.reset()

                background: Rectangle {
                    radius: tile.tokens.radius_small
                    color: tile.tokens.alpha(tile.tokens.foreground, reset.hovered ? 0.14 : 0.07)
                    border.width: reset.visualFocus ? 1 : 0
                    border.color: tile.tokens.muted
                }

                contentItem: GlyphIcon {
                    glyph: "↺"
                    fontFamily: tile.tokens.fontFamily
                    pixelSize: 15
                    font.bold: true
                    color: tile.tokens.muted
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: tile.source.text
                color: tile.tokens.foreground
                font.family: tile.tokens.monoFamily
                font.pixelSize: tile.tokens.fontSize + 5
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                radius: 2
                color: tile.tokens.alpha(tile.tokens.foreground, 0.14)

                Rectangle {
                    width: parent.width * tile.source.progress
                    height: parent.height
                    radius: parent.radius
                    color: tile.source.running ? tile.tokens.magenta : tile.tokens.muted

                    Behavior on width {
                        NumberAnimation {
                            duration: tile.tokens.motionEnabled ? tile.tokens.normalDuration : 0
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
