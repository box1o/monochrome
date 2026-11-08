import QtQml
import "../../power/models"
import "../../sound/models"

QtObject {
    id: feedback

    required property QtObject brightness
    required property QtObject audio
    required property QtObject power
    required property QtObject bluetooth
    property QtObject devices: null
    property QtObject downloads: null
    property QtObject notifications: null
    property string kind: "power"
    property string title: ""
    property string iconName: ""
    property string symbol: ""
    property int percentage: -1
    property int revision: 0
    readonly property bool active: expiry.running
    readonly property Connections brightnessEvents: Connections {
        function onChanged(percentage) {
            feedback.present("brightness", "Brightness", "", percentage, "");
        }

        target: feedback.brightness
    }

    readonly property MicrophoneFeedback microphoneEvents: MicrophoneFeedback {
        source: feedback.audio
        onChanged: muted => feedback.present("microphone", muted ? "Microphone muted" : "Microphone on", "", -1, "")
    }

    readonly property Connections deviceEvents: Connections {
        function onConnectionChanged(label, connected) {
            feedback.present("usb", label + (connected ? " connected" : " disconnected"), "", -1, "");
        }

        target: feedback.devices
    }

    readonly property Connections downloadEvents: Connections {
        function onCompleted(name) {
            feedback.present("download", name, "", -1, "");
        }

        target: feedback.downloads
    }

    readonly property Connections screenshotEvents: Connections {
        function onScreenshotSaved() {
            feedback.present("screenshot", "Screenshot copied", "", -1, "");
        }

        target: feedback.notifications
    }

    readonly property VolumeFeedback volumeEvents: VolumeFeedback {
        source: feedback.audio
        onChanged: (volume, muted) => {
            // Connection sounds accompany connection events; volume feedback is silent.
            feedback.present("volume", muted ? "Muted" : "Volume", "", Math.round(volume * 100), "");
        }
    }

    readonly property PowerEventModel powerEvents: PowerEventModel {
        id: powerEvents

        source: feedback.power
        onOccurred: pluggedIn => feedback.present("power", title, String.fromCodePoint(pluggedIn ? 983617 : 983161), percentage, pluggedIn ? "charge" : "disconnect")
    }

    readonly property Connections bluetoothEvents: Connections {
        function onConnectionChanged(device, connected) {
            const title = (device.name || "Bluetooth") + (connected ? "" : " disconnected");
            const battery = device.batteryAvailable ? Math.round(device.battery * 100) : -1;
            feedback.present("bluetooth", title, String.fromCodePoint(983215), battery, connected ? "connect" : "disconnect");
        }

        target: feedback.bluetooth
    }

    readonly property Timer expiry: Timer {
        interval: ["volume", "brightness"].includes(feedback.kind) ? 1500 : 3500
    }

    signal soundRequested(string name)
    signal presented(string kind)

    function present(eventKind, label, glyph, battery, sound) {
        const entering = !active || kind !== eventKind;
        kind = eventKind;
        const icons = {
            "brightness": "brightness",
            "volume": audio.muted ? "volume-x-bold" : "volume-2-bold",
            "microphone": audio.microphoneMuted ? "mic-off" : "mic",
            "usb": "usb",
            "download": "download",
            "screenshot": "camera"
        };
        iconName = icons[eventKind] || "";
        title = label;
        symbol = glyph;
        percentage = battery;
        if (entering)
            revision++;

        expiry.restart();
        if (sound)
            soundRequested(sound);

        presented(kind);
    }

    function dismiss() {
        expiry.stop();
    }
}
