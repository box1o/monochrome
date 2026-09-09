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
    id: sliderRowRoot
    property var view

                objectName: "cc-sliders"
                Layout.row: sliderRowRoot.view.ccRow("sliders")
                Layout.column: 0
                Layout.fillWidth: true
                spacing: 8
                visible: (sliderRowRoot.view.sys.brightList || []).length > 0

                Repeater {
                    model: sliderRowRoot.view.sys.brightList

                    BrightCard {


                        view: sliderRowRoot.view
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 56
                        bid: modelData.id
                        bpct: modelData.pct
                        bname: (sliderRowRoot.view.sys.brightList || []).length > 1 ? modelData.name : ""
                    }

                }

            }
