# Cyber Lab SDDM

**Cyber Lab SDDM** ist ein in Entwicklung befindliches, animiertes Anmeldetheme für [SDDM](https://github.com/sddm/sddm). Statt einer gewöhnlichen Anmeldemaske erscheint ein kompakter High-Tech-Monitor, der an einem filigranen Gelenkarm seitlich ins Bild schwenkt, einrastet und anschließend die Anmeldung ermöglicht.

> **Projektstatus:** Konzept- und Planungsphase. Eine lauffähige Version wurde noch nicht veröffentlicht.

## Gestaltung

Das Theme zeigt einen dunklen, technischen Laborraum auf der Erde: Geräte, Glaswände, Server, Kabel, Metalloberflächen und zurückhaltende Beleuchtung bilden den Hintergrund. Im Vordergrund befindet sich ein mechanisch aufgehängter Monitor mit klarer **grün-schwarzer Benutzeroberfläche**.

Der Stil ist technisch, atmosphärisch und funktional. Kräftige grüne Akzente, kleine Statusleuchten und strukturierte Metallrahmen erzeugen Tiefe. Die eigentliche Schrift bleibt gut lesbar und kontrastreich.

## Einschwenkanimation

Die Bewegung wird als **Pseudo-3D-Animation** mit Qt Quick umgesetzt und besteht aus fünf kurzen Phasen:

1. **Ruheposition:** Zunächst ist nur der Laborhintergrund zu sehen.
2. **Einschwenken:** Der Gelenkarm führt den Monitor von der Seite ins Bild.
3. **Ausrichten:** Der Monitor dreht sich aus einer schrägen Perspektive in die Endposition.
4. **Einrasten:** Eine kurze, gedämpfte Nachbewegung vermittelt einen mechanischen Anschlag.
5. **Anmeldung:** Das Display fordert zur Eingabe des Passworts auf.

**Wichtig:** In der Endposition steht der Monitor **frontal und parallel zur Bildschirmebene**. Benutzername, Avatar und Eingabefelder werden ohne perspektivische Verzerrung dargestellt.

### Tempo

- Angestrebte Gesamtdauer: **maximal ca. 800 ms**.
- Keine langwierigen Boottexte oder künstlichen Wartezeiten.
- Die Anmeldung soll möglichst sofort per Tastatur bedienbar sein.
- Eine Option zum Deaktivieren der Animation ist vorgesehen.

## Geplante Funktionen

| Bereich | Beschreibung |
| --- | --- |
| Anmeldung | Reguläre SDDM-Authentifizierung |
| Benutzer | Anzeige und Auswahl vorhandener Systembenutzer |
| Profilbild | Übernahme des vom System bereitgestellten Benutzerbildes, sofern vorhanden |
| Passwort | Fokussiertes Passwortfeld mit klaren Fehlermeldungen |
| Sitzungen | Auswahl verfügbarer Desktop-Sitzungen |
| Systemaktionen | Neustart und Herunterfahren |
| Darstellung | Skalierbares Layout für unterschiedliche Bildschirmgrößen |
| Animation | Seitlich einschwenkender Arm, Monitorrotation und kurzes Einrasten |
| Konfiguration | Animation abschaltbar; weitere Optionen nach Umsetzung |
| Sound | Optionaler kurzer mechanischer Effekt, sofern am Anmeldebildschirm zuverlässig möglich |
| Integration | Installation als auswählbares SDDM-Theme in den KDE-Systemeinstellungen |

Eine virtuelle Bildschirmtastatur ist nicht vorgesehen.

## Technik

- **Plattform:** Linux mit SDDM, insbesondere KDE Plasma.
- **Oberfläche:** Qt Quick / QML, mit Schwerpunkt auf aktuellen Qt-6-Umgebungen.
- **Authentifizierung:** Über die bestehende SDDM-Schnittstelle; keine eigene Passwortprüfung.
- **Grafiken:** Laborhintergrund, Gelenkarm, Monitorrahmen und Benutzeroberfläche als getrennte Elemente.
- **Animation:** Transformationen und Zustandswechsel statt einer langen Videosequenz.
- **Sicherheit:** Das vorhandene Anmeldetheme bleibt während der Entwicklung unangetastet. Neue Versionen werden zunächst im Testmodus geprüft.

## Vorgesehene Verzeichnisstruktur

*Die folgende Struktur ist geplant und noch nicht vollständig angelegt.*

```text
cyber-lab-sddm/
├── README.md
├── metadata.desktop
├── Main.qml
├── theme.conf
├── Components/
│   ├── BackgroundScene.qml
│   ├── SwingArm.qml
│   ├── TerminalMonitor.qml
│   ├── LoginPanel.qml
│   └── TerminalAnimation.qml
├── Assets/
│   ├── backgrounds/
│   ├── arm/
│   ├── terminal/
│   ├── icons/
│   └── previews/
└── scripts/
    ├── test.sh
    └── install.sh
```

Das Passwortfeld und die Benutzerwahl werden als **echte QML-Bedienelemente** über der grafischen Displayfläche dargestellt, nicht als Bestandteil eines statischen Bildes.

## Entwicklungsplan

1. **Grundgerüst:** SDDM-Metadaten, Basisoberfläche und lokaler Teststart.
2. **Statische Szene:** Laborhintergrund und Monitor in frontaler Endposition.
3. **Anmeldefunktionen:** Benutzerbild, Passwort, Sitzungswahl und Systemaktionen.
4. **Animation:** Gelenkarm, räumliches Einschwenken, Rotation und Einrastbewegung.
5. **Feinschliff:** Statusleuchten, Skalierung, Einstellmöglichkeiten und gegebenenfalls Sound.
6. **Tests und Installation:** Vorschau, Tastaturbedienung, Fehlerszenarien, Installation und Auswahl in KDE.

## Installation

**Noch nicht verfügbar.** Sobald die erste funktionsfähige Version fertiggestellt ist, werden hier die benötigten Abhängigkeiten, die Installation unter `/usr/share/sddm/themes/`, der Testmodus und die Auswahl über die KDE-Systemeinstellungen dokumentiert.

## Rückmeldungen

Hinweise zu Darstellung, Lesbarkeit, Animation und zuverlässiger Anmeldung sind willkommen. Die Entwicklung erfolgt schrittweise und nachvollziehbar im Repository.
