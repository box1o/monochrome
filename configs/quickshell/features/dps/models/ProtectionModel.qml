import QtQuick

QtObject {
    id: model

    required property QtObject source
    property var drafts: ({
    })
    readonly property var fields: [{
        "key": "ovp",
        "title": "Overvoltage",
        "unit": "V",
        "limit": "maxOvp"
    }, {
        "key": "ocp",
        "title": "Overcurrent",
        "unit": "A",
        "limit": "maxOcp"
    }, {
        "key": "opp",
        "title": "Overpower",
        "unit": "W",
        "limit": "maxOpp"
    }, {
        "key": "otp",
        "title": "Temperature",
        "unit": "°C",
        "limit": "maxOtp"
    }, {
        "key": "uvp",
        "title": "Undervoltage",
        "unit": "V",
        "limit": "maxUvp"
    }]
    readonly property Connections
    events: Connections {
        function onReadyChanged() {
            if (!model.source.ready)
                model.drafts = ({
            });

        }

        function onCompleted(tag, result) {
            if (!tag.startsWith("protection:"))
                return ;

            const next = Object.assign({
            }, model.drafts);
            delete next[tag.slice(11)];
            model.drafts = next;
        }

        target: model.source
    }

    function value(key) {
        return key in drafts ? drafts[key] : Number(source.values[key]) || 0;
    }

    function dirty(key) {
        return key in drafts && Math.abs(drafts[key] - Number(source.values[key])) > 0.005;
    }

    function stage(key, value) {
        drafts = Object.assign({
        }, drafts, {
            [key]: value
        });
    }

    function apply(key) {
        if (source.writable && !source.busy && dirty(key))
            source.request("protection", {
            [key]: drafts[key]
        }, "protection:" + key);

    }

}
