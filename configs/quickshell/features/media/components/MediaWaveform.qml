import QtQuick

Item {
    id: waveform

    required property QtObject tokens
    required property var levels
    property real progress: 0
    property int barCount: 46
    readonly property real gap: 3
    readonly property real barWidth: Math.max(1, (width - gap * (barCount - 1)) / barCount)

    Repeater {
        model: waveform.barCount

        Rectangle {
            required property int index

            x: index * (waveform.barWidth + waveform.gap)
            anchors.verticalCenter: parent.verticalCenter
            width: waveform.barWidth
            height: Math.max(2, Math.pow(waveform.levels[index] || 0, 0.6) * waveform.height)
            radius: width / 2
            color: waveform.tokens.alpha(waveform.tokens.foreground, 0.22)

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: waveform.tokens.foreground
                visible: (index + 0.5) / waveform.barCount <= waveform.progress
            }

            Behavior on height {
                NumberAnimation {
                    duration: waveform.tokens.motionEnabled ? 90 : 0
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
