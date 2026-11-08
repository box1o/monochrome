import QtQml

QtObject {
    id: model

    required property QtObject source
    property bool active: false
    property string pending: ""
    property int current: 0
    readonly property var actions: source.actions
    readonly property bool busy: source.busy
    readonly property string error: source.error
    readonly property Timer confirmation: Timer {
        interval: 2600
        onTriggered: model.resetConfirmation()
    }

    function resetConfirmation() {
        pending = "";
        confirmation.stop();
    }

    function moveSelection(delta) {
        current = Math.max(0, Math.min(actions.length - 1, current + delta));
        resetConfirmation();
    }

    function activateCurrent() {
        request(actions[current].id);
    }

    function request(id) {
        const index = actions.findIndex(item => item.id === id);
        if (!active || busy || index < 0)
            return;

        current = index;
        if (id !== "lock" && pending !== id) {
            pending = id;
            confirmation.restart();
            return;
        }
        resetConfirmation();
        source.execute(id);
    }

    onActiveChanged: resetConfirmation()
}
