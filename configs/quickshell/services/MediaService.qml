import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: media

    property bool monitoring: false
    property var preferred: null
    readonly property var players: Mpris.players.values
    readonly property var player: players.find(item => item.isPlaying) || players.find(item => item === preferred) || players[0] || null
    readonly property int trackId: player?.uniqueId ?? -1
    readonly property bool available: player !== null
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: player?.trackTitle || player?.identity || "Media"
    readonly property string artist: player?.trackArtist || player?.identity || ""
    readonly property string artwork: player?.trackArtUrl || ""
    readonly property real duration: player?.lengthSupported ? Math.max(0, player.length) : 0
    readonly property real position: player?.positionSupported ? Math.max(0, player.position) : 0
    readonly property bool canSeek: !!player && player.canSeek && player.positionSupported && duration > 0
    readonly property bool canToggle: player?.canTogglePlaying ?? false
    readonly property bool canPrevious: player?.canGoPrevious ?? false
    readonly property bool canNext: player?.canGoNext ?? false

    // Retain selection after the derived player binding has finished evaluating.
    onPlayerChanged: Qt.callLater(media.rememberPlayer)

    function rememberPlayer() {
        if (preferred !== player)
            preferred = player;
    }

    function toggle() {
        if (canToggle)
            player.togglePlaying();
    }

    function previous() {
        if (canPrevious)
            player.previous();
    }

    function next() {
        if (canNext)
            player.next();
    }

    function seek(fraction) {
        if (canSeek && Number.isFinite(fraction))
            player.position = Math.max(0, Math.min(1, fraction)) * duration;
    }

    function formatTime(seconds) {
        const value = Math.max(0, Math.floor(seconds));
        const hours = Math.floor(value / 3600);
        const minutes = Math.floor(value / 60) % 60;
        const rest = String(value % 60).padStart(2, "0");
        return hours > 0 ? hours + ":" + String(minutes).padStart(2, "0") + ":" + rest : minutes + ":" + rest;
    }

    readonly property FrameAnimation positionUpdates: FrameAnimation {
        running: media.monitoring && media.playing && !!media.player && media.player.positionSupported
        onTriggered: media.player.positionChanged()
    }
}
