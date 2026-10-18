import QtQuick
import QtTest
import ".."

Item {
    width: 1920
    height: 1080
    property var config: ({GreenColor: "#66ff99", ShowUserPicture: "true", AnimationEnabled: "false", AnimationDuration: "2000"})
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
            test.parent.config = {GreenColor: "#66ff99", ShowUserPicture: "true", AnimationEnabled: "false", AnimationDuration: "2000"};
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
        function checkMeasuredPose() {
            const monitor = findChild(theme, "monitor");
            const scale = Math.max(theme.width / 1672, theme.height / 941);
            const dx = (theme.width - 1672 * scale) / 2;
            const dy = (theme.height - 941 * scale) / 2;
            const topLeft = monitor.mapToItem(theme, 0, 0);
            const topRight = monitor.mapToItem(theme, monitor.width, 0);
            const bottomRight = monitor.mapToItem(theme, monitor.width, monitor.height);
            // Independent measurements, not values imported from production geometry.
            fuzzyCompare(topLeft.x, dx + 930 * scale, 0.01);
            fuzzyCompare(topLeft.y, dy + 320 * scale, 0.01);
            fuzzyCompare(topRight.x - topLeft.x, 404 * scale, 0.01);
            fuzzyCompare(topRight.y, topLeft.y, 0.01);
            fuzzyCompare(bottomRight.y - topRight.y, 292 * scale, 0.01);
            fuzzyCompare(bottomRight.x, topRight.x, 0.01);
            compare(findChild(theme, "terminalAnimation").foldAngle, 0);
            const reference = findChild(theme, "referenceScene");
            const wrist = findChild(theme, "wristJoint").mapToItem(reference, 0, 0);
            fuzzyCompare(wrist.x, 1404, 0.01);
            fuzzyCompare(wrist.y, 453, 0.01);
        }
        function test_animationCompletesExactly() {
            const motion = findChild(theme, "terminalAnimation");
            test.parent.config = {GreenColor: "#66ff99", ShowUserPicture: "true", AnimationEnabled: "true", AnimationDuration: "2000"};
            verify(motion.running);
            wait(120);
            verify(motion.progress > 0 && motion.progress < 1);
            // Resize during the animation: geometry uses the current background transform.
            theme.width = 1672;
            theme.height = 941;
            tryCompare(motion, "running", false, 2600);
            compare(motion.progress, 1);
            checkMeasuredPose();
            verify(password.activeFocus);
            motion.restart();
            wait(80);
            test.parent.config = {GreenColor: "#66ff99", ShowUserPicture: "true", AnimationEnabled: "false", AnimationDuration: "2000"};
            verify(!motion.running);
            checkMeasuredPose();
            test.parent.config = {GreenColor: "#66ff99", ShowUserPicture: "true", AnimationEnabled: "true", AnimationDuration: "0"};
            verify(!motion.running);
            checkMeasuredPose();
        }
        function test_threeJointChain() {
            theme.width = 1672;
            theme.height = 941;
            const motion = findChild(theme, "terminalAnimation");
            const arm = findChild(theme, "swingArm");
            const reference = findChild(theme, "referenceScene");
            const shoulder = findChild(theme, "shoulderJoint");
            const elbow = findChild(theme, "elbowJoint");
            const wrist = findChild(theme, "wristJoint");
            const monitor = findChild(theme, "monitor");
            const poses = [0, 0.155, 0.31, 0.43, 0.55, 0.61, 0.67, 0.77, 0.9, 1];
            for (let i = 0; i < poses.length; ++i) {
                motion.progress = poses[i];
                wait(20);
                const a = shoulder.mapToItem(reference, 0, 0);
                fuzzyCompare(a.x, 1674, 0.01);
                fuzzyCompare(a.y, 658, 0.01);
                // Upper-link length is invariant in its model Y-Z space,
                // not in a foreshortened 2D projection.
                fuzzyCompare(Math.hypot(arm.upperX, elbow.projectedY, elbow.projectedZ),
                             Math.hypot(198, 48, 210), 0.01);
                compare(wrist.x, -198);
                compare(elbow.rotation, 0);
                compare(wrist.rotation, 0);
                compare(findChild(theme, "background").opacity, 1);
                verify(findChild(theme, "background").visible);
                grabImage(theme).save("/tmp/cyber-lab-motion-" + i + ".png");
            }
            checkMeasuredPose();
        }
        function test_phaseOrderAndDirection() {
            const motion = findChild(theme, "terminalAnimation");
            const reference = findChild(theme, "referenceScene");
            const elbow = findChild(theme, "elbowJoint");
            const wrist = findChild(theme, "wristJoint");
            const monitor = findChild(theme, "monitor");
            motion.progress = 0;
            const startAngle = motion.baseAngle;
            const startWrist = wrist.mapToItem(reference, 0, 0);
            verify(startWrist.x > 1672, "Starts beyond the right edge");
            motion.progress = 0.155;
            verify(motion.baseAngle > startAngle, "Clockwise base rotation");
            compare(motion.liftAngle, 65);
            compare(motion.foldAngle, 65);
            motion.progress = 0.31;
            compare(motion.baseAngle, 0);
            compare(motion.liftAngle, 65);
            compare(motion.foldAngle, 65);
            const low = wrist.mapToItem(reference, 0, 0);
            const hinge = elbow.mapToItem(reference, 0, 0);
            motion.progress = 0.43;
            const mid = wrist.mapToItem(reference, 0, 0);
            fuzzyCompare(mid.x, low.x, 0.01);
            verify(mid.y < low.y, "Joint 2 lifts, with no sideways sweep");
            compare(motion.baseAngle, 0);
            compare(motion.foldAngle, 65);
            motion.progress = 0.55;
            const raised = wrist.mapToItem(reference, 0, 0);
            fuzzyCompare(raised.x, low.x, 0.01);
            verify(raised.y < mid.y);
            fuzzyCompare(elbow.mapToItem(reference, 0, 0).y, hinge.y, 0.01);
            compare(motion.liftAngle, 0);
            compare(motion.foldAngle, 65);
            // Geometry no longer collapses while unfolding. The underside
            // is drawn with perspective sprites at its full mechanical size.
            compare(monitor.openness, 0);
            verify(findChild(theme, "monitor").foldAngle > 60);
            motion.progress = 0.61;
            verify(motion.foldAngle < 65 && motion.foldAngle > 0, "Counter-clockwise unfolding");
            compare(motion.baseAngle, 0);
            compare(motion.liftAngle, 0);
            fuzzyCompare(wrist.mapToItem(reference, 0, 0).y, raised.y, 0.01);
            motion.progress = 0.67;
            checkMeasuredPose();
            motion.progress = 0.77;
            verify(Math.abs(motion.foldAngle) <= 0.6);
            verify(Math.abs(motion.foldAngle) > 0);
            compare(motion.baseAngle, 0);
            compare(motion.liftAngle, 0);
            motion.progress = 0.90;
            checkMeasuredPose();
            motion.progress = 1;
            checkMeasuredPose();
        }
        function test_noTopEntrance() {
            const motion = findChild(theme, "terminalAnimation");
            const reference = findChild(theme, "referenceScene");
            const monitor = findChild(theme, "monitor");
            let previousX = Infinity;
            for (let i = 0; i <= 31; ++i) {
                motion.progress = i / 100;
                const center = monitor.mapToItem(reference, monitor.width / 2, monitor.height / 2);
                verify(center.x <= previousX + 0.01, "Entrance moves right to left");
                previousX = center.x;
                const corners = [monitor.mapToItem(reference, 0, 0),
                    monitor.mapToItem(reference, monitor.width, 0),
                    monitor.mapToItem(reference, 0, monitor.height),
                    monitor.mapToItem(reference, monitor.width, monitor.height)];
                for (const corner of corners)
                    verify(corner.y > 450, "No monitor entry from above");
            }
            motion.progress = 1;
        }
        function test_smoothBoundariesAndUnfolding() {
            const motion = findChild(theme, "terminalAnimation");
            const monitor = findChild(theme, "monitor");
            const reference = findChild(theme, "referenceScene");
            for (const boundary of [0.31, 0.55, 0.67, 0.77, 0.90]) {
                motion.progress = boundary - 0.0001;
                const before = monitor.mapToItem(reference, 0, 0);
                motion.progress = boundary + 0.0001;
                const after = monitor.mapToItem(reference, 0, 0);
                verify(Math.hypot(after.x - before.x, after.y - before.y) < 0.1,
                       "No visible position jump at a phase boundary");
            }
            for (let i = 0; i <= 24; ++i) {
                motion.progress = 0.55 + 0.12 * i / 24;
                const left = monitor.mapToItem(reference, 0, 0);
                const right = monitor.mapToItem(reference, monitor.width, 0);
                verify(right.x - left.x <= 404.01, "No perspective ballooning past final width: " + (right.x - left.x) + " at " + motion.progress);
            }
            motion.progress = 1;
            checkMeasuredPose();
        }
        function test_sizes_data() {
            return [ {tag:"1672x941", w:1672, h:941}, {tag:"640x480", w:640, h:480}, {tag:"800x600", w:800, h:600},
                     {tag:"1280x720", w:1280, h:720}, {tag:"1920x1080", w:1920, h:1080} ];
        }
        function test_sizes(data) {
            theme.width = data.w;
            theme.height = data.h;
            wait(50);
            const monitor = findChild(theme, "monitor");
            checkMeasuredPose();
            const background = findChild(theme, "background");
            compare(background.status, Image.Ready);
            verify(background.visible && background.opacity === 1);
            test.parent.config = {GreenColor: "#66ff99", ShowUserPicture: "false", AnimationEnabled: "false", AnimationDuration: "2000"};
            wait(20);
            checkMeasuredPose();
            verify(!findChild(theme, "userProfile").visible);
            grabImage(theme).save("/tmp/cyber-lab-" + data.tag + ".png");
        }
    }
}
