import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

Item {
    visible: false
    id: service
    property var host
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property bool btOn: btAdapter ? btAdapter.enabled : false
    readonly property var btDevices: btAdapter ? btAdapter.devices : null
    readonly property var btConnectedDevice: {
        if (!btDevices) return null;
        var list = btDevices.values;
        for (var i = 0; i < list.length; i++)
            if (list[i] && list[i].connected) return list[i];
        return null;
    }
    readonly property string btConnectedName: {
        if (btConnectedDevice) return btConnectedDevice.name || "Device";
        return "";
    }
    readonly property string btConnectedType: {
        if (!btConnectedDevice) return "earbuds";
        var icon = String(btConnectedDevice.icon || "").toLowerCase();
        var name = String(btConnectedDevice.name || "").toLowerCase();
        if (icon === "input-mouse" || name.indexOf("mouse") >= 0) return "mouse";
        if (icon === "input-keyboard" || name.indexOf("keyboard") >= 0) return "keyboard";
        if (icon === "input-gaming" || name.indexOf("controller") >= 0 || name.indexOf("gamepad") >= 0 || name.indexOf("dualsense") >= 0 || name.indexOf("xbox") >= 0) return "gamepad";
        if (icon === "phone" || name.indexOf("phone") >= 0 || name.indexOf("iphone") >= 0 || name.indexOf("android") >= 0) return "phone";
        if (icon === "audio-speakers" || icon === "audio-speaker" || name.indexOf("speaker") >= 0) return "speaker";
        return "earbuds";
    }
    readonly property int btConnectedBattery: {
        if (btConnectedDevice && btConnectedDevice.batteryAvailable)
            return Math.round(btConnectedDevice.battery * 100);
        return -1;
    }

    property bool btAudioConnected: false
    property string btAudioMode: "music"
    property string btAudioCodec: "-"
    Process { id: pBtAudioStatus; command: [service.host.scriptDir + "/bluetooth_audio.sh", "status"]; stdout: StdioCollector { onStreamFinished: { var values = {}; String(text).trim().split("\n").forEach(function (line) { var p = line.split("="); if (p.length === 2) values[p[0]] = p[1]; }); service.btAudioConnected = values.connected === "1"; service.btAudioMode = values.mode || "music"; service.btAudioCodec = values.codec || "-"; } } }
    Timer { interval: 2500; running: true; repeat: true; triggeredOnStart: true; onTriggered: { pBtAudioStatus.running = false; pBtAudioStatus.running = true; } }
    Process { id: pBtAudioToggle }
    function toggleBtAudio() { pBtAudioToggle.command = [service.host.scriptDir + "/bluetooth_audio.sh", "toggle"]; pBtAudioToggle.running = false; pBtAudioToggle.running = true; btAudioRefresh.restart(); }
    Timer { id: btAudioRefresh; interval: 900; onTriggered: pBtAudioStatus.running = true }

    property string btToastName: ""
    property string btToastType: "earbuds"
    property bool   btToastDisconnected: false
    property bool   btToastShown: false
    readonly property bool btToastActive: btToastShown && !host.expanded
    property string btPrevConnected: ""

    onBtConnectedNameChanged: {
        var name = service.btConnectedName;
        if (name.length > 0 && name !== service.btPrevConnected) {
            service.btPrevConnected = name;
            host.showBtToast(name, service.btConnectedType, false);
        } else if (name.length === 0 && service.btPrevConnected.length > 0) {
            var prev = service.btPrevConnected;
            var prevType = service.btToastType;
            service.btPrevConnected = "";
            host.showBtToast(prev, prevType, true);
        }
    }

    function showBtToast(name, type, isDisconnect) {
        service.btToastName = name;
        service.btToastType = type || "earbuds";
        service.btToastDisconnected = isDisconnect || false;
        service.btToastShown = true;
        if (host.expanded) host.collapse();
        btToastTimer.restart();
        host.playSound(isDisconnect ? "disconnect" : "connect");
    }
    function dismissBtToast() {
        service.btToastShown = false;
        btToastTimer.stop();
    }
    Timer {
        id: btToastTimer
        interval: 2500
        onTriggered: service.dismissBtToast()
    }

    property bool acToastShown: false
    readonly property bool acToastActive:
        acToastShown && !host.expanded && host.isLaptop && !service.btToastActive
    property bool acPrev: host.acOnline

    Connections {
        target: host
        function onAcOnlineChanged() {
            if (host.acOnline && !service.acPrev && host.isLaptop) service.showAcToast();
            service.acPrev = host.acOnline;
        }
    }
    function showAcToast() {
        service.acToastShown = true;
        if (host.expanded) host.collapse();
        acToastTimer.restart();
        host.playSound("charge");
    }
    function dismissAcToast() {
        service.acToastShown = false;
        acToastTimer.stop();
    }
    Timer {
        id: acToastTimer
        interval: 2300
        onTriggered: service.dismissAcToast()
    }

    Process { id: pBtUnblock; command: ["rfkill", "unblock", "bluetooth"] }
    function toggleBt() {
        if (!btAdapter) return;
        if (!btAdapter.enabled) {
            pBtUnblock.running = true;
            btPowerOn.restart();
        } else {
            btAdapter.enabled = false;
        }
    }
    Timer {
        id: btPowerOn
        interval: 250
        onTriggered: if (service.btAdapter) service.btAdapter.enabled = true;
    }
    function scanBt() {
        if (!btAdapter || !btAdapter.enabled) return;
        btAdapter.pairable = true;
        btAdapter.discovering = true;
        btScanStop.restart();
    }
    Timer { id: btScanStop; interval: 12000; onTriggered: if (service.btAdapter) service.btAdapter.discovering = false }

}
