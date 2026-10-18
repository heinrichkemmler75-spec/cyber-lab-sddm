import QtQuick
import QtQuick.Layouts

RowLayout {
    id: actions
    required property var backend
    property color accent: "#66ff99"
    spacing: 8
    signal focusRequested(var control)
    GreenButton {
        objectName: "rebootButton"
        Layout.fillWidth: true
        text: "Neustart"
        accent: actions.accent
        enabled: actions.backend.canReboot
        onClicked: actions.backend.reboot()
        onActiveFocusChanged: if (activeFocus) actions.focusRequested(this)
    }
    GreenButton {
        objectName: "powerOffButton"
        Layout.fillWidth: true
        text: "Herunterfahren"
        accent: actions.accent
        enabled: actions.backend.canPowerOff
        onClicked: actions.backend.powerOff()
        onActiveFocusChanged: if (activeFocus) actions.focusRequested(this)
    }
}
