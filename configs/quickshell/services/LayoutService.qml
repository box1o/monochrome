import QtQuick
import Quickshell

Item {
    id: service
    visible: false
    property var host
    readonly property bool cornersWanted:
        !(host.settingsMode || host.pillHidden)
    property bool cornersOn: false
    Timer {
        id: cornerReveal
        interval: host.animMs + 40
        onTriggered: service.cornersOn = true
    }
    onCornersWantedChanged: {
        if (host.cornersWanted) {
            cornerReveal.restart();
        } else {
            cornerReveal.stop();
            service.cornersOn = false;
        }
    }

    readonly property string scriptDir:
        Quickshell.env("HOME") + "/.config/quickshell/scripts"

    // The shell has one fixed black-and-white appearance.
    readonly property bool themeNothing: true

    //
    readonly property real dotHBig:   host.fontSize + 10
    readonly property real dotHClock: host.fontSize - 1
    readonly property real dotHSmall: host.fontSize - 3
    readonly property real dotHTiny:  host.fontSize - 5

    function fgOn(c) {
        return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) > 0.6
               ? host.colBg : "#ffffff";
    }

    readonly property color colBg:     host.theme.background
    readonly property color colFg:     host.theme.foreground
    readonly property color colMuted:  host.theme.muted
    readonly property color colLine:   host.theme.line
    readonly property color colHover:  host.theme.hover
    readonly property color colOn:     host.theme.active
    readonly property color colOk:     host.theme.success
    readonly property color colCrit:   host.theme.critical

    //
    readonly property color colWarn: host.colFg
    readonly property string fontFam:  host.cfg.fontFam
    readonly property string fontBody:    host.cfg.fontBody || host.cfg.fontFam
    readonly property string fontDisplay: host.cfg.fontDisplay || host.cfg.fontFam
    readonly property int fontSize:    host.cfg.fontSize
    readonly property int iconSize:    host.cfg.iconSize
    readonly property int unit:        host.cfg.spacingUnit
    readonly property int radiusS:     host.cfg.smallRadius

    readonly property int pillH: host.cfg.pillH

    readonly property string pillPos: {
        var p = String(host.cfg.pillPos || "top");
        return (p === "bottom" || p === "left" || p === "right") ? p : "top";
    }
    readonly property bool pillAtTop:    pillPos === "top"
    readonly property bool pillAtBottom: pillPos === "bottom"
    readonly property bool pillAtLeft:   pillPos === "left"
    readonly property bool pillAtRight:  pillPos === "right"
    readonly property bool pillSide: pillAtLeft || pillAtRight

    property bool  pillDragging: false
    property real  dragDX: 0
    property real  dragDY: 0
    property string dragEdge: ""

    function edgeAt(cx, cy) {
        var w = host.width, h = host.height;
        var dTop = cy, dBottom = h - cy, dLeft = cx, dRight = w - cx;
        var m = Math.min(dTop, dBottom, dLeft, dRight);
        if (m > Math.min(w, h) * 0.25) return "";
        if (m === dTop)    return "top";
        if (m === dBottom) return "bottom";
        if (m === dLeft)   return "left";
        return "right";
    }

    function dropPill() {
        var edge = service.dragEdge;
        service.pillDragging = false;
        service.dragEdge = "";
        service.dragDX = 0;
        service.dragDY = 0;
        if (edge.length && edge !== host.pillPos) {
            host.cfg.pillPos = edge;
            host.saveCfg();
        }
        host.hoverExpandArmed = false;
        host.collapse();
    }

    readonly property int panelW: host.cfg.panelW
    readonly property int gap: 5
    readonly property int cornerR: host.cfg.notchMode ? host.cfg.notchFlare : 0

    readonly property bool noMotion: host.cfg.reduceMotion
    readonly property int animMs:   noMotion ? 0 : host.cfg.animMove
    readonly property int animFade: noMotion ? 0 : host.cfg.animFade
    readonly property int animHover: noMotion ? 0 : host.cfg.animHover
    readonly property real animBounce: noMotion ? 0 : host.cfg.animBounce / 100
    readonly property real easeOvershoot: animBounce * 1.7
    readonly property int animFast: Math.round(animMs * 0.52)
    readonly property int animQuick: Math.round(animMs * 0.48)

    property bool morphing: false
    Connections {
        target: host
        function onExpandedChanged() { service.morphing = true; morphTimer.restart() }
        function onPageChanged() { service.morphing = true; morphTimer.restart() }
    }
    Timer { id: morphTimer; interval: host.animMs + 140; onTriggered: service.morphing = false }

}
