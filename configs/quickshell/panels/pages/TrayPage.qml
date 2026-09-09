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
    id: trayPageRoot
    property var view


            property var chain: []
            readonly property var rootHandle: trayPageRoot.view.sys.trayMenuItem ? trayPageRoot.view.sys.trayMenuItem.menu : null
            readonly property var handle: chain.length > 0 ? chain[chain.length - 1] : rootHandle

            width: parent.width
            spacing: 3
            opacity: trayPageRoot.view.sys.page === "traymenu" ? 1 : 0
            visible: opacity > 0.01
            onRootHandleChanged: {
                if (chain.length > 0)
                    chain = [];

            }

            QsMenuOpener {
                id: menuOpener

                menu: trayPage.handle
            }

            Header {


                view: trayPageRoot.view
                title: trayPageRoot.view.sys.trayMenuItem ? String(trayPageRoot.view.sys.trayMenuItem.tooltipTitle || trayPageRoot.view.sys.trayMenuItem.title || trayPageRoot.view.sys.tr("Menu")) : trayPageRoot.view.sys.tr("Menu")
                busy: false
                onBack: {
                    if (trayPage.chain.length > 0) {
                        var c = trayPage.chain.slice();
                        c.pop();
                        trayPage.chain = c;
                    } else {
                        trayPageRoot.view.sys.page = "main";
                        trayPageRoot.view.sys.trayMenuItem = null;
                    }
                }
                onRefresh: {
                }
            }

            Repeater {
                model: menuOpener.children

                Item {
                    id: entry

                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: modelData.isSeparator ? 9 : 34

                    Rectangle {
                        visible: entry.modelData.isSeparator
                        height: 1
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        color: trayPageRoot.view.sys.colLine
                    }

                    Rectangle {
                        visible: !entry.modelData.isSeparator
                        anchors.fill: parent
                        radius: 10
                        color: entryMa.containsMouse && entry.modelData.enabled ? trayPageRoot.view.sys.colHover : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 11
                            anchors.rightMargin: 11
                            spacing: 9

                            Text {
                                visible: entry.modelData.buttonType !== QsMenuButtonType.None
                                text: entry.modelData.checkState === Qt.Checked ? "󰄬" : "󰝦"
                                color: entry.modelData.checkState === Qt.Checked ? trayPageRoot.view.sys.colOn : trayPageRoot.view.sys.colMuted

                                font {
                                    family: trayPageRoot.view.sys.fontFam
                                    pixelSize: 12
                                }

                            }

                            Image {
                                visible: String(entry.modelData.icon || "").length > 0
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                source: String(entry.modelData.icon || "")
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            Text {
                                Layout.fillWidth: true
                                text: String(entry.modelData.text || "")
                                color: entry.modelData.enabled ? trayPageRoot.view.sys.colFg : trayPageRoot.view.sys.colMuted
                                elide: Text.ElideRight

                                font {
                                    family: trayPageRoot.view.sys.fontFam
                                    pixelSize: 12
                                }

                            }

                            Text {
                                visible: entry.modelData.hasChildren
                                text: ""
                                color: trayPageRoot.view.sys.colMuted

                                font {
                                    family: trayPageRoot.view.sys.fontFam
                                    pixelSize: 11
                                }

                            }

                        }

                        MouseArea {
                            id: entryMa

                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: entry.modelData.enabled
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (entry.modelData.hasChildren) {
                                    var c = trayPage.chain.slice();
                                    c.push(entry.modelData);
                                    trayPage.chain = c;
                                    return ;
                                }
                                entry.modelData.triggered();
                                trayPageRoot.view.sys.collapse();
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }

                        }

                    }

                }

            }

            Text {
                Layout.fillWidth: true
                visible: !menuOpener.children || menuOpener.children.values.length === 0
                text: trayPageRoot.view.sys.tr("Menu is empty")
                color: trayPageRoot.view.sys.colMuted
                horizontalAlignment: Text.AlignHCenter

                font {
                    family: trayPageRoot.view.sys.fontFam
                    pixelSize: 11
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: trayPageRoot.view.sys.animFast
                }

            }

        }
