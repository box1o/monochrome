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
    id: powerRow
    property var view


                readonly property int tileH: 76

                objectName: "cc-power"
                Layout.row: powerRow.view.ccRow("power")
                Layout.column: 0
                Layout.fillWidth: true
                spacing: 8

                MiniTile {


                    view: powerRow.view
                    visible: powerRow.view.sys.showBattery || powerRow.view.sys.showPowerProfiles
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: powerRow.tileH
                    icon: powerRow.view.sys.batteryPresent ? powerRow.view.sys.batteryLevelIcon : String.fromCodePoint(983617)
                    label: powerRow.view.sys.batteryPresent ? powerRow.view.sys.batteryPct + "%" : powerRow.view.sys.tr("Battery")
                    sub: powerRow.view.sys.batteryCharging ? powerRow.view.sys.tr("Charging") : powerRow.view.sys.acOnline ? powerRow.view.sys.tr("On AC") : powerRow.view.sys.profileLabel
                    on: powerRow.view.sys.batteryCharging || powerRow.view.sys.acOnline
                    wave: powerRow.view.sys.batteryCharging
                    waveLevel: powerRow.view.sys.batteryPct / 100
                    accent: powerRow.view.sys.batteryPct <= 15 && !powerRow.view.sys.acOnline ? powerRow.view.sys.colCrit : powerRow.view.sys.colOk
                    onIconClicked: powerRow.view.sys.openSub("battery")
                    onBodyClicked: powerRow.view.sys.openSub("battery")
                }

                PomodoroCard {
                    view: powerRow.view
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1.25
                    Layout.preferredHeight: powerRow.tileH
                }

                LoadCard {


                    view: powerRow.view
                    visible: !powerRow.view.sys.batteryPresent
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1.35
                    Layout.preferredHeight: powerRow.tileH
                }

            }
