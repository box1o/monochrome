import QtQml
import Quickshell
import Quickshell.Io
import "ClipboardData.js" as ClipboardData

QtObject {
    id: clipboard

    property var entries: []
    property bool browsing: false
    property string operationError: ""
    property string discoveryError: ""
    property bool refreshQueued: false
    property int revision: 0
    readonly property string error: operationError || discoveryError
    readonly property bool busy: action.running
    readonly property string helper: Quickshell.env("HOME") + "/.local/libexec/mono/desktop/clipboard.sh"
    readonly property Process query: Process {
        property string output: ""
        property int revision: 0

        command: [clipboard.helper, "list"]
        onExited: (code, status) => {
            clipboard.discoveryError = code === 0 && status === 0 ? "" : "Could not read clipboard history";
            if (!clipboard.discoveryError && !clipboard.busy && revision === clipboard.revision) {
                const items = ClipboardData.parse(output);
                if (JSON.stringify(items) !== JSON.stringify(clipboard.entries))
                    clipboard.entries = items;
            }
            output = "";
            if (clipboard.refreshQueued && !clipboard.busy)
                clipboard.refresh();
        }

        stdout: StdioCollector {
            onStreamFinished: clipboard.query.output = text
        }
    }

    readonly property Process action: Process {
        property string operation: ""

        onExited: (code, status) => {
            clipboard.operationError = code === 0 && status === 0 ? "" : "Could not update clipboard history";
            if (!clipboard.operationError) {
                if (operation === "copy")
                    clipboard.copied();

                clipboard.refresh();
            } else if (clipboard.refreshQueued) {
                clipboard.refresh();
            }
        }
    }

    readonly property Timer monitor: Timer {
        interval: 2000
        repeat: true
        running: clipboard.browsing
        onTriggered: clipboard.refresh()
    }

    signal copied

    function refresh() {
        if (query.running || busy) {
            refreshQueued = true;
            return;
        }
        refreshQueued = false;
        query.revision = revision;
        query.output = "";
        query.running = true;
    }

    function perform(operation, id = "") {
        if (busy || !["copy", "delete", "clear"].includes(operation))
            return;

        if (operation !== "clear" && !entries.some(entry => {
            return entry.id === id;
        }))
            return;

        revision++;
        operationError = "";
        action.operation = operation;
        action.command = operation === "clear" ? [helper, operation] : [helper, operation, id];
        action.running = true;
    }

    onBrowsingChanged: {
        if (browsing)
            refresh();
    }
}
