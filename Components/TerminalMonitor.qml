import QtQuick
import "ReferencePose.js" as ReferencePose

Rectangle {
    id: monitor
    readonly property var pose: ReferencePose.geometry()
    property color accent: "#66ff99"
    default property alias content: screen.data
    width: pose.width
    height: pose.height
    color: "#151b18"
    border.color: accent
    border.width: 2
    radius: 4
    Rectangle {
        id: screen
        x: monitor.width * monitor.pose.screenX / monitor.pose.width
        y: monitor.height * monitor.pose.screenY / monitor.pose.height
        width: monitor.width * monitor.pose.screenWidth / monitor.pose.width
        height: monitor.height * monitor.pose.screenHeight / monitor.pose.height
        color: "#000000"
    }
}
