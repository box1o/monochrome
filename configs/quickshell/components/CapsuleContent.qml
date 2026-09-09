import QtQuick
import QtQuick.Layouts
import Quickshell
import "../panels"

Item {
    id: contentRoot
    property var rootState
    property var capsuleRef
    property var detachedPanel
    property alias contentLoader: contentLoader

    Item {
        id: dragHandle
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 16
        z: 60
        visible: rootState.cfg.pillDrag && rootState.expanded && rootState.page === "main"
                 && !rootState.settingsMode

        Rectangle {
            anchors.centerIn: parent
            width: 46
            height: 4
            radius: 2
            color: rootState.pillDragging ? rootState.colOn
                 : (handleMa.containsMouse ? Qt.rgba(1, 1, 1, 0.45)
                                           : Qt.rgba(1, 1, 1, 0.18))
            Behavior on color { ColorAnimation { duration: 140 } }
        }

        MouseArea {
            id: handleMa
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            cursorShape: rootState.pillDragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor

            property real pressX: 0
            property real pressY: 0

            onPressed: mouse => {
                var p = mapToItem(null, mouse.x, mouse.y);
                handleMa.pressX = p.x;
                handleMa.pressY = p.y;
                rootState.pillDragging = true;
            }
            onPositionChanged: mouse => {
                if (!rootState.pillDragging) return;
                var p = mapToItem(null, mouse.x, mouse.y);
                rootState.dragDX = p.x - handleMa.pressX;
                rootState.dragDY = p.y - handleMa.pressY;
                rootState.dragEdge = rootState.edgeAt(capsuleRef.x + rootState.dragDX + capsuleRef.width / 2,
                                            capsuleRef.y + rootState.dragDY + capsuleRef.height / 2);
            }
            onReleased: rootState.dropPill()
            onCanceled: rootState.dropPill()
        }
    }

    Loader {
        id: contentLoader
        z: 10
        parent: (rootState.cfg.pillKeepVisible && rootState.expanded && !rootState.settingsMode) ? detachedPanel : capsule
        anchors.top: parent ? parent.top : undefined
        anchors.topMargin: 15
        anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
        width: (rootState.settingsMode ? rootState.settingsW : rootState.panelW) - 30
        active: (rootState.expanded || capsuleRef.height > rootState.pillH + 4 || (rootState.cfg.pillKeepVisible && detachedPanel.opacity > 0.005))
                && !rootState.btToastActive
                && !rootState.acToastActive
        visible: !rootState.btToastActive && !rootState.acToastActive
        focus: true
        onLoaded: if (item) item.forceActiveFocus()
        Keys.onEscapePressed: {
            var it = contentLoader.item;
            if (it && typeof it.goBack === "function" && it.goBack()) return;
            rootState.collapse();
        }
        opacity: rootState.expanded ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: rootState.expanded ? rootState.animFast : 90; easing.type: Easing.OutCubic }
        }

        sourceComponent: rootState.page === "launcher" ? launcherComp
                       : rootState.page === "settings" ? settingsComp
                       : rootState.page === "clip"     ? clipComp
                       : rootState.page === "power"    ? powerComp
                       : rootState.page === "notif"    ? notifComp
                       : rootState.page === "audio"    ? audioComp
                       : rootState.page === "cal"      ? calComp
                                                  : controlsComp
    }

    Component { id: controlsComp; ControlsView { sys: rootState } }
    Component { id: launcherComp; LauncherView { sys: rootState } }
    Component { id: settingsComp; SettingsView { sys: rootState } }
    Component { id: clipComp;     ClipboardView { sys: rootState } }
    Component { id: powerComp;    PowerView { sys: rootState } }
    Component { id: notifComp;    NotificationsView { sys: rootState } }
    Component { id: audioComp;    AudioView { sys: rootState } }
    Component { id: calComp;      CalendarView { sys: rootState } }}
