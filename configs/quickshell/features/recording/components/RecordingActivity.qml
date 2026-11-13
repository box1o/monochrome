import QtQuick
import QtQuick.Layouts

RowLayout {
    id: activity

    required property QtObject tokens
    readonly property real contentWidth: implicitWidth + tokens.px(24)

    spacing: activity.tokens.spacing

    Rectangle {
        Layout.preferredWidth: tokens.px(7)
        Layout.preferredHeight: tokens.px(7)
        radius: width / 2
        color: activity.tokens.red

        SequentialAnimation on opacity {
            running: activity.visible && activity.tokens.motionEnabled
            loops: Animation.Infinite
            NumberAnimation {
                to: 0.4
                duration: activity.tokens.duration(700)
            }
            NumberAnimation {
                to: 1
                duration: activity.tokens.duration(700)
            }
        }
    }

    Text {
        text: "Recording"
        color: activity.tokens.foreground
        font.family: activity.tokens.fontFamily
        font.pixelSize: activity.tokens.labelSize
        font.bold: true
    }
}
