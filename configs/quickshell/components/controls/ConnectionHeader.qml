import QtQuick
import QtQuick.Layouts

MenuHeader {
    id: header

    required property string radioIcon
    property bool radioEnabled: false
    property bool available: true
    property bool busy: false
    property bool scanVisible: false
    property bool scanning: false
    property bool scanStoppable: false

    signal toggleRequested
    signal scanRequested

    action: RowLayout {
        spacing: header.tokens.gap_inner

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
}
