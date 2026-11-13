import QtQuick

QtObject {
    id: model

    required property QtObject source
    property real voltage: 0
    property real current: 0
    property bool edited: false
    property bool sending: false
    property bool failed: false
    property int revision: 0
    property int sentRevision: 0
    readonly property real maxVoltage: Math.max(0, Math.min(30, Number(source.values.maxVoltage) || 0))
    readonly property real maxCurrent: Math.max(0, Math.min(5, Number(source.values.maxCurrent) || 0))
    readonly property bool dirty: edited && (Math.abs(voltage - Number(source.values.setVoltage)) > 0.005 || Math.abs(current - Number(source.values.setCurrent)) > 0.0005)
    readonly property bool valid: voltage >= 0 && voltage <= maxVoltage && current >= 0 && current <= maxCurrent
    readonly property Timer
    update: Timer {
        interval: 100
        onTriggered: model.send()
    }

    readonly property Connections
    events: Connections {
        function onReadyChanged() {
            update.stop();
            model.edited = false;
            model.sending = false;
            model.failed = false;
            if (model.source.ready)
                model.reset();

        }

        function onStateChanged() {
            if (!model.edited && !model.sending && model.source.ready)
                model.reset();

        }

        function onCompleted(tag, result) {
            if (tag !== "setpoint")
                return ;

            model.sending = false;
            if (model.sentRevision === model.revision)
                model.reset();
            else
                update.restart();
        }

        function onFailed(tag) {
            if (tag !== "setpoint")
                return ;

            update.stop();
            model.sending = false;
            model.failed = true;
        }

        target: model.source
    }

    function reset() {
        voltage = Number(source.values.setVoltage) || 0;
        current = Number(source.values.setCurrent) || 0;
        edited = false;
        failed = false;
    }

    function setValues(nextVoltage, nextCurrent) {
        if (!source.writable)
            return ;

        voltage = Number(nextVoltage.toFixed(2));
        current = Number(nextCurrent.toFixed(3));
        edited = true;
        failed = false;
        revision++;
        if (!update.running)
            update.start();

    }

    function send() {
        if (!source.writable || !valid || failed)
            return ;

        if (!dirty) {
            edited = false;
            return ;
        }
        if (sending || source.busy) {
            update.restart();
            return ;
        }
        sentRevision = revision;
        sending = source.request("set", {
            "voltage": voltage,
            "current": current
        }, "setpoint");
    }

    function retry() {
        failed = false;
        update.restart();
    }

}
