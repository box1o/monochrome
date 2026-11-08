import QtQuick
import QtQuick.Layouts
import "../../../components/controls"

RowLayout {
    id: controls

    required property QtObject tokens
    required property bool timerActive
    required property bool timerRunning
    required property string timerText
    required property bool recordingActive
    required property bool recordingBusy

    signal timerToggleRequested
    signal recordingStopRequested

    visible: timerActive || recordingActive
    spacing: tokens.gap_inner

    TextButton {
        visible: controls.timerActive
        tokens: controls.tokens
        text: controls.timerText
        textColor: controls.tokens.magenta
        description: controls.timerRunning ? "Pause focus timer" : "Resume focus timer"
        onClicked: controls.timerToggleRequested()
    }

    IconButton {
        visible: controls.recordingActive
        enabled: !controls.recordingBusy
        tokens: controls.tokens
        iconName: "video"
        color: controls.tokens.red
        description: "Stop screen recording"
        onClicked: controls.recordingStopRequested()
    }
}
