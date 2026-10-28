pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: profile
    property var users
    property int selectedIndex: -1
    property string userName: ""
    property bool showName: true
    property color accent: "#66ff99"
    implicitHeight: 56

    Rectangle {
        // Follow the actual size supplied by the layout; keep the portrait
        // square without stretching either the image or the fallback avatar.
        width: profile.showName ? 56 : Math.min(profile.width, profile.height)
        height: width
        anchors.verticalCenter: parent.verticalCenter
        color: "#0b1910"
        border.color: profile.accent
        Text {
            anchors.centerIn: parent
            text: profile.userName ? profile.userName.charAt(0).toUpperCase() : "?"
            color: profile.accent
            font.pixelSize: Math.round(parent.width * 0.46)
        }
        Repeater {
            model: profile.users
            delegate: Image {
                required property int index
                objectName: "avatarImage" + index
                required property string icon
                anchors.fill: parent
                anchors.margins: 2
                visible: index === profile.selectedIndex && status === Image.Ready
                source: index === profile.selectedIndex ? icon : ""
                fillMode: Image.PreserveAspectFit
            }
        }
    }
    Text {
        visible: profile.showName
        anchors.left: parent.left
        anchors.leftMargin: 70
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: profile.userName || "Kein Benutzer verfügbar"
        color: profile.accent
        font.pixelSize: 17
        elide: Text.ElideRight
    }
}
