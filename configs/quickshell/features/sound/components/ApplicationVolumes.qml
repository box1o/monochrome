import QtQuick
import "../../../components/controls"
import "../../../components/layout"

MenuList {
    id: applications

    required property QtObject source
    required property QtObject tokens

    model: source.applications
    spacing: 12

    StatusLabel {
        anchors.centerIn: parent
        width: parent.width
        tokens: applications.tokens
        horizontalAlignment: Text.AlignHCenter
        text: "Applications appear while playing sound."
        visible: applications.count === 0
    }

    delegate: AudioLevelRow {
        required property var modelData

        width: applications.width
        tokens: applications.tokens
        title: applications.source.applicationName(modelData)
        available: applications.source.usable(modelData)
        volume: available ? modelData.audio.volume : 0
        muted: available && modelData.audio.muted
        onVolumeRequested: value => {
            return applications.source.setNodeVolume(modelData, value);
        }
        onMuteRequested: applications.source.toggleNodeMute(modelData)
    }
}
