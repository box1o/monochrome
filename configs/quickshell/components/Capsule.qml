import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../components"
import "../panels"
import "capsules"

Rectangle {
id: capsule
property var rootState
property var detachedPanel
property var metrics
property alias contentLoader: capsuleContent.contentLoader


    anchors.top:    rootState.pillAtTop    ? parent.top    : undefined
    anchors.bottom: rootState.pillAtBottom ? parent.bottom : undefined
    anchors.left:   rootState.pillAtLeft   ? parent.left   : undefined
    anchors.right:  rootState.pillAtRight  ? parent.right  : undefined
    anchors.horizontalCenter: rootState.pillSide ? undefined : parent.horizontalCenter
    anchors.verticalCenter:   rootState.pillSide ? parent.verticalCenter : undefined

    readonly property real freeGap: rootState.cfg.notchMode ? 0 : rootState.cfg.islandGap
    readonly property real edgeMargin: rootState.settingsMode && !rootState.pillSide
                                       ? Math.max(24, (rootState.height - targetH) / 2)
                                       : rootState.pillHidden ? -(targetH + 4) : freeGap
    readonly property real sideMargin: rootState.settingsMode && rootState.pillSide
                                       ? Math.max(24, (rootState.width - width) / 2)
                                       : rootState.pillHidden ? -(width + 4) : freeGap
    anchors.topMargin:    rootState.pillAtTop    ? edgeMargin : 0
    anchors.bottomMargin: rootState.pillAtBottom ? edgeMargin : 0
    anchors.leftMargin:   rootState.pillAtLeft   ? sideMargin : 0
    anchors.rightMargin:  rootState.pillAtRight  ? sideMargin : 0
    Behavior on anchors.leftMargin {
        NumberAnimation { duration: rootState.animMs; easing.type: Easing.InOutCubic }
    }
    Behavior on anchors.rightMargin {
        NumberAnimation { duration: rootState.animMs; easing.type: Easing.InOutCubic }
    }
    Behavior on anchors.topMargin {
        NumberAnimation { duration: rootState.animMs; easing.type: Easing.InOutCubic }
    }
    Behavior on anchors.bottomMargin {
        NumberAnimation { duration: rootState.animMs; easing.type: Easing.InOutCubic }
    }

    readonly property int collapsedMin: Math.max(rootState.cfg.collapsedW, 300)

    //
    function evenUp(v) { return Math.round(v / 2) * 2; }

    readonly property real idleLen: rootState.btToastActive
                ? capsule.evenUp(Math.max(btCapsule.implicitWidth + 48, 240))
            : rootState.acToastActive
                ? capsule.evenUp(Math.max(acCapsule.implicitWidth + 48, 240))
            : rootState.toastActive ? 440
            : rootState.osdActive ? capsule.evenUp(osdCapsule.implicitWidth + 32)
            : rootState.pillSide  ? capsule.evenUp(Math.max(vertCapsule.implicitHeight + 30,
                                                       capsule.collapsedMin))
            : capsule.evenUp(Math.max(nothingCapsule.implicitWidth + 28,
                                       capsule.collapsedMin))
    readonly property real idleThick: (rootState.btToastActive || rootState.acToastActive)
            ? rootState.pillH
            : rootState.toastActive
            ? toastCapsule.implicitHeight + 24
            : (rootState.themeNothing && rootState.cfg.notchMode ? rootState.cfg.notchH : rootState.pillH)

    width: rootState.settingsMode ? rootState.settingsW
         : (rootState.expanded && !rootState.cfg.pillKeepVisible) ? rootState.panelW
         : rootState.pillSide     ? idleThick
                             : idleLen
    property real contentH: 220

    Timer {
        id: contentSettle
        interval: 24
        onTriggered: capsule.applyContentH()
    }
    function refreshContentH() { contentSettle.restart(); }
    function applyContentH() {
        var it = contentLoader.item;
        if (!it || it.implicitHeight <= 40) return;
        var target = it.implicitHeight + 30;
        if (Math.abs(target - capsule.contentH) < 8) return;
        capsule.contentH = target;
    }
    Connections {
        target: contentLoader
        function onItemChanged() { capsule.refreshContentH(); }
    }
    Connections {
        target: contentLoader.item
        ignoreUnknownSignals: true
        function onImplicitHeightChanged() { capsule.refreshContentH(); }
    }

    readonly property real targetH: rootState.settingsMode ? Math.min(contentH, rootState.height - 48)
            : (rootState.expanded && !rootState.cfg.pillKeepVisible) ? Math.min(contentH, rootState.cfg.expandedH)
            : rootState.pillSide ? idleLen
                            : idleThick
    height: Math.min(targetH, rootState.height - rootState.gap * 2)

    transform: Translate {
        x: rootState.dragDX
        y: rootState.dragDY
        Behavior on x {
            enabled: !rootState.pillDragging
            NumberAnimation { duration: rootState.animMs; easing.type: Easing.OutCubic }
        }
        Behavior on y {
            enabled: !rootState.pillDragging
            NumberAnimation { duration: rootState.animMs; easing.type: Easing.OutCubic }
        }
    }

    opacity: 1
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: rootState.animFast } }

    color: rootState.colBg
    readonly property real edgeR: (rootState.settingsMode || !rootState.cfg.notchMode)
                                  ? (rootState.cfg.islandRadius > 0 ? rootState.cfg.islandRadius : 26)
                                  : 0
    readonly property real freeR: (rootState.settingsMode || (rootState.expanded && !rootState.cfg.pillKeepVisible))
            ? (rootState.cfg.islandRadius > 0 && !rootState.cfg.notchMode ? rootState.cfg.islandRadius : 26)
            : (rootState.cfg.islandRadius > 0 && !rootState.cfg.notchMode
               ? rootState.cfg.islandRadius : rootState.pillH / 2)
    topLeftRadius:     rootState.pillAtTop || rootState.pillAtLeft  ? edgeR : freeR
    topRightRadius:    rootState.pillAtTop || rootState.pillAtRight ? edgeR : freeR
    bottomLeftRadius:  rootState.pillAtBottom || rootState.pillAtLeft  ? edgeR : freeR
    bottomRightRadius: rootState.pillAtBottom || rootState.pillAtRight ? edgeR : freeR
    Behavior on topLeftRadius  { NumberAnimation { duration: rootState.animMs; easing.type: Easing.InOutCubic } }
    Behavior on topRightRadius { NumberAnimation { duration: rootState.animMs; easing.type: Easing.InOutCubic } }

    // Niente bordo, in nessuno stato: e' l'unica differenza di stile che
    // c'era fra pillola e pannello. Un bordo largo 1 viene disegnato
    // *dentro* al rettangolo, quindi anche quando era trasparente lasciava
    // passare 1px di sfondo sul lato superiore: da qui l'impressione che
    // la pillola non fosse attaccata al bordo dello schermo e che il fondo
    // cambiasse all'apertura.
    border.width: 0

    Behavior on width {
        NumberAnimation {
            duration: rootState.animMs
            easing.type: rootState.animBounce > 0 ? Easing.OutBack : Easing.InOutCubic
            easing.overshoot: rootState.easeOvershoot
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: rootState.morphing ? rootState.animMs : rootState.animQuick
            easing.type: rootState.animBounce > 0 ? Easing.OutBack
                       : rootState.morphing ? Easing.InOutCubic : Easing.OutCubic
            easing.overshoot: rootState.easeOvershoot
        }
    }
    Behavior on bottomLeftRadius  { NumberAnimation { duration: rootState.animMs; easing.type: Easing.InOutCubic } }
    Behavior on bottomRightRadius { NumberAnimation { duration: rootState.animMs; easing.type: Easing.InOutCubic } }

    clip: true

    HoverHandler {
        id: capsuleHover
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

        property point armPos: Qt.point(-9999, -9999)
        function markArmPoint() {
            capsuleHover.armPos = capsuleHover.hovered
                    ? capsuleHover.point.scenePosition : Qt.point(-9999, -9999);
        }
        onPointChanged: {
            if (rootState.hoverExpandArmed || !capsuleHover.hovered) return;
            var p = capsuleHover.point.scenePosition;
            if (Math.abs(p.x - capsuleHover.armPos.x)
                + Math.abs(p.y - capsuleHover.armPos.y) < 12) return;
            rootState.hoverExpandArmed = true;
            expandTimer.restart();
        }

        onHoveredChanged: {
            if (hovered && !rootState.hoverExpandArmed)
                capsuleHover.armPos = capsuleHover.point.scenePosition;
            if (hovered) {
                collapseTimer.stop();
                expandTimer.restart();
                rearmTimer.stop();
            } else {
                expandTimer.stop();
                collapseTimer.restart();
                rearmTimer.restart();
            }
        }
    }
    readonly property bool hovered: capsuleHover.hovered
    function markArmPoint() { capsuleHover.markArmPoint(); }

    //
    function openPanel() {
        if (!rootState.expanded) {
            pageResetTimer.stop();
            rootState.page = "main";
        }
        rootState.expanded = true;
    }

    Timer {
        id: expandTimer; interval: 0
        onTriggered: {
            if (!capsuleHover.hovered || rootState.launcherOpen) return;
            if (!rootState.hoverExpandArmed) return;
            if (rootState.toastActive || rootState.btToastActive || rootState.acToastActive  ) return;
            if (rootState.cfg.pillAutoHide) return;
            capsule.openPanel();
        }
    }
    Timer {
        id: rearmTimer
        interval: 450
        onTriggered: rootState.hoverExpandArmed = true
    }
    Timer {
        id: collapseTimer; interval: 180
        onTriggered: {
            if (capsuleHover.hovered || (detachedHover.hovered && rootState.cfg.pillKeepVisible) || rootState.holdOpen) return;
            rootState.collapse();
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        enabled: !rootState.expanded && !rootState.toastActive && !rootState.pillDragging
                 && !rootState.osdActive && !rootState.btToastActive && !rootState.acToastActive
        cursorShape: Qt.PointingHandCursor
        onClicked: capsule.openPanel()
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        enabled: rootState.cfg.pillKeepVisible && rootState.expanded && !rootState.settingsMode
                 && !rootState.toastActive && !rootState.pillDragging
        cursorShape: Qt.PointingHandCursor
        onClicked: rootState.collapse()
    }

    ToastCapsule { id: toastCapsule; rootState: capsule.rootState }
    BtCapsule { id: btCapsule; rootState: capsule.rootState }
    AcCapsule { id: acCapsule; rootState: capsule.rootState }
    OsdCapsule { id: osdCapsule; rootState: capsule.rootState }
    IdleCapsule { id: idleCapsule; rootState: capsule.rootState }

    //
    MouseArea {
        anchors.fill: parent
        z: 100
        enabled: rootState.toastActive
        visible: enabled
        preventStealing: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (rootState.notifCurrent) rootState.activateNotification(rootState.notifCurrent)
    }



    Canvas {
        id: acWave
        anchors.fill: parent
        z: 1
        visible: rootState.acToastActive
        property color tint: rootState.colOk
        property real level: rootState.batteryPct / 100
        property real phase: 0
        onPhaseChanged: requestPaint()
        onLevelChanged: requestPaint()
        onTintChanged: requestPaint()

        Timer {
            interval: 45
            running: rootState.acToastActive && acWave.visible
            repeat: true
            onTriggered: acWave.phase += 0.16
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            if (width <= 0 || height <= 0) return;

            var mr = Math.min(width, height) / 2;
            var tl = Math.min(capsule.topLeftRadius, mr);
            var tr = Math.min(capsule.topRightRadius, mr);
            var br = Math.min(capsule.bottomRightRadius, mr);
            var bl = Math.min(capsule.bottomLeftRadius, mr);
            ctx.beginPath();
            ctx.moveTo(tl, 0);
            ctx.arcTo(width, 0, width, height, tr);
            ctx.arcTo(width, height, 0, height, br);
            ctx.arcTo(0, height, 0, 0, bl);
            ctx.arcTo(0, 0, width, 0, tl);
            ctx.closePath();
            ctx.clip();

            var base = height * (1 - Math.max(0.12, Math.min(0.92, level)));
            var amp = 3.2;

            for (var w = 0; w < 2; w++) {
                var off = w === 0 ? 0 : Math.PI * 0.7;
                var k = w === 0 ? 0.055 : 0.041;
                ctx.beginPath();
                ctx.moveTo(0, height);
                for (var x = 0; x <= width; x += 3) {
                    var y = base + amp * Math.sin(k * x + phase + off)
                                 + amp * 0.5 * Math.sin(k * 1.9 * x - phase * 0.7);
                    if (x === 0) ctx.lineTo(0, y); else ctx.lineTo(x, y);
                }
                ctx.lineTo(width, height);
                ctx.closePath();
                ctx.fillStyle = Qt.rgba(tint.r, tint.g, tint.b, w === 0 ? 0.16 : 0.11);
                ctx.fill();
            }
        }
    }



    Notch {
        id: nothingCapsule
        rootState: capsule.rootState
        metrics: capsule.metrics
    }

    Item {
        id: vertCapsule
        anchors.centerIn: parent
        width: rootState.pillH
        height: rootState.pillH
        visible: rootState.pillSide && !rootState.expanded && !rootState.toastActive
                 && !rootState.btToastActive && !rootState.acToastActive && !rootState.osdActive
        Column {
            anchors.centerIn: parent
            spacing: -2
            VertText { value: rootState.timeText; textColor: rootState.colFg; fontFam: rootState.fontFam; size: rootState.fontSize - 2; bold: true }
        }
    }

    CapsuleContent {
        id: capsuleContent
        rootState: capsule.rootState
        capsuleRef: capsule
        detachedPanel: capsule.detachedPanel
    }

}

