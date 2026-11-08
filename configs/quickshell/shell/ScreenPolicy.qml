import QtQml
import "ScreenSelection.js" as Selection

QtObject {
    property var screens: []
    readonly property var selected: Selection.topmost(screens)
}
