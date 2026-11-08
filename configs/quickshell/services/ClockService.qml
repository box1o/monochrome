import Quickshell

SystemClock {
    property bool detailed: false
    readonly property string dayKey: Qt.formatDateTime(date, "yyyy-MM-dd")
    readonly property date today: new Date(dayKey + "T12:00:00")
    readonly property string seconds: Qt.formatDateTime(date, "ss")
    readonly property string dateLabel: Qt.formatDateTime(date, "dddd, d MMMM")
    readonly property string text: Qt.formatDateTime(date, "HH:mm")

    precision: detailed ? SystemClock.Seconds : SystemClock.Minutes
}
