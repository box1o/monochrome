import QtQml

QtObject {
    id: model

    required property QtObject source
    readonly property bool connected: source?.connected ?? false
    readonly property int percentage: source?.percentage ?? 0
    readonly property string title: connected ? (source?.charging ? "Charging" : "Power connected") : "On battery"
    readonly property QtObject storage: QtObject {
        id: history

        property bool initialized: false
        property bool connected: false
    }

    readonly property Connections observer: Connections {
        function onReadyChanged() {
            model.reconcile();
        }

        function onConnectedChanged() {
            model.reconcile();
        }

        target: model.source
    }

    signal occurred(bool pluggedIn)

    function reconcile() {
        if (!source || !source.ready) {
            history.initialized = false;
            return;
        }
        if (history.initialized && history.connected !== source.connected)
            occurred(source.connected);

        history.connected = source.connected;
        history.initialized = true;
    }

    Component.onCompleted: reconcile()
}
