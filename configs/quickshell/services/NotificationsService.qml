import Quickshell
import Quickshell.Services.Notifications

NotificationServer {
    id: server

    readonly property var entries: trackedNotifications.values.slice().reverse()
    readonly property int count: entries.length
    property double lastSoundAt: 0

    signal soundRequested()
    signal screenshotSaved()

    function clear() {
        for (const notification of trackedNotifications.values.slice()) notification.dismiss()
    }

    function iconFor(notification) {
        const image = notification.image || notification.appIcon;
        if (!image)
            return "";

        if (image.includes("/") || image.includes(":"))
            return image;

        return Quickshell.hasThemeIcon(image) ? Quickshell.iconPath(image) : "";
    }

    function activate(notification) {
        const actions = Array.from(notification.actions);
        const action = actions.find(item => item.identifier === "default") || (actions.length === 1 ? actions[0] : null);
        if (!action)
            return false;

        const id = notification.id;
        const resident = notification.resident;
        action.invoke();
        const current = trackedNotifications.values.find(item => item.id === id);
        if (current && !resident)
            current.dismiss();

        return true;
    }

    keepOnReload: true
    bodySupported: true
    bodyMarkupSupported: false
    imageSupported: true
    actionsSupported: true
    onNotification: (notification) => {
        notification.tracked = true;
        const now = Date.now();
        if (!notification.lastGeneration && !notification.hints["suppress-sound"] && now - lastSoundAt > 500) {
            lastSoundAt = now;
            soundRequested();
        }
        if (!notification.lastGeneration && notification.appName === "Mono" && notification.summary === "Screenshot copied")
            screenshotSaved();

        const entries = trackedNotifications.values;
        if (entries.length > 50)
            entries[0].dismiss();
    }
}
