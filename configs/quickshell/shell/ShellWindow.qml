import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: window

    required property bool menuOpen
    required property QtObject geometry
    required property Item notchView

    signal dismissRequested

    // Keep the surface stable; the native grab owns temporary keyboard focus.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors.top: true
    implicitWidth: geometry.surfaceWidth
    implicitHeight: geometry.surfaceHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    HyprlandFocusGrab {
        windows: [window]
        active: window.menuOpen
        onCleared: window.dismissRequested()
    }

    mask: Region {
        item: notchView.body

        Region {
            item: notchView.leftShoulder
        }

        Region {
            item: notchView.rightShoulder
        }
    }
}
