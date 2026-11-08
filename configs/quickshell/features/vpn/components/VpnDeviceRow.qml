import QtQuick
import QtQuick.Layouts
import "../../../components/controls"
import "../../../components/icons"

OverviewCard {
    id: row

    required property var device
    required property bool busy
    signal copyRequested()
    signal pingRequested()

    implicitHeight: 44

    RowLayout {
        anchors.fill: parent
        anchors.margins: 7
        spacing: 10

        AssetIcon {
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            name: ["android", "iOS"].includes(row.device.os) ? "smartphone" : "laptop"
            color: row.device.online ? row.tokens.blue : row.tokens.muted
        }

        Text {
            Layout.fillWidth: true
            text: row.device.name
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: row.tokens.foreground
            font.family: row.tokens.fontFamily
            font.pixelSize: row.tokens.fontSize - 3
        }

        Text {
            text: row.device.self ? "This device" : row.device.online ? "Online" : "Offline"
            color: row.device.online && !row.device.self ? row.tokens.green : row.tokens.muted
            font.family: row.tokens.fontFamily
            font.pixelSize: row.tokens.fontSize - 5
        }

        IconButton {
            tokens: row.tokens
            iconName: "activity"
            description: "Check connection to " + row.device.name
            visible: row.device.online && !row.device.self
            enabled: !row.busy
            onClicked: row.pingRequested()
        }

        IconButton {
            tokens: row.tokens
            iconName: "copy"
            description: "Copy IP address"
            enabled: row.device.address.length > 0
            onClicked: row.copyRequested()
        }
    }
}
