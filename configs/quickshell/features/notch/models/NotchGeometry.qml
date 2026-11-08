import QtQml

QtObject {
    required property QtObject style
    property real availableWidth: style.expandedWidth + 2 * style.shoulder
    property real availableHeight: style.expandedHeight
    property real progress: 0
    property real contentWidth: 0
    property real contentHeight: 0
    readonly property real widthLimit: Math.max(0, availableWidth - 2 * style.shoulder)
    readonly property real expandedWidth: Math.min(style.expandedWidth, widthLimit)
    readonly property real expandedHeight: Math.min(Math.max(style.expandedHeight, contentHeight), Math.max(0, availableHeight))
    readonly property real compactHeight: Math.min(style.compactHeight, expandedHeight)
    property real compactWidth: Math.min(expandedWidth, Math.max(style.compactWidth, contentWidth))
    // Clamp animated values as well as targets: the width spring can overshoot.
    readonly property real bodyWidth: Math.max(0, Math.min(expandedWidth, compactWidth + (expandedWidth - compactWidth) * progress))
    readonly property real bodyHeight: compactHeight + (expandedHeight - compactHeight) * progress
    readonly property real lowerRadius: Math.min(bodyWidth / 2, bodyHeight / 2, style.compactRadius + (style.expandedRadius - style.compactRadius) * progress)
    readonly property real surfaceWidth: Math.min(availableWidth, expandedWidth + 2 * style.shoulder)
    readonly property real surfaceHeight: expandedHeight
}
