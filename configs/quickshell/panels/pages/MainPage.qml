import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Bluetooth
import Quickshell.Services.Notifications

import QtQuick.Controls
import "../../components"
import "../controls"
import "main"

GridLayout {
    id: mainPageRoot
    property var view


            width: parent.width
            columns: 1
            columnSpacing: 0
            rowSpacing: 9
            ClockRow { view: mainPageRoot.view }
            ToggleRow { view: mainPageRoot.view }
            SliderRow { view: mainPageRoot.view }
            MediaRow { view: mainPageRoot.view }
            PowerRow { view: mainPageRoot.view }
            QuickRow { view: mainPageRoot.view }
            TrayRow { view: mainPageRoot.view }
            opacity: (mainPageRoot.view.preview || mainPageRoot.view.sys.page === "main") ? 1 : 0
            visible: opacity > 0.01








            Behavior on opacity {
                NumberAnimation {
                    duration: mainPageRoot.view.sys.animFast
                }

            }

        }
