import QtQuick
import QtQuick.Layouts
import "../../../components/icons"

RowLayout {
    id: status

    required property QtObject model
    required property QtObject tokens
    required property QtObject style

    spacing: 8

    Connections {
        function onRevisionChanged() {
            if (status.tokens.motionEnabled)
                arrival.restart();
        }

        target: status.model
    }

    SequentialAnimation {
        id: arrival

        NumberAnimation {
            target: symbol
            property: "scale"
            from: 0.75
            to: 1.14
            duration: status.tokens.fastDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: symbol
            property: "scale"
            to: 1
            duration: status.tokens.normalDuration
            easing.type: Easing.OutCubic
        }
    }

    Item {
        id: symbol
        Layout.preferredWidth: Math.min(status.style.compactHeight - 4, status.tokens.iconSize + 3)
        Layout.preferredHeight: Layout.preferredWidth

        AssetIcon {
            anchors.fill: parent
            visible: status.model.iconName.length > 0
            name: status.model.iconName
            color: status.tokens.blue
        }

        Text {
            anchors.centerIn: parent
            visible: status.model.iconName.length === 0
            text: status.model.symbol
            color: status.model.kind === "bluetooth" ? status.tokens.blue : status.style.foreground
            font.family: status.tokens.monoFamily
            font.pixelSize: symbol.width
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: status.model.title
        color: status.style.foreground
        font.family: status.tokens.monoFamily
        font.pixelSize: status.tokens.fontSize
        font.bold: true
    }

    TextMetrics {
        id: percentageMetrics

        text: "100%"
        font.family: status.tokens.monoFamily
        font.pixelSize: status.tokens.fontSize
        font.bold: true
    }

    Text {
        Layout.preferredWidth: percentageMetrics.width
        Layout.minimumWidth: percentageMetrics.width
        Layout.maximumWidth: percentageMetrics.width
        horizontalAlignment: Text.AlignRight
        visible: status.model.percentage >= 0
        text: status.model.percentage + "%"
        color: status.style.foreground
        font.family: status.tokens.monoFamily
        font.pixelSize: status.tokens.fontSize
        font.bold: true
    }
}
