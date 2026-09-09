import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: service
    visible: false
    property var host
    readonly property var sinkAudio: host ? host.appState.audio.sinkAudio : null
    readonly property var srcAudio: host ? host.appState.audio.sourceAudio : null
    property string osdKind: ""          // "vol" | "mic" | "bright"
    property real   osdValue: 0          // 0..1
    property bool   osdMuted: false
    readonly property bool osdActive: osdKind.length > 0 && !host.expanded

    Timer {
        id: osdTimer
        interval: 1700
        onTriggered: service.osdKind = ""
    }
    function showOsd(kind, value, muted) {
        osdKind = kind;
        osdValue = Math.max(0, Math.min(1, value));
        osdMuted = muted === true;
        osdTimer.restart();
    }

    readonly property string osdIcon: {
        if (osdKind === "bright") return String.fromCodePoint(0xF00DE);
        if (osdKind === "mic")
            return String.fromCodePoint(osdMuted ? 0xF036D : 0xF036C);
        if (osdMuted || osdValue <= 0.001) return String.fromCodePoint(0xF075F);
        if (osdValue < 0.34) return String.fromCodePoint(0xF057F);
        if (osdValue < 0.67) return String.fromCodePoint(0xF0580);
        return String.fromCodePoint(0xF057E);
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
    property bool osdReady: false
    Timer { interval: 1500; running: true; onTriggered: service.osdReady = true }

    property bool sinkSwitching: false
    onSinkAudioChanged: { service.sinkSwitching = true; sinkSettleTimer.restart(); }
    Timer { id: sinkSettleTimer; interval: 700; onTriggered: service.sinkSwitching = false }

    Connections {
        target: service.sinkAudio
        enabled: service.sinkAudio !== null
        function onVolumeChanged() {
            if (service.osdReady && !service.sinkSwitching)
                host.showOsd("vol", service.sinkAudio.volume, service.sinkAudio.muted);
        }
        function onMutedChanged() {
            if (service.osdReady && !service.sinkSwitching)
                host.showOsd("vol", service.sinkAudio.volume, service.sinkAudio.muted);
        }
    }
    Connections {
        target: service.srcAudio
        enabled: service.srcAudio !== null
        function onMutedChanged() {
            if (service.osdReady) host.showOsd("mic", service.srcAudio.volume, service.srcAudio.muted);
        }
    }

}
