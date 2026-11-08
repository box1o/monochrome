import QtQml
import Quickshell.Bluetooth

QtObject {
    id: model

    required property QtObject source
    property bool active: false
    property QtObject selected: null
    property bool confirmForget: false
    readonly property Binding browsing: Binding {
        target: model.source
        property: "browsing"
        value: model.active
        restoreMode: Binding.RestoreBindingOrValue
    }

    function describe(device) {
        let status;
        if (device.blocked)
            status = "Blocked";
        else if (device.pairing)
            status = "Pairing…";
        else if (device.state === BluetoothDeviceState.Connecting)
            status = "Connecting…";
        else if (device.state === BluetoothDeviceState.Disconnecting)
            status = "Disconnecting…";
        else
            status = device.connected ? "Connected" : device.paired || device.bonded ? "Paired" : "Available";
        if (device.batteryAvailable)
            status += " · " + Math.round(device.battery * 100) + "%";

        return status;
    }

    function iconFor(device) {
        switch (device.icon) {
        case "audio-headset":
        case "audio-headphones":
            return "headphones";
        case "input-mouse":
            return "mouse";
        case "input-keyboard":
            return "keyboard";
        case "phone":
            return "smartphone";
        case "audio-card":
        case "audio-speakers":
            return "speaker";
        case "input-gaming":
            return "gamepad-2";
        case "computer":
            return "laptop";
        default:
            return "bluetooth";
        }
    }

    function clearActions() {
        confirmForget = false;
    }

    function select(device) {
        selected = device;
        clearActions();
        source.error = "";
    }

    function open(device) {
        select(device);
        if (device && !device.connected)
            activate();
    }

    function reset() {
        selected = null;
        clearActions();
    }

    function activate() {
        clearActions();
        if (!selected || source.busy)
            return;

        if (selected.connected)
            source.disconnect(selected);
        else if (selected.paired || selected.bonded)
            source.connect(selected);
        else
            source.pair(selected);
    }

    function forget() {
        if (!selected || source.busy)
            return;

        if (!confirmForget) {
            confirmForget = true;
            return;
        }
        source.forget(selected);
        reset();
    }

    onActiveChanged: {
        if (!active)
            reset();
    }
}
