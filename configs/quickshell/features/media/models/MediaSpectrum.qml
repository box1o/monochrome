import QtQml
import Quickshell
import Quickshell.Io

QtObject {
    id: spectrum

    property bool active: false
    property var levels: []
    readonly property int barCount: 46
    readonly property Process source: Process {
        command: ["cava", "-p", Quickshell.env("HOME") + "/.local/libexec/mono/audio/spectrum.conf"]
        running: spectrum.active

        stdout: SplitParser {
            onRead: (line) => {
                const values = line.trim().split(";");
                if (values.length < spectrum.barCount)
                    return;

                spectrum.levels = values.slice(0, spectrum.barCount).map((value) => {
                    const level = Number(value);
                    return Number.isFinite(level) ? Math.max(0, Math.min(1, level / 100)) : 0;
                });
            }
        }
    }

    onActiveChanged: {
        if (!active)
            levels = [];
    }
}
