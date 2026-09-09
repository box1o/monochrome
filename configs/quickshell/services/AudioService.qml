import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var sinkAudio: sink ? sink.audio : null
    readonly property var sourceAudio: source ? source.audio : null
    readonly property var nodes: Pipewire.nodes
}
