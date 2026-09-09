import QtQuick
import Quickshell
import Quickshell.Io

Item {
    visible: false
    id: service
    property var host
    readonly property string wifiScript: Quickshell.env("HOME") + "/.config/quickshell/scripts/wifi.sh"

    property bool wifiOn: true
    property string wifiSsid: ""
    property int wifiQuality: 0
    property bool wifiBusy: false
    property string wifiError: ""

    ListModel { id: wifiModel }
    readonly property var wifiNetworks: wifiModel

    Process {
        id: pWifiStatus
        command: [host.wifiScript, "status"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                var p = line.trim().split("|");
                if (p.length < 3) return;
                service.wifiOn = (p[0] === "on");
                service.wifiSsid = p[1] || "";
                service.wifiQuality = parseInt(p[2]) || 0;
            }
        }
    }
    function refreshWifiStatus() {
        pWifiStatus.running = false;
        pWifiStatus.running = true;
    }
    Timer {
        interval: host.expanded ? 4000 : 15000
        running: true; repeat: true
        onTriggered: service.refreshWifiStatus()
    }

    Process {
        id: pWifiList
        command: [host.wifiScript, "list"]
        stdout: SplitParser {
            onRead: line => {
                var p = line.trim().split("|");
                if (p.length < 5) return;
                wifiModel.append({
                    connected: p[0] === "yes",
                    ssid: p[1],
                    security: p[2],
                    quality: parseInt(p[3]) || 0,
                    known: p[4] === "yes"
                });
            }
        }
        onRunningChanged: if (!running) service.wifiBusy = false
    }

    Process { id: pWifiScan; command: [host.wifiScript, "scan"] }
    Process {
        id: pWifiToggle
        command: [host.wifiScript, "toggle"]
        onRunningChanged: if (!running) pWifiStatus.running = true
    }
    Process {
        id: pWifiConnect
        onRunningChanged: {
            if (running) return;
            service.wifiBusy = false;
            if (exitCode !== 0) service.wifiError = "Could not connect";
            else { service.wifiError = ""; host.page = "main"; }
            service.refreshWifiStatus();
            wifiSettleTimer.begin();
            service.refreshWifiList();
        }
    }

    Timer {
        id: wifiSettleTimer
        interval: 1200
        repeat: true
        property int tries: 0
        onTriggered: {
            service.refreshWifiStatus();
            if (service.wifiSsid.length || ++wifiSettleTimer.tries > 6) {
                wifiSettleTimer.tries = 0;
                wifiSettleTimer.stop();
            }
        }
        function begin() { wifiSettleTimer.tries = 0; wifiSettleTimer.restart(); }
    }

    Process { id: pWifiDisconnect }
    function disconnectWifi() {
        pWifiDisconnect.running = false;
        pWifiDisconnect.command = [host.wifiScript, "disconnect"];
        pWifiDisconnect.running = true;
        wifiSettleTimer.begin();
    }
    Process { id: pWifiForget }
    function forgetWifi(ssid) {
        if (!ssid || !ssid.length) return;
        pWifiForget.running = false;
        pWifiForget.command = [host.wifiScript, "forget", String(ssid)];
        pWifiForget.running = true;
        wifiSettleTimer.begin();
        wifiRescanTimer.restart();
    }

    function toggleWifi() { pWifiToggle.running = true; }
    function refreshWifiList() {
        wifiModel.clear();
        service.wifiBusy = true;
        pWifiList.running = true;
    }
    function scanWifi() {
        service.wifiBusy = true;
        pWifiScan.running = true;
        wifiRescanTimer.restart();
    }
    Timer { id: wifiRescanTimer; interval: 2600; onTriggered: service.refreshWifiList() }

    function connectWifi(ssid, password) {
        service.wifiBusy = true;
        service.wifiError = "";
        pWifiConnect.command = password && password.length
            ? [host.wifiScript, "connect", String(ssid), String(password)]
            : [host.wifiScript, "connect", String(ssid)];
        pWifiConnect.running = true;
    }

}
