# MASTER SPEC — Pferd und Steve

Stand: 2026-09-28

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
- das sichtbare Farm-Pferd ist das vollständige Cutout-Rig; RIGHT = Original und LEFT = Spiegelung des gesamten äußeren `HorseVisual`-Containers
- Hufpunkt statt Bildmitte ist der Bodenanker
- perspektivische 1/Z-Skalierung ist aktiv und auf den realen Fold-Screenshot kalibriert
- extreme Kameranähe schneidet Unterkörper/Beine natürlich am unteren Viewport ab
- die hintere Bodenlinie ist als physische, X-abhängige Laufgrenze modelliert
- Heuballen links und rechter Unterstand/Balken können nicht mehr optisch als schwebende Standfläche benutzt werden
- Godot-4.3-Headless-Validierung läuft in GitHub Actions
- Android-Debug-APK wird automatisiert gebaut
- `scenes/horse_cutout_rig.tscn` ist als PackedScene in die Farm integriert; das bestehende Farm-/Perspektivsystem bleibt dabei mathematisch unverändert
- Körper, oberer Kopf, Unterkiefer und Schweif sind aus den unveränderten bestätigten Runtime-Assets statisch montiert
- alle vier Beine sind vollständig als `Upper → LowerPivot → Lower → HoofPivot → Hoof` montiert; insgesamt sind damit alle 12 Beinsegmente angebunden
- vollständige statische Pferdefigur wurde in Schritt 6 gegen die Master-Pose geprüft; einzige nötige Transformkorrektur war die Ruhe-Rotation von `JawPivot` von ursprünglich `-14°` über einen kontrollierten Zwischenstand `-17°` auf final `-19°`
- Body, Tail, HeadPivot/HeadUpper sowie alle vier Bein-Roots, Pivotwerte, Scales und Layer blieben in Schritt 6 unverändert
- minimaler Jaw-Test, minimale HeadPivot-Kopfrotation, primitive TailPivot-Schweifrotation und erster bewusst billiger Walk-Test laufen jetzt im integrierten Farm-Rig; Bodenanker, Perspektive, LEFT/RIGHT, Drag/Touch, Hindernisgrenzen und World-Z sind validiert

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

## Rig-Meilenstein — beide Vorderbeine vollständig

Erreicht am 2026-09-27:

- `FrontNear` und `FrontFar` sind als vollständige 3-Segment-Ketten montiert
- beide Ketten verwenden verlustfrei `AtlasTexture` direkt aus dem unveränderten bestätigten Front-Sheet
- Front-Sheet SHA-256 bleibt `21003a4575973514be9f1508e828c0f90c2f0d12f3f519188b4e1b495eb96e8a`
- `FrontFar`: Position `(247, -53)`, Scale `0.5`, `z_index = -1`
- FrontFar Upper: Offset `(28.522, 268.645)`
- FrontFar LowerPivot: `(-25.791, 269.543)`
- FrontFar Lower: Offset `(0.943, 138.502)`
- FrontFar HoofPivot: `(4.488, 140.352)`
- FrontFar Hoof: Offset `(41.127, 131.459)`
- kontrollierter Master-Vergleich bestätigt die statische Standpose
- Godot 4.3 Headless: **success**
- Android Debug Export: **success**
- Validierungs-Commit: `eeb764fca324e009efe5fe4012c3d568106bfb28`
- Test-APK SHA-256: `94bc4edc898cc33dd102a0cfd272be823794468de2da4f93037b310be4b69710`
- beide Hinterbeine bleiben weiterhin untexturiert
- keine Animation und keine Farm-Integration begonnen

## Rig-Meilenstein — drei von vier Beinen vollständig

Erreicht am 2026-09-27:

- `FrontNear`, `FrontFar` und `HindNear` sind vollständig als 3-Segment-Ketten montiert
- linke Hind-Sheet-Spalte ist nach kontrolliertem Layervergleich als `HindNear` bestätigt
- Hind-Sheet SHA-256 bleibt `d24aba84e51075cdd1e5c83d12432d2d7a1731c8c9bbb522c2db731bc04744e3`
- `HindNear`: Position `(-446, -74)`, Scale `0.5`, `z_index = 1`
- HindNear Upper: Offset `(-20.816, 234.353)`
- HindNear LowerPivot: `(-36.101, 235.597)`
- HindNear Lower: Offset `(-13.638, 163.241)`
- HindNear HoofPivot: `(-34.745, 160.511)`
- HindNear Hoof: Offset `(49.841, 181.998)`
- Parent-Pfad-Korrektur: `6e282810862492afb8067ba3b3b20539b660f65c`
- Godot 4.3 Headless: **success**
- Android Debug Export: **success**
- Test-APK SHA-256: `8b13955688527e79fb3483847694476cbc3c9b825d64a36f142bfa99e44c34f9`
- `HindFar` bleibt als einziges Bein untexturiert
- keine Animation und keine Farm-Integration begonnen

## Rig-Meilenstein — alle vier Beine vollständig

Erreicht am 2026-09-27:

- alle vier Beine sind als vollständige 3-Segment-Ketten montiert
- insgesamt sind damit alle **12 Beinsegmente** im Cutout-Rig angebunden
- Front-Sheet: linke Spalte = `FrontNear`, rechte Spalte = `FrontFar`
- Hind-Sheet: linke Spalte = `HindNear`, rechte Spalte = `HindFar`
- Near-Beine liegen mit `z_index = 1` vor dem Body
- Far-Beine liegen mit `z_index = -1` hinter dem Body
- keine Beinsegmente wurden gespiegelt oder neu gerendert
- alle Segmente verwenden `AtlasTexture` direkt aus den unveränderten bestätigten Sheets
- `HindFar` final: Position `(-262, -77)`, Scale `0.5`, `z_index = -1`
- HindFar Upper: Offset `(32.071, 233.122)`
- HindFar LowerPivot: `(7.159, 219.652)`
- HindFar Lower: Offset `(38.005, 165.058)`
- HindFar HoofPivot: `(31.74, 160.626)`
- HindFar Hoof: Offset `(-49.206, 182.544)`
- eine transparente Upper/Lower-Lücke bei HindFar wurde ausschließlich durch Pivot-/Root-Überlappung korrigiert; Quellbilder blieben unverändert
- finaler Vier-Bein-Mastervergleich: plausibel und ohne sichtbare transparente Gelenklücke
- Godot 4.3 Headless: **success**
- Android Debug Export: **success**
- Validierungs-Commit: `04c9a06b69147845727d47a58b3c12c7cb50aeaa`
- Test-APK SHA-256: `eda1d08a2f3fad3011109d0322d4c122c035b4d4e9ff7c143063656dace7fd0c`
- keine Walk-Animation und keine Farm-Integration begonnen
- Detaildokumentation: `docs/HORSE_LEG_RIG.md`

## Rig-Meilenstein — vollständige statische Pferdefigur validiert

Abgeschlossen am 2026-09-27.

### Geprüfter Umfang

Der vollständige Stand von `scenes/horse_cutout_rig.tscn` wurde gemeinsam gegen die bestätigte Master-Pose geprüft:

- Body
- Tail
- HeadUpper
- Jaw in Ruhepose
- FrontNear
- FrontFar
- HindNear
- HindFar
- vier Hufhöhen
- horizontale Beinabstände
- Near/Far-Layering
- Übergänge Upper → Lower → Hoof
- Hals-/Kopfanschluss
- Schweifansatz

Der Vergleich wurde aus der echten TSCN erzeugt; die temporäre Preview parste die Scene-Transforms direkt statt die Rig-Werte separat nachzubauen. Vor jedem Preview-Lauf wurde der fail-closed Rig-Materializer ausgeführt. Asset-Integrität blieb erfolgreich.

### Einzige statische Korrektur in Schritt 6

Im vollständigen Vergleich stand der Unterkiefer in Ruhe sichtbar etwas zu offen gegenüber der Master-Pose.

Nur `JawPivot.rotation` wurde verändert:

- vorher: `-0.244346 rad` = ca. `-14°`
- kontrollierter Zwischenstand: `-0.296706 rad` = ca. `-17°`
- final: `-0.331613 rad` = ca. `-19°`

Commits:

- `5e9b6f9f6687f4d06e5781f557eea5c2a5bfb7a5` — erster Jaw-Ruhekorrekturversuch auf `-17°`
- `dd94c868e9b36a7196012b5ce736702d76fc961b` — finaler Jaw-Ruhewert `-19°`

Der `-17°`-Zwischenstand wurde absichtlich nicht stillschweigend überschrieben; er bleibt als dokumentierter kontrollierter Korrekturversuch im Commit-Verlauf erhalten.

### Unveränderte bestätigte Transforms

In Schritt 6 wurden **nicht** verändert:

- Body: Position `(-76.5412, -101.756)`, Rotation `0.0239099 rad`, Scale `0.695201`
- TailPivot: Position `(-449, -198)`, `z_index = -1`
- Tail: Offset `(-102.18, 270.66)`, Scale `0.39`
- HeadPivot: Position `(321.171, -194.253)`, Rotation `-0.00592869 rad`, Scale `0.42439`, `z_index = 10`
- HeadUpper: Offset `(311, -199)`, relativer `z_index = 1`
- JawPivot Position: `(340, -110)`
- Jaw: Offset `(260.624, 174.613)`, Rotation `0.0299578 rad`, Scale `0.27589`
- FrontNear inklusive aller drei Segment-/Pivotwerte
- FrontFar inklusive aller drei Segment-/Pivotwerte
- HindNear inklusive aller drei Segment-/Pivotwerte
- HindFar inklusive finalem `LowerPivot (7.159, 219.652)` und Root `(-262, -77)`
- Near/Far-Layering: Near `z_index = 1`, Far `z_index = -1`

Nach der Jaw-Korrektur war kein zweiter sichtbar störender Fehler stark genug, um einen bereits bestätigten Transform anzufassen. Der bewusste Cutout-/Stickercharakter bleibt erhalten.

`docs/HORSE_LEG_RIG.md` musste nicht geändert werden, weil in Schritt 6 kein Beinwert verändert wurde.

### Finale technische Validierung

Temporärer vollständiger Vergleich:

- finaler Scene-Commit: `dd94c868e9b36a7196012b5ce736702d76fc961b`
- Preview-/Headless-Nachweis: Commit `f9b62b8db2384b9937de0418de824d3eeff2b0ee`
- Godot 4.3 Headless: **success**
- Asset-Integrität: **success**

Finale Android-Prüfung:

- Validierungsbasis: `1303fe7500d46ba67aa5459aa037f6ad92370bcb`
- Ergebnis-Commit: `8ce3f810b9cf770d7b25fb8a2d8bd02dd93408bd`
- Godot 4.3 Headless: **success**
- Android Debug Export: **success**
- APK SHA-256: `78ca4078c154854c9daed1aef82e9ff3d13ccd44ffe9cae0f9ed68f9fab3d0b5`

Damit ist **Schritt 6 abgeschlossen**. Es wurde keine Jaw-Animation, Kopfanimation, Schweifanimation, Walk-Animation oder Farm-Integration begonnen.

## Rig-Meilenstein — minimaler Jaw-Test

Abgeschlossen am 2026-09-27.

### Ziel

Der Unterkiefer soll ausschließlich über den bereits bestätigten `JawPivot` bewusst billig hoch/runter klappen. Keine neue Kopf-Perspektive, keine Bildbearbeitung, kein Lip-Sync-System und keine Farm-Integration.

### Implementierung

In `scenes/horse_cutout_rig.tscn` wurde ein eigener `AnimationPlayer` ergänzt.

Animation:

- Name: `jaw_test`
- Autoplay: aktiv
- Loop: aktiv
- Länge: `0.6 s`
- Track: `HeadPivot/JawPivot:rotation`
- Interpolation: einfache lineare Value-Interpolation
- Ruheposition bleibt unverändert bei `-0.331613 rad` ≈ `-19°`

Finale Keyframes:

- `0.00 s` → `-19°` Ruhe
- `0.15 s` → `-9°` Hauptöffnung
- `0.30 s` → `-19°` Ruhe
- `0.42 s` → `-13°` kleinere zweite Öffnung
- `0.60 s` → `-19°` Ruhe

Dadurch entsteht absichtlich eine leicht ungleichmäßige, primitive Puppen-Sprechbewegung.

Zusätzlich existiert eine `RESET`-Animation, die ausschließlich die bestätigte Ruhe-Rotation `-0.331613 rad` setzt.

### Kontrollierter Korrekturversuch

Erster Test:

- Ruhe: `-19°`
- Hauptöffnung: `-7°`
- zweite Öffnung: `-10°`
- Commit: `352f7478d1e588ddec3a808405466fa19e94a8a2`
- erster visueller Nachweis: `7530bd4df4b38a9aac494a64aacb99e103864e89`

Die `-7°`-Öffnung wirkte im Nahvergleich sichtbar zu weit und ließ den Unterkiefer eher ausgerenkt als billig-puppig erscheinen.

Deshalb wurde ausschließlich der Öffnungsbereich verkleinert:

- Hauptöffnung final: `-9°` / `-0.15708 rad`
- zweite Öffnung final: `-13°` / `-0.226893 rad`
- Korrektur-Commit: `a33f2701c9200230c0610d6b4dab5a20832c85e5`

Der temporäre Preview-Workflow hatte danach zunächst noch alte Winkelbeschriftungen; ausschließlich diese Prüfbeschriftung wurde mit Commit `9e18d1855a84d8ed8945297b81f286a48d448b90` korrigiert. Der finale visuelle Nachweis liegt im temporären Ergebnis-Commit `8dad80d1009b0390cb7a5e5a18d697c097479596`.

### Unverändert

Schritt 7 verändert ausschließlich die Jaw-Animation.

Unverändert bleiben insbesondere:

- `JawPivot.position = (340, -110)`
- statische Jaw-Ruhe-Rotation `-0.331613 rad`
- Jaw-Asset-Offset, -Rotation und -Scale
- HeadPivot und HeadUpper
- Body
- Tail
- alle vier Beine und alle zwölf Beinsegmente
- sämtliche Near/Far-Layer
- Farm-/Perspektivsystem
- `scripts/main.gd`

Keine Textur wurde neu generiert, neu encodiert, zugeschnitten oder ersetzt.

### Finale technische Validierung

Finaler Lauf:

- Workflow-Basis: `cbf9e4b071874e0e95334e992c81d417304f0987`
- Ergebnis-Commit: `d442fe93b576526708926517892acb94473f6ed0`
- Asset-Integrität: **success**
- Godot 4.3 Headless: **success**
- Runtime-Check der geladenen `horse_cutout_rig.tscn`: **success**
- `AnimationPlayer`: gefunden
- `jaw_test`: gefunden
- Autoplay `jaw_test`: bestätigt
- Rotation-Track `HeadPivot/JawPivot:rotation`: bestätigt
- alle fünf Keyframe-Zeiten und Winkelwerte: bestätigt
- Android Debug Export: **success**
- APK SHA-256: `a72eccd7942f70db81da71113656c6906d0668c01d7df02d7948868440fd49de`

Damit ist **Schritt 7 abgeschlossen**.

Es wurde ausdrücklich **keine** Kopfanimation, Schweifanimation, Walk-Animation oder Farm-Integration begonnen.

## Rig-Meilenstein — minimale Kopfrotation

Abgeschlossen am 2026-09-27.

### Ziel

Der komplette bereits ausgeschnittene Kopf soll ausschließlich über `HeadPivot.rotation` leicht hoch/runter wackeln. Die Bewegung bleibt bewusst simpel und puppig. Es wurde kein Neck-Rig, keine IK, keine neue Perspektive und keine Asset-Bearbeitung eingeführt.

### Ausgangszustand

Vor Schritt 8 wurde GitHub `main` direkt geprüft:

- Ausgangs-HEAD: `1be8af6c8e902adcc60f549e45c2da4a609e8a1e`
- der Übergabeanker war damit exakt aktuell; keine späteren Runtime-Änderungen lagen vor
- statische HeadPivot-Ruhe-Rotation: `-0.00592869 rad` ≈ `-0.339689°`
- Step-7-Jaw-Track blieb exakt bei:
  - Zeiten: `0.00 / 0.15 / 0.30 / 0.42 / 0.60 s`
  - Werte: `-0.331613 / -0.15708 / -0.331613 / -0.226893 / -0.331613 rad`
  - entsprechend ungefähr `-19° / -9° / -19° / -13° / -19°`

### Erster getesteter und finaler Bewegungsbereich

Der erste Test verwendete einen symmetrischen Ausschlag von ungefähr `±3°` relativ zur bestätigten Ruheposition.

Finale HeadPivot-Keyframes innerhalb der bestehenden `jaw_test`-Animation:

- `0.00 s` → `-0.00592869 rad` ≈ `-0.339689°` — Ruhe
- `0.18 s` → `-0.05828857 rad` ≈ `-3.339689°` — Kopf leicht hoch
- `0.38 s` → `0.04643119 rad` ≈ `+2.660311°` — Kopf leicht runter
- `0.60 s` → `-0.00592869 rad` ≈ `-0.339689°` — Ruhe

Animationslänge bleibt `0.6 s`, Loop bleibt aktiv und Autoplay bleibt `jaw_test`.

Der Head-Track wurde als zweiter Value-Track in die bereits laufende `jaw_test`-Animation aufgenommen. Dadurch läuft die Step-7-Unterkieferbewegung parallel weiter, ohne ihre fünf Zeiten oder Rotationswerte zu verändern.

Die `RESET`-Animation setzt zusätzlich `HeadPivot.rotation` wieder exakt auf `-0.00592869 rad`.

### Visuelle Prüfung

Temporärer Preview-Workflow:

- Workflow-Commit: `5327cd314366e5bdc001a66d612d496bf529e31c`
- Preview-Ergebnis: `a847becc8081aae6a3ed855f53a885acdf76d458`
- Preview-Run: `36349188668` — **success**
- Asset-Integrität: **success**
- Vergleich zeigte Ruhe, Kopf hoch und Kopf runter; der Unterkiefer wurde für diesen Vergleich bewusst in statischer Ruhe gehalten

Ergebnis:

- Halsanschluss bleibt geschlossen/plausibel
- kein sichtbares Ausrenken
- Ausschlag ist deutlich genug lesbar
- der primitive Cutout-/Puppeneffekt bleibt erhalten

Der erste getestete Bereich wurde deshalb direkt als final übernommen. Es gab **keinen verworfenen Head-Winkelbereich** und keine zusätzliche Transformkorrektur.

### Runtime-Änderung

Scene-Commit:

- `14eb13dd8d6c5e6c4d3097778a848aa00b6f4918` — `Add minimal head rotation test`

Zwischen Ausgangs-HEAD und diesem Runtime-Commit wurde ausschließlich `scenes/horse_cutout_rig.tscn` verändert. Der Scene-Diff enthält nur die zusätzlichen HeadPivot-Animationseinträge; keine Asset-, Script-, Farm- oder Bein-Datei wurde verändert.

Unverändert blieben insbesondere:

- `HeadPivot.position = (321.171, -194.253)`
- `HeadPivot.scale = 0.42439`
- `HeadPivot.z_index = 10`
- `HeadUpper.position = (311, -199)`
- kompletter Jaw-Track aus Schritt 7
- `JawPivot.position = (340, -110)`
- statische Jaw-Ruhe-Rotation `-0.331613 rad`
- Jaw-Asset-Offset, -Rotation und -Scale
- Body
- Tail
- alle vier Beine und alle zwölf Beinsegmente
- sämtliche Near/Far-Layer
- `scenes/main.tscn`
- `scripts/main.gd`
- Farm-/Perspektivsystem
- alle bestätigten Runtime-Assets

`docs/HORSE_LEG_RIG.md` wurde bewusst nicht geändert, weil kein Beinwert betroffen war.

### Finale technische Validierung

Separater Step-8-Workflow:

- Workflow-Commit: `433f5e8ef1c40c4100d4c02ad89a9bdb9ad0e3c7`
- Workflow-Run: `36349290047` — **success**
- Ergebnis-Commit: `aad0cb473b6a15a65c70b301ed13156a676ead42`

Bestätigt:

- Asset-Integrität: **success**
- Godot 4.3 Headless: **success**
- Runtime-Scene lädt: **success**
- `AnimationPlayer` vorhanden
- Autoplay `jaw_test` bestätigt
- Loop und Länge `0.6 s` bestätigt
- Step-7-Jaw-Track vollständig unverändert bestätigt
- `JawPivot` ist weiterhin direktes Kind von `HeadPivot`
- neuer `HeadPivot:rotation`-Track vorhanden
- alle vier Head-Keyframe-Zeiten und -Werte bestätigt
- RESET-Werte für Jaw und Head bestätigt
- Android Debug Export: **success**
- APK SHA-256: `e7b953dd702ecf8c4f1743db06769619cec3cc2a3248f2a4d6782e11f0588e60`

Damit ist **Schritt 8 abgeschlossen**.

Es wurde ausdrücklich **keine** Schweifanimation, Walk-Animation oder Farm-Integration begonnen.

## Rig-Meilenstein — primitive Schweifrotation

Abgeschlossen am 2026-09-27.

### Ziel

Der bereits montierte Schweif bewegt sich ausschließlich durch einfache Rotation von `TailPivot`. Die Bewegung bleibt bewusst primitiv und etwas unregelmäßig. Es wurde keine Physiksimulation, kein Bone-System und kein Secondary-Motion-System eingeführt.

### Ausgangszustand

Vor Schritt 9 wurde GitHub `main` erneut direkt geprüft:

- Ausgangs-HEAD: `846badeadbe696238e13042ba48f7b0d1c3b6e50`
- `main` war exakt identisch mit dem Step-8-Cleanup-HEAD
- `TailPivot.position = (-449, -198)`
- `TailPivot.rotation = 0 rad`
- `TailPivot.z_index = -1`
- `Tail.position = (-102.18, 270.66)`
- `Tail.scale = 0.39`
- Head- und Jaw-Animation aus Schritt 8/7 waren unverändert vorhanden

### Implementierung

Damit der Schweif unabhängig vom bestehenden Jaw-/Head-Test laufen kann, wurde ein eigener zweiter `AnimationPlayer` ergänzt:

- Node: `TailAnimationPlayer`
- Autoplay: `tail_test`
- Loop: aktiv
- Länge: `1.1 s`
- Track: `TailPivot:rotation`
- Interpolation: einfache lineare Value-Interpolation

Zusätzlich existiert für diesen Player eine eigene `RESET`-Animation, die `TailPivot.rotation` exakt auf `0 rad` setzt.

Scene-Commit:

- `cfd7bb9d2aff2866fc7f7497251ff8e6c88fb062` — `Add primitive tail rotation test`

Erster getesteter Bewegungsbereich:

- `0.00 s` → `0 rad` = `0°` Ruhe
- `0.30 s` → `0.0872665 rad` ≈ `+5°`
- `0.68 s` → `-0.0698132 rad` ≈ `-4°`
- `0.88 s` → `0.0349066 rad` ≈ `+2°`
- `1.10 s` → `0 rad` = `0°` Ruhe

Die asymmetrischen Winkel und Zeiten sind absichtlich gewählt, damit der Schweif nicht wie ein perfekt gleichmäßiges Pendel wirkt.

### Erste technische CI des Runtime-Commits

Direkt auf dem Scene-Commit liefen die bestehenden Projektprüfungen erfolgreich:

- Godot-Projektvalidierung: Run `36350141541` — **success**
- Android-Debug-Build: Run `36350141595` — **success**

Damit war bereits vor der visuellen Prüfung bestätigt, dass der neue `TailAnimationPlayer` die Scene nicht technisch beschädigt.

### Visuelle Prüfung

Temporärer Preview-Workflow:

- Workflow-Commit: `7413945b3971ad924b070779c14a7db9b447f7ac`
- Preview-Ergebnis: `68d0fd0eeb33de4aed8be97b59e882ef8b144e42`
- Preview-Run: `36350245797` — **success**
- Asset-Integrität: **success**
- Godot 4.3 Headless: **success**

Der Vergleich zeigte:

- Ruhe bei `0°`
- positiven Ausschlag bei `+5°`
- negativen Ausschlag bei `-4°`
- Kopf und Unterkiefer für den visuellen Vergleich bewusst statisch in Ruhe

Ergebnis:

- Schweifansatz bleibt sauber hinter dem Körper verdeckt
- keine sichtbare Lücke am Ansatz
- Bewegung ist klar erkennbar, aber nicht übertrieben
- der Cutout-/Puppencharakter bleibt erhalten

Der erste getestete Bereich wurde deshalb direkt als final übernommen. Es gab **keinen verworfenen Tail-Winkelbereich** und keinen Korrekturcommit.

### Unverändert

Schritt 9 verändert ausschließlich die primitive Schweifanimation und ergänzt dafür den separaten `TailAnimationPlayer`.

Unverändert blieben insbesondere:

- `TailPivot.position = (-449, -198)`
- `TailPivot.z_index = -1`
- `Tail.position = (-102.18, 270.66)`
- `Tail.scale = 0.39`
- gesamter Step-7-Jaw-Track
- gesamter Step-8-Head-Track
- `HeadPivot`- und `JawPivot`-Transforms
- Body
- alle vier Beine und alle zwölf Beinsegmente
- sämtliche Near/Far-Layer
- `scenes/main.tscn`
- `scripts/main.gd`
- Farm-/Perspektivsystem
- alle bestätigten Runtime-Assets

`docs/HORSE_LEG_RIG.md` wurde bewusst nicht geändert, weil kein Beinwert betroffen war.

### Finale technische Validierung

Separater Step-9-Workflow:

- Workflow-Commit: `f73d1136059821a5ca92c40e78f1d01b541b434e`
- Workflow-Run: `36350319921` — **success**
- Ergebnis-Commit: `2fe032e831c8332227a65cf835ec125513534721`

Bestätigt:

- Asset-Integrität: **success**
- Godot 4.3 Headless: **success**
- Runtime-Scene lädt: **success**
- bestehender Jaw-Track vollständig unverändert: **success**
- bestehender Head-Track vollständig unverändert: **success**
- `TailAnimationPlayer` vorhanden
- Autoplay `tail_test` bestätigt
- Loop und Länge `1.1 s` bestätigt
- Track `TailPivot:rotation` bestätigt
- alle fünf Tail-Keyframe-Zeiten und -Werte bestätigt
- Tail-RESET auf `0 rad` bestätigt
- statische TailPivot-Position und Layering bestätigt
- Android Debug Export: **success**
- APK SHA-256: `d0f4c21f8681179c150277cfe5e22a569ac5c5527166a0218eda2c32ecc6a9ea`

Damit ist **Schritt 9 abgeschlossen**.

Es wurde ausdrücklich **keine** Walk-Animation und keine Farm-Integration begonnen.

## Rig-Meilenstein — erster bewusst billiger Walk-Test

Abgeschlossen am 2026-09-27.

### Ziel

Der vollständige Standalone-Cutout soll erstmals eine einfache Laufbewegung zeigen, ohne daraus eine realistische Pferde-Ganganalyse zu machen.

Verbindlich blieb:

- Segmentrotation statt IK
- leichte Asynchronität
- kleine primitive Körperbewegung
- keine Asset-Neugenerierung
- keine Farm-Integration
- kein Animieren des gesamten Rig-Roots, damit die spätere Farm-Positionierung nicht überschrieben wird

Detailwerte aller zwölf Bein-Rotationstracks sind dauerhaft in `docs/HORSE_LEG_RIG.md` dokumentiert.

### Ausgangszustand

- Step-10-Ausgangs-HEAD: `5026bc227da6dde89a8097226fe0a23988818160`
- dieser HEAD war exakt der bereinigte Abschluss von Schritt 9
- alle statischen Bein-, Body-, Head-, Jaw- und Tail-Transforms waren unverändert
- bestehende `jaw_test`-, HeadPivot- und `tail_test`-Animationen waren weiterhin korrekt vorhanden

### Eigener WalkAnimationPlayer

Neu ergänzt:

- Node: `WalkAnimationPlayer`
- Animation: `walk_test`
- Autoplay: aktiv
- Loop: aktiv
- Länge: `1.2 s`
- eigene `RESET`-Animation

Final enthält `walk_test` exakt **15 Tracks**:

- 4 × Bein-Root/Upper-Rotation
- 4 × LowerPivot-Rotation
- 4 × HoofPivot-Rotation
- 3 × Position für `Body`, `HeadPivot`, `TailPivot`

Die RESET-Animation enthält dieselben 15 Eigenschaften mit den bestätigten Ruhewerten.

### Aufbau in kleinen Runtime-Schritten

1. Nur Bein-Roots / proximale Segmente:
   - Commit `684642a7e87ba86d9ba854a9484a4bf08008c078`
   - diagonal gegeneinander, leicht asynchron
   - maximale Root-Ausschläge zwischen ungefähr `-5°` und `+6°`

2. LowerPivot-Gegenbewegung:
   - Commit `68dfdc73268568a36875344e45f911cf1aac7d56`
   - maximale Lower-Ausschläge zwischen ungefähr `-8°` und `+6°`

3. HoofPivot-Gegenrotation:
   - Commit `a659d41dfe39cc46cf40955047225db249a852a6`
   - bewusst kleiner Bereich zwischen ungefähr `-3°` und `+4°`

4. Kleiner Torso-Bob:
   - Commit `bfa96169aae7e1b852a5e0c6133b8e162a8a96d1`
   - bewegt ausschließlich `Body`, `HeadPivot` und `TailPivot` gemeinsam
   - Y-Deltas über den Zyklus: `0 / -3 / +2 / -2 / 0 px`
   - Rig-Root selbst bleibt unangetastet

Es wurde kein zusätzliches Gleiten in die Standalone-Animation eingebaut. Horizontale Fortbewegung bleibt Aufgabe des späteren Farm-/Movement-Systems.

### Visuelle Prüfung

Temporärer Walk-Preview-Workflow:

- Workflow-Basis: `a81a01b810613a0024bbbee7f147b3aa52fce608`
- Root-only Preview: `3a044616e50e5bc8f53a03a9ed6c3872032079b3`
- Lower-Preview: `8b4d492ba4ba8b5d3983d5b937ecf84154c0158f`
- Hoof-Preview: `d362cbf3372277d75756a6fd1e7e0103c08259d2`

Vor dem Torso-Bob wurde das Prüfwerkzeug separat um Positions-Tracks erweitert:

- `d10aa0f2123cd1bbb19cce0dcbbd3d46c94b7f18` — Preview unterstützt Rotation + Position
- `6f3015a0824818b2f4c8eed7271421d155914d75` — Verifikations-Preview

Beim ersten Torso-Bob-Preview trat ausschließlich im Prüfwerkzeug ein Fehler auf:

- fehlgeschlagener Preview-Run: `36351647438`
- Runtime/Godot innerhalb dieses Runs: **success**
- Ursache: `Vector2(...)`-Regex im Python-Preview war zu stark escaped und erkannte keine Positionswerte
- kleinster Fix: `d0d3d261c032d7adcef1a55393906034172f6185`
- korrigierter Preview-Run: `36351702096` — **success**
- finaler visueller Nachweis: `9b74b73e3229c596aeb13d15c43e8538da06c099`

Ergebnis der finalen Sichtprüfung:

- alle Segmentanschlüsse bleiben geschlossen
- keine neue transparente Gelenklücke
- Root-, Lower- und Hoof-Bewegungen sind klar lesbar
- Bewegung bleibt absichtlich steif und puppig
- der kleine Torso-Bob erzeugt Bewegung, ohne sichtbar auszurenken
- kein finaler Winkelbereich musste nach der vollständigen Preview korrigiert werden

### Unverändert

Schritt 10 verändert keine bestätigten statischen Rig-Transforms und keine Runtime-Assets.

Unverändert bleiben insbesondere:

- alle vier Bein-Root-Positionen und Scales
- sämtliche LowerPivot- und HoofPivot-Positionen
- alle Near/Far-Layer
- HindFar-Sonderkorrekturen
- AtlasTexture-Regions
- Body-Ruheposition
- HeadPivot-Ruheposition/-Rotation/-Scale
- Jaw-Ruheposition und Step-7-Jaw-Werte
- Step-8-Head-Rotationswerte
- TailPivot-Ruheposition und Step-9-Tail-Werte
- `scenes/main.tscn`
- `scripts/main.gd`
- Farm-/Perspektivsystem
- alle bestätigten Bildassets

### Finale technische Validierung

Finaler Step-10-Workflow:

- Workflow-Commit: `64aba17d30447a6b15d3ae2f4da013961a4d0651`
- Workflow-Run: `36351805073` — **success**
- Ergebnis-Commit: `844f3664edcadcaeac5cefb789f50ac8f1a21e0d`

Bestätigt:

- Asset-Integrität: **success**
- Godot 4.3 Headless: **success**
- Runtime-Scene lädt: **success**
- Step-7-Jaw-Track unverändert: **success**
- Step-8-Head-Track unverändert: **success**
- Step-9-Tail-Track unverändert: **success**
- `WalkAnimationPlayer`: vorhanden
- Autoplay `walk_test`: bestätigt
- Loop: bestätigt
- Länge: `1.2 s`
- Walk-Track-Anzahl: `15`
- RESET-Track-Anzahl: `15`
- 4 Root-/Upper-Tracks: bestätigt
- 4 LowerPivot-Tracks: bestätigt
- 4 HoofPivot-Tracks: bestätigt
- 3 Torso-Positions-Tracks: bestätigt
- statische Standpose-Transforms: bestätigt
- Android Debug Export: **success**
- APK SHA-256: `1f8359f2f6c460b2e3e0fce354148a4ac9b09d8633b83e6468eaba7f7f60e517`

Damit ist **Schritt 10 abgeschlossen**.

Es wurde ausdrücklich **keine Farm-Integration** begonnen.

## Farm-Meilenstein — Cutout-Rig in bestehende Farm integriert

Schritt 11 wurde am 2026-09-27 technisch abgeschlossen.

- ursprünglicher sichtbarer Node: `HorseRoot/HorseMaster` (`Sprite2D`)
- neuer sichtbarer Pfad:
  `HorseRoot/HorseVisual/RigSpace/HorseCutoutRig`
- Ground-Anchor-Offset: `(0, -516.7995)`
- fester Rig-Integrationsscale: `0.701686`
- die bestehende kalibrierte 1/Z-Perspektivformel bleibt unverändert auf `HorseRoot`
- RIGHT/LEFT wird ausschließlich durch X-Spiegelung des gesamten `HorseVisual` umgesetzt
- Touch/Drag, Hindernisgrenzen, extreme Kameranähe und World-Z wurden unter Godot 4.3 Runtime-validiert
- sechs echte Farm-Runtime-Previewfälle FAR/MID/NEAR × RIGHT/LEFT wurden geprüft
- `horse_cutout_rig.tscn` blieb bytegenau unverändert gegenüber Step 10:
  SHA-256 `328edf3d34090b08f4e729c690f04c36ad3f69f4d9d6813145bf73f9315cf96e`
- finaler Runtime-Commit:
  `bfba37dbc058de129e2f2605a015241ae6bca2e7`
- finaler Validierungs-Run: `36354264467` — **success**
- Android Debug Export: **success**
- Step-11-APK SHA-256:
  `782dfed3cb22d7fd38ad52f9402cacacc75a60de86b4be08465266097c4be4de`
- sämtliche temporären Step-11-Preview-, Probe- und Validierungsdateien wurden nach gesicherter Dokumentation einzeln entfernt
- finaler Diff gegen den Step-10-Abschluss enthält nur `scenes/main.tscn`, `scripts/main.gd`, `docs/MASTER_SPEC.md` und die neue `docs/FARM_RIG_INTEGRATION.md`
- Detailaudit: `docs/FARM_RIG_INTEGRATION.md`

## Aktuell nächste technische Aufgabe

Erst nach ausdrücklichem `weiter` folgt **Schritt 12: Android-Gerätetest auf dem
Samsung Galaxy Z Fold7 / Android 16**.

Auf echtem Gerät werden dann ausschließlich Integration und Darstellung geprüft:
extreme Kameranähe, Touch/Drag, Richtungswechsel, Walk-Lesbarkeit, Tail, Jaw/Head,
Bodenanker, Perspektivscale, Performance und mögliche Segmentlücken.

Noch **nicht** automatisch beginnen: State-Machine, bewegungsabhängiges Walk,
sprechabhängiger Jaw, Steve, Sound oder weiteres Gameplay.


## Technischer Meilenstein — Step 12 Android-Gerätetest-Fixblock

Umgesetzt am 2026-09-28 als gezielter Fixblock nach dem ersten echten Step-11-Test auf dem Samsung Galaxy Z Fold7. Die Farm-Perspektive, bestätigten Quellassets und der grundsätzliche Cutout-Rig-Aufbau wurden nicht neu erfunden.

### Umgesetzte Runtime-Fixes

- **12A Kopf höher:** `HeadPivot.y -194.253 → -236.253`; RESET- und Walk-Positionskeys identisch mitverschoben. Runtime-Commit `378f8a73a89a419e0d918f139f37ba2b5735309f`.
- **12B Hals-/Kopfüberdeckung:** `HeadPivot.x 321.171 → 303.171`, inklusive Positionskeys; Head-Z `10 → 12`. Runtime-Commit `1b9cd86e118c20ecac2b70a6d8439133dfe15f07`.
- **12C verkehrtes Hinterbein:** komplette bestehende `HindNear`-Kette über Root-X-Scale `-0.5` anatomisch umgerichtet; zugehörige Animationsdrehrichtung angepasst. Runtime-Commit `bd81055911cb30fd86b2eb079502a0126b4de302`.
- **12D äußeres Hinterbein:** `HindFar.x -262 → -330`, ohne Y-/Pivot-/Assetänderung. Runtime-Commit `26ba13c40a27b603f0370f82f5a77759365a6cad`.
- **12E Layering:** eindeutige Tiefe `Tail -2 → HindFar -1 → Body 0 → HindNear +1 → Head 12`. Runtime-Commit `ccd15bfa5d73af62003e90f71fa42d4215c2146b`.
- **12F stärkerer Walk:** vorhandener 1,2-s-Zyklus beibehalten; deutlich größere Root-/Lower-/Hoof-Rotationen und klarere Viertelphasen für besser lesbaren 4-Takt-Charakter. Body-Bob bleibt klein. Runtime-Commit `c2b24d34855bad9995011f74153f5ec8d1051a76`.
- **12G Geschwindigkeitskopplung:** keine Gait-State-Machine; echte Drag-Geschwindigkeit steuert Walk-Playback weich zwischen `0.72×` und `1.60×` sowie die gespeicherte Basisamplitude zwischen `0.86×` und `1.20×`. Runtime-Commit `f3eb8ce362bf413b0d22c979844fbee39473f4ca`.

Die Walk-Phasen orientieren sich am realen 4-Takt-Prinzip des Schritts; Trab/Galopp wurden ausdrücklich noch nicht implementiert.

### Android-Build / automatisierte Prüfung

- Build-/Validierungsbasis: `d10b76b235f8a81cb60d163a8e34f1be7e8af0e0`.
- GitHub-Actions-Run: `36361667754` — **success**.
- automatischer Nachweis-Commit: `ddef8d00606dc4b18f70b857726c429728631c61`.
- Asset-Integrität: **success**.
- Godot 4.3 Headless Parse/Editor: **success**.
- echte Hauptszene headless gestartet: **success**.
- Android Debug Export: **success**.
- APK: `Pferd-und-Steve-step12-debug.apk`.
- Artifact: `Pferd-und-Steve-step12-final-apk` / ID `10945053792`.
- APK SHA-256: `9bc3bb2972905b0e780afa5ad6808517486d0817140e9b4a05b7d541cd9ef648`.

### Testergebnis und Reststatus

Automatisch ist Step 12 technisch grün: Projekt parst, startet und exportiert für Android. Die **visuelle Abnahme auf dem echten Fold mit diesem neuen Step-12-Build steht noch aus** und darf nicht mit dem erfolgreichen CI-Test verwechselt werden.

Beim nächsten Gerätetest werden ausschließlich die Step-12-Ziele erneut bewertet: Kopf/Halsübergang, beide Hinterbeine und Layering, Walk-Lesbarkeit bei langsam/mittel/schnell, LEFT/RIGHT, FAR/MID/NEAR, extreme Nähe, Bodenanker, Segmentlücken, Perspektive, Touch/Drag und Performance. Bis dieser Retest abgeschlossen ist, noch keine Steve-, Sound-, Sprach-Jaw-, Gameplay- oder vollständige Walk/Trot/Canter-State-Machine beginnen.


### Step-12 Recovery nach fehlgeschlagenem echtem Gerätetest

Der erste Step-12-Fixbuild wurde auf dem Samsung Galaxy Z Fold7 verworfen. Der echte Gerätetest zeigte zwei klare Regressionen: beide Hinterbeine wirkten falsch herum und die zuvor validierten Hof-/Hindernisbegrenzungen verhielten sich wieder falsch.

Deshalb gilt ab jetzt:

- Die Step-12-Runtimeänderungen an Hinterbeinen, Walk, Layering und geschwindigkeitsabhängiger Bewegung sind **kein Canon**.
- `scripts/main.gd` ist wieder bytegenau der Step-11-Stand aus `e8771b39dd0f7619a882e78fd6f657d48f46de6b`; Recovery-Commit `c8d10c7a8c84562275b2ec029b8fe281ec5116d0`.
- Beide Hinterbeine und der komplette Walk sind wieder exakt Step 11; Recovery-Commit `7f3b243753080d8ebc26e9c5accf12820bb6793d`.
- Erhalten bleiben ausschließlich die isolierten Kopfkorrekturen aus 12A/12B.
- Der frühere Step-12-Build aus Run `36361667754` und APK-SHA `9bc3bb2972905b0e780afa5ad6808517486d0817140e9b4a05b7d541cd9ef648` ist ausdrücklich **verworfen**.
- Nächster technischer Schritt ist ausschließlich die Wiederbestätigung der stabilen Step-11-Bewegung/Beine mit den Kopfkorrekturen auf echtem Android-Gerät. Vorher keine weiteren Bein-/Walk-/Speed-Experimente.


### Step-12 Recovery-Build technisch bestätigt

Die Recovery-Basis wurde danach mit einem separaten fail-closed Workflow geprüft:

- `scripts/main.gd` musste exakt den Step-11-Git-Blob `a32408d507f0ee1c928c766f214666bedad65175` haben
- `horse_cutout_rig.tscn` musste exakt den Recovery-Git-Blob `0c94231e6e037d2ff32f9a70fe69f459dcc870ac` haben
- Godot 4.3 Headless: **success**
- Runtime-Hauptszene: **success**
- Android Debug Export: **success**
- Workflow-Run: `36362768392`
- Nachweis-Commit: `34c4b02468099a0d71931a122465f2b29ce4c419`
- Recovery-APK SHA-256: `fe86fb4354a07e6fd02a8f7559f4a2f0b7a1d425c838e1c9e9b78d1fd44edc44`

Dieser Recovery-Build ist der aktuelle Retest-Stand. Er enthält **Step-11 Beine, Step-11 Walk und Step-11 Bewegungs-/Hofgrenzen** plus ausschließlich die Kopfkorrekturen 12A/12B.


### Aspect-ratio-feste Farmgrenzen nach Fold-Retest

Der zweite Step-12-Gerätetest zeigte, dass die historische obstacle-aware Grenze zwar code-seitig erhalten war, aber im aktuellen Fold-Querformat 1536×658 visuell nicht mehr auf den Farmhindernissen lag. Ursache: die ursprüngliche Kalibrierung war als direkte Viewport-Ratios aus einem 1536×1384-Testbild gespeichert, während der Hintergrund per `cover` skaliert/gecroppt wird.

Ab Commit `aa07a14d87ed983d2e7268fa701bae528f81f7c2` gelten die Hindernisgrenzen deshalb in **kanonischen 1536×864-Farmtexturkoordinaten** und werden zur Laufzeit mit dem Background-Cover-Transform in den aktuellen Viewport projiziert. Zusätzlich wird die projizierte sichtbare Pferdebreite für Hindernis- und Bildschirmrandprüfungen berücksichtigt.

Wichtig:
- keine Änderung an Pferde-Rig, Beinen oder Walk
- Recovery-Rig-Blob bleibt `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`
- Validierungsrun `36363441866`: **success**
- 1536×658 und 1536×1384 Mapping jeweils automatisiert geprüft
- Android Debug Export: **success**
- APK SHA-256: `a30e097b41782094c1227f865f129d01a84009babda72308763139b35ac67c01`

Nächster Schritt ist ausschließlich der echte Fold-Retest dieser neuen Farmgrenzen.


### Fence-specific Collision-Canon nach Fold-Gerätescreenshots

Die Collision-Zielobjekte wurden anhand echter Screenshots präzisiert:

- kleines 1536×658-Querbild: seitliche Begrenzung = sichtbarer weißer Vordergrund-Zaun ganz rechts (analog links)
- großes 1536×1384-Bild: hintere Begrenzung = weißer horizontaler Zaun in der Bildmitte
- Heuballen und Unterstand sind keine primären Collision-Grenzen

Ab Runtime-Commit `07b575e7e780ba3320bc68f3f89294f7980b5cb3` werden sichtbare seitliche Zaunlinien in Farm-Texturkoordinaten als X-Grenzen benutzt. Durch `cover` aus dem Viewport herausgecroppte Seitenzäune erzeugen keine unsichtbare Wand. Der horizontale hintere Zaun bleibt die Rear-/Depth-Grenze.

Rig/Walk unverändert:
- `horse_cutout_rig.tscn` Blob `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`

Validierung:
- Godot `36364162114`: success
- Android `36364162142`: success
- Artifact `10946946741`
- APK SHA-256 `f5e51d13ff4c5cf599246d959509b5d0a5710a5d2aefeea0f6e8c5cd1c1d8e37`

Nächster Schritt: ausschließlich echter Fold-Retest dieser Zaungrenzen.


## OBERSTE ARBEITSREGEL — BESTÄTIGTE FUNKTIONEN SIND EINGEFROREN

Diese Regel ist verbindlich und hat Vorrang vor späteren Optimierungs-, Cleanup- oder Refactoring-Ideen.

Sobald der Nutzer einen Zustand ausdrücklich als **funktionierend**, **sauber**, **fertig**, **bestätigt**, **abgelegt** oder sinngleich akzeptiert hat:

- dieser technische Zustand gilt als **IMMUTABLE / FROZEN BASELINE**
- der zugehörige Code darf in späteren Arbeiten **nicht mitverändert, refaktoriert, neu interpretiert oder "verbessert"** werden
- Änderungen an anderen Systemen müssen so isoliert werden, dass die eingefrorene Funktion unverändert bleibt
- ein bestätigtes System darf erst wieder geändert werden, wenn der Nutzer **ausdrücklich genau dieses System** zur Änderung freigibt
- bei Unsicherheit gilt: **nicht ändern**
- vor jeder Runtime-Änderung ist zu prüfen, ob der betroffene Code zu einem bestätigten/abgelegten Stand gehört
- wenn eine spätere Änderung versehentlich eine bestätigte Funktion regressiert, muss auf den letzten explizit bestätigten Snapshot zurückgegangen werden; keine freie Rekonstruktion und kein erneutes Raten

### Aktuell eingefrorene historische Farmbewegungs-Baseline

Der Git-Verlauf enthält einen ausdrücklich als vom Nutzer bestätigt dokumentierten Stand:

- Collision-/Ground-Boundary-Implementierung: `d5d3ff9ca32968f035d304176668eb2a326578ad` — `Add obstacle-aware physical ground boundary`
- Bestätigungs-/Canon-Dokumentation: `f34c9142c67c388758d7749fca2536ea51734b9d` — `Record approved perspective and calibrated yard boundaries`

Die danach entstandenen Collision-Experimente aus Step 12 dürfen **nicht** als Begründung verwendet werden, diesen bestätigten Zustand frei neu zu erfinden. Jede weitere Collision-Recovery muss zuerst diesen bestätigten Snapshot als Quelle verwenden und darf andere bereits bestätigte Systeme nicht verändern.

## FROZEN USER-APPROVED BASELINES

Dieser Bereich ist die verbindliche Registry für vom Nutzer ausdrücklich bestätigte
Systeme. Ein Eintrag mit Status **FROZEN** darf weder refaktoriert noch nebenbei
angepasst werden. Änderungen sind nur nach ausdrücklicher Freigabe genau dieses
Subsystems erlaubt.

### Farm Collision — historisch user-approved

- System: physischer Hof-Laufraum / obstacle-aware hintere Bodengrenze
- Status: **FROZEN — historische Semantik**
- Ursprünglicher Runtime-Commit:
  `d5d3ff9ca32968f035d304176668eb2a326578ad`
- Bestätigungs-/Canon-Commit:
  `f34c9142c67c388758d7749fca2536ea51734b9d`
- Kalibrierungsdokumentation:
  `bd064faffffcde52f494886b81d6215dd18f2560`
- historischer `main.gd`-Blob am Runtime-Commit:
  `29d39e8a5f373014178e6e2d46f4d5bb9674fd61`
- Gerätetest: Samsung Galaxy Z Fold / realer Fold-Test 2026-09-27
- Freigabegrund:
  Nah-/Fernskalierung, hintere Hofgröße und die kalibrierten physischen
  Hofgrenzen wurden vom Nutzer als funktionierend bestätigt.
- Verbindliche Collision-Semantik:
  - offener hinterer Hof `0.565`
  - Hindernisbereiche `0.585`
  - äußerste Bereiche `0.600`
  - X-Stützstellen `0.00 / 0.36 / 0.43 / 0.80 / 0.87 / 1.00`
  - Projection-to-legal-ground statt frei erfundener Bounding-Box-Physik
- Do not modify without explicit user permission.

Wichtig: Dieser FROZEN-Eintrag schützt die **bereits damals bestätigte Semantik**.
Er bedeutet nicht, dass jeder spätere technische Recovery-Build automatisch erneut
auf allen Fold-Zuständen abgenommen ist.

### Aktueller integrierter Collision-Recovery-Kandidat

- Status: **AWAITING USER DEVICE APPROVAL — noch nicht als neuer Baseline-Snapshot eingefroren**
- Recovery-Runtime-Commit:
  `fd0962080edf756030a0b2a5a06cb5c1315ea859`
- `scripts/main.gd`:
  `a32408d507f0ee1c928c766f214666bedad65175`
- `scenes/main.tscn`:
  `336c90377be17ac57fe9b611a455ee544da6ba85`
- `scenes/horse_cutout_rig.tscn`:
  `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`
- Rig/Walk/Head/Assets wurden durch den Collision-Recovery-Commit nicht verändert.
- Cutout-Adapter: **nicht erforderlich**.
  `HorseRoot` blieb bei der Cutout-Integration derselbe physische Welt-/Bodenanker;
  `RigSpace.scale = 0.701686` und
  `HorseCutoutRig.position.y = -516.7995` bilden das Rig auf denselben
  historischen Kalibrierraum ab.
- Technischer Recovery-Validator:
  Commit `dc7924ac79ea244b0343e33f156a4fc02962e912`,
  Run `36368232364` — **success**.
- Android-Testartefakt:
  `Pferd-und-Steve-approved-collision-recovery-debug.apk`
- Artifact-ID: `10947917953`
- APK SHA-256:
  `d0b6d9995f9d2b4df837ed7b8fc6c61f0b1a61baacd51fbda8b2980aac86452c`
- Gerätetest: **ausstehend auf Samsung Galaxy Z Fold7 / Android 16**

Nach ausdrücklicher Nutzerbestätigung „Kollision passt jetzt“ oder sinngleich wird
dieser integrierte Recovery-Snapshot mit seinem dann aktuellen Commit, allen
relevanten Blobs, APK-SHA, Datum und Geräteteststatus als **FROZEN / USER APPROVED**
in dieser Registry festgeschrieben.

### Verworfene Collision-Experimente — ausdrücklich kein Canon

Die folgenden Runtime-Commits dürfen nicht als Quelle einer neuen Collision-Recovery
verwendet werden:

- `aa07a14d87ed983d2e7268fa701bae528f81f7c2`
  — `Make farm obstacle boundaries aspect-ratio aware`
- `07b575e7e780ba3320bc68f3f89294f7980b5cb3`
  — `Use visible farm fences as movement boundaries`

Die Git-Analyse zeigte als Ursache der Regression nicht das Cutout-Rig, sondern die
spätere Änderung der Collision-Semantik: Source-Space-/Cover-Mapping,
geschätzte Pferdebreite, Mehrfach-Probes, iterative X-/Depth-Clamps und anschließend
Side-Fence-Grenzen ersetzten den zuvor bestätigten normierten Hof-Laufraum.

### Pending Collision Candidate — exact visible cutout bounds

Ein neuer, technisch validierter Collision-Kandidat liegt vor, ist aber **noch nicht
USER APPROVED / FROZEN**.

Runtime-Commit:
`98eb642fa4399d2bd5b7f649118a6cec0b3960a5`
— `Resolve farm collision from exact cutout bounds`.

Grund für diesen Ansatz:

Die bisherigen Screenshots zeigen, dass der historische `HorseRoot` legal sein kann,
obwohl sichtbare Teile des heutigen Cutout-Rigs bereits Heuballen, Unterstand,
Seitenzaun oder Bildschirmrand schneiden. Deshalb wird die bestätigte historische
Hofkurve nicht ersetzt, sondern jetzt über die **tatsächliche sichtbare X-Spanne aller
aktuellen Sprite2D-Teile** ausgewertet.

Explizit keine Schätzung:
- keine `HORSE_HALF_WIDTH_TO_PROJECTED_HEIGHT`
- keine erfundene pauschale Pferdebreite
- keine Änderung am Rig

Frozen-Blobs weiterhin:
- `scenes/main.tscn`: `336c90377be17ac57fe9b611a455ee544da6ba85`
- `scenes/horse_cutout_rig.tscn`: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`

Runtime-Validator:
- Commit `eeadb4585bddd63dff1e0959bcb0efd0dcb13cd3`
- Run `36374011658`: **success**
- beide Fold-Formate, beide Richtungen, extreme X- und Tiefenproben geprüft

Android:
- Build-Run `36373925737`: **success**
- Artifact-ID `10949734349`
- APK SHA-256
  `b8af37bb6b6c21c5620472b72bdfb760fd02e77889a53c560ae997798d371feb`

Status:
**AWAITING REAL Z FOLD7 DEVICE APPROVAL**.

Nur wenn der Nutzer diesen konkreten Stand ausdrücklich bestätigt, wird er als
neuer integrierter Collision-Snapshot unter
`FROZEN USER-APPROVED BASELINES` festgeschrieben.

