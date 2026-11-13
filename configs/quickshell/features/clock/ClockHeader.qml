import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/text"

RowLayout {
    id: header

    required property QtObject clock
    required property QtObject metrics
    required property QtObject tokens
    required property real clockWidth
    property bool calendarOpen: false
    property Component accessory: null
    property bool accessoryVisible: false

    signal clicked

    implicitHeight: metrics.headerHeight
    Layout.minimumHeight: metrics.headerHeight
    Layout.preferredHeight: metrics.headerHeight
    Layout.maximumHeight: metrics.headerHeight
    spacing: tokens.spacing

    AbstractButton {
        id: calendarButton

        Layout.fillWidth: true
        Layout.fillHeight: true
        padding: 0
        hoverEnabled: true
        Accessible.name: header.calendarOpen ? "Back to overview" : "Open calendar"
        onClicked: header.clicked()

        background: Rectangle {
            radius: header.tokens.radius_small
            color: "transparent"
            border.width: calendarButton.visualFocus ? 1 : 0
            border.color: header.tokens.focusColor
        }

        contentItem: RowLayout {
            spacing: header.tokens.spacing

            RowLayout {
                spacing: tokens.px(3)

                Item {
                    Layout.preferredWidth: header.clockWidth
                    Layout.preferredHeight: header.metrics.clockSize
                }

                DottedText {
                    Layout.alignment: Qt.AlignTop
                    text: header.clock.seconds
                    pixelSize: header.tokens.captionSize
                    color: header.tokens.muted
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: header.tokens.gap_inner

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                    font.family: header.tokens.monoFamily
                    font.pixelSize: header.tokens.detailSize
                    text: header.clock.dateLabel
                    color: header.tokens.muted
                }

                Text {
                    text: header.calendarOpen ? "Back to overview" : "Calendar"
                    color: header.tokens.muted
                    font.family: header.tokens.monoFamily
                    font.pixelSize: header.tokens.captionSize
                }
            }
        }
    }

    Loader {
        sourceComponent: header.accessory
        active: header.accessoryVisible && header.accessory !== null
        visible: active
        Layout.alignment: Qt.AlignVCenter
    }
}
