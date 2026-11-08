import QtQml
import QtCore
import "UsageHistory.js" as UsageHistory

QtObject {
    id: usage

    required property url path
    readonly property var entries: UsageHistory.parse(storage.history)
    readonly property Settings storage: Settings {
        property string history: "{}"

        location: usage.path
    }

    function record(id) {
        if (!id)
            return;

        storage.history = JSON.stringify(UsageHistory.record(entries, id, Date.now()));
        storage.sync();
    }
}
