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
    id: quickRowRoot
    property var view

                objectName: "cc-quick"
                Layout.row: quickRowRoot.view.ccRow("quick")
                Layout.column: 0
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    id: awakeRow

                    readonly property color tint: quickRowRoot.view.sys.colOn

                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: 44
                    radius: 12
                    color: quickRowRoot.view.sys.keepAwake ? Qt.rgba(awakeRow.tint.r, awakeRow.tint.g, awakeRow.tint.b, 0.16) : (awakeMa.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(1, 1, 1, 0.05))
                    border.color: quickRowRoot.view.sys.keepAwake ? Qt.rgba(awakeRow.tint.r, awakeRow.tint.g, awakeRow.tint.b, 0.4) : quickRowRoot.view.sys.colLine
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 13
                        anchors.rightMargin: 13
                        spacing: 11

                        Glyph {
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            glyph: String.fromCodePoint(quickRowRoot.view.sys.keepAwake ? 983414 : 983415)
                            color: quickRowRoot.view.sys.keepAwake ? awakeRow.tint : quickRowRoot.view.sys.colMuted
                            fontFam: quickRowRoot.view.sys.fontFam
                            size: quickRowRoot.view.sys.iconSize + 2
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Coffee mode"
                            color: quickRowRoot.view.sys.keepAwake ? quickRowRoot.view.sys.colFg : quickRowRoot.view.sys.colMuted

                            font {
                                family: quickRowRoot.view.sys.fontFam
                                pixelSize: quickRowRoot.view.sys.fontSize - 2
                                bold: quickRowRoot.view.sys.keepAwake
                            }

                        }

                        Rectangle {
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 21
                            radius: 11
                            color: quickRowRoot.view.sys.keepAwake ? awakeRow.tint : Qt.rgba(1, 1, 1, 0.14)

                            Rectangle {
                                width: 17
                                height: 17
                                radius: 9
                                y: 2
                                x: quickRowRoot.view.sys.keepAwake ? parent.width - width - 2 : 2
                                color: quickRowRoot.view.sys.keepAwake ? quickRowRoot.view.sys.fgOn(awakeRow.tint) : "#ffffff"

                                Behavior on x {
                                    NumberAnimation {
                                        duration: 180
                                        easing.type: Easing.OutCubic
                                    }

                                }

                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 180
                                }

                            }

                        }

                    }

                    MouseArea {
                        id: awakeMa

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: quickRowRoot.view.sys.keepAwake = !quickRowRoot.view.sys.keepAwake
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 160
                        }

                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 160
                        }

                    }

                }

                IconBtn {


                    view: quickRowRoot.view
                    glyph: String.fromCodePoint(0xF10B)
                    tip: quickRowRoot.view.sys.tr("Open scrcpy")
                    active: quickRowRoot.view.sys.adbBusy || quickRowRoot.view.sys.page === "scrcpy"
                    onAct: quickRowRoot.view.sys.openScrcpy()
                }

                IconBtn {
                    view: quickRowRoot.view
                    glyph: quickRowRoot.view.sys.btAudioMode === "music"
                           ? String.fromCodePoint(0xF075A) : String.fromCodePoint(0xF036C)
                    tip: quickRowRoot.view.sys.btAudioConnected
                          ? quickRowRoot.view.sys.tr("Bluetooth") + " · " + quickRowRoot.view.sys.btAudioCodec
                          : quickRowRoot.view.sys.tr("No Bluetooth audio")
                    active: quickRowRoot.view.sys.btAudioConnected
                    activeColor: quickRowRoot.view.sys.btAudioMode === "music"
                                 ? quickRowRoot.view.sys.colOn : quickRowRoot.view.sys.colOk
                    onAct: quickRowRoot.view.sys.toggleBtAudio()
                }

                IconBtn {


                    view: quickRowRoot.view
                    glyph: String.fromCodePoint(quickRowRoot.view.sys.srcAudio && quickRowRoot.view.sys.srcAudio.muted ? 0xF036D : 0xF036C)
                    tip: quickRowRoot.view.sys.srcAudio && quickRowRoot.view.sys.srcAudio.muted ? quickRowRoot.view.sys.tr("Microphone off") : quickRowRoot.view.sys.tr("Microphone on")
                    active: quickRowRoot.view.sys.srcAudio !== null
                    activeColor: quickRowRoot.view.sys.srcAudio && quickRowRoot.view.sys.srcAudio.muted ? "#ef4444" : "#22c55e"
                    glyphColor: quickRowRoot.view.sys.srcAudio !== null ? activeColor : quickRowRoot.view.sys.colMuted
                    onAct: {
                        if (quickRowRoot.view.sys.srcAudio)
                            quickRowRoot.view.sys.srcAudio.muted = !quickRowRoot.view.sys.srcAudio.muted;
                    }
                }

                IconBtn {


                    view: quickRowRoot.view
                    glyph: String.fromCodePoint(984101)
                    tip: quickRowRoot.view.sys.tr("Power")
                    activeColor: quickRowRoot.view.sys.colCrit
                    onAct: quickRowRoot.view.sys.togglePage("power")
                }

                IconBtn {


                    view: quickRowRoot.view
                    glyph: String.fromCodePoint(quickRowRoot.view.sys.dnd ? 983195 : 983194)
                    tip: quickRowRoot.view.sys.dnd ? quickRowRoot.view.sys.tr("Do not disturb") : quickRowRoot.view.sys.tr("Notifications")
                    badge: quickRowRoot.view.sys.notifications.count
                    onAct: quickRowRoot.view.sys.togglePage("notif")
                }

                IconBtn {


                    view: quickRowRoot.view
                    glyph: String.fromCodePoint(984211)
                    tip: quickRowRoot.view.sys.tr("Settings")
                    onAct: quickRowRoot.view.sys.togglePage("settings")
                }

            }
