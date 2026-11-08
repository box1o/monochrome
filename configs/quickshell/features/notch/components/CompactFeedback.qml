import QtQuick
import "../../calendar/components"
import "../../pomodoro/components"
import "../../recording/components"

Item {
    id: compact

    required property QtObject presentation
    required property QtObject pomodoro
    required property QtObject feedback
    required property QtObject month
    required property QtObject tokens
    required property QtObject style
    required property QtObject geometry
    readonly property string activityKey: presentation.kind === "connection" ? presentation.kind + ":" + feedback.revision : presentation.kind
    property real arrival: 1

    onActivityKeyChanged: {
        if (presentation.activityVisible && tokens.motionEnabled)
            entrance.restart();
    }

    SequentialAnimation {
        id: entrance

        PropertyAction {
            target: compact
            property: "arrival"
            value: 0
        }
        NumberAnimation {
            target: compact
            property: "arrival"
            to: 1
            duration: compact.tokens.normalDuration
            easing.type: Easing.OutCubic
        }
    }

    Connections {
        target: compact.tokens
        function onMotionEnabledChanged() {
            if (!compact.tokens.motionEnabled) {
                entrance.stop();
                compact.arrival = 1;
            }
        }
    }

    opacity: arrival * Math.max(0, 1 - geometry.progress * 3)
    transform: Translate {
        y: (1 - compact.arrival) * 4
    }

    readonly property real contentWidth: {
        switch (presentation.kind) {
        case "connection":
            return connectionView.contentWidth;
        case "month":
            return monthView.contentWidth;
        case "pomodoro":
            return pomodoroView.contentWidth;
        case "recording":
            return recordingView.contentWidth;
        default:
            return 0;
        }
    }

    StatusFeedbackView {
        id: connectionView

        anchors.fill: parent
        visible: compact.presentation.kind === "connection"
        model: compact.feedback
        tokens: compact.tokens
        style: compact.style
        lowerRadius: compact.geometry.lowerRadius
    }

    MonthProgressView {
        id: monthView

        anchors.centerIn: parent
        visible: compact.presentation.kind === "month"
        opacity: Math.max(0, 1 - compact.geometry.progress * 2)
        model: compact.month
        tokens: compact.tokens
        style: compact.style
    }

    RecordingActivity {
        id: recordingView

        anchors.centerIn: parent
        visible: compact.presentation.kind === "recording"
        tokens: compact.tokens
    }

    PomodoroActivity {
        id: pomodoroView

        anchors.centerIn: parent
        visible: compact.presentation.kind === "pomodoro"
        source: compact.pomodoro
        tokens: compact.tokens
    }
}
