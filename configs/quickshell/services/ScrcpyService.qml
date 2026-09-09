import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service
    visible: false
    property var host
    property var adbDevices: []
    property bool adbBusy: false
    property string adbError: ""
    property bool scrcpyChecking: false

    Process {
        id: pScrcpyCheck
        command: ["sh", "-c", "if ! command -v scrcpy >/dev/null 2>&1; then echo __SCRCPY_MISSING__; elif pgrep -x scrcpy >/dev/null 2>&1; then echo __SCRCPY_RUNNING__; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                host.scrcpyChecking = false;
                var status = text.trim();
                if (status === "__SCRCPY_MISSING__") {
                    host.adbError = host.tr("scrcpy is not installed");
                    host.notifyScrcpyMissing();
                    return;
                }
                if (status === "__SCRCPY_RUNNING__") {
                    host.notifyScrcpyRunning();
                    host.page = "scrcpy";
                    host.expanded = true;
                    host.holdOpen = true;
                    return;
                }
                host.refreshAdbDevices();
            }
        }
    }

    Process {
        id: pScrcpyNotify
        command: ["notify-send", "scrcpy", "A scrcpy session is already running."]
    }

    Process {
        id: pAdbDevices
        command: ["sh", "-c", "if ! command -v adb >/dev/null 2>&1; then echo __ADB_MISSING__; else adb devices -l 2>/dev/null; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.indexOf("__ADB_MISSING__") >= 0) {
                    host.adbDevices = [];
                    host.adbBusy = false;
                    host.adbError = host.tr("adb is not installed");
                    return;
                }
                var found = [];
                var lines = text.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (!line || line.indexOf("List of devices") === 0) continue;
                    var fields = line.split(/\s+/);
                    if (fields.length >= 2 && fields[1] === "device")
                        found.push({ serial: fields[0], label: fields[0] });
                }
                host.adbDevices = found;
                host.adbBusy = false;
                if (found.length === 0) {
                    host.adbError = host.tr("No ADB devices found");
                }
            }
        }
    }

    function refreshAdbDevices() {
        host.adbBusy = true;
        host.adbError = "";
        pAdbDevices.running = false;
        pAdbDevices.running = true;
    }

    function launchScrcpy(serial) {
        if (!serial) return;
        var known = host.adbDevices.some(function (device) { return device.serial === serial; });
        if (!known) return;
        var safe = String(serial).replace(/'/g, "'\\''");
        host.runDetached("scrcpy -s '" + safe + "'");
    }

    function notifyScrcpyRunning() {
        pScrcpyNotify.running = false;
        pScrcpyNotify.running = true;
    }

    function notifyScrcpyMissing() {
        pScrcpyNotify.command = ["notify-send", "scrcpy", "scrcpy is not installed."];
        pScrcpyNotify.running = false;
        pScrcpyNotify.running = true;
    }

    function openScrcpy() {
        pageResetTimer.stop();
        host.page = "scrcpy";
        host.expanded = true;
        host.holdOpen = true;
        host.adbBusy = false;
        host.scrcpyChecking = true;
        pScrcpyCheck.running = false;
        pScrcpyCheck.running = true;
    }

}
