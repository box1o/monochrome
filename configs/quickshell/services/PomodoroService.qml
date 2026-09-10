import QtQuick
import Quickshell
import Quickshell.Io

Item {
    visible: false
    id: service
    property var config

    property bool running: false
    property string phase: "work"
    property int workSeconds: 25 * 60
    property int breakSeconds: 5 * 60
    property int totalSeconds: workSeconds
    property int remainingSeconds: totalSeconds

    readonly property string phaseLabel: phase === "work" ? "Focus" : "Break"
    readonly property string timeText: {
        var minutes = Math.floor(Math.max(0, remainingSeconds) / 60);
        var seconds = Math.max(0, remainingSeconds) % 60;
        return (minutes < 10 ? "0" : "") + minutes + ":"
             + (seconds < 10 ? "0" : "") + seconds;
    }
    readonly property real progress: totalSeconds > 0
                                      ? 1 - remainingSeconds / totalSeconds : 0

    Process { id: soundProcess }

    function playSound(name) {
        if (service.config && service.config.uiSounds === false) return;
        var path = Quickshell.env("HOME") + "/.config/quickshell/sounds/" + name + ".wav";
        soundProcess.command = ["sh", "-c",
            "command -v pw-play >/dev/null 2>&1 && pw-play \"$1\" >/dev/null 2>&1 || "
          + "(command -v paplay >/dev/null 2>&1 && paplay \"$1\" >/dev/null 2>&1)", "_", path];
        soundProcess.running = false;
        soundProcess.running = true;
    }

    Timer {
        interval: 1000
        repeat: true
        running: service.running
        onTriggered: service.tick()
    }

    function start() {
        if (service.running) return;
        service.running = true;
        service.playSound("connect");
    }

    function stop() {
        if (!service.running) return;
        service.running = false;
        service.playSound("disconnect");
    }

    function toggle() {
        if (service.running) service.stop();
        else service.start();
    }

    function reset() {
        service.running = false;
        service.phase = "work";
        service.totalSeconds = service.workSeconds;
        service.remainingSeconds = service.totalSeconds;
    }

    function tick() {
        if (service.remainingSeconds > 0) {
            service.remainingSeconds -= 1;
            return;
        }
        service.phase = service.phase === "work" ? "break" : "work";
        service.totalSeconds = service.phase === "work"
                             ? service.workSeconds : service.breakSeconds;
        service.remainingSeconds = service.totalSeconds;
        service.playSound(service.phase === "work" ? "connect" : "charge");
    }
}
