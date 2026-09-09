import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Bluetooth
import Quickshell.Services.Notifications

import QtQuick.Controls
import "../../components"
import "../controls"

ColumnLayout {
    id: battPageRoot
    property var view


            width: parent.width
            spacing: 8
            opacity: battPageRoot.view.sys.page === "battery" ? 1 : 0
            visible: opacity > 0.01

            Header {


                view: battPageRoot.view
                title: battPageRoot.view.sys.tr("Battery")
                onBack: battPageRoot.view.sys.page = "main"
            }

            Rectangle {
                readonly property color tint: battPageRoot.view.sys.batteryCharging || battPageRoot.view.sys.acOnline ? battPageRoot.view.sys.colOk : battPageRoot.view.sys.batteryPct <= 15 ? battPageRoot.view.sys.colCrit : battPageRoot.view.sys.colFg

                Layout.fillWidth: true
                Layout.preferredHeight: 62
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: battPageRoot.view.sys.colLine
                border.width: 1

                ChargeWave {


                    view: battPageRoot.view
                    anchors.fill: parent
                    radius: parent.radius
                    tint: battPageRoot.view.sys.colOk
                    level: battPageRoot.view.sys.batteryPct / 100
                    running: battPageRoot.view.sys.batteryCharging
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    Glyph {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        glyph: battPageRoot.view.sys.batteryLevelIcon
                        color: parent.parent.tint
                        fontFam: battPageRoot.view.sys.fontFam
                        size: battPageRoot.view.sys.iconSize + 3
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: battPageRoot.view.sys.batteryPct + "%"
                            color: parent.parent.parent.tint

                            font {
                                family: battPageRoot.view.sys.fontFam
                                pixelSize: 18
                                bold: true
                            }

                        }

                        Text {
                            Layout.fillWidth: true
                            text: battPageRoot.view.sys.batteryCharging ? battPageRoot.view.sys.tr("Charging") : battPageRoot.view.sys.acOnline ? battPageRoot.view.sys.tr("On AC") : battPageRoot.view.sys.profileLabel
                            color: battPageRoot.view.sys.colMuted
                            elide: Text.ElideRight

                            font {
                                family: battPageRoot.view.sys.fontFam
                                pixelSize: 11
                            }

                        }

                    }

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        Layout.alignment: Qt.AlignVCenter
                        radius: 15
                        visible: battPageRoot.view.sys.batteryCharging || battPageRoot.view.sys.acOnline
                        color: Qt.rgba(battPageRoot.view.sys.colOk.r, battPageRoot.view.sys.colOk.g, battPageRoot.view.sys.colOk.b, 0.18)

                        Text {
                            anchors.centerIn: parent
                            text: String.fromCodePoint(battPageRoot.view.sys.batteryCharging ? 983617 : 984741)
                            color: battPageRoot.view.sys.colOk
                            onVisibleChanged: {
                                if (!visible)
                                    opacity = 1;

                            }

                            font {
                                family: battPageRoot.view.sys.fontFam
                                pixelSize: 15
                            }

                            SequentialAnimation on opacity {
                                running: battPageRoot.view.sys.batteryCharging
                                loops: Animation.Infinite

                                NumberAnimation {
                                    to: 0.4
                                    duration: 750
                                    easing.type: Easing.InOutSine
                                }

                                NumberAnimation {
                                    to: 1
                                    duration: 750
                                    easing.type: Easing.InOutSine
                                }

                            }

                        }

                    }

                }

            }

            RowLayout {
                visible: battPageRoot.view.sys.showPowerProfiles
                Layout.fillWidth: true
                spacing: 8

                PowerSeg {


                    view: battPageRoot.view
                    icon: "󰾆"
                    label: battPageRoot.view.sys.tr("Power saver")
                    profile: "power-saver"
                    accent: battPageRoot.view.sys.colOk
                }

                PowerSeg {


                    view: battPageRoot.view
                    icon: "󰾅"
                    label: battPageRoot.view.sys.tr("Balanced")
                    profile: "balanced"
                    accent: battPageRoot.view.sys.colOn
                }

                PowerSeg {


                    view: battPageRoot.view
                    icon: "󰓅"
                    label: battPageRoot.view.sys.tr("Performance")
                    profile: "performance"
                    accent: battPageRoot.view.sys.colWarn
                }

            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: battPageRoot.view.sys.batteryPresent

                BattStat {


                    view: battPageRoot.view
                    label: battPageRoot.view.sys.tr("Capacity")
                    value: battPageRoot.view.sys.batteryCapacity > 0 ? battPageRoot.view.sys.batteryCapacity.toFixed(1) + " Wh" : "—"
                }

                BattStat {


                    view: battPageRoot.view
                    label: battPageRoot.view.sys.tr("Health")
                    value: battPageRoot.view.sys.batteryHealth > 0 ? battPageRoot.view.sys.batteryHealth + "%" : "—"
                }

                BattStat {


                    view: battPageRoot.view
                    label: battPageRoot.view.sys.batteryCharging ? "󰐥" : "󰚥"
                    value: Math.abs(battPageRoot.view.sys.batteryRate) > 0.05 ? Math.abs(battPageRoot.view.sys.batteryRate).toFixed(1) + " W" : "—"
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: battPageRoot.view.sys.animFast
                }

            }

        }
