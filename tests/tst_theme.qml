import QtQuick
import QtTest
import ".."

Item {
    width: 1920
    height: 1080
    property var config: ({GreenColor: "#66ff99", ShowUserPicture: "true", AnimationEnabled: "false", AnimationDuration: "800"})
    QtObject {
        id: sddm
        property bool canReboot: true
        property bool canPowerOff: true
        property int loginCalls: 0
        property string loginUser: ""
        property string loginPassword: ""
        property int loginSession: -1
        property int reboots: 0
        property int shutdowns: 0
        signal loginFailed()
        signal loginSucceeded()
        function login(user, password, session) {
            loginCalls++;
            loginUser = user;
            loginPassword = password;
            loginSession = session;
        }
        function reboot() { reboots++; }
        function powerOff() { shutdowns++; }
    }
    ListModel {
        id: userModel
        property int lastIndex: 1
        ListElement { name: "alice"; icon: "" }
        ListElement { name: "bob"; icon: "" }
    }
    ListModel {
        id: sessionModel
        property int lastIndex: 1
        ListElement { name: "Plasma (Wayland)" }
        ListElement { name: "Plasma (X11)" }
    }
    Component { id: scene; Main { } }
    TestCase {
        id: test
        name: "CyberLab"
        when: windowShown
        property var theme
        property var panel
        property var password
        function init() {
            test.parent.config = {GreenColor: "#66ff99", ShowUserPicture: "true", AnimationEnabled: "false", AnimationDuration: "800"};
            sddm.canReboot = true;
            sddm.canPowerOff = true;
            sddm.loginCalls = 0;
            sddm.reboots = 0;
            sddm.shutdowns = 0;
            theme = createTemporaryObject(scene, test.parent, {width: 1280, height: 720});
            verify(theme);
            panel = findChild(theme, "loginPanel");
            password = findChild(theme, "passwordField");
            wait(50);
        }
        function test_loginAndFailure() {
            compare(panel.selectedUser, "bob");
            compare(panel.selectedSession, 1);
            verify(password.activeFocus);
            compare(password.echoMode, TextInput.Password);
            password.text = "dummy-secret";
            keyClick(Qt.Key_Return);
            compare(sddm.loginCalls, 1);
            compare(sddm.loginUser, "bob");
            compare(sddm.loginPassword, "dummy-secret");
            compare(sddm.loginSession, 1);
            verify(panel.busy);
            compare(password.text, "");
            panel.submit();
            compare(sddm.loginCalls, 1);
            sddm.loginFailed();
            verify(!panel.busy);
            verify(panel.errorMessage.length > 0);
            verify(password.activeFocus);
            password.text = "second-dummy";
            mouseClick(findChild(theme, "loginButton"));
            compare(sddm.loginCalls, 2);
            sddm.loginSucceeded();
            compare(password.text, "");
        }
        function test_userAndSessionSelection() {
            const users = findChild(theme, "userChoice");
            users.forceActiveFocus();
            keyClick(Qt.Key_Home);
            compare(users.currentIndex, 0);
            compare(panel.selectedUser, "alice");
            const sessions = findChild(theme, "sessionChoice");
            sessions.forceActiveFocus();
            keyClick(Qt.Key_Home);
            compare(panel.selectedSession, 0);
            password.text = "dummy";
            panel.submit();
            compare(sddm.loginUser, "alice");
            compare(sddm.loginSession, 0);
        }
        function test_powerCapabilities() {
            mouseClick(findChild(theme, "rebootButton"));
            mouseClick(findChild(theme, "powerOffButton"));
            compare(sddm.reboots, 1);
            compare(sddm.shutdowns, 1);
            sddm.canReboot = false;
            sddm.canPowerOff = false;
            verify(!findChild(theme, "rebootButton").enabled);
            verify(!findChild(theme, "powerOffButton").enabled);
        }
        function test_keyboardScroll() {
            theme.width = 640;
            theme.height = 480;
            wait(20);
            password.forceActiveFocus();
            keyClick(Qt.Key_Tab);
            verify(findChild(theme, "sessionChoice").activeFocus);
            keyClick(Qt.Key_Tab);
            verify(findChild(theme, "loginButton").activeFocus);
            keyClick(Qt.Key_Tab);
            verify(findChild(theme, "rebootButton").activeFocus);
            keyClick(Qt.Key_Tab);
            const shutdown = findChild(theme, "powerOffButton");
            verify(shutdown.activeFocus);
            const scroll = findChild(theme, "formScroll");
            const point = shutdown.mapToItem(scroll, 0, 0);
            verify(point.y >= 0 && point.y + shutdown.height <= scroll.height + 1);
            keyClick(Qt.Key_Tab);
            verify(findChild(theme, "userChoice").activeFocus);
            keyClick(Qt.Key_Tab);
            verify(password.activeFocus);
        }
        function test_avatar() {
            const profile = findChild(theme, "userProfile");
            verify(profile.visible);
            userModel.setProperty(1, "icon", Qt.resolvedUrl("../Assets/backgrounds/final_lab_background.png").toString());
            wait(50);
            const avatar = findChild(profile, "avatarImage1");
            compare(avatar.status, Image.Ready);
            verify(avatar.visible);
            grabImage(theme).save("/tmp/cyber-lab-avatar.png");
            userModel.setProperty(1, "icon", "");
            wait(10);
            verify(!avatar.visible);
        }
        function test_emptyModels() {
            panel.users = [];
            panel.sessions = [];
            wait(10);
            verify(!panel.canLogin);
            panel.submit();
            compare(sddm.loginCalls, 0);
            verify(findChild(theme, "statusMessage").text.length > 0);
        }
        function test_sizes_data() {
            return [ {tag:"640x480", w:640, h:480}, {tag:"800x600", w:800, h:600},
                     {tag:"1280x720", w:1280, h:720}, {tag:"1920x1080", w:1920, h:1080} ];
        }
        function test_sizes(data) {
            theme.width = data.w;
            theme.height = data.h;
            wait(50);
            const monitor = findChild(theme, "monitor");
            verify(monitor.x > theme.width / 2);
            verify(monitor.x + monitor.width <= theme.width);
            verify(monitor.y >= 0);
            verify(monitor.y + monitor.height <= theme.height);
            const background = findChild(theme, "background");
            compare(background.status, Image.Ready);
            verify(background.visible && background.opacity === 1);
            const initialX = monitor.x;
            test.parent.config = {GreenColor: "#66ff99", ShowUserPicture: "false", AnimationEnabled: "true", AnimationDuration: "800"};
            wait(20);
            compare(monitor.x, initialX);
            verify(!findChild(theme, "userProfile").visible);
            grabImage(theme).save("/tmp/cyber-lab-" + data.tag + ".png");
        }
    }
}
