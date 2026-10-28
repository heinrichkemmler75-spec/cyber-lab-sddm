import QtQuick

// Mechanical beam; its local origin stays at the proximal joint (0, 0).
// Changing the sprite never changes the kinematic chain.
Item {
    id: link
    property color accent: "#66ff99"
    property url sprite: ""
    // Render-only overscan: hide the ends of the beam beneath the joint covers.
    // This never changes the length or position of the kinematic link.
    property real startOverlap: 0
    property real endOverlap: 0
    width: 180
    height: 20

    Rectangle {
        visible: link.sprite.toString().length === 0
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 20
        color: "#1c2922"
        border.color: link.accent
        border.width: 1
        radius: 3
    }
    Image {
        visible: link.sprite.toString().length > 0
        source: link.sprite
        asynchronous: false
        smooth: true
        mipmap: true
        x: -link.startOverlap
        y: -34
        width: link.width + link.startOverlap + link.endOverlap
        height: 68
        // Candidate beams already have a particular camera angle.
        // Keep their ends at the joint coordinates; do not scale the chain itself.
        fillMode: Image.Stretch
    }
}
