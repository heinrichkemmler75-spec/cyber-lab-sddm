import QtQuick
import "ReferencePose.js" as ReferencePose

Item {
    id: arm
    objectName: "swingArm"
    default property alias payload: monitorMount.data
    readonly property var pose: ReferencePose.geometry()
    property real baseAngle: 0
    property real liftAngle: 0
    property real foldAngle: 0
    property real faceHeightScale: 1
    property color accent: "#66ff99"

    // Fixed camera foreshortening of the swing plane keeps the entrance on
    // the lower right. S * Rz * inverse(S) is identity at the measured end pose.
    readonly property real swingProjection: 0.4
    readonly property real elbowX: ReferencePose.pixel(ReferencePose.elbow).x - pose.baseX
    readonly property real elbowY: ReferencePose.pixel(ReferencePose.elbow).y - pose.baseY
    readonly property real upperX: ReferencePose.pixel(ReferencePose.wrist).x - ReferencePose.pixel(ReferencePose.elbow).x
    readonly property real upperY: ReferencePose.pixel(ReferencePose.wrist).y - ReferencePose.pixel(ReferencePose.elbow).y

    Item {
        id: shoulder
        objectName: "shoulderJoint"
        x: arm.pose.baseX
        y: arm.pose.baseY
        transform: Scale { yScale: arm.swingProjection }
        Item {
            id: swing
            objectName: "baseRotation"
            rotation: arm.baseAngle
            transformOrigin: Item.TopLeft
            Item {
                transform: Scale { yScale: 1 / arm.swingProjection }
                ArmLink {
                    width: arm.pose.lowerLength
                    transform: Rotation { origin.y: 10; angle: arm.pose.shoulderAngle }
                    accent: arm.accent
                }
                Item {
                    id: elbow
                    objectName: "elbowJoint"
                    x: arm.elbowX
                    y: arm.elbowY
                    // Y-Z lift around the second hinge. The upper boom has a
                    // model depth of 210 reference pixels, invisible at rest.
                    // Orthographic projection of Rx: y' = y*cos(a) + z*sin(a).
                    // x is constant: this is a lift, not a second side-swing.
                    readonly property real radians: arm.liftAngle * Math.PI / 180
                    readonly property real modelDepth: 210
                    readonly property real projectedY: arm.upperY * Math.cos(radians) + modelDepth * Math.sin(radians)
                    readonly property real projectedZ: -arm.upperY * Math.sin(radians) + modelDepth * Math.cos(radians)
                    readonly property real depthScale: 1 - 0.10 * Math.sin(radians)
                    ArmLink {
                        width: Math.hypot(arm.upperX, elbow.projectedY)
                        transform: Rotation {
                            origin.y: 10
                            angle: Math.atan2(elbow.projectedY, arm.upperX) * 180 / Math.PI
                        }
                        accent: arm.accent
                    }
                    Item {
                        id: wrist
                        objectName: "wristJoint"
                        x: arm.upperX
                        y: elbow.projectedY
                        // Joint 3 inherits both earlier joints. Only its own
                        // X-Z turn begins at 1100 ms; no animated Z roll here.
                        Item {
                            id: monitorMount
                            objectName: "monitorMount"
                            scale: elbow.depthScale
                            transformOrigin: Item.TopLeft
                            transform: [
                                Rotation {
                                    objectName: "monitorFoldRotation"
                                    axis.x: 0; axis.y: 1; axis.z: 0
                                    angle: arm.foldAngle
                                },
                                Scale {
                                    // Counter the default Qt perspective magnification:
                                    // unfolding should grow toward, never balloon past, the end width.
                                    xScale: 1 - 0.6 * Math.sin(Math.abs(arm.foldAngle) * Math.PI / 180)
                                    yScale: arm.faceHeightScale
                                }
                            ]
                            ArmLink {
                                id: connector
                                readonly property real dx: arm.pose.monitorX + arm.pose.width
                                readonly property real dy: arm.pose.monitorY + arm.pose.height / 2
                                width: Math.hypot(dx, dy)
                                transform: Rotation {
                                    origin.y: 10
                                    angle: Math.atan2(connector.dy, connector.dx) * 180 / Math.PI
                                }
                                accent: arm.accent
                            }
                        }
                        ArmJoint { accent: arm.accent; z: 1 }
                    }
                    ArmJoint { accent: arm.accent; z: 1 }
                }
                ArmJoint { accent: arm.accent; z: 1 }
            }
        }
    }
}
