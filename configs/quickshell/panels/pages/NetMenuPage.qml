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
    id: netMenuPageRoot
    property var view


            width: parent.width
            spacing: 3
            opacity: netMenuPageRoot.view.sys.page === "netmenu" ? 1 : 0
            visible: opacity > 0.01

            Header {


                view: netMenuPageRoot.view
                title: wifiPage.menuSsid.length ? wifiPage.menuSsid : netMenuPageRoot.view.sys.tr("Network")
                busy: netMenuPageRoot.view.sys.wifiBusy
                onBack: netMenuPageRoot.view.sys.page = "wifi"
                onRefresh: {
                }
            }

            Row1 {


                view: netMenuPageRoot.view
                visible: wifiPage.menuConnected
                icon: "󰖪"
                title: netMenuPageRoot.view.sys.tr("Disconnect")
                sub: netMenuPageRoot.view.sys.tr("Drops the link, keeps the network saved")
                onActivated: {
                    netMenuPageRoot.view.sys.disconnectWifi();
                    netMenuPageRoot.view.sys.page = "wifi";
                }
            }

            Row1 {


                view: netMenuPageRoot.view
                visible: wifiPage.menuKnown
                icon: "󰅖"
                title: netMenuPageRoot.view.sys.tr("Forget network")
                sub: netMenuPageRoot.view.sys.tr("Stop connecting automatically")
                onActivated: {
                    netMenuPageRoot.view.sys.forgetWifi(wifiPage.menuSsid);
                    netMenuPageRoot.view.sys.page = "wifi";
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: 4
                visible: !wifiPage.menuConnected && !wifiPage.menuKnown
                text: netMenuPageRoot.view.sys.tr("Nothing is saved for this network.")
                color: netMenuPageRoot.view.sys.colMuted
                horizontalAlignment: Text.AlignHCenter

                font {
                    family: netMenuPageRoot.view.sys.fontFam
                    pixelSize: 11
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: netMenuPageRoot.view.sys.animFast
                }

            }

        }
