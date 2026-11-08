import QtQml
import Quickshell

QtObject {
    id: model

    property bool active: false
    property QtObject trayItem: null
    property var chain: []
    readonly property string title: trayItem ? (trayItem.tooltipTitle || trayItem.title || trayItem.id) : "Tray"
    readonly property var entries: chain.length > 0 ? submenu.children : root.children
    // Keep the root open so submenu entries retain their owning menu tree.
    readonly property QsMenuOpener root: QsMenuOpener {
        menu: model.trayItem ? model.trayItem.menu : null
    }

    readonly property QsMenuOpener submenu: QsMenuOpener {
        menu: model.chain.length > 0 ? model.chain[model.chain.length - 1] : null
    }

    signal actionInvoked
    signal backRequested

    onTrayItemChanged: {
        chain = [];
        if (active && !trayItem)
            backRequested();
    }

    function open(item) {
        if (!item || !item.hasMenu)
            return false;

        chain = [];
        trayItem = item;
        return true;
    }

    function reset() {
        chain = [];
        trayItem = null;
    }

    function back() {
        if (chain.length > 0)
            chain = chain.slice(0, -1);
        else
            backRequested();
    }

    function activate(entry) {
        if (!entry || !entry.enabled || entry.isSeparator)
            return;

        if (entry.hasChildren) {
            chain = chain.concat([entry]);
        } else {
            entry.triggered();
            actionInvoked();
        }
    }

    onActiveChanged: {
        if (!active)
            reset();
    }
}
