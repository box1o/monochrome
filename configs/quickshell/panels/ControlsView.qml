import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

import "../components"
import "controls"
import "pages"
import "../services"
Item {
    id: view

    property var sys
    property bool preview: false
    property var ccOrderOverride: null
    readonly property var ccDefault: ["clock", "toggles", "sliders", "media", "power", "quick", "tray"]
    readonly property var ccOrder: {
        if (view.ccOrderOverride)
            return view.ccOrderOverride;

        var saved = String(view.sys.cfg.ccLayout || "").split(",").filter((x) => {
            return x.length;
        });
        var out = saved.filter((id) => {
            return view.ccDefault.indexOf(id) >= 0;
        });
        view.ccDefault.forEach((id) => {
            if (out.indexOf(id) < 0)
                out.push(id);

        });
        return out;
    }

    function ccBlock(id) {
        for (var i = 0; i < mainPage.children.length; i++) if (mainPage.children[i].objectName === "cc-" + id) {
            return mainPage.children[i];
        }
        return null;
    }

    function ccRow(id) {
        var i = view.ccOrder.indexOf(id);
        return i < 0 ? view.ccDefault.indexOf(id) : i;
    }

    function fmtTime(sec) {
        var t = Math.max(0, Math.floor(sec));
        var h = Math.floor(t / 3600);
        var m = Math.floor((t % 3600) / 60);
        var s = t % 60;
        var mm = h > 0 && m < 10 ? "0" + m : String(m);
        return (h > 0 ? h + ":" : "") + mm + ":" + (s < 10 ? "0" + s : String(s));
    }

    function goBack() {
        if (view.sys.page === "netmenu") {
            view.sys.page = "wifi";
            return true;
        }
        if (view.sys.page === "wifi" || view.sys.page === "bt" || view.sys.page === "battery" || view.sys.page === "scrcpy") {
            view.sys.page = "main";
            return true;
        }
        if (view.sys.page === "traymenu") {
            view.sys.page = "main";
            view.sys.trayMenuItem = null;
            return true;
        }
        return false;
    }

    implicitHeight: stack.implicitHeight
    focus: true
    Component.onCompleted: forceActiveFocus()
    Keys.onEscapePressed: {
        if (!view.goBack())
            view.sys.collapse();

    }

    Item {
        id: stack

        width: parent.width
        MainPage { id: mainPage; view: view }
        BattPage { id: battPage; view: view }
        WifiPage { id: wifiPage; view: view }
        NetMenuPage { id: netMenuPage; view: view }
        TrayPage { id: trayPage; view: view }
        BtPage { id: btPage; view: view }
        ScrcpyPage { id: scrcpyPage; view: view }
        implicitHeight: (view.preview || view.sys.page === "main") ? mainPage.implicitHeight : view.sys.page === "wifi" ? wifiPage.implicitHeight : view.sys.page === "netmenu" ? netMenuPage.implicitHeight : view.sys.page === "traymenu" ? trayPage.implicitHeight : view.sys.page === "battery" ? battPage.implicitHeight : view.sys.page === "scrcpy" ? scrcpyPage.implicitHeight : btPage.implicitHeight



        // ------------------------------------------------------------ Wi-Fi



        // -------------------------------------------------------- Bluetooth


    }
















}
