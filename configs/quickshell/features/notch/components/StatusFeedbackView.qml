import QtQuick
import "../../../components/indicators"

Item {
    id: feedback

    required property QtObject model
    required property QtObject tokens
    required property QtObject style
    property real lowerRadius: 13
    readonly property real contentWidth: status.implicitWidth + 48

    ConnectionWave {
        anchors.fill: parent
        level: feedback.model.percentage >= 0 ? feedback.model.percentage / 100 : 0.5
        lowerRadius: feedback.lowerRadius
        tint: feedback.model.kind !== "power" ? feedback.tokens.blue : feedback.style.foreground
        animated: feedback.tokens.motionEnabled
    }

    StatusFeedbackContent {
        id: status

        anchors.centerIn: parent
        width: Math.min(implicitWidth, Math.max(0, parent.width - 24))
        model: feedback.model
        tokens: feedback.tokens
        style: feedback.style
    }
}
