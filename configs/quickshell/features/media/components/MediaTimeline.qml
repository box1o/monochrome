import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../components/text"

ColumnLayout {
    id: timeline

    required property QtObject source
    required property QtObject tokens
    required property var levels
    property var dragPlayer: null
    property int dragTrack: -1
    property real preview: 0

    spacing: 2

    Slider {
        id: seek

        objectName: "playback-position"
        Layout.fillWidth: true
        implicitHeight: 12
        from: 0
        to: 1
        padding: 0
        live: true
        hoverEnabled: true
        onMoved: timeline.preview = value
        enabled: timeline.source.canSeek
        Accessible.name: "Playback position"
        onPressedChanged: {
            if (pressed) {
                timeline.preview = value;
                timeline.dragPlayer = timeline.source.player;
                timeline.dragTrack = timeline.source.trackId;
            } else if (enabled && timeline.dragPlayer === timeline.source.player && timeline.dragTrack === timeline.source.trackId) {
                timeline.source.seek(timeline.preview);
            }
        }
        Keys.onLeftPressed: timeline.source.seek(value - 5 / Math.max(1, timeline.source.duration))
        Keys.onRightPressed: timeline.source.seek(value + 5 / Math.max(1, timeline.source.duration))

        Binding {
            target: seek
            property: "value"
            value: timeline.source.duration > 0 ? timeline.source.position / timeline.source.duration : 0
            when: !seek.pressed
            restoreMode: Binding.RestoreNone
        }

        background: MediaWaveform {
            width: seek.width
            height: seek.height
            tokens: timeline.tokens
            levels: timeline.levels
            progress: seek.visualPosition
        }

        handle: Rectangle {
            x: Math.max(0, Math.min(seek.width - width, seek.visualPosition * seek.width - width / 2))
            width: 2
            height: seek.height
            radius: 1
            color: timeline.tokens.foreground
            visible: seek.enabled && (seek.hovered || seek.pressed || seek.activeFocus)
        }
    }

    RowLayout {
        Layout.fillWidth: true

        DottedText {
            text: timeline.source.formatTime(seek.pressed ? timeline.preview * timeline.source.duration : timeline.source.position)
            color: timeline.tokens.muted
            pixelSize: 8
            letterSpacing: 1
        }

        Item {
            Layout.fillWidth: true
        }

        DottedText {
            text: timeline.source.duration > 0 ? timeline.source.formatTime(timeline.source.duration) : "--:--"
            color: timeline.tokens.alpha(timeline.tokens.foreground, 0.3)
            pixelSize: 8
            letterSpacing: 1
        }
    }
}
