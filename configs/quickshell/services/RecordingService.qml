import QtQml
import Quickshell
import Quickshell.Io

QtObject {
    id: recording

    property bool active: false
    property string error: ""
    readonly property bool busy: action.running
    readonly property string helper: Quickshell.env("HOME") + "/.local/libexec/mono/capture/capture.sh"
    readonly property Timer monitor: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: recording.refresh()
    }

    readonly property Process query: Process {
        command: ["pgrep", "-u", Quickshell.env("USER"), "-x", "wf-recorder"]
        onExited: (code, status) => {
            if (status === 0 && (code === 0 || code === 1))
                recording.active = code === 0;
        }
    }

    readonly property Process action: Process {
        onExited: (code, status) => {
            if (code !== 0 || status !== 0)
                recording.error = "Could not change screen recording";

            recording.refresh();
        }
    }

    function refresh() {
        if (!query.running && !busy)
            query.running = true;
    }

    function toggle() {
        if (busy)
            return;

        error = "";
        action.command = [helper, active ? "record-stop" : "record-start"];
        action.running = true;
    }

    Component.onCompleted: refresh()
}
