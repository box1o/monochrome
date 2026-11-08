import QtQuick
import Quickshell
import Quickshell.Io
import "../features/snippets/models/SnippetData.js" as Data

QtObject {
    id: service

    property var catalog: ({
        "snippets": []
    })
    property string operationError: ""
    property string discoveryError: ""
    property bool loaded: false
    property string snapshot: ""
    property bool refreshQueued: false
    readonly property string error: operationError || discoveryError
    readonly property bool available: loaded && !discoveryError.length
    readonly property bool busy: loader.running || action.running
    property string helper: Quickshell.env("HOME") + "/.local/libexec/mono/desktop/snippets.sh"
    readonly property Process loader: Process {
        command: ["bash", service.helper, "list"]
        onExited: (code, status) => {
            if (code !== 0 || status !== 0)
                service.discoveryError = "Cannot read snippets. Open Edit to check the YAML file.";
            else
                service.readSnapshot(output.text);
            if (service.refreshQueued)
                Qt.callLater(service.refresh);
        }

        stdout: StdioCollector {
            id: output
        }

        stderr: StdioCollector {
        }
    }

    readonly property Process action: Process {
        property string operation: ""
        property string payload: ""

        onStarted: {
            if (operation === "copy" || operation === "save") {
                write(payload);
                stdinEnabled = false;
                payload = "";
            }
        }
        onExited: (code, status) => {
            payload = "";
            if (code !== 0 || status !== 0) {
                const errors = {
                    "save": "Could not save snippet",
                    "copy": "Could not copy snippet",
                    "add": "Could not add clipboard text",
                    "delete": "Could not delete snippet",
                    "edit": "Could not open Neovim"
                };
                service.operationError = errors[operation] || "Snippet operation failed";
                if (service.refreshQueued)
                    Qt.callLater(service.refresh);

                return;
            }
            service.operationError = "";
            if (operation === "copy") {
                service.copied();
            } else {
                if (operation === "save")
                    service.saved();

                if (operation === "add")
                    service.added();

                Qt.callLater(service.refresh);
            }
            if (service.refreshQueued)
                Qt.callLater(service.refresh);
        }

        stderr: StdioCollector {
        }
    }

    signal saved()
    signal added()
    signal copied()
    signal editing()

    function refresh() {
        if (busy) {
            refreshQueued = true;
            return;
        }
        refreshQueued = false;
        loader.running = true;
    }

    function readSnapshot(text) {
        try {
            if (!loaded || text !== snapshot) {
                catalog = Data.validate(JSON.parse(text));
                snapshot = text;
            }
            discoveryError = "";
            loaded = true;
        } catch (error) {
            discoveryError = "Invalid snippets: " + error.message;
        }
    }

    function run(operation, id = "", payload = "") {
        if (busy)
            return false;

        operationError = "";
        action.operation = operation;
        action.payload = payload;
        action.stdinEnabled = operation === "copy" || operation === "save";
        action.command = ["bash", helper, operation].concat(id ? [id] : []);
        action.running = true;
        return true;
    }

    function add() {
        if (available)
            run("add");
    }

    function remove(id) {
        if (available && catalog.snippets.some(entry => entry.id === id))
            run("delete", id);
    }

    function save(id, title, body) {
        if (available && title.trim().length && body.length)
            run("save", id, JSON.stringify({
            "title": title,
            "body": body
        }));
    }

    function edit() {
        if (run("edit"))
            editing();
    }

    function copy(text) {
        if (available && text.length)
            run("copy", "", text);
    }
}
