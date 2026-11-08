import QtQml

QtObject {
    id: activity

    required property date today
    property int duration: 3200
    readonly property bool active: expiry.running
    readonly property int daysInMonth: new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate()
    readonly property int day: today.getDate()
    readonly property real progress: day / daysInMonth
    readonly property string dateLabel: Qt.formatDate(today, "ddd MMM")
    readonly property string description: "Day " + day + " of " + daysInMonth + " this month"
    readonly property Timer expiryTimer: Timer {
        id: expiry

        interval: activity.duration
    }

    function show() {
        expiry.restart();
    }

    function dismiss() {
        expiry.stop();
    }
}
