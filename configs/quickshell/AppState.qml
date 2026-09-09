import QtQuick
import "services"

QtObject {
    property bool expanded: false
    property string page: "main"
    property bool holdOpen: false
    property string freezeShot: ""

    readonly property AudioService audio: AudioService {}
    readonly property BatteryService battery: BatteryService {}
    readonly property MediaService media: MediaService {}
    property var config
    readonly property ClockService clock: ClockService { config: appState.config }
    readonly property WorkspaceService workspace: WorkspaceService {}
    readonly property NetworkService network: NetworkService {}
    // NotificationServer is still owned by shell.qml until its loader is migrated.
    readonly property var notifications: null
}
