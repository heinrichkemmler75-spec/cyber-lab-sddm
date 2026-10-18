import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

FocusScope {
    id: panel
    objectName: "loginPanel"
    required property var backend
    required property var users
    required property var sessions
    property color accent: "#66ff99"
    property bool showAvatar: true
    property bool busy: false
    property string errorMessage: ""
    readonly property string selectedUser: userChoice.currentValue || ""
    readonly property int selectedSession: sessionChoice.currentIndex
    readonly property bool canLogin: selectedUser.length > 0 && selectedSession >= 0 && !busy

    function focusPassword() {
        password.forceActiveFocus();
    }
    function submit() {
        if (!canLogin)
            return;
        errorMessage = "";
        busy = true;
        backend.login(selectedUser, password.text, selectedSession);
        password.clear();
    }

    Connections {
        target: panel.backend
        function onLoginFailed() {
            panel.busy = false;
            panel.errorMessage = "Anmeldung fehlgeschlagen. Bitte Zugangsdaten prüfen.";
            password.clear();
            panel.focusPassword();
        }
        function onLoginSucceeded() {
            password.clear();
        }
    }

    Flickable {
        id: scroll
        objectName: "formScroll"
        anchors.fill: parent
        anchors.margins: 5
        contentWidth: width
        contentHeight: form.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {}

        function reveal(item) {
            const pos = item.mapToItem(form, 0, 0);
            if (pos.y < contentY)
                contentY = pos.y;
            else if (pos.y + item.height > contentY + height)
                contentY = Math.min(contentHeight - height, pos.y + item.height - height);
        }

        ColumnLayout {
            id: form
            width: scroll.width
            spacing: 3
            Text {
                text: "CYBER LAB / ZUGANG"
                color: panel.accent
                font.pixelSize: 11
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                UserProfile {
                    objectName: "userProfile"
                    Layout.preferredWidth: 45
                    Layout.preferredHeight: 45
                    visible: panel.showAvatar
                    showName: false
                    users: panel.users
                    selectedIndex: userChoice.currentIndex
                    userName: panel.selectedUser
                    accent: panel.accent
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    GreenComboBox {
                        id: userChoice
                        objectName: "userChoice"
                        Layout.fillWidth: true
                        accent: panel.accent
                        model: panel.users
                        enabled: !panel.busy && count > 0
                        Accessible.name: "Benutzer"
                        onActiveFocusChanged: if (activeFocus)
                            scroll.reveal(this)
                        onActivated: {
                            password.clear();
                            panel.errorMessage = "";
                            panel.focusPassword();
                        }
                        Component.onCompleted: {
                            const last = panel.users ? panel.users.lastIndex : -1;
                            currentIndex = count > 0 ? Math.max(0, Math.min(last, count - 1)) : -1;
                        }
                    }
                    TextField {
                        id: password
                        objectName: "passwordField"
                        Layout.fillWidth: true
                        implicitHeight: 25
                        color: panel.accent
                        font.pixelSize: 13
                        placeholderText: "Passwort"
                        placeholderTextColor: panel.accent
                        echoMode: TextInput.Password
                        passwordMaskDelay: 0
                        enabled: !panel.busy
                        focus: true
                        selectByMouse: true
                        selectionColor: "#184a2c"
                        selectedTextColor: panel.accent
                        Accessible.name: "Passwort"
                        inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                        onAccepted: panel.submit()
                        onActiveFocusChanged: if (activeFocus)
                            scroll.reveal(this)
                        background: Rectangle {
                            color: "#000000"
                            border.color: panel.accent
                            border.width: password.activeFocus ? 3 : 1
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Sitzung"
                    color: panel.accent
                    font.pixelSize: 12
                }
                SessionSelector {
                    id: sessionChoice
                    objectName: "sessionChoice"
                    Layout.fillWidth: true
                    sessions: panel.sessions
                    accent: panel.accent
                    enabled: !panel.busy && count > 0
                    onActiveFocusChanged: if (activeFocus)
                        scroll.reveal(this)
                }
            }
            GreenButton {
                objectName: "loginButton"
                Layout.fillWidth: true
                accent: panel.accent
                text: panel.busy ? "Anmeldung läuft …" : "Anmelden"
                enabled: panel.canLogin
                onClicked: panel.submit()
                onActiveFocusChanged: if (activeFocus)
                    scroll.reveal(this)
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    objectName: "statusMessage"
                    Layout.fillWidth: true
                    Layout.minimumHeight: 20
                    text: panel.errorMessage || (userChoice.count === 0 ? "Keine Benutzer verfügbar." : sessionChoice.count === 0 ? "Keine Desktop-Sitzungen verfügbar." : "")
                    color: panel.errorMessage ? "#ffb3a7" : panel.accent
                    wrapMode: Text.WordWrap
                    font.pixelSize: 10
                    Accessible.role: Accessible.StaticText
                    Accessible.name: text
                }
                SystemActions {
                    backend: panel.backend
                    accent: panel.accent
                    enabled: !panel.busy
                    onFocusRequested: control => scroll.reveal(control)
                }
            }
        }
    }
    Component.onCompleted: Qt.callLater(focusPassword)
}
