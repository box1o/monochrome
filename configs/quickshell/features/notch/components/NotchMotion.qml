import QtQuick
import "../models"

NotchGeometry {
    id: motion

    required property QtObject tokens
    property bool expanded: false

    progress: expanded ? 1 : 0

    Behavior on expandedHeight {
        // Opening already interpolates height through progress.
        enabled: motion.expanded && motion.progress === 1
        NumberAnimation {
            duration: motion.tokens.motionEnabled ? motion.tokens.normalDuration : 0
            easing.type: Easing.OutCubic
        }
    }

    Behavior on compactWidth {
        NumberAnimation {
            duration: motion.tokens.motionEnabled ? motion.tokens.duration(230) : 0
            easing.type: Easing.OutBack
            easing.overshoot: 1.343
        }
    }

    Behavior on progress {
        NumberAnimation {
            duration: motion.tokens.motionEnabled ? motion.tokens.normalDuration : 0
            easing.type: Easing.BezierSpline
            easing.bezierCurve: motion.tokens.curve
        }
    }
}
