import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Rectangle {
    id: loadCardRoot
    property var view

        radius: 14
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: loadCardRoot.view.sys.colLine
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 11
            anchors.rightMargin: 11
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            spacing: 4

            LoadRow {
                view: loadCardRoot.view
                Layout.fillWidth: true
                glyph: String.fromCodePoint(986848)
                name: "CPU"
                pct: loadCardRoot.view.sys.loadCpu
                temp: loadCardRoot.view.sys.loadTempCpu
            }

            LoadRow {
                view: loadCardRoot.view
                Layout.fillWidth: true
                glyph: String.fromCodePoint(983899)
                name: "RAM"
                pct: loadCardRoot.view.sys.loadMem
            }

            LoadRow {
                view: loadCardRoot.view
                Layout.fillWidth: true
                glyph: String.fromCodePoint(983929)
                name: "GPU"
                pct: loadCardRoot.view.sys.loadGpu
                temp: loadCardRoot.view.sys.loadTempGpu
            }

        }

    }
