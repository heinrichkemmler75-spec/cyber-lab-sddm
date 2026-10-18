#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if (( $# )); then
    printf 'Usage: %s (environment: QT_QPA_PLATFORM, QT_QUICK_BACKEND)\n' "$0" >&2
    exit 2
fi
if ! command -v sddm-greeter-qt6 >/dev/null; then
    printf 'Qt6-Greeter sddm-greeter-qt6 fehlt.\n' >&2
    exit 1
fi
for file in Main.qml theme.conf metadata.desktop Assets/backgrounds/final_lab_background.png; do
    test -r "$root/$file" || { printf 'Fehlende Datei: %s\n' "$file" >&2; exit 1; }
done
exec sddm-greeter-qt6 --test-mode --theme "$root"
