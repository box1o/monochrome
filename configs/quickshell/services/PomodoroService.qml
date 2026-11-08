import QtQml
import QtCore
import Quickshell
import Quickshell.Io
import "../features/pomodoro/models"

PomodoroTimer {
    id: pomodoro

    readonly property Settings storage: Settings {
        property string session: ""
        location: "file://" + (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/mono/pomodoro.ini"
    }

    readonly property IpcHandler controls: IpcHandler {
        target: "pomodoro"
        function start(): void { pomodoro.start(); }
        function pause(): void { pomodoro.pause(); }
        function toggle(): void { pomodoro.toggle(); }
        function reset(): void { pomodoro.reset(); }
        function status(): string { return pomodoro.snapshot(); }
    }

    Component.onCompleted: restore(storage.session)
    onSessionChanged: {
        storage.session = snapshot();
        storage.sync();
    }
}
