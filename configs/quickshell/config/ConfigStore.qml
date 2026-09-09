import Quickshell.Io

FileView {
    property string configPath: ""

    path: configPath
    watchChanges: true
    adapter: ConfigAdapter {}
}
