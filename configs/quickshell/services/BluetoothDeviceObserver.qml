import QtQml

QtObject {
    id: observer

    required property QtObject device
    property bool initialized: false
    property bool lastConnected: false
    readonly property Connections changes: Connections {
        function onConnectedChanged() {
            if (observer.initialized)
                settle.restart();
        }

        target: observer.device
    }
    // A brief settle avoids repeating feedback during rapid profile negotiation.

    readonly property Timer settle: Timer {
        interval: 180
        onTriggered: {
            if (!observer.device || observer.lastConnected === observer.device.connected)
                return;

            observer.lastConnected = observer.device.connected;
            observer.connectionChanged(observer.lastConnected);
        }
    }

    signal connectionChanged(bool connected)

    Component.onCompleted: {
        lastConnected = device.connected;
        initialized = true;
    }
}
