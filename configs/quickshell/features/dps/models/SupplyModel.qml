import QtQuick

QtObject {
    id: model

    required property QtObject source
    property bool active: false
    property string section: "Control"
    readonly property var sections: ["Control", "Presets", "Settings"]
    readonly property QtObject
    control: SetpointModel {
        source: model.source
    }

    readonly property QtObject
    protections: ProtectionModel {
        source: model.source
    }

    property int selectedPreset: 0
    property int editingPreset: 0
    property real presetVoltage: 0
    property real presetCurrent: 0
    readonly property bool outputOn: source.ready && source.values.outputEnabled === 1
    readonly property Connections
    events: Connections {
        function onReadyChanged() {
            model.selectedPreset = 0;
            model.editingPreset = 0;
            if (model.active && model.source.ready)
                model.source.details();

        }

        function onCompleted(tag, result) {
            if (tag === "preset-save")
                model.editingPreset = 0;

        }

        target: model.source
    }

    function toggleOutput() {
        if (source.ready && !source.busy && (outputOn || source.writable && !control.dirty))
            source.request("output", {
            "enabled": !outputOn
        }, "output");

    }

    function preset(number) {
        const voltage = source.values["preset" + number + "Voltage"];
        const current = source.values["preset" + number + "Current"];
        return {
            "voltage": voltage,
            "current": current,
            "loaded": Number.isFinite(voltage) && Number.isFinite(current)
        };
    }

    function loadPreset(number) {
        const item = preset(number);
        if (!item.loaded || !source.writable)
            return ;

        selectedPreset = number;
        control.setValues(item.voltage, item.current);
        section = "Control";
    }

    function editPreset(number) {
        const item = preset(number);
        if (!item.loaded)
            return ;

        presetVoltage = item.voltage;
        presetCurrent = item.current;
        editingPreset = number;
    }

    function savePreset() {
        if (!source.writable || source.busy || !editingPreset)
            return ;

        if (presetVoltage < 0 || presetVoltage > control.maxVoltage || presetCurrent < 0 || presetCurrent > control.maxCurrent)
            return ;

        source.request("preset", {
            "number": editingPreset,
            "voltage": presetVoltage,
            "current": presetCurrent
        }, "preset-save");
    }

    onActiveChanged: {
        if (active && source && source.ready)
            source.details();

    }
}
