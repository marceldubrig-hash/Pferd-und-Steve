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
- separate Rig-Testszene `scenes/horse_cutout_rig.tscn` angelegt; Farm-/Perspektivsystem bleibt dabei unangetastet
- erster Cutout-Baustein ist implementiert und getestet: bestätigter Körper + oberer Kopf + Unterkiefer sind als unveränderte Runtime-Texturen eingebunden, statisch ausgerichtet und über getrennte Head-/Jaw-Pivots vorbereitet
- bestätigter Schweif ist ebenfalls implementiert und getestet; `TailPivot` sitzt am Schweifansatz, der Schweif liegt hinter dem Körper
- erstes vollständiges Bein ist implementiert und getestet: linke Front-Sheet-Kette = `FrontNear`, als `Upper → LowerPivot → Lower → HoofPivot → Hoof`; die übrigen drei Beine bleiben untexturiert

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

## Rig-Asset-Meilenstein — Canon wiederhergestellt

Erreicht am 2026-09-27:

- Recovery-Paket liegt unverändert auf `main`:
  - `asset_packs/Pferd-und-Steve-source-rig-missing-v01.zip`
  - Upload-Commit: `bea7227181fd2eafc1d64b15d3bd87ff2c9c4d65`
- Rig-Source-Audit lief danach erfolgreich:
  - Run `36328975035`
  - Ergebnis: **success**
- Ein fail-closed Materializer wurde hinzugefügt:
  - `tools/materialize_verified_rig_assets.py`
  - prüft die sechs Recovery-Dateien gegen die festgeschriebenen SHA-256-Werte
  - schreibt nur exakte Originalbytes und überschreibt niemals abweichende bestehende Dateien
- Materializer-Workflow:
  - Run `36329092128`
  - Ergebnis: **success**
- Acht bestätigte Rig-Dateien liegen nun unverändert unter `assets/horse/rig/`:
  - `horse_body_v01.png`
  - `horse_tail_v01.png`
  - `horse_head_upper_v01.png`
  - `horse_jaw_v01.png`
  - `horse_head_talk_halfopen_preview_v01.png`
  - `horse_head_talk_open_preview_v01.png`
  - `horse_front_legs_segments_sheet_v01.png`
  - `horse_hind_legs_segments_sheet_v01.png`
- Materialisierungs-Commit: `c2fb613e987636b74877b2913d202544a8fa135d`

## Rig-Meilenstein — Körper + oberer Kopf + Unterkiefer

Erreicht am 2026-09-27:

- Ausschließlich die drei bestätigten Runtime-Assets wurden verwendet:
  - `assets/horse/rig/horse_body_v01.png`
  - `assets/horse/rig/horse_head_upper_v01.png`
  - `assets/horse/rig/horse_jaw_v01.png`
- Die PNG-Dateien wurden nicht verändert, neu encodiert oder ersetzt. Die gesamte Ausrichtung liegt ausschließlich in Godot-Node-Transforms.
- Die statische Ausrichtung wurde gegen die bestätigte 1448×1086-Master-Pose kalibriert; der Rig-Root verwendet dabei deren Bildmitte als lokalen Referenznullpunkt.
- Body:
  - Position: `(-76.5412, -101.756)`
  - Rotation: `0.0239099 rad` ≈ `1.36994°`
  - Scale: `0.695201`
- HeadPivot:
  - Position: `(321.171, -194.253)`
  - Rotation: `-0.00592869 rad` ≈ `-0.339689°`
  - Scale: `0.42439`
  - Halsansatz entspricht ungefähr Quellkoordinate `(250, 900)` im 1122×1402-Head-Asset.
- HeadUpper:
  - lokaler Offset: `(311, -199)`
  - relativer `z_index = 1`
- JawPivot:
  - lokaler Pivot-Offset unter HeadPivot: `(340, -110)`
  - entspricht ungefähr dem hinteren Mundwinkel bei Head-Quellkoordinate `(590, 790)`
  - Ruhe-Rotation: `-0.244346 rad` = `-14°`
- Jaw:
  - lokaler Offset: `(260.624, 174.613)`
  - Asset-Ausrichtungsrotation: `0.0299578 rad` ≈ `1.71645°`
  - Scale relativ zu HeadPivot: `0.27589`
- Layering:
  - Body bleibt auf Basis-Z
  - HeadPivot liegt bei `z_index = 10`
  - HeadUpper liegt relativ eine Ebene über dem Jaw, damit der hochgeklappte Unterkiefer sauber hinter der festen oberen Kopfform verschwinden kann
- Noch **nicht** integriert: Beine, Laufanimation, Sprachsystem, Farm-Integration.
- Scene-Commit: `eb7188ad112214b8e4557ff9275f6be02a80382b`
- Godot-4.3-Headless-Validierung: Run `36330114083` — **success**
- Automatischer Android-Debug-Build derselben Commit-Basis: Run `36330114109` — **success**

## Rig-Meilenstein — Schweif + TailPivot

Erreicht am 2026-09-27:

- Ausschließlich das bestätigte Runtime-Asset wurde verwendet:
  - `assets/horse/rig/horse_tail_v01.png`
- Das verwendete Schweif-Original wurde vor der Ausrichtung erneut gegen den festgeschriebenen SHA-256 geprüft:
  - `b608633b49b8cf6eb3dd612cf2482d9b482c4bfc7d8a72dbf9a4ecb1c7d58fe1`
- Das PNG wurde nicht verändert, neu encodiert, beschnitten oder ersetzt. Die gesamte Ausrichtung liegt ausschließlich in Godot-Node-Transforms.
- Die statische Ausrichtung wurde gegen die bestätigte Master-Pose kalibriert.
- TailPivot:
  - Position im Rig-Root: `(-449, -198)`
  - entspricht ungefähr dem Schweifansatz/Dock der Master-Pose
  - `z_index = -1`, damit der Schweif hinter dem Körper liegt und der Ansatz sauber vom Rumpf verdeckt wird
- Tail:
  - lokaler Offset relativ zu TailPivot: `(-102.18, 270.66)`
  - Scale: `0.39`
  - keine Ruhe-Rotation; `TailPivot` bleibt damit für eine spätere primitive Schweifrotation vorbereitet
- Referenzpunkt im 1086×1448-Quellasset für den Pivot liegt ungefähr bei `(805, 30)`.
- Die LEFT/RIGHT-Regel bleibt unverändert: später wird das **gesamte Rig** gespiegelt; der Schweif benötigt keine eigene Spiegelungslogik.
- Noch **nicht** integriert: Beine, Laufanimation, Sprachsystem, Farm-Integration.
- Scene-Commit: `df1f778f218b50ca2aa0db226a3a78bbe4d5d056`
- Godot-4.3-Headless-Validierung: Run `36330979600` — **success**
- Automatischer Android-Debug-Build derselben Commit-Basis: Run `36330979638` — **success**

## Rig-Meilenstein — Bein-Segment-Sheets technisch verifiziert

Erreicht am 2026-09-27:

- Detaildokumentation: `docs/HORSE_LEG_RIG.md`
- beide bestätigten Sheets sind native `1122×1402`-RGBA-PNGs
- Front-Sheet SHA-256: `21003a4575973514be9f1508e828c0f90c2f0d12f3f519188b4e1b495eb96e8a`
- Hind-Sheet SHA-256: `d24aba84e51075cdd1e5c83d12432d2d7a1731c8c9bbb522c2db731bc04744e3`
- die Hashes stimmen mit den bereits gepinnten Materializer-Werten überein
- jedes Sheet enthält exakt zwei vollständige 3-Segment-Ketten: Upper + Lower + Hoof
- die beiden Varianten pro Sheet sind echte unterschiedliche Formen/Texturen und werden nicht durch segmentweises Spiegeln ersetzt
- robuste Segmentboxen und Pivot-Ankerkandidaten wurden pixelbasiert dokumentiert
- wichtiges Alpha-Artefakt: beim Hind-Sheet können extrem schwache Alpha-Reste bei `alpha > 0` Upper und Lower scheinbar verbinden; ab `alpha >= 4` werden stabil sechs große Segmente erkannt
- die Near/Far-Semantik der linken/rechten Sheet-Spalten ist in den Quelldateien nicht beschriftet und wird deshalb noch **nicht** geraten oder als Canon festgeschrieben
- verfeinerter Analyse-Run `36331705192`: **success**
- keine Runtime-Szene und kein Asset wurde in diesem Analyseschritt verändert

## Rig-Meilenstein — erstes vollständiges FrontNear-Bein

Erreicht am 2026-09-27:

- ausschließlich die bestätigte linke Kette aus `horse_front_legs_segments_sheet_v01.png` wurde verwendet
- keine Einzel-PNGs wurden erzeugt; die drei Segmente werden verlustfrei per `AtlasTexture` direkt aus dem unveränderten Sheet gelesen
- Front-Sheet SHA-256 bleibt `21003a4575973514be9f1508e828c0f90c2f0d12f3f519188b4e1b495eb96e8a`
- der kontrollierte Vor-/Hinter-Body-Vergleich bestätigt die linke Front-Sheet-Spalte als `FrontNear`
- `FrontNear`: Position `(155, -53)`, Scale `0.5`, `z_index = 1`
- Upper: Offset `(-19.75, 275.924)`
- LowerPivot: `(-33.065, 274.582)`
- Lower: Offset `(-3.209, 148.182)`
- HoofPivot: `(-21.145, 149.993)`
- Hoof: Offset `(67.359, 138.418)`
- Detaildokumentation: `docs/HORSE_LEG_RIG.md`
- Parent-Pfad-Korrektur: `b1b86e94d2c9f9e8d320bddbfc7142ca7e0e2639`
- finale Verifikationsbasis: `efba8db681ad6ab575ebeced78f8e968fa6c9536`
- Godot 4.3 Headless: **success**
- Android Debug Export: **success**
- Validierungs-Commit: `9971aceae4f80023ac630f36bbebd066eeefc6a4`
- Test-APK SHA-256: `5a8c519bdfe87fde09ba64b90f0975b81167549018b2468d112de017105493b5`
- keine Animation und keine Farm-Integration begonnen

## Aktuell nächste technische Aufgabe

Die bestätigte Farm-/Perspektivgrundlage bleibt unverändert.

Die statischen Cutout-Bausteine **Körper + oberer Kopf + Unterkiefer + Schweif + FrontNear-Bein** sind abgeschlossen und getestet. Die FrontNear-Kette besteht vollständig aus drei Segmenten und ist gegen die Master-Pose kontrolliert.

Als nächster Schritt folgt **Schritt 5: Übertragung auf die übrigen drei Beine**. Dieser Schritt wurde bewusst noch nicht begonnen.
