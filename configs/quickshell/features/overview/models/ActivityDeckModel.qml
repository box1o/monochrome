import QtQml

QtObject {
    id: model

    required property QtObject media
    property bool active: false
    property int currentIndex: 1
    readonly property Binding monitoring: Binding {
        target: model.media
        property: "monitoring"
        value: model.active && model.currentIndex === 0
        restoreMode: Binding.RestoreBindingOrValue
    }

    function select(index) {
        if (index === 0 || index === 1)
            currentIndex = index;
    }
}
