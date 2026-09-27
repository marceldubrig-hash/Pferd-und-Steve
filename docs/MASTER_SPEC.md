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

Reines 2D mit perspektivischer Projektion.

- weiter unten/vorne = deutlich größer
- weiter oben/hinten = kleiner, aber weiterhin klar lesbar
- Größe wird nicht mehr linear geschätzt, sondern aus einer kalibrierten 1/Z-Perspektive abgeleitet
- Huf-/Bodenkontakt ist der vertikale Sprite-Anker
- direkt vor der Kamera darf der Hufpunkt unterhalb des Viewports liegen; dadurch bleiben nur Kopf/Hals/Oberkörper sichtbar
- Y-basierte Z-Sortierung ist aktiv
- die hintere begehbare Bodengrenze ist ortsabhängig: Heuballen links und rechter Unterstand drücken das Pferd nach vorne, statt es optisch auf Hindernissen stehen zu lassen
- Details siehe `docs/PERSPECTIVE_MODEL.md`
- Schatten kann später mitskalieren

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
- Canon-Tagfarm, Canon-Nachtfarm und Master-Pferd liegen in den echten `assets/...`-Runtime-Pfaden
- horizontales Spiegeln des Master-Pferds ist als RIGHT = Original / LEFT = Flip aktiv
- Hufpunkt statt Bildmitte ist der Bodenanker
- perspektivische 1/Z-Skalierung ist aktiv und auf den realen Fold-Screenshot kalibriert
- extreme Kameranähe schneidet Unterkörper/Beine natürlich am unteren Viewport ab
- die hintere Bodenlinie ist als physische, X-abhängige Laufgrenze modelliert
- Heuballen links und rechter Unterstand/Balken können nicht mehr optisch als schwebende Standfläche benutzt werden
- Godot-4.3-Headless-Validierung läuft in GitHub Actions
- Android-Debug-APK wird automatisiert gebaut

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

## Test-Meilenstein — Perspektive und physische Hofgrenzen

Vom Nutzer auf dem Fold bestätigt:

- Nah-/Fernskalierung wirkt jetzt überzeugend.
- Sehr nah an der Kamera ist die massive Vordergrunddarstellung ausdrücklich erwünscht.
- Die Größe im hinteren Hofbereich ist passend.
- Problem aus dem Gerätetest: an Heuballen links und am rechten Unterstand/Balken konnte das Pferd noch optisch schweben.

Korrektur abgeschlossen:

- offene hintere Hoffläche bleibt bei ca. `y = 0,565 × Bildschirmhöhe`
- Heuballen- und Unterstandgrenzen wurden aus den ausgewählten 1536×1384-Testbildern auf ca. `y = 0,585 × Bildschirmhöhe` kalibriert
- zu den äußeren Bildrändern läuft die Grenze weich bis ca. `0,600` nach vorne
- unerlaubte Zielpunkte werden auf den nächstliegenden legalen Bodenpunkt vor dem Hindernis projiziert
- Godot-Validierung: erfolgreich
- Android-Build-Run `36325845081`: erfolgreich
- Code-Basis der Grenzkorrektur: `d5d3ff9ca32968f035d304176668eb2a326578ad`

## Aktuell nächste technische Aufgabe

Den neuen Grenz-Build auf dem Fold nur an den kritischen Stellen prüfen:

1. direkt vor den Heuballen links
2. am linken Scheunenrand
3. vor dem rechten Unterstand/Balken
4. vom freien hinteren Hof seitlich in diese Bereiche ziehen

Wenn dort kein Schweben/Stehen auf Objekten mehr auftritt, ist die Grundbewegung der Farm bestätigt. Danach beginnt als nächster abgeschlossener Schritt das eigentliche Cutout-Rig aus Körper, oberem Kopf, Unterkiefer, Schweif und Beinsegmenten.
