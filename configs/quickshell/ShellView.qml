import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell.Bluetooth
import Quickshell.Hyprland
import "components"
import "config"
import "panels"
import "services"

//
ShellRoot {

PanelWindow {
    id: panel

    ShellViewModel { id: viewModel }
    readonly property var cfg: viewModel.cfg
    readonly property var appState: viewModel.appState
    readonly property var theme: viewModel.theme

    readonly property var metrics: uiMetrics

    UiMetrics {
        id: uiMetrics
        fontSize: panel.fontSize
        iconSize: panel.iconSize
        dotSmall: panel.dotHSmall
        notchHeight: panel.cfg.notchH
    }

    SystemService { id: systemService; host: panel }
    readonly property string wiredName: systemService.wiredName
    readonly property bool wiredOn: systemService.wiredOn
    function playSound(name) { systemService.playSound(name) }
    function tr(k) { return systemService.tr(k) }
    function monCmd(n, o) { return systemService.monCmd(n, o) }
    function monMap() { return systemService.monMap() }
    function monApply(n, o) { systemService.monApply(n, o) }
    function monReplay() { systemService.monReplay() }
    function runDetached(cmd) { systemService.runDetached(cmd) }

    ScrcpyService { id: scrcpyService; host: panel }
    readonly property var adbDevices: scrcpyService.adbDevices
    readonly property bool adbBusy: scrcpyService.adbBusy
    readonly property string adbError: scrcpyService.adbError
    readonly property bool scrcpyChecking: scrcpyService.scrcpyChecking
    function refreshAdbDevices() { scrcpyService.refreshAdbDevices() }
    function launchScrcpy(serial) { scrcpyService.launchScrcpy(serial) }
    function notifyScrcpyRunning() { scrcpyService.notifyScrcpyRunning() }
    function notifyScrcpyMissing() { scrcpyService.notifyScrcpyMissing() }
    function openScrcpy() { scrcpyService.openScrcpy() }

    //
    //
    LayoutService { id: layoutService; host: panel }
    readonly property bool cornersWanted: layoutService.cornersWanted
    property alias cornersOn: layoutService.cornersOn
    readonly property string scriptDir: layoutService.scriptDir
    readonly property bool themeNothing: layoutService.themeNothing
    readonly property real dotHBig: layoutService.dotHBig
    readonly property real dotHClock: layoutService.dotHClock
    readonly property real dotHSmall: layoutService.dotHSmall
    readonly property real dotHTiny: layoutService.dotHTiny
    function fgOn(c) { return layoutService.fgOn(c) }
    readonly property color colBg: layoutService.colBg
    readonly property color colFg: layoutService.colFg
    readonly property color colMuted: layoutService.colMuted
    readonly property color colLine: layoutService.colLine
    readonly property color colHover: layoutService.colHover
    readonly property color colOn: layoutService.colOn
    readonly property color colOk: layoutService.colOk
    readonly property color colCrit: layoutService.colCrit
    readonly property color colWarn: layoutService.colWarn
    readonly property string fontFam: layoutService.fontFam
    readonly property string fontBody: layoutService.fontBody
    readonly property string fontDisplay: layoutService.fontDisplay
    readonly property int fontSize: layoutService.fontSize
    readonly property int iconSize: layoutService.iconSize
    readonly property int unit: layoutService.unit
    readonly property int radiusS: layoutService.radiusS
    readonly property int pillH: layoutService.pillH
    readonly property string pillPos: layoutService.pillPos
    readonly property bool pillAtTop: layoutService.pillAtTop
    readonly property bool pillAtBottom: layoutService.pillAtBottom
    readonly property bool pillAtLeft: layoutService.pillAtLeft
    readonly property bool pillAtRight: layoutService.pillAtRight
    readonly property bool pillSide: layoutService.pillSide
    property alias pillDragging: layoutService.pillDragging
    property alias dragDX: layoutService.dragDX
    property alias dragDY: layoutService.dragDY
    property alias dragEdge: layoutService.dragEdge
    function edgeAt(x, y) { return layoutService.edgeAt(x, y) }
    function dropPill() { layoutService.dropPill() }
    readonly property int panelW: layoutService.panelW
    readonly property int gap: layoutService.gap
    readonly property int cornerR: layoutService.cornerR
    readonly property bool noMotion: layoutService.noMotion
    readonly property int animMs: layoutService.animMs
    readonly property int animFade: layoutService.animFade
    readonly property int animHover: layoutService.animHover
    readonly property real animBounce: layoutService.animBounce
    readonly property real easeOvershoot: layoutService.easeOvershoot
    readonly property int animFast: layoutService.animFast
    readonly property int animQuick: layoutService.animQuick
    property alias morphing: layoutService.morphing

    property alias expanded: viewModel.expanded
    // "main" | "wifi" | "bt" | "battery" | "launcher"
    property alias page: viewModel.page
    FullscreenService { id: fullscreenService; host: panel }
    property alias fullscreenActive: fullscreenService.fullscreenActive

    Component.onCompleted: {
        
        fullscreenService.probe();
        fullscreenService.replay();
        panel.cornersOn = panel.cornersWanted;
        panel.wsList = panel.wsRaw;
    }

    function gotoWorkspace(id) {
        if (Hyprland.usingLua) Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })");
        else                   Hyprland.dispatch("workspace " + id);
    }
    property var trayMenuItem: null
    property alias holdOpen: viewModel.holdOpen
    // Hover expansion is armed while the shell is idle.  The capsule disarms
    // it only when the pill reappears from auto-hide, then rearms after the
    // pointer moves away and back over the notch.
    property bool hoverExpandArmed: true
    onHoldOpenChanged: if (holdOpen) refocusTimer.restart()
    Timer {
        id: refocusTimer
        interval: 60
        onTriggered: if (capsule.contentLoader.item) capsule.contentLoader.item.forceActiveFocus()
    }

    readonly property bool launcherOpen: expanded && page === "launcher"

    function collapse() {
        expanded = false;
        holdOpen = false;
        pageResetTimer.restart();
    }
    Timer {
        id: pageResetTimer
        interval: panel.animMs + 40
        onTriggered: if (!panel.expanded) { panel.page = "main"; panel.trayMenuItem = null; }
    }

    function openSub(name) {
        pageResetTimer.stop();
        page = name;
        expanded = true;
        holdOpen = true;
    }

    function togglePage(name) {
        if (expanded && page === name) { collapse(); return; }
        pageResetTimer.stop();
        page = name;
        expanded = true;
        holdOpen = true;
    }
    function openLauncher() {
        pageResetTimer.stop();
        page = "launcher";
        expanded = true;
        holdOpen = true;
    }
    function closeLauncher() { collapse(); }
    function toggleLauncher() {
        if (launcherOpen) closeLauncher(); else openLauncher();
    }

    property alias freezeShot: viewModel.freezeShot

    readonly property rect freezeBounds: {
        var xs = Quickshell.screens;
        if (!xs || xs.length === 0) return Qt.rect(0, 0, 0, 0);
        var minx = Infinity, miny = Infinity, maxx = -Infinity, maxy = -Infinity;
        for (var i = 0; i < xs.length; i++) {
            var s = xs[i];
            minx = Math.min(minx, s.x);
            miny = Math.min(miny, s.y);
            maxx = Math.max(maxx, s.x + s.width);
            maxy = Math.max(maxy, s.y + s.height);
        }
        return Qt.rect(minx, miny, maxx - minx, maxy - miny);
    }

    Process { id: pShotSay }
    function shotCopied(path: string): void {
        var name = String(path).split("/").pop();
        pShotSay.command = ["notify-send", "-a", "Mono", "-i", String(path),
                            "-h", "int:transient:1",
                            panel.tr("Screenshot"),
                            panel.tr("Copied to the clipboard") + " · " + name];
        pShotSay.running = false;
        pShotSay.running = true;
        panel.playSound("screenshot");
    }

    readonly property bool settingsMode: expanded && page === "settings"

    readonly property int settingsW: Math.min(1040, (screen ? screen.width : 1920) - 80)

    readonly property var player: appState.media.player
    readonly property bool mediaActive: appState.media.active
    readonly property string mediaArt: appState.media.art

    readonly property var battDev: appState.battery.device
    readonly property int batteryPct: appState.battery.percentage
    readonly property bool batteryCharging: appState.battery.charging
    readonly property bool acOnline: !appState.battery.onBattery
    readonly property var battIcons: appState.battery.icons
    readonly property string batteryLevelIcon: appState.battery.levelIcon
    readonly property bool batteryPresent: appState.battery.present

    HardwareService { id: hardwareService; host: panel }
    property alias brightBackend: hardwareService.brightBackend
    property alias hasTouchpad: hardwareService.hasTouchpad
    property alias ddcutilPresent: hardwareService.ddcutilPresent
    readonly property bool isLaptop: panel.batteryPresent
    readonly property bool showBattery: panel.batteryPresent
    readonly property bool showPowerProfiles: panel.batteryPresent
    property alias loadCpu: hardwareService.loadCpu
    property alias loadMem: hardwareService.loadMem
    property alias loadGpu: hardwareService.loadGpu
    property alias loadTempCpu: hardwareService.loadTempCpu
    property alias loadTempGpu: hardwareService.loadTempGpu
    readonly property bool loadWanted: panel.expanded
    property alias brightList: hardwareService.brightList
    property alias brightBusy: hardwareService.brightBusy
    property alias brightPendingId: hardwareService.brightPendingId
    property alias brightPendingPct: hardwareService.brightPendingPct
    property alias keepAwake: hardwareService.keepAwake
    function brightRefresh(r) { hardwareService.brightRefresh(r) }
    function brightSet(i, p) { hardwareService.brightSet(i, p) }

    readonly property real batteryHealth: appState.battery.health
    readonly property real batteryCapacity: appState.battery.capacity
    readonly property real batteryRate: appState.battery.rate
    readonly property string batteryIcon: appState.battery.icon

    AudioRoutingService { id: audioRoutingService; host: panel }
    readonly property var audioSinks: audioRoutingService.audioSinks
    readonly property var audioStreams: audioRoutingService.audioStreams
    readonly property string sinkName: audioRoutingService.sinkName
    function setSink(node) { audioRoutingService.setSink(node) }

    NotificationService { id: notificationService; host: panel }
    readonly property var trayItems: SystemTray.items
    property alias dnd: notificationService.dnd
    readonly property var notifCurrent: notificationService.notifCurrent
    readonly property var notifications: notificationService.notifications
    readonly property var notifServer: notificationService.notifServer
    readonly property var activeNotifications: notificationService.activeNotifications
    readonly property bool toastActive: notificationService.toastActive
    readonly property string notifSummary: notificationService.notifSummary
    readonly property string notifBody: notificationService.notifBody
    readonly property string notifApp: notificationService.notifApp
    readonly property string notifImage: notificationService.notifImage
    readonly property bool notifUrgent: notificationService.notifUrgent
    function toggleDnd() { notificationService.toggleDnd() }
    function focusApp(h) { notificationService.focusApp(h) }
    function activateNotification(n) { notificationService.activateNotification(n) }
    function notifIconFor(n) { return notificationService.notifIconFor(n) }
    function forgetNotification(i) { notificationService.forgetNotification(i) }
    function dropNotification(i) { notificationService.dropNotification(i) }
    function dismissToast() { notificationService.dismissToast() }
    function clearNotifications() { notificationService.clearNotifications() }

    OsdService { id: osdService; host: panel }
    readonly property string osdKind: osdService.osdKind
    readonly property real osdValue: osdService.osdValue
    readonly property bool osdMuted: osdService.osdMuted
    readonly property bool osdActive: osdService.osdActive
    readonly property string osdIcon: osdService.osdIcon
    readonly property var sinkAudio: osdService.sinkAudio
    readonly property var srcAudio: osdService.srcAudio
    function showOsd(k, v, m) { osdService.showOsd(k, v, m) }

    PowerService { id: powerService; host: panel }
    readonly property string powerScript: powerService.powerScript
    readonly property string powerProfile: powerService.powerProfile
    readonly property string profileLabel: powerService.profileLabel
    function setPowerProfile(name) { powerService.setPowerProfile(name) }

    readonly property int wsId: appState.workspace.current
    readonly property var wsRaw: appState.workspace.ids

    //
    property var wsList: []
    onWsRawChanged: {
        var a = panel.wsRaw, b = panel.wsList;
        if (a.length === b.length) {
            var same = true;
            for (var i = 0; i < a.length; i++)
                if (a[i] !== b[i]) { same = false; break; }
            if (same) return;
        }
        panel.wsList = a;
    }

    readonly property string timeText: appState.clock.timeText
    readonly property string dayText: appState.clock.dayText
    readonly property string dateLong: appState.clock.dateLong
    readonly property string secText: appState.clock.secText
    readonly property string dayNum: appState.clock.dayNum
    readonly property bool weekend: appState.clock.weekend
    readonly property string monthText: appState.clock.monthText

    WifiService { id: wifiService; host: panel }
    readonly property string wifiScript: wifiService.wifiScript
    readonly property bool wifiOn: wifiService.wifiOn
    readonly property string wifiSsid: wifiService.wifiSsid
    readonly property int wifiQuality: wifiService.wifiQuality
    readonly property bool wifiBusy: wifiService.wifiBusy
    readonly property string wifiError: wifiService.wifiError
    readonly property var wifiNetworks: wifiService.wifiNetworks
    function refreshWifiStatus() { wifiService.refreshWifiStatus() }
    function refreshWifiList() { wifiService.refreshWifiList() }
    function scanWifi() { wifiService.scanWifi() }
    function connectWifi(ssid, password) { wifiService.connectWifi(ssid, password) }
    function disconnectWifi() { wifiService.disconnectWifi() }
    function forgetWifi(ssid) { wifiService.forgetWifi(ssid) }
    function toggleWifi() { wifiService.toggleWifi() }

    BluetoothService { id: bluetoothService; host: panel }
    readonly property var btAdapter: bluetoothService.btAdapter
    readonly property bool btOn: bluetoothService.btOn
    readonly property var btDevices: bluetoothService.btDevices
    readonly property var btConnectedDevice: bluetoothService.btConnectedDevice
    readonly property string btConnectedName: bluetoothService.btConnectedName
    readonly property string btConnectedType: bluetoothService.btConnectedType
    readonly property int btConnectedBattery: bluetoothService.btConnectedBattery
    readonly property string btToastName: bluetoothService.btToastName
    readonly property string btToastType: bluetoothService.btToastType
    readonly property bool btToastDisconnected: bluetoothService.btToastDisconnected
    readonly property bool btToastShown: bluetoothService.btToastShown
    readonly property bool btToastActive: bluetoothService.btToastActive
    readonly property bool acToastShown: bluetoothService.acToastShown
    readonly property bool acToastActive: bluetoothService.acToastActive
    function showBtToast(n, t, d) { bluetoothService.showBtToast(n, t, d) }
    function dismissBtToast() { bluetoothService.dismissBtToast() }
    function showAcToast() { bluetoothService.showAcToast() }
    function dismissAcToast() { bluetoothService.dismissAcToast() }
    function toggleBt() { bluetoothService.toggleBt() }
    function scanBt() { bluetoothService.scanBt() }

    IpcRouter { rootState: panel }

    screen: panel.pickScreen

    readonly property var pickScreen: {
        var want = panel.cfg.pillScreen;
        var all = Quickshell.screens;
        if (want && want !== "auto") {
            for (var i = 0; i < all.length; i++)
                if (all[i].name === want) return all[i];
        }
        // Prefer an external output. With the Hyprland layout above, this is
        // the physically top display. Internal panels commonly use these names.
        for (var j = 0; j < all.length; j++) {
            var name = String(all[j].name || "");
            if (!/^(eDP|LVDS|DSI)-/i.test(name)) return all[j];
        }
        var fm = Hyprland.focusedMonitor;
        return (fm && fm.screen) ? fm.screen : null;
    }

    anchors.top:    !panel.pillAtBottom
    anchors.bottom: !panel.pillAtTop
    anchors.left:   !panel.pillAtRight
    anchors.right:  !panel.pillAtLeft
    //
    //
    implicitHeight: panel.screen ? panel.screen.height : 1080
    implicitWidth: panel.screen ? panel.screen.width : 1920
    color: "transparent"
    exclusiveZone: (panel.cfg.pillOverlay || panel.pillHidden || (panel.fullscreenActive && !panel.expanded))
                   ? 0 : (panel.themeNothing && panel.cfg.notchMode ? panel.cfg.notchH : pillH) + gap
    WlrLayershell.layer: WlrLayer.Overlay
    visible: !panel.fullscreenActive || panel.expanded || panel.osdActive

    readonly property bool pillHidden: panel.cfg.pillAutoHide
                                       && !panel.expanded && !panel.holdOpen
                                       && !panel.osdActive && !panel.pillDragging
                                       && !revealHover.hovered && !capsule.hovered

    onPillHiddenChanged: {
        if (panel.pillHidden) return;
        panel.hoverExpandArmed = false;
        capsule.markArmPoint();
    }

    Item {
        id: revealStrip
        visible: panel.cfg.pillAutoHide
        anchors.top:    panel.pillAtBottom ? undefined : parent.top
        anchors.bottom: panel.pillAtBottom ? parent.bottom : undefined
        anchors.left:   panel.pillAtRight  ? undefined : parent.left
        anchors.right:  panel.pillAtRight  ? parent.right : undefined
        width:  panel.pillSide ? 4 : parent.width
        height: panel.pillSide ? parent.height : 4
        HoverHandler { id: revealHover }
    }

    Region {
        id: capsuleRegion
        item: capsule
        Region {
            item: panel.cfg.pillAutoHide ? revealStrip : null
            intersection: Intersection.Combine
        }
        Region {
            item: (panel.cfg.pillKeepVisible && !panel.settingsMode && (panel.expanded || detachedPanel.opacity > 0.005)) ? detachedPanel : null
            intersection: Intersection.Combine
        }
    }
    readonly property var activePanel: (panel.cfg.pillKeepVisible && panel.expanded && !panel.settingsMode) ? detachedPanel : capsule
    mask: panel.holdOpen ? null : capsuleRegion
    WlrLayershell.keyboardFocus: panel.holdOpen ? WlrKeyboardFocus.Exclusive
                                              : WlrKeyboardFocus.None


    Repeater {
        model: 4
        MouseArea {
            required property int index
            enabled: panel.holdOpen
            visible: enabled
            z: 5
            x: index === 3 ? panel.activePanel.x + panel.activePanel.width : 0
            y: index === 1 ? panel.activePanel.y + panel.activePanel.height
             : index >= 2 ? panel.activePanel.y : 0
            width:  index < 2 ? panel.width
                  : index === 2 ? panel.activePanel.x
                                : Math.max(0, panel.width - panel.activePanel.x - panel.activePanel.width)
            height: index === 0 ? panel.activePanel.y
                  : index === 1 ? Math.max(0, panel.height - panel.activePanel.y - panel.activePanel.height)
                                : panel.activePanel.height
            onClicked: panel.collapse()
        }
    }

    Repeater {
        model: ["top", "bottom", "left", "right"]
        Rectangle {
            required property string modelData
            readonly property bool side: modelData === "left" || modelData === "right"
            readonly property bool lit: panel.pillDragging && panel.dragEdge === modelData

            width:  side ? 4 : parent.width
            height: side ? parent.height : 4
            x: modelData === "right" ? parent.width - width : 0
            y: modelData === "bottom" ? parent.height - height : 0
            z: 80
            radius: 2
            color: panel.colOn
            opacity: lit ? 0.9 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: 140 } }
        }
    }

    Capsule {
        id: capsule
        rootState: panel
        metrics: panel.metrics
        detachedPanel: detachedPanel
    }

    Rectangle {
        id: detachedPanel
        z: 50
        readonly property bool showMe: panel.cfg.pillKeepVisible && !panel.settingsMode && panel.expanded

        visible: panel.cfg.pillKeepVisible && !panel.settingsMode && (panel.expanded || opacity > 0.005)
        opacity: showMe ? 1 : 0
        scale: showMe ? 1 : 0.96

        transformOrigin: panel.pillAtBottom ? Item.Bottom
                       : panel.pillAtLeft   ? Item.Left
                       : panel.pillAtRight  ? Item.Right
                                           : Item.Top

        transform: Translate {
            y: panel.pillAtBottom
               ? (detachedPanel.showMe ? 0 : 10)
               : (detachedPanel.showMe ? 0 : -10)
            x: panel.pillAtRight
               ? (detachedPanel.showMe ? 0 : 10)
               : panel.pillAtLeft
               ? (detachedPanel.showMe ? 0 : -10)
               : 0

            Behavior on y {
                NumberAnimation {
                    duration: detachedPanel.showMe ? panel.animMs : panel.animFast
                    easing.type: detachedPanel.showMe
                                 ? (panel.animBounce > 0 ? Easing.OutBack : Easing.OutCubic)
                                 : Easing.OutCubic
                    easing.overshoot: panel.easeOvershoot
                }
            }
            Behavior on x {
                NumberAnimation {
                    duration: detachedPanel.showMe ? panel.animMs : panel.animFast
                    easing.type: detachedPanel.showMe
                                 ? (panel.animBounce > 0 ? Easing.OutBack : Easing.OutCubic)
                                 : Easing.OutCubic
                    easing.overshoot: panel.easeOvershoot
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: detachedPanel.showMe ? panel.animFade : Math.round(panel.animFade * 0.75)
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: detachedPanel.showMe ? panel.animMs : panel.animFast
                easing.type: detachedPanel.showMe
                             ? (panel.animBounce > 0 ? Easing.OutBack : Easing.OutCubic)
                             : Easing.OutCubic
                easing.overshoot: panel.easeOvershoot
            }
        }

        readonly property real panelGap: panel.cfg.islandGap > 0 ? panel.cfg.islandGap : 10

        width: (panel.cfg.pillKeepVisible && !panel.settingsMode && (panel.expanded || opacity > 0.005)) ? panel.panelW : 0

        readonly property real detachedTargetH: Math.min(capsule.contentH, panel.cfg.expandedH)
        height: (panel.cfg.pillKeepVisible && !panel.settingsMode && (panel.expanded || opacity > 0.005))
                ? Math.min(detachedTargetH, panel.height - (capsule.y + capsule.height + panelGap + 24))
                : 0
        Behavior on height { NumberAnimation { duration: panel.animQuick; easing.type: Easing.OutCubic } }

        x: panel.pillSide
           ? (panel.pillAtLeft  ? capsule.x + capsule.width + panelGap
              : panel.pillAtRight ? capsule.x - width - panelGap
              : Math.max(12, Math.min(panel.width - width - 12, capsule.x + (capsule.width - width) / 2)))
           : Math.max(12, Math.min(panel.width - width - 12, capsule.x + (capsule.width - width) / 2))

        y: panel.pillAtBottom
           ? capsule.y - height - panelGap
           : panel.pillAtTop
              ? capsule.y + capsule.height + panelGap
              : Math.max(12, Math.min(panel.height - height - 12, capsule.y + (capsule.height - height) / 2))

        radius: panel.cfg.islandRadius > 0 ? panel.cfg.islandRadius : 24
        color: panel.colBg
        border.width: 0
        clip: true

        HoverHandler {
            id: detachedHover
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onHoveredChanged: {
                if (hovered) {
                    collapseTimer.stop();
                } else if (!capsule.hovered && !panel.holdOpen) {
                    collapseTimer.restart();
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {}
        }
    }

    property string tipText: ""
    property real   tipX: 0
    property real   tipY: 0
    function showTip(text, x, y) { panel.tipText = text; panel.tipX = x; panel.tipY = y; }
    function hideTip(text) { if (panel.tipText === text) panel.tipText = ""; }

    Rectangle {
        id: globalTip
        z: 200
        visible: opacity > 0.01
        opacity: panel.tipText.length > 0 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 130 } }

        width: globalTipText.implicitWidth + 20
        height: 26
        radius: 13
        x: Math.max(6, panel.tipX - width - 10)
        y: panel.tipY - height / 2
        color: Qt.rgba(0.04, 0.04, 0.05, 0.98)
        border.color: panel.colLine
        border.width: 1

        scale: panel.tipText.length > 0 ? 1 : 0.92
        transformOrigin: Item.Right
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

        Text {
            id: globalTipText
            anchors.centerIn: parent
            text: panel.tipText
            color: panel.colFg
            font { family: panel.fontFam; pixelSize: 11 }
        }
    }

    NotchCorner {
        id: notchBefore
        side: panel.pillSide ? (panel.pillAtLeft ? "right" : "left") : "left"
        fill: panel.colBg
        r: panel.cornerR
        transform: Scale {
            origin.y: panel.cornerR / 2
            yScale: panel.pillSide ? -1 : (panel.pillAtBottom ? -1 : 1)
        }
        x: panel.pillAtLeft  ? 0
         : panel.pillAtRight ? parent.width - width
                            : Math.round(capsule.x) - width
        y: panel.pillSide ? capsule.y - height
         : panel.pillAtBottom ? parent.height - height : 0
        opacity: panel.cornersOn ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: panel.animFast } }
    }
    NotchCorner {
        id: notchAfter
        side: panel.pillSide ? (panel.pillAtLeft ? "right" : "left") : "right"
        fill: panel.colBg
        r: panel.cornerR
        transform: Scale {
            origin.y: panel.cornerR / 2
            yScale: panel.pillSide ? 1 : (panel.pillAtBottom ? -1 : 1)
        }
        x: panel.pillAtLeft  ? 0
         : panel.pillAtRight ? parent.width - width
                            : Math.round(capsule.x + capsule.width)
        y: panel.pillSide ? capsule.y + capsule.height
         : panel.pillAtBottom ? parent.height - height : 0
        opacity: panel.cornersOn ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: panel.animFast } }
    }
}

Variants {
    model: panel.freezeShot !== "" ? Quickshell.screens : []

    PanelWindow {
        id: freezeWin
        required property var modelData

        screen: freezeWin.modelData
        anchors { top: true; bottom: true; left: true; right: true }
        color: "black"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        mask: Region {}

        Image {
            x: panel.freezeBounds.x - freezeWin.modelData.x
            y: panel.freezeBounds.y - freezeWin.modelData.y
            width: panel.freezeBounds.width
            height: panel.freezeBounds.height
            source: panel.freezeShot
            fillMode: Image.Stretch
            smooth: true
            cache: false
        }
    }
}

}
