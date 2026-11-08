import QtQuick
import QtQuick.Controls
import Quickshell.Widgets
import "../../../components/icons"
import "../../../components/controls"

AbstractButton {
    id: artwork

    required property QtObject tokens
    required property string source
    property string description: "Toggle playback"

    implicitWidth: 42
    implicitHeight: 42
    padding: 0
    hoverEnabled: true
    Accessible.name: description

    ButtonTooltip {
        parent: artwork
        tokens: artwork.tokens
        text: artwork.description
        visible: artwork.hovered && artwork.visible && artwork.enabled && !artwork.down
    }

    contentItem: Item {
    }

    background: ClippingRectangle {
        radius: artwork.tokens.radius
        border.width: artwork.visualFocus ? 1 : 0
        border.color: artwork.tokens.foreground
        color: artwork.tokens.alpha(artwork.tokens.foreground, 0.07)

        Image {
            id: image

            anchors.fill: parent
            source: artwork.source
            sourceSize.width: 84
            sourceSize.height: 84
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        AssetIcon {
            anchors.centerIn: parent
            width: 20
            height: 20
            name: "music"
            color: artwork.tokens.muted
            visible: image.status !== Image.Ready
        }
    }
}
