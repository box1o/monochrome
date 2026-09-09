import QtQuick
import Quickshell.Services.Mpris

Item {
    width: 0
    height: 0
    visible: false
    property var stickyPlayer: null

    readonly property var player: {
        var list = Mpris.players ? Mpris.players.values : [];
        var playing = null;
        var any = null;
        var stickyAlive = null;
        for (var i = 0; i < list.length; i++) {
            var item = list[i];
            if (!item) continue;
            if (!any) any = item;
            if (item === stickyPlayer) stickyAlive = item;
            if (item.isPlaying && !playing) playing = item;
        }
        return playing || stickyAlive || any;
    }

    readonly property bool active:
        player !== null && player !== undefined
        && String(player.trackTitle).trim().length > 0

    property string art: ""
    property string artTrack: ""

    function refreshArt() {
        if (!player) return;
        var title = String(player.trackTitle || "");
        var source = String(player.trackArtUrl || "");
        if (!title.length) return;
        if (title !== artTrack) {
            artTrack = title;
            art = source;
        } else if (source.length > 0) {
            art = source;
        }
    }

    onPlayerChanged: {
        if (player) stickyPlayer = player;
        refreshArt();
    }

    Connections {
        target: player
        ignoreUnknownSignals: true
        function onTrackArtUrlChanged() { refreshArt(); }
        function onTrackTitleChanged() { refreshArt(); }
        function onPostTrackChanged() { refreshArt(); }
        function onIsPlayingChanged() { refreshArt(); }
    }
}
