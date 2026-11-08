import QtQuick
import QtQuick.Layouts

GridLayout {
    id: grid

    required property var cells
    required property QtObject tokens

    columns: 7
    columnSpacing: 2
    rowSpacing: 2

    Repeater {
        model: grid.cells

        Item {
            id: day

            required property var modelData

            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: 25
            Accessible.role: Accessible.StaticText
            Accessible.name: Qt.formatDate(modelData.date, "dddd, d MMMM yyyy") + (modelData.isToday ? ", today" : "")

            Rectangle {
                anchors.centerIn: parent
                width: 22
                height: 22
                radius: 11
                color: grid.tokens.foreground
                visible: day.modelData.isToday
            }

            Text {
                anchors.centerIn: parent
                text: day.modelData.day
                color: day.modelData.isToday ? grid.tokens.background : day.modelData.inMonth ? grid.tokens.foreground : grid.tokens.muted
                opacity: day.modelData.inMonth ? 1 : 0.45
                font.family: grid.tokens.monoFamily
                font.pixelSize: grid.tokens.fontSize - 3
                font.bold: day.modelData.isToday
            }
        }
    }
}
