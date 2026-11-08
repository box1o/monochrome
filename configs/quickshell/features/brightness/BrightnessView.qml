import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/controls"
import "../../components/layout"

MenuPage {
    id: page

    required property QtObject source
    signal backRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            IconButton {
                tokens: page.tokens
                iconName: "chevron-left"
                description: "Back"
                onClicked: page.backRequested()
            }

            Text {
                text: "Display brightness"
                color: page.tokens.foreground
                font.family: page.tokens.fontFamily
                font.pixelSize: page.tokens.fontSize - 2
            }

            Item { Layout.fillWidth: true }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: displays.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: displays
                width: parent.width
                spacing: 6

                Repeater {
                    model: page.source.devices

                    AbstractButton {
                        id: display
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 38
                        enabled: !page.source.busy
                        Accessible.name: modelData.label
                        onClicked: page.source.selectDevice(modelData.id)

                        background: Rectangle {
                            radius: page.tokens.radius
                            color: display.modelData.id === page.source.device
                                ? page.tokens.alpha(page.tokens.foreground, 0.1) : "transparent"
                        }

                        contentItem: Text {
                            leftPadding: 12
                            rightPadding: 12
                            text: display.modelData.label
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            color: page.tokens.foreground
                            font.family: page.tokens.fontFamily
                            font.pixelSize: page.tokens.fontSize - 3
                        }
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
