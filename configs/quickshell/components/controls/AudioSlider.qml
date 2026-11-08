import QtQuick

LabeledSlider {
    id: slider

    property string iconName: "volume-2-bold"
    property string mutedIconName: "volume-x-bold"
    property bool muted: false
    signal muteRequested

    displayIconName: muted ? mutedIconName : iconName
    iconInteractive: true
    actionDescription: (muted ? "Unmute " : "Mute ") + description
    onIconClicked: muteRequested()
}
