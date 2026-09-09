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
    id: trayRowRoot
    property var view

                objectName: "cc-tray"
                Layout.row: trayRowRoot.view.ccRow("tray")
                Layout.column: 0
                Layout.fillWidth: true
                Layout.topMargin: 2
                spacing: 8
                visible: trayRowRoot.view.sys.trayItems.values.length > 0

                Text {
                    text: trayRowRoot.view.sys.tr("Tray")
                    color: trayRowRoot.view.sys.colMuted

                    font {
                        family: trayRowRoot.view.sys.fontFam
                        pixelSize: trayRowRoot.view.sys.fontSize - 4
                        bold: true
                        capitalization: Font.AllUppercase
                        letterSpacing: 1
                    }

                }

                Repeater {
                    model: trayRowRoot.view.sys.trayItems

                    Rectangle {
                        id: trayBtn

                        required property var modelData

                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        z: trayMa.containsMouse ? 10 : 0
                        radius: 10
                        color: trayMa.containsMouse ? Qt.rgba(1, 1, 1, 0.13) : Qt.rgba(1, 1, 1, 0.05)
                        border.color: trayRowRoot.view.sys.colLine
                        border.width: 1
                        scale: trayMa.pressed ? 0.9 : 1

                        Image {
                            anchors.fill: parent
                            anchors.margins: 7
                            source: String(trayBtn.modelData.icon || "")
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        MouseArea {
                            id: trayMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.RightButton) {
                                    if (!trayBtn.modelData.hasMenu)
                                        return ;

                                    trayRowRoot.view.sys.trayMenuItem = trayBtn.modelData;
                                    trayRowRoot.view.sys.page = "traymenu";
                                    trayRowRoot.view.sys.holdOpen = true;
                                    return ;
                                }
                                if (mouse.button === Qt.MiddleButton)
                                    trayBtn.modelData.secondaryActivate();
                                else
                                    trayBtn.modelData.activate();
                                trayRowRoot.view.sys.collapse();
                            }
                        }

                        Rectangle {
                            id: tip

                            readonly property string label: String(trayBtn.modelData.tooltipTitle || trayBtn.modelData.title || "")

                            visible: opacity > 0.01
                            opacity: (trayMa.containsMouse && label.length) ? 1 : 0
                            width: tipText.implicitWidth + 20
                            height: 26
                            radius: 13
                            x: (parent.width - width) / 2
                            y: -height - 8
                            color: Qt.rgba(0.04, 0.04, 0.05, 0.96)
                            border.color: trayRowRoot.view.sys.colLine
                            border.width: 1
                            scale: trayMa.containsMouse ? 1 : 0.92
                            transformOrigin: Item.Bottom

                            Text {
                                id: tipText

                                anchors.centerIn: parent
                                text: tip.label
                                color: trayRowRoot.view.sys.colFg

                                font {
                                    family: trayRowRoot.view.sys.fontFam
                                    pixelSize: 11
                                }

                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 140
                                }

                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 160
                                    easing.type: Easing.OutBack
                                }

                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 130
                                easing.type: Easing.OutBack
                            }

                        }

                    }

                }

                Item {
                    Layout.fillWidth: true
                }

            }
