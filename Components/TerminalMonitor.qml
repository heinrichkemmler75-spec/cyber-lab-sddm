import QtQuick
import "ReferencePose.js" as ReferencePose

Item {
    id: monitor
    readonly property var pose: ReferencePose.geometry()
    property color accent: "#66ff99"
    property real animationProgress: 1
    property real foldAngle: 0
    default property alias content: screen.data
    width: pose.width
    height: pose.height

    // The monitor itself stays at full mechanical size. Rendered side/bottom
    // views replace the front during the third joint motion; no "grow" effect.
    readonly property real openness: Math.max(0, Math.min(1, 1 - Math.abs(foldAngle) / 65))
    readonly property real poseIndex: openness * 6
    readonly property int lowPose: Math.min(6, Math.floor(poseIndex))
    readonly property int highPose: Math.min(6, lowPose + 1)
    readonly property real poseBlend: poseIndex - lowPose
    readonly property var poseImages: [
        "../Assets/terminal/poses/monitor_00deg.png",
        "../Assets/terminal/poses/monitor_15deg.png",
        "../Assets/terminal/poses/monitor_30deg.png",
        "../Assets/terminal/poses/monitor_45deg.png",
        "../Assets/terminal/poses/monitor_60deg.png",
        "../Assets/terminal/poses/monitor_75deg.png",
        "../Assets/terminal/poses/monitor_90deg.png"
    ]

    // Underlying screen remains black and retains keyboard focus throughout.
    Rectangle {
        id: screen
        x: monitor.pose.screenX
        y: monitor.pose.screenY
        width: monitor.pose.screenWidth
        height: monitor.pose.screenHeight
        color: "#000000"
        clip: true
        // Only reveal the usable LCD when it is almost face-on.
        opacity: monitor.openness >= 0.92
                 ? Math.min(1, (monitor.openness - 0.92) / 0.08) : 0
        z: 2
    }
    Item {
        id: poses
        anchors.fill: parent
        visible: monitor.openness < 0.999
        z: 1
        Image {
            anchors.fill: parent
            source: monitor.poseImages[monitor.lowPose]
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
        Image {
            anchors.fill: parent
            source: monitor.poseImages[monitor.highPose]
            opacity: monitor.poseBlend
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
    }
    Image {
        id: frame
        z: 3
        anchors.fill: parent
        source: "../Assets/terminal/monitor_frame.png"
        opacity: monitor.openness >= 0.92
                 ? Math.min(1, (monitor.openness - 0.92) / 0.08) : 0
        fillMode: Image.Stretch
        smooth: true
        mipmap: true
    }
    Row {
        id: ledBar
        objectName: "monitorLedBar"
        z: 4
        visible: monitor.openness >= 0.99
        x: monitor.width * 0.405
        y: monitor.height * 0.951
        width: monitor.width * 0.17
        height: Math.max(2, monitor.height * 0.019)
        spacing: 1
        readonly property int count: 12
        Repeater {
            model: ledBar.count
            Rectangle {
                required property int index
                width: (ledBar.width - (ledBar.count - 1) * ledBar.spacing) / ledBar.count
                height: ledBar.height
                radius: Math.min(width, height) * 0.25
                color: monitor.accent
                opacity: index < Math.ceil(Math.max(0, Math.min(1, monitor.animationProgress)) * ledBar.count) ? 0.93 : 0.12
                Behavior on opacity { NumberAnimation { duration: 95 } }
            }
        }
    }
}
