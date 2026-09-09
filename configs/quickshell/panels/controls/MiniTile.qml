import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Rectangle {
    id: tile
    property var view


        property string icon: ""
        property Component iconItem: null
        property string label: ""
        property string sub: ""
        property bool on: false
        property color accent: tile.view.sys.colOn
        property bool wave: false
        property real waveLevel: 0.5
        readonly property bool solid: tile.on && !tile.wave
        readonly property color ink: tile.solid ? tile.view.sys.fgOn(tile.accent) : tile.view.sys.colFg

        signal iconClicked()
        signal bodyClicked()

        implicitWidth: 140
        implicitHeight: 56
        radius: 14
        color: solid ? accent : on ? Qt.rgba(accent.r, accent.g, accent.b, 0.16) : Qt.rgba(1, 1, 1, 0.05)
        border.color: solid ? accent : on ? Qt.rgba(accent.r, accent.g, accent.b, 0.35) : tile.view.sys.colLine
        border.width: 1

        ChargeWave {
            anchors.fill: parent
            radius: parent.radius
            tint: parent.accent
            level: parent.waveLevel
            running: parent.wave
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 9
            anchors.rightMargin: 10
            spacing: 8

            Rectangle {
                id: miniIcon

                readonly property color ink: tile.solid ? "#ffffff" : tile.on ? tile.view.sys.fgOn(tile.accent) : "#ffffff"

                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 19
                color: tile.solid ? tile.view.sys.colBg : tile.on ? tile.accent : Qt.rgba(1, 1, 1, 0.1)
                scale: miniIconMa.pressed ? 0.9 : (miniIconMa.containsMouse ? 1.07 : 1)

                Text {
                    anchors.centerIn: parent
                    visible: tile.iconItem === null
                    text: tile.icon
                    color: miniIcon.ink

                    font {
                        family: tile.view.sys.fontFam
                        pixelSize: 17
                    }

                }

                Loader {
                    id: iconLoader

                    anchors.centerIn: parent
                    active: tile.iconItem !== null
                    sourceComponent: tile.iconItem
                }

                Binding {
                    target: iconLoader.item
                    property: "color"
                    value: miniIcon.ink
                    when: iconLoader.item !== null
                }

                MouseArea {
                    id: miniIconMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: miniIcon.parent.parent.iconClicked()
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }

                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 130
                        easing.type: Easing.OutBack
                    }

                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: tile.label
                    color: tile.ink
                    elide: Text.ElideRight

                    font {
                        family: tile.view.sys.fontFam
                        pixelSize: 12
                        bold: true
                    }

                }

                Text {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: tile.sub
                    color: tile.solid ? Qt.rgba(tile.ink.r, tile.ink.g, tile.ink.b, 0.6) : tile.view.sys.colMuted
                    elide: Text.ElideRight

                    font {
                        family: tile.view.sys.fontFam
                        pixelSize: 10
                    }

                }

            }

        }

        MouseArea {
            anchors.fill: parent
            anchors.leftMargin: 44
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.bodyClicked()
        }

        Behavior on color {
            ColorAnimation {
                duration: 180
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 180
            }

        }

    }
