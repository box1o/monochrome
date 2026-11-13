import "../../../components/controls"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: panel

    required property QtObject tokens
    required property QtObject model
    readonly property QtObject source: model.source
    property bool protectionsOpen: false

    spacing: tokens.sectionSpacing

    Item {
        Layout.fillWidth: true
        implicitHeight: levels.implicitHeight + tokens.px(28)

        ColumnLayout {
            id: levels

            anchors.fill: parent
            anchors.margins: tokens.px(14)
            spacing: tokens.px(14)

            SettingLevel {
                Layout.fillWidth: true
                tokens: panel.tokens
                title: "Brightness"
                minimum: 1
                value: Number(panel.source.values.brightness) || 1
                enabled: panel.source.writable && !panel.source.busy
                onCommitted: (next) => {
                    return panel.source.request("settings", {
                        "brightness": next
                    }, "brightness");
                }
            }

            SettingLevel {
                Layout.fillWidth: true
                tokens: panel.tokens
                title: "Sound"
                value: Number(panel.source.values.volume) || 0
                enabled: panel.source.writable && !panel.source.busy
                onCommitted: (next) => {
                    return panel.source.request("settings", {
                        "volume": next
                    }, "volume");
                }
            }

            RowLayout {
                Text {
                    Layout.fillWidth: true
                    text: "Energy metering"
                    color: panel.tokens.muted
                    font.family: panel.tokens.fontFamily
                    font.pixelSize: panel.tokens.labelSize
                }

                TextButton {
                    tokens: panel.tokens
                    text: panel.source.values.metering === 1 ? "On" : "Off"
                    selected: panel.source.values.metering === 1
                    enabled: panel.source.writable && !panel.source.busy
                    onClicked: panel.source.request("settings", {
                        "metering": panel.source.values.metering === 1 ? 0 : 1
                    }, "metering")
                }

            }

        }

    }

    Repeater {
        model: [{
            "title": "Temperature",
            "value": !panel.source.stale && Number.isFinite(panel.source.values.temperature) ? panel.source.values.temperature.toFixed(1) + " °C" : "—"
        }, {
            "title": "Regulation mode",
            "value": !panel.source.stale ? (panel.source.values.mode === 0 ? "CC" : panel.source.values.mode === 1 ? "CV" : "—") : "—"
        }, {
            "title": "Input voltage",
            "value": !panel.source.stale && Number.isFinite(panel.source.values.inputVoltage) ? panel.source.values.inputVoltage.toFixed(2) + " V" : "—"
        }]

        RowLayout {
            required property var modelData

            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: modelData.title
                color: panel.tokens.muted
                font.family: panel.tokens.fontFamily
                font.pixelSize: panel.tokens.labelSize
            }

            Text {
                text: modelData.value
                color: panel.tokens.foreground
                font.family: panel.tokens.monoFamily
                font.pixelSize: panel.tokens.labelSize
            }

        }

    }

    TextButton {
        Layout.fillWidth: true
        tokens: panel.tokens
        text: panel.protectionsOpen ? "Protection settings −" : "Protection settings +"
        selected: panel.protectionsOpen
        onClicked: panel.protectionsOpen = !panel.protectionsOpen
    }

    ProtectionSettings {
        Layout.fillWidth: true
        visible: panel.protectionsOpen
        tokens: panel.tokens
        model: panel.model.protections
    }

}
