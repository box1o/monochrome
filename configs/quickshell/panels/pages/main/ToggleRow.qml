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
    id: toggleRowRoot
    property var view

                objectName: "cc-toggles"
                Layout.row: toggleRowRoot.view.ccRow("toggles")
                Layout.column: 0
                Layout.fillWidth: true
                spacing: 8

                MiniTile {


                    view: toggleRowRoot.view
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 56
                    iconItem: null
                    icon: toggleRowRoot.view.sys.wifiOn ? (toggleRowRoot.view.sys.wifiQuality > 66 ? "󰤨" : toggleRowRoot.view.sys.wifiQuality > 33 ? "󰤥" : "󰤟") : "󰤮"
                    label: toggleRowRoot.view.sys.wiredOn ? toggleRowRoot.view.sys.tr("Wired") : (toggleRowRoot.view.sys.wifiOn && toggleRowRoot.view.sys.wifiSsid.length) ? toggleRowRoot.view.sys.wifiSsid : "Wi-Fi"
                    sub: toggleRowRoot.view.sys.wiredOn ? toggleRowRoot.view.sys.wiredName : !toggleRowRoot.view.sys.wifiOn ? toggleRowRoot.view.sys.tr("Off") : (toggleRowRoot.view.sys.wifiSsid.length ? toggleRowRoot.view.sys.wifiQuality + "%" : toggleRowRoot.view.sys.tr("Not connected"))
                    on: toggleRowRoot.view.sys.wiredOn || toggleRowRoot.view.sys.wifiOn
                    onIconClicked: {
                        if (!toggleRowRoot.view.sys.wiredOn)
                            toggleRowRoot.view.sys.toggleWifi();

                    }
                    onBodyClicked: {
                        if (!toggleRowRoot.view.sys.wifiOn)
                            return ;

                        toggleRowRoot.view.sys.openSub("wifi");
                        toggleRowRoot.view.sys.refreshWifiList();
                        toggleRowRoot.view.sys.scanWifi();
                    }
                }

                MiniTile {


                    view: toggleRowRoot.view
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 56
                    icon: toggleRowRoot.view.sys.btOn ? "󰂯" : "󰂲"
                    label: (toggleRowRoot.view.sys.btOn && toggleRowRoot.view.sys.btConnectedName.length) ? toggleRowRoot.view.sys.btConnectedName : "Bluetooth"
                    sub: !toggleRowRoot.view.sys.btOn ? toggleRowRoot.view.sys.tr("Off") : (toggleRowRoot.view.sys.btConnectedName.length ? (toggleRowRoot.view.sys.btConnectedBattery >= 0 ? "󰥉 " + toggleRowRoot.view.sys.btConnectedBattery + "%" : toggleRowRoot.view.sys.tr("Connected")) : toggleRowRoot.view.sys.tr("No devices"))
                    on: toggleRowRoot.view.sys.btOn
                    accent: toggleRowRoot.view.sys.colOn
                    onIconClicked: toggleRowRoot.view.sys.toggleBt()
                    onBodyClicked: {
                        if (!toggleRowRoot.view.sys.btOn)
                            return ;

                        toggleRowRoot.view.sys.openSub("bt");
                        toggleRowRoot.view.sys.scanBt();
                    }
                }

                VolCard {


                    view: toggleRowRoot.view
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 56
                }

            }
