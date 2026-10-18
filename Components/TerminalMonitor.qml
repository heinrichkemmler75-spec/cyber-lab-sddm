import QtQuick
import "ReferencePose.js" as ReferencePose

Item {
    id: monitor
    readonly property var pose: ReferencePose.geometry()
    property color accent: "#66ff99"
    default property alias content: screen.data
    width: pose.width
    height: pose.height

    // Solid LCD background; SDDM fields are normal interactive QML, not baked
    // into the artwork. All positions derive from the calibrated reference pose.
    Rectangle {
        id: screen
        x: monitor.pose.screenX
        y: monitor.pose.screenY
        width: monitor.pose.screenWidth
        height: monitor.pose.screenHeight
        color: "#000000"
        clip: true
    }
    Image {
        id: frame
        z: 2
        anchors.fill: parent
        source: "../Assets/terminal/monitor_frame.png"
        fillMode: Image.Stretch
        smooth: true
        mipmap: true
        // Frame image has transparent center and does not cover input controls.
    }
}
