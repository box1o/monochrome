import QtQml
import Quickshell
import Quickshell.Networking

QtObject {
    id: wifi

    property bool browsing: false
    property QtObject pending: null
    property string error: ""
    property bool passwordRequested: false
    readonly property var adapters: Networking.devices.values.filter(device => device.type === DeviceType.Wifi)
    readonly property QtObject adapter: adapters.find(device => device.connected) || adapters[0] || null
    readonly property bool available: adapter !== null
    readonly property bool hardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool enabled: Networking.wifiEnabled
    readonly property bool busy: pending !== null && pending.stateChanging
    readonly property var networks: adapter ? adapter.networks.values.filter(network => network.name).slice().sort((a, b) => Number(b.connected) - Number(a.connected) || Number(b.known) - Number(a.known) || b.signalStrength - a.signalStrength || a.name.localeCompare(b.name)) : []
    readonly property QtObject connectedNetwork: networks.find(network => network.connected) || null
    readonly property string summary: !available ? "No adapter" : !hardwareEnabled ? "Hardware blocked" : !enabled ? "Off" : (connectedNetwork?.name || "Not connected")

    readonly property Binding scanner: Binding {
        target: wifi.adapter
        property: "scannerEnabled"
        value: wifi.browsing && wifi.enabled
        when: wifi.adapter !== null
        restoreMode: Binding.RestoreBindingOrValue
    }

    readonly property Connections failures: Connections {
        target: wifi.pending
        function onConnectionFailed(reason) {
            wifi.passwordRequested = reason === ConnectionFailReason.NoSecrets && wifi.isPersonal(wifi.pending);
            wifi.error = wifi.passwordRequested ? "Enter the Wi-Fi password and try again." : "Connection failed: " + ConnectionFailReason.toString(reason);
        }
    }

    function isPersonal(network) {
        return network && [WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk, WifiSecurityType.Sae].includes(network.security);
    }

    function needsPassword(network) {
        return isPersonal(network) && (!network.known || (pending === network && passwordRequested));
    }

    function needsSetup(network) {
        return network && !network.known && !isPersonal(network) && ![WifiSecurityType.Open, WifiSecurityType.Owe].includes(network.security);
    }

    function toggle() {
        if (available && hardwareEnabled && !busy) {
            error = "";
            Networking.wifiEnabled = !enabled;
        }
    }

    function connect(network, password = "") {
        if (!network || busy || !enabled)
            return;
        error = "";
        passwordRequested = false;
        pending = network;
        if (password && isPersonal(network))
            network.connectWithPsk(password);
        else if (network.known || [WifiSecurityType.Open, WifiSecurityType.Owe].includes(network.security))
            network.connect();
        else
            error = "Configure this network in Network Settings.";
    }

    function disconnect(network) {
        if (network && !busy) {
            error = "";
            network.disconnect();
        }
    }

    function forget(network) {
        if (network && network.known && !network.connected && !busy)
            network.forget();
    }

    function openSettings() {
        Quickshell.execDetached(["nm-connection-editor"]);
    }
}
