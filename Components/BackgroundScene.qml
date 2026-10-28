import QtQuick

// KDE's SDDM KCM stores the wallpaper under [General] background in
// theme.conf.user. Paths may be relative to the theme or absolute when
// a user selects an external picture.
Image {
    id: scene
    property string backgroundPath: "Assets/backgrounds/final_lab_background.png"
    property string backgroundType: "image"
    property color backgroundColor: "#000000"

    readonly property string selectedPath: backgroundPath.trim()
    readonly property string effectivePath: selectedPath.length > 0
        ? selectedPath : "Assets/backgrounds/final_lab_background.png"

    source: backgroundType.toLowerCase() === "color" ? ""
        : effectivePath.startsWith("file:") || effectivePath.startsWith("qrc:")
          ? effectivePath
        : effectivePath.startsWith("/") ? "file://" + effectivePath
        : Qt.resolvedUrl("../" + effectivePath)
    fillMode: Image.PreserveAspectCrop
    asynchronous: false

    Rectangle {
        anchors.fill: parent
        color: scene.backgroundColor
        visible: scene.backgroundType.toLowerCase() === "color"
        z: -1
    }
}
