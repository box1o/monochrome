import QtQml
import "../../power/models"
import "../../sound/models"

QtObject {
    id: feedback

    required property QtObject brightness
    required property QtObject audio
    required property QtObject power
    required property QtObject bluetooth
    property string kind: "power"
    property string title: ""
    property string iconName: ""
    property string symbol: ""
    property int percentage: -1
    property int revision: 0
    readonly property bool active: expiry.running
    readonly property Connections brightnessEvents: Connections {
        target: feedback.brightness
        function onChanged(percentage) {
            feedback.present("brightness", "Brightness", "", percentage, "");
        }
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
        onOccurred: pluggedIn => feedback.present("power", title, String.fromCodePoint(pluggedIn ? 0xF0241 : 0xF0079), percentage, pluggedIn ? "charge" : "disconnect")
    }

    readonly property Connections bluetoothEvents: Connections {
        function onConnectionChanged(device, connected) {
            const title = (device.name || "Bluetooth") + (connected ? "" : " disconnected");
            const battery = device.batteryAvailable ? Math.round(device.battery * 100) : -1;
            feedback.present("bluetooth", title, String.fromCodePoint(0xF00AF), battery, connected ? "connect" : "disconnect");
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
        iconName = eventKind === "brightness" ? "brightness" : eventKind === "volume" ? (audio.muted ? "volume-x-bold" : "volume-2-bold") : "";
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
