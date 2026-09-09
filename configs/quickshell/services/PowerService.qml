import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service
    visible: false
    property var host
    readonly property string powerScript:
        Quickshell.env("HOME") + "/.config/quickshell/scripts/power.sh"

    // "power-saver" | "balanced" | "performance"
    property string powerProfile: "balanced"

    Process {
        id: pPowerGet
        command: [host.powerScript, "get"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                var s = line.trim();
                if (s.length) service.powerProfile = s;
            }
        }
    }
    Process {
        id: pPowerSet
        onRunningChanged: if (!running) pPowerGet.running = true
    }
    Timer {
        interval: host.expanded ? 10000 : 30000
        running: true; repeat: true
        onTriggered: pPowerGet.running = true
    }

    readonly property string profileLabel:
        powerProfile === "power-saver" ? host.tr("Power saver")
      : powerProfile === "performance" ? host.tr("Performance")
                                       : host.tr("Balanced")

    function setPowerProfile(name) {
        service.powerProfile = name;
        pPowerSet.command = [host.powerScript, "set", name];
        pPowerSet.running = true;
    }

}
