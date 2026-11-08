import QtQml
import Quickshell
import Quickshell.Io

QtObject {
    id: brightness

    property var devices: []
    property bool browsing: false
    property bool rescanPending: false
    property string device: ""
    property string label: "No display control"
    property int percentage: -1
    property string operationError: ""
    property string discoveryError: ""
    readonly property string error: operationError || discoveryError
    property int pending: -1
    property bool refreshQueued: false
    property int revision: 0
    property int queryRevision: 0
    readonly property bool busy: writer.running || pending >= 0
    readonly property bool available: device.length > 0 && percentage >= 0
    readonly property string backlightPath: device.startsWith("bl:") ? "/sys/class/backlight/" + device.slice(3) : ""
    readonly property string helper: Quickshell.env("HOME") + "/.local/libexec/mono/desktop/brightness.sh"
    signal changed(int percentage)

    Component.onCompleted: refresh()

    function refresh() {
        if (query.running)
            refreshQueued = true;
        else {
            queryRevision = revision;
            query.command = [helper, rescanPending ? "rescan" : "list"];
            rescanPending = false;
            query.running = true;
        }
    }

    function setPercentage(value) {
        if (!available || !Number.isFinite(value))
            return;
        const next = Math.max(5, Math.min(100, Math.round(value / 5) * 5));
        if (next === percentage)
            return;
        revision++;
        pending = next;
        percentage = next;
        changed(next);
        if (!writer.running)
            dispatch.restart();
    }

    function selectDevice(id) {
        if (busy || id === device)
            return;
        const next = devices.find(item => item.id === id);
        if (!next)
            return;
        revision++;
        device = next.id;
        label = next.label;
        percentage = next.percentage;
        operationError = "";
        refresh();
    }

    function rescan() {
        rescanPending = true;
        refresh();
    }

    function readState(text) {
        const nextDevices = text.trim().split("\n").map(line => {
            const fields = line.split("\t");
            return {id: fields[0], label: fields[1], percentage: Number(fields[2])};
        }).filter(item => item.id && item.label && Number.isFinite(item.percentage)
            && item.percentage >= 0 && item.percentage <= 100);
        const next = nextDevices.find(item => item.id === device) || nextDevices[0];
        const previous = device;
        devices = nextDevices;
        if (!next) {
            device = "";
            percentage = -1;
            label = "No display control";
            return;
        }
        if (previous === next.id && (busy || queryRevision !== revision))
            return;
        // The sysfs watcher is authoritative for the selected built-in display.
        // A full display query may have read it before a slow DDC transaction.
        if (previous === next.id && backlightPath)
            return;
        const notify = previous === next.id && percentage >= 0 && percentage !== next.percentage;
        if (previous !== next.id) {
            pending = -1;
            dispatch.stop();
        }
        device = next.id;
        label = next.label;
        percentage = next.percentage;
        if (notify)
            changed(percentage);
    }

    function readBacklight() {
        if (busy || !backlightPath || !current.loaded || !maximum.loaded)
            return;
        const limit = Number(maximum.text());
        const value = Number(current.text());
        if (!Number.isFinite(limit) || limit <= 0 || !Number.isFinite(value))
            return;
        const next = Math.max(0, Math.min(100, Math.round(value / limit * 100)));
        const notify = percentage >= 0 && percentage !== next;
        percentage = next;
        if (notify)
            changed(next);
    }

    readonly property FileView maximum: FileView {
        path: brightness.backlightPath ? brightness.backlightPath + "/max_brightness" : ""
        preload: path.length > 0
        printErrors: false
        onLoaded: brightness.readBacklight()
    }

    readonly property FileView current: FileView {
        path: brightness.backlightPath ? brightness.backlightPath + "/brightness" : ""
        preload: path.length > 0
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: brightness.readBacklight()
    }

    // Some drivers emit neither udev nor file notifications for brightness writes.
    readonly property Timer backlightUpdates: Timer {
        interval: 200
        running: brightness.backlightPath.length > 0
        repeat: true
        onTriggered: brightness.current.reload()
    }

    readonly property Process query: Process {
        stdout: StdioCollector {
            onStreamFinished: brightness.readState(text)
        }
        onExited: (code, status) => {
            brightness.discoveryError = code === 0 && status === 0 ? "" : "Brightness control unavailable";
            if (brightness.refreshQueued) {
                brightness.refreshQueued = false;
                brightness.refresh();
            }
        }
    }

    readonly property Process writer: Process {
        onExited: (code, status) => {
            brightness.operationError = code === 0 && status === 0 ? "" : "Could not change brightness";
            if (brightness.pending >= 0)
                brightness.dispatch.restart();
            else
                brightness.refresh();
        }
    }

    readonly property Timer dispatch: Timer {
        interval: 60
        onTriggered: {
            if (!brightness.available || brightness.pending < 0 || brightness.writer.running)
                return;
            brightness.writer.command = [brightness.helper, "set", brightness.device, String(brightness.pending)];
            brightness.writer.running = true;
            brightness.pending = -1;
        }
    }

    readonly property Timer externalUpdates: Timer {
        interval: 2500
        running: brightness.browsing && brightness.device.startsWith("ddc:")
        repeat: true
        onTriggered: brightness.refresh()
    }

    readonly property Connections screens: Connections {
        target: Quickshell
        function onScreensChanged() {
            brightness.rescan();
        }
    }

    readonly property Process events: Process {
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith("UDEV"))
                    brightness.updates.restart();
            }
        }
    }

    readonly property Timer updates: Timer {
        interval: 80
        onTriggered: brightness.refresh()
    }
}
