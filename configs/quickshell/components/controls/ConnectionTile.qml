import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../icons"

Rectangle {
    id: tile

    required property QtObject tokens
    required property string title
    required property string subtitle
    required property string icon
    required property string description
    property bool radioEnabled: false
    property bool available: true
    readonly property color ink: radioEnabled ? tokens.background : tokens.foreground

    signal toggleRequested()
    signal openRequested()

    implicitHeight: 54
    radius: tokens.radius + 5
    color: radioEnabled ? tokens.foreground : tokens.alpha(tokens.foreground, 0.035)
    border.width: radioEnabled ? 0 : 1
    border.color: tokens.alpha(tokens.foreground, 0.07)

    RowLayout {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 8

        AbstractButton {
            id: toggle

            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            Layout.alignment: Qt.AlignVCenter
            enabled: tile.available
            hoverEnabled: true
            Accessible.name: (tile.radioEnabled ? "Disable " : "Enable ") + tile.description
            onClicked: tile.toggleRequested()

            ButtonTooltip {
                parent: toggle
                tokens: tile.tokens
                text: toggle.Accessible.name
                visible: toggle.hovered && toggle.visible && toggle.enabled && !toggle.down
            }

            AssetIcon {
                anchors.centerIn: parent
                // The Wi-Fi artwork sits slightly below its SVG view-box center.
                anchors.verticalCenterOffset: tile.icon === "wifi" ? -1 : 0
                width: 18
                height: 18
                name: tile.icon
                color: tile.radioEnabled ? tile.tokens.foreground : tile.tokens.muted
            }

            background: Rectangle {
                radius: width / 2
                color: tile.radioEnabled ? tile.tokens.background : tile.tokens.alpha(tile.tokens.foreground, toggle.hovered ? 0.14 : 0.08)
            }
        }

        AbstractButton {
            id: details

            Layout.fillWidth: true
            Layout.fillHeight: true
            Accessible.name: "Open " + tile.description
            onClicked: tile.openRequested()

            background: Item {}

            contentItem: Item {
                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    spacing: 3

                    Text {
                        width: parent.width
                        text: tile.title
                        textFormat: Text.PlainText
                        color: tile.ink
                        font.family: tile.tokens.monoFamily
                        font.pixelSize: tile.tokens.fontSize - 3
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: tile.subtitle
                        textFormat: Text.PlainText
                        color: tile.tokens.alpha(tile.ink, 0.62)
                        font.family: tile.tokens.monoFamily
                        font.pixelSize: tile.tokens.fontSize - 4
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: tile.tokens.motionEnabled ? tile.tokens.fastDuration : 0
        }
    }
}
