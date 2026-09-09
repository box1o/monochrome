import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components"

Item {
    id: num
    property var view


        property string value: ""
        property real size: 12
        property real gapRatio: 0.22
        property color color: num.view.sys.colFg

        implicitWidth: nDots.implicitWidth
        implicitHeight: nDots.implicitHeight

        DotText {
            id: nDots

            visible: num.view.sys.themeNothing
            value: num.value
            size: num.size
            gapRatio: num.gapRatio
            color: num.color
        }

        Text {
            id: nPlain

            visible: !num.view.sys.themeNothing
            text: num.value
            color: num.color

            font {
                family: num.view.sys.fontFam
                pixelSize: Math.round(num.size * 1.35)
            }

        }

    }
