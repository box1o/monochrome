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
    readonly property color ink: radioEnabled ? tokens.onFill : tokens.foreground

    signal toggleRequested()
    signal openRequested()

    implicitHeight: tokens.cardHeight
    radius: tokens.cardRadius
    color: radioEnabled ? tokens.foreground : tokens.cardBackground
    border.width: radioEnabled ? 0 : 1
    border.color: tokens.cardBorder

    RowLayout {
        anchors.fill: parent
        anchors.margins: tile.tokens.cardInset
        spacing: tile.tokens.spacing

        AbstractButton {
            id: toggle

            Layout.preferredWidth: tokens.px(34)
            Layout.preferredHeight: tokens.px(34)
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
                width: tokens.px(18)
                height: tokens.px(18)
                name: tile.icon
                color: tile.radioEnabled ? tile.tokens.foreground : tile.tokens.muted
            }

            background: Rectangle {
                radius: width / 2
                color: tile.radioEnabled ? tile.tokens.onFill : toggle.hovered ? tile.tokens.hoverBackground : tile.tokens.controlBackground
            }
        }

        AbstractButton {
            id: details

            Layout.fillWidth: true
            Layout.fillHeight: true
            Accessible.name: "Open " + tile.description
            onClicked: tile.openRequested()

            background: Item {
            }

            contentItem: Item {
                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    spacing: tokens.px(3)

                    Text {
                        width: parent.width
                        text: tile.title
                        textFormat: Text.PlainText
                        color: tile.ink
                        font.family: tile.tokens.monoFamily
                        font.pixelSize: tile.tokens.labelSize
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: tile.subtitle
                        textFormat: Text.PlainText
                        color: tile.tokens.alpha(tile.ink, 0.62)
                        font.family: tile.tokens.monoFamily
                        font.pixelSize: tile.tokens.detailSize
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
