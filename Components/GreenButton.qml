import QtQuick
import QtQuick.Controls.Basic

Button {
    id: control
    property color accent: "#66ff99"
    implicitHeight: 40
    font.pixelSize: 15
    palette.buttonText: accent
    palette.button: "#000000"
    palette.highlight: accent
    contentItem: Text {
        text: control.text
        font: control.font
        color: control.enabled ? control.accent : "#718078"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    background: Rectangle {
        color: control.down ? "#183524" : control.hovered ? "#10251a" : "#000000"
        border.color: control.enabled ? control.accent : "#718078"
        border.width: control.activeFocus ? 3 : 1
        radius: 2
    }
}
