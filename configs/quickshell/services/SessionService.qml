import QtQml
import Quickshell
import Quickshell.Io

QtObject {
    id: session

    property string error: ""
    readonly property bool busy: action.running
    readonly property string helper: Quickshell.env("HOME") + "/.local/bin/mono-session"
    readonly property var actions: [{
        "id": "lock",
        "title": "Lock",
        "icon": "lock-keyhole"
    }, {
        "id": "suspend",
        "title": "Sleep",
        "icon": "moon"
    }, {
        "id": "logout",
        "title": "Log out",
        "icon": "log-out"
    }, {
        "id": "reboot",
        "title": "Restart",
        "icon": "rotate-ccw"
    }, {
        "id": "poweroff",
        "title": "Shut down",
        "icon": "power"
    }]
    readonly property Process action: Process {
        onExited: (code, status) => {
            if (code !== 0 || status !== 0)
                session.error = "The session action could not be completed";
        }
    }

    function execute(id) {
        if (busy || !actions.some(item => item.id === id))
            return;

        error = "";
        action.command = id === "reboot" || id === "poweroff" ? ["systemctl", id] : [helper, id];
        action.running = true;
    }
}
