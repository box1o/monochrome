import QtQuick

Item {
    width: 0
    height: 0
    visible: false
    property var config
    property string timeText: ""
    property string dayText: ""
    property string dateLong: ""
    property string secText: ""
    property string dayNum: ""
    property bool weekend: false
    property string monthText: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date();
            var seconds = config && config.clockSeconds ? ":ss" : "";
            timeText = config && config.clock12
                ? Qt.formatDateTime(d, "h:mm" + seconds + " AP")
                : Qt.formatDateTime(d, "HH:mm" + seconds);
            secText = Qt.formatDateTime(d, "ss");
            dateLong = (config && config.clockWeekday ? Qt.formatDateTime(d, "dddd") + ", " : "")
                + Qt.formatDateTime(d, (config && config.clockDateFmt) || "d MMMM");
            dayText = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][d.getDay()];
            dayNum = String(d.getDate());
            weekend = d.getDay() === 0 || d.getDay() === 6;
            monthText = ["January", "February", "March", "April", "May", "June", "July",
                         "August", "September", "October", "November", "December"][d.getMonth()];
        }
    }
}
