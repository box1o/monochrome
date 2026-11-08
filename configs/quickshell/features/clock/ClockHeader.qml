import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components/text"

AbstractButton {
    id: header

    required property QtObject clock
    required property QtObject metrics
    required property QtObject tokens
    required property QtObject style
    property bool calendarOpen: false
    required property real clockWidth

    implicitHeight: metrics.headerHeight
    padding: 0
    hoverEnabled: true
    Accessible.name: calendarOpen ? "Back to overview" : "Open calendar"

    background: Rectangle {
        radius: header.tokens.radius_small
        color: "transparent"
        border.width: header.visualFocus ? 1 : 0
        border.color: header.style.foreground
    }

    contentItem: RowLayout {
        spacing: 10

        RowLayout {
            spacing: 3

            Item {
                Layout.preferredWidth: header.clockWidth
                Layout.preferredHeight: header.metrics.clockSize
            }

            DottedText {
                Layout.alignment: Qt.AlignTop
                text: header.clock.seconds
                pixelSize: header.tokens.fontSize - 6
                color: header.tokens.muted
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.family: header.tokens.monoFamily
                font.pixelSize: header.tokens.fontSize - 4
                text: header.clock.dateLabel
                color: header.tokens.muted
            }

            Text {
                text: header.calendarOpen ? "Back to overview" : "Calendar"
                color: header.tokens.muted
                font.family: header.tokens.monoFamily
                font.pixelSize: header.tokens.fontSize - 6
            }
        }
    }
}
