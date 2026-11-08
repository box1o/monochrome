import QtQml
import Quickshell.Services.Pipewire

QtObject {
    id: audio

    property bool browsing: false
    property bool monitoringInput: false
    readonly property QtObject sink: Pipewire.defaultAudioSink
    readonly property QtObject microphone: Pipewire.defaultAudioSource
    readonly property var nodes: Pipewire.nodes.values.filter(node => node.audio !== null)
    readonly property var outputs: nodes.filter(node => !node.isStream && node.isSink)
    readonly property var inputs: nodes.filter(node => !node.isStream && !node.isSink)
    readonly property var applications: nodes.filter(node => node.type === PwNodeType.AudioOutStream)
    readonly property bool available: usable(sink)
    readonly property bool microphoneAvailable: usable(microphone)
    readonly property bool microphoneMuted: microphoneAvailable && microphone.audio.muted
    readonly property real microphoneGain: usable(microphone) ? Math.cbrt(Math.max(0, microphone.audio.volume)) : 0
    readonly property real volume: available ? sink.audio.volume : 0
    readonly property bool muted: available && sink.audio.muted
    readonly property string name: sink ? label(sink) : "No output device"
    readonly property PwNodePeakMonitor microphoneLevels: PwNodePeakMonitor {
        node: audio.microphone
        enabled: audio.monitoringInput && audio.usable(audio.microphone) && !audio.microphone.audio.muted
    }

    readonly property real inputLevel: microphoneLevels.enabled ? microphoneLevels.peak : 0
    readonly property PwObjectTracker tracker: PwObjectTracker {
        objects: audio.browsing ? audio.nodes : [audio.sink, audio.microphone].filter(node => node !== null)
    }

    function usable(node) {
        return !!node && node.ready && node.audio !== null;
    }

    function label(node) {
        return node ? (node.nickname || node.description || node.name) : "No device";
    }

    function applicationName(node) {
        return node.ready ? (node.properties["application.name"] || label(node)) : label(node);
    }

    function setNodeVolume(node, value) {
        if (!usable(node) || !Number.isFinite(value))
            return;

        node.audio.volume = Math.max(0, Math.min(1, value));
        if (value > 0 && node.audio.muted)
            node.audio.muted = false;
    }

    function setMicrophoneGain(value) {
        if (Number.isFinite(value)) {
            const gain = Math.max(0, Math.min(1, value));
            setNodeVolume(microphone, gain * gain * gain);
        }
    }

    function toggleNodeMute(node) {
        if (usable(node))
            node.audio.muted = !node.audio.muted;
    }

    function setVolume(value) {
        setNodeVolume(sink, value);
    }

    function toggleMute() {
        toggleNodeMute(sink);
    }

    function selectOutput(node) {
        if (outputs.includes(node))
            Pipewire.preferredDefaultAudioSink = node;
    }

    function selectInput(node) {
        if (inputs.includes(node))
            Pipewire.preferredDefaultAudioSource = node;
    }
}
