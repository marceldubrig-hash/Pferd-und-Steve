# MASTER SPEC — Pferd und Steve

Stand: 2026-09-27

## Kernidee

Bewusst simpel produzierter Mobile-Pferdesimulator/Tamagotchi. Der Spieler ist Farmer Steve und kümmert sich zunächst relativ normal um ein Pferd. Mit der Zeit wird die Welt immer merkwürdiger. Normalität und Langeweile bleiben wichtig, damit absurde Ereignisse stärker wirken.

## Humor

- trocken
- improvisiert wirkend
- absurde Non-Sequiturs
- unerwartete Richtungswechsel
- Anti-Punchlines
- unnötig konkrete Details
- gelegentliche Versprecher/Selbstkorrekturen
- Running Gags dürfen sehr spät zurückkehren
- keine kopierten Dialoge oder Figuren bestehender Werke

Vertonung zunächst vollständig auf Deutsch. Das Pferd wird vom Nutzer selbst gesprochen.

## Visueller Stil

### Farm
- gesättigter 2D-Comiclook
- flach, simpel, bunt
- bewusst grobe Cutout-/Cartoon-DNA

### Interaktive/bewegliche Objekte
- möglichst realistisch/fotorealistisch
- Pferd, Farmer Steve, Eimer, Futter, Werkzeuge etc.
- der Stilbruch Comic-Farm + reales PNG ist absichtlich Teil des Humors

## Farm-Canon

Zwei Hintergründe derselben Szene:
- Tag
- Nacht

Komposition:
- links große rote offene Scheune
- Mitte großer freier Hof/Paddock
- weißer Zaun und Landschaft im Hintergrund
- rechts offener Unterstand
- vorne viel freie Fläche
- hinten kleiner wirkende Spielfläche für Pseudo-3D

## Pseudo-3D

Reines 2D.

- weiter unten/vorne = größer
- weiter oben/hinten = kleiner
- grobe Zielwerte: vorne 115–130 %, Mitte 100 %, hinten 70–85 %
- später Y-basierte Z-Sortierung
- Schatten kann mitskalieren

## Pferd — verbindliche Regeln

- realistisches/fotorealistisches chestnut/braunes Pferd
- dunkle Mähne
- dunkler Schweif
- natürliche weiße Blesse
- genau eine Seitenperspektive
- RIGHT = Original
- LEFT = horizontal gespiegelt
- keine Front-, Rück- oder 3/4-Ansichten
- STEHEND ist die Master-Pose

### Rig

Grundteile:
- Körper
- fester oberer Kopf
- separater Unterkiefer
- separater Schweif
- 4 Beine mit je 3 Segmenten = 12 Beinsegmente

### Mund

Der Kopf wird NICHT quer durch Nase oder Schnauze geteilt.

Nur der Unterkiefer wird wie mit einer Bastelschere entlang der natürlichen Mundöffnung abgetrennt.

- Drehpunkt ungefähr am hinteren Mundwinkel
- Unterkiefer klappt nur hoch/runter
- absichtlich billige Puppenbewegung
- kein komplexes Lip-Sync
- leichte Unregelmäßigkeit beim Sprechen erwünscht

### Beine

- bewusst billige Cutout-Puppenanimation
- Segmentrotation statt realistischer Gangsimulation
- Pferd darf leicht gleiten/wackeln
- Anatomie bleibt vollständig; keine fehlenden Gliedmaßen
- keine AAA-Animation

### Kopfbewegung

Der komplette ausgeschnittene Kopf darf leicht hoch/runter rotieren.
Es ist nicht wichtig, dass die Bewegung elegant aussieht; der primitive Sticker-/Bastelcharakter ist gewünscht.

## Fertige Assets

- farm_day_v01.png
- farm_night_v01.png
- horse_master_standing_v01.png
- horse_head_upper_v01.png
- horse_jaw_v01.png
- horse_head_talk_halfopen_preview_v01.png
- horse_head_talk_open_preview_v01.png
- horse_body_v01.png
- horse_tail_v01.png
- horse_front_legs_segments_sheet_v01.png
- horse_hind_legs_segments_sheet_v01.png

## Offene Assets / später

- einzelne 12 Beinsegmente bei Bedarf aus den Segment-Sheets exportieren
- Schlafpose
- eventuell Fresspose
- eventuell Trinkpose
- Farmer Steve
- interaktive Gegenstände

## Verworfene Varianten

- kompletter Schnitt quer durch die Schnauze
- bewegter halber Kopf
- zusätzliche Kopf-Perspektiven
- anatomisch komplexe Mundanimation
- große überladene Asset-Sheets als Hauptworkflow
- realistischer/aufwendiger Pferdegang

## Technischer Implementierungsstand

Stand auf `main`:
- minimales Godot-4-Projekt (`project.godot`) angelegt
- `scenes/main.tscn` als Einstiegsszene angelegt
- `scripts/main.gd` angelegt
- Einstiegsszene in `project.godot` registriert
- Testcontroller kennt bereits die verbindlichen Runtime-Pfade für Tag-Farm, Nacht-Farm und Master-Pferd
- horizontales Spiegeln des Master-Pferds ist als RIGHT = Original / LEFT = Flip vorbereitet
- Y-basierte Skalierung ist mit 70 % hinten bis 130 % vorne vorbereitet
- fehlende Runtime-Bilder führen nur zu Warnungen und nicht zu einem absichtlichen Neudesign

Die bestätigten Binär-Assets liegen derzeit weiterhin in versionierten ZIP-Paketen unter `asset_packs/`. Sie sind noch nicht als einzelne PNG-Dateien in die verbindlichen `assets/...`-Runtime-Pfade entpackt.

## Technischer Test-Meilenstein — erster Android-Build

Erreicht am 2026-09-27:

- Canon-Assets wurden aus dem bereits bestätigten Runtime-Paket in die echten Runtime-Pfade übernommen:
  - `assets/backgrounds/farm_day_v01.png`
  - `assets/backgrounds/farm_night_v01.png`
  - `assets/horse/horse_master_standing_v01.png`
- Die WebP-Quellen aus dem Paket wurden ohne Neugenerierung in PNG konvertiert.
- Die minimale Farm-Szene lädt die Tag-Farm und das Master-Pferd.
- Touch-/Maus-Drag bewegt das Pferd auf dem Hof.
- Bewegungsrichtung spiegelt das Pferd horizontal; RIGHT bleibt das Original.
- Die Y-Position steuert die Größe und Z-Reihenfolge für den Pseudo-3D-Effekt.
- Godot 4.3 hat das Projekt headless erfolgreich importiert und validiert.
- Für Android wurde ETC2/ASTC-Import aktiviert, damit der Headless-Android-Export auf Linux korrekt validiert.
- Ein signiertes Android-Debug-APK wurde erfolgreich gebaut und als CI-Artefakt erzeugt.
- Erfolgreicher Build-Run: `36324391689`
- Build-Basis: Commit `62e333994784883b989fb30ef0b9ebe39733f99c`
- Lokaler Prüfsummenwert des heruntergeladenen Test-APK: `SHA-256 3e59b18f166e88be0853922115230080f3ab1f2ed6590e8262440d878c99ee4a`
- APK-Archivprüfung: keine ZIP-/Kompressionsfehler; die drei Canon-Texturen und die Hauptszene sind im APK enthalten.

## Aktuell nächste technische Aufgabe

Zuerst den ersten Android-Build auf dem realen Testgerät prüfen. Dabei ausschließlich diese Basisfunktionen kontrollieren:

1. App startet ohne Absturz.
2. Tag-Farm wird korrekt dargestellt.
3. Master-Pferd steht sichtbar auf dem Hof.
4. Touch/Drag bewegt das Pferd.
5. Beim Wechsel nach links/rechts wird nur horizontal gespiegelt.
6. Beim Verschieben nach oben/unten wird das Pferd plausibel kleiner/größer.

Erst wenn diese Basis bestätigt oder gezielt korrigiert wurde, wird das eigentliche Cutout-Rig aus Kopf, Unterkiefer, Schweif und Beinsegmenten eingebaut.
