import QtQuick

GreenComboBox {
    id: selector
    property var sessions
    model: sessions
    Accessible.name: "Desktop-Sitzung"
    Component.onCompleted: {
        const last = sessions ? sessions.lastIndex : -1;
        currentIndex = count > 0 ? Math.max(0, Math.min(last, count - 1)) : -1;
    }
}
