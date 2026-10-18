# Cyber Lab SDDM

Ein modulares Qt6/QML-Anmeldetheme für SDDM mit permanent sichtbarem Laborhintergrund und einer grünen Anmeldeoberfläche auf schwarzem Grund.

**Status: Version 0.1.0 – erste statische Implementierung.** Der rechteckige Monitor rechts der Bildmitte ist ein Platzhalter. Arm, endgültige Monitorgrafiken und Einschwenkanimation werden separat entwickelt. Die SDDM-Schnittstellen sind angebunden; eine echte Systemanmeldung wurde noch nicht geprüft.

## Funktionen

- Benutzerwahl aus `userModel`, vorbelegt mit dem letzten Benutzer, andernfalls dem ersten verfügbaren Eintrag.
- Benutzerbild aus der von SDDM gelieferten `icon`-Rolle; bei fehlendem oder nicht ladbarem Bild erscheint der Anfangsbuchstabe des Benutzernamens.
- Verdecktes Passwortfeld, unmittelbarer Tastaturfokus, Anmeldung mit Enter oder Schaltfläche.
- Übergabe von Benutzer, Passwort und Sitzungsindex an `sddm.login()`. Während eines Versuchs sind weitere Anmeldeversuche und Systemaktionen gesperrt.
- Nach `loginFailed` klare Fehlermeldung, leeres Passwortfeld und erneuter Passwortfokus. Passwörter werden weder gespeichert noch protokolliert.
- Desktop-Sitzungen aus `sessionModel`, vorbelegt mit der letzten gültigen Sitzung.
- Neustart und Herunterfahren über SDDM; Schaltflächen berücksichtigen `canReboot` und `canPowerOff`.
- Tab/Shift+Tab, Pfeiltasten für Auswahllisten und automatisch nachgeführter Scrollbereich bei kleinen Bildschirmhöhen.
- Keine virtuelle Bildschirmtastatur.

Der freigegebene Hintergrund `Assets/backgrounds/final_lab_background.png` bleibt unverändert und dauerhaft sichtbar. Er wird proportional bildfüllend dargestellt; je nach Seitenverhältnis werden die Ränder beschnitten. Auf schmalen Bildschirmen verdeckt der Monitor einen größeren Teil des Tanks. Empfohlen sind mindestens 1280×720; 640×480 und 800×600 sind bedienbar, benötigen aber gegebenenfalls Scrollen.

## Aufbau

```text
Main.qml                         SDDM-Kontext, Konfiguration und Anordnung
metadata.desktop                 SDDM-Metadaten, Qt6, Version und Vorschau
theme.conf                       Theme-Einstellungen
Components/
  BackgroundScene.qml            Permanenter Laborhintergrund
  TerminalMonitor.qml            Rechteckiger Monitor mit eigenem Inhaltsbereich
  LoginPanel.qml                 Anmeldung, Fehlerzustand und Fokus
  UserProfile.qml                Profilbild und Ersatzanzeige
  SessionSelector.qml            Auswahl der SDDM-Sitzung
  SystemActions.qml              Neustart und Herunterfahren
  TerminalAnimation.qml          Ausschließlich Schnittstelle für spätere Animation
  GreenButton.qml                Gemeinsame Schaltflächengestaltung
  GreenComboBox.qml              Gemeinsame Auswahlgestaltung
Assets/
  backgrounds/final_lab_background.png
  previews/final_terminal_preview.png
  arm/, terminal/, icons/        Reserviert für spätere Entwicklung
scripts/
  test.sh                        Echter SDDM-Greeter im Testmodus
  check.sh                       Statische Prüfung, Qt-Tests, Greeter-Ladetest
  install.sh                     Ausschließlich Kopieren des Themes
tests/tst_theme.qml             Automatisierte Tests mit simuliertem SDDM
```

Position und Größe des Monitors werden in `Main.qml` gesetzt. `TerminalMonitor` nimmt beliebige QML-Inhalte auf. `LoginPanel` erhält Backend und Modelle als Eigenschaften und hängt nicht von der Monitorgeometrie ab.

`TerminalAnimation` stellt `target`, `animationEnabled`, `duration`, `running` und das Signal `ready` bereit. Aktuell meldet sie sofort Bereitschaft: keine Bewegung, Überblendung, Verzögerung oder endgültige Arm-/Monitorgrafik. Als zukünftiges Ziel erhält sie ausschließlich den Monitor, niemals den Hintergrund.

## Voraussetzungen

Geprüfte lokale Umgebung am 18.10.2026:

- EndeavourOS, SDDM **0.21.0-7**, ausführbares Programm `sddm-greeter-qt6`.
- Qt Base **6.12.0-3**, Qt Declarative **6.12.0-1**.
- QML-Module: **QtQuick**, **QtQuick.Controls.Basic**, **QtQuick.Layouts** und deren Qt-Abhängigkeiten.
- Für die automatisierten Tests zusätzlich **QtTest**, `qmltestrunner` und `qmllint` aus der Qt6-Installation; Bash und `timeout` für die Skripte.

Auf diesem System kommen die benötigten QML-Module aus `qt6-declarative`. Andere Distributionen können sie auf mehrere Pakete aufteilen. Das Theme nutzt weder KDE-spezifische Komponenten noch Qt5Compat, QtMultimedia, QtQuick.VirtualKeyboard oder die älteren SddmComponents. Nur PNG-Dateien werden benötigt; Qt SVG ist keine Theme-Abhängigkeit. Ältere Qt6-Versionen sind nicht geprüft; der verwendete gebundene QML-Komponentenkontext setzt Qt 6.4 oder neuer voraus.

Die Schnittstellen wurden mit den installierten Themes und dem [SDDM-0.21-Quelltext](https://github.com/sddm/sddm/tree/v0.21.0/src/greeter) abgeglichen. Weitere Informationen bietet die [offizielle Theming-Dokumentation](https://github.com/sddm/sddm/wiki/Theming).

## Konfiguration

`theme.conf` enthält:

```ini
[General]
AnimationEnabled=false
AnimationDuration=800
GreenColor=#66ff99
ShowUserPicture=true
```

| Einstellung | Bedeutung |
| --- | --- |
| `AnimationEnabled` | Für die spätere Animation reserviert; aktuell auch bei `true` keine Bewegung. |
| `AnimationDuration` | Vorbereitete Dauer in Millisekunden, Vorgabe 800; aktuell keine Wartezeit. |
| `GreenColor` | Qt-Farbwert für Schrift, Bedienelemente und Rahmen. Für gute Lesbarkeit einen hellen Grünton verwenden. |
| `ShowUserPicture` | `true` zeigt Profilbereich und Ersatzanzeige, `false` blendet den Profilbereich aus. Die Benutzerwahl bleibt verfügbar. |

Für lokale Anpassungen empfiehlt sich `theme.conf.user` mit einer `[General]`-Sektion und den abweichenden Werten. SDDM liest diese Übersteuerungen; das Installationsskript überschreibt diese Datei nicht. Änderungen werden beim nächsten Greeter-Start geladen.

## Testen

Im Repository, ohne Administratorrechte:

```bash
./scripts/test.sh
```

Das Skript startet ausschließlich `sddm-greeter-qt6 --test-mode --theme …`. Es startet keinen SDDM-Dienst und verändert keine Systemkonfiguration. Der Greeter kann die Vorschau bildschirmfüllend öffnen; zum Beenden im aufrufenden Terminal Strg+C verwenden.

Ohne sichtbares Fenster, einschließlich automatisierter Tests:

```bash
./scripts/check.sh
```

Falls die Qt-Werkzeuge anders installiert sind:

```bash
QT6_BIN_DIR=/pfad/zu/qt6/bin ./scripts/check.sh
```

Die Tests verwenden ein simuliertes Backend und ausschließlich erfundene Zugangsdaten. Sie erzeugen Prüfbilder unter `/tmp/cyber-lab-*.png`. Der anschließende Greeter-Ladetest verwendet die tatsächlich installierte SDDM-Version mit dem Offscreen- und Software-Renderer und beendet sie nach fünf Sekunden. Die dabei erwartete Meldung `Socket error: QLocalSocket::connectToServer: Invalid name` entsteht durch den fehlenden Daemon-Socket im Testmodus; sie ist kein QML-Ladefehler. Systemaktionen können in dieser Vorschau deaktiviert sein, und ein Anmeldeversuch kann ohne Daemon-Rückmeldung im Wartezustand bleiben. Die Vorschau dann neu starten.

### Tatsächlich durchgeführt

- `qmllint` für `Main.qml` und alle Komponenten: ohne Warnungen. Die vier von SDDM eingespeisten Kontextvariablen sind gezielt von der statischen Prüfung unqualifizierter Zugriffe ausgenommen und werden im echten Greeter geladen.
- Qt-Tests: **12 bestanden, 0 fehlgeschlagen** einschließlich Initialisierung und Aufräumen.
- Geprüft: Enter und Anmeldeschaltfläche, übergebene Zugangsdaten/Sitzung, Schutz vor doppelter Anmeldung, Fehleranzeige, geleertes Passwort und wiederhergestellter Fokus, Benutzer-/Sitzungswechsel, Profilbild und Ersatzanzeige, Systemaktionsaufrufe und deren Verfügbarkeit, leere Modelle.
- Geprüft: Fokusfolge und automatisches Scrollen bei 640×480; Layout bei **640×480, 800×600, 1280×720 und 1920×1080**; Hintergrund bleibt geladen und sichtbar; Aktivieren der vorbereiteten Animation bewegt nichts; Profilbereich lässt sich ausblenden.
- Gerenderte Prüfbilder visuell kontrolliert, insbesondere 640×480 und 1280×720.
- Echter SDDM-Greeter im Testmodus: Theme geladen, kein Rückfall auf das eingebettete Theme, keine QML-Lade-, Bindungs- oder Importfehler.
- Shell-Skripte mit `bash -n` geprüft.

**Eine erfolgreiche Vorschau ist keine geprüfte Systemanmeldung.** PAM-Authentifizierung, Start einer realen Desktop-Sitzung, tatsächliches Herunterfahren/Neustarten, Grafiktreiber im produktiven Greeter sowie Mehrmonitor- und HiDPI-Betrieb wurden nicht getestet. Die aktive SDDM-Konfiguration wurde weder geändert noch das Theme automatisch aktiviert.

## Installation

Erst prüfen, anschließend bei Bedarf ausdrücklich nur die Dateien kopieren:

```bash
./scripts/check.sh
sudo ./scripts/install.sh --copy-only
```

Das Skript installiert QML-Dateien, beide vorhandenen Bilder, Lizenz, Metadaten und `theme.conf` nach `/usr/share/sddm/themes/cyber-lab-sddm/` mit lesbaren Dateirechten. Eine erneute Ausführung aktualisiert diese Dateien. Es bearbeitet keine SDDM-Konfiguration, aktiviert kein Theme und startet keinen Dienst neu. **Die Installation wurde in dieser Entwicklungsrunde nicht ausgeführt.**

Die spätere Aktivierung erfolgt bewusst manuell, beispielsweise über die KDE-Systemeinstellungen für den SDDM-Anmeldebildschirm. Vor einer produktiven Nutzung ist eine gesonderte echte Anmeldung nötig. Dabei muss insbesondere geprüft werden, ob der Systembenutzer `sddm` die gewünschten Benutzerbilder lesen darf.

## Bekannte Einschränkungen und nächste Schritte

- Statischer Platzhalter; endgültige Grafiken und die Einschwenkanimation fehlen absichtlich.
- Standardanmeldung mit Benutzername und Passwort. Zusätzliche PAM-Dialoge wie Passwortwechsel oder mehrstufige Abfragen sind nicht implementiert.
- Es werden die von SDDM angebotenen Benutzer verwendet; keine freie Eingabe versteckter Konten.
- Deutsche Oberflächentexte; keine zusätzliche Sprachauswahl, Tastaturbelegungsauswahl oder Bildschirmtastatur.
- Bei sehr vielen Benutzern wird für jedes Profil ein Bildobjekt angelegt; geladen wird nur das ausgewählte Bild.
- Noch keine Prüfung unter einem produktiven SDDM-Daemon und keine Freigabe als vollständig systemgetestetes Release.

## Gestalterisches Zielbild

Das folgende freigegebene Vorschaubild zeigt die **spätere Gestaltung mit mechanischem Arm**, nicht den Funktionsumfang von Version 0.1.0. Die Metadaten verwenden dieses vorhandene Vorschaubild. Der aktuelle Monitor besteht ausschließlich aus einfachen QML-Rechtecken.

![Gestalterisches Zielbild mit Arm und Terminal](Assets/previews/final_terminal_preview.png)
