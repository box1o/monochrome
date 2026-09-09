import QtQuick
import Quickshell
import "config"

// Shared application model for the shell view. It owns persisted settings and
// the domain state services; visual components consume this through ShellView.
Item {
    visible: false
    id: model

    ConfigStore {
        id: cfgFile
        configPath: Quickshell.env("HOME") + "/.config/quickshell/config/settings.json"
        onFileChanged: reload()
    }

    readonly property var cfg: cfgFile.adapter
    property alias appState: state
    property alias expanded: state.expanded
    property alias page: state.page
    property alias holdOpen: state.holdOpen
    property alias freezeShot: state.freezeShot

    AppState {
        id: state
        config: model.cfg
    }

    Theme {
        id: themeObject
        cfg: model.cfg
    }
    readonly property var theme: themeObject

    function save() {
        cfgFile.writeAdapter()
    }
}
