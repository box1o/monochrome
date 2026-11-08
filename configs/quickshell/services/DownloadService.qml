import QtQml
import Quickshell.Io

QtObject {
    id: downloads

    property bool enabled: true
    property var pending: []
    property string directory: ""
    property string error: ""
    property var recent: ({
    })
    readonly property Process inspect: Process {
        property string name: ""
        property string output: ""

        onExited: (code, status) => {
            if (code === 0 && status === 0 && Number(output) > 0) {
                const history = Object.assign({
                }, downloads.recent);
                history[name] = Date.now();
                downloads.recent = history;
                downloads.completed(name.replace(/[\x00-\x1f\x7f]/g, " ").slice(0, 80));
            }
            output = "";
            downloads.verifyNext();
        }

        stdout: StdioCollector {
            onStreamFinished: downloads.inspect.output = text
        }
    }

    readonly property Process location: Process {
        property string output: ""

        command: ["xdg-user-dir", "DOWNLOAD"]
        running: downloads.enabled && downloads.directory.length === 0
        onExited: (code, status) => {
            if (code === 0 && status === 0 && output.startsWith("/"))
                downloads.directory = output;
            else
                downloads.error = "Downloads folder is unavailable";
        }

        stdout: StdioCollector {
            onStreamFinished: downloads.location.output = text.trim()
        }
    }

    readonly property Process monitor: Process {
        command: ["inotifywait", "--monitor", "--quiet", "--event", "close_write,moved_to", "--format", "%e\t%f%0", "--no-newline", downloads.directory]
        running: downloads.enabled && downloads.directory.length > 0
        onExited: downloads.error = "Download event monitor stopped"

        stdout: SplitParser {
            splitMarker: "\u0000"
            onRead: (event) => {
                const separator = event.indexOf("\t");
                if (separator >= 0 && !event.slice(0, separator).includes("ISDIR"))
                    downloads.receive(event.slice(separator + 1));
            }
        }
    }

    signal completed(string name)

    function receive(name) {
        if (!name || name.startsWith(".") || /\.(part|crdownload|tmp|download|swp|swx|lock)$/i.test(name) || name.endsWith("~"))
            return;

        const now = Date.now();
        const history = {
        };
        for (const key of Object.keys(recent)) {
            if (now - recent[key] < 2000)
                history[key] = recent[key];
        }
        recent = history;
        if (name in history || pending.includes(name) || (inspect.running && inspect.name === name))
            return;

        pending = pending.concat(name).slice(-32);
        verifyNext();
    }

    function verifyNext() {
        if (inspect.running || pending.length === 0)
            return;

        inspect.name = pending[0];
        pending = pending.slice(1);
        inspect.command = ["stat", "--format=%s", "--", directory + "/" + inspect.name];
        inspect.running = true;
    }
}
