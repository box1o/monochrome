import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell

Item {
    id: service
    visible: false
    property var host
    readonly property var trayItems: SystemTray.items

    property bool dnd: host.cfg.notifDnd
    function toggleDnd() { host.cfg.notifDnd = !host.cfg.notifDnd; host.saveCfg(); }
    property var  notifCurrent: null
    ListModel { id: notifModel }
    readonly property var notifications: notifModel
    property var notifServer: notifLoader.item
    Loader {
        id: notifLoader
        active: true
        sourceComponent: notifServerComp
    }
    readonly property var activeNotifications:
        notifServer ? notifServer.trackedNotifications : null

    property var notifObjs: ({})

    Process { id: pFocusApp }
    function focusApp(hint) {
        var h = String(hint || "").trim();
        if (h.length === 0) return;
        pFocusApp.running = false;
        pFocusApp.command = [host.scriptDir + "/focusapp.sh", h];
        pFocusApp.running = true;
    }

    //
    property bool hoverExpandArmed: true

    //
    function activateNotification(what) {
        var n = null;
        var id = -1;
        if (what !== null && typeof what === "object") {
            n = what;
            id = Number(what.id);
        } else {
            id = Number(what);
            n = service.notifObjs[String(id)] || null;
        }
        var hint = "";
        if (n) {
            hint = String(n.desktopEntry || "") || String(n.appName || "");
            var acts = n.actions || [];
            var used = false;
            for (var i = 0; i < acts.length; i++) {
                if (String(acts[i].identifier) === "default") {
                    acts[i].invoke(); used = true; break;
                }
            }
            if (!used && acts.length === 1) acts[0].invoke();
        }
        host.focusApp(hint);
        host.dismissToast();
        if (id >= 0) host.dropNotification(id);
        host.hoverExpandArmed = false;
        capsuleHover.markArmPoint();
        host.collapse();
    }

    readonly property bool toastActive: notifCurrent !== null && !expanded
    readonly property string notifSummary: notifCurrent ? String(notifCurrent.summary || "") : ""
    readonly property string notifBody:    notifCurrent ? String(notifCurrent.body || "") : ""
    readonly property string notifApp:     notifCurrent ? String(notifCurrent.appName || "") : ""
    readonly property string notifImage:   notifCurrent ? host.notifIconFor(notifCurrent) : ""

    function notifIconFor(n) {
        var img = String(n.image || "");
        if (img.length === 0) img = String(n.appIcon || "");
        if (img.length === 0) return "";
        if (img.indexOf("image://icon/") === 0)
            return Quickshell.iconPath(img.substring(13).split("?")[0], true);
        if (img.indexOf("/") >= 0 || img.indexOf(":") >= 0) return img;
        return Quickshell.iconPath(img, true);
    }
    readonly property bool   notifUrgent:
        notifCurrent ? notifCurrent.urgency === NotificationUrgency.Critical : false

    Component {
    id: notifServerComp
    NotificationServer {
        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;

            var app = String(n.appName || "");
            var sum = String(n.summary || "");
            var isTransient = (app === "Mono"
                               || sum === host.tr("Screenshot")
                               || sum === "Screenshot"
                               || sum === "Screenshot"
                               || sum.indexOf("Screenshot") >= 0
                               || sum.indexOf("Screenshot") >= 0);
            if (n.hints && (n.hints["transient"] === true || n.hints["transient"] === 1 || n.hints["transient"] === "1")) {
                isTransient = true;
            }

            if (!isTransient) {
                notifModel.insert(0, {
                    nId: Number(n.id),
                    nSummary: String(n.summary || ""),
                    nBody: String(n.body || ""),
                    nApp: String(n.appName || ""),
                    nImage: host.notifIconFor(n),
                    nUrgent: n.urgency === NotificationUrgency.Critical,
                    nTime: Qt.formatDateTime(new Date(), "HH:mm")
                });
                while (notifModel.count > 50) notifModel.remove(notifModel.count - 1);
            }

            var nid = Number(n.id);
            var objs = service.notifObjs;
            objs[String(nid)] = n;
            service.notifObjs = objs;
            n.closed.connect(function (reason) {
                var o = service.notifObjs;
                delete o[String(nid)];
                service.notifObjs = o;
                if (reason !== NotificationCloseReason.CloseRequested) return;
                host.dropNotification(nid);
            });

            if (service.dnd && n.urgency !== NotificationUrgency.Critical) return;

            host.enqueueToast(n);
        }
    }
    }

    property var toastQueue: []

    function enqueueToast(n) {
        var q = service.toastQueue.slice();
        q.push({ notif: n, at: Date.now() });
        service.toastQueue = q;
        host.pumpToasts();
    }

    function pumpToasts() {
        if (service.notifCurrent !== null || host.expanded) return;
        if (service.toastQueue.length === 0) return;

        var q = service.toastQueue.slice();
        var item = q.shift();
        service.toastQueue = q;

        if (Date.now() - item.at > 60000) { host.pumpToasts(); return; }

        var n = item.notif;
        service.notifCurrent = n;
        var crit = n.urgency === NotificationUrgency.Critical;
        var want = crit ? host.cfg.notifCritTimeout : host.cfg.notifTimeout;
        var ms = n.expireTimeout > 0 ? (n.expireTimeout < 100 ? n.expireTimeout * 1000 : n.expireTimeout) : want;
        if (!crit && want > 0 && ms > want) ms = want;
        if (crit && want === 0) ms = 0;
        toastTimer.interval = ms > 0 ? Math.max(1000, ms) : 24 * 60 * 60 * 1000;
        toastTimer.restart();
    }

    Timer { id: toastPump; interval: 260; onTriggered: host.pumpToasts() }

    Timer {
        id: toastTimer
        onTriggered: {
            
            host.dismissToast();
        }
    }
    function forgetNotification(index) {
        var e = notifModel.get(index);
        var nid = e ? Number(e.nId) : -1;
        notifModel.remove(index);
        if (nid < 0 || !notifServer) return;
        var live = notifServer.trackedNotifications.values;
        for (var i = 0; i < live.length; i++) {
            if (live[i] && Number(live[i].id) === nid) { live[i].dismiss(); break; }
        }
        if (service.notifCurrent && Number(service.notifCurrent.id) === nid) host.dismissToast();
    }

    function dropNotification(nid) {
        for (var i = 0; i < notifModel.count; i++) {
            if (Number(notifModel.get(i).nId) === nid) { notifModel.remove(i); break; }
        }
        var q = service.toastQueue.filter(function (it) {
            return !it.notif || Number(it.notif.id) !== nid;
        });
        if (q.length !== service.toastQueue.length) service.toastQueue = q;

        if (service.notifCurrent && Number(service.notifCurrent.id) === nid) host.dismissToast();
    }

    function dismissToast() {
        toastTimer.stop();
        service.notifCurrent = null;
        toastPump.restart();
    }
    function clearNotifications() {
        notifModel.clear();
        if (!notifServer) return;
        var live = notifServer.trackedNotifications.values;
        for (var i = live.length - 1; i >= 0; i--) {
            if (live[i]) live[i].dismiss();
        }
    }

}
