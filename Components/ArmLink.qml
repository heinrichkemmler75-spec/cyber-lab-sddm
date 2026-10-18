import QtQuick

// Mechanical beam; its local origin stays at the proximal joint (0, 0).
// Changing the sprite never changes the kinematic chain.
Item {
    id: link
    property color accent: "#66ff99"
    property url sprite: ""
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
        x: 0
        y: -34
        width: link.width
        height: 68
        // Candidate beams already have a particular camera angle.
        // Keep their ends at the joint coordinates; do not scale the chain itself.
        fillMode: Image.Stretch
    }
}
