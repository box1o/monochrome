import QtQml

QtObject {
    id: model

    required property QtObject source
    property bool active: false
    property string section: "Connections"
    readonly property var sections: ["Connections", "Devices", "Settings"]

    function selectSection(value) {
        if (sections.includes(value))
            section = value;
    }

    function reset() {
        if (source)
            section = source.tailscale.connected ? "Devices" : "Connections";
    }

    onActiveChanged: {
        if (active)
            reset();
    }
    onSourceChanged: {
        if (active)
            reset();
    }
}
