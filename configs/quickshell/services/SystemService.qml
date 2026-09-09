import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: service
    visible: false
    property var host
    Process { id: pSound }
    function playSound(name) {
        if (host.cfg.uiSounds === false) return;
        var p = Quickshell.env("HOME") + "/.config/quickshell/sounds/" + name + ".wav";
        pSound.command = ["sh", "-c", "command -v pw-play >/dev/null 2>&1 && pw-play \"$1\" >/dev/null 2>&1 || (command -v paplay >/dev/null 2>&1 && paplay \"$1\" >/dev/null 2>&1)", "_", p];
        pSound.running = false;
        pSound.running = true;
    }

    //
    Process { id: pMon; property string args: ""; command: ["sh", "-c", pMon.args] }

    function monCmd(n, o) {
        var mode = o.w + "x" + o.h + "@" + Number(o.rr).toFixed(2);
        var lua = "hl.monitor({ output=\"" + n + "\", mode=\"" + mode
                + "\", position=\"" + o.pos + "\", scale=" + Number(o.scale).toFixed(6)
                + ", transform=" + o.transform + ", vrr=" + (o.vrr ? 1 : 0) + " })";
        var legacy = n + "," + mode + "," + o.pos + "," + Number(o.scale).toFixed(6)
                   + ",transform," + o.transform + ",vrr," + (o.vrr ? 1 : 0);
        return "out=$(hyprctl eval '" + lua + "' 2>&1); case \"$out\" in ok*) ;; *) "
             + "hyprctl keyword monitor '" + legacy + "' ;; esac";
    }

    function monMap() {
        try { return JSON.parse(host.cfg.monOverrides || "{}") || ({}); }
        catch (e) { return ({}); }
    }

    function monApply(n, o) {
        pMon.args = host.monCmd(n, o);
        pMon.running = false;
        pMon.running = true;
        var all = host.monMap();
        all[n] = o;
        host.cfg.monOverrides = JSON.stringify(all);
        host.saveCfg();
    }

    function monReplay() {
        var all = host.monMap(), parts = [];
        for (var n in all) parts.push(host.monCmd(n, all[n]));
        if (!parts.length) return;
        pMon.args = parts.join("; ");
        pMon.running = false;
        pMon.running = true;
    }

    //
    //
    //   type == 1  — Ethernet (ARPHRD_ETHER);
    //
    property string wiredName: ""
    readonly property bool wiredOn: service.wiredName.length > 0

    Process {
        id: pWired
        command: ["sh", "-c",
            "for d in /sys/class/net/*; do " +
            "n=${d##*/}; " +
            "[ -d \"$d/wireless\" ] && continue; " +
            "case $n in lo|docker*|veth*|br-*|virbr*|tun*|tap*|wg*|zt*|tailscale*) continue ;; esac; " +
            "[ \"$(cat $d/type 2>/dev/null)\" = 1 ] || continue; " +
            "[ \"$(cat $d/carrier 2>/dev/null)\" = 1 ] && { echo $n; exit 0; }; " +
            "done"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n");
                service.wiredName = lines.length ? lines[lines.length - 1].trim() : "";
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { pWired.running = false; pWired.running = true; }
    }

    function saveCfg() { viewModel.save(); }

    function tr(k) { return k; }

    function runDetached(cmd) {
        //
        //
        //
        if (Hyprland.usingLua) {
            var safe = String(cmd).replace(/'/g, "\\'");
            Hyprland.dispatch("hl.dsp.exec_cmd('" + safe + "')");
        } else {
            Hyprland.dispatch("exec " + String(cmd));
        }
    }

}
