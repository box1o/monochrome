import QtQml
import Quickshell
import Quickshell.Io

QtObject {
    id: vpn

    property var connections: []
    property var tailscale: ({
            devices: [],
            preferences: {},
            connected: false
        })
    property bool browsing: false
    property string operationError: ""
    property string discoveryError: ""
    readonly property string error: operationError || discoveryError
    property string notice: ""
    property string loginUrl: ""
    property bool refreshQueued: false
    property int revision: 0
    property int queryRevision: 0
    readonly property bool busy: change.running
    readonly property var primary: connections.find(item => item.connected) || connections[0] || null
    readonly property var exitNodes: tailscale.devices.filter(item => item.offersExit && !item.self)
    readonly property string helper: Quickshell.env("HOME") + "/.local/libexec/mono/vpn/control.sh"

    Component.onCompleted: refresh()
    onBrowsingChanged: {
        if (browsing)
            refresh();
    }

    function refresh() {
        if (busy || query.running) {
            refreshQueued = true;
            return;
        }
        refreshQueued = false;
        queryRevision = revision;
        query.running = true;
    }

    function readSnapshot(text) {
        if (busy || queryRevision !== revision)
            return;
        try {
            const result = JSON.parse(text);
            if (!Array.isArray(result.connections) || !Array.isArray(result.tailscale?.devices))
                throw new Error("Invalid snapshot");
            discoveryError = "";
            connections = result.connections;
            tailscale = result.tailscale;
            loginUrl = tailscale.authUrl || (tailscale.connected ? "" : loginUrl);
        } catch (failure) {
            discoveryError = "Could not read VPN connections";
        }
    }

    function toggle(id) {
        const connection = connections.find(item => item.id === id);
        if (connection)
            run([connection.connected ? "disconnect" : "connect", id]);
    }

    function run(commandArgs) {
        if (busy)
            return;
        revision++;
        operationError = "";
        notice = "";
        messageExpiry.stop();
        change.command = [helper].concat(commandArgs);
        change.running = true;
    }

    function setPreference(name, value) {
        run(["setting", name, String(value)]);
    }

    function ping(address) {
        if (tailscale.devices.some(item => item.address === address && item.online && !item.self))
            run(["ping", address]);
    }

    function showNotice(text) {
        notice = text;
        messageExpiry.restart();
    }

    function copyAddress(address) {
        if (!clipboard.running && tailscale.devices.some(item => item.address === address && address)) {
            clipboard.command = ["wl-copy", "--", address];
            clipboard.running = true;
        }
    }

    function signIn() {
        if (loginUrl.startsWith("https://login.tailscale.com/"))
            Qt.openUrlExternally(loginUrl);
    }

    function finish(code, output, message) {
        const url = (output + "\n" + message).match(/https:\/\/login\.tailscale\.com\/[^\s]+/);
        if (url)
            loginUrl = url[0];
        if (change.command[1] === "ping") {
            if (code === 0)
                showNotice("Device is reachable");
            else
                operationError = "Device did not respond";
        } else if (code === 126 || code === 127) {
            operationError = "Authentication cancelled or unavailable";
        } else if (code === 124) {
            operationError = "VPN action timed out. Try again.";
        } else if (code !== 0) {
            operationError = message.split("\n")[0] || "Could not complete VPN action";
        }
        refresh();
    }

    readonly property Process clipboard: Process {
        onExited: (code, status) => {
            if (code === 0 && status === 0) {
                vpn.operationError = "";
                vpn.showNotice("IP address copied");
            } else
                vpn.operationError = "Could not copy IP address";
        }
    }

    readonly property Process query: Process {
        command: [vpn.helper, "snapshot"]
        stdout: StdioCollector {
            onStreamFinished: vpn.readSnapshot(text)
        }
        onExited: (code, status) => {
            if (code !== 0 || status !== 0)
                vpn.discoveryError = "VPN discovery unavailable";
            if (vpn.refreshQueued)
                vpn.refresh();
        }
    }

    readonly property Process change: Process {
        property string message: ""
        property string output: ""
        onStarted: {
            message = "";
            output = "";
        }
        stdout: StdioCollector {
            onStreamFinished: vpn.change.output = text.trim()
        }
        stderr: StdioCollector {
            onStreamFinished: vpn.change.message = text.trim()
        }
        onExited: (code, status) => vpn.finish(status === 0 ? code : 1, output, message)
    }

    readonly property Timer messageExpiry: Timer {
        interval: 2500
        onTriggered: vpn.notice = ""
    }

    readonly property Timer updates: Timer {
        interval: vpn.browsing ? 3000 : 15000
        running: true
        repeat: true
        onTriggered: vpn.refresh()
    }
}
