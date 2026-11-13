import QtQuick
import QtQuick.Controls

ToolTip {
    id: tooltip

    required property QtObject tokens

    delay: 550
    timeout: 3000
    margins: tokens.px(6)
    padding: tokens.px(7)
    leftPadding: tokens.px(10)
    rightPadding: tokens.px(10)
    contentWidth: Math.min(tokens.px(240), measurement.width)

    TextMetrics {
        id: measurement

        text: tooltip.text
        font.family: tooltip.tokens.fontFamily
        font.pixelSize: tooltip.tokens.detailSize
    }

    contentItem: Text {
        text: tooltip.text
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        color: tooltip.tokens.foreground
        font: measurement.font
    }

    background: Rectangle {
        radius: tooltip.tokens.radius_small + tokens.px(2)
        color: tooltip.tokens.surface
        border.width: 1
        border.color: tooltip.tokens.alpha(tooltip.tokens.foreground, 0.1)
    }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: tooltip.tokens.motionEnabled ? 80 : 0
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            to: 0
            duration: tooltip.tokens.motionEnabled ? 60 : 0
        }
    }
}
