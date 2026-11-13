import "../../components/controls"
import "../../components/layout"
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import "components"

MenuPage {
    id: page

    required property QtObject model
    readonly property QtObject source: model.source
    readonly property bool editingText: {
        const window = page.Window.window;
        const focused = window ? window.activeFocusItem : null;
        return !!focused && typeof focused.readOnly === "boolean" && !focused.readOnly;
    }

    contentItem: content

    HoverHandler {
        id: panelHover

        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    Shortcut {
        sequence: "Space"
        autoRepeat: false
        enabled: page.active && panelHover.hovered && !page.editingText
        onActivated: page.model.toggleOutput()
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: page.tokens.spacing

        TabHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            sections: page.model.sections
            currentSection: page.model.section
            showBackButton: false
            onSectionRequested: (section) => {
                return page.model.section = section;
            }

            action: Component {
                SupplyToolbar {
                    tokens: page.tokens
                    model: page.model
                    showOutput: page.model.section !== "Settings"
                }

            }

        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            text: page.source.error || (page.source.values.protection ? "Protection active" : page.source.ready && page.source.state.readOnly ? "Controls locked" : "")
            error: page.source.error.length > 0 || !!page.source.values.protection
        }

        ControlPanel {
            Layout.fillWidth: true
            visible: page.model.section === "Control"
            tokens: page.tokens
            model: page.model
        }

        PresetsPanel {
            Layout.fillWidth: true
            visible: page.model.section === "Presets"
            tokens: page.tokens
            model: page.model
        }

        SettingsPanel {
            Layout.fillWidth: true
            visible: page.model.section === "Settings"
            tokens: page.tokens
            model: page.model
        }

        Item {
            Layout.fillHeight: true
        }

    }

}
