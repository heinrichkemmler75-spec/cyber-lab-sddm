import QtQuick
import "ReferencePose.js" as ReferencePose

Item {
    id: monitor
    readonly property var pose: ReferencePose.geometry()
    property color accent: "#66ff99"
    // 0..1 progress, provided by the motion controller. LEDs fill up during
    // the mechanical sequence; no blinking or perpetual animation.
    property real animationProgress: 1
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

    // A narrow, legible light bar sits on the BOTTOM BEZEL (outside the LCD).
    // Drawn over the fixed decorative LEDs in the supplied PNG, to ensure
    // visible progress without a flashing effect.
    Row {
        id: ledBar
        objectName: "monitorLedBar"
        z: 3
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
                // One smooth fill from left to right during arm deployment.
                opacity: index < Math.ceil(Math.max(0, Math.min(1, monitor.animationProgress)) * ledBar.count)
                         ? 0.93 : 0.12
                Behavior on opacity { NumberAnimation { duration: 95 } }
            }
        }
    }
}
