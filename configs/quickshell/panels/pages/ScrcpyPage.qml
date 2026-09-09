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
    id: scrcpyPageRoot
    property var view


            width: parent.width
            spacing: 7
            opacity: scrcpyPageRoot.view.sys.page === "scrcpy" ? 1 : 0
            visible: opacity > 0.01

            Header {


                view: scrcpyPageRoot.view
                title: scrcpyPageRoot.view.sys.tr("Scrcpy devices")
                busy: scrcpyPageRoot.view.sys.adbBusy
                onBack: scrcpyPageRoot.view.sys.page = "main"
                onRefresh: scrcpyPageRoot.view.sys.refreshAdbDevices()
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: scrcpyPageRoot.view.sys.adbDevices

                    Row1 {


                        view: scrcpyPageRoot.view
                        required property var modelData
                        icon: "󰄜"
                        title: modelData.label
                        sub: scrcpyPageRoot.view.sys.tr("Open with scrcpy")
                        onActivated: {
                            scrcpyPageRoot.view.sys.launchScrcpy(modelData.serial);
                            scrcpyPageRoot.view.sys.page = "main";
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: scrcpyPageRoot.view.sys.adbDevices.length === 0
                text: scrcpyPageRoot.view.sys.adbError.length ? scrcpyPageRoot.view.sys.adbError : scrcpyPageRoot.view.sys.tr("No ADB devices found")
                color: scrcpyPageRoot.view.sys.colMuted
                horizontalAlignment: Text.AlignHCenter
                font { family: scrcpyPageRoot.view.sys.fontFam; pixelSize: 11 }
            }

            Behavior on opacity {
                NumberAnimation { duration: scrcpyPageRoot.view.sys.animFast }
            }
        }
