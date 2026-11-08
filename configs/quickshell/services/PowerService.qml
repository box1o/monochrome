import QtQml
import Quickshell.Services.UPower

QtObject {
    id: power

    property int requestedProfile: -1
    property string error: ""
    readonly property bool busy: requestedProfile >= 0
    readonly property int profile: PowerProfiles.profile
    readonly property var profiles: [
        {value: PowerProfile.PowerSaver, title: "Power Saver", detail: "Lower energy use", icon: "leaf"},
        {value: PowerProfile.Balanced, title: "Balanced", detail: "Balanced power and performance", icon: "gauge"},
        {value: PowerProfile.Performance, title: "Performance", detail: "Maximum performance", icon: "zap"}
    ].filter(item => item.value !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)
    readonly property string profileName: profiles.find(item => item.value === profile)?.title || "Balanced"
    readonly property string limitation: PowerProfiles.degradationReason === PerformanceDegradationReason.None
        ? "" : PerformanceDegradationReason.toString(PowerProfiles.degradationReason)

    readonly property bool ready: UPower.displayDevice.ready && UPower.devices.values.some((device) => {
        return device.isLaptopBattery && device.isPresent;
    })
    readonly property bool connected: !UPower.onBattery
    readonly property bool charging: UPower.displayDevice.state === UPowerDeviceState.Charging
    readonly property int percentage: ready ? Math.round(UPower.displayDevice.percentage * 100) : 0

    function selectProfile(value) {
        if (busy || value === profile || !profiles.some(item => item.value === value))
            return;
        error = "";
        requestedProfile = value;
        confirmation.restart();
        PowerProfiles.profile = value;
        confirmProfile();
    }

    function confirmProfile() {
        if (requestedProfile >= 0 && profile === requestedProfile) {
            requestedProfile = -1;
            confirmation.stop();
        }
    }

    readonly property Connections profileChanges: Connections {
        target: PowerProfiles
        function onProfileChanged() { power.confirmProfile(); }
    }

    readonly property Timer confirmation: Timer {
        interval: 3000
        onTriggered: {
            power.requestedProfile = -1;
            power.error = "Could not change the power profile";
        }
    }
}
