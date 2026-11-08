import QtQuick

Item {
    id: page

    required property QtObject tokens
    required property bool active
    required property real direction

    opacity: active ? 1 : 0
    visible: opacity > 0
    enabled: active

    transform: Translate {
        x: page.active ? 0 : page.direction * 12

        Behavior on x {
            NumberAnimation {
                duration: page.tokens.motionEnabled ? page.tokens.normalDuration : 0
                easing.type: Easing.OutCubic
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: page.tokens.motionEnabled ? page.tokens.normalDuration : 0
        }
    }
}
