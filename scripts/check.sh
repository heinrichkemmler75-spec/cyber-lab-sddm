#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
qt_bin=${QT6_BIN_DIR:-/usr/lib/qt6/bin}
for tool in qmllint qmltestrunner; do
    test -x "$qt_bin/$tool" || { printf 'Fehlt: %s/%s (QT6_BIN_DIR setzen)\n' "$qt_bin" "$tool" >&2; exit 1; }
done
for script in "$root"/scripts/*.sh; do
    bash -n "$script"
done
"$qt_bin/qmllint" "$root/Main.qml" "$root"/Components/*.qml
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
    "$qt_bin/qmltestrunner" -input "$root/tests" -o -,txt
log=$(mktemp)
trap 'rm -f "$log"' EXIT
status=0
QT_FORCE_STDERR_LOGGING=1 QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
    timeout 5s "$root/scripts/test.sh" >"$log" 2>&1 || status=$?
cat "$log"
if [[ $status != 124 ]]; then
    printf 'Greeter wurde unerwartet beendet (Status %s).\n' "$status" >&2
    exit 1
fi
if grep -E 'ReferenceError|TypeError|SyntaxError|Binding loop|Cannot assign|Unable to assign|not installed|No such file|Error decoding|Cannot open|Failed to load|Fallback to embedded theme|is not a type|is not available' "$log"; then
    exit 1
fi
grep -q 'Adding view for' "$log"
printf 'QML-Prüfung, Oberflächentests und Greeter-Ladetest bestanden. Keine echte Systemanmeldung geprüft.\n'
