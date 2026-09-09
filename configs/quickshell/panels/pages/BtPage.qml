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
    id: btPageRoot
    property var view


            width: parent.width
            spacing: 7
            opacity: btPageRoot.view.sys.page === "bt" ? 1 : 0
            visible: opacity > 0.01

            Header {


                view: btPageRoot.view
                title: btPageRoot.view.sys.tr("Bluetooth")
                busy: btPageRoot.view.sys.btAdapter ? btPageRoot.view.sys.btAdapter.discovering : false
                onBack: btPageRoot.view.sys.page = "main"
                onRefresh: btPageRoot.view.sys.scanBt()
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: btPageRoot.view.sys.btDevices

                    Row1 {


                        view: btPageRoot.view
                        id: row1

                        required property var modelData
                        property var dev: modelData

                        icon: modelData.icon === "audio-headset" ? "󰋋" : modelData.icon === "input-mouse" ? "󰦋" : modelData.icon === "input-keyboard" ? "󰌌" : modelData.icon === "phone" ? "󰄞" : "󰂯"
                        title: modelData.name || modelData.address
                        sub: modelData.pairing ? btPageRoot.view.sys.tr("Pairing…") : modelData.state === BluetoothDeviceState.Connecting ? btPageRoot.view.sys.tr("Connecting…") : modelData.connected ? btPageRoot.view.sys.tr("Connected") : (modelData.paired || modelData.bonded ? btPageRoot.view.sys.tr("Paired") : btPageRoot.view.sys.tr("Available")) + (modelData.batteryAvailable ? " · " + Math.round(modelData.battery * 100) + "%" : "")
                        highlight: modelData.connected || modelData.pairing || modelData.state === BluetoothDeviceState.Connecting
                        onActivated: {
                            if (modelData.connected) {
                                modelData.disconnect();
                                return ;
                            }
                            modelData.trusted = true;
                            if (modelData.paired || modelData.bonded)
                                modelData.connect();
                            else
                                modelData.pair();
                        }

                        Connections {
                            function onPairedChanged() {
                                if (row1.dev.paired && !row1.dev.connected)
                                    row1.dev.connect();

                            }

                            target: row1.dev
                        }

                    }

                }

            }

            Text {
                Layout.fillWidth: true
                visible: !btPageRoot.view.sys.btDevices || btPageRoot.view.sys.btDevices.values.length === 0
                text: (btPageRoot.view.sys.btAdapter && btPageRoot.view.sys.btAdapter.discovering) ? btPageRoot.view.sys.tr("Scanning devices…") : btPageRoot.view.sys.tr("No devices found")
                color: btPageRoot.view.sys.colMuted
                horizontalAlignment: Text.AlignHCenter

                font {
                    family: btPageRoot.view.sys.fontFam
                    pixelSize: 11
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: btPageRoot.view.sys.animFast
                }

            }

        }
