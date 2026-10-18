# Vermessene Monitor-Endpose

## Bezugssystem und Messmethode

Verbindliche Bildreferenzen sind `Assets/previews/final_terminal_preview.png` und
`Assets/backgrounds/final_lab_background.png`, beide **1672 × 941 Pixel**. Die Kopien
im gelieferten `cyber-lab-image-package.zip` wurden byteweise damit verglichen: identisch.
Koordinaten beginnen links oben; x zeigt nach rechts, y nach unten.

Der Rahmen wurde im Originalbild an den äußeren Gehäusekanten abgelesen. Der obere
Tragegriff und die seitliche Halterung zählen nicht zum rechteckigen Monitorgehäuse.
Die schwarze Displayöffnung wurde separat vermessen. Der Platzhalter bildet die
rechteckige Hülle des abgefasten Rahmens ab, nicht seine endgültige Silhouette.

Die gemeinsame Bildausrichtung wurde zusätzlich anhand von fünf unverdeckten
40×40-Pixel-Ausschnitten geprüft: normierte Grauwert-Kreuzkorrelation mit einem
Suchbereich von ±8 Pixeln, ohne Skalierung. Beste Verschiebung von Hintergrund zu
Vorschau:

| Ausschnittzentrum | dx, dy | Korrelation |
| --- | --- | --- |
| (100, 800) | (0, 0) | 0,893 |
| (380, 550) | (0, 0) | 0,966 |
| (720, 760) | (−2, 0) | 0,771 |
| (700, 80) | (0, 0) | 0,983 |
| (1130, 180) | (0, 0) | 0,991 |

Vier Ausschnitte stimmen ohne Verschiebung überein. Deshalb wird das gemeinsame
Bildkoordinatensystem verwendet, ohne zusätzliche globale Verschiebung oder
Verzerrung. Die Bilder sind in Details unterschiedlich; sie sind keine zwei
identischen Renderdurchläufe mit bloß zugeschaltetem Monitor.

## Verbindliche Zielwerte

| Größe | Referenzpixel | Normiert auf das vollständige Bild |
| --- | --- | --- |
| Monitor links | 930 | 0,5562200957 |
| Monitor oben | 320 | 0,3400637620 |
| Monitorbreite | 404 | 0,2416267943 |
| Monitorhöhe | 292 | 0,3103081828 |
| Monitorzentrum | (1132, 466) | (0,6770334928; 0,4952178533) |
| Display links/oben | (962, 346) | (0,5753588517; 0,3676939426) |
| Displaybreite/-höhe | (340, 234) | (0,2033492823; 0,2486716259) |
| Endausrichtung | frontal, Roll=0°, Yaw=0°, Pitch=0° | keine Scherung oder Perspektivverzerrung |

Die normierten Werte stehen zentral in `Components/ReferencePose.js`. Die
Bruchschreibweise erhält die vermessenen Pixelwerte ohne Dezimalrundung. Breite,
Höhe und Lage werden nicht mehr anhand der Fenstergröße frei gewählt.

Das Ablesen der gezeichneten Gehäusekanten hat eine Unsicherheit von ungefähr
**2–3 Referenzpixeln**. Die vielen Dezimalstellen dienen der reproduzierbaren
Umrechnung, nicht der Behauptung einer subpixelgenauen Bildmessung. Als festgelegte
Endpose gelten exakt die oben angegebenen Werte. Der Gehäuserahmen und die
Displaykanten sind im Bild annähernd achsenparallel; die Bedienfläche wird gemäß
der frontalen Referenz auf 0° ausgerichtet.

## Abbildung auf den Bildschirm

Für eine Fenstergröße `(W, H)` gilt derselbe mittige Bildbeschnitt wie für den
Hintergrund mit `Image.PreserveAspectCrop`:

```text
s  = max(W / 1672, H / 941)
dx = (W - 1672*s) / 2
dy = (H - 941*s) / 2

Monitor links = dx + 930*s
Monitor oben  = dy + 320*s
Breite        = 404*s
Höhe          = 292*s
```

Bei 1280×720 ergibt das ungefähr `(711,96; 244,78)` mit `309,28×223,54` Pixeln.
Bei 4:3 wird seitlich beschnitten. Es gibt absichtlich keine zusätzliche
Fensterzentrierung, Mindestgröße oder Randkorrektur, die den Monitor relativ zum
Tank verschieben würde. Auch eine Größenänderung während der Animation verwendet
sofort dieselbe neue Abbildung für Hintergrund und Arm.

## Drei Gelenke und Endstellung

Die Gelenkpunkte wurden aus den sichtbaren Ringzentren der Vorschau abgeleitet:

| Gelenk | Referenzpunkt | Einordnung |
| --- | --- | --- |
| Basis/Schulter | (1674, 658) | Ring angeschnitten; Mittelpunkt näherungsweise aus sichtbarem Kreisbogen rekonstruiert, etwa ±8 px |
| Ellbogen | (1602, 501) | sichtbares Ringzentrum, etwa ±3 px |
| Handgelenk/Monitorhalter | (1404, 453) | sichtbares Ringzentrum, etwa ±3 px |

Die Bildreferenz bestimmt keine eindeutige räumliche Robotermekanik. Implementiert
ist eine hierarchische QML-Projektion mit drei unterschiedlichen Bewegungsebenen.
Die abgelesenen Gelenkzentren und die Monitor-Endpose bleiben unverändert.
Die statischen Endvektoren im Bild sind:

```text
Basis → Ellbogen:       (−72, −157)
Ellbogen → Handgelenk:  (−198, −48)
Handgelenk → Monitor:   (−474, −133)   # linke obere Gehäuseecke
```

Die zuletzt genannten Koordinaten werden nie unabhängig animiert. Alle
Bewegungsprojektionen werden in der Endstellung zur Identität, sodass die
vermessenen Bildpunkte exakt wiederhergestellt sind.

### Phase 1: Basis, 0–620 ms

Das erste Gelenk dreht um die Bild-z-Achse von −145° nach 0°. Die zunehmenden
Winkel bedeuten in QML-Bildkoordinaten eine Drehung im Uhrzeigersinn. Ellbogen und
Monitor bleiben zunächst in ihrer abgesenkten bzw. eingeklappten Stellung.

Eine feste Projektionsverkürzung der Bewegungsebene (`S = diag(1, 0.4)`) macht
hieraus einen flachen seitlichen Bogen rechts unten. Die kalibrierte
Transformation ist `S · Rz · inverse(S)`. Damit bleibt die Basis ortsfest, der
Monitor tritt von rechts statt von oben ein, und bei 0° ist die Transformation
exakt die Identität. Das ist eine bewusst gestaltete QML-Projektion und keine
Behauptung über eine aus dem Referenzbild rekonstruierte Kamerakalibrierung.

### Phase 2: Anheben, 620–1100 ms

Das zweite Gelenk bleibt am Ende des ersten Armsegments befestigt. Es hat keine
animierte Drehung um die Bild-z-Achse. Stattdessen wird das obere Segment in der
y-z-Ebene um die x-Achse angehoben:

```text
α: 65° → 0°
x' = −198
y' = −48·cos(α) + 210·sin(α)
z' =  48·sin(α) + 210·cos(α)
```

Die modellierte Tiefe 210 ist ein Gestaltungsparameter für die Bewegung, kein
Messwert aus dem Einzelbild. Die räumliche Segmentlänge bleibt konstant; die
projizierte Länge verändert sich. Das Handgelenk steigt von etwa y=671 auf y=453,
bei unverändertem x=1404. Eine geringe Tiefenskalierung der angehängten Halterung
verstärkt den räumlichen Eindruck. Am Ende ist dieser Skalierungsfaktor 1.

### Phase 3: Monitor aufrichten, 1100–1340 ms

Erst jetzt bewegt sich Gelenk 3. Halterung und Monitor drehen sich gemeinsam von
+65° nach 0° um die lokale y-Achse (abnehmender Winkel, gegen den Uhrzeigersinn in
der gewählten x-z-Ansicht). Eine vertikale Projektionsskalierung von 0,14 nach 1
stellt zunächst eine waagerechte Platte und anschließend die senkrechte frontale
Bedienfläche dar. Eine zusätzliche, winkelabhängige horizontale Verkürzung
kompensiert die Standardperspektive von Qt, damit der Monitor beim Aufrichten
nicht über seine Zielbreite hinaus aufbläht. In der Endpose sind beide Skalen 1.

Diese Kombination simuliert das gewünschte räumliche Aufrichten in Qt Quick 2D;
sie ist kein physikalisch vollständiges 3D-Mesh. Gelenk 1 und 2 bewegen sich dabei
nicht weiter. Gelenk 3 ist über das Handgelenk an Gelenk 2 aufgehängt und erbt
alle vorangegangenen Transformationen.

### Phase 4: Einrasten, 1340–2000 ms

Eine einzige kleine Nachbewegung am Monitorgelenk erreicht maximal −0,6° bei
1540 ms und kehrt bis 1800 ms auf 0° zurück. Die verbleibenden 200 ms sind eine
ruhige Endstellung. Keine Endlosschwingung, keine neue Armbewegung.

Alle Phasen verwenden lokal **InOutCubic**. An den Phasengrenzen sind Position
und Geschwindigkeit stetig; die örtliche Geschwindigkeit ist dort null. Der
zentrale Fortschrittsgeber bleibt linear, damit die Zeitgrenzen stimmen. Eine
abweichende Gesamtdauer skaliert die Anteile 31 %, 24 %, 12 % und 33 % proportional.
Bei abgeschalteter Animation oder Dauer 0 erscheint sofort die gemessene Endpose.

## Nachweis und Bildpaket

Die Qt-Tests prüfen die vier Monitor-Ecken gegen unabhängig festgeschriebene
Bildmesswerte, einschließlich Bildbeschnitt, mit einer numerischen Toleranz von
0,01 Bildschirmpixeln. Diese Rechengenauigkeit ist von der oben beschriebenen
Messunsicherheit zu unterscheiden. Außerdem werden die konstante Segmentlänge im räumlichen Liftmodell,
Phasenreihenfolge, Drehrichtungen, keine seitliche Drift des anhebenden
Handgelenks, Eintritt von rechts statt von oben, weiche Phasengrenzen und
begrenzte Perspektivvergrößerung geprüft. Ende/Abbruch/Dauer 0, Fokus und
Größenänderung während der Bewegung bleiben abgedeckt. Zehn gerenderte Phasen
liegen nach dem Test unter `/tmp/cyber-lab-motion-0.png` bis `-9.png`.
Die [Video-Vorschau](animation-preview.mp4) zeigt die 2000-ms-Bewegung bei 30 fps
mit simulierten Benutzern; sie ist kein Nachweis einer echten Anmeldung.

[Messoverlay auf dem freigegebenen Vorschaubild](reference-pose.svg)

Aktuelle QML-Endpose, mit erfundenen Testbenutzern:

![QML-Endpose](preview-end-pose.png)

Die gelieferten Kandidaten und Konzepttafeln liegen unverändert unter
`docs/image-package/`. Das dortige Originalmanifest beschreibt Referenzmaterial;
seine Aussagen sind keine Produktionsfreigabe. Auf ausdrücklichen Wunsch werden
vorerst nur QML-Formen verwendet. Die Referenzdateien sind kein Bestandteil der
Theme-Installation. Der bestehende Laborhintergrund bleibt unverändert.
