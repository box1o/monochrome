import QtQuick
import QtQuick.Layouts
import "../../../components/controls"
import "../../../components/indicators"

ColumnLayout {
    id: devices

    required property QtObject source
    required property QtObject tokens
    property bool input: false
    readonly property QtObject selected: input ? source.microphone : source.sink
    spacing: 10

    AudioLevelRow {
        Layout.fillWidth: true
        tokens: devices.tokens
        showPercentage: !devices.input
        title: devices.input ? "Microphone gain" : "Device volume"
        detail: !devices.input ? (devices.selected ? devices.source.label(devices.selected) : "No device available") : ""
        iconName: devices.input ? "mic" : "volume-2-bold"
        mutedIconName: devices.input ? "mic-off" : "volume-x-bold"
        available: devices.source.usable(devices.selected)
        volume: available ? (devices.input ? devices.source.microphoneGain : devices.selected.audio.volume) : 0
        muted: available && devices.selected.audio.muted
        onVolumeRequested: value => devices.input ? devices.source.setMicrophoneGain(value) : devices.source.setNodeVolume(devices.selected, value)
        onMuteRequested: devices.source.toggleNodeMute(devices.selected)
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: devices.input
        spacing: 5
        StatusLabel {
            Layout.fillWidth: true
            tokens: devices.tokens
            text: devices.selected?.audio?.muted ? "Microphone muted" : "Input level · aim for green, avoid red"
        }

        AudioLevelMeter {
            Layout.fillWidth: true
            tokens: devices.tokens
            peak: devices.source.inputLevel
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.topMargin: 4
        text: devices.input ? "Input device" : "Output device"
        color: devices.tokens.muted
        font.family: devices.tokens.fontFamily
        font.pixelSize: devices.tokens.fontSize - 3
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 2
        model: devices.input ? devices.source.inputs : devices.source.outputs
        boundsBehavior: Flickable.StopAtBounds
        delegate: SelectableMenuItem {
            required property var modelData
            width: ListView.view.width
            tokens: devices.tokens
            title: devices.source.label(modelData)
            subtitle: modelData === devices.selected ? "Selected" : ""
            iconName: devices.input ? "mic" : "speaker"
            selected: modelData === devices.selected
            onClicked: devices.input ? devices.source.selectInput(modelData) : devices.source.selectOutput(modelData)
        }
    }
}
