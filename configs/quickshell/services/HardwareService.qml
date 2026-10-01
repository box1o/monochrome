import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service
    visible: false
    property var host
    //
    property string brightBackend: "none"   // backlight | ddc | none
    property bool   hasTouchpad: false
    property bool   ddcutilPresent: false
    property bool   keepAwake: true

    Process {
        running: service.keepAwake
        command: ["systemd-inhibit", "--what=idle:sleep:handle-lid-switch",
                  "--who=Mono", "--why=Keep awake", "sleep", "infinity"]
    }
    readonly property bool isLaptop: host.batteryPresent
    readonly property bool showBattery: host.batteryPresent
    readonly property bool showPowerProfiles: host.batteryPresent

    Process {
        id: pMachine
        running: true
        command: [host.scriptDir + "/brightness.sh", "detect"]
        stdout: StdioCollector {
            onStreamFinished: {
                var t = text.slice(text.lastIndexOf("backend="));
                t.trim().split("\n").forEach(function (line) {
                    var p = line.split("=");
                    if (p.length !== 2) return;
                    if (p[0] === "backend")  service.brightBackend  = p[1].trim();
                    if (p[0] === "touchpad") service.hasTouchpad    = p[1].trim() === "1";
                    if (p[0] === "ddcutil")  service.ddcutilPresent = p[1].trim() === "1";
                });
                host.brightRefresh(false);
            }
        }
    }

    property int loadCpu:  -1
    property int loadMem:  -1
    property int loadGpu:  -1
    property int loadTempCpu: -1
    property int loadTempGpu: -1

    readonly property bool loadWanted: host.expanded

    Process {
        id: pLoad
        command: [host.scriptDir + "/sysload.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var recs = String(text).trim().split("\n").filter(r => r.indexOf("|") >= 0);
                if (!recs.length) return;
                var a = recs[recs.length - 1].split("|");
                function num(s) {
                    s = String(s || "").trim();
                    return s.length ? (+s) : -1;
                }
                service.loadCpu = num(a[0]);
                service.loadMem = num(a[1]);
                service.loadGpu = num(a[2]);
                service.loadTempCpu = num(a[3]);
                service.loadTempGpu = num(a[4]);
            }
        }
    }

    Timer {
        interval: 2000
        running: host.loadWanted
        repeat: true
        triggeredOnStart: true
        onTriggered: { pLoad.running = false; pLoad.running = true; }
    }

    property var brightList: []
    property bool brightBusy: false

    Process {
        id: pBrightList
        command: [host.scriptDir + "/brightness.sh", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = [];
                text.trim().split("\n").forEach(function (line) {
                    var p = line.split("\t");
                    if (p.length < 3) return;
                    var pct = parseInt(p[2]);
                    if (isNaN(pct)) return;
                    out.push({ id: p[0], name: p[1], pct: pct });
                });
                service.brightList = out;
                service.brightBusy = false;
            }
        }
    }

    function brightRefresh(rescan) {
        if (service.brightBackend === "none") return;
        service.brightBusy = true;
        pBrightList.command = [host.scriptDir + "/brightness.sh", rescan ? "rescan" : "list"];
        pBrightList.running = false;
        pBrightList.running = true;
    }

    Process { id: pBrightSet }
    property string brightPendingId: ""
    property int    brightPendingPct: -1

    Timer {
        id: brightFlush
        interval: 180
        repeat: false
        onTriggered: {
            if (service.brightPendingPct < 0) return;
            pBrightSet.command = [host.scriptDir + "/brightness.sh", "set",
                                  service.brightPendingId, String(service.brightPendingPct)];
            pBrightSet.running = false;
            pBrightSet.running = true;
            service.brightPendingPct = -1;
        }
    }

    function brightSet(id, pct) {
        pct = Math.max(1, Math.min(100, Math.round(pct)));
        var l = service.brightList.slice();
        for (var i = 0; i < l.length; i++)
            if (l[i].id === id) l[i] = { id: id, name: l[i].name, pct: pct };
        service.brightList = l;

        service.brightPendingId = id;
        service.brightPendingPct = pct;
        brightFlush.restart();
    }

}
