import QtQml

QtObject {
    id: model

    required property QtObject source
    property bool active: false
    property QtObject selected: null
    property bool confirmForget: false
    readonly property bool passwordNeeded: selected !== null && source.needsPassword(selected)
    readonly property Binding browsing: Binding {
        target: model.source
        property: "browsing"
        value: model.active
        restoreMode: Binding.RestoreBindingOrValue
    }

    function describe(network) {
        const state = network.stateChanging ? "Working…" : network.connected ? "Connected" : network.known ? "Saved" : "Available";
        return state + " · " + Math.round(network.signalStrength * 100) + "%";
    }

    function select(network) {
        selected = network;
        confirmForget = false;
        source.error = "";
    }

    function reset() {
        selected = null;
        confirmForget = false;
    }

    function connect(password) {
        confirmForget = false;
        source.connect(selected, password);
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
