import QtQml

QtObject {
    id: state

    property int closeDelay: 180
    property bool hoverOpenEnabled: true
    property bool pinned: false
    readonly property bool expanded: internal.open
    readonly property QtObject storage: QtObject {
        id: internal

        property bool open: false
    }

    readonly property Timer closeTimer: Timer {
        interval: state.closeDelay
        onTriggered: {
            if (!state.pinned)
                state.close("hover");
        }
    }

    signal dismissed(string reason)

    function open() {
        closeTimer.stop();
        internal.open = true;
    }

    function setHovered(hovered) {
        if (hovered) {
            closeTimer.stop();
            if (hoverOpenEnabled)
                open();
        } else if (!pinned) {
            closeTimer.restart();
        }
    }

    function close(reason = "explicit") {
        closeTimer.stop();
        if (!internal.open)
            return;

        internal.open = false;
        dismissed(reason);
    }
}
