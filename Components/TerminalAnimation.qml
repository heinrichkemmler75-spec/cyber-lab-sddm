import QtQuick
import "ReferencePose.js" as ReferencePose

Item {
    id: motion
    objectName: "terminalAnimation"
    property bool animationEnabled: false
    property int duration: 3000
    property real progress: 1
    property bool initialized: false
    // For 3000 ms: base 0-930, lift 880-1770, monitor unfolds 1720-2700,
    // then settles by 3000 ms. 50 ms overlaps remain between main joints.
    // Start the next joint 50 ms before the preceding phase ends, for a
    // small crossfade of motion rather than three isolated stop-and-go steps.
    // Calculate overlap from milliseconds so it stays 50 ms if duration changes.
    readonly property real overlap: duration > 0
        ? Math.min(50 / duration, 0.10) : 0
    readonly property real swingProgress: ReferencePose.phase(progress, 0, 0.31)
    readonly property real liftProgress: ReferencePose.phase(progress, 0.31 - overlap, 0.59)
    readonly property real unfoldProgress: ReferencePose.phase(progress, 0.59 - overlap, 0.90)
    // Positive Z rotation is clockwise in Qt's screen coordinates.
    readonly property real baseAngle: -145 * (1 - swingProgress)
    readonly property real liftAngle: 65 * (1 - liftProgress)
    // Decreasing Y rotation supplies the counter-clockwise X-Z unfolding cue.
    readonly property real foldAngle: 65 * (1 - unfoldProgress) - ReferencePose.latch(progress)
    readonly property real faceHeightScale: 0.14 + 0.86 * unfoldProgress
    readonly property bool running: timeline.running
    signal ready()

    function restart() {
        timeline.stop();
        if (animationEnabled && duration > 0) {
            progress = 0;
            timeline.start();
        } else {
            progress = 1;
            ready();
        }
    }
    onAnimationEnabledChanged: if (initialized) restart()
    onDurationChanged: if (initialized) restart()
    NumberAnimation {
        id: timeline
        target: motion
        property: "progress"
        from: 0
        to: 1
        duration: Math.max(0, motion.duration)
        easing.type: Easing.Linear
        onFinished: motion.ready()
    }
    Component.onCompleted: {
        initialized = true;
        restart();
    }
}
