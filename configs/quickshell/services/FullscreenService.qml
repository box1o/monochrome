import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: service
    visible: false
    property var host
    property bool fullscreenActive: false
    function probe() { fsProbe.restart() }
    function replay() { monReplayTimer.restart() }
    Process {
        id: pFullscreen
        command: ["sh", "-c",
            "hyprctl activewindow -j 2>/dev/null | grep -o '\"fullscreen\": *[0-9]*' | grep -o '[0-9]*$'"]
        stdout: StdioCollector {
            onStreamFinished: host.fullscreenActive = parseInt(text.trim()) > 0
        }
    }
    Timer { id: fsProbe; interval: 120; onTriggered: pFullscreen.running = true }
    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: pFullscreen.running = true
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            var n = String(event.name);
            if (n === "fullscreen" || n === "activewindow" || n === "activewindowv2"
                || n === "closewindow" || n === "openwindow" || n === "workspace"
                || n === "focusedmon")
                fsProbe.restart();
            if (n === "configreloaded") monReplayTimer.restart();
        }
    }
    Timer {
        id: monReplayTimer
        interval: 400
        onTriggered: host.monReplay()
    }

}
