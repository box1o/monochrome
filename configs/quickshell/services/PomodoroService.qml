import QtQuick

Item {
    visible: false
    id: service

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

    Timer {
        interval: 1000
        repeat: true
        running: service.running
        onTriggered: service.tick()
    }

    function start() { service.running = true; }
    function stop() { service.running = false; }
    function toggle() { service.running = !service.running; }

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
    }
}
