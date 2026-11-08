import QtQuick

WheelHandler {
    id: motion

    property Flickable area: parent instanceof Flickable ? parent : parent ? parent.parent : null
    property bool motionEnabled: true
    property real step: 84
    property real speed: 2.4
    readonly property real velocityLimit: 4600
    property real velocity: 0
    property double lastInputAt: 0
    readonly property Timer release: Timer {
        interval: 40
        onTriggered: {
            if (motion.enabled && motion.motionEnabled && !motion.area.dragging && Math.abs(motion.velocity) > 40)
                motion.area.flick(0, motion.velocity);
        }
    }

    readonly property Binding deceleration: Binding {
        target: motion.area
        property: "flickDeceleration"
        value: 1000
        when: motion.enabled && motion.motionEnabled
        restoreMode: Binding.RestoreBindingOrValue
    }

    readonly property Binding maximumVelocity: Binding {
        target: motion.area
        property: "maximumFlickVelocity"
        value: motion.velocityLimit
        when: motion.enabled && motion.motionEnabled
        restoreMode: Binding.RestoreBindingOrValue
    }

    readonly property Connections interaction: Connections {
        function onDraggingChanged() {
            if (motion.area.dragging)
                motion.stop();
        }

        function onContentHeightChanged() {
            motion.stop();
        }

        function onHeightChanged() {
            motion.stop();
        }

        target: motion.area
    }

    function stop() {
        release.stop();
        velocity = 0;
        lastInputAt = 0;
        if (area)
            area.cancelFlick();
    }

    function scrollBy(delta) {
        const first = area.originY;
        const last = Math.max(first, first + area.contentHeight - area.height);
        const destination = Math.max(first, Math.min(last, area.contentY - delta));
        if (destination === area.contentY) {
            stop();
            return false;
        }
        const now = Date.now();
        const continuing = lastInputAt > 0 && now - lastInputAt < 120;
        const elapsed = continuing ? Math.max(8, now - lastInputAt) : 32;
        const sample = Math.max(-velocityLimit, Math.min(velocityLimit, delta * 1000 / elapsed));
        velocity = continuing && sample * velocity > 0 ? velocity * 0.55 + sample * 0.45 : sample;
        lastInputAt = now;
        area.cancelFlick();
        area.contentY = destination;
        if (motionEnabled)
            release.restart();
        else
            velocity = 0;
        return true;
    }

    target: null
    enabled: area && area.visible && area.enabled && area.interactive
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    onEnabledChanged: {
        if (!enabled) {
            stop();
        }
    }
    onMotionEnabledChanged: {
        if (!motionEnabled) {
            stop();
        }
    }
    onWheel: (event) => {
        // Wayland can supply pixel deltas for either a mouse or a touchpad.
        const pixels = event.pixelDelta.y;
        const delta = pixels !== 0 ? pixels * speed : event.angleDelta.y / 120 * step;
        if (delta === 0) {
            event.accepted = release.running || area.flicking;
            return;
        }
        event.accepted = scrollBy(delta);
    }
}
