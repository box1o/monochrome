import QtQuick
import QtQuick.Layouts

GridLayout {
    id: grid

    required property var cells
    required property QtObject tokens

    columns: 7
    columnSpacing: tokens.px(2)
    rowSpacing: tokens.px(2)

    Repeater {
        model: grid.cells

        Item {
            id: day

            required property var modelData

            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: tokens.px(25)
            Accessible.role: Accessible.StaticText
            Accessible.name: Qt.formatDate(modelData.date, "dddd, d MMMM yyyy") + (modelData.isToday ? ", today" : "")

            Rectangle {
                anchors.centerIn: parent
                width: tokens.px(22)
                height: tokens.px(22)
                radius: width / 2
                color: grid.tokens.foreground
                visible: day.modelData.isToday
            }

            Text {
                anchors.centerIn: parent
                text: day.modelData.day
                color: day.modelData.isToday ? grid.tokens.background : day.modelData.inMonth ? grid.tokens.foreground : grid.tokens.muted
                opacity: day.modelData.inMonth ? 1 : 0.45
                font.family: grid.tokens.monoFamily
                font.pixelSize: grid.tokens.labelSize
                font.bold: day.modelData.isToday
            }
        }
    }
}
