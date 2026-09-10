import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service
    visible: false
    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/scripts/network.sh"
    property bool connected: false
    property string name: ""
    property string ip: ""
    property int quality: 0
    Process {
        id: status
        command: [service.scriptPath, "status"]
        stdout: SplitParser { onRead: line => {
            var p = line.trim().split("="); if (p.length < 2) return;
            if (p[0] === "state") service.connected = p[1].indexOf("100") === 0 || p[1].indexOf("connected") >= 0;
            if (p[0] === "name") service.name = p.slice(1).join("=");
            if (p[0] === "ip") service.ip = p.slice(1).join("=");
        }}
    }
    Process { id: reconnect; onRunningChanged: if (!running) status.running = true }
    Timer { interval: 10000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { if (!status.running) status.running = true; } }
    function reconnectNow() { reconnect.command = [service.scriptPath, "reconnect"]; reconnect.running = true; }
}
