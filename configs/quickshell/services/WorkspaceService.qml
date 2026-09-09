import QtQuick
import Quickshell.Hyprland

QtObject {
    readonly property int current: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property var workspaces: Hyprland.workspaces
    readonly property var ids: {
        var out = [];
        var all = workspaces ? workspaces.values : [];
        for (var i = 0; i < all.length; i++)
            if (all[i] && all[i].id > 0) out.push(all[i].id);
        out.sort(function (a, b) { return a - b; });
        return out;
    }
}
