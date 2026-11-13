import "../../../components/controls"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

AbstractButton {
    id: tile

    required property QtObject tokens
    required property int number
    required property var preset
    property bool selected: false
    property bool editing: false
    property bool editable: false

    signal editRequested()

    implicitHeight: tokens.px(82)
    hoverEnabled: true
    Accessible.name: "Preset " + number + (preset.loaded ? ": " + preset.voltage.toFixed(2) + " volts, " + preset.current.toFixed(3) + " amperes" : ", loading")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: tokens.px(12)
        spacing: tokens.px(8)

        Text {
            text: "Preset " + String(tile.number).padStart(2, "0")
            color: tile.selected ? tile.tokens.blue : tile.tokens.muted
            font.family: tile.tokens.fontFamily
            font.pixelSize: tile.tokens.labelSize
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: tile.preset.loaded ? tile.preset.voltage.toFixed(2) + " V" : "— V"
                color: tile.tokens.blue
                font.family: tile.tokens.monoFamily
                font.pixelSize: tokens.textSize(22)
            }

            Text {
                text: tile.preset.loaded ? tile.preset.current.toFixed(3) + " A" : "— A"
                color: tile.tokens.magenta
                font.family: tile.tokens.monoFamily
                font.pixelSize: tile.tokens.labelSize
            }

        }

    }

    IconButton {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: tokens.px(3)
        tokens: tile.tokens
        iconName: "pencil"
        description: "Edit preset " + tile.number
        opacity: tile.hovered || activeFocus || tile.editing ? 1 : 0.25
        enabled: tile.editable
        onClicked: tile.editRequested()
    }

    background: Rectangle {
        radius: tile.tokens.controlRadius
        color: tile.selected ? tile.tokens.alpha(tile.tokens.blue, 0.08) : tile.hovered ? tile.tokens.hoverBackground : "transparent"
        border.width: tile.visualFocus ? 1 : 0
        border.color: tile.tokens.blue

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: tokens.px(10)
            height: 1
            color: tile.tokens.cardBorder
        }

    }

}
