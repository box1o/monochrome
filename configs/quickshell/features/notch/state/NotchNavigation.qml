import QtQml

QtObject {
    property string page: "overview"
    readonly property bool overviewOpen: page === "overview"
    readonly property bool calendarOpen: page === "calendar"
    readonly property bool clipboardOpen: page === "clipboard"
    readonly property bool launcherOpen: page === "launcher"
    readonly property bool wifiOpen: page === "wifi"
    readonly property bool bluetoothOpen: page === "bluetooth"
    readonly property bool soundOpen: page === "sound"
    readonly property bool brightnessOpen: page === "brightness"
    readonly property bool vpnOpen: page === "vpn"
    readonly property bool powerOpen: page === "power"
    readonly property bool phoneOpen: page === "phone"
    readonly property bool sessionOpen: page === "session"
    readonly property bool notificationsOpen: page === "notifications"
    readonly property bool trayOpen: page === "tray"
    readonly property bool detailsOpen: !overviewOpen && !calendarOpen

    function toggleCalendar() {
        page = calendarOpen ? "overview" : "calendar";
    }

    function reset() {
        page = "overview";
    }
}
