pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic

ComboBox {
    id: control
    property color accent: "#66ff99"
    implicitHeight: 26
    font.pixelSize: 12
    textRole: "name"
    valueRole: "name"
    palette.text: accent
    palette.buttonText: accent
    palette.windowText: accent
    palette.base: "#000000"
    palette.button: "#000000"
    palette.window: "#000000"
    palette.highlight: "#184a2c"
    palette.highlightedText: accent
    background: Rectangle {
        color: "#000000"
        border.color: control.enabled ? control.accent : "#718078"
        border.width: control.activeFocus ? 3 : 1
        radius: 2
    }
    indicator: Text {
        x: control.width - width - 12
        anchors.verticalCenter: parent.verticalCenter
        text: "▾"
        color: control.enabled ? control.accent : "#718078"
        font.pixelSize: 18
    }
    delegate: ItemDelegate {
        id: option
        required property int index
        required property string name
        width: control.width
        text: name
        font: control.font
        highlighted: control.highlightedIndex === index
        contentItem: Text {
            text: option.text
            color: control.accent
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle { color: option.highlighted ? "#184a2c" : "#000000" }
    }
    Accessible.name: "Auswahl"
}
