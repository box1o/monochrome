import QtQuick
import QtQuick.Layouts

RowLayout {
    id: activity

    required property QtObject tokens
    readonly property real contentWidth: implicitWidth + 24

    spacing: activity.tokens.spacing

    Rectangle {
        Layout.preferredWidth: 7
        Layout.preferredHeight: 7
        radius: 3.5
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
