import QtQml
import Quickshell
import "../../../components/controls"

SelectableMenuItem {
    required property var application

    title: application.name
    subtitle: application.genericName || application.comment
    iconSource: Quickshell.hasThemeIcon(application.icon) ? Quickshell.iconPath(application.icon) : ""
}
