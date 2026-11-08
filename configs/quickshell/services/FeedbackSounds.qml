import QtQml
import QtMultimedia
import Quickshell

QtObject {
    id: sounds

    readonly property string directory: "file://" + Quickshell.env("HOME") + "/.local/share/mono/sounds/"
    readonly property SoundEffect charge: SoundEffect {
        source: sounds.directory + "charge.wav"
        volume: 0.25
    }

    readonly property SoundEffect connected: SoundEffect {
        source: sounds.directory + "connect.wav"
        volume: 0.25
    }

    readonly property SoundEffect disconnected: SoundEffect {
        source: sounds.directory + "disconnect.wav"
        volume: 0.25
    }

    function play(name) {
        const effects = {
            "charge": charge,
            "connect": connected,
            "disconnect": disconnected
        };
        const effect = effects[name];
        if (!effect)
            return;

        charge.stop();
        connected.stop();
        disconnected.stop();
        effect.play();
    }
}
