import QtQuick
import QtQuick.Layouts

RowLayout {
    id: header

    required property QtObject tokens
    required property var sections
    required property string currentSection
    property Component action: null

    signal backRequested()
    signal sectionRequested(string section)

    spacing: tokens.gap_inner

    IconButton {
        tokens: header.tokens
        iconName: "chevron-left"
        description: "Back"
        onClicked: header.backRequested()
    }

    Repeater {
        model: header.sections

        TextButton {
            required property string modelData

            tokens: header.tokens
            text: modelData
            selected: header.currentSection === modelData
            textColor: selected ? header.tokens.foreground : header.tokens.muted
            Accessible.role: Accessible.PageTab
            Accessible.selected: selected
            onClicked: header.sectionRequested(modelData)
        }
    }

    Item {
        Layout.fillWidth: true
    }

    Loader {
        sourceComponent: header.action
        visible: item !== null
    }
}
