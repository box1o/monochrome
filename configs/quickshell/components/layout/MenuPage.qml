import QtQuick

FocusScope {
    id: page

    required property QtObject tokens
    property bool active: false
    property real reveal: active ? 1 : 0

    signal closeRequested()

    visible: active
    enabled: active
    focus: active
    Keys.onEscapePressed: closeRequested()

    transform: Translate {
        y: (1 - page.reveal) * -8
    }

    Behavior on reveal {
        NumberAnimation {
            duration: page.tokens.motionEnabled ? page.tokens.normalDuration : 0
            easing.type: Easing.OutCubic
        }
    }
}
