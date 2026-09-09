import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: router
    property QtObject rootState
    width: 0
    height: 0
    visible: false

    IpcHandler {
        id: handler
        target: "mono"
        function launcher(): void { router.rootState.toggleLauncher(); }
        function controls(): void { router.rootState.togglePage("main"); }
        function toggle(): void { router.rootState.togglePage("main"); }
        function wifi(): void {
            if (router.rootState.expanded && router.rootState.page === "wifi") { router.rootState.collapse(); return; }
            router.rootState.togglePage("wifi");
            router.rootState.refreshWifiList(); router.rootState.scanWifi();
        }
        function bluetooth(): void {
            if (router.rootState.expanded && router.rootState.page === "bt") { router.rootState.collapse(); return; }
            router.rootState.togglePage("bt");
            router.rootState.scanBt();
        }
        function settings(): void { router.rootState.togglePage("settings"); }
        function clipboard(): void { router.rootState.togglePage("clip"); }
        function powermenu(): void { router.rootState.togglePage("power"); }
        function smartClose(): string {
            if (!router.rootState.cfg.closeMonoFirst) return "disabled";
            if (router.rootState.expanded) {
                router.rootState.collapse();
                return "closed_overlay";
            }
            return "none";
        }
        function freeze(path: string): void { router.rootState.freezeShot = "file://" + path; }
        function unfreeze(): void { router.rootState.freezeShot = ""; }
        function shotCopied(path: string): void { router.rootState.shotCopied(path); }
        function notifications(): void { router.rootState.togglePage("notif"); }
        function audio(): void { router.rootState.togglePage("audio"); }
        function scrcpy(): void { router.rootState.openScrcpy(); }
        function calendar(): void { router.rootState.togglePage("cal"); }
        function dnd(): void { router.rootState.toggleDnd(); }
        function brightness(pct: string): void {
            var v = parseFloat(pct);
            router.rootState.showOsd("bright", v / 100.0, false);
            var values = router.rootState.brightList.slice();
            var hit = false;
            for (var i = 0; i < values.length; i++) {
                if (String(values[i].id).indexOf("bl:") === 0 || values.length === 1) {
                    values[i] = { id: values[i].id, name: values[i].name, pct: Math.round(v) };
                    hit = true;
                }
            }
            if (hit) router.rootState.brightList = values;
            else if (values.length === 0) router.rootState.brightRefresh(false);
        }
        function motion(on: string): void {
            router.rootState.cfg.reduceMotion = (on !== "on");
            router.rootState.saveCfg();
        }
        function close(): void { router.rootState.collapse(); }
    }
}
