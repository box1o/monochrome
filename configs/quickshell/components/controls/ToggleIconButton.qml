import QtQuick

IconButton {
    id: toggle

    required property bool active
    property real controlScale: 1

    iconName: ""
    implicitWidth: tokens.buttonSize * controlScale
    implicitHeight: tokens.buttonSize * controlScale
    padding: tokens.px(4) * controlScale
    color: active ? tokens.green : tokens.alpha(tokens.red, 0.75)

    Behavior on color {
        ColorAnimation {
            duration: toggle.tokens.motionEnabled ? toggle.tokens.normalDuration : 0
            easing.type: Easing.OutCubic
        }
    }

    contentItem: Item {
        Rectangle {
            id: track

            anchors.centerIn: parent
            width: tokens.px(22) * toggle.controlScale
            height: tokens.px(12) * toggle.controlScale
            radius: height / 2
            color: "transparent"
            border.width: 1.4 * toggle.controlScale
            border.color: toggle.enabled ? toggle.color : toggle.tokens.alpha(toggle.color, 0.45)

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: tokens.px(6) * toggle.controlScale
                height: width
                radius: width / 2
                x: toggle.active ? track.width - width - toggle.tokens.px(3) * toggle.controlScale : toggle.tokens.px(3) * toggle.controlScale
                color: track.border.color

                Behavior on x {
                    NumberAnimation {
                        duration: toggle.tokens.motionEnabled ? toggle.tokens.normalDuration : 0
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
