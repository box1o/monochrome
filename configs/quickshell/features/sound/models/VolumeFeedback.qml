import QtQml

QtObject {
    id: feedback

    required property QtObject source
    readonly property QtObject history: QtObject {
        property QtObject sink: null
        property bool initialized: false
        property real volume: 0
        property bool muted: false
    }

    readonly property Connections observer: Connections {
        function onVolumeChanged() {
            feedback.reconcile();
        }

        function onMutedChanged() {
            feedback.reconcile();
        }

        function onSinkChanged() {
            feedback.reconcile();
        }

        function onAvailableChanged() {
            feedback.reconcile();
        }

        target: feedback.source
    }

    readonly property Timer settle: Timer {
        interval: 80
        onTriggered: feedback.changed(feedback.source.volume, feedback.source.muted)
    }

    signal changed(real volume, bool muted)

    function reconcile() {
        if (!source.available) {
            history.initialized = false;
            settle.stop();
            return;
        }
        if (!history.initialized || history.sink !== source.sink) {
            settle.stop();
            history.sink = source.sink;
            history.volume = source.volume;
            history.muted = source.muted;
            history.initialized = true;
            return;
        }
        if (Math.abs(history.volume - source.volume) > 0.0001 || history.muted !== source.muted) {
            history.volume = source.volume;
            history.muted = source.muted;
            settle.restart();
        }
    }

    Component.onCompleted: reconcile()
}
