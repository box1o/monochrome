import QtQml
import "CalendarMath.js" as CalendarMath

QtObject {
    required property date today
    property int monthOffset: 0
    readonly property date displayed: CalendarMath.month(today, monthOffset)
    readonly property string title: Qt.formatDate(displayed, "MMMM yyyy")
    readonly property var cells: CalendarMath.cells(today, displayed)
    readonly property var weekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    function shiftMonth(delta) {
        monthOffset += delta;
    }

    function reset() {
        monthOffset = 0;
    }
}
