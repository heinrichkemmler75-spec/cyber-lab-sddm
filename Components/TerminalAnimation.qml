import QtQuick
import "ReferencePose.js" as ReferencePose

Item {
    id: motion
    objectName: "terminalAnimation"
    property bool animationEnabled: false
    property int duration: 800
    property real progress: 1
    property bool initialized: false
    readonly property var endPose: ReferencePose.geometry()
    readonly property real shoulderAngle: endPose.shoulderAngle + ReferencePose.track(progress, [120, 5, -0.5, 0])
    readonly property real elbowAngle: endPose.elbowAngle + ReferencePose.track(progress, [60, 25, -1, 0])
    readonly property real wristAngle: endPose.wristAngle + ReferencePose.track(progress, [-90, -45, 2, 0])
    readonly property real yaw: ReferencePose.track(progress, [70, 45, 12, 0])
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
