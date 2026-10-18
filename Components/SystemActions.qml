import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

RowLayout {
    id: actions
    required property var backend
    property color accent: "#66ff99"
    spacing: 5
    signal focusRequested(var control)

    Item { Layout.fillWidth: true }

    Button {
        objectName: "rebootButton"
        Layout.preferredWidth: 30
        Layout.preferredHeight: 27
        enabled: actions.backend.canReboot
        Accessible.name: "Neustart"
        ToolTip.visible: hovered
        ToolTip.text: "Neustart"
        onClicked: actions.backend.reboot()
        onActiveFocusChanged: if (activeFocus) actions.focusRequested(this)
        contentItem: Text {
            text: "⟳"
            color: parent.enabled ? actions.accent : "#718078"
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.hovered ? "#173d2a" : "#040e09"
            border.color: actions.accent
            border.width: parent.activeFocus ? 2 : 1
        }
    }
    Button {
        objectName: "powerOffButton"
        Layout.preferredWidth: 30
        Layout.preferredHeight: 27
        enabled: actions.backend.canPowerOff
        Accessible.name: "Herunterfahren"
        ToolTip.visible: hovered
        ToolTip.text: "Herunterfahren"
        onClicked: actions.backend.powerOff()
        onActiveFocusChanged: if (activeFocus) actions.focusRequested(this)
        contentItem: Text {
            text: "⏻"
            color: parent.enabled ? actions.accent : "#718078"
            font.pixelSize: 21
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.hovered ? "#173d2a" : "#040e09"
            border.color: actions.accent
            border.width: parent.activeFocus ? 2 : 1
        }
    }
}
