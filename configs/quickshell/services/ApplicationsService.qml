import QtQml
import Quickshell

QtObject {
    readonly property var usage: history.entries
    readonly property ApplicationUsage history: ApplicationUsage {
        path: "file://" + (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/mono/launcher.ini"
    }

    readonly property var entries: DesktopEntries.applications.values

    function launch(entry) {
        if (!entry || entry.noDisplay)
            return false;

        entry.execute();
        history.record(entry.id);
        return true;
    }
}
