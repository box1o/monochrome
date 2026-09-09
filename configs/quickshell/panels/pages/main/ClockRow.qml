import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import "../../../components"
import Quickshell
import Quickshell.Services.Pipewire

import QtQuick.Controls
import "../../controls"
import "../../../components"

RowLayout {
    id: clockRowRoot
    property var view

                objectName: "cc-clock"
                Layout.row: clockRowRoot.view.ccRow("clock")
                Layout.column: 0
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 12
                    color: clockMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

                    RowLayout {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 4
                        spacing: 10

                        Text {
                            visible: !clockRowRoot.view.sys.themeNothing
                            text: clockRowRoot.view.sys.timeText
                            color: clockRowRoot.view.sys.colFg

                            font {
                                family: clockRowRoot.view.sys.fontFam
                                pixelSize: clockRowRoot.view.sys.fontSize + 8
                                bold: true
                            }

                        }

                        RowLayout {
                            visible: clockRowRoot.view.sys.themeNothing
                            spacing: 5

                            DotText {
                                Layout.alignment: Qt.AlignVCenter
                                value: clockRowRoot.view.sys.timeText
                                size: clockRowRoot.view.sys.dotHBig
                                color: clockRowRoot.view.sys.colFg
                            }

                            DotText {
                                Layout.alignment: Qt.AlignTop
                                Layout.topMargin: 1
                                visible: !clockRowRoot.view.sys.cfg.clockSeconds
                                value: clockRowRoot.view.sys.secText
                                size: clockRowRoot.view.sys.dotHSmall
                                color: clockRowRoot.view.sys.colMuted
                            }

                        }

                        ColumnLayout {
                            spacing: -1

                            Text {
                                text: clockRowRoot.view.sys.dateLong
                                color: clockRowRoot.view.sys.colMuted

                                font {
                                    family: clockRowRoot.view.sys.fontFam
                                    pixelSize: clockRowRoot.view.sys.fontSize - 3
                                }

                            }

                            Text {
                                text: clockRowRoot.view.sys.tr("Calendar")
                                color: clockMa.containsMouse ? clockRowRoot.view.sys.colOn : Qt.rgba(1, 1, 1, 0.28)

                                font {
                                    family: clockRowRoot.view.sys.fontFam
                                    pixelSize: clockRowRoot.view.sys.fontSize - 5
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }

                                }

                            }

                        }

                    }

                    MouseArea {
                        id: clockMa

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clockRowRoot.view.sys.togglePage("cal")
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

            }
