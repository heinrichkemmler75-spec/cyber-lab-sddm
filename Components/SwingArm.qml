import QtQuick
import "ReferencePose.js" as ReferencePose

Item {
    id: arm
    objectName: "swingArm"
    default property alias payload: wrist.data
    readonly property var pose: ReferencePose.geometry()
    property real shoulderAngle: pose.shoulderAngle
    property real elbowAngle: pose.elbowAngle
    property real wristAngle: pose.wristAngle
    property color accent: "#66ff99"

    // True serial chain: all geometry downstream inherits each joint rotation.
    Item {
        id: shoulder
        objectName: "shoulderJoint"
        x: arm.pose.baseX; y: arm.pose.baseY
        rotation: arm.shoulderAngle
        transformOrigin: Item.TopLeft
        ArmLink { width: arm.pose.lowerLength; accent: arm.accent }
        Item {
            id: elbow
            objectName: "elbowJoint"
            x: arm.pose.lowerLength
            rotation: arm.elbowAngle
            transformOrigin: Item.TopLeft
            ArmLink { width: arm.pose.upperLength; accent: arm.accent }
            Item {
                id: wrist
                objectName: "wristJoint"
                x: arm.pose.upperLength
                rotation: arm.wristAngle
                transformOrigin: Item.TopLeft
                // Connector terminates at the measured right-hand monitor edge.
                ArmLink {
                    id: connector
                    readonly property real dx: arm.pose.monitorX + arm.pose.width
                    readonly property real dy: arm.pose.monitorY + arm.pose.height / 2
                    width: Math.hypot(dx, dy)
                    transform: Rotation {
                        origin.x: 0; origin.y: 10
                        angle: Math.atan2(connector.dy, connector.dx) * 180 / Math.PI
                    }
                    accent: arm.accent
                }
                ArmJoint { accent: arm.accent; z: 1 }
            }
            ArmJoint { accent: arm.accent; z: 1 }
        }
        ArmJoint { accent: arm.accent; z: 1 }
    }
}
