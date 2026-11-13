import QtQuick
import "../../../components/indicators"

Item {
    id: feedback

    required property QtObject model
    required property QtObject tokens
    required property QtObject style
    property real lowerRadius: 13
    readonly property color accentColor: {
        switch (model.kind) {
        case "power":
            return tokens.green;
        case "microphone":
            return tokens.yellow;
        case "screenshot":
        case "download":
            return tokens.cyan;
        default:
            return tokens.blue;
        }
    }
    readonly property real contentWidth: status.implicitWidth + 48

    ConnectionWave {
        anchors.fill: parent
        level: feedback.model.percentage >= 0 ? feedback.model.percentage / 100 : 0.5
        lowerRadius: feedback.lowerRadius
        tint: feedback.accentColor
        animated: feedback.tokens.motionEnabled
    }

    StatusFeedbackContent {
        id: status

        anchors.centerIn: parent
        width: Math.min(implicitWidth, Math.max(0, parent.width - tokens.px(24)))
        accentColor: feedback.accentColor
        model: feedback.model
        tokens: feedback.tokens
        style: feedback.style
    }
}
