import QtQml
import QtQml.Models
import Quickshell.Bluetooth

QtObject {
    id: bluetooth

    signal connectionChanged(QtObject device, bool connected)

    property bool browsing: false
    property QtObject pending: null
    property QtObject scanOwner: null
    property string action: ""
    property string error: ""
    readonly property var prompt: pairing.prompt
    readonly property QtObject adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter !== null && adapter.enabled
    readonly property bool blocked: adapter !== null && adapter.state === BluetoothAdapterState.Blocked
    readonly property bool busy: pending !== null || (adapter !== null && [BluetoothAdapterState.Enabling, BluetoothAdapterState.Disabling].includes(adapter.state))
    readonly property bool ownsScan: scanOwner !== null && scanOwner.discovering
    readonly property bool scanning: adapter !== null && adapter.discovering
    readonly property var devices: adapter ? adapter.devices.values.slice().sort(compareDevices) : []
    readonly property QtObject connectedDevice: devices.find(device => device.connected) || null
    readonly property string summary: {
        if (!available)
            return "No adapter";
        if (blocked)
            return "Hardware blocked";
        return enabled ? (connectedDevice?.name || "Not connected") : "Off";
    }

    function compareDevices(a, b) {
        return Number(b.connected) - Number(a.connected) || Number(b.paired) - Number(a.paired) || a.name.localeCompare(b.name);
    }

    onBrowsingChanged: {
        if (!browsing)
            stopScan();
    }
    onAdapterChanged: stopScan()

    readonly property Instantiator deviceObservers: Instantiator {
        model: Bluetooth.devices
        delegate: BluetoothDeviceObserver {
            required property var modelData
            device: modelData
            onConnectionChanged: connected => {
                if (connected)
                    bluetooth.enableAudioReconnect(device);
                bluetooth.connectionChanged(device, connected);
            }
        }
    }

    readonly property Timer scanDeadline: Timer {
        interval: 15000
        onTriggered: bluetooth.stopScan()
    }

    readonly property Timer operationDeadline: Timer {
        interval: 30000
        onTriggered: bluetooth.cancel("Operation timed out. Try again.")
    }

    readonly property Connections stateWatcher: Connections {
        target: bluetooth.pending
        function onConnectedChanged() {
            if (!bluetooth.pending)
                return;
            if (bluetooth.action === "connect" && bluetooth.pending.connected)
                bluetooth.finish();
            else if (bluetooth.action === "disconnect" && !bluetooth.pending.connected)
                bluetooth.finish();
        }

        function onStateChanged() {
            if (bluetooth.pending && bluetooth.action === "connect" && bluetooth.pending.state === BluetoothDeviceState.Disconnected)
                bluetooth.finish("Could not connect. Check that the device is nearby and ready.");
        }
    }

    readonly property BluetoothPairing pairing: BluetoothPairing {
        onSucceeded: {
            if (!bluetooth.pending)
                return;
            bluetooth.enableAudioReconnect(bluetooth.pending);
            bluetooth.action = "connect";
            bluetooth.operationDeadline.interval = 30000;
            bluetooth.operationDeadline.restart();
            if (bluetooth.pending.connected)
                bluetooth.finish();
            else
                bluetooth.pending.connect();
        }
        onFailed: message => bluetooth.finish(message)
    }

    function toggle() {
        if (available && !blocked && !busy) {
            error = "";
            if (enabled)
                stopScan();
            adapter.enabled = !enabled;
        }
    }

    function scan() {
        if (!adapter || !enabled || !browsing || adapter.discovering || scanOwner === adapter)
            return;
        error = "";
        scanOwner = adapter;
        scanOwner.discovering = true;
        scanDeadline.restart();
    }

    function stopScan() {
        scanDeadline.stop();
        if (scanOwner)
            scanOwner.discovering = false;
        scanOwner = null;
    }

    function begin(device, operation) {
        if (!device || busy || !enabled || device.blocked)
            return false;
        error = "";
        action = operation;
        pending = device;
        operationDeadline.interval = operation === "pair" ? 100000 : 30000;
        operationDeadline.restart();
        return true;
    }

    function connect(device) {
        if (!begin(device, "connect"))
            return;
        enableAudioReconnect(device);
        device.connect();
    }

    function enableAudioReconnect(device) {
        // BlueZ persists trust and authorizes the headphones to reconnect themselves.
        if (device && (device.paired || device.bonded) && !device.blocked && ["audio-headset", "audio-headphones", "audio-card", "audio-speakers"].includes(device.icon))
            device.trusted = true;
    }

    function disconnect(device) {
        if (!begin(device, "disconnect"))
            return;
        device.disconnect();
    }

    function pair(device) {
        if (!begin(device, "pair"))
            return;
        if (!pairing.start(device.dbusPath))
            finish("Another pairing request is still finishing. Try again.");
    }

    function reply(accept, value = "") {
        pairing.reply(accept, value);
    }

    function finish(message = "") {
        operationDeadline.stop();
        error = message;
        pending = null;
        action = "";
    }

    function cancel(message = "") {
        pairing.cancel();
        if (pending && action === "connect")
            pending.disconnect();
        finish(message);
    }

    function forget(device) {
        if (device && !busy && !device.connected)
            device.forget();
    }
}
