import QtQuick
import QtQuick.Controls
import "../icons"

LevelSlider {
    id: slider

    property color readoutColor: tokens.foreground
    property color filledReadoutColor: tokens.onFill
    property string title: ""
    property string displayIconName: ""
    property bool iconInteractive: false
    property string actionDescription: ""
    property bool showPercentage: true
    property string label: enabled ? Math.round(value * 100) + "%" : "—"

    signal iconClicked()

    Readout {
        anchors.fill: parent
        ink: slider.readoutColor
    }

    Item {
        width: slider.width * slider.visualPosition
        height: slider.height
        clip: true

        Readout {
            width: slider.width
            height: slider.height
            ink: slider.filledReadoutColor
        }
    }

    AbstractButton {
        id: iconButton

        anchors.left: parent.left
        anchors.leftMargin: 3
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        height: 22
        visible: slider.iconInteractive
        hoverEnabled: true
        Accessible.name: slider.actionDescription
        onClicked: slider.iconClicked()

        ButtonTooltip {
            parent: iconButton
            tokens: slider.tokens
            text: slider.actionDescription
            visible: iconButton.hovered && iconButton.visible && iconButton.enabled && !iconButton.down && text.length > 0
        }

        background: Rectangle {
            radius: width / 2
            color: "transparent"
            border.width: iconButton.visualFocus ? 1 : 0
            border.color: slider.tokens.focusColor
        }

        contentItem: Item {
        }
    }

    component Readout: Item {
        id: readout

        required property color ink

        AssetIcon {
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            name: slider.displayIconName
            color: readout.ink
        }

        Text {
            id: deviceName

            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, Math.max(0, parent.width - anchors.leftMargin - (percentage.visible ? percentage.implicitWidth + 19 : 7)))
            text: slider.title
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: readout.ink
            font.family: slider.tokens.fontFamily
            font.pixelSize: slider.tokens.detailSize
            visible: slider.title.length > 0
        }

        Text {
            id: percentage

            visible: slider.showPercentage
            anchors.right: parent.right
            anchors.rightMargin: 7
            anchors.verticalCenter: parent.verticalCenter
            text: slider.label
            color: readout.ink
            font.family: slider.tokens.monoFamily
            font.pixelSize: slider.tokens.detailSize
            font.bold: true
        }
    }
}
