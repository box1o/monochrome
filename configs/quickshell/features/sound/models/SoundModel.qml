import QtQml

QtObject {
    id: model

    required property QtObject source
    required property QtObject profiles
    property bool active: false
    property string section: "Applications"
    readonly property var sections: ["Applications", "Output", "Input", "Codec"]

    function selectSection(value) {
        if (sections.includes(value))
            section = value;
    }

    onActiveChanged: {
        if (active)
            section = "Applications";
    }

    readonly property Binding browsing: Binding {
        target: model.source
        property: "browsing"
        value: model.active
        restoreMode: Binding.RestoreBindingOrValue
    }

    readonly property Binding microphone: Binding {
        target: model.source
        property: "monitoringInput"
        value: model.active && model.section === "Input"
        restoreMode: Binding.RestoreBindingOrValue
    }

    readonly property Binding codecs: Binding {
        target: model.profiles
        property: "active"
        value: model.active && model.section === "Codec"
        restoreMode: Binding.RestoreBindingOrValue
    }
}
