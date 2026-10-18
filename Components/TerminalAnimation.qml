import QtQuick

QtObject {
    // Reserved interface. Deliberately no transforms, timers or animations yet.
    property Item target
    property bool animationEnabled: false
    property int duration: 800
    readonly property bool running: false
    signal ready()
    Component.onCompleted: ready()
}
