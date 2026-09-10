import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    required property var sys
    implicitHeight: body.implicitHeight
    focus: true
    Keys.onEscapePressed: sys.collapse()
    ColumnLayout {
        id: body
        width: parent.width
        spacing: 14
        Text { text: sys.tr("Settings"); color: sys.colFg; font.family: sys.fontFam; font.pixelSize: sys.fontSize + 3; font.bold: true }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: sys.pomodoro.preset === "custom" ? 118 : 76; radius: 14
            color: Qt.rgba(1, 1, 1, 0.05); border.color: sys.colLine
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 6
                Text { text: sys.tr("Pomodoro"); color: sys.colMuted; font.family: sys.fontFam; font.pixelSize: sys.fontSize - 3; font.bold: true }
                RowLayout {
                    Layout.fillWidth: true; spacing: 7
                    Repeater {
                        model: ["25/5", "50/10", "custom"]
                        Rectangle {
                            required property string modelData
                            Layout.fillWidth: true; Layout.preferredHeight: 30; radius: 9
                            color: sys.pomodoro.preset === modelData ? Qt.rgba(sys.colOn.r, sys.colOn.g, sys.colOn.b, 0.2) : Qt.rgba(1, 1, 1, 0.07)
                            border.color: sys.pomodoro.preset === modelData ? sys.colOn : sys.colLine
                            Text { anchors.centerIn: parent; text: modelData === "custom" ? sys.tr("Custom") : modelData; color: sys.colFg; font.family: sys.fontFam; font.pixelSize: sys.fontSize - 3 }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sys.setPomodoroPreset(modelData) }
                        }
                    }
                }
                RowLayout {
                    visible: sys.pomodoro.preset === "custom"
                    Layout.fillWidth: true
                    TextField { id: workField; Layout.fillWidth: true; placeholderText: sys.tr("Focus min"); text: String(sys.pomodoro.customWorkMinutes); validator: IntValidator { bottom: 1; top: 180 } }
                    TextField { id: breakField; Layout.fillWidth: true; placeholderText: sys.tr("Break min"); text: String(sys.pomodoro.customBreakMinutes); validator: IntValidator { bottom: 1; top: 60 } }
                    Button { text: sys.tr("Apply"); onClicked: sys.setPomodoroCustom(workField.text, breakField.text) }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 14
            color: Qt.rgba(1, 1, 1, 0.05); border.color: sys.colLine
            RowLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 10
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 2
                    Text { text: sys.tr("Network"); color: sys.colFg; font.family: sys.fontFam; font.pixelSize: sys.fontSize - 2; font.bold: true }
                    Text { text: sys.networkConnected ? (sys.networkName + (sys.networkIp ? " · " + sys.networkIp : "")) : sys.tr("Disconnected"); color: sys.colMuted; elide: Text.ElideRight; font.family: sys.fontFam; font.pixelSize: sys.fontSize - 4 }
                }
                Button { text: sys.tr("Reconnect"); onClicked: sys.reconnectNetwork() }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 14
            color: Qt.rgba(1, 1, 1, 0.05); border.color: sys.colLine
            RowLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 8
                Text { text: sys.tr("Capture"); color: sys.colFg; font.family: sys.fontFam; font.pixelSize: sys.fontSize - 2; font.bold: true }
                Item { Layout.fillWidth: true }
                Button { text: sys.tr("Screenshot"); onClicked: sys.runCapture("screenshot") }
                Button { text: sys.tr("Record"); onClicked: sys.runCapture("record") }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 14
            color: Qt.rgba(1, 1, 1, 0.05); border.color: sys.colLine
            RowLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 8
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 2
                    Text { text: sys.tr("System health"); color: sys.colFg; font.family: sys.fontFam; font.pixelSize: sys.fontSize - 2; font.bold: true }
                    Text { text: "CPU " + sys.loadCpu + "% · RAM " + sys.loadMem + "% · GPU " + sys.loadGpu + "%"; color: sys.colMuted; font.family: sys.fontFam; font.pixelSize: sys.fontSize - 4 }
                }
                Text { text: "°C " + sys.loadTempCpu; color: sys.colMuted; font.family: sys.fontFam; font.pixelSize: sys.fontSize - 3 }
            }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 58; radius: 14
            color: Qt.rgba(1, 1, 1, 0.05); border.color: sys.colLine
            RowLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 8
                Text { text: sys.tr("Configuration backup"); color: sys.colFg; font.family: sys.fontFam; font.pixelSize: sys.fontSize - 2; font.bold: true }
                Item { Layout.fillWidth: true }
                Button { text: sys.tr("Save"); onClicked: sys.backupConfigs() }
                Button { text: sys.tr("Restore"); onClicked: sys.restoreConfigs() }
            }
        }
    }
}
