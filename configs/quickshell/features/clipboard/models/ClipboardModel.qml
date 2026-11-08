import QtQml
import "ClipboardSearch.js" as ClipboardSearch

QtObject {
    id: model

    required property QtObject source
    property bool active: false
    property string query: ""
    property int selectedIndex: 0
    readonly property var results: ClipboardSearch.search(source.entries, query)
    readonly property Binding browsing: Binding {
        target: model.source
        property: "browsing"
        value: model.active
        restoreMode: Binding.RestoreBindingOrValue
    }

    function reset() {
        query = "";
        selectedIndex = 0;
    }

    function moveSelection(delta) {
        selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta));
    }

    function copy(index = selectedIndex) {
        if (index >= 0 && index < results.length)
            source.perform("copy", results[index].id);
    }

    onResultsChanged: selectedIndex = Math.max(0, Math.min(selectedIndex, results.length - 1))
    onQueryChanged: selectedIndex = 0
}
