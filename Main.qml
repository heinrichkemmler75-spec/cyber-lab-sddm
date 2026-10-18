import QtQuick
import "Components"

Item {
    id: root
    width: 1280
    height: 720

    // SDDM injects these context properties at runtime; qmllint cannot discover them.
    // qmllint disable unqualified
    readonly property var themeConfig: config
    readonly property var greeter: sddm
    readonly property var availableUsers: userModel
    readonly property var availableSessions: sessionModel
    // qmllint enable unqualified

    readonly property color accent: root.themeConfig.GreenColor || "#66ff99"
    readonly property bool showAvatar: String(root.themeConfig.ShowUserPicture).toLowerCase() !== "false"
    readonly property bool animationEnabled: String(root.themeConfig.AnimationEnabled).toLowerCase() === "true"
    readonly property int animationDuration: isFinite(Number(root.themeConfig.AnimationDuration))
        ? Math.max(0, Number(root.themeConfig.AnimationDuration)) : 800

    BackgroundScene { objectName: "background"; anchors.fill: parent }

    TerminalMonitor {
        id: monitor
        objectName: "monitor"
        // Geometry belongs to the presentation, never to the authentication panel.
        width: Math.min(470, root.width * 0.43)
        height: Math.min(560, root.height - 32)
        x: root.width - width - Math.max(16, root.width * 0.035)
        y: (root.height - height) / 2
        accent: root.accent

        LoginPanel {
            id: login
            anchors.fill: parent
            backend: root.greeter
            users: root.availableUsers
            sessions: root.availableSessions
            accent: root.accent
            showAvatar: root.showAvatar
        }
    }

    TerminalAnimation {
        target: monitor
        animationEnabled: root.animationEnabled
        duration: root.animationDuration
        onReady: login.focusPassword()
    }
}
