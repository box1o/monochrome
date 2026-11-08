import QtQml
import "ApplicationSearch.js" as ApplicationSearch

QtObject {
    id: launcher

    required property QtObject applications
    property string query: ""
    property int selectedIndex: 0
    readonly property var results: ApplicationSearch.search(applications.entries, query, applications.usage)

    signal closeRequested

    function reset() {
        query = "";
        selectedIndex = 0;
    }

    function moveSelection(delta) {
        selectedIndex = Math.max(0, Math.min(results.length - 1, selectedIndex + delta));
    }

    function launch(index = selectedIndex) {
        if (index >= 0 && index < results.length)
            applications.launch(results[index]);

        closeRequested();
    }

    onResultsChanged: selectedIndex = 0
}
