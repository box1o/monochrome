import QtQuick
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"
import "components"

MenuPage {
    id: page

    required property QtObject model
    readonly property QtObject source: model.source
    readonly property QtObject profiles: model.profiles

    signal backRequested()

    contentItem: content

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: page.tokens.spacing

        TabHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            sections: page.model.sections
            currentSection: page.model.section
            onBackRequested: page.backRequested()
            onSectionRequested: section => page.model.selectSection(section)
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            text: page.model.section === "Codec" ? (page.profiles.busy ? "Switching codec…" : page.profiles.error) : ""
            error: page.profiles.error.length > 0 && !page.profiles.busy
        }

        AudioDevices {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: page.source
            tokens: page.tokens
            visible: page.model.section === "Output" || page.model.section === "Input"
            input: page.model.section === "Input"
        }

        ApplicationVolumes {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: page.source
            tokens: page.tokens
            visible: page.model.section === "Applications"
        }

        BluetoothProfiles {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: page.profiles
            tokens: page.tokens
            visible: page.model.section === "Codec"
        }
    }
}
