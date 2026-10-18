# Cyber Lab SDDM – Grafikpaket v1

Dies sind **echte RGBA-PNG-Einzeldateien** für den Einbau in das QML-Theme. Die alten \`candidate\`-Bezeichnungen entfallen; die Einzeldateien liegen unter \`Assets/arm/\`, \`Assets/terminal/\` und \`Assets/leds/\`.

## Einbau

Die Ordner \`Assets/arm\`, \`Assets/terminal\` und \`Assets/leds\` direkt im geklonten Repository ablegen und nach GitHub pushen. Vorhandenen Hintergrund und Vorschaubild nicht ersetzen.

- **Arm:** \`base.png\`, \`base_joint.png\`, \`lower_link.png\`, \`elbow_joint.png\`, \`upper_link.png\`, \`monitor_mount.png\`, \`cable_bundle.png\`.
- **Monitor:** \`monitor_frame.png\` mit echter transparenter Bildschirmöffnung.
- **Perspektiven:** \`poses/monitor_00deg.png\` bis \`monitor_90deg.png\`; dies sind technisch aus der Frontansicht projizierte **2,5D-Zwischenbilder**, keine vollständig separat gerenderten dreidimensionalen Seitenansichten. Winkel beziehen sich auf 0° = waagerecht, 90° = frontal/senkrecht.
- **LEDs:** \`ring_base_overlay.png\`, \`ring_segment_overlay.png\`, \`bar_segments.png\` plus fotografische Referenz \`status_bar_reference.png\`.

## Vor dem Produktivbetrieb prüfen

1. Die Einzelgrafiken stammen aus unterschiedlichen Einzelrenders. Auch wenn die Materialien ähnlich sind, sind **Anschlussgeometrie, Drehrichtungen und Maßstab nicht garantiert passend**. Gelenkachsen in QML mit einer Montagevorschau abstimmen.
2. Einzelne Metallteile zeigen noch dunkle Alterungsflecken. **Keine Löcher oder strukturellen Schäden akzeptieren**; fragliche Flecken vor finaler Freigabe nacharbeiten.
3. Die abgeschnittene Basis kann bewusst außerhalb des unteren Bildrands liegen.
4. Echte Login-Elemente gehören als QML über die transparente Öffnung des Monitorrahmens; Passwort darf nicht in PNG eingebrannt werden.
5. LED-Effekte durch QML-Opacity/Rotation/Masken und eigene Schichten animieren.
6. Drei Gelenke: Basisschwenk im Uhrzeigersinn, Hebung danach, Monitor vom waagerechten zum frontal-senkrechten Zustand erst danach. Zeit 2000 ms, Gelenkphasen überlappen jeweils 50 ms.
7. **Nicht** ohne Sichtprüfung sofort als Standard-SDDM-Theme aktivieren.

## Geometrie

\`docs/asset_manifest.json\` dokumentiert PNG-Maße. Exakte Drehpunktkoordinaten sind noch nicht mechanisch vermessen; sie müssen aus dem QML-Aufbau und der tatsächlich gewählten Skalierung ermittelt werden. Gleichzeitiges Ausrichten aller Grafiken durch blindes Festlegen von Pivot-Werten wäre irreführend.
