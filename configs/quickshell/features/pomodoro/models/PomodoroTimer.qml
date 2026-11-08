import QtQml

QtObject {
    id: timer

    property int focusMinutes: 25
    property int breakMinutes: 5
    property int longBreakMinutes: 15
    property string phase: "focus"
    property int completedFocus: 0
    property bool running: false
    property bool active: false
    property real deadline: 0
    property int remaining: focusMinutes * 60
    readonly property int duration: (phase === "focus" ? focusMinutes : phase === "break" ? breakMinutes : longBreakMinutes) * 60
    readonly property string title: phase === "focus" ? "Focus" : phase === "break" ? "Break" : "Long break"
    readonly property string text: String(Math.floor(remaining / 60)).padStart(2, "0") + ":" + String(remaining % 60).padStart(2, "0")
    readonly property string actionLabel: running ? "Pause" : remaining < duration ? "Resume" : "Start"
    readonly property real progress: Math.max(0, Math.min(1, 1 - remaining / duration))
    readonly property Timer ticks: Timer {
        interval: 250
        repeat: true
        running: timer.running
        onTriggered: timer.update(Date.now())
    }

    signal sessionChanged()
    signal phaseCompleted(string phase)

    function toggle() {
        if (running)
            pause();
        else
            start();
    }

    function start() {
        if (running)
            return;

        active = true;
        deadline = Date.now() + remaining * 1000;
        running = true;
        sessionChanged();
    }

    function pause() {
        update(Date.now());
        if (!running)
            return;

        running = false;
        deadline = 0;
        sessionChanged();
    }

    function reset() {
        running = false;
        active = false;
        deadline = 0;
        phase = "focus";
        completedFocus = 0;
        remaining = duration;
        sessionChanged();
    }

    function update(now) {
        if (!running)
            return;

        remaining = Math.max(0, Math.ceil((deadline - now) / 1000));
        if (remaining > 0)
            return;

        const finished = phase;
        running = false;
        deadline = 0;
        if (phase === "focus") {
            completedFocus++;
            phase = completedFocus % 4 === 0 ? "long-break" : "break";
        } else {
            phase = "focus";
        }
        remaining = duration;
        sessionChanged();
        phaseCompleted(finished);
    }

    function snapshot() {
        return JSON.stringify({
            "phase": phase,
            "completedFocus": completedFocus,
            "active": active,
            "running": running,
            "remaining": remaining,
            "deadline": deadline
        });
    }

    function restore(text) {
        // Ignore a malformed local session and retain the default timer.

        if (!text)
            return;

        try {
            const state = JSON.parse(text);
            if (!["focus", "break", "long-break"].includes(state.phase) || !Number.isSafeInteger(state.completedFocus) || state.completedFocus < 0 || !Number.isInteger(state.remaining) || state.remaining < 1 || !Number.isFinite(state.deadline) || typeof state.running !== "boolean" || typeof state.active !== "boolean" || (state.running && (!state.active || state.deadline <= 0)))
                return;

            phase = state.phase;
            completedFocus = state.completedFocus;
            active = state.active;
            remaining = Math.min(duration, state.remaining);
            deadline = state.deadline;
            running = state.running;
            update(Date.now());
        } catch (failure) {
        }
    }
}
