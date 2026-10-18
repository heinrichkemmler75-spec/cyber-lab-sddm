import QtQuick

// Joint pivot is the CENTER of this item, at parent coordinates (0, 0).
Item {
    id: joint
    property color accent: "#66ff99"
    property url sprite: ""
    property bool motorActive: false
    property bool showLeds: true
    width: 76
    height: 76
    x: -width / 2
    y: -height / 2

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#0a100d"
        border.color: joint.accent
        border.width: 2
        visible: joint.sprite.toString().length === 0
        Rectangle {
            anchors.centerIn: parent
            width: 10; height: 10; radius: 5
            color: joint.accent
        }
    }
    Image {
        anchors.fill: parent
        source: joint.sprite
        visible: joint.sprite.toString().length > 0
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
    }
    Image {
        id: ledRing
        anchors.centerIn: parent
        width: parent.width * 0.56
        height: width
        source: "../Assets/leds/ring_segment_overlay.png"
        visible: joint.showLeds
        smooth: true
        opacity: joint.motorActive ? 0.86 : 0.36
        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 900
            loops: Animation.Infinite
            running: joint.motorActive
        }
        Behavior on opacity { NumberAnimation { duration: 160 } }
    }
}
