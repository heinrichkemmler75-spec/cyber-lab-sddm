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

                // Cable harness routed under the lower mechanical beam.
                Image {
                    z: -1
                    x: -8
                    y: 16
                    width: arm.pose.lowerLength
                    height: 45
                    source: "../Assets/arm/cable_bundle.png"
                    rotation: arm.pose.shoulderAngle
                    transformOrigin: Item.TopLeft
                    fillMode: Image.Stretch
                    smooth: true
                }
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

                    // Flexible cable loop between elbow and wrist; it follows
                    // the second segment as the projection changes.
                    Canvas {
                        id: upperCable
                        z: -1
                        x: Math.min(0, arm.upperX) - 18
                        y: Math.min(0, elbow.projectedY) - 25
                        width: Math.abs(arm.upperX) + 48
                        height: Math.abs(elbow.projectedY) + 70
                        onPaint: {
                            const p = getContext("2d");
                            p.reset();
                            const sx = 18 - x, sy = -y;
                            const ex = arm.upperX - x, ey = elbow.projectedY - y;
                            p.strokeStyle = "#151b18";
                            p.lineWidth = 9;
                            p.lineCap = "round";
                            p.beginPath();
                            p.moveTo(sx, sy);
                            p.bezierCurveTo(sx + (ex-sx)*0.32, sy+46,
                                           sx + (ex-sx)*0.70, ey+50, ex, ey);
                            p.stroke();
                            p.strokeStyle = "#66756c";
                            p.lineWidth = 1.5;
                            p.stroke();
                        }
                        Connections {
                            target: elbow
                            function onProjectedYChanged() { upperCable.requestPaint() }
                        }
                    }
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
                            // Perspective/underside views are now drawn inside
                            // TerminalMonitor. Never scale the entire login panel
                            // during the final unfolding.
                            // An identity transform preserves the calibrated pose.
                            transform: Rotation {
                                objectName: "monitorFoldRotation"
                                axis.x: 0; axis.y: 1; axis.z: 0
                                angle: 0
                            }
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
                            // The monitor mount is a single mechanical part.
                            // Its rear housing is aligned to the right monitor
                            // edge and the vertical center of the monitor.
                            // Keep the wrist pivot at the calibrated position:
                            // duplicating the same sprite in an ArmJoint would
                            // make the connection appear to have two joints.
                            Image {
                                x: arm.pose.monitorX + arm.pose.width - 30
                                y: arm.pose.monitorY + arm.pose.height / 2 - height / 2
                                width: 115
                                height: 120
                                z: -1
                                source: "../Assets/arm/monitor_mount.png"
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                            }
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
