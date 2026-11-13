import QtQml

QtObject {
    required property QtObject feedback
    required property QtObject month
    property QtObject supply: null
    property QtObject recording: null
    property QtObject pomodoro: null
    property bool activityDismissed: false
    property bool expanded: false
    readonly property string kind: {
        if (expanded)
            return "none";

        if (feedback.active)
            return "connection";

        if (recording && recording.active && !activityDismissed)
            return "recording";

        if (month.active)
            return "month";

        if (pomodoro && pomodoro.active && !activityDismissed)
            return "pomodoro";

        return supply && supply.lastOutputOn && !activityDismissed ? "supply" : "clock";
    }
    readonly property bool activityVisible: kind === "connection" || kind === "month" || kind === "pomodoro" || kind === "recording" || kind === "supply"
}
