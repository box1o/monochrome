import QtQuick
import QtQuick.Layouts
import "../../../components/indicators"

RowLayout {
    id: activity

    required property QtObject model
    required property QtObject tokens
    required property QtObject style
    readonly property real contentWidth: implicitWidth + 28

    spacing: 8
    Accessible.role: Accessible.StaticText
    Accessible.name: model.dateLabel + ", " + model.description

    Text {
        text: activity.model.dateLabel
        color: activity.style.foreground
        font.family: activity.tokens.monoFamily
        font.pixelSize: activity.tokens.fontSize - 3
    }

    ProgressPill {
        color: activity.style.activityColor
        progress: activity.visible ? activity.model.progress : 0

        Text {
            anchors.centerIn: parent
            text: activity.model.day + "/" + activity.model.daysInMonth
            color: activity.style.activityColor
            font.family: activity.tokens.monoFamily
            font.pixelSize: activity.tokens.fontSize - 6
            font.bold: true
        }

        Behavior on progress {
            NumberAnimation {
                duration: activity.tokens.motionEnabled ? activity.tokens.slowDuration * 2 : 0
                easing.type: Easing.OutCubic
            }
        }
    }
}
