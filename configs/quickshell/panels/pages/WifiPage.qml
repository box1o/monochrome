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
    id: wifiPageRoot
    property var view


            property string menuSsid: ""
            property bool menuConnected: false
            property bool menuKnown: false
            property string passwordFor: ""

            width: parent.width
            spacing: 7
            opacity: wifiPageRoot.view.sys.page === "wifi" ? 1 : 0
            visible: opacity > 0.01

            Header {


                view: wifiPageRoot.view
                title: wifiPageRoot.view.sys.tr("Wi-Fi networks")
                busy: wifiPageRoot.view.sys.wifiBusy
                onBack: {
                    wifiPageRoot.view.sys.page = "main";
                    passwordFor = "";
                }
                onRefresh: wifiPageRoot.view.sys.scanWifi()
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                visible: wifiPage.passwordFor.length > 0
                radius: 12
                color: Qt.rgba(1, 1, 1, 0.06)
                border.color: wifiPageRoot.view.sys.colLine
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 11
                    anchors.rightMargin: 7
                    spacing: 8

                    Text {
                        text: "󰌾"
                        color: wifiPageRoot.view.sys.colMuted

                        font {
                            family: wifiPageRoot.view.sys.fontFam
                            pixelSize: 14
                        }

                    }

                    TextField {
                        id: pwField

                        Layout.fillWidth: true
                        placeholderText: wifiPageRoot.view.sys.tr("Password for «") + wifiPage.passwordFor + "»"
                        echoMode: TextInput.Password
                        color: wifiPageRoot.view.sys.colFg
                        placeholderTextColor: wifiPageRoot.view.sys.colMuted
                        background: null
                        onAccepted: connectBtn.go()

                        font {
                            family: wifiPageRoot.view.sys.fontFam
                            pixelSize: 12
                        }

                    }

                    Rectangle {
                        id: connectBtn

                        function go() {
                            if (!pwField.text.length)
                                return ;

                            wifiPageRoot.view.sys.connectWifi(wifiPage.passwordFor, pwField.text);
                            wifiPage.passwordFor = "";
                            pwField.text = "";
                            wifiPageRoot.view.sys.holdOpen = false;
                        }

                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 32
                        radius: 10
                        color: pwField.text.length ? wifiPageRoot.view.sys.colOn : Qt.rgba(1, 1, 1, 0.1)

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: "#ffffff"

                            font {
                                family: wifiPageRoot.view.sys.fontFam
                                pixelSize: 13
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: connectBtn.go()
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                    }

                }

            }

            Text {
                Layout.fillWidth: true
                visible: wifiPageRoot.view.sys.wifiError.length > 0
                text: wifiPageRoot.view.sys.wifiError
                color: wifiPageRoot.view.sys.colCrit

                font {
                    family: wifiPageRoot.view.sys.fontFam
                    pixelSize: 11
                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: wifiPageRoot.view.sys.wifiNetworks

                    Row1 {


                        view: wifiPageRoot.view
                        required property var model

                        icon: model.quality > 66 ? "󰤨" : model.quality > 33 ? "󰤥" : "󰤟"
                        title: model.ssid
                        sub: (model.security === "open" ? wifiPageRoot.view.sys.tr("Open") : wifiPageRoot.view.sys.tr("Secured")) + " · " + model.quality + "%" + (model.known ? wifiPageRoot.view.sys.tr(" · saved") : "")
                        highlight: model.connected
                        onActivated: {
                            if (model.connected)
                                return ;

                            if (model.security === "open" || model.known) {
                                wifiPageRoot.view.sys.connectWifi(model.ssid, "");
                            } else {
                                wifiPage.passwordFor = model.ssid;
                                wifiPageRoot.view.sys.holdOpen = true;
                                pwFocus.restart();
                            }
                        }
                        onMenuRequested: (mx, my) => {
                            if (!model.connected && !model.known)
                                return ;

                            wifiPage.menuSsid = model.ssid;
                            wifiPage.menuConnected = model.connected;
                            wifiPage.menuKnown = model.known;
                            wifiPageRoot.view.sys.page = "netmenu";
                        }
                    }

                }

            }

            Text {
                Layout.fillWidth: true
                visible: wifiPageRoot.view.sys.wifiNetworks.count === 0
                text: wifiPageRoot.view.sys.wifiBusy ? wifiPageRoot.view.sys.tr("Scanning networks…") : wifiPageRoot.view.sys.tr("No networks found")
                color: wifiPageRoot.view.sys.colMuted
                horizontalAlignment: Text.AlignHCenter

                font {
                    family: wifiPageRoot.view.sys.fontFam
                    pixelSize: 11
                }

            }

            Timer {
                id: pwFocus

                interval: 80
                onTriggered: pwField.forceActiveFocus()
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: wifiPageRoot.view.sys.animFast
                }

            }

        }
