import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: service
    visible: false
    property var host
    readonly property var audioSinks: {
        var out = [];
        var all = Pipewire.nodes ? Pipewire.nodes.values : [];
        for (var i = 0; i < all.length; i++) {
            var n = all[i];
            if (n && n.isSink && !n.isStream) out.push(n);
        }
        return out;
    }
    readonly property var audioSources: {
        var out = [];
        var all = Pipewire.nodes ? Pipewire.nodes.values : [];
        for (var i = 0; i < all.length; i++) {
            var n = all[i];
            if (n && n.isSource && !n.isStream) out.push(n);
        }
        return out;
    }
    readonly property var audioStreams: {
        var out = [];
        var all = Pipewire.nodes ? Pipewire.nodes.values : [];
        for (var i = 0; i < all.length; i++) {
            var n = all[i];
            if (n && n.isStream && n.audio) {
                var props = n.properties || {};
                var name = String(props["application.name"] || props["media.name"] || n.name || "").toLowerCase();
                if (name.indexOf("cava") < 0 && name.indexOf("quickshell") < 0) {
                    out.push(n);
                }
            }
        }
        return out;
    }
    readonly property string sinkName: {
        var n = Pipewire.defaultAudioSink;
        if (!n) return "";
        return String(n.nickname || n.description || n.name || "");
    }
    readonly property var source: Pipewire.defaultAudioSource
    readonly property string sourceName: {
        var n = Pipewire.defaultAudioSource;
        if (!n) return "";
        return String(n.nickname || n.description || n.name || "");
    }
    function setSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }
    function setSource(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }
    function moveStream(streamId, sinkId) {
        if (host && host.runDetached)
            host.runDetached(host.scriptDir + "/audio_streams.sh move " + String(streamId) + " " + String(sinkId));
    }

}
