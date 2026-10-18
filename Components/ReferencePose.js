.pragma library

// Pixel measurements: docs/reference-pose.md. Norms refer to the full source image,
// NEVER to the viewport. Do not tune the final pose in the animation tracks.
var imageWidth = 1672;
var imageHeight = 941;
var monitor = { x: 930 / 1672, y: 320 / 941,
                width: 404 / 1672, height: 292 / 941, roll: 0, yaw: 0 };
var screen = { x: 962 / 1672, y: 346 / 941,
               width: 340 / 1672, height: 234 / 941 };
var base = { x: 1674 / 1672, y: 658 / 941 };
var elbow = { x: 1602 / 1672, y: 501 / 941 };
var wrist = { x: 1404 / 1672, y: 453 / 941 };

function pixel(point) { return { x: point.x * imageWidth, y: point.y * imageHeight }; }
function distance(a, b) { return Math.hypot(b.x - a.x, b.y - a.y); }
function angle(a, b) { return Math.atan2(b.y - a.y, b.x - a.x) * 180 / Math.PI; }
function geometry() {
    var a = pixel(base), b = pixel(elbow), c = pixel(wrist);
    var m = pixel(monitor), s = pixel(screen);
    var w = monitor.width * imageWidth, h = monitor.height * imageHeight;
    var first = angle(a, b), second = angle(b, c);
    return {
        baseX: a.x, baseY: a.y,
        lowerLength: distance(a, b), upperLength: distance(b, c),
        shoulderAngle: first, elbowAngle: second - first,
        wristAngle: monitor.roll - second,
        monitorX: m.x - c.x, monitorY: m.y - c.y,
        width: w, height: h,
        screenX: s.x - m.x, screenY: s.y - m.y,
        screenWidth: screen.width * imageWidth, screenHeight: screen.height * imageHeight
    };
}

// Each phase owns one degree of freedom. The clock stays linear; the local
// phase interpolation is InOutCubic, with zero velocity at both boundaries.
function phase(t, start, end) {
    var u = Math.max(0, Math.min(1, (t - start) / (end - start)));
    return u < 0.5 ? 4 * u * u * u : 1 - Math.pow(-2 * u + 2, 3) / 2;
}

function latch(t) {
    // A single sub-degree excursion, then rest. No perpetual spring/oscillation.
    if (t <= 0.90 || t >= 1.0) return 0;
    if (t < 0.945) return 0.45 * phase(t, 0.90, 0.945);
    return 0.45 * (1 - phase(t, 0.945, 1.0));
}
