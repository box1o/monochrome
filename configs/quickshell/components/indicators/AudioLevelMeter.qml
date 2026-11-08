import QtQuick

Item {
    id: meter

    required property QtObject tokens
    property real peak: 0
    readonly property real decibels: 20 * Math.log10(Math.max(0.000001, peak))
    property real level: Math.max(0, Math.min(1, (decibels + 60) / 60))
    readonly property int segments: 28

    property real spacing: 3
    implicitHeight: 8
    Accessible.role: Accessible.Indicator
    Accessible.name: "Microphone signal level"
    Accessible.description: peak >= 0.89 ? "Near clipping" : peak > 0.001 ? "Signal detected" : "Quiet"

    Behavior on level {
        NumberAnimation {
            duration: meter.tokens.motionEnabled ? 100 : 0
            easing.type: Easing.OutCubic
        }
    }

    Row {
        anchors.fill: parent
        spacing: meter.spacing

        Repeater {
            model: meter.segments
            Rectangle {
                required property int index
                width: Math.max(0, (meter.width - meter.spacing * (meter.segments - 1)) / meter.segments)
                height: meter.height
                radius: 2
                color: index >= 27 ? meter.tokens.red : index >= 25 ? meter.tokens.yellow : meter.tokens.green
                opacity: index < meter.level * meter.segments ? 1 : 0.12
            }
        }
    }
}
