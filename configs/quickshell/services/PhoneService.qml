import QtQml
import Quickshell
import Quickshell.Io
import "PhoneDevices.js" as Devices

QtObject {
    id: phone

    property var devices: []
    property string error: ""
    property bool browsing: false
    readonly property bool busy: query.running
    readonly property Timer monitor: Timer {
        interval: 3000
        repeat: true
        running: phone.browsing
        onTriggered: phone.refresh()
    }

    readonly property Process query: Process {
        command: ["timeout", "8", "adb", "devices", "-l"]
        onExited: (code, status) => {
            phone.error = code === 0 && status === 0 ? "" : "Could not read ADB devices. Check the connection and ADB installation.";
            if (phone.error)
                phone.devices = [];
        }

        stdout: StdioCollector {
            onStreamFinished: {
                phone.devices = Devices.parse(text);
            }
        }

    }

    function refresh() {
        if (!query.running)
            query.running = true;
    }

    function mirror(serial) {
        if (!devices.some(device => device.serial === serial && device.state === "device"))
            return false;

        Quickshell.execDetached(["scrcpy", "--serial", serial]);
        return true;
    }

    onBrowsingChanged: {
        if (browsing)
            refresh();
    }
}
