#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [[ $# != 1 || $1 != --copy-only ]]; then
    printf 'Usage: sudo %s --copy-only\nKopiert das Theme; aktiviert es nicht.\n' "$0" >&2
    exit 2
fi
destination=/usr/share/sddm/themes/cyber-lab-sddm
install -d -m 755 "$destination" "$destination/Components"
install -m 644 "$root/Main.qml" "$root/metadata.desktop" "$root/theme.conf" "$root/LICENSE" "$destination/"
install -m 644 "$root"/Components/*.qml "$root"/Components/*.js "$destination/Components/"

# Install all supplied theme artwork, including all selectable backgrounds,
# the animated monitor poses, arm segments and LEDs. Preserve directories.
while IFS= read -r -d '' asset; do
    relative=${asset#"$root/"}
    install -D -m 644 "$asset" "$destination/$relative"
done < <(find "$root/Assets" -type f -print0)

# theme.conf.user is intentionally not copied or overwritten. KDE's KCM
# stores the local background choice there, and it survives theme updates.
printf 'Kopiert nach %s. Die aktive SDDM-Konfiguration wurde nicht verändert.\n' "$destination"
