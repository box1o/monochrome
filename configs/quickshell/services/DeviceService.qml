import QtQml
import Quickshell.Io

QtObject {
    id: devices

    property bool enabled: true
    property bool initialized: false
    property bool refreshQueued: false
    property var previous: ({
    })
    property string error: ""
    readonly property Process query: Process {
        property string output: ""

        command: ["lsblk", "--json", "--output", "NAME,TYPE,TRAN,LABEL,MODEL"]
        onExited: (code, status) => {
            if (code === 0 && status === 0)
                devices.reconcile(output);
            else
                devices.error = "Could not inspect USB storage";
            output = "";
            if (devices.refreshQueued) {
                devices.refreshQueued = false;
                Qt.callLater(devices.refresh);
            }
        }

        stdout: StdioCollector {
            onStreamFinished: devices.query.output = text
        }
    }

    readonly property Process monitor: Process {
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=block"]
        running: devices.enabled
        onExited: devices.error = "USB event monitor stopped"

        stdout: SplitParser {
            onRead: (line) => {
                if (line.startsWith("UDEV"))
                    settle.restart();
            }
        }
    }

    readonly property Timer settle: Timer {
        interval: 180
        onTriggered: devices.refresh()
    }

    signal connectionChanged(string label, bool connected)

    function refresh() {
        if (query.running) {
            refreshQueued = true;
            return;
        }
        query.running = true;
    }

    function reconcile(text) {
        let data;
        try {
            data = JSON.parse(text);
        } catch (error) {
            devices.error = "Could not read USB storage";
            return;
        }
        if (!data || !Array.isArray(data.blockdevices)) {
            devices.error = "Could not read USB storage";
            return;
        }
        const current = {
        };
        for (const device of data.blockdevices) {
            if (device.type !== "disk" || device.tran !== "usb")
                continue;

            const volume = (device.children || []).find(item => item.label);
            current[device.name] = String(device.label || (volume && volume.label) || device.model || "USB drive").trim();
        }
        if (initialized) {
            for (const key of Object.keys(current)) {
                if (!(key in previous))
                    connectionChanged(current[key], true);
            }
            for (const key of Object.keys(previous)) {
                if (!(key in current))
                    connectionChanged(previous[key], false);
            }
        }
        previous = current;
        initialized = true;
        devices.error = "";
    }

    Component.onCompleted: {
        if (enabled)
            refresh();
    }
}
