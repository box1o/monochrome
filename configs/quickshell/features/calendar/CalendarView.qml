import QtQuick
import QtQuick.Layouts
import "components"

ColumnLayout {
    id: calendar

    required property QtObject model
    required property QtObject tokens

    signal previousRequested()
    signal nextRequested()
    signal todayRequested()

    spacing: 8

    MonthNavigation {
        Layout.fillWidth: true
        tokens: calendar.tokens
        title: calendar.model.title
        onPreviousRequested: calendar.previousRequested()
        onNextRequested: calendar.nextRequested()
        onTodayRequested: calendar.todayRequested()
    }

    RowLayout {
        Layout.fillWidth: true

        Repeater {
            model: calendar.model.weekdays

            Text {
                required property string modelData

                font.family: calendar.tokens.fontFamily
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                text: modelData
                color: calendar.tokens.muted
                font.pixelSize: calendar.tokens.fontSize - 4
            }
        }
    }

    MonthGrid {
        Layout.fillWidth: true
        Layout.fillHeight: true
        cells: calendar.model.cells
        tokens: calendar.tokens
    }
}
