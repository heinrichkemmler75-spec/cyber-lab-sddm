import QtQuick

Rectangle {
    property color accent: "#66ff99"
    width: 36
    height: width
    x: -width / 2
    y: -height / 2
    radius: width / 2
    color: "#0a100d"
    border.color: accent
    border.width: 2
    Rectangle {
        anchors.centerIn: parent
        width: 10; height: 10; radius: 5
        color: parent.accent
    }
}
