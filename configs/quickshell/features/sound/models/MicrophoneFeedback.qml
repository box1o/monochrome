import QtQml

QtObject {
    id: feedback

    required property QtObject source
    property QtObject microphone: null
    property bool initialized: false
    property bool muted: false
    readonly property Connections observer: Connections {
        function onMicrophoneChanged() {
            feedback.reconcile();
        }

        function onMicrophoneAvailableChanged() {
            feedback.reconcile();
        }

        function onMicrophoneMutedChanged() {
            feedback.reconcile();
        }

        target: feedback.source
    }

    signal changed(bool muted)

    function reconcile() {
        if (!source.microphoneAvailable) {
            initialized = false;
            return;
        }
        if (!initialized || microphone !== source.microphone) {
            microphone = source.microphone;
            muted = source.microphoneMuted;
            initialized = true;
            return;
        }
        if (muted !== source.microphoneMuted) {
            muted = source.microphoneMuted;
            changed(muted);
        }
    }

    Component.onCompleted: reconcile()
}
