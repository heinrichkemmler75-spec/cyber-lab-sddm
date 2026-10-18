import QtQuick
import "ReferencePose.js" as ReferencePose

Item {
    id: motion
    objectName: "terminalAnimation"
    property bool animationEnabled: false
    property int duration: 2000
    property real progress: 1
    property bool initialized: false
    // Phase boundaries remain at 620 / 1100 / 1340 ms for the 2000 ms default.
    // Start the next joint 50 ms before the preceding phase ends, for a
    // small crossfade of motion rather than three isolated stop-and-go steps.
    // Calculate overlap from milliseconds so it stays 50 ms if duration changes.
    readonly property real overlap: duration > 0
        ? Math.min(50 / duration, 0.025) : 0
    readonly property real swingProgress: ReferencePose.phase(progress, 0, 0.31)
    readonly property real liftProgress: ReferencePose.phase(progress, 0.31 - overlap, 0.55)
    readonly property real unfoldProgress: ReferencePose.phase(progress, 0.55 - overlap, 0.67)
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
