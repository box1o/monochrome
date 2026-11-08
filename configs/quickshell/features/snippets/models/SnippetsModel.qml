import QtQuick
import "SnippetData.js" as Data

QtObject {
    id: model

    required property QtObject source
    property var editingEntry: null
    property string draftTitle: ""
    property string draftBody: ""
    readonly property bool editing: editingEntry !== null
    readonly property bool canSave: source.available && editing && draftTitle.trim().length > 0 && draftBody.length > 0 && !source.busy
    readonly property Connections persistence: Connections {
        function onAdded() {
            model.query = "";
            model.selectedIndex = 0;
        }

        function onSaved() {
            model.closeEditor();
        }

        target: model.source
    }

    property string query: ""
    property int selectedIndex: 0
    readonly property var searchIndex: Data.index(source.catalog.snippets)
    readonly property var results: Data.search(searchIndex, query)
    readonly property var selected: results[selectedIndex] || null

    function openEditor(entry) {
        editingEntry = entry;
        draftTitle = entry.title;
        draftBody = entry.body;
    }

    function closeEditor() {
        editingEntry = null;
        draftTitle = "";
        draftBody = "";
    }

    function save() {
        if (canSave)
            source.save(editingEntry.id, draftTitle.trim(), draftBody);
    }

    function reset() {
        closeEditor();
        query = "";
        selectedIndex = 0;
        source.refresh();
    }

    function moveSelection(delta) {
        selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta));
    }

    function copy() {
        if (selected && source.available)
            source.copy(selected.body);
    }

    onQueryChanged: selectedIndex = 0
    onResultsChanged: selectedIndex = Math.max(0, Math.min(selectedIndex, results.length - 1))
}
