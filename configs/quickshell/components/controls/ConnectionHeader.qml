import QtQuick
import QtQuick.Layouts

RowLayout {
    id: header

    required property QtObject tokens
    required property string title
    required property string radioIcon
    property bool radioEnabled: false
    property bool available: true
    property bool busy: false
    property bool scanVisible: false
    property bool scanning: false
    property bool scanStoppable: false

    signal backRequested()
    signal toggleRequested()
    signal scanRequested()

    spacing: 6

    IconButton {
        iconName: "chevron-left"
        description: "Back"
        tokens: header.tokens
        onClicked: header.backRequested()
    }

    Text {
        Layout.fillWidth: true
        text: header.title
        color: header.tokens.foreground
        font.family: header.tokens.fontFamily
        font.pixelSize: header.tokens.fontSize - 1
        font.bold: true
    }

    IconButton {
        tokens: header.tokens
        iconName: "rotate-cw"
        description: header.scanning ? (header.scanStoppable ? "Stop scanning" : "Scanning for devices") : "Scan for devices"
        visible: header.scanVisible
        enabled: header.available && header.radioEnabled && !header.busy && (!header.scanning || header.scanStoppable)
        color: header.scanning ? header.tokens.green : header.tokens.muted
        spinning: header.scanning
        onClicked: header.scanRequested()
    }

    RadioIconButton {
        tokens: header.tokens
        active: header.radioEnabled
        radioIcon: header.radioIcon
        description: (header.radioEnabled ? "Disable " : "Enable ") + header.title
        enabled: header.available && !header.busy
        onClicked: header.toggleRequested()
    }
}
