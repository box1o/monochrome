import QtQml

QtObject {
    property bool enabled: true

    function toggle() {
        enabled = !enabled;
    }
}
