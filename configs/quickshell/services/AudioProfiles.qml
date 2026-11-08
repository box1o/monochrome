import QtQml
import Quickshell.Io
import "AudioProfileData.js" as ProfileData

QtObject {
    id: profiles

    property bool active: false
    property var cards: []
    property string error: ""
    property bool refreshQueued: false
    property string requestedCard: ""
    property string requestedProfile: ""
    readonly property bool busy: change.running || codecs.running || requestedCard.length > 0

    onActiveChanged: {
        if (active) {
            error = "";
            refresh();
        } else
            debounce.stop();
    }

    function refresh() {
        if (!active && !requestedCard)
            return;
        if (query.running)
            refreshQueued = true;
        else
            query.running = true;
    }

    function select(cardName, profile) {
        const card = cards.find(item => item.name === cardName);
        const selected = card?.profiles.find(item => item.name === profile);
        if (busy || !selected || card.current === profile)
            return;
        error = "";
        requestedCard = card.name;
        requestedProfile = profile;
        confirmation.restart();
        if (selected.stereo) {
            codecs.command = ["pactl", "send-message", "/card/" + card.name + "/bluez", "list-codecs"];
            codecs.running = true;
        } else {
            change.command = ["pactl", "set-card-profile", card.name, profile];
            change.running = true;
        }
    }

    function finish(message = "") {
        confirmation.stop();
        requestedCard = "";
        requestedProfile = "";
        error = message;
    }

    readonly property Timer confirmation: Timer {
        interval: 8000
        onTriggered: {
            profiles.finish("The device did not accept this codec. Reconnect the headphones and try again.");
            profiles.change.running = false;
            profiles.codecs.running = false;
        }
    }

    readonly property Process codecs: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                if (!profiles.requestedCard)
                    return;
                try {
                    const card = profiles.cards.find(item => item.name === profiles.requestedCard);
                    const selected = card?.profiles.find(item => item.name === profiles.requestedProfile);
                    const codec = selected ? ProfileData.codecId(text, selected.title) : null;
                    if (!codec) {
                        profiles.finish("This codec is no longer available. Reconnect the headphones and try again.");
                        return;
                    }
                    profiles.change.command = ["pactl", "send-message", "/card/" + card.name + "/bluez", "switch-codec", JSON.stringify(codec)];
                    profiles.change.running = true;
                } catch (_) {
                    profiles.finish("Could not read the device's available codecs.");
                }
            }
        }
        onExited: (code, status) => {
            if (code !== 0 && profiles.requestedCard)
                profiles.finish("Could not query the device's codec controls.");
        }
    }

    readonly property Process query: Process {
        command: ["pactl", "-f", "json", "list", "cards"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    profiles.cards = ProfileData.parse(text);
                    const requested = profiles.cards.find(card => card.name === profiles.requestedCard);
                    if (requested && requested.current === profiles.requestedProfile)
                        profiles.finish();
                } catch (_) {
                    profiles.error = "Could not read Bluetooth audio profiles.";
                }
            }
        }
        onExited: (code, status) => {
            if (code !== 0)
                profiles.error = "Audio profiles are unavailable. Check that PipeWire Pulse is running.";
            if (profiles.refreshQueued) {
                profiles.refreshQueued = false;
                profiles.debounce.restart();
            }
        }
    }

    readonly property Process change: Process {
        onExited: (code, status) => {
            if (code !== 0 && profiles.requestedCard)
                profiles.finish("Could not change the audio profile. Check that the device is connected.");
            profiles.debounce.restart();
        }
    }

    readonly property Process events: Process {
        command: ["pactl", "subscribe"]
        running: profiles.active
        stdout: SplitParser {
            onRead: line => {
                if (/ on (card|server) /.test(line))
                    profiles.debounce.restart();
            }
        }
    }

    readonly property Timer debounce: Timer {
        interval: 200
        onTriggered: profiles.refresh()
    }
}
