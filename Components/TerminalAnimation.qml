import QtQuick
import "ReferencePose.js" as ReferencePose

Item {
    id: motion
    objectName: "terminalAnimation"
    property bool animationEnabled: false
    property int duration: 2000
    property real progress: 1
    property bool initialized: false
    // 0–620 / 620–1100 / 1100–1340 / 1340–2000 ms at the default duration.
    readonly property real swingProgress: ReferencePose.phase(progress, 0, 0.31)
    readonly property real liftProgress: ReferencePose.phase(progress, 0.31, 0.55)
    readonly property real unfoldProgress: ReferencePose.phase(progress, 0.55, 0.67)
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
