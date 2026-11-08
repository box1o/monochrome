import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: page

    required property QtObject source

    signal backRequested()

    contentItem: content

    ColumnLayout {
        id: content

        anchors.fill: parent
        spacing: 12

        MenuHeader {
            Layout.fillWidth: true
            tokens: page.tokens
            title: "Display brightness"
            onBackRequested: page.backRequested()
        }

        Flickable {
            implicitHeight: Math.max(36, contentHeight)
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: displays.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollMotion {
                motionEnabled: page.tokens.motionEnabled
            }

            ColumnLayout {
                id: displays

                width: parent.width
                spacing: 6

                Repeater {
                    model: page.source.devices

                    SelectableMenuItem {
                        required property var modelData

                        Layout.fillWidth: true
                        tokens: page.tokens
                        title: modelData.label
                        iconName: "brightness"
                        selected: modelData.id === page.source.device
                        enabled: !page.source.busy
                        onClicked: page.source.selectDevice(modelData.id)
                    }
                }
            }
        }

        StatusLabel {
            Layout.fillWidth: true
            tokens: page.tokens
            text: page.source.error
            error: text.length > 0
        }

        BrightnessSlider {
            Layout.fillWidth: true
            source: page.source
            tokens: page.tokens
            title: page.source.label
        }
    }
}
