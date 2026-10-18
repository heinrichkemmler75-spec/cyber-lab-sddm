#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [[ $# != 1 || $1 != --copy-only ]]; then
    printf 'Usage: sudo %s --copy-only\nKopiert das Theme; aktiviert es nicht.\n' "$0" >&2
    exit 2
fi
destination=/usr/share/sddm/themes/cyber-lab-sddm
install -d -m 755 "$destination" "$destination/Components" "$destination/Assets/backgrounds" "$destination/Assets/previews"
install -m 644 "$root/Main.qml" "$root/metadata.desktop" "$root/theme.conf" "$root/LICENSE" "$destination/"
install -m 644 "$root"/Components/*.qml "$destination/Components/"
install -m 644 "$root/Assets/backgrounds/final_lab_background.png" "$destination/Assets/backgrounds/"
install -m 644 "$root/Assets/previews/final_terminal_preview.png" "$destination/Assets/previews/"
printf 'Kopiert nach %s. Die aktive SDDM-Konfiguration wurde nicht verändert.\n' "$destination"
