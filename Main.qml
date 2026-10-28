import QtQuick
import "Components"
import "Components/ReferencePose.js" as ReferencePose

Item {
    id: root
    width: 1280
    height: 720
    clip: true

    // SDDM injects these context properties at runtime; qmllint cannot discover them.
    // qmllint disable unqualified
    readonly property var themeConfig: config
    readonly property var greeter: sddm
    readonly property var availableUsers: userModel
    readonly property var availableSessions: sessionModel
    // qmllint enable unqualified
    readonly property color accent: root.themeConfig.GreenColor || "#66ff99"
    readonly property bool showAvatar: String(root.themeConfig.ShowUserPicture).toLowerCase() !== "false"
    // KDE SDDM writes the lowercase [General] showClock option into theme.conf.user.
    // Missing values retain the enabled default; an explicit false disables it.
    readonly property bool showClock: !["false", "0", "off"].includes(
        String(root.themeConfig.showClock).toLowerCase())
    readonly property bool animationEnabled: String(root.themeConfig.AnimationEnabled).toLowerCase() === "true"
    readonly property int animationDuration: isFinite(Number(root.themeConfig.AnimationDuration))
        ? Math.max(0, Number(root.themeConfig.AnimationDuration)) : 3000
    readonly property real sceneScale: Math.max(width / ReferencePose.imageWidth, height / ReferencePose.imageHeight)

    BackgroundScene {
        objectName: "background"
        anchors.fill: parent
        // Match the exact keys used by KDE's SDDM configuration module.
        backgroundPath: root.themeConfig.background
            ? String(root.themeConfig.background)
            : "Assets/backgrounds/final_lab_background.png"
        backgroundType: root.themeConfig.type
            ? String(root.themeConfig.type) : "image"
        backgroundColor: root.themeConfig.color
            ? root.themeConfig.color : "#000000"
    }

    Item {
        id: referenceScene
        objectName: "referenceScene"
        width: ReferencePose.imageWidth
        height: ReferencePose.imageHeight
        x: (root.width - width * root.sceneScale) / 2
        y: (root.height - height * root.sceneScale) / 2
        scale: root.sceneScale
        transformOrigin: Item.TopLeft

        SwingArm {
            id: arm
            baseAngle: motion.baseAngle
            liftAngle: motion.liftAngle
            foldAngle: motion.foldAngle
            faceHeightScale: motion.faceHeightScale
            accent: root.accent
            TerminalMonitor {
                id: monitor
                objectName: "monitor"
                x: arm.pose.monitorX
                y: arm.pose.monitorY
                accent: root.accent
                animationProgress: motion.progress
                foldAngle: motion.foldAngle
                LoginPanel {
                    id: login
                    anchors.fill: parent
                    backend: root.greeter
                    users: root.availableUsers
                    sessions: root.availableSessions
                    accent: root.accent
                    showAvatar: root.showAvatar
                    showClock: root.showClock
                }
            }
        }
    }
    TerminalAnimation {
        id: motion
        animationEnabled: root.animationEnabled
        duration: root.animationDuration
        onReady: login.focusPassword()
    }
}
