import QtQuick
import Quickshell.Services.UPower

QtObject {
    readonly property var device: UPower.displayDevice
    readonly property bool present: {
        var devices = UPower.devices ? UPower.devices.values : [];
        for (var i = 0; i < devices.length; i++) {
            if (devices[i] && devices[i].ready && devices[i].isLaptopBattery) return true;
        }
        return false;
    }
    readonly property int percentage: device && device.ready ? Math.round(device.percentage * 100) : 100
    readonly property bool charging: device ? device.state === UPowerDeviceState.Charging : false
    readonly property bool onBattery: UPower.onBattery
    readonly property var icons: [
        0xF008E, 0xF007A, 0xF007B, 0xF007C, 0xF007D, 0xF007E,
        0xF007F, 0xF0080, 0xF0081, 0xF0082, 0xF0079
    ]
    readonly property string levelIcon:
        String.fromCodePoint(icons[Math.max(0, Math.min(10, Math.round(percentage / 10)))])
    readonly property string icon: {
        if (charging) return String.fromCodePoint(0xF0241);
        return levelIcon;
    }
    readonly property real health:
        device && device.ready ? Math.round(device.healthPercentage) : 0
    readonly property real capacity:
        device && device.ready ? device.energyCapacity : 0
    readonly property real rate:
        device && device.ready ? device.changeRate : 0
}
