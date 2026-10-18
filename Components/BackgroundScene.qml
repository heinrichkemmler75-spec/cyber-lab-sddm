import QtQuick

Image {
    source: Qt.resolvedUrl("../Assets/backgrounds/final_lab_background.png")
    fillMode: Image.PreserveAspectCrop
    asynchronous: false
    // Always present; the animation interface only receives the monitor.
}
