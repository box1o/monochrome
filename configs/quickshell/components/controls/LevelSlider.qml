import QtQuick
import QtQuick.Controls

Slider {
    id: slider

    required property QtObject tokens
    property string description: "Level"
    property color trackColor: tokens.controlBackground
    property color fillColor: tokens.foreground
    property bool focusOutline: true

    from: 0
    to: 1
    stepSize: 0.01
    implicitHeight: 22
    implicitWidth: 100
    padding: 0
    wheelEnabled: true
    Accessible.name: description

    background: Rectangle {
        id: track

        x: slider.leftPadding
        y: (slider.height - height) / 2
        width: slider.availableWidth
        height: 20
        radius: height / 2
        color: slider.trackColor
        border.width: slider.focusOutline && slider.visualFocus ? 1 : 0
        border.color: slider.tokens.focusColor

        Item {
            width: track.width * slider.visualPosition
            height: track.height
            clip: true

            Rectangle {
                // Keep the left cap identical to the track, even below its diameter.
                width: Math.max(track.height, parent.width)
                height: track.height
                radius: track.radius
                color: slider.enabled ? slider.fillColor : slider.tokens.muted
            }
        }
    }

    handle: Item {
    }
}
