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

    readonly property bool baseMoving: Math.abs(baseAngle) > 0.2
    readonly property bool elbowMoving: Math.abs(liftAngle) > 0.2
    readonly property bool wristMoving: Math.abs(foldAngle) > 0.2

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

        // The base stays attached to the right-hand machine; its lower portion
        // deliberately disappears below the scene.
        Image {
            z: -2
            source: "../Assets/arm/base.png"
            width: 250
            height: 185
            x: -168
            y: -90
            smooth: true
            mipmap: true
            fillMode: Image.PreserveAspectFit
        }

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
                    sprite: "../Assets/arm/lower_link.png"
                    accent: arm.accent
                }
                Item {
                    id: elbow
                    objectName: "elbowJoint"
                    x: arm.elbowX
                    y: arm.elbowY
                    // Y-Z lift is modelled in projection, not another side swing.
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
                        sprite: "../Assets/arm/upper_link.png"
                        accent: arm.accent
                    }
                    Item {
                        id: wrist
                        objectName: "wristJoint"
                        x: arm.upperX
                        y: elbow.projectedY
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
                                    xScale: 1 - 0.6 * Math.sin(Math.abs(arm.foldAngle) * Math.PI / 180)
                                    yScale: arm.faceHeightScale
                                }
                            ]
                            // Real mechanical housing joins the wrist to the
                            // frame. The hidden beam keeps end-pose geometry
                            // stable without drawing across the login field.
                            ArmLink {
                                id: connector
                                readonly property real dx: arm.pose.monitorX + arm.pose.width
                                readonly property real dy: arm.pose.monitorY + arm.pose.height / 2
                                width: Math.hypot(dx, dy)
                                transform: Rotation {
                                    origin.y: 10
                                    angle: Math.atan2(connector.dy, connector.dx) * 180 / Math.PI
                                }
                                sprite: ""
                                visible: false
                            }
                            Image {
                                x: -87
                                y: -60
                                width: 115
                                height: 120
                                z: -1
                                source: "../Assets/arm/monitor_mount.png"
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                            }
                        }
                        ArmJoint {
                            sprite: "../Assets/arm/elbow_joint.png"
                            accent: arm.accent
                            motorActive: arm.wristMoving
                            z: 3
                        }
                    }
                    ArmJoint {
                        sprite: "../Assets/arm/elbow_joint.png"
                        accent: arm.accent
                        motorActive: arm.elbowMoving
                        z: 3
                    }
                }
                ArmJoint {
                    sprite: "../Assets/arm/base_joint.png"
                    accent: arm.accent
                    motorActive: arm.baseMoving
                    z: 3
                }
            }
        }
    }
}
