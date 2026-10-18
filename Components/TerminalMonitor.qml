import QtQuick

Rectangle {
    id: monitor
    property color accent: "#66ff99"
    default property alias content: screen.data
    color: "#151b18"
    border.color: accent
    border.width: 2
    radius: 4

    Rectangle {
        id: screen
        anchors.fill: parent
        anchors.margins: 12
        color: "#000000"
    }
}
